--#region Mod Config Menu
local mod = ComplianceImmortal

mod.optionNum = 1
mod.optionChance = 20
mod.optionContrition = 1
    local Options = {
        [1] = "Vanilla",
        [2] = "Aladar",
		[3] = "Lifebar",
		[4] = "Beautiful",
		[5] = "Goncholito",
		[6] = "Flashy", 
		[7] = "Better Icons", 
		[8] = "Eternal Update",
		[9] = "Re-color",
		[10] = "Sussy",
    }

if ModConfigMenu then
    
    local ImmortalMCM = "Immortal Hearts"
	ModConfigMenu.UpdateCategory(ImmortalMCM, {
		Info = {"Configuration for Immortal Hearts mod.",}
	})

    ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return mod.optionNum
        end,
        Minimum = 1,
        Maximum = 10,
        Display = function()
            return 'Use sprites: ' .. Options[mod.optionNum]
        end,
        OnChange = function(currentNum)
            mod.optionNum = currentNum
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
                mod.ImmortalSplash:ReplaceSpritesheet(j,spritename)
            end
            mod.ImmortalSplash:LoadGraphics()
        end,
        Info = "Change appearance of immortal hearts."
    })

    ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return mod.optionChance
        end,
        Default = 20,
        Minimum = 0,
        Maximum = 100,
        Display = function()
            return 'Chance to replace Eternal Heart: '..mod.optionChance..'%'
        end,
        OnChange = function(currentNum)
            mod.optionChance = currentNum
        end,
        Info = "Immortal heart's rarity."
    })
	
	ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			local current = false
			if mod.optionContrition == 1 then
				current = true
			end
			return current
		end,
		Display = function()
			local onOff = "Off"
			if mod.optionContrition == 1 then
				onOff = "On"
			end
			return "Act of Contrition gives Immortal Heart: " .. onOff
		end,
		OnChange = function(currentBool)
			if currentBool == true then
				mod.optionContrition = 1
			else
				mod.optionContrition = 2
			end
		end,
		Info = "Replaces Act of Contrition's Eternal Heart with an Immortal Heart, like in Antibirth."
	})
	
end