local screenW, screenH = guiGetScreenSize()
local craftingGUI = {
    visible = false,
    x = (screenW - 500) / 2,
    y = (screenH - 400) / 2,
    width = 500,
    height = 420,
    items = {},
    selectedItem = nil,
}

local craftingProgress = false
local progressValue = 0
local progressMax = 0
local progressItemName = ""
local progressStart, progressEnd

-- Function to open the crafting menu
function openCraftingMenu()
    craftingGUI.visible = true
    craftingGUI.selectedItem = nil
    triggerServerEvent("requestCraftableItems", localPlayer)
end
addCommandHandler("craft", openCraftingMenu)

-- Function to close the crafting menu
function closeCraftingMenu()
    craftingGUI.visible = false
end

-- Receive craftable items from server
addEvent("receiveCraftableItems", true)
addEventHandler("receiveCraftableItems", root, function(items)
    craftingGUI.items = items
end)

-- Render the crafting menu
function renderCraftingMenu()
    if not craftingGUI.visible then return end

    -- Draw the background window
    dxDrawRectangle(craftingGUI.x, craftingGUI.y, craftingGUI.width, craftingGUI.height, tocolor(50, 50, 50, 200))
    dxDrawText("Crafting Menu", craftingGUI.x + 10, craftingGUI.y + 10, craftingGUI.x + craftingGUI.width, craftingGUI.y + 30, tocolor(255, 255, 255, 255), 1.2, "default-bold", "left", "top")

    -- Start position for the grid of items
    local startX = craftingGUI.x + 10
    local startY = craftingGUI.y + 40
    local itemWidth = (craftingGUI.width - 30) / 2 -- Two items per row
    local itemHeight = 150
    local padding = 10

    -- Only show up to 4 items (2 rows, 2 columns)
    local itemsToDisplay = {}
    for i = 1, math.min(4, #craftingGUI.items) do
        table.insert(itemsToDisplay, craftingGUI.items[i])
    end

    -- Draw the items (2 rows, 2 columns)
    for i, item in ipairs(itemsToDisplay) do
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        local x = startX + col * (itemWidth + padding)
        local y = startY + row * (itemHeight + padding)

        -- Draw item box
        dxDrawRectangle(x, y, itemWidth, itemHeight, tocolor(30, 30, 30, 200))
        if craftingGUI.selectedItem == i then
            dxDrawRectangle(x, y, itemWidth, itemHeight, tocolor(0, 150, 255, 100))
        end

        -- Draw item name (title)
        dxDrawText(item.displayName, x + 10, y + 10, x + itemWidth - 10, y + 30, tocolor(255, 255, 255, 255), 1, "default-bold", "left", "top")

        -- Draw materials
        local materialsText = ""
        for _, mat in ipairs(item.materials) do
            materialsText = materialsText .. exports["item-system"]:getItemName(mat.id).." ("..mat.quantity.."), "
        end
        materialsText = materialsText:sub(1, -3)  -- Remove trailing comma
        dxDrawText(materialsText, x + 10, y + 40, x + itemWidth - 10, y + itemHeight - 10, tocolor(255, 255, 255, 255), 1, "default", "left", "top", true, true)

        -- Draw crafting time
        dxDrawText("Time: " .. tostring(item.time) .. " sec", x + 10, y + itemHeight - 30, x + itemWidth - 10, y + itemHeight - 10, tocolor(255, 255, 255, 255), 1, "default", "left", "bottom")
    end

    -- Buttons section at the bottom of the screen
    local buttonAreaY = craftingGUI.y + craftingGUI.height - 60 -- 10 pixels above the bottom for spacing
    local buttonWidth = (craftingGUI.width - 30) / 2
    local buttonSpacing = 10 -- Space between buttons
    local buttonX = craftingGUI.x + 10

    -- Craft button
    if dxDrawButton(buttonX, buttonAreaY, buttonWidth - buttonSpacing / 2, 40, "Craft Selected Item") then
        if craftingGUI.selectedItem then
            local itemID = craftingGUI.items[craftingGUI.selectedItem].id
            triggerServerEvent("requestCrafting", localPlayer, itemID)
            closeCraftingMenu()
        else
            outputChatBox("Select an item to craft.", 255, 0, 0)
        end
    end

    -- Close button
    if dxDrawButton(buttonX + buttonWidth + buttonSpacing / 2, buttonAreaY, buttonWidth - buttonSpacing / 2, 40, "Close") then
        closeCraftingMenu()
    end
end
addEventHandler("onClientRender", root, renderCraftingMenu)

-- Handle mouse clicks
function handleCraftingMenuClick(button, state)
    if button == "left" and state == "down" and craftingGUI.visible then
        -- Check if an item is clicked
        local startX = craftingGUI.x + 10
        local startY = craftingGUI.y + 40
        local itemWidth = (craftingGUI.width - 30) / 2
        local itemHeight = 150
        local padding = 10

        for i = 1, 4 do
            local row = math.floor((i - 1) / 2)
            local col = (i - 1) % 2
            local x = startX + col * (itemWidth + padding)
            local y = startY + row * (itemHeight + padding)

            if isMouseInPosition(x, y, itemWidth, itemHeight) then
                craftingGUI.selectedItem = i
                break
            end
        end
    end
end
addEventHandler("onClientClick", root, handleCraftingMenuClick)

-- Utility function to draw a button
function dxDrawButton(x, y, width, height, text)
    local isHovered = isMouseInPosition(x, y, width, height)
    dxDrawRectangle(x, y, width, height, tocolor(0, 150, 255, isHovered and 200 or 100))
    dxDrawText(text, x, y, x + width, y + height, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center")
    return isHovered and getKeyState("mouse1")
end

-- Utility function to check if mouse is in a position
function isMouseInPosition(x, y, width, height)
    local mx, my = getCursorPosition()
    if not mx or not my then return false end
    mx, my = mx * screenW, my * screenH
    return mx >= x and mx <= x + width and my >= y and my <= y + height
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

        dxDrawRectangle(barX, barY, barWidth, barHeight, tocolor(0, 0, 0, 200))
        dxDrawRectangle(barX, barY, barWidth * progressPercentage, barHeight, tocolor(0, 200, 0, 255))
        dxDrawText(progressItemName .. " (" .. math.floor(progressPercentage * 100) .. "%)", barX, barY, barX + barWidth, barY + barHeight, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center")
    end
end
addEventHandler("onClientRender", root, renderCraftingProgress)

-- Event to start crafting progress
addEvent("startCraftingProgress", true)
addEventHandler("startCraftingProgress", root, function(itemName, time)
    craftingProgress = true
    progressItemName = itemName
    progressStart = getTickCount()
    progressMax = time * 1000
    progressEnd = progressStart + progressMax
end)
