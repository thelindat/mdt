QBCore = nil
local call_index = 0

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

RegisterServerEvent("mdt:hotKeyOpen")
AddEventHandler("mdt:hotKeyOpen", function()
	local usource = source
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if xPlayer.PlayerData.job.name == 'police' then
    	exports['ghmattimysql']:execute("SELECT * FROM (SELECT * FROM `mdt_reports` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(reports)
    		for r = 1, #reports do
    			reports[r].charges = json.decode(reports[r].charges)
    		end
    		exports['ghmattimysql']:execute("SELECT * FROM (SELECT * FROM `mdt_warrants` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(warrants)
    			for w = 1, #warrants do
    				warrants[w].charges = json.decode(warrants[w].charges)
    			end

    			local officer = GetCharacterName(usource)
    			TriggerClientEvent('mdt:toggleVisibilty', usource, reports, warrants, officer, xPlayer.PlayerData.job.name, xPlayer.PlayerData.job.grade.name)
    		end)
    	end)
    end
end)

RegisterServerEvent("mdt:getOffensesAndOfficer")
AddEventHandler("mdt:getOffensesAndOfficer", function()
	local usource = source
	local charges = {}
	exports['ghmattimysql']:execute('SELECT * FROM fine_types', {
	}, function(fines)
		for j = 1, #fines do
			if fines[j].category == 0 or fines[j].category == 1 or fines[j].category == 2 or fines[j].category == 3 then
				table.insert(charges, fines[j])
			end
		end

		local officer = GetCharacterName(usource)

		TriggerClientEvent("mdt:returnOffensesAndOfficer", usource, charges, officer)
	end)
end)

RegisterNetEvent("mdt:performOffenderSearch")
AddEventHandler("mdt:performOffenderSearch", function(query)
	local src = source
	local matches = {}
	exports['ghmattimysql']:execute('SELECT * FROM `players`', {
	},function(result)
		for i,v in pairs(result) do
			charinfo = json.decode(v.charinfo)
			if charinfo ~= nil then
				query = string.lower(query)
				first = string.lower(charinfo.firstname)
				last = string.lower(charinfo.lastname)
				local name = nil
				if first ~= '' and last ~= '' then
					name = first .. ' ' .. last
				end
				v.firstname = charinfo.firstname
				v.lastname = charinfo.lastname
				v.id = v.citizenid
				v.char_id = v.citizenid
				if name ~= nil then
					if string.find(query, name) then
						table.insert(matches, v)
					elseif string.find(query, first) then
						table.insert(matches, v)
					elseif string.find(query, last) then
						table.insert(matches, v)
					end
				end
			end
		end

		TriggerClientEvent("mdt:returnOffenderSearchResults", src, matches)
	end)
end)

RegisterServerEvent("mdt:getOffenderDetails")
AddEventHandler("mdt:getOffenderDetails", function(offender)
	local usource = source
	local player = QBCore.Functions.GetPlayerByCitizenId(offender.citizenid)
	offender.phone_number = player.PlayerData.charinfo.phone
	offender.dateofbirth = player.PlayerData.charinfo.birthdate
	offender.licenses = {}

	exports['ghmattimysql']:execute('SELECT * FROM `players` WHERE `citizenid` = @id', {
		['@id'] = offender.id
	}, function(player)
		player = player[1]
		if player and player.metadata then
			local metadata = json.decode(player.metadata)
			offender.fingerprint = metadata.fingerprint
			for k,v in pairs(metadata['licences']) do
				if k and v then
					if k == 'driver' then
						k = 'Driver'
					elseif k == 'business' then
						k = 'Business'
					elseif k == 'weapon' then
						k = 'Weapon'
					end
					table.insert(offender.licenses, k)
				end
			end
		end
	end)

	exports['ghmattimysql']:execute('SELECT * FROM `player_mdt` WHERE `char_id` = @id', {
		['@id'] = offender.id
	}, function(result)
		offender.notes = ""
		offender.mugshot_url = ""
		offender.bail = false

		if result[1] then
			offender.notes = result[1].notes
			offender.mugshot_url = result[1].mugshot_url
			offender.bail = result[1].bail
		end
	end)

	exports['ghmattimysql']:execute('SELECT * FROM `player_convictions` WHERE `char_id` = @id', {
		['@id'] = offender.id
	}, function(convictions)
		if convictions[1] then
			offender.convictions = {}
			for i = 1, #convictions do
				local conviction = convictions[i]
				offender.convictions[conviction.offense] = conviction.count
			end
		end
	end)

	exports['ghmattimysql']:execute('SELECT * FROM `mdt_warrants` WHERE `char_id` = @id', {
		['@id'] = offender.id
	}, function(warrants)
		if warrants[1] then
			offender.haswarrant = true
		end
	end)

	offender.vehicles = ""

--[[ 	exports['ghmattimysql']:execute('SELECT * FROM `player_vehicles` WHERE `citizenid` = @id', {
		['@id'] = offender.id
	}, function(vehicles)
		for i = 1, #vehicles do
			vehicles[i].state, vehicles[i].stored, vehicles[i].job, vehicles[i].fourrieremecano, vehicles[i].vehiclename, vehicles[i].ownerName = nil
			vehicles[i].vehicle = json.decode(vehicles[i].vehicle)
			vehicles[i].model = vehicles[i].vehicle
			if vehicles[i].vehicle.color1 then
				if colors[tostring(vehicles[i].vehicle.color2)] and colors[tostring(vehicles[i].vehicle.color1)] then
					vehicles[i].color = colors[tostring(vehicles[i].vehicle.color2)] .. " on " .. colors[tostring(vehicles[i].vehicle.color1)]
				elseif colors[tostring(vehicles[i].vehicle.color1)] then
					vehicles[i].color = colors[tostring(vehicles[i].vehicle.color1)]
				elseif colors[tostring(vehicles[i].vehicle.color2)] then
					vehicles[i].color = colors[tostring(vehicles[i].vehicle.color2)]
				else
					vehicles[i].color = "Unknown"
				end
			end
			vehicles[i].vehicle = nil
			offender.vehicles = vehicles
		end
	end) ]]

	TriggerClientEvent("mdt:returnOffenderDetails", usource, offender)
end)

RegisterServerEvent("mdt:getOffenderDetailsById")
AddEventHandler("mdt:getOffenderDetailsById", function(char_id)
	local usource = source
	local player = QBCore.Functions.GetPlayerByCitizenId(char_id)

	exports['ghmattimysql']:execute('SELECT * FROM `players` WHERE `citizenid` = @id', {
		['@id'] = char_id
	}, function(result)
		local offender = result[1]
		if not offender then
			TriggerClientEvent("mdt:closeModal", usource)
			TriggerClientEvent("mdt:sendNotification", usource, "This person no longer exists.")
			return
		end
	end)

	offender.phone_number = player.PlayerData.charinfo.phone
	offender.dateofbirth = player.PlayerData.charinfo.birthdate
	offender.licenses = {}

	exports['ghmattimysql']:execute('SELECT * FROM `players` WHERE `citizenid` = @id', {
		['@id'] = offender.id
	}, function(player)
		player = player[1]
		if player and player.metadata then
			local metadata = json.decode(player.metadata)
			offender.fingerprint = metadata.fingerprint
			for k,v in pairs(metadata['licences']) do
				if k and v then
					if k == 'driver' then
						k = 'Driver'
					elseif k == 'business' then
						k = 'Business'
					elseif k == 'weapon' then
						k = 'Weapon'
					end
					table.insert(offender.licenses, k)
				end
			end
		end
	end)

	exports['ghmattimysql']:execute('SELECT * FROM `player_mdt` WHERE `char_id` = @id', {
		['@id'] = offender.id
	}, function(result)
		offender.notes = ""
		offender.mugshot_url = ""
		offender.bail = false

		if result[1] then
			offender.notes = result[1].notes
			offender.mugshot_url = result[1].mugshot_url
			offender.bail = result[1].bail
		end
	end)

	exports['ghmattimysql']:execute('SELECT * FROM `player_convictions` WHERE `char_id` = @id', {
		['@id'] = offender.id
	}, function(convictions)
		if convictions[1] then
			offender.convictions = {}
			for i = 1, #convictions do
				local conviction = convictions[i]
				offender.convictions[conviction.offense] = conviction.count
			end
		end
	end)

	exports['ghmattimysql']:execute('SELECT * FROM `mdt_warrants` WHERE `char_id` = @id', {
		['@id'] = offender.id
	}, function(warrants)
		if warrants[1] then
			offender.haswarrant = true
		end
	end)

	offender.vehicles = ""

--[[ 	local vehicles = exports['ghmattimysql']:execute('SELECT * FROM `player_vehicles` WHERE `owner` = @identifier', {
		['@identifier'] = offender.identifier
	})
	for i = 1, #vehicles do
		vehicles[i].state, vehicles[i].stored, vehicles[i].job, vehicles[i].fourrieremecano, vehicles[i].vehiclename, vehicles[i].ownerName = nil
		vehicles[i].vehicle = json.decode(vehicles[i].vehicle)
		vehicles[i].model = vehicles[i].vehicle.model
		if vehicles[i].vehicle.color1 then
			if colors[tostring(vehicles[i].vehicle.color2)] and colors[tostring(vehicles[i].vehicle.color1)] then
				vehicles[i].color = colors[tostring(vehicles[i].vehicle.color2)] .. " on " .. colors[tostring(vehicles[i].vehicle.color1)]
			elseif colors[tostring(vehicles[i].vehicle.color1)] then
				vehicles[i].color = colors[tostring(vehicles[i].vehicle.color1)]
			elseif colors[tostring(vehicles[i].vehicle.color2)] then
				vehicles[i].color = colors[tostring(vehicles[i].vehicle.color2)]
			else
				vehicles[i].color = "Unknown"
			end
		end
		vehicles[i].vehicle = nil
	end
	offender.vehicles = vehicles ]]

	TriggerClientEvent("mdt:returnOffenderDetails", usource, offender)
end)

RegisterServerEvent("mdt:saveOffenderChanges")
AddEventHandler("mdt:saveOffenderChanges", function(id, changes, identifier)
	local usource = source
	exports['ghmattimysql']:execute('SELECT * FROM `player_mdt` WHERE `char_id` = @id', {
		['@id']  = id
	}, function(result)
		if result[1] then
			exports['ghmattimysql']:execute('UPDATE `player_mdt` SET `notes` = @notes, `mugshot_url` = @mugshot_url, `bail` = @bail WHERE `char_id` = @id', {
				['@id'] = id,
				['@notes'] = changes.notes,
				['@mugshot_url'] = changes.mugshot_url,
				['@bail'] = changes.bail
			})
		else
			exports['ghmattimysql']:execute('INSERT INTO `player_mdt` (`char_id`, `notes`, `mugshot_url`, `bail`) VALUES (@id, @notes, @mugshot_url, @bail)', {
				['@id'] = id,
				['@notes'] = changes.notes,
				['@mugshot_url'] = changes.mugshot_url,
				['@bail'] = changes.bail
			})
		end
		
		if changes.licenses_removed then
			local xPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenid)

			if xPlayer then
				local licenses = xPlayer.PlayerData['metadata']['licences']
				for i = 1, #changes.licenses_removed do
					local license = string.lower(changes.licenses_removed[i])
					if licenses[license] ~= nil then
						licenses[license] = false
					end
				end
	
				xPlayer.Functions.SetMetaData('licences', licenses)
			else
				exports['ghmattimysql']:execute("SELECT * FROM `players` WHERE `citizenid` = '" .. citizenid .. "'", {}, function(result)
					if result[1] then
						local metadata = json.decode(result[1].metadata)
						for i = 1, #changes.licenses_removed do
							local license = string.lower(changes.licenses_removed[i])
							if metadata.licences[license] ~= nil then
								metadata.licences[license] = false
							end
						end

						exports['ghmattimysql']:execute("UPDATE `players` SET `metadata` = '" .. json.encode(metadata) .. "'")
					end
				end)
			end
		end

		if changes.convictions ~= nil then
			for conviction, amount in pairs(changes.convictions) do	
				exports['ghmattimysql']:execute('UPDATE `player_convictions` SET `count` = @count WHERE `char_id` = @id AND `offense` = @offense', {
					['@id'] = id,
					['@count'] = amount,
					['@offense'] = conviction
				})
			end
		end

		for i = 1, #changes.convictions_removed do
			exports['ghmattimysql']:execute('DELETE FROM `player_convictions` WHERE `char_id` = @id AND `offense` = @offense', {
				['@id'] = id,
				['offense'] = changes.convictions_removed[i]
			})
		end

		TriggerClientEvent("mdt:sendNotification", usource, "Offender changes have been saved.")
	end)
end)

RegisterServerEvent("mdt:saveReportChanges")
AddEventHandler("mdt:saveReportChanges", function(data)
	exports['ghmattimysql']:execute('UPDATE `mdt_reports` SET `title` = @title, `incident` = @incident WHERE `id` = @id', {
		['@id'] = data.id,
		['@title'] = data.title,
		['@incident'] = data.incident
	})
	TriggerClientEvent("mdt:sendNotification", source, "Report changes have been saved.")
end)

RegisterServerEvent("mdt:deleteReport")
AddEventHandler("mdt:deleteReport", function(id)
	exports['ghmattimysql']:execute('DELETE FROM `mdt_reports` WHERE `id` = @id', {
		['@id']  = id
	})
	TriggerClientEvent("mdt:sendNotification", source, "Report has been successfully deleted.")
end)

RegisterServerEvent("mdt:submitNewReport")
AddEventHandler("mdt:submitNewReport", function(data)
	local usource = source
	local author = GetCharacterName(source)
	charges = json.encode(data.charges)
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	exports['ghmattimysql']:execute('INSERT INTO `mdt_reports` (`char_id`, `title`, `incident`, `charges`, `author`, `name`, `date`) VALUES (@id, @title, @incident, @charges, @author, @name, @date)', {
		['@id']  = data.char_id,
		['@title'] = data.title,
		['@incident'] = data.incident,
		['@charges'] = charges,
		['@author'] = author,
		['@name'] = data.name,
		['@date'] = data.date,
	}, function(id)
		--TriggerEvent("mdt:getReportDetailsById", id, usource)
		TriggerClientEvent("mdt:sendNotification", usource, "A new report has been submitted.")
	end)

	for offense, count in pairs(data.charges) do
		exports['ghmattimysql']:execute('SELECT * FROM `player_convictions` WHERE `offense` = @offense AND `char_id` = @id', {
			['@offense'] = offense,
			['@id'] = data.char_id
		}, function(result)
			if result[1] then
				exports['ghmattimysql']:execute('UPDATE `player_convictions` SET `count` = @count WHERE `offense` = @offense AND `char_id` = @id', {
					['@id']  = data.char_id,
					['@offense'] = offense,
					['@count'] = count + 1
				})
			else
				exports['ghmattimysql']:execute('INSERT INTO `player_convictions` (`char_id`, `offense`, `count`) VALUES (@id, @offense, @count)', {
					['@id']  = data.char_id,
					['@offense'] = offense,
					['@count'] = count
				})
			end
		end)
	end
end)

RegisterServerEvent("mdt:performReportSearch")
AddEventHandler("mdt:performReportSearch", function(query)
	local usource = source
	local matches = {}
	exports['ghmattimysql']:execute("SELECT * FROM `mdt_reports` WHERE `id` LIKE @query OR LOWER(`title`) LIKE @query OR LOWER(`name`) LIKE @query OR LOWER(`author`) LIKE @query or LOWER(`charges`) LIKE @query", {
		['@query'] = string.lower('%'..query..'%') -- % wildcard, needed to search for all alike results
	}, function(result)

		for index, data in ipairs(result) do
			data.charges = json.decode(data.charges)
			table.insert(matches, data)
		end

		TriggerClientEvent("mdt:returnReportSearchResults", usource, matches)
	end)
end)

RegisterNetEvent("mdt:performVehicleSearch")
AddEventHandler("mdt:performVehicleSearch", function(query)
	local src = source
	local matches = {}
	exports['ghmattimysql']:execute("SELECT * FROM `player_vehicles` WHERE LOWER(`plate`) LIKE @query", {
		['@query'] = string.lower('%'..query..'%') -- % wildcard, needed to search for all alike results
	}, function(result)

		for index, data in ipairs(result) do
			local data_decoded = json.decode(data.mods)
			data.model = data.vehicle
			if data_decoded.color1 then
				data.color = colors[tostring(data_decoded.color1)]
				if colors[tostring(data_decoded.color2)] then
					data.color = colors[tostring(data_decoded.color2)] .. " on " .. colors[tostring(data_decoded.color1)]
				end
			end
			table.insert(matches, data)
		end

		TriggerClientEvent("mdt:returnVehicleSearchResults", src, matches)
	end)
end)

RegisterServerEvent("mdt:performVehicleSearchInFront")
AddEventHandler("mdt:performVehicleSearchInFront", function(query)
	local usource = source
	local xPlayer = QBCore.Functions.GetPlayer(usource)
    if xPlayer.job.name == 'police' then
    	exports['ghmattimysql']:execute("SELECT * FROM (SELECT * FROM `mdt_reports` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(reports)
    		for r = 1, #reports do
    			reports[r].charges = json.decode(reports[r].charges)
    		end
    		exports['ghmattimysql']:execute("SELECT * FROM (SELECT * FROM `mdt_warrants` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(warrants)
    			for w = 1, #warrants do
    				warrants[w].charges = json.decode(warrants[w].charges)
    			end
    			exports['ghmattimysql']:execute("SELECT * FROM `player_vehicles` WHERE `plate` = @query", {
					['@query'] = query
				}, function(result)
					local officer = GetCharacterName(usource)
    				TriggerClientEvent('mdt:toggleVisibilty', usource, reports, warrants, officer, xPlayer.job.name)
					TriggerClientEvent("mdt:returnVehicleSearchInFront", usource, result, query)
				end)
    		end)
    	end)
	end
end)

RegisterNetEvent("mdt:getVehicle")
AddEventHandler("mdt:getVehicle", function(vehicle)
	local src = source
	exports['ghmattimysql']:execute("SELECT * FROM `players` WHERE `citizenid` = @query", {
		['@query'] = vehicle.citizenid
	}, function(result)
		if result[1] then
			local charinfo = json.decode(tostring(result[1].charinfo))
			local first = charinfo.firstname
			local last = charinfo.lastname

			vehicle.owner = first .. ' ' .. last
			vehicle.owner_id = result[1].citizenid
		end

		vehicle.type = types[vehicle.type]
		TriggerClientEvent("mdt:returnVehicleDetails", src, vehicle)
	end)
end)

RegisterServerEvent("mdt:getWarrants")
AddEventHandler("mdt:getWarrants", function()
	local usource = source
	exports['ghmattimysql']:execute("SELECT * FROM `mdt_warrants`", {}, function(warrants)
		for i = 1, #warrants do
			warrants[i].expire_time = ""
			warrants[i].charges = json.decode(warrants[i].charges)
		end
		TriggerClientEvent("mdt:returnWarrants", usource, warrants)
	end)
end)

RegisterServerEvent("mdt:submitNewWarrant")
AddEventHandler("mdt:submitNewWarrant", function(data)
	local usource = source
	data.charges = json.encode(data.charges)
	data.author = GetCharacterName(source)
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	exports['ghmattimysql']:execute('INSERT INTO `mdt_warrants` (`name`, `char_id`, `report_id`, `report_title`, `charges`, `date`, `expire`, `notes`, `author`) VALUES (@name, @char_id, @report_id, @report_title, @charges, @date, @expire, @notes, @author)', {
		['@name']  = data.name,
		['@char_id'] = data.char_id,
		['@report_id'] = data.report_id,
		['@report_title'] = data.report_title,
		['@charges'] = data.charges,
		['@date'] = data.date,
		['@expire'] = data.expire,
		['@notes'] = data.notes,
		['@author'] = data.author
	}, function()
		TriggerClientEvent("mdt:completedWarrantAction", usource)
		TriggerClientEvent("mdt:sendNotification", usource, "A new warrant has been created.")
	end)
end)

RegisterServerEvent("mdt:deleteWarrant")
AddEventHandler("mdt:deleteWarrant", function(id)
	local usource = source
	exports['ghmattimysql']:execute('DELETE FROM `mdt_warrants` WHERE `id` = @id', {
		['@id']  = id
	}, function()
		TriggerClientEvent("mdt:completedWarrantAction", usource)
	end)
	TriggerClientEvent("mdt:sendNotification", usource, "Warrant has been successfully deleted.")
end)

RegisterServerEvent("mdt:getReportDetailsById")
AddEventHandler("mdt:getReportDetailsById", function(query, _source)
	print(query)
	if _source then source = _source end
	local usource = source
	exports['ghmattimysql']:execute("SELECT * FROM `mdt_reports` WHERE `id` = @query", {
		['@query'] = query
	}, function(result)
		if result and result[1] then
			result[1].charges = json.decode(result[1].charges)
			TriggerClientEvent("mdt:returnReportDetails", usource, result[1])
		else
			TriggerClientEvent("mdt:closeModal", usource)
			TriggerClientEvent("mdt:sendNotification", usource, "This report cannot be found.")
		end
	end)
end)

RegisterServerEvent("mdt:newCall")
AddEventHandler("mdt:newCall", function(details, caller, coords, sendNotification)
	call_index = call_index + 1
	local xPlayers = QBCore.Functions.GetPlayers()
	for i= 1, #xPlayers do
		local source = xPlayers[i]
		local xPlayer = QBCore.Functions.GetPlayer(source)
		if xPlayer.PlayerData.job.name == 'police' then
			TriggerClientEvent("mdt:newCall", source, details, caller, coords, call_index)
			if sendNotification ~= false then
				TriggerClientEvent("InteractSound_CL:PlayOnOne", source, 'demo', 0.0)
				TriggerClientEvent('QBCore:Notify', source, 'You Have Received A New Call')
			end
		end
	end
end)

RegisterServerEvent("mdt:attachToCall")
AddEventHandler("mdt:attachToCall", function(index)
	local usource = source
	local charname = GetCharacterName(usource)
	local xPlayers = QBCore.Functions.GetPlayers()
	for i= 1, #xPlayers do
		local source = xPlayers[i]
		local xPlayer = QBCore.Functions.GetPlayer(source)
		if xPlayer.PlayerData.job.name == 'police' then
			TriggerClientEvent("mdt:newCallAttach", source, index, charname)
		end
	end
	TriggerClientEvent("mdt:sendNotification", usource, "You have attached to this call.")
end)

RegisterServerEvent("mdt:detachFromCall")
AddEventHandler("mdt:detachFromCall", function(index)
	local usource = source
	local charname = GetCharacterName(usource)
	local xPlayers = QBCore.Functions.GetPlayers()
	for i= 1, #xPlayers do
		local source = xPlayers[i]
		local xPlayer = QBCore.Functions.GetPlayer(source)
		if xPlayer.PlayerData.job.name == 'police' then
			TriggerClientEvent("mdt:newCallDetach", source, index, charname)
		end
	end
	TriggerClientEvent("mdt:sendNotification", usource, "You have detached from this call.")
end)

RegisterServerEvent("mdt:editCall")
AddEventHandler("mdt:editCall", function(index, details)
	local usource = source
	local xPlayers = QBCore.Functions.GetPlayers()
	for i= 1, #xPlayers do
		local source = xPlayers[i]
		local xPlayer = QBCore.Functions.GetPlayer(source)
		if xPlayer.PlayerData.job.name == 'police' then
			TriggerClientEvent("mdt:editCall", source, index, details)
		end
	end
	TriggerClientEvent("mdt:sendNotification", usource, "You have edited this call.")
end)

RegisterServerEvent("mdt:deleteCall")
AddEventHandler("mdt:deleteCall", function(index)
	local usource = source
	local xPlayers = QBCore.Functions.GetPlayers()
	for i= 1, #xPlayers do
		local source = xPlayers[i]
		local xPlayer = QBCore.Functions.GetPlayer(source)
		if xPlayer.PlayerData.job.name == 'police' then
			TriggerClientEvent("mdt:deleteCall", source, index)
		end
	end
	TriggerClientEvent("mdt:sendNotification", usource, "You have deleted this call.")
end)

RegisterServerEvent("mdt:saveVehicleChanges")
AddEventHandler("mdt:saveVehicleChanges", function(data)
	if data.stolen then data.stolen = 1 else data.stolen = 0 end
	local usource = source
	exports['ghmattimysql']:execute('SELECT * FROM `vehicle_mdt` WHERE `plate` = @plate', {
		['@plate'] = data.plate
	}, function(result)
		if result[1] then
			exports['ghmattimysql']:execute('UPDATE `vehicle_mdt` SET `stolen` = @stolen, `notes` = @notes WHERE `plate` = @plate', {
				['@plate'] = data.plate,
				['@stolen'] = data.stolen,
				['@notes'] = data.notes
			})
		else
			exports['ghmattimysql']:execute('INSERT INTO `vehicle_mdt` (`plate`, `stolen`, `notes`) VALUES (@plate, @stolen, @notes)', {
				['@plate'] = data.plate,
				['@stolen'] = data.stolen,
				['@notes'] = data.notes
			})
		end
		
		TriggerClientEvent("mdt:sendNotification", usource, "Vehicle changes have been saved.")
	end)
end)

function GetLicenses(identifier, cb)
	local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
	local licenses = player.PlayerData.metadata['licences']
	cb(licenses)
end

function GetCharacterName(source)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if xPlayer then
		return xPlayer.PlayerData.name
	end
end

function tprint (tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2 
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "   
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end
