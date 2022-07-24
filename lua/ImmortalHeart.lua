local mod = ComplianceImmortal
local game = Game()
local sfx = SFXManager()
local immortalBreakSfx = Isaac.GetSoundIdByName("ImmortalHeartBreak")
local immortalSfx = Isaac.GetSoundIdByName("immortal")
local screenHelper = require("lua.screenhelper")
-- API functions --

function ComplianceImmortal.AddImmortalHearts(player, amount)
	local index = mod:GetEntityIndex(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		player = player:GetSubPlayer()
	end
	if amount % 2 == 0 then
		if player:GetSoulHearts() % 2 ~= 0 then
			amount = amount - 1 -- if you already have a half heart, a new full immortal heart always replaces it instead of adding another heart
		end
	end
	
	if player:CanPickBlackHearts() or amount < 0 then
		player:AddSoulHearts(amount)
	end
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
		mod.DataTable[index].ImmortalCharge = mod.DataTable[index].ImmortalCharge + math.ceil(amount/2)
	else
		mod.DataTable[index].ComplianceImmortalHeart = mod.DataTable[index].ComplianceImmortalHeart + amount
	end
end

function ComplianceImmortal.GetImmortalHearts(player)
	local index = mod:GetEntityIndex(player)
	return mod.DataTable[index].ComplianceImmortalHeart
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

local function CanOnlyHaveSoulHearts(player)
	if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY
	or player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B or player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS
	or player:GetPlayerType() == PlayerType.PLAYER_JUDAS_B or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B
	or player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
		return true
	end
	return false
end

function mod:ImmortalHeartCollision(entity, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local player = collider:ToPlayer()
		if player.Parent ~= nil then return false end
		if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
			player = player:GetMainTwin()
		end
		local data = mod.DataTable[mod:GetEntityIndex(player)]
		
		if data.ComplianceImmortalHeart < (player:GetHeartLimit() - player:GetEffectiveMaxHearts()) then
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

function mod:shouldDeHook()
	local reqs = {
	  not game:GetHUD():IsVisible(),
	  game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD),
	  game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= 0,
	}
	return reqs[1] or reqs[2] or reqs[3]
end

local pauseColorTimer = 0

local function playersHeartPos(i,hearts,hpOffset,isForgotten)
	if i == 1 then return Options.HUDOffset * Vector(20, 12) + Vector(hearts*6+36+hpOffset, 12) + Vector(0,10) * isForgotten end
	if i == 2 then return screenHelper.GetScreenTopRight(0) + Vector(hearts*6+hpOffset-123,12) + Options.HUDOffset * Vector(-20*1.2, 12) + Vector(0,20) * isForgotten end
	if i == 3 then return screenHelper.GetScreenBottomLeft(0) + Vector(hearts*6+hpOffset+46,-27) + Options.HUDOffset * Vector(20*1.1, -12*0.5) + Vector(0,20) * isForgotten end
	if i == 4 then return screenHelper.GetScreenBottomRight(0) + Vector(hearts*6+hpOffset-131,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5) + Vector(0,20) * isForgotten end
	if i == 5 then return screenHelper.GetScreenBottomRight(0) + Vector((-hearts)*6+hpOffset-36,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5) end
	return Options.HUDOffset * Vector(20, 12)
end

local function renderingHearts(player,playeroffset)
	local index = mod:GetEntityIndex(player)
	local pType = player:GetPlayerType()
	local isForgotten = pType == PlayerType.PLAYER_THEFORGOTTEN and 1 or 0
	local transperancy = 1
	local isTotalEven = mod.DataTable[index].ComplianceImmortalHeart % 2 == 0
	local level = game:GetLevel()
	if pType == PlayerType.PLAYER_JACOB2_B or player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) or isForgotten == 1 then
		transperancy = 0.3
	end
	if isForgotten == 1 then
		player = player:GetSubPlayer()
	end
	local heartIndex = math.ceil(mod.DataTable[index].ComplianceImmortalHeart/2) - 1
	local goldHearts = player:GetGoldenHearts()
	local getMaxHearts = player:GetEffectiveMaxHearts() + (player:GetSoulHearts() + player:GetSoulHearts() % 2)
	local eternalHeart = player:GetEternalHearts()
	for i=0, heartIndex do

		local hearts = ((CanOnlyHaveSoulHearts(player) and player:GetBoneHearts()*2 or player:GetEffectiveMaxHearts()) + player:GetSoulHearts()) - (i * 2)
		local hpOffset = hearts%2 ~= 0 and (playeroffset == 5 and -6 or 6) or 0
		--[[local playersHeartPos = {
			[1] = Options.HUDOffset * Vector(20, 12) + Vector(hearts*6+36+hpOffset, 12) + Vector(0,10) * isForgotten,
			[2] = screenHelper.GetScreenTopRight(0) + Vector(hearts*6+hpOffset-123,12) + Options.HUDOffset * Vector(-20*1.2, 12) + Vector(0,20) * isForgotten,
			[3] = screenHelper.GetScreenBottomLeft(0) + Vector(hearts*6+hpOffset+46,-27) + Options.HUDOffset * Vector(20*1.1, -12*0.5) + Vector(0,20) * isForgotten,
			[4] = screenHelper.GetScreenBottomRight(0) + Vector(hearts*6+hpOffset-131,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5) + Vector(0,20) * isForgotten,
			[5] = screenHelper.GetScreenBottomRight(0) + Vector((-hearts)*6+hpOffset-36,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5)
		}]]
		local offset = playersHeartPos(playeroffset,hearts,hpOffset,isForgotten)--playersHeartPos[playeroffset]
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
		mod.ImmortalSplash.Color = Color(1,1,1,transperancy)
		--[[local rendering = mod.ImmortalSplash.Color.A > 0.1 or game:GetFrameCount() < 1
		if game:IsPaused() then
			pauseColorTimer = pauseColorTimer + 1
			if pauseColorTimer >= 40 and pauseColorTimer <= 60 and rendering then
				mod.ImmortalSplash.Color = Color.Lerp(mod.ImmortalSplash.Color,Color(1,1,1,0.1),0.1)
			end
		else
			pauseColorTimer = 0
			mod.ImmortalSplash.Color = Color.Lerp(mod.ImmortalSplash.Color,Color(1,1,1,1),0.1)--Color(1,1,1,transperancy)
		end]]
		if not mod.ImmortalSplash:IsPlaying(anim) then 
			mod.ImmortalSplash:Play(anim, true)
		end
		mod.ImmortalSplash.FlipX = playeroffset == 5
		mod.ImmortalSplash:Render(Vector(offset.X, offset.Y), Vector(0,0), Vector(0,0))
	end
end

function mod:onRender(shadername)
	if shadername ~= "Immortal Hearts" then return end
	if mod:shouldDeHook() then return end
	local isJacobFirst = false
	local pNum = 1
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player.Parent == nil then
			local index = mod:GetEntityIndex(player)
			if i == 0 and player:GetPlayerType() == PlayerType.PLAYER_JACOB then
				isJacobFirst = true
			end
			
			if (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS_B or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B) then
				if player:GetOtherTwin() then
					if mod.DataTable[index].i and mod.DataTable[index].i == i then
						mod.DataTable[index].i = nil
					end
					if not mod.DataTable[index].i then
						local otherIndex = mod:GetEntityIndex(player:GetOtherTwin())
						mod.DataTable[otherIndex].i = i
					end
				elseif mod.DataTable[index].i then
					mod.DataTable[index].i = nil
				end
			end
			if player:GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B and not mod.DataTable[index].i then
				if player:GetPlayerType() == PlayerType.PLAYER_ESAU and isJacobFirst then
					renderingHearts(player,5)	
				elseif player:GetPlayerType() ~= PlayerType.PLAYER_ESAU then
					renderingHearts(player,pNum)
					pNum = pNum + 1
				end
				if pNum > 4 then break end
			end
		end
	end

end
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.onRender)

function mod:ImmortalBlock(entity, damage, flag, source, cooldown)
	local player = entity:ToPlayer()
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then return nil end
	local index = mod:GetEntityIndex(player)
	player = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B and player:GetOtherTwin() or player
	if mod.DataTable[index].ComplianceImmortalHeart > 0 and damage > 0 and player:GetDamageCooldown() <= 0 then
		if source.Type ~= EntityType.ENTITY_DARK_ESAU then
			if flag & DamageFlag.DAMAGE_FAKE == 0 then
				if not ((flag & DamageFlag.DAMAGE_RED_HEARTS == DamageFlag.DAMAGE_RED_HEARTS or player:HasTrinket(TrinketType.TRINKET_CROW_HEART)) and player:GetHearts() > 0) then
					local isLastImmortalEternal = mod.DataTable[index].ComplianceImmortalHeart == damage and player:GetSoulHearts() == damage and player:GetEffectiveMaxHearts() == 0 and player:GetEternalHearts() > 0
					if (mod.DataTable[index].ComplianceImmortalHeart % 2 ~= 0) and not isLastImmortalEternal then
						sfx:Play(immortalBreakSfx,1,0)
						local shatterSPR = Isaac.Spawn(EntityType.ENTITY_EFFECT, 904, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect():GetSprite()
						shatterSPR.PlaybackSpeed = 2
						for i = 0, damage / 2 do
							local NumSoulHearts = player:GetSoulHearts() - (1 - player:GetSoulHearts() % 2) - 2 * i
							player:RemoveBlackHeart(NumSoulHearts)
						end
					end
					--Checking for Half Immortal and Eternal heart
					if not isLastImmortalEternal  then
						mod.DataTable[index].TookIHDamage = true 
						mod.DataTable[index].ComplianceImmortalHeart = mod.DataTable[index].ComplianceImmortalHeart - damage
					end
					if mod.DataTable[index].ComplianceImmortalHeart <= 0 and mod.DataTable[index].ComplianceHalfDamage and not player:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) and not player:HasCollectible(CollectibleType.COLLECTIBLE_CANCER) then
						mod.DataTable[index].ComplianceHalfDamage = nil
						player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER)
					end
				end
			end				 
		end								
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.ImmortalBlock, EntityType.ENTITY_PLAYER)

function mod:ActOfImmortal(player)
	if player.Parent ~= nil then return end
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) then return end
	if mod.optionContrition ~= 1 then return end
	local index = mod:GetEntityIndex(player)
	if not mod.DataTable[index].lastEternalHearts or not mod.DataTable[index].lastMaxHearts then
		mod.DataTable[index].lastEternalHearts = 0
		mod.DataTable[index].lastMaxHearts = 0
	end
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		player = player:GetMainTwin()
	end
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		player = player:GetSubPlayer()
	end
	
	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) == mod.DataTable[index].ContritionCount then
		mod.DataTable[index].lastEternalHearts = player:GetEternalHearts()
		mod.DataTable[index].lastMaxHearts = player:GetMaxHearts()
	end
	mod.DataTable[index].ContritionCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION)
	
	if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then return end
	if player:GetEternalHearts() > mod.DataTable[index].lastEternalHearts then
		player:AddEternalHearts(-1)
		
		ComplianceImmortal.AddImmortalHearts(player, 2)
	elseif player:GetMaxHearts() > mod.DataTable[index].lastMaxHearts then
		player:AddMaxHearts(-2) -- still plays the eternal heart animation but its the best we can do right now
		
		ComplianceImmortal.AddImmortalHearts(player, 2)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.ActOfImmortal)

function mod:HeartHandling(player)
	if player.Parent ~= nil then return end
	local forgottenCheck = player
	local index = mod:GetEntityIndex(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		if mod.DataTable[index].ComplianceHalfDamage == true and forgottenCheck:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_WAFER) > 0
		and not player:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then
			forgottenCheck:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER)
			mod.DataTable[index].ComplianceHalfDamage = nil
		end
		player = player:GetSubPlayer()
	end
	if mod.DataTable[index].ComplianceImmortalHeart > 0 then
		mod.DataTable[index].ComplianceImmortalHeart = mod.DataTable[index].ComplianceImmortalHeart > player:GetSoulHearts() and player:GetSoulHearts() or mod.DataTable[index].ComplianceImmortalHeart
		local heartIndex = math.ceil(mod.DataTable[index].ComplianceImmortalHeart/2) - 1
		
		if player:GetSoulHearts() % 2 ~= 0 then
			if mod.DataTable[index].ComplianceImmortalHeart % 2 == 0 then
				player:AddSoulHearts(1)
			end
		end
		if player:GetSoulHearts() % 2 == 0 then
			if mod.DataTable[index].ComplianceImmortalHeart % 2 ~= 0 then
				mod.DataTable[index].ComplianceImmortalHeart = mod.DataTable[index].ComplianceImmortalHeart + 1
			end
		end

		for i=0, heartIndex do
			local ExtraHearts = math.ceil(player:GetSoulHearts() / 2) + player:GetBoneHearts() - i
			local imHeartLastIndex = player:GetSoulHearts() - (1 - player:GetSoulHearts() % 2)
			if player:IsBoneHeart(ExtraHearts - 1) or not player:IsBlackHeart(imHeartLastIndex - i * 2) then
				for j = imHeartLastIndex , (imHeartLastIndex - heartIndex * 2), -2 do
					player:RemoveBlackHeart(j)
				end
				local complh = mod.DataTable[index].ComplianceImmortalHeart
				player:AddSoulHearts(-complh)
				player:AddBlackHearts(complh)
				break
			end
		end

		if mod.DataTable[index].ComplianceImmortalHeart > 0 and forgottenCheck:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_WAFER) < 1
		and forgottenCheck:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN then
			forgottenCheck:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER)
			mod.DataTable[index].ComplianceHalfDamage = true
		end
		if mod.DataTable[index].TookIHDamage then
			local cd = 20
			player:ResetDamageCooldown()
			player:SetMinDamageCooldown(cd)
			if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_ESAU
			or player:GetPlayerType() == PlayerType.PLAYER_JACOB then
				player:GetOtherTwin():ResetDamageCooldown()
				player:GetOtherTwin():SetMinDamageCooldown(cd)		
			end
			mod.DataTable[index].TookIHDamage = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.HeartHandling)

function mod:ImmortalHeal()
	for i = 0, game:GetNumPlayers() - 1 do
		ComplianceImmortal.HealImmortalHeart(Isaac.GetPlayer(i))
	end
	for _, entity in pairs(Isaac.FindByType(3, 206)) do
		local index = mod:GetEntityIndex(entity)
		if mod.DataTable[index].IsImmortal == 1 and entity.HitPoints < entity.MaxHitPoints + 3 then
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
	local index = mod:GetEntityIndex(player)
	local wispIndex = mod:GetEntityIndex(wisp)
	if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
		if mod.DataTable[index].ImmortalCharge > 0 then
			wisp:SetColor(Color(232, 240, 255, 0.02, 0, 0, 0), -1, 1, false, false)
			mod.DataTable[index].ImmortalCharge = mod.DataTable[index].ImmortalCharge - 1
			mod.DataTable[wispIndex].IsImmortal = 1
		else
			mod.DataTable[wispIndex].IsImmortal = 0
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.DefaultWispInit, FamiliarVariant.WISP)

function mod:ImmortalWispUpdate(wisp)
	local wispIndex = mod:GetEntityIndex(wisp)
	local wispData = mod:GetData(wisp)
	if not wispData.IsImmortal then
		wispData.IsImmortal = 0
	end
	if mod.DataTable[wispIndex].IsImmortal and wispData.IsImmortal ~= mod.DataTable[wispIndex].IsImmortal then
		if mod.DataTable[wispIndex].IsImmortal > 0 then
			wisp:SetColor(Color(232, 240, 255, 0.02, 0, 0, 0), -1, 1, false, false)
		end
		wispData.IsImmortal = mod.DataTable[wispIndex].IsImmortal
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
