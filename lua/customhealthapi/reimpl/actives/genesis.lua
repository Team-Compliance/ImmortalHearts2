CustomHealthAPI.PersistentData.UsingGenesis = CustomHealthAPI.PersistentData.UsingGenesis or false

function CustomHealthAPI.Helper.AddUseGenesisCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_USE_ITEM, CustomHealthAPI.Mod.UseGenesisCallback, CollectibleType.COLLECTIBLE_GENESIS)
end
CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_ITEM] = CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_ITEM] or {}
CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GENESIS] = CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GENESIS] or {}
table.insert(CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GENESIS], CustomHealthAPI.Helper.AddUseGenesisCallback)

function CustomHealthAPI.Helper.RemoveUseGenesisCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_USE_ITEM, CustomHealthAPI.Mod.UseGenesisCallback)
end
CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_ITEM] = CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_ITEM] or {}
CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GENESIS] = CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GENESIS] or {}
table.insert(CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GENESIS], CustomHealthAPI.Helper.RemoveUseGenesisCallback)

function CustomHealthAPI.Mod:UseGenesisCallback()
	CustomHealthAPI.PersistentData.UsingGenesis = true
	CustomHealthAPI.PersistentData.GlowingHourglassBackup = CustomHealthAPI.Library.GetHealthBackup()
end

function CustomHealthAPI.Helper.ClearHealthForGenesis()
	CustomHealthAPI.PersistentData.HiddenPlayerHealthBackup = {}
	CustomHealthAPI.PersistentData.HiddenSubplayerHealthBackup = {}
	
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		player:GetData().CustomHealthAPISavedata = nil
		player:GetData().CustomHealthAPIOtherData = nil
		CustomHealthAPI.Helper.ClearCandiesAndLockets(player)
		
		if player:GetSubPlayer() ~= nil then
			player:GetSubPlayer():GetData().CustomHealthAPISavedata = nil
			player:GetSubPlayer():GetData().CustomHealthAPIOtherData = nil
			CustomHealthAPI.Helper.ClearCandiesAndLockets(player:GetSubPlayer())
		end
		
		if player:GetOtherTwin() ~= nil then
			player:GetOtherTwin():GetData().CustomHealthAPISavedata = nil
			player:GetOtherTwin():GetData().CustomHealthAPIOtherData = nil
			CustomHealthAPI.Helper.ClearCandiesAndLockets(player:GetOtherTwin())
		end
		
		local callbacks = CustomHealthAPI.Helper.GetCallbacks(CustomHealthAPI.Enums.Callbacks.POST_PLAYER_GENESIS)
		for _, callback in ipairs(callbacks) do
			callback.Function(player)
		end
	end
	
	local callbacks = CustomHealthAPI.Helper.GetCallbacks(CustomHealthAPI.Enums.Callbacks.POST_GENESIS)
	for _, callback in ipairs(callbacks) do
		callback.Function()
	end
end
