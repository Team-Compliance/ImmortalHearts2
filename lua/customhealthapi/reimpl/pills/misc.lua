-- Thanks Xalum for Horse Pill detection
function CustomHealthAPI.Helper.IsPlayerUsingHorsePill(player, useflags)
	local pillColour = player:GetPill(0)

	local holdingHorsePill = pillColour & PillColor.PILL_GIANT_FLAG > 0
	local proccedByEchoChamber = useflags & (1 << 11) > 0 -- UseFlag.USE_NOHUD i hate basegame enums all my homies hate basegame enums

	return holdingHorsePill and not proccedByEchoChamber
end

function CustomHealthAPI.Helper.AddUsePillCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_USE_PILL, CustomHealthAPI.Mod.UsePillCallback, -1)
end
CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_PILL] = CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_PILL] or {}
table.insert(CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_PILL], CustomHealthAPI.Helper.AddUsePillCallback)

function CustomHealthAPI.Helper.RemoveUsePillCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_USE_PILL, CustomHealthAPI.Mod.UsePillCallback)
end
CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_PILL] = CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_PILL] or {}
table.insert(CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_PILL], CustomHealthAPI.Helper.RemoveUsePillCallback)

function CustomHealthAPI.Mod:UsePillCallback(pill, player, useflags)
	local doubled = CustomHealthAPI.Helper.IsPlayerUsingHorsePill(player, useflags)
	if pill == PillEffect.PILLEFFECT_BALLS_OF_STEEL then
		-- adds two soul hearts
		local hp = 4
		if doubled then 
			hp = hp * 2
		end
		CustomHealthAPI.Helper.UpdateHealthMasks(player, "SOUL_HEART", hp)
		CustomHealthAPI.Helper.UpdateBasegameHealthState(player)
	elseif pill == PillEffect.PILLEFFECT_FULL_HEALTH then
		-- full heal
		CustomHealthAPI.Helper.UpdateHealthMasks(player, "RED_HEART", 99, true, false, false, true)
		if doubled then
			CustomHealthAPI.Helper.UpdateHealthMasks(player, "SOUL_HEART", 6)
		end
		CustomHealthAPI.Helper.UpdateBasegameHealthState(player)
	elseif pill == PillEffect.PILLEFFECT_HEALTH_DOWN then
		-- removes a heart container
		-- adds a heart container
		if CustomHealthAPI.Helper.PlayerIsTheForgotten(player) then
			local hp = -1
			if doubled then 
				hp = hp * 2
			end
			CustomHealthAPI.Helper.UpdateHealthMasks(player, "BONE_HEART", hp)
		else
			local hp = -2
			if doubled then 
				hp = hp * 2
			end
			CustomHealthAPI.Helper.UpdateHealthMasks(player, "EMPTY_HEART", hp, false, true)
		end
		if CustomHealthAPI.Helper.GetTotalHP(player) == 0 then
			if CustomHealthAPI.Helper.PlayerIsBethany(player) then
				CustomHealthAPI.Helper.UpdateHealthMasks(player, "EMPTY_HEART", 1)
				CustomHealthAPI.Helper.UpdateHealthMasks(player, "RED_HEART", 1, false, false, false, true)
			elseif CustomHealthAPI.Helper.PlayerIsTheForgotten(player) then
				CustomHealthAPI.Helper.UpdateHealthMasks(player, "BONE_HEART", 1)
			else
				local key = "SOUL_HEART"
				local hp = 1
				
				--[[local prevent = false
				local callbacks = CustomHealthAPI.Helper.GetCallbacks(CustomHealthAPI.Enums.Callbacks.PRE_HORSE_HEALTH_DOWN_HEAL)
				for _, callback in ipairs(callbacks) do
					local newKey, newHP = callback.Function(player, key, hp)
					if newKey ~= nil or newHP ~= nil then
						key = newKey or key
						hp = newHP or hp
					end
				end]]--
				
				CustomHealthAPI.Helper.UpdateHealthMasks(player, key, hp)
			end
		end
		CustomHealthAPI.Helper.UpdateBasegameHealthState(player)
	elseif pill == PillEffect.PILLEFFECT_HEALTH_UP then
		-- adds a heart container
		local hp = 2
		if doubled then 
			hp = hp * 2
		end
		CustomHealthAPI.Helper.UpdateHealthMasks(player, "EMPTY_HEART", hp)
		CustomHealthAPI.Helper.UpdateBasegameHealthState(player)
	elseif pill == PillEffect.PILLEFFECT_HEMATEMESIS then
		-- sets red health to 1 red heart of the highest priority key
		CustomHealthAPI.Helper.HandleHematemesis(player)
		CustomHealthAPI.Helper.UpdateBasegameHealthState(player)
	elseif pill == PillEffect.PILLEFFECT_EXPERIMENTAL then
		-- not implemented; no way to discern what stats were changed
	end
end