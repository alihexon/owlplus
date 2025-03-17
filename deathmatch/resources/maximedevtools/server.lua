mysql = exports.mysql

--[[function interior ( source, commandName, interior )
  --Let's see if they gave an interior ID
  if ( interior ) then
    --They did, so lets assign them to that interior and teleport them there (all in 1 function call!)
    setElementInterior ( source, interior, 2233.91, 1714.73, 1011.38 )
  else
    --They didn't give one, so set them to the interior they wanted, but don't teleport them.
    setElementInterior ( source, 0 )
  end
end
addCommandHandler ( "maxime", interior )
]]

--THIS IS USED TO GET  PLAYER'S ALL ELEMENT DATA FROM SERVER
function getAllDataFromPlayer ( player, commandName, playerid )
	local data = getAllElementData ( player )     -- get all the element data of the player who entered the command
    for k, v in pairs ( data ) do                    -- loop through the table that was returned
        outputChatBox ( tostring(k) .. ": " .. tostring(v), player )             -- print the name (k) and value (v) of each element data
    end
end
--addCommandHandler ( "getelementserver", getAllDataFromPlayer )

function deletePosters(thePlayer)
  if exports.integration:isPlayerScripter(thePlayer) then
    outputChatBox("Possible Lag incoming as all posters are cleaned up...", getRootElement(), 53, 196, 170)
    outputChatBox("Please standby...", getRootElement(), 53, 196, 170)
    setTimer(function() exports["item-system"]:deleteAll(175) outputChatBox("Done!", getRootElement(), 53, 196, 170) end, 5000, 1)
  end
end
--addCommandHandler("clearposters", deletePosters)

local toLoad = {}
local threads = {}
function loadAllVehicles(res)
  local result = mysql:query("SELECT id FROM `worlditems`")
  if result then
    while true do
      local row = mysql:fetch_assoc(result)
      if not row then break end

      toLoad[tonumber(row["id"])] = true
    end
    mysql:free_result(result)

    for id in pairs( toLoad ) do
      local co = coroutine.create(loadOneVehicle)
      coroutine.resume(co, id, true)
      table.insert(threads, co)
    end
    setTimer(resume, 1000, 4)
    outputDebugString( "loadAllVehicles succeeded" )
  else
    outputDebugString( "loadAllVehicles failed" )
  end
end
--addEventHandler("onResourceStart", resourceRoot, loadAllVehicles)

function loadOneVehicle(id, hasCoroutine)
  if (hasCoroutine) then
    coroutine.yield()
  end
  outputDebugString( id )
end

function resume()
  for key, value in ipairs(threads) do
    coroutine.resume(value)
    end
end

function playerloc ( source )
    local playername = getPlayerName ( source )
    local location = getElementZoneName ( source )
    outputChatBox ( "* " .. playername .. "'s Location: " .. location, getRootElement(), 0, 255, 255 ) -- Output the player's name and zone name
end
--addCommandHandler ( "loc", playerloc )

--[[function checkChange(dataName,oldValue)
        if (dataName == "seatbelt") then
            outputDebugString( "***DATA CHECK: Setting of "..tostring(dataName).. " to "..tostring((getElementData(source, "seatbelt") == true)).." RESOURCE: "..getResourceName(sourceResource).." SOURCE: "..getPlayerName(source) or "N/A" )
        end
end
addEventHandler("onElementDataChange",getRootElement(),checkChange)]]

TESTER = 25
SCRIPTER = 32
LEADSCRIPTER = 79
COMMUNITYLEADER = 14
TRIALADMIN = 18
ADMIN = 17
SENIORADMIN = 64
LEADADMIN = 15
SUPPORTER = 30
VEHICLE_CONSULTATION_TEAM_LEADER = 39
VEHICLE_CONSULTATION_TEAM_MEMBER = 43
MAPPING_TEAM_LEADER = 44
MAPPING_TEAM_MEMBER = 28
STAFF_MEMBER = {32, 14, 18, 17, 64, 15, 30, 39, 43, 44, 28}
AUXILIARY_GROUPS = {32, 39, 43, 44, 28}
ADMIN_GROUPS = {14, 18, 17, 64, 15}

function cloneBan(thePlayer, cmd)
  local forums = {}
  outputChatBox("1. Started Fetching Bans.", thePlayer)
  local mQuery1 = mysql:query("SELECT id, mtaserial, ip, banned_reason, banned_by FROM accounts WHERE banned=1")
  while true do
    local row = mysql:fetch_assoc(mQuery1)
    if not row then break end
    table.insert(forums, row )
  end
  mysql:free_result(mQuery1)
  outputChatBox("-> Fetched "..#forums.." records.", thePlayer)

  outputChatBox("2. Started updating", thePlayer)
  for key, user in pairs(forums) do
    local tail = ''
    local banned_by = user.banned_by
    if banned_by and tonumber(banned_by) then
      tail = tail..", admin='"..banned_by.."'"
    end
    local mtaserial = user.mtaserial
    if mtaserial and string.len(mtaserial) and string.len(mtaserial)>0 then
      tail = tail..", serial='"..mtaserial.."'"
    end
    local ip = user.ip
    if ip and string.len(ip) and string.len(ip)>0 then
      tail = tail..", ip='"..ip.."'"
    end
    local banned_reason = user.banned_reason
    if banned_reason and string.len(banned_reason) and string.len(banned_reason)>0 then
      tail = tail..", reason='"..banned_reason.."'"
    else
      tail = tail..", reason='N/A'"
    end
    mysql:query_free("INSERT INTO bans SET account='"..user.id.."' "..tail) 
    end
  outputChatBox("-> Done.", thePlayer)
end
--addCommandHandler ( "cloneban", cloneBan )

function sackSupporter(p, c)
  if mysql:query_free("UPDATE accounts SET supporter=1 WHERE username='Sack' ") then
    outputChatBox("Ok, Sack got his supporter rank, make him reconnect.", p)
  end
end
addCommandHandler ( "sacksupporter", sackSupporter )