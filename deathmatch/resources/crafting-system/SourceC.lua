local screenW, screenH = guiGetScreenSize()

-- Crafting GUI settings
local craftingGUI = {
    visible = false,
    x = (screenW - 500) / 2,
    y = (screenH - 420) / 2,
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

-- Grid settings for items
local grid = {
    startX = craftingGUI.x + 10,
    startY = craftingGUI.y + 40,
    itemWidth = (craftingGUI.width - 50) / 2, -- leave extra room on right for slider
    itemHeight = 150,
    padding = 10,
    visibleRows = 2, -- only 2 rows visible
}
grid.visibleHeight = grid.visibleRows * (grid.itemHeight + grid.padding) - grid.padding
grid.totalWidth = (grid.itemWidth * 2) + grid.padding  -- for 2 columns

-- Create a render target for the grid (to clip items)
local gridRT = dxCreateRenderTarget(grid.totalWidth, grid.visibleHeight)

-- Slider settings (draggable slider next to the grid)
local slider = {
    x = craftingGUI.x + craftingGUI.width - 15, -- moved further right
    y = grid.startY, -- align with grid
    width = 15,
    height = grid.visibleHeight, -- only as tall as the grid area
    minValue = 0,
    maxValue = 100,
    currentValue = 0, -- 0 means grid scrolled to top
    dragging = false,
}

-- Open the crafting menu when using /craft command
function openCraftingMenu()
    craftingGUI.visible = true
    craftingGUI.selectedItem = nil
    triggerServerEvent("requestCraftableItems", localPlayer)
end
addCommandHandler("craft", openCraftingMenu)

-- Close the crafting menu
function closeCraftingMenu()
    craftingGUI.visible = false
end

-- Receive craftable items from server
addEvent("receiveCraftableItems", true)
addEventHandler("receiveCraftableItems", root, function(items)
    craftingGUI.items = items
end)

-- Render the crafting menu, grid (via render target) and slider
function renderCraftingMenu()
    if not craftingGUI.visible then return end

    -- Draw the background window
    dxDrawRectangle(craftingGUI.x, craftingGUI.y, craftingGUI.width, craftingGUI.height, tocolor(50, 50, 50, 200))
    dxDrawText("Crafting Menu", craftingGUI.x + 10, craftingGUI.y + 10, craftingGUI.x + craftingGUI.width, craftingGUI.y + 30, 
        tocolor(255, 255, 255, 255), 1.2, "default-bold", "left", "top")

    -- Calculate scrolling parameters for the grid
    local totalItems = #craftingGUI.items
    local totalRows = math.ceil(totalItems / 2)
    local maxScrollRows = math.max(totalRows - grid.visibleRows, 0)
    local scrollOffsetRows = (slider.currentValue / slider.maxValue) * maxScrollRows
    local scrollOffsetPixels = scrollOffsetRows * (grid.itemHeight + grid.padding)

    -- Draw items to the render target so they are clipped to the grid area
    dxSetRenderTarget(gridRT, true)  -- enable clear mode; this clears automatically
    -- Removed the explicit clear rectangle so that gaps remain transparent
    for i, item in ipairs(craftingGUI.items) do
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        local x = col * (grid.itemWidth + grid.padding)
        local y = row * (grid.itemHeight + grid.padding) - scrollOffsetPixels

        -- Only draw if the item falls within the render target (clipping)
        if y + grid.itemHeight >= 0 and y <= grid.visibleHeight then
            -- Draw item box
            dxDrawRectangle(x, y, grid.itemWidth, grid.itemHeight, tocolor(50, 50, 50, 200))
            if craftingGUI.selectedItem == i then
                dxDrawRectangle(x, y, grid.itemWidth, grid.itemHeight, tocolor(0, 150, 255, 100))
            end

            -- Draw item name
            dxDrawText(item.displayName, x + 10, y + 10, x + grid.itemWidth - 10, y + 30, 
                tocolor(255, 255, 255, 255), 1, "default-bold", "left", "top")
            
            -- Draw materials
            local materialsText = ""
            for _, mat in ipairs(item.materials) do
                materialsText = materialsText .. exports["item-system"]:getItemName(mat.id).." ("..mat.quantity.."), "
            end
            materialsText = materialsText:sub(1, -3)  -- Remove trailing comma and space
            dxDrawText(materialsText, x + 10, y + 40, x + grid.itemWidth - 10, y + grid.itemHeight - 10, 
                tocolor(255, 255, 255, 255), 1, "default", "left", "top", true, true)
            
            -- Draw crafting time
            dxDrawText("Time: " .. tostring(item.time) .. " sec", x + 10, y + grid.itemHeight - 30, 
                x + grid.itemWidth - 10, y + grid.itemHeight - 10, tocolor(255, 255, 255, 255), 1, "default", "left", "bottom")
        end
    end
    dxSetRenderTarget(nil)

    -- Draw the grid render target onto the screen at the grid position
    dxDrawImage(grid.startX, grid.startY, grid.totalWidth, grid.visibleHeight, gridRT)

    -- Draw buttons at the bottom of the GUI (outside grid area)
    local buttonAreaY = craftingGUI.y + craftingGUI.height - 60
    local buttonWidth = (craftingGUI.width - 30) / 2
    local buttonSpacing = 10
    local buttonX = craftingGUI.x + 10

    if dxDrawButton(buttonX, buttonAreaY, buttonWidth - buttonSpacing / 2, 40, "Craft Selected Item") then
        if craftingGUI.selectedItem then
            local itemID = craftingGUI.items[craftingGUI.selectedItem].id
            triggerServerEvent("requestCrafting", localPlayer, itemID)
            closeCraftingMenu()
        else
            outputChatBox("Select an item to craft.", 255, 0, 0)
        end
    end

    if dxDrawButton(buttonX + buttonWidth + buttonSpacing / 2, buttonAreaY, buttonWidth - buttonSpacing / 2, 40, "Close") then
        closeCraftingMenu()
    end

    -- Render the draggable slider next to the grid
    renderSlider()
end
addEventHandler("onClientRender", root, renderCraftingMenu)

-- Render the crafting progress bar
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
        dxDrawText(progressItemName .. " (" .. math.floor(progressPercentage * 100) .. "%)", barX, barY, 
            barX + barWidth, barY + barHeight, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center")
    end
end
addEventHandler("onClientRender", root, renderCraftingProgress)

-- Utility function to draw a button
function dxDrawButton(x, y, width, height, text)
    local isHovered = isMouseInPosition(x, y, width, height)
    dxDrawRectangle(x, y, width, height, tocolor(0, 150, 255, isHovered and 200 or 100))
    dxDrawText(text, x, y, x + width, y + height, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center")
    return isHovered and getKeyState("mouse1")
end

-- Utility function to check if mouse is in a given area
function isMouseInPosition(x, y, width, height)
    local mx, my = getCursorPosition()
    if not mx or not my then return false end
    mx, my = mx * screenW, my * screenH
    return mx >= x and mx <= x + width and my >= y and my <= y + height
end

-- Handle mouse clicks for crafting menu item selection (accounting for scroll offset)
function handleCraftingMenuClick(button, state)
    if button == "left" and state == "down" and craftingGUI.visible then
        for i, item in ipairs(craftingGUI.items) do
            local row = math.floor((i - 1) / 2)
            local col = (i - 1) % 2
            local x = grid.startX + col * (grid.itemWidth + grid.padding)
            local y = grid.startY + row * (grid.itemHeight + grid.padding)
            
            local totalRows = math.ceil(#craftingGUI.items / 2)
            local maxScrollRows = math.max(totalRows - grid.visibleRows, 0)
            local scrollOffsetRows = (slider.currentValue / slider.maxValue) * maxScrollRows
            local scrollOffsetPixels = scrollOffsetRows * (grid.itemHeight + grid.padding)
            y = y - scrollOffsetPixels
            
            if isMouseInPosition(x, y, grid.itemWidth, grid.itemHeight) then
                craftingGUI.selectedItem = i
                break
            end
        end
    end
end
addEventHandler("onClientClick", root, handleCraftingMenuClick)

-- Event to start crafting progress
addEvent("startCraftingProgress", true)
addEventHandler("startCraftingProgress", root, function(itemName, time)
    craftingProgress = true
    progressItemName = itemName
    progressStart = getTickCount()
    progressMax = time * 1000
    progressEnd = progressStart + progressMax
end)

-- Event to stop crafting progress (if player leaves marker)
addEvent("stopCraftingProgress", true)
addEventHandler("stopCraftingProgress", root, function()
    craftingProgress = false
end)

--------------------------------------------------------------------------------
-- DRAGGABLE SLIDER CODE (Integrated into the crafting GUI)
--------------------------------------------------------------------------------

-- Render the slider and its draggable thumb (no text display)
function renderSlider()
    -- Draw slider background
    dxDrawRectangle(slider.x, slider.y, slider.width, slider.height, tocolor(30, 30, 30, 200))
    local thumbHeight = 20
    local thumbY = slider.y + (slider.currentValue / slider.maxValue) * (slider.height - thumbHeight)
    dxDrawRectangle(slider.x, thumbY, slider.width, thumbHeight, tocolor(0, 150, 255, 200))
end

-- Check if the mouse is in a given rectangle area
function isMouseInArea(x, y, width, height)
    local mx, my = getCursorPosition()
    if not mx or not my then return false end
    mx, my = mx * screenW, my * screenH
    return mx >= x and mx <= x + width and my >= y and my <= y + height
end

-- Handle mouse click events for slider dragging
function handleSliderDrag(button, state)
    if button == "left" then
        local thumbHeight = 20
        local thumbY = slider.y + (slider.currentValue / slider.maxValue) * (slider.height - thumbHeight)
        if state == "down" then
            if isMouseInArea(slider.x, thumbY, slider.width, thumbHeight) then
                slider.dragging = true
            end
        elseif state == "up" then
            slider.dragging = false
        end
    end
end
addEventHandler("onClientClick", root, handleSliderDrag)

-- Update the slider value while dragging
function updateSliderValue()
    if slider.dragging then
        local mx, my = getCursorPosition()
        if mx and my then
            my = my * screenH
            local relativeY = math.max(0, math.min(slider.height, my - slider.y))
            local newValue = (relativeY / slider.height) * slider.maxValue
            slider.currentValue = math.floor(newValue + 0.5)
        end
    end
end
addEventHandler("onClientRender", root, updateSliderValue)
