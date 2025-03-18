-- Table to hold the craftable items and their details
local craftableItems = {
    { name = "pcp", id = 43, material = 33 },       
    { name = "redbandana", id = 123, material = 160 }, 
    { name = "cocaine", id = 50, material = 42 },
    { name = "cocainee", id = 51, material = 43 },
    { name = "meth", id = 52, material = 44 },  -- Added extra items for testing
    { name = "heroin", id = 53, material = 45 }
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
    local windowW, windowH = 300, 450 -- Increased window height
    local posX, posY = (screenW - windowW) / 2, (screenH - windowH) / 2

    window = guiCreateWindow(posX, posY, windowW, windowH, "Crafting Menu", false)
    guiWindowSetSizable(window, false)

    -- Create a scroll pane to handle more items
    local scrollPane = guiCreateScrollPane(50, 50, 200, 300, false, window)
    local yOffset = 0 

    buttons = {} -- Reset buttons table

    for _, item in ipairs(craftableItems) do
        local button = guiCreateButton(0, yOffset, 180, 40, "Craft " .. item.name, false, scrollPane)
        table.insert(buttons, { button = button, itemName = item.name })

        addEventHandler("onClientGUIClick", button, function()
            craftItem(item.name)
        end, false)

        yOffset = yOffset + 45
    end

    -- Close button below the scroll pane
    local closeButton = guiCreateButton(50, windowH - 60, 200, 40, "Close", false, window)
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
