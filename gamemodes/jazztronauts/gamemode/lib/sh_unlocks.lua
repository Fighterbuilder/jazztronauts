if SERVER then
	util.AddNetworkString( "unlock_msg" )
	AddCSLuaFile("sh_unlocks.lua")
end

module( "unlocks", package.seeall )

--take our localization off of the list name
local function localization_strip(list_name)
	if not isstring(list_name) then return list_name end
	if not string.find(list_name,"_",1,false) then return list_name end
	local split = string.Explode("_",list_name)
	local name = ""
	for i=1,#split-1 do
		name = name..split[i]
	end
	return name
end

unlock_lists = unlock_lists or {}

function IsValid( list_name )
	local name = localization_strip(list_name)
	return unlock_lists[name] ~= nil

end

function Clear( list_name )

	if SERVER then
		local name = localization_strip(list_name)
		
		local table_name = "unlocklist_" .. name
		sql.Query( "DROP TABLE \"" .. table_name .."\"" )
		print("Dropping " .. table_name)

	end

end

function ClearAll()
	for k, v in pairs(unlock_lists) do
		Clear(k)
	end
end

function Register( list_name )

	local name = localization_strip(list_name)

	if unlock_lists[name] ~= nil then return end

	if CLIENT then

		unlock_lists[name] = {
			keys = {},
			values = {},
		}

	else

		local table_name = "unlocklist_" .. name
		local columns = "steamid bigint(64) DEFAULT '0', strkey varchar(32)"

		--for testing
		--sql.Query( "DROP TABLE " .. table_name )

		if not sql.TableExists( table_name ) then

			--deal with it
			if false == sql.Query( ("CREATE TABLE %s (%s)"):format(table_name, columns) ) then
				print("ERROR: " .. tostring( sql.LastError() ) )
			end
		end

		unlock_lists[name] = table_name

	end

end

function IsUnlocked( list_name, ply, key )

	local name = localization_strip(list_name)
	
	if CLIENT then

		if unlock_lists[name] == nil then return false end
		return unlock_lists[name]["keys"][key] or false

	else

		if not unlock_lists[name] then return false end
		local steam_id = ply:SteamID64()
		local result = sql.Query( ("SELECT * FROM \"%s\" WHERE steamid = '%s' AND strkey = '%s'"):format(
			unlock_lists[name],
			steam_id,
			key ) )

		if false == result then
			print("ERROR: " .. tostring( sql.LastError() ) )
			return false
		end

		return result ~= nil

	end

	return false

end

function Unlock( list_name, ply, key )
	local name = localization_strip(list_name)

	if not unlock_lists[name] then return false end
	if IsUnlocked( name, ply, key ) then return false end

	if CLIENT then

		--print("UNLOCKED: " .. "[" .. name .. "] " .. key)

		local list = unlock_lists[name]
		list["keys"][key] = true
		table.insert( list["values"], key )

		hook.Call( "OnUnlocked", nil, name, key, ply )
		return true

	end

	local steam_id = ply:SteamID64()
	local result = sql.Query( ("INSERT INTO \"%s\" VALUES ('%s','%s')"):format(
		unlock_lists[name],
		steam_id,
		key ) )

	if false == result then
		print("ERROR: " .. tostring( sql.LastError() ) )
		return false
	end

	hook.Call( "OnUnlocked", nil, name, key, ply )

	net.Start( "unlock_msg" )
	net.WriteString( name )
	net.WriteString( key )
	net.Send( ply )

	return true

end

function GetAll( list_name, ply )

	local name = localization_strip(list_name)

	if CLIENT then

		return unlock_lists[name]["values"]

	end

	local steam_id = ply:SteamID64()
	local result = sql.Query( ("SELECT * FROM \"%s\" WHERE steamid = '%s'"):format(
		unlock_lists[name],
		steam_id ) )

	if false == result then
		print("ERROR: " .. tostring( sql.LastError() ) )
		return false
	end

	local t = {}
	for k,v in pairs( result or {} ) do
		table.insert(t, v.strkey)
	end

	return t

end

if CLIENT then

	net.Receive( "unlock_msg", function()

		local list_name = net.ReadString()
		
		local key = net.ReadString()

		if not unlock_lists[list_name] then
			Register( list_name )
		end

		Unlock( list_name, LocalPlayer(), key )

	end )

end

--DOWNLOADING

local function EncodeList( list_name, ply )

	local name = localization_strip(list_name)
	
	local blob = tostring(name) .. '\0'

	for x, str in pairs( GetAll( tostring(name), ply ) ) do
		blob = blob .. str .. '\0'
	end

	return blob

end

local function DecodeList( blob )

	local buf = ""
	local strings = {}

	for i=1, #blob do
		if blob[i] == '\0' then
			table.insert( strings, buf )
			buf = ""
		else
			buf = buf .. blob[i]
		end
	end

	local name = strings[1]
	table.remove( strings, 1 )

	return name, strings

end

download.Register( "download_unlocks", function( cb, dl )

	if CLIENT then

		if cb == DL_FINISHED then

			local list_name, strings = DecodeList( dl:GetData() )

			if not unlock_lists[list_name] then

				Register( list_name )

			end

			for _, key in pairs( strings ) do

				Unlock( list_name, LocalPlayer(), key )

			end

		end

	else

		if cb == DL_PROGRESS then

			print( dl.list_name .. " : " .. tostring(dl:GetPlayer()) .. " : " .. tostring(dl))

		end

	end

end )

function DownloadToPlayer( list_name, ply )

	local name = localization_strip(list_name)
	
	if CLIENT then return end

	local data = EncodeList( name, ply )
	if #data > 0 then

		print("QUEUED DOWNLOAD FOR LIST: " .. name .. " TO PLAYER " .. tostring( ply ) )

		local dl = download.Start( "download_unlocks", data, ply, 50000 )
		if dl then
			dl.list_name = name
		end
	end

end

hook.Add( "PlayerInitialSpawn", "download_unlocks", function(ply)

	for list_name, _ in pairs( unlock_lists ) do

		DownloadToPlayer( list_name, ply )

	end

end )


hook.Add( "OnUnlocked", "unlock_test", function( list_name, key, ply )

	--local name = localization_strip(list_name)

	--print( ("  UNLOCKED[ %s ] => %s (for %s)" ):format( name, key, tostring(ply) ) )

end )

concommand.Add( "jazz_download_unlocks_to_players", function( ply )

	if ply:IsAdmin() then

		for _, pl in pairs( player.GetAll() ) do

			for list_name, _ in pairs( unlock_lists ) do
				DownloadToPlayer( list_name, pl )
			end

		end

	end

end )


--[[Register("ballocs")
Unlock("ballocs", player.GetAll()[1], "props/props_static/this_prop_sucks.mdl")
Unlock("ballocs", player.GetAll()[1], "props/props_dynamic/this_prop_sucks_too.mdl")
Unlock("ballocs", player.GetAll()[1], "props/props_dynamic/this_prop_sucks_too.mdl")
Unlock("ballocs", player.GetAll()[1], "props/props_junk/fuck_this.mdl")


DownloadToPlayer("ballocs", player.GetAll()[1])]]