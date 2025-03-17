-- Client-side code
local markerX, markerY, markerZ = 2779.9921875, -2417.47265625, 13.635567665
local craftingMarker = createMarker(markerX, markerY, markerZ, "cylinder", 1.5, 255, 0, 0, 150)

function onClientPlayerEnterMarker(hitElement, matchingDimension)
    if hitElement == localPlayer and matchingDimension then
        outputChatBox("Hello, " .. getPlayerName(localPlayer) .. "! Welcome to the crafting area.", 0, 255, 0)
    end
end

addEventHandler("onClientMarkerHit", craftingMarker, onClientPlayerEnterMarker)