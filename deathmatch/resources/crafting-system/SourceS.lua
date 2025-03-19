-- Define craftable items with required materials (name first, then displayName)
local craftableItems = {
    { name = "pcp", displayName = "PCP", id = 43, materials = { { id = 33, quantity = 2 }, { id = 34, quantity = 1 } } },       
    { name = "redbandana", displayName = "Red Bandana", id = 123, materials = { { id = 160, quantity = 1 } } }, 
    { name = "cocaine", displayName = "Cocaine", id = 50, materials = { { id = 42, quantity = 3 } } },
    { name = "cocainee", displayName = "Cocaine Brick", id = 51, materials = { { id = 43, quantity = 2 } } },
    { name = "meth", displayName = "Meth", id = 52, materials = { { id = 44, quantity = 2 }, { id = 42, quantity = 1 } } },
    { name = "heroin", displayName = "Heroin", id = 53, materials = { { id = 45, quantity = 3 } } },
    { name = "heroinn", displayName = "Heroin Brick", id = 53, materials = { { id = 46, quantity = 2 }, { id = 44, quantity = 1 } } }
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
            -- Check if the player has the required materials
            for _, material in ipairs(item.materials) do
                if exports["item-system"]:countItems(player, material.id) < material.quantity then
                    outputChatBox("You do not have enough materials for " .. item.displayName .. ".", player, 255, 0, 0)
                    return
                end
            end

            -- Start crafting process
            activeCraftingSessions[player] = true
            outputChatBox("Processing... Crafting " .. item.displayName .. " (5 seconds).", player, 0, 255, 0)

            setTimer(function()
                if isElement(player) and playersInMarker[player] then
                    -- Recheck materials before finalizing
                    for _, material in ipairs(item.materials) do
                        if exports["item-system"]:countItems(player, material.id) < material.quantity then
                            outputChatBox("Crafting failed! You lost or used some materials.", player, 255, 0, 0)
                            activeCraftingSessions[player] = nil
                            return
                        end
                    end

                    -- Remove materials
                    for _, material in ipairs(item.materials) do
                        for i = 1, material.quantity do
                            exports["item-system"]:takeItem(player, material.id)
                        end
                    end

                    -- Give crafted item
                    local giveSuccess = exports["item-system"]:giveItem(player, item.id, 1)
                    if giveSuccess then
                        outputChatBox("You crafted a " .. item.displayName .. "!", player, 0, 255, 0)
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

-- Client-side crafting menu (simplified for your request)
local screenW, screenH = guiGetScreenSize()
local craftingWindow = nil
local craftingList = nil
local craftButton = nil
local closeButton = nil

local craftableItems = {
    { name = "pcp", displayName = "PCP" },
    { name = "redbandana", displayName = "Red Bandana" },
    { name = "cocaine", displayName = "Cocaine" },
    { name = "cocainee", displayName = "Cocaine Brick" },
    { name = "meth", displayName = "Meth" },
    { name = "heroin", displayName = "Heroin" },
    { name = "heroinn", displayName = "Heroin Brick" }
}

function openCraftingMenu()
    if isElement(craftingWindow) then return end -- Prevent opening multiple windows

    craftingWindow = guiCreateWindow((screenW - 400) / 2, (screenH - 300) / 2, 400, 300, "Crafting Menu", false)
    craftingList = guiCreateGridList(10, 30, 380, 200, false, craftingWindow)
    
    guiGridListAddColumn(craftingList, "Item Name", 0.85)
    
    for _, item in ipairs(craftableItems) do
        local row = guiGridListAddRow(craftingList)
        guiGridListSetItemText(craftingList, row, 1, item.displayName, false, false)
    end

    craftButton = guiCreateButton(10, 240, 180, 40, "Craft Item", false, craftingWindow)
    closeButton = guiCreateButton(210, 240, 180, 40, "Close", false, craftingWindow)

    addEventHandler("onClientGUIClick", craftButton, function()
        local selectedRow = guiGridListGetSelectedItem(craftingList)
        if selectedRow ~= -1 then
            local itemName = guiGridListGetItemText(craftingList, selectedRow, 1)
            triggerServerEvent("requestCrafting", localPlayer, itemName) -- Send item name only
        else
            outputChatBox("Select an item to craft.", 255, 0, 0)
        end
    end, false)

    addEventHandler("onClientGUIClick", closeButton, function()
        if isElement(craftingWindow) then
            destroyElement(craftingWindow)
        end
    end, false)
end

addCommandHandler("craft", openCraftingMenu)
