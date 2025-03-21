local REQUIRED, NOT_REQUIRED, LOADED = 0, 1, 2

local interface = {
	edf = REQUIRED,
	editor_gui = NOT_REQUIRED,
	freecam = REQUIRED,
	move_cursor = REQUIRED,
	move_freecam = REQUIRED,
	move_keyboard = REQUIRED,
}

local interface_mt = {
	__index = function(t, k)
		if getUserdataType(t.res) ~= "resource-data" or getResourceState(t.res) ~= "running" then return end
		return function(...) return call(t.res, k, ...) end
	end
}

addEventHandler("onClientResourceStart", root,
	function(resource)
		local name = getResourceName(resource)
		if interface[name] then
			_G[name] = setmetatable({res=resource}, interface_mt)
			interface[name] = LOADED
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		for name in pairs(interface) do
			local resource = getResourceFromName(name)
			if resource then
				_G[name] = setmetatable({res=resource}, interface_mt)
				interface[name] = LOADED
			end
		end
	end
)

function isInterfaceLoaded()
	local isLoaded = true
	for name, state in pairs(interface) do
		if state == REQUIRED then
			isLoaded = false
			break
		end
	end
	return isLoaded
end
