-- Define craftable items with required materials (ignoring quantity)
local craftableItems = {
    { name = "pcp", id = 43, materials = {33, 34} },       
    { name = "redbandana", id = 123, materials = {160} }, 
    { name = "cocaine", id = 50, materials = {42} },
    { name = "cocainee", id = 51, materials = {43} },
    { name = "meth", id = 52, materials = {44, 42} },
    { name = "heroin", id = 53, materials = {45} },
    { name = "heroinn", id = 53, materials = {46, 44} }
}

-- Create crafting marker
local markerX, markerY, markerZ = 2779.9921875, -2417.47265625, 13.635567665 - 1
local craftingMarker = createMarker(markerX, markerY, markerZ, "cylinder", 1.5, 255, 0, 0, 150)

local playersInMarker = {}
local activeCraftingSessions = {}

function craftItem(player, itemName)
    if not playersInMarker[player] then
        outputChatBox("You must be inside the crafting marker to use this command.", player, 255, 0, 0)
        return
    end

    if activeCraftingSessions[player] then
        outputChatBox("You are already crafting an item. Please wait.", player, 255, 0, 0)
        return
    end

    for _, item in ipairs(craftableItems) do
        if item.name == itemName then
            -- Check if the player has all required materials (ignoring quantity)
            for _, materialID in ipairs(item.materials) do
                if not exports["item-system"]:hasItem(player, materialID) then
                    outputChatBox("You do not have the required materials.", player, 255, 0, 0)
                    return
                end
            end

            -- Start crafting process
            activeCraftingSessions[player] = true
            outputChatBox("Processing... Please wait 5 seconds.", player, 0, 255, 0)

            setTimer(function()
                if isElement(player) and playersInMarker[player] then
                    -- Remove one unit of each material (since we're ignoring quantity)
                    for _, materialID in ipairs(item.materials) do
                        exports["item-system"]:takeItem(player, materialID)
                    end

                    -- Give the crafted item
                    local giveSuccess = exports["item-system"]:giveItem(player, item.id, 1)
                    if giveSuccess then
                        outputChatBox("You have crafted a " .. item.name .. "!", player, 0, 255, 0)
                    else
                        outputChatBox("Failed to give item. Inventory might be full.", player, 255, 0, 0)
                    end
                else
                    outputChatBox("Crafting canceled. You left the crafting area.", player, 255, 0, 0)
                end
                activeCraftingSessions[player] = nil
            end, 5000, 1)

            return
        end
    end
    outputChatBox("Invalid item name.", player, 255, 0, 0)
end

-- Marker events
function onPlayerEnterMarker(hitPlayer, matchingDimension)
    if hitPlayer and getElementType(hitPlayer) == "player" and matchingDimension then
        playersInMarker[hitPlayer] = true
        outputChatBox("Type /craft to open the crafting menu.", hitPlayer, 0, 255, 0)
    end
end
addEventHandler("onMarkerHit", craftingMarker, onPlayerEnterMarker)

function onPlayerLeaveMarker(hitPlayer, matchingDimension)
    if hitPlayer and getElementType(hitPlayer) == "player" and matchingDimension then
        playersInMarker[hitPlayer] = nil
        outputChatBox("You left the crafting area.", hitPlayer, 255, 0, 0)

        if activeCraftingSessions[hitPlayer] then
            outputChatBox("Crafting canceled. You left the crafting area.", hitPlayer, 255, 0, 0)
            activeCraftingSessions[hitPlayer] = nil
        end
    end
end
addEventHandler("onMarkerLeave", craftingMarker, onPlayerLeaveMarker)

-- Handle crafting request
addEvent("requestCrafting", true)
addEventHandler("requestCrafting", root, function(itemName)
    if client then
        craftItem(client, itemName)
    end
end)
