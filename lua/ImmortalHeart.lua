local mod = ComplianceImmortal
local game = Game()
local sfx = SFXManager()
local immortalBreakSfx = Isaac.GetSoundIdByName("ImmortalHeartBreak")
local immortalSfx = Isaac.GetSoundIdByName("immortal")
-- API functions --

if CustomHealthAPI and CustomHealthAPI.Library and CustomHealthAPI.Library.UnregisterCallbacks then
    CustomHealthAPI.Library.UnregisterCallbacks("ComplianceImmortal")
end

CustomHealthAPI.Library.RegisterSoulHealth(
    "HEART_IMMORTAL",
    {
        AnimationFilename = "gfx/ui/ui_remix_hearts.anm2",
        AnimationName = {"ImmortalHeartHalf", "ImmortalHeartFull"},
        SortOrder = 150,
        AddPriority = 175,
        HealFlashRO = 240/255, 
        HealFlashGO = 240/255,
        HealFlashBO = 240/255,
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

CustomHealthAPI.Library.AddCallback("ComplianceImmortal",CustomHealthAPI.Enums.Callbacks.ON_SAVE,0,function (savedata,isPreGameExit)
    mod.savedata.CustomHealthAPISave = savedata
end)

CustomHealthAPI.Library.AddCallback("ComplianceImmortal", CustomHealthAPI.Enums.Callbacks.ON_LOAD, 0, function()
	return mod.savedata.CustomHealthAPISave
end)

CustomHealthAPI.Library.AddCallback("ComplianceImmortal", CustomHealthAPI.Enums.Callbacks.PRE_HEALTH_DAMAGED, 0, function(player, flags, key, hpDamaged, otherKey, otherHPDamaged, amountToRemove)
	if otherKey == "HEART_IMMORTAL" then
		return 1
	end
end)

CustomHealthAPI.Library.AddCallback("ComplianceImmortal", CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED, 0, function(player, flags, key, hpDamaged, wasDepleted, wasLastDamaged)
	if key == "HEART_IMMORTAL" then
		if wasDepleted then
			sfx:Play(immortalBreakSfx,1,0)
			local shatterSPR = Isaac.Spawn(EntityType.ENTITY_EFFECT, 904, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect():GetSprite()
			shatterSPR.PlaybackSpeed = 2
		else
			player:GetData().ImmortalHeartDamage = true
		end
	end
end)

function ComplianceImmortal.GetImmortalHeartsNum(player)
	return CustomHealthAPI.Library.GetHPOfKey(player, "HEART_IMMORTAL")
end

function ComplianceImmortal.GetImmortalHearts(player)
	return ComplianceImmortal.GetImmortalHeartsNum(player)
end

function ComplianceImmortal.AddImmortalHearts(player, hp)
	CustomHealthAPI.Library.AddHealth(player, "HEART_IMMORTAL", hp)
end

function ComplianceImmortal.CanPickImmortalHearts(player)
	return CustomHealthAPI.Library.CanPickKey(player, "HEART_IMMORTAL")
end

function ComplianceImmortal.HealImmortalHeart(player) -- returns true if successful
	if ComplianceImmortal.GetImmortalHeartsNum(player) > 0 and ComplianceImmortal.GetImmortalHeartsNum(player) % 2 ~= 0 then
		ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 903, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
		ImmortalEffect:GetSprite().Offset = Vector(0, -22)
		sfx:Play(immortalSfx,1,0)
		ComplianceImmortal.AddImmortalHearts(player, 1)
		return true
	end
	return false
end

function mod:ImmortalHeartCollision(pickup, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local player = collider:ToPlayer()
		if player.Parent ~= nil then return pickup:IsShopItem() end
		if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
			player = player:GetMainTwin()
		end
		if pickup.SubType == HeartSubType.HEART_IMMORTAL then
			if pickup:IsShopItem() and (pickup.Price > 0 and player:GetNumCoins() < pickup.Price or not player:IsExtraAnimationFinished()) then
				return true
			end
			if ComplianceImmortal.CanPickImmortalHearts(player) then
				if not pickup:IsShopItem() then
					pickup:GetSprite():Play("Collect")
					pickup:Die()
				else
					if pickup.Price >= 0 or pickup.Price == PickupPrice.PRICE_FREE or pickup.Price == PickupPrice.PRICE_SPIKES then
						if pickup.Price == PickupPrice.PRICE_SPIKES then
							local tookDamage = player:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
							if not tookDamage then
								return pickup:IsShopItem()
							end
						end
						if pickup.Price >= 0 then
							player:AddCoins(-pickup.Price)
						end
						CustomHealthAPI.Library.TriggerRestock(pickup)
						CustomHealthAPI.Helper.TryRemoveStoreCredit(player)
						pickup:Remove()
						player:AnimatePickup(pickup:GetSprite(), true)
					end
				end
				if player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B then
					ComplianceImmortal.AddImmortalHearts(player, 2)
				end
				sfx:Play(immortalSfx,1,0)
				if pickup.OptionsPickupIndex ~= 0 then
					local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
					for _, entity in ipairs(pickups) do
						if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and
						(entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
						then
							Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
							entity:Remove()
						end
					end
				end
				return true
			else
				if pickup:IsShopItem() and pickup.Price == PickupPrice.PRICE_SPIKES and player:GetDamageCooldown() <= 0 then
					player:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
				end
				return pickup:IsShopItem()
			end
		else
		
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

function mod:ImmortalHeartIFrames(player)
	if player:GetData().ImmortalHeartDamage then
		local cd = 20
		player:ResetDamageCooldown()
		player:SetMinDamageCooldown(cd)
		if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_ESAU
		or player:GetPlayerType() == PlayerType.PLAYER_JACOB then
			player:GetOtherTwin():ResetDamageCooldown()
			player:GetOtherTwin():SetMinDamageCooldown(cd)
		end
		player:GetData().ImmortalHeartDamage = nil
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.ImmortalHeartIFrames)

function mod:ImmortalHeal()
	for i = 0, game:GetNumPlayers() - 1 do
		ComplianceImmortal.HealImmortalHeart(Isaac.GetPlayer(i))
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.ImmortalHeal)

local grng = RNG()
function mod:PreEternalSpawn(id, var, subtype, pos, vel, spawner, seed)
	if id == EntityType.ENTITY_PICKUP and var == PickupVariant.PICKUP_HEART and subtype == HeartSubType.HEART_ETERNAL and not mod.savedata.Pickups[tostring(seed)] then
		mod.savedata.Pickups[tostring(seed)] = true
		grng:SetSeed(seed, 0)
		if grng:RandomFloat() >= (1 - mod.optionChance / 100) then
			return {id, var, HeartSubType.HEART_IMMORTAL, seed }
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, mod.PreEternalSpawn)

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
