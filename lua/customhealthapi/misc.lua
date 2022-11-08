function CustomHealthAPI.Helper.PlayerIsKeeper(player)
	local playerType = player:GetPlayerType()
	return playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B
end

function CustomHealthAPI.Helper.PlayerIsTheForgotten(player)
	local playertype = player:GetPlayerType()
	return playertype == PlayerType.PLAYER_THEFORGOTTEN
end

function CustomHealthAPI.Helper.PlayerIsTheSoul(player)
	local playertype = player:GetPlayerType()
	return playertype == PlayerType.PLAYER_THESOUL
end

function CustomHealthAPI.Helper.PlayerIsTaintedMaggie(player)
	local playertype = player:GetPlayerType()
	return playertype == PlayerType.PLAYER_MAGDALENE_B
end

function CustomHealthAPI.Helper.PlayerIsBethany(player)
	local playertype = player:GetPlayerType()
	return playertype == PlayerType.PLAYER_BETHANY
end

function CustomHealthAPI.Helper.PlayerIsTaintedBethany(player)
	local playertype = player:GetPlayerType()
	return playertype == PlayerType.PLAYER_BETHANY_B
end

function CustomHealthAPI.Helper.IsFoundSoul(player)
	return player.Variant == 1 and player.SubType == BabySubType.BABY_FOUND_SOUL
end

function CustomHealthAPI.Helper.PlayerIsIgnored(player)
	local playertype = player:GetPlayerType()
	return playertype == PlayerType.PLAYER_THELOST or
	       playertype == PlayerType.PLAYER_THELOST_B or
	       playertype == PlayerType.PLAYER_KEEPER or
	       playertype == PlayerType.PLAYER_KEEPER_B or
		   playertype == PlayerType.PLAYER_THESOUL_B or
	       CustomHealthAPI.Helper.IsFoundSoul(player) or
		   player:IsCoopGhost()
end

function CustomHealthAPI.Helper.GetPlayerIndex(player)
    local rng
    if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
        rng = player:GetCollectibleRNG(2) -- flip sucks
	else
        rng = player:GetCollectibleRNG(1)
    end
    
    return tostring(rng:GetSeed())
end

function CustomHealthAPI.Helper.AddBasegameRedHealthWithoutModifiers(player, amount)
	if not (CustomHealthAPI.Helper.PlayerIsTheSoul(player) or CustomHealthAPI.Helper.PlayerIsTaintedBethany(player)) then
		if amount > 0 then
			if CustomHealthAPI.Helper.PlayerIsTaintedMaggie(player) then
				local desiredRed = CustomHealthAPI.PersistentData.OverriddenFunctions.GetHearts(player) + amount
				CustomHealthAPI.PersistentData.OverriddenFunctions.AddHearts(player, math.ceil(amount / 2))
				local actualRed = CustomHealthAPI.PersistentData.OverriddenFunctions.GetHearts(player)
				CustomHealthAPI.PersistentData.OverriddenFunctions.AddHearts(player, desiredRed - actualRed)
			else
				CustomHealthAPI.PersistentData.OverriddenFunctions.AddHearts(player, amount)
			end
		else
			CustomHealthAPI.PersistentData.OverriddenFunctions.AddHearts(player, amount)
		end
	end
end

function CustomHealthAPI.Helper.AddBasegameRottenHealthWithoutModifiers(player, amount)
	if not (CustomHealthAPI.Helper.PlayerIsTheSoul(player) or CustomHealthAPI.Helper.PlayerIsTaintedBethany(player)) then
		if amount > 0 then
			if CustomHealthAPI.Helper.PlayerIsTaintedMaggie(player) then
				CustomHealthAPI.PersistentData.OverriddenFunctions.AddRottenHearts(player, math.ceil(amount / 2))
			else
				CustomHealthAPI.PersistentData.OverriddenFunctions.AddRottenHearts(player, amount)
			end
		else
			CustomHealthAPI.PersistentData.OverriddenFunctions.AddRottenHearts(player, amount)
		end
	end
end

function CustomHealthAPI.Helper.AddBasegameMaxHealthWithoutModifiers(player, amount)
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddMaxHearts(player, amount)
end

function CustomHealthAPI.Helper.AddBasegameSoulHealthWithoutModifiers(player, amount)
	if not (CustomHealthAPI.Helper.PlayerIsTheForgotten(player) or CustomHealthAPI.Helper.PlayerIsBethany(player)) then
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddSoulHearts(player, amount)
	end
end

function CustomHealthAPI.Helper.AddBasegameBlackHealthWithoutModifiers(player, amount)
	if not (CustomHealthAPI.Helper.PlayerIsTheForgotten(player) or CustomHealthAPI.Helper.PlayerIsBethany(player)) then
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddBlackHearts(player, amount)
	end
end

function CustomHealthAPI.Helper.AddBasegameBoneHealthWithoutModifiers(player, amount)
	if not CustomHealthAPI.Helper.PlayerIsTheSoul(player) then
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddBoneHearts(player, amount)
	end
end

function CustomHealthAPI.Helper.AddBasegameBrokenHealthWithoutModifiers(player, amount)
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddBrokenHearts(player, amount)
end

function CustomHealthAPI.Helper.AddBasegameEternalHealthWithoutModifiers(player, amount)
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddEternalHearts(player, amount)
end

function CustomHealthAPI.Helper.AddBasegameGoldenHealthWithoutModifiers(player, amount)
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddGoldenHearts(player, amount)
end

function CustomHealthAPI.Helper.ClearBasegameHealth(player)
	local isTheForgotten = CustomHealthAPI.Helper.PlayerIsTheForgotten(player)
	local isTheSoul = CustomHealthAPI.Helper.PlayerIsTheSoul(player)
	local isBethany = CustomHealthAPI.Helper.PlayerIsBethany(player)
	local isTaintedBethany = CustomHealthAPI.Helper.PlayerIsTaintedBethany(player)

	local goldenTotal = CustomHealthAPI.PersistentData.OverriddenFunctions.GetGoldenHearts(player)
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddGoldenHearts(player, -1 * goldenTotal)
	
	local eternalTotal = CustomHealthAPI.PersistentData.OverriddenFunctions.GetEternalHearts(player)
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddEternalHearts(player, -1 * eternalTotal)
	
	if not isTheSoul then
		if not isTaintedBethany then
			local redTotal = CustomHealthAPI.PersistentData.OverriddenFunctions.GetHearts(player)
			CustomHealthAPI.PersistentData.OverriddenFunctions.AddHearts(player, -1 * redTotal)
		end
		local maxTotal = CustomHealthAPI.PersistentData.OverriddenFunctions.GetMaxHearts(player)
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddMaxHearts(player, -1 * maxTotal)
	end
	
	local brokenTotal = CustomHealthAPI.PersistentData.OverriddenFunctions.GetBrokenHearts(player)
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddBrokenHearts(player, -1 * brokenTotal)
	
	if not isTheSoul then
		local boneTotal = CustomHealthAPI.PersistentData.OverriddenFunctions.GetBoneHearts(player)
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddBoneHearts(player, -1 * boneTotal)
	end
	
	if not (isTheForgotten or isBethany) then
		local soulTotal = CustomHealthAPI.PersistentData.OverriddenFunctions.GetSoulHearts(player)
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddSoulHearts(player, -1 * soulTotal)
	end
end

function CustomHealthAPI.Helper.ClearBasegameHealthNoOther(player)
	local isTheSoul = CustomHealthAPI.Helper.PlayerIsTheSoul(player)

	local goldenTotal = CustomHealthAPI.PersistentData.OverriddenFunctions.GetGoldenHearts(player)
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddGoldenHearts(player, -1 * goldenTotal)
	
	local eternalTotal = CustomHealthAPI.PersistentData.OverriddenFunctions.GetEternalHearts(player)
	CustomHealthAPI.PersistentData.OverriddenFunctions.AddEternalHearts(player, -1 * eternalTotal)
	
	if not isTheSoul then
		local redTotal = CustomHealthAPI.PersistentData.OverriddenFunctions.GetHearts(player)
		CustomHealthAPI.PersistentData.OverriddenFunctions.AddHearts(player, -1 * redTotal)
	end
end

function CustomHealthAPI.Helper.UpdateBasegameHealthState(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		if player:GetOtherTwin() ~= nil then
			return CustomHealthAPI.Helper.UpdateBasegameHealthState(player:GetOtherTwin())
		end
	end
	
	if CustomHealthAPI.Helper.PlayerIsIgnored(player) then
		return
	end
	
	local data = player:GetData().CustomHealthAPISavedata
	local otherMasks = data.OtherHealthMasks
	
	local addedWhoreOfBabylonPrevention = CustomHealthAPI.Helper.AddWhoreOfBabylonPrevention(player)
	local addedBloodyBabylonPrevention = CustomHealthAPI.Helper.AddBloodyBabylonPrevention(player)
	
	local alabasterSlots = {[0] = false, [1] = false, [2] = false}
	local alabasterCharges = {[0] = 0, [1] = 0, [2] = 0}
	for i = 2, 0, -1 do
		if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
			alabasterSlots[i] = true
			alabasterCharges[i] = player:GetActiveCharge(i)
		end
	end
	
	local shacklesDisabled = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIRIT_SHACKLES_DISABLED)
	player:GetEffects():RemoveNullEffect(NullItemID.ID_SPIRIT_SHACKLES_DISABLED, shacklesDisabled)
	
	local challengeIsHaveAHeart = Game().Challenge == Challenge.CHALLENGE_HAVE_A_HEART
	if challengeIsHaveAHeart then
		Game().Challenge = Challenge.CHALLENGE_NULL
	end
	
	local maxHealth = CustomHealthAPI.Helper.GetTotalMaxHP(player)
	local brokenHealth = CustomHealthAPI.Helper.GetTotalKeys(player, "BROKEN_HEART")
	
	local redHealthTotal = CustomHealthAPI.Helper.GetTotalRedHP(player, true)
	local rottenHealth = CustomHealthAPI.Helper.GetTotalHPOfKey(player, "ROTTEN_HEART")
	local redHealth = redHealthTotal - (rottenHealth * 2)
	
	for i = 2, 0, -1 do
		if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
			player:SetActiveCharge(0, i)
		end
	end
	
	CustomHealthAPI.Helper.ClearBasegameHealth(player)
	
	for i = 2, 0, -1 do
		if player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
			player:SetActiveCharge(24, i)
		end
	end
	
	CustomHealthAPI.Helper.AddBasegameMaxHealthWithoutModifiers(player, maxHealth)
	CustomHealthAPI.Helper.AddBasegameBrokenHealthWithoutModifiers(player, brokenHealth)
	
	for i = 1, #otherMasks do
		local mask = otherMasks[i]
		for j = 1, #mask do
			local health = mask[j]
			local key = health.Key
			local atMax = health.HP >= CustomHealthAPI.PersistentData.HealthDefinitions[key].MaxHP
			
			if CustomHealthAPI.PersistentData.HealthDefinitions[key].Type == CustomHealthAPI.Enums.HealthTypes.CONTAINER and
			   CustomHealthAPI.PersistentData.HealthDefinitions[key].KindContained ~= CustomHealthAPI.Enums.HealthKinds.NONE and 
			   CustomHealthAPI.PersistentData.HealthDefinitions[key].MaxHP > 0
			then
				CustomHealthAPI.Helper.AddBasegameBoneHealthWithoutModifiers(player, 1)
			elseif key == "BLACK_HEART" then
				CustomHealthAPI.Helper.AddBasegameBlackHealthWithoutModifiers(player, (atMax and 2) or 1)
			elseif CustomHealthAPI.PersistentData.HealthDefinitions[key].Type == CustomHealthAPI.Enums.HealthTypes.SOUL and
			       key ~= "BLACK_HEART"
			then
				CustomHealthAPI.Helper.AddBasegameSoulHealthWithoutModifiers(player, (atMax and 2) or 1)
			end
		end
	end
	
	CustomHealthAPI.Helper.AddBasegameRottenHealthWithoutModifiers(player, rottenHealth * 2)
	CustomHealthAPI.Helper.AddBasegameRedHealthWithoutModifiers(player, redHealth)
	CustomHealthAPI.Helper.AddBasegameGoldenHealthWithoutModifiers(player, data.Overlays["GOLDEN_HEART"])
	CustomHealthAPI.Helper.AddBasegameEternalHealthWithoutModifiers(player, data.Overlays["ETERNAL_HEART"])
	
	player:GetEffects():AddNullEffect(NullItemID.ID_SPIRIT_SHACKLES_DISABLED, true, shacklesDisabled)
	
	for i = 2, 0, -1 do
		if alabasterSlots[i] then
			player:SetActiveCharge(alabasterCharges[i], i)
		end
	end
	
	if addedWhoreOfBabylonPrevention then CustomHealthAPI.Helper.RemoveWhoreOfBabylonPrevention(player) end
	if addedBloodyBabylonPrevention then CustomHealthAPI.Helper.RemoveBloodyBabylonPrevention(player) end
	
	if challengeIsHaveAHeart then
		Game().Challenge = Challenge.CHALLENGE_HAVE_A_HEART
	end
end

function CustomHealthAPI.Helper.CanAffordPickup(player, pickup)
	local playerType = player:GetPlayerType()
	if pickup.Price > 0 then
		return player:GetNumCoins() >= pickup.Price
	elseif playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B then
		return true
	elseif pickup.Price == -1 then
		--1 Red
		return math.ceil(player:GetMaxHearts() / 2) + player:GetBoneHearts() >= 1
	elseif pickup.Price == -2 then
		--2 Red
		return math.ceil(player:GetMaxHearts() / 2) + player:GetBoneHearts() >= 1
	elseif pickup.Price == -3 then
		--3 soul
		return math.ceil(player:GetSoulHearts() / 2) >= 1
	elseif pickup.Price == -4 then
		--1 Red, 2 Soul
		return math.ceil(player:GetMaxHearts() / 2) + player:GetBoneHearts() >= 1
	elseif pickup.Price == -7 then
		--1 Soul
		return math.ceil(player:GetSoulHearts() / 2) >= 1
	elseif pickup.Price == -8 then
		--2 Souls
		return math.ceil(player:GetSoulHearts() / 2) >= 1
	elseif pickup.Price == -9 then
		--1 Red, 1 Soul
		return math.ceil(player:GetMaxHearts() / 2) + player:GetBoneHearts() >= 1
	else
		return true
	end
end

function CustomHealthAPI.Helper.EmptyAllHealth(player)
	local data = player:GetData().CustomHealthAPISavedata
	local redMasks = data.RedHealthMasks
	local otherMasks = data.OtherHealthMasks
	
	for i = 1, #redMasks do
		local mask = redMasks[i]
		for j = #mask, 1, -1 do
			table.remove(mask, j)
		end
	end
	
	for i = 1, #otherMasks do
		local mask = otherMasks[i]
		for j = #mask, 1, -1 do
			local health = mask[j]
			local key = health.Key
			if CustomHealthAPI.PersistentData.HealthDefinitions[key].Type == CustomHealthAPI.Enums.HealthTypes.SOUL then
				table.remove(mask, j)
			elseif CustomHealthAPI.PersistentData.HealthDefinitions[key].Type == CustomHealthAPI.Enums.HealthTypes.CONTAINER and
			       CustomHealthAPI.PersistentData.HealthDefinitions[key].KindContained ~= CustomHealthAPI.Enums.HealthKinds.NONE and
			       CustomHealthAPI.PersistentData.HealthDefinitions[key].MaxHP > 0 
			then
				table.remove(mask, j)
			end
		end
	end
end
