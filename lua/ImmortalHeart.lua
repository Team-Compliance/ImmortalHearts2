local mod = ComplianceImmortal
local game = Game()
local sfx = SFXManager()
local immortalBreakSfx = Isaac.GetSoundIdByName("ImmortalHeartBreak")
local immortalSfx = Isaac.GetSoundIdByName("immortal")
local screenHelper = require("lua.screenhelper")
-- API functions --

CustomHealthAPI.Library.RegisterSoulHealth(
    "HEART_IMMORTAL",
    {
        AnimationFilename = "gfx/ui/ui_remix_hearts.anm2",
        AnimationName = {"ImmortalHeartHalf", "ImmortalHeartFull"},
        SortOrder = 150,
        AddPriority = 175,
        HealFlashRO = 245/255, 
        HealFlashGO = 240/255,
        HealFlashBO = 66/255,
        MaxHP = 2,
        PrioritizeHealing = true,
        PickupEntities = {
            {ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = HeartSubType.HEART_IMMORTAL}
        },
        SumptoriumSubType = 20,  -- immortal heart clot
        SumptoriumSplatColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
        SumptoriumTrailColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
        SumptoriumCollectSoundSettings = {
            ID = SoundEffect.SOUND_MEAT_IMPACTS,
            Volume = 1.0,
            FrameDelay = 0,
            Loop = false,
            Pitch = 1.0,
            Pan = 0
        }
    }
)

CustomHealthAPI.Library.AddCallback("ComplianceImmortalHeart", CustomHealthAPI.Enums.Callbacks.PRE_HEALTH_DAMAGED, 0, function(player, flags, key, hpDamaged, otherKey, otherHPDamaged, amountToRemove)
	if otherKey == "HEART_IMMORTAL" then
		return 1
	end
end)

CustomHealthAPI.Library.AddCallback("ComplianceImmortalHeart", CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED, 0, function(player, flags, key, hpDamaged, wasDepleted, wasLastDamaged)
	print(key)
	if key == "HEART_IMMORTAL" then
		if wasDepleted then
			sfx:Play(immortalBreakSfx,1,0)
			local shatterSPR = Isaac.Spawn(EntityType.ENTITY_EFFECT, 904, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect():GetSprite()
			shatterSPR.PlaybackSpeed = 2
		else
			local cd = 20
			player:ResetDamageCooldown()
			player:SetMinDamageCooldown(cd)
			if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_ESAU
			or player:GetPlayerType() == PlayerType.PLAYER_JACOB then
				player:GetOtherTwin():ResetDamageCooldown()
				player:GetOtherTwin():SetMinDamageCooldown(cd)		
			end
		end
	end
end)

function ComplianceImmortal.AddImmortalHearts(player, amount)
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
		local data = mod:GetEntityData(player)
		data.ImmortalCharge = data.ImmortalCharge + math.ceil(amount/2)
	else
		if amount % 2 == 0 then
			if player:GetSoulHearts() % 2 ~= 0 then
				-- if you already have a half heart, a new full immortal heart always replaces it instead of adding another heart
				player:AddSoulHearts(-1)
			end
		end
		CustomHealthAPI.Library.AddHealth(player,"HEART_IMMORTAL", amount)
	end
end

function ComplianceImmortal.GetImmortalHearts(player)
	return CustomHealthAPI.Library.GetHPOfKey(player,"HEART_IMMORTAL")
end

function ComplianceImmortal.HealImmortalHeart(player) -- returns true if successful
	if ComplianceImmortal.GetImmortalHearts(player) > 0 and ComplianceImmortal.GetImmortalHearts(player) % 2 ~= 0 then
		ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 903, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
		ImmortalEffect:GetSprite().Offset = Vector(0, -22)
		SFXManager():Play(immortalSfx,1,0)
		ComplianceImmortal.AddImmortalHearts(player, 1)
		return true
	end
	return false
end

function mod:ImmortalHeartCollision(entity, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local player = collider:ToPlayer()
		if player.Parent ~= nil then return entity:IsShopItem() end
		if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
			player = player:GetMainTwin()
		end
		if ComplianceImmortal.GetImmortalHearts(player) < player:GetHeartLimit() - player:GetMaxHearts() then
			if entity.SubType == HeartSubType.HEART_IMMORTAL then
				if player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B then
					ComplianceImmortal.AddImmortalHearts(player, 2)
				end
				entity.Velocity = Vector.Zero
				entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				entity:GetSprite():Play("Collect", true)
				entity:Die()
				sfx:Play(immortalSfx,1,0)
				return true
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.ImmortalHeartCollision, PickupVariant.PICKUP_HEART)

function mod:ActOfImmortal(player)
	if player.Parent ~= nil then return end
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) then return end
	if mod.optionContrition ~= 1 then return end
	local data = mod:GetEntityData(player)
	if not data.lastEternalHearts or not data.lastMaxHearts then
		data.lastEternalHearts = 0
		data.lastMaxHearts = 0
	end
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		player = player:GetMainTwin()
	end
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		player = player:GetSubPlayer()
	end
	
	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) == data.ContritionCount then
		data.lastEternalHearts = player:GetEternalHearts()
		data.lastMaxHearts = player:GetMaxHearts()
	end
	data.ContritionCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION)
	
	if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then return end
	if player:GetEternalHearts() > data.lastEternalHearts then
		player:AddEternalHearts(-1)
		
		ComplianceImmortal.AddImmortalHearts(player, 2)
	elseif player:GetMaxHearts() > data.lastMaxHearts then
		player:AddMaxHearts(-2) -- still plays the eternal heart animation but its the best we can do right now
		
		ComplianceImmortal.AddImmortalHearts(player, 2)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.ActOfImmortal)

function mod:ImmortalHeal()
	for i = 0, game:GetNumPlayers() - 1 do
		ComplianceImmortal.HealImmortalHeart(Isaac.GetPlayer(i))
	end
	for _, entity in pairs(Isaac.FindByType(3, 206)) do
		local data = mod:GetEntityData(entity)
		if data.IsImmortal == 1 and entity.HitPoints < entity.MaxHitPoints + 3 then
			entity.HitPoints = entity.HitPoints + 1
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.ImmortalHeal)

function mod:PreEternalSpawn(heart)
	local rng = RNG()
	if heart.SubType == HeartSubType.HEART_ETERNAL and heart:GetSprite():IsPlaying("Appear") then
		rng:SetSeed(heart.InitSeed, 35)
		if rng:RandomFloat() >= (1 - mod.optionChance / 100) then
			heart:Morph(heart.Type,heart.Variant,HeartSubType.HEART_IMMORTAL,true,true)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.PreEternalSpawn, PickupVariant.PICKUP_HEART)

function mod:DefaultWispInit(wisp)
	local player = wisp.Player
	local data = mod:GetEntityData(player)
	local wispData = mod:GetEntityData(wisp)
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
		if data.ImmortalCharge > 0 then
			wisp:SetColor(Color(232, 240, 255, 0.02, 0, 0, 0), -1, 1, false, false)
			data.ImmortalCharge = data.ImmortalCharge - 1
			wispData.IsImmortal = 1
		else
			wispData.IsImmortal = 0
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.DefaultWispInit, FamiliarVariant.WISP)

function mod:ImmortalWispUpdate(wisp)
	local wispData = mod:GetEntityData(wisp)
	local wispTempData = mod:GetData(wisp)
	if not wispTempData.IsImmortal then
		wispTempData.IsImmortal = 0
	end
	if wispData.IsImmortal and wispTempData.IsImmortal ~= wispData.IsImmortal then
		if wispData.IsImmortal > 0 then
			wisp:SetColor(Color(232, 240, 255, 0.02, 0, 0, 0), -1, 1, false, false)
		end
		wispTempData.IsImmortal = wispData.IsImmortal
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.ImmortalWispUpdate, FamiliarVariant.WISP)

function mod:SpriteChange(entity)
	if entity.SubType == HeartSubType.HEART_IMMORTAL then
		local sprite = entity:GetSprite()
		local spritename = "gfx/items/pick ups/pickup_001_remix_heart"
		if mod.optionNum == 2 then
			spritename = spritename.."_aladar"
		end
		if mod.optionNum == 3 then
			spritename = spritename.."_peas"
		end
		if mod.optionNum == 6 then
			spritename = spritename.."_flashy"
		end
		if mod.optionNum == 7 then
			spritename = spritename.."_bettericons"
		end
		if mod.optionNum == 9 then
			spritename = spritename.."_duxi"
		end
		if mod.optionNum == 10 then
			spritename = spritename.."_sussy" 
		end
		spritename = spritename..".png"
		for i = 0,2 do
			sprite:ReplaceSpritesheet(i,spritename)
		end
		sprite:LoadGraphics()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, mod.SpriteChange, PickupVariant.PICKUP_HEART)
