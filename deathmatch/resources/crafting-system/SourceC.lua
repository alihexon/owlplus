local screenW, screenH = guiGetScreenSize()
local craftingGUI, craftingList, craftButton, closeButton
local craftingProgress = false
local progressValue = 0
local progressMax = 0
local progressItemName = ""

-- Function to open the crafting menu
function openCraftingMenu()
    if isElement(craftingGUI) then destroyElement(craftingGUI) end
    
    craftingGUI = guiCreateWindow((screenW - 450) / 2, (screenH - 350) / 2, 450, 350, "Crafting Menu", false)
    guiWindowSetSizable(craftingGUI, false)

    craftingList = guiCreateGridList(10, 30, 430, 230, false, craftingGUI)
    local colName = guiGridListAddColumn(craftingList, "Item", 0.3)
    local colMaterials = guiGridListAddColumn(craftingList, "Materials", 0.4)
    local colTime = guiGridListAddColumn(craftingList, "Time (sec)", 0.2)

    craftButton = guiCreateButton(10, 270, 210, 40, "Craft Selected Item", false, craftingGUI)
    closeButton = guiCreateButton(230, 270, 210, 40, "Close", false, craftingGUI)

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

    addEventHandler("onClientGUIClick", closeButton, function()
        if isElement(craftingGUI) then destroyElement(craftingGUI) end
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
            guiGridListSetItemText(craftingList, row, 2, item.materials, false, false)  -- New materials column
            guiGridListSetItemText(craftingList, row, 3, tostring(item.time), false, false)
            guiGridListSetItemData(craftingList, row, 1, item.id)
        end
    end
end)

-- Function to draw a rounded rectangle (for progress bar)
function dxDrawRoundedRectangle(x, y, width, height, color, radius)
    dxDrawRectangle(x + radius, y, width - 2 * radius, height, color)  -- Main middle part
    dxDrawRectangle(x, y + radius, width, height - 2 * radius, color)  -- Main vertical parts
    dxDrawCircle(x + radius, y + radius, radius, 180, 270, color, color, 10) -- Top-left corner
    dxDrawCircle(x + width - radius, y + radius, radius, 270, 360, color, color, 10) -- Top-right corner
    dxDrawCircle(x + radius, y + height - radius, radius, 90, 180, color, color, 10) -- Bottom-left corner
    dxDrawCircle(x + width - radius, y + height - radius, radius, 0, 90, color, color, 10) -- Bottom-right corner
end

-- Crafting progress bar rendering
function renderCraftingProgress()
    if craftingProgress then
        local barWidth = 300
        local barHeight = 30
        local barX = (screenW - barWidth) / 2
        local barY = screenH - 220  -- Adjusted slightly higher

        dxDrawRoundedRectangle(barX, barY, barWidth, barHeight, tocolor(0, 0, 0, 200), 10) -- Background
        dxDrawRoundedRectangle(barX + 2, barY + 2, (barWidth - 4) * (progressValue / progressMax), barHeight - 4, tocolor(0, 200, 0, 255), 10) -- Green bar
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
