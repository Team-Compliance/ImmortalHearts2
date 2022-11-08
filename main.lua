ComplianceImmortal = RegisterMod("Compliance Immortal Hearts", 1)
local mod = ComplianceImmortal
local game = Game()
local json = require("json") 

HeartSubType.HEART_IMMORTAL = 902

mod.DataTable = {}
mod.ImmortalSplash = Sprite()
mod.ImmortalSplash:Load("gfx/ui/ui_remix_hearts.anm2",true)

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
			if not mod.DataTable[index] then
				mod.DataTable[index] = {}
			end
			if not mod.DataTable[index].lastEternalHearts or not mod.DataTable[index].lastMaxHearts then
				mod.DataTable[index].lastEternalHearts = 0
				mod.DataTable[index].lastMaxHearts = 0
			end
			if player:GetPlayerType() == PlayerType.PLAYER_BETHANY and not mod.DataTable[index].ImmortalCharge then
				mod.DataTable[index].ImmortalCharge = 0
			end
			return mod.DataTable[index]
		elseif entity.Type == EntityType.ENTITY_FAMILIAR then
			local index = entity:ToFamiliar().InitSeed
			if not mod.DataTable[index] then
				mod.DataTable[index] = {}
			end
			return mod.DataTable[index]
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
		save.PlayerData = mod.DataTable
	end
	save.SpriteStyle = mod.optionNum
	save.AppearanceChance = mod.optionChance
	save.ActOfContritionChance = mod.optionContrition
	save.showAchievement = true
	mod:SaveData(json.encode(save))
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.OnSave)

function mod:OnLoad(isLoading)
	mod.DataTable = {}
	if mod:HasData() then
		local save = json.decode(mod:LoadData())
		if isLoading then
			mod.DataTable = save.PlayerData				
		end
		mod.optionNum = save.SpriteStyle and save.SpriteStyle or 1
		mod.optionChance = save.AppearanceChance and save.AppearanceChance or 20
		mod.optionContrition = save.ActOfContritionChance and save.ActOfContritionChance or 1
		
		if EID then
			if mod.optionContrition == 1 then -- Has to be here because of save data
				EID:addCollectible(601, "↑ {{Tears}} +0.7 Tears up#{{ImmortalHeart}} +1 Immortal Heart#{{AngelChance}} Allows Angel Rooms to spawn even if you've taken a Devil deal#Taking Red Heart damage doesn't reduce Devil/Angel Room chance as much", "Act of Contrition", "en_us")
				EID:addCollectible(601, "↑ {{Tears}} Lágrimas +0.7#{{ImmortalHeart}} +1 corazón inmortal#{{AngelChance}} Permite que aparezcan salas del ángel aunque hayas hecho pactos con el diablo antes", "Acto de contrición", "spa")
				EID:addCollectible(601, "↑ {{Tears}} +0.7 к скорострельности#{{ImmortalHeart}} +1 бессмертное сердце#{{AngelChance}} Позволяет Ангельским комнатам появляться даже в том случае, если ранее была заключена сделка с Дьяволом#Получение урона красными сердцами не так сильно снижает шанс сделки", "Покаяние", "ru")
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.OnLoad)

-----------------------------------
--Helper Functions (thanks piber)--
-----------------------------------

function mod:GetPlayers(functionCheck, ...)

	local args = {...}
	local players = {}
	
	local game = Game()
	
	for i=1, game:GetNumPlayers() do
	
		local player = Isaac.GetPlayer(i-1)
		
		local argsPassed = true
		
		if type(functionCheck) == "function" then
		
			for j=1, #args do
			
				if args[j] == "player" then
					args[j] = player
				elseif args[j] == "currentPlayer" then
					args[j] = i
				end
				
			end
			
			if not functionCheck(table.unpack(args)) then
			
				argsPassed = false
				
			end
			
		end
		
		if argsPassed then
			players[#players+1] = player
		end
		
	end
	
	return players
	
end

function mod:GetPlayerFromTear(tear)
	for i=1, 3 do
		local check = nil
		if i == 1 then
			check = tear.Parent
		elseif i == 2 then
			check = mod:GetSpawner(tear)
		elseif i == 3 then
			check = tear.SpawnerEntity
		end
		if check then
			if check.Type == EntityType.ENTITY_PLAYER then
				return mod:GetPtrHashEntity(check):ToPlayer()
			elseif check.Type == EntityType.ENTITY_FAMILIAR and check.Variant == FamiliarVariant.INCUBUS then
				local data = mod:GetData(tear)
				data.IsIncubusTear = true
				return check:ToFamiliar().Player:ToPlayer()
			end
		end
	end
	return nil
end

function mod:GetPtrHashEntity(entity)
	if entity then
		if entity.Entity then
			entity = entity.Entity
		end
		for _, matchEntity in pairs(Isaac.FindByType(entity.Type, entity.Variant, entity.SubType, false, false)) do
			if GetPtrHash(entity) == GetPtrHash(matchEntity) then
				return matchEntity
			end
		end
	end
	return nil
end

function mod:GetData(entity)
	if entity and entity.GetData then	
		local data = entity:GetData()
		if not data.ImmortalHeart then
			data.ImmortalHeart = {}
		end
		return data.ImmortalHeart
	end
	return nil
end

function mod:DidPlayerCollectibleCountJustChange(player)
	local data = mod:GetEntityData(player)
	if data.didCollectibleCountJustChange then
		return true
	end
	return false
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	local data = mod:GetEntityData(player)
	local currentCollectibleCount = player:GetCollectibleCount()
	if not data.lastCollectibleCount then
		data.lastCollectibleCount = currentCollectibleCount
	end
	data.didCollectibleCountJustChange = false
	if data.lastCollectibleCount ~= currentCollectibleCount then
		data.didCollectibleCountJustChange = true
	end
	data.lastCollectibleCount = currentCollectibleCount
end)
function mod:Contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

function mod:GetRandomNumber(numMin, numMax, rng)
	if not numMax then
		numMax = numMin
		numMin = nil
	end
	
	rng = rng or RNG()

	if type(rng) == "number" then
		local seed = rng
		rng = RNG()
		rng:SetSeed(seed, 1)
	end
	
	if numMin and numMax then
		return rng:Next() % (numMax - numMin + 1) + numMin
	elseif numMax then
		return rng:Next() % numMin
	end
	return rng:Next()
end

OnRenderCounter = 0
IsEvenRender = true
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	OnRenderCounter = OnRenderCounter + 1
	
	IsEvenRender = false
	if Isaac.GetFrameCount()%2 == 0 then
		IsEvenRender = true
	end
end)

--ripairs stuff from revel
function ripairs_it(t,i)
	i=i-1
	local v=t[i]
	if v==nil then return v end
	return i,v
end
function ripairs(t)
	return ripairs_it, t, #t+1
end
