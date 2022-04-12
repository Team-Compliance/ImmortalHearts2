local mod = ComplianceImmortal
local game = Game()
local sfx = SFXManager()
local immortalBreakSfx = Isaac.GetSoundIdByName("ImmortalHeartBreak")
local immortalSfx = Isaac.GetSoundIdByName("immortal")
local screenHelper = require("lua.screenhelper")
local doulbeSoulHearts = Isaac.GetEntityVariantByName("Heart (double soul)")
local hearts

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
			if entity.SubType == 902 then
				if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
					player:AddSoulCharge(2)
					data.ImmortalCharge = data.ImmortalCharge + 1
				elseif player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B then
				
					if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
						player = player:GetSubPlayer()
					end
					
					local amount = 2
					if player:GetSoulHearts() % 2 ~= 0 then
						if data.ComplianceImmortalHeart % 2 ~= 0 then
							amount = amount - 1 -- keep it even
						end
						player:AddSoulHearts(1)
					else
						player:AddBlackHearts(2)
					end
					data.ComplianceImmortalHeart = data.ComplianceImmortalHeart + amount
				end
				
				entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				entity:GetSprite():Play("Collect", true)
				entity:Die()
				sfx:Play(immortalSfx,1,0)
				return true
			elseif (player:GetEffectiveMaxHearts() + player:GetSoulHearts() == player:GetHeartLimit() - 1) and data.ComplianceImmortalHeart % 2 ~= 0 then
				local heart = entity:ToPickup()
				if heart.SubType == HeartSubType.HEART_SOUL or (2^math.floor(player:GetSoulHearts()/2) == player:GetBlackHearts() and heart.SubType == HeartSubType.HEART_BLACK) then
					return false
				else
					player:AddBlackHearts(1)
					player:AddSoulHearts(-1)
					
					heart.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					heart:GetSprite():Play("Collect", true)
					heart:Die()
					sfx:Play(SoundEffect.SOUND_UNHOLY,1,0)
					return true
				end
			end
			
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.ImmortalHeartUpdate, PickupVariant.PICKUP_HEART)

function mod:FullSoulHeartInit(pickup)
	if pickup.Variant == PickupVariant.PICKUP_HEART and (pickup.SubType == HeartSubType.HEART_HALF_SOUL or pickup.SubType == HeartSubType.HEART_BLENDED) or 
	(RepentancePlusMod and CustomPickups and (pickup.SubType == CustomPickups.TaintedHearts.HEART_BENIGHTED or pickup.SubType == CustomPickups.TaintedHearts.HEART_DESERTED))
	or (doulbeSoulHearts and pickup.Variant == doulbeSoulHearts) then
		
		pickup = pickup:ToPickup()
		local isImmortalHeart = false
		for i = 0, game:GetNumPlayers() - 1 do
			local data = mod:GetData(Isaac.GetPlayer(i))
			if data.ComplianceImmortalHeart > 0 then
				isImmortalHeart = true
			end
		end
		if isImmortalHeart then
			if pickup.Variant == PickupVariant.PICKUP_HEART then
				if pickup.SubType == HeartSubType.HEART_HALF_SOUL then
					pickup:Morph(pickup.Type,pickup.Variant,HeartSubType.HEART_SOUL,true,true)
				elseif pickup.SubType == HeartSubType.HEART_BLENDED then
					pickup:Morph(pickup.Type,pickup.Variant,HeartSubType.HEART_HALF,true,true)
				elseif RepentancePlusMod then
					if pickup.SubType == CustomPickups.TaintedHearts.HEART_BENIGHTED or pickup.SubType == CustomPickups.TaintedHearts.HEART_DESERTED then
						pickup:Morph(pickup.Type,pickup.Variant,HeartSubType.HEART_BLACK,true,true)
					elseif pickup.SubType == CustomPickups.TaintedHearts.HEART_FETTERED then
						pickup:Morph(pickup.Type,pickup.Variant,HeartSubType.HEART_SOUL,true,true)
					end
				end
			elseif doulbeSoulHearts and pickup.Variant == doulbeSoulHearts and (pickup.SubType == 1 or pickup.SubType == 2) then
				local convert = HeartSubType.HEART_SOUL
				if pickup.SubType == 2 then
					convert = HeartSubType.HEART_BLACK
				end
				local soul1 = Isaac.Spawn(pickup.Type,PickupVariant.PICKUP_HEART,convert,Isaac.GetFreeNearPosition(pickup.Position, 1),Vector.Zero,nil):ToPickup()
				local soul2 = Isaac.Spawn(pickup.Type,PickupVariant.PICKUP_HEART,convert,Isaac.GetFreeNearPosition(pickup.Position, 1),Vector.Zero,nil):ToPickup()
				if pickup:IsShopItem() then
					soul1.AutoUpdatePrice = false
					soul2.AutoUpdatePrice = false
					soul1.Price = soul1.Price > 0 and math.ceil(pickup.Price / 2) or pickup.Price
					soul2.Price = pickup.Price - soul1.Price
				end
				pickup:Remove()
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.FullSoulHeartInit)

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
	if not data.lastEternalHearts then
		data.lastEternalHearts = 0
	end
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		player = player:GetMainTwin()
	end
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		player = player:GetSubPlayer()
	end
	
	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) == data.ContritionCount then
		data.lastEternalHearts = player:GetEternalHearts()
	end
	data.ContritionCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION)
	
	if player:GetEternalHearts() > data.lastEternalHearts then
		player:AddEternalHearts(-1)
		
		local amount = 2
		if player:GetSoulHearts() % 2 ~= 0 then
			player:AddSoulHearts(-1)
			if data.ComplianceImmortalHeart % 2 ~= 0 then
				amount = amount - 1 -- keep it even
			end
		end
		player:AddSoulHearts(amount)
		data.ComplianceImmortalHeart = data.ComplianceImmortalHeart + amount
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
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.HeartHandling)

function mod:ImmortalHeal()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = mod:GetData(player)
		if not (data.ComplianceImmortalHeart % 2 == 0) then
			ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 903, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
			ImmortalEffect:GetSprite().Offset = Vector(0, -22)
			SFXManager():Play(immortalSfx,1,0)
			data.ComplianceImmortalHeart = data.ComplianceImmortalHeart + 1
			player:AddSoulHearts(1)
		end
	end
	for _, entity in pairs(Isaac.FindByType(3, 206)) do
		local wispdata = entity:GetData()
		if wispdata.IsImmortal == 1 and entity.HitPoints < entity.MaxHitPoints + 3 then
			entity.HitPoints = entity.HitPoints + 1
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.ImmortalHeal)

function mod:preEntitySpawn(entityType, variant, subType, position, velocity, spawner, seed)
	local rng = RNG()
	if entityType == EntityType.ENTITY_PICKUP then
		if variant == PickupVariant.PICKUP_HEART then
			if subType == HeartSubType.HEART_ETERNAL then
				rng:SetSeed(seed, 1)
				if rng:RandomFloat() >= (1 - mod.optionChance / 100) then
					return {entityType, variant, 902, seed}
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, mod.preEntitySpawn)

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
	if entity.SubType == 902 then
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