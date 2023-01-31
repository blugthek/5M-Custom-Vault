---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by BLUGTHEK.
--- DateTime: 8/8/2022 6:56 PM
---

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('blugx:fetchVaultItem', function(source,cb, refresh,jobName)
	local _jobName = jobName
	local xPlayer = ESX.GetPlayerFromId(source)
	local refresh = refresh or false

	local items		= {}
	local weapons	= {}
	local money 	= {}	

	if not refresh and xPlayer == nil then
		cb(false)
		-- return
	end

	
	TriggerEvent('esx_addonaccount:getSharedAccount', _jobName,function(sharedAcc)
		money = sharedAcc.money or 0
	end)

	TriggerEvent('esx_addoninventory:getSharedInventory', _jobName, function(inventory)
		items = inventory.items
	end)

	TriggerEvent('esx_datastore:getSharedDataStore', _jobName, function(store)
		weapons = store.get('weapons') or {}
	end)

	cb({
		blackMoney = 0,
		money		= money,
		items      = items,
		weapons    = weapons,
		tempJob = _jobName
	})

	print(money)
end)

RegisterServerEvent('blugx:getStockManager')
AddEventHandler('blugx:getStockManager',function(type,itemName,count,jobName)
	local _jobName = jobName
	local _source      = source
	local xPlayer      = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	if type == 'item_standard' then

		TriggerEvent('esx_addoninventory:getSharedInventory', _jobName, function(inventory)
			local inventoryItem = inventory.getItem(itemName)
			local sCount = sourceItem.count
			local itemCount = sourceItem.count + count;
			local itemMaximumCount = sourceItem.limit
			if itemMaximumCount == nil then itemMaximumCount = 99999 end
			if itemCount == nil then itemCount = 0 end

			-- is there enough in the society?
			if count > 0 and inventoryItem.count >= count then

				-- can the player carry the said amount of x item?
				if itemCount >= itemMaximumCount then
					if itemCount >= itemMaximumCount and itemMaximumCount ~= 0 then
						local nCount =	math.abs(sCount - itemMaximumCount)
						if nCount == 0 then
							TriggerClientEvent('pNotify:SendNotification',_source,{
								text = _U('ดึงไม่ได้เต็ม',inventoryItem.label),
								type = "alert",
								timeout = 5500,
								layout = "bottomCenter"})
						elseif itemMaximumCount ~= -1 then
							inventory.removeItem(itemName, nCount)
							xPlayer.addInventoryItem(itemName, nCount)
							TriggerClientEvent('pNotify:SendNotification',_source,{
								text = _U('ดึง',inventoryItem.label,nCount),
								type = "success",
								timeout = 8500,
								layout = "bottomCenter"})
						else
							inventory.removeItem(itemName, count)
							xPlayer.addInventoryItem(itemName, count)
							TriggerClientEvent('pNotify:SendNotification',_source,{
								text = "ในตัวคุณมี "..inventoryItem.label.. " ทั้งหมด " ..nCount.. " ชิ้น",
								type = "success",
								timeout = 8500,
								layout = "bottomCenter"})
						end
					else
						inventory.removeItem(itemName, count)
						xPlayer.addInventoryItem(itemName, count)
						TriggerClientEvent('pNotify:SendNotification',_source,{
							text = _U('ดึง',inventoryItem.label,count),
							type = "success",
							timeout = 8500,
							layout = "bottomCenter"})
					end
				else
					inventory.removeItem(itemName, count)
					xPlayer.addInventoryItem(itemName, count)
					TriggerClientEvent("pNotify:SendNotification", _source, {
						text = 'have_withdrawn'.. count.. inventoryItem.label,
						type = "success",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})

					local sendToDiscord = '' .. xPlayer.name .. ' นำ ' .. inventoryItem.label .. ' จำนวน ' .. ESX.Math.GroupDigits(count) .. ' ออกจากคลัง'
					TriggerEvent('azael_dc-serverlogs:sendToDiscord', 'PoliceGetStockItem', sendToDiscord, xPlayer.source, '^3')
				end
			else
				TriggerClientEvent("pNotify:SendNotification", _source, {
					text = '<strong class="red-text">จำนวนที่ไม่ถูกต้อง</strong>',
					type = "success",
					timeout = 3000,
					layout = "bottomCenter",
					queue = "global"
				})
			end
		end)
	elseif type == 'item_weapon' then
		TriggerEvent('esx_datastore:getSharedDataStore', _jobName, function(store)
			local storeWeapons = store.get('weapons') or {}
			local weaponName   = nil
			local ammo         = nil

			for i=1, #storeWeapons, 1 do
				if storeWeapons[i].name == item then
					weaponName = storeWeapons[i].name
					ammo       = storeWeapons[i].ammo

					table.remove(storeWeapons, i)
					break
				end
			end

			store.set('weapons', storeWeapons)
			xPlayer.addWeapon(weaponName, ammo)
		end)
	end
end)

RegisterServerEvent('blugx:putStockManager')
AddEventHandler('blugx:putStockManager',function(type,item,count,jobName)
	local _jobName = jobName
	local _source      = source
	local xPlayer      = ESX.GetPlayerFromId(_source)

	if type == 'item_standard' then

		local playerItem = xPlayer.getInventoryItem(item)
		local playerItemCount = playerItem.count

		if playerItemCount >= count and count > 0 then
			TriggerEvent('esx_addoninventory:getSharedInventory', _jobName, function(inventory)
				xPlayer.removeInventoryItem(item, count)
				inventory.addItem(item, count)
				TriggerClientEvent('pNotify:SendNotification',_source,{
					text = 'ใส่'.. playerItem.label..count,
					type = "success",
					timeout = 5500,
					layout = "bottomCenter"})
			end)
		else
			TriggerClientEvent('pNotify:SendNotification',_source,{
				text = 'ใส่ไม่ได้'..playerItem.label,
				type = "warning",
				timeout = 5500,
				layout = "bottomCenter"})
		end

	elseif type == 'item_weapon' then
		TriggerEvent('esx_datastore:getSharedDataStore', _jobName, function(store)
			local storeWeapons = store.get('weapons') or {}

			table.insert(storeWeapons, {
				name = item,
				ammo = count
			})

			store.set('weapons', storeWeapons)
			xPlayer.removeWeapon(item)
		end)
	end
end)