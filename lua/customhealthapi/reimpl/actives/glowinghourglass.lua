CustomHealthAPI.PersistentData.UsingGlowingHourglass = CustomHealthAPI.PersistentData.UsingGlowingHourglass or false
CustomHealthAPI.PersistentData.GlowingHourglassBackup = CustomHealthAPI.PersistentData.GlowingHourglassBackup or nil

function CustomHealthAPI.Helper.AddUseGlowingHourglassCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_USE_ITEM, CustomHealthAPI.Mod.UseGlowingHourglassCallback, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)
end
CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_ITEM] = CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_ITEM] or {}
CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] = CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] or {}
table.insert(CustomHealthAPI.OtherCallbacksToAdd[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS], CustomHealthAPI.Helper.AddUseGlowingHourglassCallback)

function CustomHealthAPI.Helper.RemoveUseGlowingHourglassCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_USE_ITEM, CustomHealthAPI.Mod.UseGlowingHourglassCallback)
end
CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_ITEM] = CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_ITEM] or {}
CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] = CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS] or {}
table.insert(CustomHealthAPI.OtherCallbacksToRemove[ModCallbacks.MC_USE_ITEM][CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS], CustomHealthAPI.Helper.RemoveUseGlowingHourglassCallback)

function CustomHealthAPI.Mod:UseGlowingHourglassCallback()
	CustomHealthAPI.PersistentData.UsingGlowingHourglass = true
end

function CustomHealthAPI.Helper.BackupHealthForGlowingHourglass()
	CustomHealthAPI.PersistentData.GlowingHourglassBackup = CustomHealthAPI.Library.GetHealthBackup()
end

function CustomHealthAPI.Helper.LoadHealthForGlowingHourglass()
	CustomHealthAPI.Library.LoadHealthFromBackup(CustomHealthAPI.PersistentData.GlowingHourglassBackup)
	
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		player:GetData().CustomHealthAPIOtherData = player:GetData().CustomHealthAPIOtherData or {}
		local data = player:GetData().CustomHealthAPIOtherData
		data.LastValues = nil
	end
end
