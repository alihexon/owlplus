local screenW, screenH = guiGetScreenSize()
local craftingWindow, craftingList, craftButton, closeButton
local craftableItems = {}
local progressBar = nil
local progress = 0
local craftingTime = 0

function openCraftingMenu()
    if isElement(craftingWindow) then return end

    triggerServerEvent("requestCraftableItems", localPlayer)

    craftingWindow = guiCreateWindow((screenW - 400) / 2, (screenH - 300) / 2, 400, 300, "Crafting Menu", false)
    craftingList = guiCreateGridList(10, 30, 380, 200, false, craftingWindow)
    
    guiGridListAddColumn(craftingList, "Item Name", 0.85)

    craftButton = guiCreateButton(10, 240, 180, 40, "Craft Item", false, craftingWindow)
    closeButton = guiCreateButton(210, 240, 180, 40, "Close", false, craftingWindow)

    addEventHandler("onClientGUIClick", craftButton, function()
        local selectedRow = guiGridListGetSelectedItem(craftingList)
        if selectedRow ~= -1 then
            local itemID = guiGridListGetItemData(craftingList, selectedRow, 1)
            triggerServerEvent("requestCrafting", localPlayer, itemID)
        else
            outputChatBox("Select an item to craft.", 255, 0, 0)
        end
    end, false)

    addEventHandler("onClientGUIClick", closeButton, function()
        if isElement(craftingWindow) then
            destroyElement(craftingWindow)
        end
    end, false)
end
addCommandHandler("craft", openCraftingMenu)

addEvent("receiveCraftableItems", true)
addEventHandler("receiveCraftableItems", root, function(serverItems)
    craftableItems = serverItems
    guiGridListClear(craftingList)
    
    for _, item in ipairs(craftableItems) do
        local row = guiGridListAddRow(craftingList)
        guiGridListSetItemText(craftingList, row, 1, item.displayName, false, false)
        guiGridListSetItemData(craftingList, row, 1, item.id)
    end
end)

addEvent("startCraftingProgress", true)
addEventHandler("startCraftingProgress", root, function(time)
    craftingTime = time
    progress = 0
    addEventHandler("onClientRender", root, renderProgressBar)
end)

function renderProgressBar()
    dxDrawRectangle(screenW / 2 - 150, screenH - 50, 300, 30, tocolor(0, 0, 0, 200))
    dxDrawRectangle(screenW / 2 - 150, screenH - 50, 300 * (progress / craftingTime), 30, tocolor(0, 255, 0, 200))
    progress = progress + 0.05
    if progress >= craftingTime then
        removeEventHandler("onClientRender", root, renderProgressBar)
    end
end
