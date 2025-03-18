-- Table to hold the craftable items and their details
local craftableItems = {
    { name = "pcp", id = 43, material = 33 },       -- Craft PCP
    { name = "redbandana", id = 123, material = 160 }, -- Craft Red Bandana
    { name = "cocaine", id = 50, material = 42 },
    { name = "item4", id = 80, material = 100 },     -- Add a 4th item here
    { name = "item5", id = 101, material = 200 },    -- Add a 5th item here
    -- Add more items here
}

local window, buttons = nil, {}

-- Ensure the marker is created only once
local markerX, markerY, markerZ = 2779.9921875, -2417.47265625, 13.635567665 - 1
local craftingMarker = createMarker(markerX, markerY, markerZ, "cylinder", 1.5, 255, 0, 0, 150)

-- Table to track players inside the marker
local playersInMarker = {}

-- Marker hit event (track players inside the marker)
function onPlayerEnterMarker(hitPlayer, matchingDimension)
    if hitPlayer and getElementType(hitPlayer) == "player" and matchingDimension then
        playersInMarker[hitPlayer] = true
        outputChatBox("Type /craft to open the crafting menu.", hitPlayer, 0, 255, 0)
    end
end
addEventHandler("onMarkerHit", craftingMarker, onPlayerEnterMarker)

-- Marker leave event (remove players from the tracking table)
function onPlayerLeaveMarker(hitPlayer, matchingDimension)
    if hitPlayer and getElementType(hitPlayer) == "player" and matchingDimension then
        playersInMarker[hitPlayer] = nil
        outputChatBox("You left the crafting area.", hitPlayer, 255, 0, 0)
    end
end
addEventHandler("onMarkerLeave", craftingMarker, onPlayerLeaveMarker)

-- Function to open the crafting GUI
function openCraftingGUI()
    if window and isElement(window) then return end -- Prevent duplicate windows

    local screenW, screenH = guiGetScreenSize()
    local windowW, windowH = 300, 300 -- Increased window height to accommodate more items
    local posX, posY = (screenW - windowW) / 2, (screenH - windowH) / 2

    window = guiCreateWindow(posX, posY, windowW, windowH, "Crafting Menu", false)
    guiWindowSetSizable(window, false)

    -- Clear any previous buttons
    buttons = {}

    -- Create a scroll pane to hold the buttons
    local scrollPane = guiCreateScrollPane(50, 50, 200, 200, false, window) -- Increased height of the scroll pane
    local yOffset = 0 -- Start the vertical position at 0

    -- Loop through each craftable item and create a button
    for _, item in ipairs(craftableItems) do
        local button = guiCreateButton(0, yOffset, 200, 40, "Craft " .. item.name, false, scrollPane)
        table.insert(buttons, { button = button, itemName = item.name })

        -- Add event handler for each button
        addEventHandler("onClientGUIClick", button, function()
            craftItem(item.name)
        end, false)

        -- Adjust yOffset for the next button
        yOffset = yOffset + 50
    end

    -- Close button
    local closeButton = guiCreateButton(50, yOffset + 50, 200, 40, "Close", false, window) -- Adjusted close button position
    addEventHandler("onClientGUIClick", closeButton, function()
        destroyElement(window)
        window = nil
    end, false)
end

-- Function to send crafting request to the server
function craftItem(itemName)
    triggerServerEvent("requestCrafting", localPlayer, itemName)
    destroyElement(window)
    window = nil
end

-- Command to open the crafting GUI
addCommandHandler("craft", function()
    openCraftingGUI()
end)
