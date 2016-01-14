--[[
Name: Broker kDurability
Description: Shows how damaged your equipement is

Copyright 2016 Mateusz Kasprzak

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local eqDurability
local averageDurabilityPercentage = 0

-- Zwraca w procentach wytrzymałość przedmiotu oraz czy jest właśnie założony
local function GetInventoryItemDurabilityPercentage(slot)
	local current, max = GetInventoryItemDurability(slot)
	if (current == nil) then -- that means, that item is not eqipped	
		return nil
	end
	
	return math.floor(current / max * 100)
end

-- Aktualizuje eqDurability na podanym slocie i zwiększa odpowiednio zmienne średniej
local function UpdateEquipementData(slotName, slot, currentSum, equippedItemsNumber)
	perc = GetInventoryItemDurabilityPercentage(slot)
	if (perc ~= nil) then
		eqDurability[slotName] = perc
		equippedItemsNumber = equippedItemsNumber + 1
		currentSum = currentSum + perc
	end
	
	return currentSum, equippedItemsNumber
end

-- Aktualizuje cały ekwipunek
local function equipementUpdate()
	eqDurability = {}
	sum, itemsNumber = 0, 0	
	
	sum, itemsNumber = UpdateEquipementData("Head", 1, sum, itemsNumber)
	sum, itemsNumber = UpdateEquipementData("Shoulder", 3, sum, itemsNumber)
	sum, itemsNumber = UpdateEquipementData("Chest", 5, sum, itemsNumber)
	sum, itemsNumber = UpdateEquipementData("Waist", 6, sum, itemsNumber)
	sum, itemsNumber = UpdateEquipementData("Legs", 7, sum, itemsNumber)
	sum, itemsNumber = UpdateEquipementData("Feet", 8, sum, itemsNumber)
	sum, itemsNumber = UpdateEquipementData("Wrist", 9, sum, itemsNumber)
	sum, itemsNumber = UpdateEquipementData("Hand", 10, sum, itemsNumber)
	sum, itemsNumber = UpdateEquipementData("Main Hand", 16, sum, itemsNumber)
	sum, itemsNumber = UpdateEquipementData("Off Hand", 17, sum, itemsNumber)
	sum, itemsNumber = UpdateEquipementData("Ranged", 18, sum, itemsNumber)
	
	if (itemsNumber == 0) then
		averageDurabilityPercentage = nil
	else
		averageDurabilityPercentage = math.floor(sum / itemsNumber)
	end	
end

-- Zwraca odpowiednio pokolorowany procent
local function colorPercentage(perc)	
	if (perc >= 90) then
		color = "|cff00ff00"
	elseif (perc >= 80) then
		color = "|cffaaff00"
	elseif (perc >= 70) then
		color = "|cffbbff00"
	elseif (perc >= 60) then
		color = "|cffccee00"
	elseif (perc >= 50) then
		color = "|cffdddd00"
	elseif (perc >= 40) then
		color = "|cffeecc00"
	elseif (perc >= 30) then
		color = "|cffffbb00"
	elseif (perc >= 20) then
		color = "|cffff9900"
	elseif (perc >= 10) then
		color = "|cffff3300"
	else
		color = "|cffff0000"
	end		
		
	return color..perc.."|r"
end

-- Tworzy Broker
local kBroker = ldb:GetDataObjectByName("kDurability") or ldb:NewDataObject("kDurability", {
	type = "data source", icon = [[Interface\minimap\tracking\repair]], text = "No armor",
	OnClick = function(self, button)
		ToggleCharacter("PaperDollFrame")
	end,
	OnTooltipShow = function(tip)
		tip:AddLine("Durability")
		for key, value in pairs(eqDurability) do
			tip:AddDoubleLine(key, colorPercentage(value)..'%', 1, 1, 1, 1, 1, 1)
		end
		tip:AddLine(" ")
		tip:AddLine("|cff69ccf0Click|cffffd200 to toggle Character Pane|r")
	end,
})

-- Aktualizacja Danych
local function OnEvent()
	equipementUpdate()
	if (averageDurabilityPercentage == nil) then
		kBroker.text = "No armor"
	elseif (averageDurabilityPercentage >= 90) then
		kBroker.text = averageDurabilityPercentage..'%'
	else
		kBroker.text = colorPercentage(averageDurabilityPercentage)..'%'
	end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", OnEvent)
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_INVENTORY_DURABILITY")