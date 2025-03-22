-------------------------
-- CLIENT SIDE SCRIPT (FIXED PROGRESS BAR)
-------------------------
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
    itemWidth = (craftingGUI.width - 50) / 2,
    itemHeight = 150,
    padding = 10,
    visibleRows = 2,
}
grid.visibleHeight = grid.visibleRows * (grid.itemHeight + grid.padding) - grid.padding
grid.totalWidth = (grid.itemWidth * 2) + grid.padding
grid.rowHeight = grid.itemHeight + grid.padding  -- Fixed row height calculation

-- Transparent render target
local gridRT = dxCreateRenderTarget(grid.totalWidth, grid.visibleHeight, true)

-- Slider settings
local slider = {
    x = grid.startX + grid.totalWidth + 5,
    y = grid.startY,
    width = 15,
    height = grid.visibleHeight,
    minValue = 0,
    maxValue = 1,  -- Will be updated dynamically
    currentValue = 0,
    dragging = false,
}

-- Material scroll tracking
local materialScrollOffsets = {}
local materialSliderDragging = {}

-- Marker tracking
local playersInMarker = {}

function dxDrawRoundedRectangle(x, y, width, height, color, radius)
    dxDrawRectangle(x + radius, y, width - (radius * 2), height, color)
    dxDrawRectangle(x, y + radius, radius, height - (radius * 2), color)
    dxDrawRectangle(x + width - radius, y + radius, radius, height - (radius * 2), color)
    dxDrawCircle(x + radius, y + radius, radius, 180, 270, color)
    dxDrawCircle(x + width - radius, y + radius, radius, 270, 360, color)
    dxDrawCircle(x + radius, y + height - radius, radius, 90, 180, color)
    dxDrawCircle(x + width - radius, y + height - radius, radius, 0, 90, color)
end

function dxDrawLeftRoundedRectangle(x, y, w, h, radius, color, postGUI)
    if radius > 0 then
        radius = math.min(radius, math.floor(h/2))
        -- Left rounded corners
        dxDrawCircle(x + radius, y + radius, radius, 180, 270, color, color, 16, 1, postGUI)
        dxDrawCircle(x + radius, y + h - radius, radius, 90, 180, color, color, 16, 1, postGUI)
        -- Main body
        dxDrawRectangle(x + radius, y, w - radius, h, color, postGUI)
        -- Left edge
        dxDrawRectangle(x, y + radius, radius, h - radius*2, color, postGUI)
    else
        dxDrawRectangle(x, y, w, h, color, postGUI)
    end
end

addEvent("updatePlayersInMarker", true)
addEventHandler("updatePlayersInMarker", root, function(updatedPlayersInMarker)
    playersInMarker = updatedPlayersInMarker
end)

function openCraftingMenu()
    if not playersInMarker[localPlayer] then
        outputChatBox("You must be inside the crafting marker to use this command.", 255, 0, 0)
        return
    end
    craftingGUI.visible = true
    craftingGUI.selectedItem = nil
    triggerServerEvent("requestCraftableItems", localPlayer)
end
addCommandHandler("craft", openCraftingMenu)

function closeCraftingMenu()
    craftingGUI.visible = false
end

addEvent("receiveCraftableItems", true)
addEventHandler("receiveCraftableItems", root, function(items)
    craftingGUI.items = items
    materialScrollOffsets = {}
    materialSliderDragging = {}
    for i = 1, #items do
        materialScrollOffsets[i] = 0
        materialSliderDragging[i] = false
    end
end)

function renderCraftingMenu()
    if not craftingGUI.visible then return end

    -- Main window
    dxDrawRoundedRectangle(craftingGUI.x, craftingGUI.y, craftingGUI.width, craftingGUI.height, tocolor(50, 50, 50, 200), 10)
    dxDrawText("Crafting Menu", craftingGUI.x + 10, craftingGUI.y + 10, craftingGUI.x + craftingGUI.width, craftingGUI.y + 30, 
        tocolor(255, 255, 255, 255), 1.2, "default-bold", "left", "top")

    -- Grid calculations
    local totalItems = #craftingGUI.items
    local totalRows = math.ceil(totalItems / 2)
    local maxScrollRows = math.max(totalRows - grid.visibleRows, 0)
    
    -- Fixed scrolling calculations
    slider.maxValue = maxScrollRows * grid.rowHeight
    if slider.maxValue <= 0 then slider.maxValue = 1 end
    local scrollOffsetPixels = math.floor(slider.currentValue / grid.rowHeight) * grid.rowHeight

    -- Draw items to render target
    dxSetRenderTarget(gridRT, false)
    dxDrawRectangle(0, 0, grid.totalWidth, grid.visibleHeight, tocolor(0, 0, 0, 0))
    
    for i, item in ipairs(craftingGUI.items) do
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        local x = col * (grid.itemWidth + grid.padding)
        local y = (row * grid.rowHeight) - scrollOffsetPixels  -- Fixed position

        if y + grid.itemHeight >= 0 and y <= grid.visibleHeight then
            -- Item container
            dxDrawRoundedRectangle(x, y, grid.itemWidth, grid.itemHeight, tocolor(50, 50, 50, 220), 5)
            
            if craftingGUI.selectedItem == i then
                dxDrawRoundedRectangle(x, y, grid.itemWidth, grid.itemHeight, tocolor(0, 150, 255, 100), 5)  -- Added rounded
            end

            -- Item name
            dxDrawText(item.displayName, x + 10, y + 10, x + grid.itemWidth - 10, y + 30, 
                tocolor(255, 255, 255, 255), 1, "default-bold", "left", "top")
            
            -- Materials list
            local materialsStartY = y + 40
            local maxMaterialsVisible = 4
            local materialHeight = 20
            local materialScrollOffset = materialScrollOffsets[i] or 0

            local startMaterial = math.max(1, materialScrollOffset + 1)
            local endMaterial = math.min(#item.materials, startMaterial + maxMaterialsVisible - 1)

            for j = startMaterial, endMaterial do
                local mat = item.materials[j]
                if mat then
                    local materialText = exports["item-system"]:getItemName(mat.id) .. " (" .. mat.quantity .. ")"
                    dxDrawText(materialText, x + 10, materialsStartY, x + grid.itemWidth - 10, materialsStartY + materialHeight, 
                        tocolor(255, 255, 255, 255), 1, "default", "left", "top", true, true)
                    materialsStartY = materialsStartY + materialHeight
                end
            end

            -- Material scrollbar
            if #item.materials > maxMaterialsVisible then
                local scrollbarWidth = 8  -- Slightly wider for visibility
                local scrollbarHeight = (maxMaterialsVisible * materialHeight) * (maxMaterialsVisible / #item.materials)
                local scrollbarX = x + grid.itemWidth - scrollbarWidth - 5
                local scrollbarY = y + 40 + (materialScrollOffset / #item.materials) * (maxMaterialsVisible * materialHeight)
                dxDrawRoundedRectangle(scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight, tocolor(200, 200, 200, 150), 4)
            end

            -- Crafting time
            dxDrawText("Time: " .. tostring(item.time) .. " sec", x + 10, y + grid.itemHeight - 30, 
                x + grid.itemWidth - 10, y + grid.itemHeight - 10, tocolor(255, 255, 255, 255), 1, "default", "left", "bottom")
        end
    end
    dxSetRenderTarget(nil)

    -- Draw grid and UI elements
    dxDrawImage(grid.startX, grid.startY, grid.totalWidth, grid.visibleHeight, gridRT, 0, 0, 0, tocolor(255,255,255,255), true)

    -- Buttons
    local buttonAreaY = grid.startY + grid.visibleHeight + 10
    local buttonWidth = grid.itemWidth
    local buttonXLeft = grid.startX
    local buttonXRight = grid.startX + grid.itemWidth + grid.padding

    if dxDrawButton(buttonXLeft, buttonAreaY, buttonWidth, 40, "Craft Selected Item") then
        if craftingGUI.selectedItem then
            triggerServerEvent("requestCrafting", localPlayer, craftingGUI.items[craftingGUI.selectedItem].id)
            closeCraftingMenu()
        else
            outputChatBox("Select an item to craft.", 255, 0, 0)
        end
    end

    if dxDrawButton(buttonXRight, buttonAreaY, buttonWidth, 40, "Close") then
        closeCraftingMenu()
    end

    renderSlider()
end
addEventHandler("onClientRender", root, renderCraftingMenu)

function renderCraftingProgress()
    if craftingProgress then
        local currentTime = getTickCount()
        progressValue = currentTime - progressStart
        local progressPercentage = math.min(progressValue / progressMax, 1)

        if currentTime >= progressEnd then
            craftingProgress = false
        end

        -- Progress bar settings
        local barWidth = 300
        local barHeight = 30
        local barX = (screenW - barWidth) / 2
        local barY = screenH - 100
        local radius = 8
        local bgColor = tocolor(50, 50, 50, 200)
        local fillColor = tocolor(100, 200, 255, 200)  -- Light blue

        -- Draw background
        dxDrawRoundedRectangle(barX, barY, barWidth, barHeight, bgColor, radius)

        -- Draw progress fill
        if progressPercentage > 0 then
            local fillWidth = barWidth * progressPercentage
            
            if progressPercentage < 1 then
                -- Left-rounded rectangle for partial progress
                dxDrawLeftRoundedRectangle(barX, barY, fillWidth, barHeight, radius, fillColor)
            else
                -- Fully rounded rectangle when complete
                dxDrawRoundedRectangle(barX, barY, fillWidth, barHeight, fillColor, radius)
            end
        end

        -- Progress text
        dxDrawText("Crafting: " .. progressItemName .. " (" .. math.floor(progressPercentage * 100) .. "%)", 
            barX, barY, barX + barWidth, barY + barHeight, 
            tocolor(255, 255, 255, 255), 1.2, "default-bold", "center", "center")
    end
end

addEventHandler("onClientRender", root, renderCraftingProgress)


function dxDrawButton(x, y, width, height, text)
    local isHovered = isMouseInPosition(x, y, width, height)
    dxDrawRoundedRectangle(x, y, width, height, tocolor(0, 150, 255, isHovered and 200 or 100), 5)
    dxDrawText(text, x, y, x + width, y + height, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center")
    return isHovered and getKeyState("mouse1")
end

function isMouseInPosition(x, y, width, height)
    local mx, my = getCursorPosition()
    if not mx or not my then return false end
    mx, my = mx * screenW, my * screenH
    return mx >= x and mx <= x + width and my >= y and my <= y + height
end

function handleCraftingMenuClick(button, state)
    if button == "left" and state == "down" and craftingGUI.visible then
        for i, item in ipairs(craftingGUI.items) do
            local row = math.floor((i - 1) / 2)
            local col = (i - 1) % 2
            local x = grid.startX + col * (grid.itemWidth + grid.padding)
            local y = grid.startY + row * grid.rowHeight
            
            local scrollOffsetPixels = math.floor(slider.currentValue / grid.rowHeight) * grid.rowHeight
            y = y - scrollOffsetPixels
            
            if #item.materials > 4 then
                local scrollbarWidth = 5
                local scrollbarX = x + grid.itemWidth - scrollbarWidth - 5
                local scrollbarY = y + 40
                local scrollbarHeight = 80

                if isMouseInPosition(scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight) then
                    materialSliderDragging[i] = true
                    return
                end
            end

            if y + grid.itemHeight >= grid.startY and y <= grid.startY + grid.visibleHeight then
                if isMouseInPosition(x, y, grid.itemWidth, grid.itemHeight) then
                    craftingGUI.selectedItem = i
                    break
                end
            end
        end
    elseif button == "left" and state == "up" then
        for i = 1, #craftingGUI.items do
            materialSliderDragging[i] = false
        end
    end
end
addEventHandler("onClientClick", root, handleCraftingMenuClick)

function updateMaterialsSliders()
    if not craftingGUI.visible then return end

    for i, item in ipairs(craftingGUI.items) do
        if materialSliderDragging[i] then
            local mx, my = getCursorPosition()
            if mx and my then
                my = my * screenH
                local row = math.floor((i - 1) / 2)
                local col = (i - 1) % 2
                local x = grid.startX + col * (grid.itemWidth + grid.padding)
                local y = grid.startY + row * grid.rowHeight

                local scrollbarHeight = 80
                local relativeY = math.max(0, math.min(scrollbarHeight, my - (y + 40)))
                local newOffset = math.floor((relativeY / scrollbarHeight) * (#item.materials - 4) + 0.5)
                materialScrollOffsets[i] = newOffset
            end
        end
    end
end
addEventHandler("onClientRender", root, updateMaterialsSliders)

addEvent("startCraftingProgress", true)
addEventHandler("startCraftingProgress", root, function(itemName, time)
    craftingProgress = true
    progressItemName = itemName
    progressStart = getTickCount()
    progressMax = time
    progressEnd = progressStart + progressMax
end)

addEvent("stopCraftingProgress", true)
addEventHandler("stopCraftingProgress", root, function()
    craftingProgress = false
end)

function renderSlider()
    -- Change the slider background to rounded
    dxDrawRoundedRectangle(slider.x, slider.y, slider.width, slider.height, tocolor(30, 30, 30, 200), 7)  -- Added radius
    if slider.maxValue > 0 then
        local thumbHeight = grid.visibleHeight * (grid.visibleHeight / (grid.visibleHeight + slider.maxValue))
        thumbHeight = math.max(20, thumbHeight)
        local thumbY = slider.y + (slider.currentValue / slider.maxValue) * (slider.height - thumbHeight)
        dxDrawRoundedRectangle(slider.x, thumbY, slider.width, thumbHeight, tocolor(0, 150, 255, 200), 7)
    end
end

function handleSliderDrag(button, state)
    if button == "left" then
        if state == "down" then
            if isMouseInPosition(slider.x, slider.y, slider.width, slider.height) then
                slider.dragging = true
            end
        else
            slider.dragging = false
        end
    end
end
addEventHandler("onClientClick", root, handleSliderDrag)

function updateSliderValue()
    if slider.dragging then
        local mx, my = getCursorPosition()
        if mx and my then
            my = my * screenH
            local relativeY = math.max(0, math.min(slider.height, my - slider.y))
            local newValue = (relativeY / slider.height) * slider.maxValue
            slider.currentValue = math.floor(newValue / grid.rowHeight + 0.5) * grid.rowHeight
        end
    end
end
addEventHandler("onClientRender", root, updateSliderValue)

function handleMouseWheel(key, state)
    if not craftingGUI.visible then return end

    -- First check for material list scrolling
    local mx, my = getCursorPosition()
    if mx and my then
        mx = mx * screenW
        my = my * screenH
        
        -- Check if mouse is over any item's material list
        for i, item in ipairs(craftingGUI.items) do
            if #item.materials > 4 then
                local row = math.floor((i - 1) / 2)
                local col = (i - 1) % 2
                local x = grid.startX + col * (grid.itemWidth + grid.padding)
                local y = grid.startY + row * grid.rowHeight - math.floor(slider.currentValue / grid.rowHeight) * grid.rowHeight
                
                -- Check if mouse is within this item's bounds
                if mx >= x and mx <= x + grid.itemWidth and my >= y and my <= y + grid.itemHeight then
                    -- Check if mouse is in materials area (below item title)
                    if my >= y + 40 and my <= y + grid.itemHeight - 30 then
                        if key == "mouse_wheel_up" then
                            materialScrollOffsets[i] = math.max(0, (materialScrollOffsets[i] or 0) - 1)
                        elseif key == "mouse_wheel_down" then
                            materialScrollOffsets[i] = math.min(#item.materials - 4, (materialScrollOffsets[i] or 0) + 1)
                        end
                        return true
                    end
                end
            end
        end
    end

    -- Then check for main grid scrolling
    if isMouseInPosition(grid.startX, grid.startY, grid.totalWidth, grid.visibleHeight) then
        if key == "mouse_wheel_up" then
            slider.currentValue = math.max(0, slider.currentValue - grid.rowHeight)
        elseif key == "mouse_wheel_down" then
            slider.currentValue = math.min(slider.maxValue, slider.currentValue + grid.rowHeight)
        end
        return true
    end
end
addEventHandler("onClientKey", root, handleMouseWheel)