---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by BLUGTHEK.
--- DateTime: 8/8/2022 6:56 PM
---

local ESX = nil
local gender = -1

Citizen.CreateThread(function()
	while ESX == nil do
		Citizen.Wait(0)
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	while tempDataStorage.CurrentJob == nil do
		ESX.PlayerData = ESX.GetPlayerData()
		tempDataStorage.CurrentJob = ESX.PlayerData.job.name
	end
end)