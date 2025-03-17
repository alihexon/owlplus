local pickupMarkers = {}
local markerPositions = {
    {936, -1117, 24 - 1},
    {938, -1120, 24 - 1},
    {940, -1122, 24 - 1},
    {942, -1125, 24 - 1},
    {944, -1127, 24 - 1},
    {946, -1130, 24 - 1}
}

local secondMarker = nil
local activeMarker = nil
local playerInRange = false
local dutyMarker = nil
local onDuty = false
local hasBox = false

local hasSeenPickupNotification = false
local hasSeenDropoffNotification = false

function createPickupMarkers()
    if onDuty then
        for i, pos in ipairs(markerPositions) do
            local marker = createMarker(pos[1], pos[2], pos[3], "cylinder", 1.5, 0, 255, 0, 80)
            setElementData(marker, "markerID", i)
            setElementData(marker, "isPickup", true)
            table.insert(pickupMarkers, marker)
        end
    end
end

function createDropoffMarker()
    secondMarker = createMarker(934, -1105, 23, "cylinder", 1.5, 255, 0, 0, 150)
    setElementData(secondMarker, "isDropoff", true)
    destroyElement(secondMarker)
end

function createDutyMarker()
    dutyMarker = createMarker(950.5419921875, -1099.7421875, 23, "cylinder", 1.5, 0, 0, 255, 80)
    setElementData(dutyMarker, "isDutyMarker", true)
end

function showRandomPickupMarker()
    for _, marker in ipairs(pickupMarkers) do
        destroyElement(marker)
    end
    pickupMarkers = {}

    local randomIndex = math.random(1, #markerPositions)
    local pos = markerPositions[randomIndex]
    activeMarker = createMarker(pos[1], pos[2], pos[3], "cylinder", 1.5, 0, 255, 0, 150)
    setElementData(activeMarker, "isPickup", true)
    table.insert(pickupMarkers, activeMarker)
end

function onMarkerHit(hitElement)
    if hitElement ~= localPlayer then return end
    playerInRange = true
    local markerType
    if getElementData(source, "isPickup") then
        markerType = "pickup"
    elseif getElementData(source, "isDropoff") then
        markerType = "dropoff"
    elseif getElementData(source, "isDutyMarker") then
        markerType = "duty"
    end
    if markerType then
        if markerType == "duty" then
            triggerServerEvent("playerEnteredMarker", localPlayer, markerType, onDuty)
        else
            if (markerType == "pickup" and not hasSeenPickupNotification) or
               (markerType == "dropoff" and not hasSeenDropoffNotification) then
                triggerServerEvent("playerEnteredMarker", localPlayer, markerType)
                if markerType == "pickup" then
                    hasSeenPickupNotification = true
                elseif markerType == "dropoff" then
                    hasSeenDropoffNotification = true
                end
            end
        end
    end
end

function onMarkerLeave(leaveElement)
    if leaveElement == localPlayer then
        playerInRange = false
        triggerServerEvent("playerLeftMarker", localPlayer)
    end
end

function onKeyPress(button, press)
    if onDuty then
        toggleControl("sprint", false)
        toggleControl("jump", false)
        toggleControl("crouch", false)
        toggleControl("fire", false)
    
        function checkSprinting()
            if onDuty then
                local player = getLocalPlayer()
                local isSprinting = getPedControlState(player, "sprint")
    
                if isSprinting then
                    setPedControlState(player, "sprint", false)
                end
            else
                removeEventHandler("onClientRender", root, checkSprinting)
            end
        end
    
        addEventHandler("onClientRender", root, checkSprinting)
    end

    if button == "e" and press and playerInRange then
        if isElement(activeMarker) and getElementData(activeMarker, "isPickup") and isElementWithinMarker(localPlayer, activeMarker) then
            if not hasBox then
                setPedAnimation(localPlayer, "CARRY", "liftup", -1, false, false, false, false)
                
                setTimer(function()
                    setPedAnimation(localPlayer, "CARRY", "crry_prtial", 1, true, true, true, true)
                    triggerServerEvent("playerPickedUpBox", resourceRoot)
                    
                    setTimer(function()
                        setPedAnimation(localPlayer, "CARRY", "idle", -1, false, false, false, false)
                    end, 1000, 1)
                    
                    destroyElement(activeMarker)
                    if isElement(secondMarker) then
                        destroyElement(secondMarker)
                    end
                    secondMarker = createMarker(934, -1105, 23, "cylinder", 1.5, 255, 0, 0, 150)
                    setElementData(secondMarker, "isDropoff", true)
                    setElementData(secondMarker, "visible", true)
                    hasBox = true
                end, 1200, 1)
            end
        elseif isElement(secondMarker) and getElementData(secondMarker, "isDropoff") and isElementWithinMarker(localPlayer, secondMarker) then
            if hasBox then
                setPedAnimation(localPlayer, "CARRY", "putdwn", -1, false, false, false, false)
                triggerServerEvent("playerDeliveredBox", resourceRoot)
                destroyElement(secondMarker)
                showRandomPickupMarker()
                hasBox = false
                hasSeenPickupNotification = false
            end
        elseif isElement(dutyMarker) and getElementData(dutyMarker, "isDutyMarker") and isElementWithinMarker(localPlayer, dutyMarker) then
            if onDuty then
                if hasBox then
                    triggerServerEvent("playerCannotGoOffDuty", resourceRoot)
                    return
                end
                if isElement(activeMarker) then
                    destroyElement(activeMarker)
                end
                if isElement(secondMarker) then
                    destroyElement(secondMarker)
                end
                toggleControl("sprint", true)
                toggleControl("jump", true)
                triggerServerEvent("playerToggleDuty", resourceRoot, false)
            else
                createPickupMarkers()
                showRandomPickupMarker()
                toggleControl("sprint", false)
                toggleControl("jump", false)
                triggerServerEvent("playerToggleDuty", resourceRoot, true)
            end
            onDuty = not onDuty
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    createDutyMarker()
    createDropoffMarker()
end)

addEventHandler("onClientMarkerHit", root, onMarkerHit)
addEventHandler("onClientMarkerLeave", root, onMarkerLeave)
addEventHandler("onClientKey", root, onKeyPress)
