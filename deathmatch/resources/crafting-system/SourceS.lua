-- Server-side code
local markerX, markerY, markerZ = 2779.9921875, -2417.47265625, 13.635567665
local craftingMarker = createMarker(markerX, markerY, markerZ, "cylinder", 1.5, 255, 0, 0, 150)

function onPlayerEnterMarker(hitPlayer, matchingDimension)
    if hitPlayer and getElementType(hitPlayer) == "player" and matchingDimension then
        outputChatBox("Hello, " .. getPlayerName(hitPlayer) .. "! Welcome to the crafting area.", hitPlayer, 0, 255, 0)
    end
end

addEventHandler("onMarkerHit", craftingMarker, onPlayerEnterMarker)