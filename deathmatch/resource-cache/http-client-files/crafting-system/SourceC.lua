-- Table to track if the player is inside the crafting marker
local isPlayerInMarker = false

-- Function to create the crafting GUI
function createCraftingGUI()
    if not isPlayerInMarker then
        outputChatBox("You must be inside the crafting marker to open the crafting menu.", 255, 0, 0)
        return
    end

    -- Create the GUI window
    local window = guiCreateWindow(0.35, 0.25, 0.3, 0.5, "Crafting Menu", true)
    guiWindowSetSizable(window, false)

    -- Create buttons for each craftable item
    local craftableItems = {
        { name = "pcp", material = 33 },       -- PCP requires itemid33
        { name = "redbandana", material = 160 } -- Red Bandana requires itemid160
    }

    local buttonHeight = 0.1
    local buttonSpacing = 0.05
    local startY = 0.1

    for index, item in ipairs(craftableItems) do
        local button = guiCreateButton(0.1, startY + (index - 1) * (buttonHeight + buttonSpacing), 0.8, buttonHeight, "Craft " .. item.name, true, window)
        addEventHandler("onClientGUIClick", button, function()
            triggerServerEvent("onClientCraftItem", localPlayer, item.name)
            guiSetVisible(window, false)
            destroyElement(window)
        end, false)
    end

    -- Create a "Close" button
    local closeButton = guiCreateButton(0.1, startY + #craftableItems * (buttonHeight + buttonSpacing), 0.8, buttonHeight, "Close", true, window)
    addEventHandler("onClientGUIClick", closeButton, function()
        guiSetVisible(window, false)
        destroyElement(window)
    end, false)

    -- Show the GUI
    guiSetVisible(window, true)
end

-- Event handler for entering the crafting marker
addEvent("onPlayerEnterCraftingMarker", true)
addEventHandler("onPlayerEnterCraftingMarker", resourceRoot, function()
    isPlayerInMarker = true
    outputChatBox("Type /craft to open the crafting menu.", 0, 255, 0)
end)

-- Event handler for leaving the crafting marker
addEvent("onPlayerLeaveCraftingMarker", true)
addEventHandler("onPlayerLeaveCraftingMarker", resourceRoot, function()
    isPlayerInMarker = false
    outputChatBox("You left the crafting area.", 255, 0, 0)
end)

-- Command to open the crafting GUI
addCommandHandler("craft", function()
    if isPlayerInMarker then
        createCraftingGUI()
    else
        outputChatBox("You must be inside the crafting marker to use this command.", 255, 0, 0)
    end
end)