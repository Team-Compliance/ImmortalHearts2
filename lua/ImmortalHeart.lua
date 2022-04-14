local mod = ComplianceImmortal
local game = Game()
local sfx = SFXManager()
local immortalBreakSfx = Isaac.GetSoundIdByName("ImmortalHeartBreak")
local immortalSfx = Isaac.GetSoundIdByName("immortal")
local screenHelper = require("lua.screenhelper")

-- API functions --

function ComplianceImmortal.AddImmortalHearts(player, amount, data)
	data = data and data or mod:GetData(player)
	if amount % 2 == 0 then
		if player:GetSoulHearts() % 2 ~= 0 then
			amount = amount - 1 -- if you already have a half heart, a new full immortal heart always replaces it instead of adding another heart
		end
	end
	
	if player:CanPickBlackHearts() or amount < 0 then
		player:AddBlackHearts(amount)
	end
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
		data.ImmortalCharge = data.ImmortalCharge + math.ceil(amount/2)
	else
		data.ComplianceImmortalHeart = data.ComplianceImmortalHeart + amount
	end
end

function ComplianceImmortal.GetImmortalHearts(player,data)
	data = data and data or mod:GetData(player)
	return data.ComplianceImmortalHeart
end

function ComplianceImmortal.HealImmortalHeart(player) -- returns true if successful
	local data = mod:GetData(player)
	if ComplianceImmortal.GetImmortalHearts(player) > 0 and ComplianceImmortal.GetImmortalHearts(player) % 2 ~= 0 then
		ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 903, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
		ImmortalEffect:GetSprite().Offset = Vector(0, -22)
		SFXManager():Play(immortalSfx,1,0)
		ComplianceImmortal.AddImmortalHearts(player, 1, data)
		return true
	end
	return false
end

---

function mod:initData(player)
	local data = mod:GetData(player)
	if data.ComplianceImmortalHeart == nil then
		data.ComplianceImmortalHeart = 0
	end
    if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
    	data.ImmortalCharge = 0
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.initData)

local function CanOnlyHaveSoulHearts(player)
	if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY
	or player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B or player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS
	or player:GetPlayerType() == PlayerType.PLAYER_JUDAS_B or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B
	or player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
		return true
	end
	return false
end

function mod:ImmortalHeartUpdate(entity, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local player = collider:ToPlayer()
		if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
			player = player:GetMainTwin()
		end
		local data = mod:GetData(player)
		local player = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN and player:GetSubPlayer() or player
		if data.ComplianceImmortalHeart < (player:GetHeartLimit() - player:GetEffectiveMaxHearts()) then
			if entity.SubType == HeartSubType.HEART_IMMORTAL then
				if player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B then
					ComplianceImmortal.AddImmortalHearts(player, 2, data)
				end
				
				entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				entity:GetSprite():Play("Collect", true)
				entity:Die()
				sfx:Play(immortalSfx,1,0)
				return true
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.ImmortalHeartUpdate, PickupVariant.PICKUP_HEART)

function mod:shouldDeHook()
	local reqs = {
	  not game:GetHUD():IsVisible(),
	  game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD),
	  game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= 0
	}
	return reqs[1] or reqs[2] or reqs[3]
end

local function renderingHearts(player,playeroffset)
	local data = mod:GetData(player)
	local pType = player:GetPlayerType()
	local isForgotten = pType == PlayerType.PLAYER_THEFORGOTTEN and 1 or 0
	local transperancy = 1
	local isTotalEven = data.ComplianceImmortalHeart % 2 == 0
	local level = game:GetLevel()
	if pType == PlayerType.PLAYER_JACOB2_B or player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) or isForgotten == 1 then
		transperancy = 0.3
	end
	if isForgotten == 1 then
		player = player:GetSubPlayer()
	end
	local heartIndex = math.ceil(data.ComplianceImmortalHeart/2) - 1
	local goldHearts = player:GetGoldenHearts()
	local getMaxHearts = player:GetEffectiveMaxHearts() + (player:GetSoulHearts() + player:GetSoulHearts() % 2)
	local eternalHeart = player:GetEternalHearts()
	for i=0, heartIndex do
		local ImmortalSplash = Sprite()
		ImmortalSplash:Load("gfx/ui/ui_remix_hearts.anm2",true)

		local hearts = ((CanOnlyHaveSoulHearts(player) and player:GetBoneHearts()*2 or player:GetEffectiveMaxHearts()) + player:GetSoulHearts()) - (i * 2)
		local hpOffset = hearts%2 ~= 0 and (playeroffset == 5 and -6 or 6) or 0
		local playersHeartPos = {
			[1] = Options.HUDOffset * Vector(20, 12) + Vector(hearts*6+36+hpOffset, 12) + Vector(0,10) * isForgotten,
			[2] = screenHelper.GetScreenTopRight(0) + Vector(hearts*6+hpOffset-123,12) + Options.HUDOffset * Vector(-20*1.2, 12) + Vector(0,20) * isForgotten,
			[3] = screenHelper.GetScreenBottomLeft(0) + Vector(hearts*6+hpOffset+46,-27) + Options.HUDOffset * Vector(20*1.1, -12*0.5) + Vector(0,20) * isForgotten,
			[4] = screenHelper.GetScreenBottomRight(0) + Vector(hearts*6+hpOffset-131,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5) + Vector(0,20) * isForgotten,
			[5] = screenHelper.GetScreenBottomRight(0) + Vector((-hearts)*6+hpOffset-36,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5)
		}
		local offset = playersHeartPos[playeroffset]
		local offsetCol = (playeroffset == 1 or playeroffset == 5) and 13 or 7
		offset.X = offset.X  - math.floor(hearts / offsetCol) * (playeroffset == 5 and (-72) or (playeroffset == 1 and 72 or 36))
		offset.Y = offset.Y + math.floor(hearts / offsetCol) * 10
		local anim = "ImmortalHeartFull"
		if not isTotalEven then
			if i == 0 then
				anim = "ImmortalHeartHalf"
			end
		end
		if player:GetEffectiveMaxHearts() == 0 and i == (math.ceil(player:GetSoulHearts()/2) - 1)
		and eternalHeart > 0 then
			anim = anim.."Eternal"
		end
		if goldHearts - i > 0 then
			anim = anim.."Gold"
		end
		if i == 0 and player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
		and getMaxHearts == player:GetHeartLimit() and not player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE)
		and pType ~= PlayerType.PLAYER_JACOB2_B then
			anim = anim.."Mantle"
		end
				
		ImmortalSplash.Color = Color(1,1,1,transperancy)
		--[[local rendering = ImmortalSplash.Color.A > 0.1 or game:GetFrameCount() < 1
		if game:IsPaused() then
			pauseColorTimer = pauseColorTimer + 1
			if pauseColorTimer >= 20 and pauseColorTimer <= 30 and rendering then
				ImmortalSplash.Color = Color.Lerp(ImmortalSplash.Color,Color(1,1,1,0.1),0.1)
			end
		else
			pauseColorTimer = 0
			ImmortalSplash.Color = Color(1,1,1,transperancy)
		end]]
		ImmortalSplash:Play(anim, true)
		local spritename = "gfx/ui/ui_remix_hearts"
		if mod.optionNum == 2 then
			spritename = spritename.."_aladar"
		end
		if mod.optionNum == 3 then
			spritename = spritename.."_peas"
		end
		if mod.optionNum == 4 then
			spritename = spritename.."_beautiful"
		end
		if mod.optionNum == 5 then 
			spritename = spritename.."_goncholito"
		end
		if mod.optionNum == 6 then
			spritename = spritename.."_flashy"
		end
		if mod.optionNum == 7 then
			spritename = spritename.."_bettericons"
		end
		if mod.optionNum == 8 then
			spritename = spritename.."_eternalupdate"
		end
		if mod.optionNum == 9 then
			spritename = spritename.."_duxi"
		end
		spritename = spritename..".png"
		for j = 0,4 do
			ImmortalSplash:ReplaceSpritesheet(j,spritename)
		end
		ImmortalSplash:LoadGraphics()
		ImmortalSplash.FlipX = playeroffset == 5
		ImmortalSplash:Render(Vector(offset.X, offset.Y), Vector(0,0), Vector(0,0))
	end
end

function mod:onRender(shadername)
	if shadername ~= "Immortal Hearts" then return end
	if mod:shouldDeHook() then return end
	local isJacobFirst = false
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = mod:GetData(player)
		if i == 0 and player:GetPlayerType() == PlayerType.PLAYER_JACOB then
			isJacobFirst = true
		end
		if (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS_B or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B) then
			if player:GetOtherTwin() then
				if data.i and data.i == i then
					data.i = nil
				end
				if not data.i then
					local otherTData = mod:GetData(player:GetOtherTwin())
					otherTData.i = i
				end
			elseif data.i then
				data.i = nil
			end
		end
		if player:GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B and not player.Parent and not data.i then
			if player:GetPlayerType() == PlayerType.PLAYER_ESAU and isJacobFirst then
				renderingHearts(player,5)	
			elseif player:GetPlayerType() ~= PlayerType.PLAYER_ESAU then
				renderingHearts(player,i+1)
			end
		end
	end

end
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.onRender)

function mod:ImmortalBlock(entity, damage, flag, source, cooldown)
	local player = entity:ToPlayer()
	local data = mod:GetData(player)
	player = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B and player:GetOtherTwin() or player
	if data.ComplianceImmortalHeart > 0 and damage > 0 then
		if not data.ImmortalTakeDmg and source.Type ~= EntityType.ENTITY_DARK_ESAU then
			if flag & DamageFlag.DAMAGE_FAKE == 0 then
				if not ((flag & DamageFlag.DAMAGE_RED_HEARTS == DamageFlag.DAMAGE_RED_HEARTS or player:HasTrinket(TrinketType.TRINKET_CROW_HEART)) and player:GetHearts() > 0) then
					local isLastImmortalEternal = data.ComplianceImmortalHeart == 1 and player:GetSoulHearts() == 1 and player:GetEffectiveMaxHearts() == 0 and player:GetEternalHearts() > 0
					if (data.ComplianceImmortalHeart % 2 ~= 0) and not isLastImmortalEternal then
						sfx:Play(immortalBreakSfx,1,0)
						local shatterSPR = Isaac.Spawn(EntityType.ENTITY_EFFECT, 904, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect():GetSprite()
						shatterSPR.PlaybackSpeed = 2
						local NumSoulHearts = player:GetSoulHearts() - (1 - player:GetSoulHearts() % 2)
						player:RemoveBlackHeart(NumSoulHearts)
					end
					--Checking for Half Immortal and Eternal heart
					if not isLastImmortalEternal  then
						data.ComplianceImmortalHeart = data.ComplianceImmortalHeart - 1
					end
					data.ImmortalTakeDmg = true
					player:TakeDamage(1,flag | DamageFlag.DAMAGE_NO_MODIFIERS,source,cooldown)
					if data.ComplianceImmortalHeart > 0 then
						local cd = isLastImmortalEternal and cooldown or 20
						player:ResetDamageCooldown()
						player:SetMinDamageCooldown(cd)
						if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_ESAU
						or player:GetPlayerType() == PlayerType.PLAYER_JACOB then
							player:GetOtherTwin():ResetDamageCooldown()
							player:GetOtherTwin():SetMinDamageCooldown(cd)		
						end
					end
					return false
				end
			end
		else
			data.ImmortalTakeDmg = nil
		end
	else
		data.ImmortalTakeDmg = nil
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.ImmortalBlock, EntityType.ENTITY_PLAYER)

function mod:ActOfImmortal(player)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) then return end
	if mod.optionContrition ~= 1 then return end
	local data = mod:GetData(player)
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
	
	if player:GetEternalHearts() > data.lastEternalHearts then
		player:AddEternalHearts(-1)
		
		ComplianceImmortal.AddImmortalHearts(player, 2)
	elseif player:GetMaxHearts() > data.lastMaxHearts then
		player:AddMaxHearts(-2) -- still plays the eternal heart animation but its the best we can do right now
		
		ComplianceImmortal.AddImmortalHearts(player, 2)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.ActOfImmortal)

function mod:HeartHandling(player)
	local data = mod:GetData(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		player = player:GetSubPlayer()
	end
	if data.ComplianceImmortalHeart > 0 then
		data.ComplianceImmortalHeart = data.ComplianceImmortalHeart > player:GetSoulHearts() and player:GetSoulHearts() or data.ComplianceImmortalHeart
		local heartIndex = math.ceil(data.ComplianceImmortalHeart/2) - 1
		for i=0, heartIndex do
			local ExtraHearts = math.ceil(player:GetSoulHearts() / 2) + player:GetBoneHearts() - i
			local imHeartLastIndex = player:GetSoulHearts() - (1 - player:GetSoulHearts() % 2) - i * 2
			if (player:IsBoneHeart(ExtraHearts - 1)) or not player:IsBlackHeart(player:GetSoulHearts() - (1 - player:GetSoulHearts() % 2) - i * 2) then
				for j = imHeartLastIndex, imHeartLastIndex - (heartIndex + 1) * 2, -2 do
					player:RemoveBlackHeart(j)
				end
				player:AddSoulHearts(-data.ComplianceImmortalHeart)
				player:AddBlackHearts(data.ComplianceImmortalHeart)
			end
			if player:GetEffectiveMaxHearts() + player:GetSoulHearts() == player:GetHeartLimit() and data.ComplianceImmortalHeart == 1 then
				player:AddSoulHearts(-1)
			end
		end
		
		if player:GetSoulHearts() % 2 == 0 then
			if ComplianceImmortal.GetImmortalHearts(player,data) % 2 ~= 0 then
				data.ComplianceImmortalHeart = data.ComplianceImmortalHeart + 1
			end
		end
		if player:GetSoulHearts() % 2 ~= 0 then
			if ComplianceImmortal.GetImmortalHearts(player,data) % 2 == 0 then
				print(player:GetSoulHearts())
				player:AddSoulHearts(1)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.HeartHandling)

function mod:ImmortalHeal()
	for i = 0, game:GetNumPlayers() - 1 do
		ComplianceImmortal.HealImmortalHeart(Isaac.GetPlayer(i))
	end
	for _, entity in pairs(Isaac.FindByType(3, 206)) do
		local wispdata = entity:GetData()
		if wispdata.IsImmortal == 1 and entity.HitPoints < entity.MaxHitPoints + 3 then
			entity.HitPoints = entity.HitPoints + 1
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.ImmortalHeal)

function mod:PreEternalSpawn(entityType, variant, subType, position, velocity, spawner, seed)
	local rng = RNG()
	if entityType == EntityType.ENTITY_PICKUP then
		if variant == PickupVariant.PICKUP_HEART then
			if subType == HeartSubType.HEART_ETERNAL then
				rng:SetSeed(seed, 1)
				if rng:RandomFloat() >= (1 - mod.optionChance / 100) then
					return {entityType, variant, HeartSubType.HEART_IMMORTAL, seed}
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, mod.PreEternalSpawn)

function mod:DefaultWispInit(wisp)
	local player = wisp.Player
	local data = mod:GetData(player)
	local wispdata = wisp:GetData()
	if data.ImmortalCharge > 0 then
	wisp:SetColor(Color(232, 240, 255, 0.02, 0, 0, 0), -1, 1, false, false)
		data.ImmortalCharge = data.ImmortalCharge - 1
		wispdata.IsImmortal = 1
	else
		wispdata.IsImmortal = 0
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.DefaultWispInit, FamiliarVariant.WISP)

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