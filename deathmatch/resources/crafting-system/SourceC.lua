local screenW, screenH = guiGetScreenSize()
local craftingWindow = nil
local craftingList = nil
local craftButton = nil
local closeButton = nil

local craftableItems = {
    { name = "pcp", displayName = "PCP" },
    { name = "redbandana", displayName = "Red Bandana" },
    { name = "cocaine", displayName = "Cocaine" },
    { name = "cocainee", displayName = "Cocaine Brick" },
    { name = "meth", displayName = "Meth" },
    { name = "heroin", displayName = "Heroin" },
    { name = "heroinn", displayName = "Heroin Brick" }
}

function openCraftingMenu()
    if isElement(craftingWindow) then return end -- Prevent opening multiple windows

    craftingWindow = guiCreateWindow((screenW - 400) / 2, (screenH - 300) / 2, 400, 300, "Crafting Menu", false)
    craftingList = guiCreateGridList(10, 30, 380, 200, false, craftingWindow)
    
    guiGridListAddColumn(craftingList, "Item Name", 0.85)
    
    for _, item in ipairs(craftableItems) do
        local row = guiGridListAddRow(craftingList)
        guiGridListSetItemText(craftingList, row, 1, item.displayName, false, false)
    end

    craftButton = guiCreateButton(10, 240, 180, 40, "Craft Item", false, craftingWindow)
    closeButton = guiCreateButton(210, 240, 180, 40, "Close", false, craftingWindow)

    addEventHandler("onClientGUIClick", craftButton, function()
        local selectedRow = guiGridListGetSelectedItem(craftingList)
        if selectedRow ~= -1 then
            local itemName = guiGridListGetItemText(craftingList, selectedRow, 1)
            triggerServerEvent("requestCrafting", localPlayer, itemName) -- Send item name only
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
