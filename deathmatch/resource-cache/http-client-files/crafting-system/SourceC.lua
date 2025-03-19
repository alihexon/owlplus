local screenW, screenH = guiGetScreenSize()
local craftingGUI, craftingList, craftButton
local craftingProgress = false
local progressValue = 0
local progressMax = 0
local progressItemName = ""

-- Function to open the crafting menu
function openCraftingMenu()
    if isElement(craftingGUI) then destroyElement(craftingGUI) end
    
    craftingGUI = guiCreateWindow((screenW - 400) / 2, (screenH - 300) / 2, 400, 300, "Crafting Menu", false)
    guiWindowSetSizable(craftingGUI, false)

    craftingList = guiCreateGridList(10, 30, 380, 200, false, craftingGUI)
    local colName = guiGridListAddColumn(craftingList, "Item", 0.6)
    local colTime = guiGridListAddColumn(craftingList, "Time (sec)", 0.3)
    
    craftButton = guiCreateButton(10, 240, 380, 40, "Craft Selected Item", false, craftingGUI)

    addEventHandler("onClientGUIClick", craftButton, function()
        local selectedRow = guiGridListGetSelectedItem(craftingList)
        if selectedRow ~= -1 then
            local itemID = guiGridListGetItemData(craftingList, selectedRow, colName)
            triggerServerEvent("requestCrafting", localPlayer, itemID)
            destroyElement(craftingGUI)
        else
            outputChatBox("Select an item to craft.", 255, 0, 0)
        end
    end, false)

    -- Request craftable items from server
    triggerServerEvent("requestCraftableItems", localPlayer)
end
addCommandHandler("craft", openCraftingMenu)

-- Receive craftable items from server
addEvent("receiveCraftableItems", true)
addEventHandler("receiveCraftableItems", root, function(items)
    if isElement(craftingList) then
        guiGridListClear(craftingList)
        for _, item in ipairs(items) do
            local row = guiGridListAddRow(craftingList)
            guiGridListSetItemText(craftingList, row, 1, item.displayName, false, false)
            guiGridListSetItemText(craftingList, row, 2, tostring(item.time), false, false)
            guiGridListSetItemData(craftingList, row, 1, item.id)
        end
    end
end)

-- Crafting progress bar rendering
function renderCraftingProgress()
    if craftingProgress then
        local barWidth = 300
        local barHeight = 30
        local barX = (screenW - barWidth) / 2
        local barY = screenH - 200 

        dxDrawRectangle(barX, barY, barWidth, barHeight, tocolor(0, 0, 0, 200)) -- Background
        dxDrawRectangle(barX + 2, barY + 2, (barWidth - 4) * (progressValue / progressMax), barHeight - 4, tocolor(0, 200, 0, 255)) -- Green bar
        dxDrawText(progressItemName .. " (" .. math.floor((progressValue / progressMax) * 100) .. "%)", barX, barY, barX + barWidth, barY + barHeight, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center")
    end
end
addEventHandler("onClientRender", root, renderCraftingProgress)

addEvent("startCraftingProgress", true)
addEventHandler("startCraftingProgress", root, function(itemName, duration)
    progressItemName = itemName
    progressValue = 0
    progressMax = duration
    craftingProgress = true

    local progressTimer = setTimer(function()
        progressValue = progressValue + 500
        if progressValue >= progressMax then
            craftingProgress = false
            killTimer(progressTimer)
        end
    end, 500, duration / 500)
end)

addEvent("stopCraftingProgress", true)
addEventHandler("stopCraftingProgress", root, function()
    craftingProgress = false
end)
