-- Define craftable items with required materials (ID and Quantity)
local craftableItems = {
    { name = "pcp", id = 43, materials = { {33, 2}, {34, 1} } },       
    { name = "redbandana", id = 123, materials = { {160, 1} } }, 
    { name = "cocaine", id = 50, materials = { {42, 3} } },
    { name = "cocainee", id = 51, materials = { {43, 2} } },
    { name = "meth", id = 52, materials = { {44, 2}, {42, 1} } },
    { name = "heroin", id = 53, materials = { {45, 3} } },
    { name = "heroinn", id = 53, materials = { {46, 2}, {44, 1} } }
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
            -- Check if the player has the required materials (with quantity)
            for _, material in ipairs(item.materials) do
                local materialID = material[1]
                local requiredQuantity = material[2]
                
                if exports["item-system"]:countItems(player, materialID) < requiredQuantity then
                    outputChatBox("You do not have enough of the required materials.", player, 255, 0, 0)
                    return
                end
            end

            -- Start crafting process
            activeCraftingSessions[player] = true
            outputChatBox("Processing... Please wait 5 seconds.", player, 0, 255, 0)

            setTimer(function()
                if isElement(player) and playersInMarker[player] then
                    -- Recheck if they still have the materials before finalizing
                    for _, material in ipairs(item.materials) do
                        local materialID = material[1]
                        local requiredQuantity = material[2]

                        if exports["item-system"]:countItems(player, materialID) < requiredQuantity then
                            outputChatBox("Crafting failed! You lost or used some materials during crafting.", player, 255, 0, 0)
                            activeCraftingSessions[player] = nil
                            return
                        end
                    end

                    -- Remove required quantity of each material
                    for _, material in ipairs(item.materials) do
                        local materialID = material[1]
                        local requiredQuantity = material[2]
                        exports["item-system"]:takeItem(player, materialID, requiredQuantity)
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
