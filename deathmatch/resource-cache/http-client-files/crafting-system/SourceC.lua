local window, pcpButton, bandanaButton

function openCraftingGUI()
    if window and isElement(window) then return end -- Prevent duplicate windows

    local screenW, screenH = guiGetScreenSize()
    local windowW, windowH = 300, 200
    local posX, posY = (screenW - windowW) / 2, (screenH - windowH) / 2

    window = guiCreateWindow(posX, posY, windowW, windowH, "Crafting Menu", false)
    guiWindowSetSizable(window, false)

    pcpButton = guiCreateButton(50, 50, 200, 40, "Craft PCP", false, window)
    bandanaButton = guiCreateButton(50, 100, 200, 40, "Craft Red Bandana", false, window)

    local closeButton = guiCreateButton(50, 150, 200, 40, "Close", false, window)

    -- Add event handlers for buttons
    addEventHandler("onClientGUIClick", pcpButton, function() craftItem("pcp") end, false)
    addEventHandler("onClientGUIClick", bandanaButton, function() craftItem("redbandana") end, false)
    addEventHandler("onClientGUIClick", closeButton, function() destroyElement(window) window = nil end, false)
end

-- Function to send crafting request to the server
function craftItem(itemName)
    triggerServerEvent("requestCrafting", localPlayer, itemName)
    destroyElement(window)
    window = nil
end

-- Command to open the crafting GUI (keep this for opening the menu)
addCommandHandler("craft", function()
    openCraftingGUI()
end)
