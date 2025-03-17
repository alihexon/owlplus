-- Define materials and their prices
local materials = {
    {name = "Rubber", price = 1},
    {name = "Plastic", price = 2},
    {name = "Iron", price = 3},
    {name = "Steel", price = 4},
    {name = "Aluminum", price = 5},
    {name = "Metalscrap", price = 6},
    {name = "Copper", price = 7},
    {name = "Glass", price = 8}
}

-- Create 6 pickup markers at different positions
local pickupMarkers = {}
local markerPositions = {
    {936, -1117, 24 - 1},
    {938, -1120, 24 - 1},
    {940, -1122, 24 - 1},
    {942, -1125, 24 - 1},
    {944, -1127, 24 - 1},
    {946, -1130, 24 - 1}
}

-- Initialize markers
for i, pos in ipairs(markerPositions) do
    pickupMarkers[i] = createMarker(pos[1], pos[2], pos[3], "cylinder", 1.5, 0, 255, 0, 150)
    setElementData(pickupMarkers[i], "active", false)  -- Initially set markers as inactive
    setElementVisibleTo(pickupMarkers[i], root, false)  -- Hide all markers initially
end

-- Create the second marker for drop-off (kept invisible initially)
local secondMarker = createMarker(930, -1119, 23, "cylinder", 1.5, 255, 0, 0, 150)
setElementVisibleTo(secondMarker, root, false)

-- Table to track player's progress
local playerProgress = {}

-- Function to randomly show one of the pickup markers
function showRandomPickupMarker()
    -- Hide all markers and set them to inactive
    for i = 1, #pickupMarkers do
        setElementVisibleTo(pickupMarkers[i], root, false)
        setElementData(pickupMarkers[i], "active", false)
    end

    -- Randomly select one marker and make it visible, set it to active
    local randomIndex = math.random(1, #pickupMarkers)
    setElementVisibleTo(pickupMarkers[randomIndex], root, true)
    setElementData(pickupMarkers[randomIndex], "active", true)
end

-- Call the function to show the first random marker when the script runs
showRandomPickupMarker()

-- Function to handle when a player enters any marker
function onPlayerMarkerHit(hitMarker, matchingDimension)
    local player = source

    -- Check if the player is entering any of the first markers (grabbing the box)
    for i, marker in ipairs(pickupMarkers) do
        if hitMarker == marker and matchingDimension then
            -- Check if the marker is active
            if getElementData(marker, "active") then
                -- If the player already grabbed a box but didn't deliver it, show an error message
                if playerProgress[player] and playerProgress[player].grabbedBox and not playerProgress[player].placedBox then
                    outputChatBox("Shoma ghablan yek box bardashtid, on ro tahvil bedid.", player, 255, 0, 0) -- Error message
                    return
                end

                -- Randomly select a material and its price
                local selectedMaterial = materials[math.random(1, #materials)]

                -- Save that the player has grabbed a box and its material
                playerProgress[player] = playerProgress[player] or {}
                playerProgress[player].grabbedBox = true
                playerProgress[player].material = selectedMaterial.name
                playerProgress[player].materialPrice = selectedMaterial.price
                playerProgress[player].pickupMarker = i -- Track which marker the player interacted with

                -- Output message with the selected material
                outputChatBox("Shoma yek box bardashtid. Material: " .. selectedMaterial.name, player, 255, 255, 255)

                -- Hide the current marker once the box is grabbed
                setElementVisibleTo(marker, root, false)
                setElementData(marker, "active", false)  -- Mark the current marker as inactive

                -- Make the second marker visible
                setElementVisibleTo(secondMarker, root, true)

                break
            end
        end
    end

    -- Check if the player is at the drop-off marker (second marker)
    if hitMarker == secondMarker and matchingDimension then
        -- Check if the player has grabbed a box before placing it
        if playerProgress[player] and playerProgress[player].grabbedBox then
            -- Save that the player has placed the box
            playerProgress[player].placedBox = true

            -- Reward the player with the payment based on the material's price
            local payment = playerProgress[player].materialPrice
            exports.global:giveMoney(player, payment)

            -- Output the success message with the variable payment
            outputChatBox("Shoma box ro gozashtid va $".. payment .." daryaft kardid. Material: " .. playerProgress[player].material, player, 255, 255, 255)

            -- Reset progress for the player so they can grab the next box
            playerProgress[player] = nil -- Reset everything

            -- Randomize and show a new pickup marker for the player
            showRandomPickupMarker()

            -- Hide the second marker again after delivery
            setElementVisibleTo(secondMarker, root, false)
        else
            -- Output a message if the player tries to place the box without grabbing it
            outputChatBox("Shoma ghablan box ro bardashtid.", player, 255, 0, 0) -- Red message for failure
        end
    end
end

-- Attach the event globally
addEventHandler("onPlayerMarkerHit", root, onPlayerMarkerHit)
