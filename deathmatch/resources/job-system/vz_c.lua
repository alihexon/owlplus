local int = 1 
local dim = 48
local progress = 0

local meatPos = {
	{962.38, 2140.28, 1016.2},
	{962.38, 2137.22, 1016.2},
	{962.38, 2134.04, 1016.2},
	{962.38, 2130.13, 1016.2},
	{962.38, 2126.47, 1016.2},
	{962.38, 2122.8, 1016.2},
	
	{955.97, 2140.28, 1016.2},
	{955.97, 2137.22, 1016.2},
	{955.97, 2134.04, 1016.2},
	{955.97, 2130.13, 1016.2},
	{955.97, 2126.47, 1016.2},
	{955.97, 2122.8, 1016.2},
}

local opensans = dxCreateFont("files/opensans.ttf",14)
local showMeat = false
local s = {guiGetScreenSize()}
local box = {142,12}
local pos = {s[1]/2 - box[1]/2, s[2]/1.25 - box[2]/2}
local boxing = nil

local NpcJOB = createPed(111, 960.654296875, 2097.6044921875, 1011.0230102539)
setPedRotation(NpcJOB, 1.5903015136719)
setElementFrozen (source, frozen)
setElementInterior(NpcJOB,int)
setElementDimension(NpcJOB,dim)

function cancelDamageEvent()
	if NpcJOB then
		cancelEvent()
	end
end
addEventHandler("onClientPedDamage",  getRootElement(), cancelDamageEvent)

local meatObjects = {
	{14589,945.6, 2139.4, 1013.2},
	{14586,946.13, 2141.182, 1016.44},
	{14587,948.77, 2146.45, 1015.4},
}

addEventHandler("onClientResourceStart",resourceRoot,function()
	for k,v in ipairs(meatObjects) do
		asd = createObject(v[1],v[2],v[3],v[4])
		setElementInterior(asd,int)
		setElementDimension(asd,-1)
	end
	for k,v in ipairs(meatPos) do
		obj = createObject(2589,v[1],v[2],v[3])
		setElementInterior(obj,int)
		setElementDimension(obj,dim)
		setElementData(obj,"isMeat",true)
		setElementFrozen(obj,true)
	end
	meatMarker = createMarker(942.42047119141, 2117.9008789063, 1010.0302734375,"cylinder",1,65, 105, 225,60)
	setElementDimension(meatMarker,dim)
	setElementInterior(meatMarker,int)
	setElementData(meatMarker,"boxingMarker",true)
	
	dropMarker = createMarker(964.939453125, 2160.0126953125, 1010.3,"cylinder",1,65, 105, 225,60)
	setElementDimension(dropMarker,dim)
	setElementInterior(dropMarker,int)
	setElementData(dropMarker,"boxDropMarker",true)
	setElementData(localPlayer, "isMeatInHand",false)
	setElementData(localPlayer, "isBoxInHand",false)
	
end)

addEventHandler("onClientRender",getRootElement(),function()
	if isElement(boxing) then
		local x,y,z = getElementPosition(boxing)
		if y >= 2136.38 then
			if getElementModel(boxing) == 2806 then
				setElementModel(boxing,1271)
				setElementPosition(boxing,x,y,z+0.1)
			end
		end
	end
end)

addEventHandler("onClientObjectDamage", getRootElement(),function(loss,attacker)
	if getElementData(source,"isMeat") then
		if localPlayer == attacker then
			if not isElement(boxing) then
				if getPedWeapon(localPlayer) == 2 then
					if showMeat then
						if progress >= 0 then
							--rand = math.random(30,40)
							rand = math.random(10,15) ----- This Is Speed
							progress = progress+(loss/rand)
							if progress+(loss/rand) >= 156.2 then
								showMeat = false
								progress = 0
								triggerServerEvent("givePlayerMeat",localPlayer,localPlayer)
							end
						end
					end
				end
			else
			end
		end
	end
end)

addEventHandler("onClientMarkerHit", resourceRoot, function(player,dim)
	if player == localPlayer then
		if getElementData(source, "boxingMarker") then
			if getElementData(localPlayer, "job") == 8 then
				if getElementData(localPlayer,"isMeatInHand") then
					progress = 0
					triggerServerEvent("takePlayerMeat",localPlayer,localPlayer)
					if not isElement(boxing) then
						boxing = createObject(2806,942.39227294922, 2119.8, 1011.3)
						setElementData(boxing,"isBoxingObject",false)
						setObjectScale(boxing,0.7)
						setElementRotation(boxing,0,0,90)
						setElementInterior(boxing,1)
						setElementDimension(boxing,48)
						moveObject ( boxing, 20000,942.39227294922, 2136.4, 1011.3)
					end
					theTimer = setTimer( function()
					setElementData(boxing,"isBoxingObject",true)
					theTimer = nil
					end, 20000,1)
				end
			end
		elseif getElementData(source,"boxDropMarker") then
			if getElementData(localPlayer, "job") == 8 then
				if getElementData(localPlayer,"isBoxInHand") then
					triggerServerEvent("takePlayerBox",localPlayer,localPlayer)
					triggerServerEvent("vz_GiveMoney",localPlayer,localPlayer)
				end
			end
		end
	end
end)

local meatElement = nil

setTimer(function()
		if getElementInterior(localPlayer) == int and getElementDimension(localPlayer) == dim then
			for k,v in ipairs(getElementsByType("object")) do
				if getElementData(v,"isMeat") then
					local pX,pY,pZ = getElementPosition(localPlayer)
					local eX,eY,eZ = getElementPosition(v)
					if getDistanceBetweenPoints3D(pX,pY,pZ,eX,eY,eZ-4) <= 2 then
						if getElementData(localPlayer, "job") == 8 then
							if getPedWeapon(localPlayer) == 2 then
								if not showMeat then
									showMeat = true
									meatElement = v
								end
							end
						end
					end
					if getDistanceBetweenPoints3D(pX,pY,pZ,eX,eY,eZ-4) >= 2 then
						if meatElement == v then
							if getElementData(localPlayer, "job") == 8 then
								if showMeat then
									showMeat = false
									meatElement = nil
									if progress >= 0 then
										progress = 0
									end
								end
							end
						end
					end
				end
			end
		end
end,250,0)

addEventHandler("onClientRender",getRootElement(),function()

	if showMeat then
		dxDrawRectangle(pos[1],pos[2],box[1],box[2]+20,tocolor(0,0,0,80))
		dxDrawRectangle(pos[1],pos[2],progress,box[2]+20,tocolor(65, 105, 225,200))
		dxDrawRectangle(pos[1],pos[2]-2,box[1],2,tocolor(0,0,0,160))
		dxDrawRectangle(pos[1],pos[2]+32+0.1,box[1],2,tocolor(0,0,0,160))
		dxDrawRectangle(pos[1]-2,pos[2]-2,2,box[2]+24,tocolor(0,0,0,160))
		dxDrawRectangle(pos[1]+box[1],pos[2]-2,2,box[2]+24,tocolor(0,0,0,160))
	end
	
	if getElementData(localPlayer, "isMeatInHand") then
		toggleControl("fire", false)
		toggleControl("sprint", false)
		toggleControl("crouch", false)
		toggleControl("jump", false)
	elseif getElementData(localPlayer,"isBoxInHand") then
		toggleControl("fire", false)
		toggleControl("sprint", false)
		toggleControl("crouch", false)
		toggleControl("jump", false)
	end
end)

addEventHandler("onClientClick", getRootElement(), function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if button == "left" and state == "down" then
		if isElement(clickedElement) then
		local x, y, z = getElementPosition(localPlayer)
		local ex, ey, ez = getElementPosition(clickedElement)
		if getDistanceBetweenPoints3D(x, y, z, ex, ey, ez) <= 2 then
			if getElementType(clickedElement) == "object" then
				if getElementData(clickedElement,"isBoxingObject")  == true then
				setElementData(clickedElement,"isBoxingObject",false)
				triggerServerEvent("givePlayerBox",localPlayer,localPlayer)
			    destroyElement(clickedElement)
				end
			end
		end
		end
	end
end)
