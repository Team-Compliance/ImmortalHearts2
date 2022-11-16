ComplianceImmortal = RegisterMod("Compliance Immortal Hearts", 1)
local mod = ComplianceImmortal
local game = Game()
local json = require("json") 

HeartSubType.HEART_IMMORTAL = 902

mod.savedata = {DataTable = {},CustomHealthAPISave = nil, DSS = {}}

if EID then
	EID:setModIndicatorName("Immortal Heart")
	local iconSprite = Sprite()
	iconSprite:Load("gfx/eid_icon_immortal_hearts.anm2", true)
	EID:addIcon("ImmortalHeart", "Immortal Heart Icon", 0, 10, 9, 0, 1, iconSprite)
	EID:setModIndicatorIcon("ImmortalHeart")
end

function mod:GetEntityData(entity)
	if entity then
		if entity.Type == EntityType.ENTITY_PLAYER then
			local player = entity:ToPlayer()
			if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
				player = player:GetOtherTwin()
			end
			local id = 1
			if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
				id = 2
			end
			local index = tostring(player:GetCollectibleRNG(id):GetSeed())
			if not mod.savedata.DataTable[index] then
				mod.savedata.DataTable[index] = {}
			end
			if not mod.savedata.DataTable[index].lastEternalHearts or not mod.savedata.DataTable[index].lastMaxHearts then
				mod.savedata.DataTable[index].lastEternalHearts = 0
				mod.savedata.DataTable[index].lastMaxHearts = 0
			end
			return mod.savedata.DataTable[index]
		elseif entity.Type == EntityType.ENTITY_FAMILIAR then
			local index = entity:ToFamiliar().InitSeed
			if not mod.savedata.DataTable[index] then
				mod.savedata.DataTable[index] = {}
			end
			return mod.savedata.DataTable[index]
		end
	end
	return nil
end

local function loadscripts(list)
	for _,name in pairs(list) do
		include("lua."..name)
	end
end

local scriptList = {
	"customhealthapi.core",
	"ModConfigMenu",
	"ImmortalHeart",
	"ImmortalClot",
	"deadseascrolls",
}

loadscripts(scriptList)

--include("lua/ModConfigMenu.lua")
--include("lua/ImmortalHeart.lua")
--include("lua/ImmortalClot.lua")

if MinimapAPI then
    local frame = 1
    local ImmortalSprite = Sprite()
    ImmortalSprite:Load("gfx/ui/immortalheart_icon.anm2", true)
    MinimapAPI:AddIcon("ImmortalIcon", ImmortalSprite, "ImmortalHeart", 0)
	MinimapAPI:AddPickup(HeartSubType.HEART_IMMORTAL, "ImmortalIcon", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_IMMORTAL, MinimapAPI.PickupNotCollected, "hearts", 13000)
end

function mod:OnSave(isSaving)
	local save = {}
	if isSaving then
		save.PlayerData = mod.savedata.DataTable
	end
	save.DSS = mod.savedata.DSS
	save.SpriteStyle = mod.optionNum
	save.AppearanceChance = mod.optionChance
	save.ActOfContrition = mod.optionContrition
	save.showAchievement = true
	mod:SaveData(json.encode(save))
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.OnSave)

function mod:GetLoadData(isLoading)
	if mod:HasData() then
		local save = json.decode(mod:LoadData())
		if isLoading then
			mod.savedata.DataTable = save.PlayerData
		else
			mod.savedata.DataTable = {}
			mod.savedata.CustomHealthAPISave = nil
			mod.savedata.DSS = {}
		end

		mod.savedata.DSS = save.DSS and save.DSS or {}
		mod.optionNum = save.SpriteStyle and save.SpriteStyle or 1
		mod.optionChance = save.AppearanceChance and save.AppearanceChance or 50
		mod.optionContrition = save.ActOfContrition and save.ActOfContrition or 1
	else
		mod.optionNum = 1
		mod.optionChance = 50
		mod.optionContrition = 1
		mod.savedata.DSS = {}
	end
end
function mod:OnLoad(isLoading)
	
	mod:GetLoadData(isLoading)
	if EID then
		if mod.optionContrition == 1 then -- Has to be here because of save data
			EID:addCollectible(601, "↑ {{Tears}} +0.7 Tears up#{{ImmortalHeart}} +1 Immortal Heart#{{AngelChance}} Allows Angel Rooms to spawn even if you've taken a Devil deal#Taking Red Heart damage doesn't reduce Devil/Angel Room chance as much", "Act of Contrition", "en_us")
			EID:addCollectible(601, "↑ {{Tears}} Lágrimas +0.7#{{ImmortalHeart}} +1 corazón inmortal#{{AngelChance}} Permite que aparezcan salas del ángel aunque hayas hecho pactos con el diablo antes", "Acto de contrición", "spa")
			EID:addCollectible(601, "↑ {{Tears}} +0.7 к скорострельности#{{ImmortalHeart}} +1 бессмертное сердце#{{AngelChance}} Позволяет Ангельским комнатам появляться даже в том случае, если ранее была заключена сделка с Дьяволом#Получение урона красными сердцами не так сильно снижает шанс сделки", "Покаяние", "ru")
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.OnLoad)