-- Define craftable items (server-side only) with specific crafting times
local craftableItems = {
    { id = 1, name = "pcp", displayName = "PCP", itemID = 43, materials = { { id = 33, quantity = 2 }, { id = 34, quantity = 1 } }, time = 3 },       
    { id = 2, name = "redbandana", displayName = "Red Bandana", itemID = 123, materials = { { id = 160, quantity = 1 } }, time = 3 }, 
    { id = 3, name = "cocaine", displayName = "Cocaine", itemID = 50, materials = { { id = 42, quantity = 3 } }, time = 7 },
    { id = 4, name = "cocainee", displayName = "Cocaine Brick", itemID = 51, materials = { { id = 43, quantity = 2 } }, time = 10 },
    { id = 5, name = "meth", displayName = "Meth", itemID = 52, materials = { { id = 44, quantity = 2 }, { id = 42, quantity = 1 } }, time = 6 },
    { id = 6, name = "heroin", displayName = "Heroin", itemID = 53, materials = { { id = 45, quantity = 3 } }, time = 8 },
    { id = 7, name = "heroinn", displayName = "Heroin Brick", itemID = 54, materials = { { id = 46, quantity = 2 }, { id = 44, quantity = 1 } }, time = 12 }
}

local playersInMarker = {}
local activeCraftingSessions = {}

-- Send craftable items to client
addEvent("requestCraftableItems", true)
addEventHandler("requestCraftableItems", root, function()
    if client then
        triggerClientEvent(client, "receiveCraftableItems", client, craftableItems)
    end
end)

-- Crafting function with progress bar update
function craftItem(player, itemID)
    if not playersInMarker[player] then
        outputChatBox("You must be inside the crafting marker to craft.", player, 255, 0, 0)
        return
    end

    if activeCraftingSessions[player] then
        outputChatBox("You are already crafting an item. Please wait.", player, 255, 0, 0)
        return
    end

    local foundItem = nil
    for _, item in ipairs(craftableItems) do
        if item.id == itemID then
            foundItem = item
            break
        end
    end

    if foundItem then
        for _, material in ipairs(foundItem.materials) do
            if exports["item-system"]:countItems(player, material.id) < material.quantity then
                outputChatBox("You do not have enough materials for " .. foundItem.displayName .. ".", player, 255, 0, 0)
                return
            end
        end

        local craftingTime = foundItem.time * 1000 -- Convert seconds to milliseconds
        activeCraftingSessions[player] = true
        triggerClientEvent(player, "startCraftingProgress", player, foundItem.displayName, craftingTime)

        setTimer(function()
            if isElement(player) and playersInMarker[player] then
                for _, material in ipairs(foundItem.materials) do
                    for i = 1, material.quantity do
                        exports["item-system"]:takeItem(player, material.id)
                    end
                end

                local giveSuccess = exports["item-system"]:giveItem(player, foundItem.itemID, 1)
                if giveSuccess then
                    outputChatBox("You crafted a " .. foundItem.displayName .. "!", player, 0, 255, 0)
                else
                    outputChatBox("Failed to give item. Inventory might be full.", player, 255, 0, 0)
                end
            else
                outputChatBox("Crafting canceled. You left the area.", player, 255, 0, 0)
            end
            activeCraftingSessions[player] = nil
            triggerClientEvent(player, "stopCraftingProgress", player)
        end, craftingTime, 1)

        return
    end

    outputChatBox("Invalid item ID.", player, 255, 0, 0)
end

-- Marker system
local markerX, markerY, markerZ = 2779.9921875, -2417.47265625, 13.635567665 - 1
local craftingMarker = createMarker(markerX, markerY, markerZ, "cylinder", 1.5, 255, 0, 0, 150)

function onPlayerEnterMarker(hitPlayer)
    if getElementType(hitPlayer) == "player" then
        playersInMarker[hitPlayer] = true
        outputChatBox("Type /craft to open the menu.", hitPlayer, 0, 255, 0)
    end
end
addEventHandler("onMarkerHit", craftingMarker, onPlayerEnterMarker)

function onPlayerLeaveMarker(hitPlayer)
    if getElementType(hitPlayer) == "player" then
        playersInMarker[hitPlayer] = nil
        triggerClientEvent(hitPlayer, "stopCraftingProgress", hitPlayer)

        if activeCraftingSessions[hitPlayer] then
            activeCraftingSessions[hitPlayer] = nil
        end
    end
end
addEventHandler("onMarkerLeave", craftingMarker, onPlayerLeaveMarker)

-- Handle crafting request
addEvent("requestCrafting", true)
addEventHandler("requestCrafting", root, function(itemID)
    if client then
        craftItem(client, itemID)
    end
end)