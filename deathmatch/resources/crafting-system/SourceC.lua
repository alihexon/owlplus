local screenW, screenH = guiGetScreenSize()
local craftingGUI, craftingList, craftButton, closeButton
local craftingProgress = false
local progressValue = 0
local progressMax = 0
local progressItemName = ""
local progressStart, progressEnd  -- Added variables for time tracking

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
            local materialsText = ""
            for _, mat in ipairs(item.materials) do
                materialsText = materialsText .. exports["item-system"]:getItemName(mat.id).." ("..mat.quantity.."), "
            end
            materialsText = materialsText:sub(1, -3)  -- Remove trailing comma
            
            local row = guiGridListAddRow(craftingList)
            guiGridListSetItemText(craftingList, row, 1, item.displayName, false, false)
            guiGridListSetItemText(craftingList, row, 2, materialsText, false, false)
            guiGridListSetItemText(craftingList, row, 3, tostring(item.time), false, false)
            guiGridListSetItemData(craftingList, row, 1, item.id)
        end
    end
end)

-- Function to draw a rounded rectangle (for progress bar)
function dxDrawRoundedRectangle(x, y, width, height, color, radius)
    -- Draw the main rectangle
    dxDrawRectangle(x + radius, y, width - 2 * radius, height, color)
    dxDrawRectangle(x, y + radius, radius, height - 2 * radius, color) -- Left side
    dxDrawRectangle(x + width - radius, y + radius, radius, height - 2 * radius, color) -- Right side

    -- Draw the rounded corners
    dxDrawCircle(x + radius, y + radius, radius, 180, 270, color, color, 10) -- Top-left corner
    dxDrawCircle(x + width - radius, y + radius, radius, 270, 360, color, color, 10) -- Top-right corner
    dxDrawCircle(x + radius, y + height - radius, radius, 90, 180, color, color, 10) -- Bottom-left corner
    dxDrawCircle(x + width - radius, y + height - radius, radius, 0, 90, color, color, 10) -- Bottom-right corner
end

-- Crafting progress bar rendering
function renderCraftingProgress()
    if craftingProgress then
        local currentTime = getTickCount()
        progressValue = currentTime - progressStart
        local progressPercentage = math.min(progressValue / progressMax, 1)

        if currentTime >= progressEnd then
            craftingProgress = false
        end

        local barWidth = 300
        local barHeight = 30
        local barX = (screenW - barWidth) / 2
        local barY = screenH - 220
        local radius = 10 -- Radius for rounded corners

        -- Draw the background of the progress bar
        dxDrawRoundedRectangle(barX, barY, barWidth, barHeight, tocolor(0, 0, 0, 200), radius)

        -- Calculate the width of the progress bar
        local progressWidth = (barWidth - 2 * radius) * progressPercentage

        -- Draw the progress bar with rounded corners
        if progressWidth > 0 then
            dxDrawRoundedRectangle(barX, barY, progressWidth + 2 * radius, barHeight, tocolor(0, 200, 0, 255), radius)
        end

        -- Draw the progress text
        dxDrawText(progressItemName .. " (" .. math.floor(progressPercentage * 100) .. "%)",
                   barX, barY, barX + barWidth, barY + barHeight,
                   tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center")
    end
end
addEventHandler("onClientRender", root, renderCraftingProgress)

-- Event to start crafting progress
addEvent("startCraftingProgress", true)
addEventHandler("startCraftingProgress", root, function(itemName, duration)
    progressItemName = itemName
    progressMax = duration
    craftingProgress = true
    progressStart = getTickCount()
    progressEnd = progressStart + duration
end)

-- Event to stop crafting progress
addEvent("stopCraftingProgress", true)
addEventHandler("stopCraftingProgress", root, function()
    craftingProgress = false
    progressValue = 0
    progressStart = nil
    progressEnd = nil
end)