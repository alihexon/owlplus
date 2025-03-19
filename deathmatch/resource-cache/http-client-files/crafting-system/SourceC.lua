local screenW, screenH = guiGetScreenSize()
local craftingGUI = {
    visible = false,
    x = (screenW - 500) / 2,
    y = (screenH - 400) / 2,
    width = 500,
    height = 400,
    scroll = 0,
    items = {},
    selectedItem = nil
}
local craftingProgress = false
local progressValue = 0
local progressMax = 0
local progressItemName = ""
local progressStart, progressEnd

-- Function to open the crafting menu
function openCraftingMenu()
    craftingGUI.visible = true
    craftingGUI.scroll = 0
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

    -- Draw the grid of craftable items
    local startX = craftingGUI.x + 10
    local startY = craftingGUI.y + 40
    local itemWidth = (craftingGUI.width - 30) / 2 -- Two items per row
    local itemHeight = 150
    local padding = 10

    -- Calculate the total height of the grid
    local totalRows = math.ceil(#craftingGUI.items / 2)
    local totalHeight = totalRows * (itemHeight + padding)

    -- Adjust the scroll position
    local maxScroll = math.max(0, totalHeight - (craftingGUI.height - 90))
    craftingGUI.scroll = math.max(0, math.min(craftingGUI.scroll, maxScroll))

    -- Draw the items
    for i = 1, #craftingGUI.items do
        local item = craftingGUI.items[i]
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        local x = startX + col * (itemWidth + padding)
        local y = startY + row * (itemHeight + padding) - craftingGUI.scroll

        -- Only draw items that are within the visible area
        if y + itemHeight > craftingGUI.y + 40 and y < craftingGUI.y + craftingGUI.height - 90 then
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
    end

    -- Draw scrollbar
    if totalHeight > craftingGUI.height - 90 then
        local scrollbarWidth = 5
        local scrollbarHeight = (craftingGUI.height - 90) / totalHeight * (craftingGUI.height - 90)
        local scrollbarX = craftingGUI.x + craftingGUI.width - 10
        local scrollbarY = craftingGUI.y + 40 + (craftingGUI.scroll / totalHeight) * (craftingGUI.height - 90)
        dxDrawRectangle(scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight, tocolor(255, 255, 255, 150))
    end

    -- Draw craft and close buttons
    local buttonWidth = (craftingGUI.width - 30) / 2
    if dxDrawButton(craftingGUI.x + 10, craftingGUI.y + craftingGUI.height - 50, buttonWidth - 5, 40, "Craft Selected Item") then
        if craftingGUI.selectedItem then
            local itemID = craftingGUI.items[craftingGUI.selectedItem].id
            triggerServerEvent("requestCrafting", localPlayer, itemID)
            closeCraftingMenu()
        else
            outputChatBox("Select an item to craft.", 255, 0, 0)
        end
    end

    if dxDrawButton(craftingGUI.x + buttonWidth + 5, craftingGUI.y + craftingGUI.height - 50, buttonWidth - 5, 40, "Close") then
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

        for i = 1, #craftingGUI.items do
            local row = math.floor((i - 1) / 2)
            local col = (i - 1) % 2
            local x = startX + col * (itemWidth + padding)
            local y = startY + row * (itemHeight + padding) - craftingGUI.scroll

            if isMouseInPosition(x, y, itemWidth, itemHeight) then
                craftingGUI.selectedItem = i
                break
            end
        end
    end
end
addEventHandler("onClientClick", root, handleCraftingMenuClick)

-- Handle mouse scroll
function handleCraftingMenuScroll(key, state)
    if craftingGUI.visible then
        if key == "mouse_wheel_down" then
            craftingGUI.scroll = math.min(craftingGUI.scroll + 20, math.ceil(#craftingGUI.items / 2) * 160 - (craftingGUI.height - 90))
        elseif key == "mouse_wheel_up" then
            craftingGUI.scroll = math.max(craftingGUI.scroll - 20, 0)
        end
    end
end
addEventHandler("onClientKey", root, handleCraftingMenuScroll)

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
