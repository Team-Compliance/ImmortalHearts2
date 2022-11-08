CustomHealthAPI.PersistentData.HiddenPlayerHealthBackup = CustomHealthAPI.PersistentData.HiddenPlayerHealthBackup or {}
CustomHealthAPI.PersistentData.HiddenSubplayerHealthBackup = CustomHealthAPI.PersistentData.HiddenSubplayerHealthBackup or {}

function CustomHealthAPI.Helper.AddFlipCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_PRE_USE_ITEM, CustomHealthAPI.Mod.FlipCallback, CollectibleType.COLLECTIBLE_FLIP)
end
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM] or {}
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_FLIP] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_FLIP] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_FLIP], CustomHealthAPI.Helper.AddFlipCallback)

function CustomHealthAPI.Helper.RemoveFlipCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_PRE_USE_ITEM, CustomHealthAPI.Mod.FlipCallback)
end
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM] or {}
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_FLIP] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_FLIP] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_FLIP], CustomHealthAPI.Helper.RemoveFlipCallback)

function CustomHealthAPI.Mod:FlipCallback(id, rng, player)
	local playertype = player:GetPlayerType()
	if playertype == PlayerType.PLAYER_LAZARUS_B or playertype == PlayerType.PLAYER_LAZARUS2_B then
		CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
		CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
		CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
		CustomHealthAPI.PersistentData.HiddenPlayerHealthBackup[CustomHealthAPI.Helper.GetPlayerIndex(player)] = {Save = player:GetData().CustomHealthAPISavedata, Persist = player:GetData().CustomHealthAPIPersistent}
	end
end

function CustomHealthAPI.Helper.AddEsauJrCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_PRE_USE_ITEM, CustomHealthAPI.Mod.EsauJrCallback, CollectibleType.COLLECTIBLE_ESAU_JR)
end
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM] or {}
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_ESAU_JR] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_ESAU_JR] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_ESAU_JR], CustomHealthAPI.Helper.AddEsauJrCallback)

function CustomHealthAPI.Helper.RemoveEsauJrCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_PRE_USE_ITEM, CustomHealthAPI.Mod.EsauJrCallback)
end
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM] or {}
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_ESAU_JR] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_ESAU_JR] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_USE_ITEM][CollectibleType.COLLECTIBLE_ESAU_JR], CustomHealthAPI.Helper.RemoveEsauJrCallback)

function CustomHealthAPI.Mod:EsauJrCallback(id, rng, player)
	CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(player)
	if CustomHealthAPI.Helper.PlayerIsIgnored(player) then return end
	CustomHealthAPI.Helper.CheckSubPlayerInfoOfPlayer(player)
	CustomHealthAPI.Helper.ResyncHealthOfPlayer(player)
	CustomHealthAPI.PersistentData.HiddenPlayerHealthBackup[CustomHealthAPI.Helper.GetPlayerIndex(player)] = {Save = player:GetData().CustomHealthAPISavedata, Persist = player:GetData().CustomHealthAPIPersistent}
	local subplayer = player:GetSubPlayer()
	if subplayer ~= nil then
		CustomHealthAPI.PersistentData.HiddenSubplayerHealthBackup[CustomHealthAPI.Helper.GetPlayerIndex(player)] = {Save = subplayer:GetData().CustomHealthAPISavedata, Persist = subplayer:GetData().CustomHealthAPIPersistent}
	end
end
