local screenW, screenH = guiGetScreenSize()
local craftingWindow, craftingList, craftButton, closeButton
local craftableItems = {}

function openCraftingMenu()
    if isElement(craftingWindow) then return end -- Prevent multiple windows

    triggerServerEvent("requestCraftableItems", localPlayer) -- Request item list

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
