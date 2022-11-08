CustomHealthAPI.PersistentData.SaveDataLoaded = CustomHealthAPI.PersistentData.SaveDataLoaded or false

function CustomHealthAPI.Helper.AddSaveDataOnNewLevelCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_POST_NEW_LEVEL, CustomHealthAPI.Mod.SaveDataOnNewLevelCallback, -1)
end
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_POST_NEW_LEVEL] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_POST_NEW_LEVEL] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_POST_NEW_LEVEL], CustomHealthAPI.Helper.AddSaveDataOnNewLevelCallback)

function CustomHealthAPI.Helper.RemoveSaveDataOnNewLevelCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL, CustomHealthAPI.Mod.SaveDataOnNewLevelCallback)
end
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_POST_NEW_LEVEL] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_POST_NEW_LEVEL] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_POST_NEW_LEVEL], CustomHealthAPI.Helper.RemoveSaveDataOnNewLevelCallback)

function CustomHealthAPI.Mod:SaveDataOnNewLevelCallback()
	CustomHealthAPI.PersistentData.RestockInfo = {}
	if CustomHealthAPI.PersistentData.SaveDataLoaded then
		CustomHealthAPI.Helper.SaveData()
	end
end

function CustomHealthAPI.Helper.AddSaveDataOnExitCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_PRE_GAME_EXIT, CustomHealthAPI.Mod.SaveDataOnExitCallback, -1)
end
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_GAME_EXIT] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_GAME_EXIT] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_PRE_GAME_EXIT], CustomHealthAPI.Helper.AddSaveDataOnExitCallback)

function CustomHealthAPI.Helper.RemoveSaveDataOnExitCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_PRE_GAME_EXIT, CustomHealthAPI.Mod.SaveDataOnExitCallback)
end
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_GAME_EXIT] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_GAME_EXIT] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_PRE_GAME_EXIT], CustomHealthAPI.Helper.RemoveSaveDataOnExitCallback)

function CustomHealthAPI.Mod:SaveDataOnExitCallback(shouldSave)
	if shouldSave then
		CustomHealthAPI.Helper.SaveData(true)
	end
	
	CustomHealthAPI.PersistentData.SaveDataLoaded = false
end

function CustomHealthAPI.Helper.AddHandleSaveDataOnGameStartCallback()
	CustomHealthAPI.PersistentData.OriginalAddCallback(CustomHealthAPI.Mod, ModCallbacks.MC_POST_GAME_STARTED, CustomHealthAPI.Mod.HandleSaveDataOnGameStartCallback, -1)
end
CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_POST_GAME_STARTED] = CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_POST_GAME_STARTED] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToAdd[ModCallbacks.MC_POST_GAME_STARTED], CustomHealthAPI.Helper.AddHandleSaveDataOnGameStartCallback)

function CustomHealthAPI.Helper.RemoveHandleSaveDataOnGameStartCallback()
	CustomHealthAPI.Mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, CustomHealthAPI.Mod.HandleSaveDataOnGameStartCallback)
end
CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_POST_GAME_STARTED] = CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_POST_GAME_STARTED] or {}
table.insert(CustomHealthAPI.ForceEndCallbacksToRemove[ModCallbacks.MC_POST_GAME_STARTED], CustomHealthAPI.Helper.RemoveHandleSaveDataOnGameStartCallback)

function CustomHealthAPI.Mod:HandleSaveDataOnGameStartCallback(isContinued)
	CustomHealthAPI.PersistentData.HiddenPlayerHealthBackup = {}
	CustomHealthAPI.PersistentData.HiddenSubplayerHealthBackup = {}
	CustomHealthAPI.PersistentData.RestockInfo = {}
	
	if isContinued then
		CustomHealthAPI.Helper.LoadData()
	end
	CustomHealthAPI.Helper.SaveData()
	CustomHealthAPI.PersistentData.GlowingHourglassBackup = CustomHealthAPI.Library.GetHealthBackup()
	
	CustomHealthAPI.PersistentData.SaveDataLoaded = true
end

function CustomHealthAPI.Helper.SaveData(isPreGameExit)
	local save = CustomHealthAPI.Library.GetHealthBackup()
	
	local callbacks = CustomHealthAPI.Helper.GetCallbacks(CustomHealthAPI.Enums.Callbacks.ON_SAVE)
	for _, callback in ipairs(callbacks) do
		callback.Function(save, isPreGameExit == true)
	end
end

function CustomHealthAPI.Helper.LoadData()
	local save
	
	local callbacks = CustomHealthAPI.Helper.GetCallbacks(CustomHealthAPI.Enums.Callbacks.ON_LOAD)
	for _, callback in ipairs(callbacks) do
		save = callback.Function()
		if save ~= nil then
			break
		end
	end
	
	if save ~= nil then
		CustomHealthAPI.Library.LoadHealthFromBackup(save)
	end
end
