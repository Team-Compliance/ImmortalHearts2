local DSSModName = "Dead Sea Scrolls (Immortal Hearts)"

local DSSCoreVersion = 7

local mod = ComplianceImmortal
-- Every MenuProvider function below must have its own implementation in your mod, in order to handle menu save data.
local MenuProvider = {}

function MenuProvider.SaveSaveData()
    mod:OnSave(true)
end

function MenuProvider.GetPaletteSetting()
    return  mod.savedata.DSS.MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    mod.savedata.DSS.MenuPalette = var
end

function MenuProvider.GetGamepadToggleSetting()
    return  mod.savedata.DSS.GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    mod.savedata.DSS.GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return  mod.savedata.DSS.MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    mod.savedata.DSS.MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return  mod.savedata.DSS.MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    mod.savedata.DSS.MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return mod.savedata.DSS.MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    mod.savedata.DSS.MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return mod.savedata.DSS.MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    mod.savedata.DSS.MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return mod.savedata.DSS.MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    mod.savedata.DSS.MenusPoppedUp = var
end

local DSSInitializerFunction = include("lua.dssmenucore")

-- This function returns a table that some useful functions and defaults are stored on
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)


-- Adding a Menu


-- Creating a menu like any other DSS menu is a simple process.
-- You need a "Directory", which defines all of the pages ("items") that can be accessed on your menu, and a "DirectoryKey", which defines the state of the menu.
local ihdir = {
    -- The keys in this table are used to determine button destinations.
    main = {
        -- "title" is the big line of text that shows up at the top of the page!
        title = 'immortal hearts',

        -- "buttons" is a list of objects that will be displayed on this page. The meat of the menu!
        buttons = {
            -- The simplest button has just a "str" tag, which just displays a line of text.
            
            -- The "action" tag can do one of three pre-defined actions:
            --- "resume" closes the menu, like the resume game button on the pause menu. Generally a good idea to have a button for this on your main page!
            --- "back" backs out to the previous menu item, as if you had sent the menu back input
            --- "openmenu" opens a different dss menu, using the "menu" tag of the button as the name
            {str = 'resume game', action = 'resume'},

            -- The "dest" option, if specified, means that pressing the button will send you to that page of your menu.
            -- If using the "openmenu" action, "dest" will pick which item of that menu you are sent to.
            {str = 'settings', dest = 'settings'},

           
            -- A few default buttons are provided in the table returned from DSSInitializerFunction.
            -- They're buttons that handle generic menu features, like changelogs, palette, and the menu opening keybind
            -- They'll only be visible in your menu if your menu is the only mod menu active; otherwise, they'll show up in the outermost Dead Sea Scrolls menu that lets you pick which mod menu to open.
            -- This one leads to the changelogs menu, which contains changelogs defined by all mods.
            dssmod.changelogsButton,

        },

        -- A tooltip can be set either on an item or a button, and will display in the corner of the menu while a button is selected or the item is visible with no tooltip selected from a button.
        -- The object returned from DSSInitializerFunction contains a default tooltip that describes how to open the menu, at "menuOpenToolTip"
        -- It's generally a good idea to use that one as a default!
        tooltip = dssmod.menuOpenToolTip
    },
    settings = {
        title = 'settings',
        buttons = {
            -- These buttons are all generic menu handling buttons, provided in the table returned from DSSInitializerFunction
            -- They'll only show up if your menu is the only mod menu active
            -- You should generally include them somewhere in your menu, so that players can change the palette or menu keybind even if your mod is the only menu mod active.
            -- You can position them however you like, though!
                        
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
            dssmod.menuHintButton,
            dssmod.menuBuzzerButton,
           
            {
                str = 'sprites',

                -- The "choices" tag on a button allows you to create a multiple-choice setting
                
                choices = {
                    "vanilla",
                    "aladar",
                    "lifebar",
                    "beautiful",
                    "flashy", 
                    "better icons", 
                    "eternal update",
                    "re-color",
                    "sussy",
                },
                -- The "setting" tag determines the default setting, by list index. EG "1" here will result in the default setting being "choice a"
                setting = 1,

                -- "variable" is used as a key to story your setting; just set it to something unique for each setting!
                variable = 'ComplianceImmortal.optionNum',
                
                -- When the menu is opened, "load" will be called on all settings-buttons
                -- The "load" function for a button should return what its current setting should be
                -- This generally means looking at your mod's save data, and returning whatever setting you have stored
                load = function()
                    return mod.optionNum or 1
                end,

                -- When the menu is closed, "store" will be called on all settings-buttons
                -- The "store" function for a button should save the button's setting (passed in as the first argument) to save data!
                store = function(var)
                    mod.optionNum = var
                    local animfile = "gfx/ui/ui_remix_hearts"
                    if mod.optionNum == 2 then
                        animfile = animfile.."_aladar"
                    end
                    if mod.optionNum == 3 then
                        animfile = animfile.."_peas"
                    end
                    if mod.optionNum == 4 then
                        animfile = animfile.."_beautiful"
                    end
                    if mod.optionNum == 5 then
                        animfile = animfile.."_flashy"
                    end
                    if mod.optionNum == 6 then
                        animfile = animfile.."_bettericons"
                    end
                    if mod.optionNum == 7 then
                        animfile = animfile.."_eternalupdate"
                    end
                    if mod.optionNum == 8 then
                        animfile = animfile.."_duxi"
                    end
                    
                    if CustomHealthAPI.PersistentData.HealthDefinitions["HEART_IMMORTAL"] then
                        CustomHealthAPI.PersistentData.HealthDefinitions["HEART_IMMORTAL"].AnimationFilename = animfile..".anm2"
                    end
                end,

                -- A simple way to define tooltips is using the "strset" tag, where each string in the table is another line of the tooltip
                tooltip = {strset = {'change', 'appearance', 'of immortal', 'hearts'}}
            },
            
            {
                str = 'spawn',

                -- If "min" and "max" are set without "slider", you've got yourself a number option!
                -- It will allow you to scroll through the entire range of numbers from "min" to "max", incrementing by "increment"
                min = 0,
                max = 100,
                increment = 1,

                -- You can also specify a prefix or suffix that will be applied to the number, which is especially useful for percentages!
                --pref = 'hi! ',
                suf = '%',

                setting = 20,

                variable = "ComplianceImmortal.optionChance",

                load = function()
                    return mod.optionChance or 20
                end,
                store = function(var)
                    mod.optionChance = var
                end,

                tooltip = {strset = {"immortal", "heart's ", "rarity"}},
            },
            
            {
                str = 'act of contrition',

                -- The "choices" tag on a button allows you to create a multiple-choice setting
                
                choices = {
                    "on",
                    "off",
                },
                -- The "setting" tag determines the default setting, by list index. EG "1" here will result in the default setting being "choice a"
                setting = 1,

                -- "variable" is used as a key to story your setting; just set it to something unique for each setting!
                variable = 'ComplianceImmortal.optionContrition',
                
                -- When the menu is opened, "load" will be called on all settings-buttons
                -- The "load" function for a button should return what its current setting should be
                -- This generally means looking at your mod's save data, and returning whatever setting you have stored
                load = function()
                    return mod.optionContrition or 1
                end,

                -- When the menu is closed, "store" will be called on all settings-buttons
                -- The "store" function for a button should save the button's setting (passed in as the first argument) to save data!
                store = function(var)
                    mod.optionContrition = var
                end,

                -- A simple way to define tooltips is using the "strset" tag, where each string in the table is another line of the tooltip
                tooltip = {strset = {"replaces act", "of contrition's", "eternal heart", "with an", "immortal", "heart", "like in", "antibirth"}}
            },
        }
    },
}

local ihdirkey = {
    Item = ihdir.main, -- This is the initial item of the menu, generally you want to set it to your main item
    Main = 'main', -- The main item of the menu is the item that gets opened first when opening your mod's menu.

    -- These are default state variables for the menu; they're important to have in here, but you don't need to change them at all.
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

--#region AgentCucco pause manager for DSS

local OldTimer
local OldTimerBossRush
local OldTimerHush
local OverwrittenPause = false
local AddedPauseCallback = false
local function OverridePause(self, player, hook, action)
	if not AddedPauseCallback then return nil end

	if OverwrittenPause then
		OverwrittenPause = false
		AddedPauseCallback = false
		return
	end

	if action == ButtonAction.ACTION_SHOOTRIGHT then
		OverwrittenPause = true
		for _, ember in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.FALLING_EMBER, -1)) do
			if ember:Exists() then
				ember:Remove()
			end
		end
		if REPENTANCE then
			for _, rain in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.RAIN_DROP, -1)) do
				if rain:Exists() then
					rain:Remove()
				end
			end
		end
		return 0.75
	end
end
ComplianceImmortal:AddCallback(ModCallbacks.MC_INPUT_ACTION, OverridePause, InputHook.IS_ACTION_PRESSED)

local function FreezeGame(unfreeze)
	if unfreeze then
		OldTimer = nil
        OldTimerBossRush = nil
        OldTimerHush = nil
        if not AddedPauseCallback then
			AddedPauseCallback = true
		end
	else
		if not OldTimer then
			OldTimer = Game().TimeCounter
		end
        if not OldTimerBossRush then
            OldTimerBossRush = Game().BossRushParTime
		end
        if not OldTimerHush then
			OldTimerHush = Game().BlueWombParTime
		end
		
        Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, UseFlag.USE_NOANIM)
		
		Game().TimeCounter = OldTimer
		Game().BossRushParTime = OldTimerBossRush
		Game().BlueWombParTime = OldTimerHush
	end
end

local function RunDSSMenu(tbl)
    FreezeGame()
    dssmod.runMenu(tbl)
end

local function CloseDSSMenu(tbl, fullClose, noAnimate)
    FreezeGame(true)
    dssmod.closeMenu(tbl, fullClose, noAnimate)
end

--#endregion

DeadSeaScrollsMenu.AddMenu("Immortal Hearts", {
    -- The Run, Close, and Open functions define the core loop of your menu
    -- Once your menu is opened, all the work is shifted off to your mod running these functions, so each mod can have its own independently functioning menu.
    -- The DSSInitializerFunction returns a table with defaults defined for each function, as "runMenu", "openMenu", and "closeMenu"
    -- Using these defaults will get you the same menu you see in Bertran and most other mods that use DSS
    -- But, if you did want a completely custom menu, this would be the way to do it!
    
    -- This function runs every render frame while your menu is open, it handles everything! Drawing, inputs, etc.
    Run = RunDSSMenu,
    -- This function runs when the menu is opened, and generally initializes the menu.
    Open = dssmod.openMenu,
    -- This function runs when the menu is closed, and generally handles storing of save data / general shut down.
    Close = CloseDSSMenu,

    Directory = ihdir,
    DirectoryKey = ihdirkey
})

-- There are a lot more features that DSS supports not covered here, like sprite insertion and scroller menus, that you'll have to look at other mods for reference to use.
-- But, this should be everything you need to create a simple menu for configuration or other simple use cases!