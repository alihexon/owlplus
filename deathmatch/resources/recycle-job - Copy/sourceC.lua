-- Table to store markers for each player (Client-Side)
local playerMarkers = {}

-- Function to create markers for a player (Client-Side)
addEvent("createMarker", true)
addEventHandler("createMarker", root, function(player, x, y, z, index)
    if player == localPlayer then
        local marker = createMarker(x, y, z, "cylinder", 1.5, 0, 255, 0, 150)
        setElementData(marker, "active", false)  -- Initially set markers as inactive
        setElementVisibleTo(marker, player, false)  -- Hide markers initially for the player
        playerMarkers[index] = marker
    end
end)

-- Function to show a random marker for the player (Client-Side)
function showRandomPickupMarkerForPlayer()
    -- Hide all markers for this player and set them to inactive
    for i, marker in ipairs(playerMarkers) do
        setElementVisibleTo(marker, localPlayer, false)
        setElementData(marker, "active", false)
    end

    -- Randomly select one marker and make it visible, set it to active
    local randomIndex = math.random(1, #playerMarkers)
    local selectedMarker = playerMarkers[randomIndex]

    setElementVisibleTo(selectedMarker, localPlayer, true)
    setElementData(selectedMarker, "active", true)
end

-- Show a random marker when the player joins the game
addEventHandler("onClientResourceStart", resourceRoot, function()
    showRandomPickupMarkerForPlayer()
end)

-- Function to hide a marker when the player interacts with it (Client-Side)
addEvent("hideMarker", true)
addEventHandler("hideMarker", root, function(player, index)
    if player == localPlayer then
        local marker = playerMarkers[index]
        if marker then
            setElementVisibleTo(marker, player, false)
            setElementData(marker, "active", false)
        end
    end
end)

-- Function to show the drop-off marker when a box is grabbed (Client-Side)
addEvent("showDropOffMarker", true)
addEventHandler("showDropOffMarker", root, function()
    -- Show drop-off marker to the player
    -- Assuming a drop-off marker exists as 'secondMarker' in the code
    setElementVisibleTo(secondMarker, localPlayer, true)
end)
