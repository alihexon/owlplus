function onClientPlayerEnterCraftingMarker()
    outputChatBox("Hello, " .. getPlayerName(localPlayer) .. "! Welcome to the crafting area.", 0, 255, 0)
end

addEvent("onClientPlayerEnterCraftingMarker", true)
addEventHandler("onClientPlayerEnterCraftingMarker", root, onClientPlayerEnterCraftingMarker)