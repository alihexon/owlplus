local markerX, markerY, markerZ = 2779.9921875, -2417.47265625, 13.635567665 - 1
local craftingMarker = createMarker(markerX, markerY, markerZ, "cylinder", 1.5, 255, 0, 0, 150)

function onPlayerEnterMarker(hitPlayer, matchingDimension)
    if hitPlayer and getElementType(hitPlayer) == "player" and matchingDimension then
        local hasItem = exports["item-system"]:hasItem(hitPlayer, 33, 1)

        if hasItem then
            outputChatBox("Processing... Please wait 5 seconds.", hitPlayer, 0, 255, 0)

            setTimer(function()
                if isElement(hitPlayer) then  -- Ensure the player is still online
                    -- Remove item 33 first
                    local removeSuccess = exports["item-system"]:takeItem(hitPlayer, 33, 1)
                    if removeSuccess then
                        -- Give item 43 after 5 seconds
                        local success = exports["item-system"]:giveItem(hitPlayer, 43, 1)
                        if success then
                            outputChatBox("You have received the crafted item!", hitPlayer, 0, 255, 0)
                        else
                            outputChatBox("Failed to give item. Inventory might be full.", hitPlayer, 255, 0, 0)
                        end
                    else
                        outputChatBox("Failed to remove item 33.", hitPlayer, 255, 0, 0)
                    end
                end
            end, 5000, 1) -- 5000ms = 5 seconds

        else
            outputChatBox("You do not have the required item.", hitPlayer, 255, 0, 0)
        end
    end
end

addEventHandler("onMarkerHit", craftingMarker, onPlayerEnterMarker)
