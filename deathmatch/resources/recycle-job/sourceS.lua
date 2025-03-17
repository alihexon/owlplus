local materials = {
    {name = "Rubber", price = 100},
    {name = "Plastic", price = 200},
    {name = "Iron", price = 300},
    {name = "Steel", price = 400},
    {name = "Aluminum", price = 500},
    {name = "Metalscrap", price = 600},
    {name = "Copper", price = 700},
    {name = "Glass", price = 800}
}

local playerProgress = {}
local playerBoxes = {}

function sendCustomNotification(player, message, type)
    exports["alii_infobox"]:add(player, "Recycle Job", type, message)
end

function givePlayerBox(player)
    local box = createObject(1271, 0, 0, 0)
    setObjectScale(box, 0.7)
    setElementInterior(box, getElementInterior(player))
    setElementDimension(box, getElementDimension(player))
    exports.bone_attach:attachElementToBone(box, player, 12, 0.2, 0.2, 0.2, 0, 90, 65)
    playerBoxes[player] = box
end

function removePlayerBox(player)
    if playerBoxes[player] and isElement(playerBoxes[player]) then
        exports.bone_attach:detachElementFromBone(playerBoxes[player])
        destroyElement(playerBoxes[player])
        playerBoxes[player] = nil
    end
end

function onPlayerPickupBox()
    local player = client
    if playerProgress[player] and playerProgress[player].grabbedBox then
        sendCustomNotification(player, "[OMEGA RP] Shoma yek box dar dast darid.", "error")
        return
    end

    local selectedMaterial = materials[math.random(1, #materials)]
    playerProgress[player] = {
        grabbedBox = true,
        material = selectedMaterial.name,
        materialPrice = selectedMaterial.price
    }
    
    givePlayerBox(player)
    sendCustomNotification(player, "[OMEGA RP] Shoma yek box " .. selectedMaterial.name .. " daryaft kardid.", "info")
end
addEvent("playerPickedUpBox", true)
addEventHandler("playerPickedUpBox", resourceRoot, onPlayerPickupBox)

function onPlayerDeliverBox()
    local player = client
    if not playerProgress[player] or not playerProgress[player].grabbedBox then
        sendCustomNotification(player, "[OMEGA RP] Shoma boxi baraye tahvil dadan nadarid.", "error")
        return
    end

    local payment = playerProgress[player].materialPrice
    exports.global:giveMoney(player, payment)
    sendCustomNotification(player, "[OMEGA RP] Shoma box ra tahvil dadid va $" .. payment .. " daryaft kardid.", "success")

    removePlayerBox(player)
    playerProgress[player] = nil
end
addEvent("playerDeliveredBox", true)
addEventHandler("playerDeliveredBox", resourceRoot, onPlayerDeliverBox)

function onPlayerToggleDuty(onDuty)
    local player = client
    if onDuty then
        sendCustomNotification(player, "[OMEGA RP] Shoma on-duty kardid.", "info")
    else
        sendCustomNotification(player, "[OMEGA RP] Shoma off-duty kardid.", "info")
    end
end
addEvent("playerToggleDuty", true)
addEventHandler("playerToggleDuty", resourceRoot, onPlayerToggleDuty)

-- New event to handle off-duty with box
addEvent("playerCannotGoOffDuty", true)
addEventHandler("playerCannotGoOffDuty", resourceRoot, function()
    local player = client
    sendCustomNotification(player, "[OMEGA RP] Shoma nemitavanid off-duty shavid, chon yek box darid.", "error")
end)

-- Handle marker entry notifications
function onPlayerEnteredMarker(markerType, onDuty)
    local message
    if markerType == "pickup" then
        message = "[OMEGA RP] Baraye bardashtane yek box dokmeye E ra feshar dahid."
    elseif markerType == "dropoff" then
        message = "[OMEGA RP]Baraye gozashtane yek box dokmeye E ra feshar dahid."
    elseif markerType == "duty" then
        message = onDuty and "[OMEGA RP] Baraye off-duty kardan dokmeye E ra feshar dahid." or "[OMEGA RP] Baraye on-duty kardan dokmeye E ra feshar dahid."
    end
    if message then
        sendCustomNotification(client, message, "info")
    end
end
addEvent("playerEnteredMarker", true)
addEventHandler("playerEnteredMarker", root, onPlayerEnteredMarker)

function onPlayerLeftMarker()
    -- Optional: Clear notifications if needed
end
addEvent("playerLeftMarker", true)
addEventHandler("playerLeftMarker", root, onPlayerLeftMarker)