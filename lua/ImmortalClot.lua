local mod = ComplianceImmortal
local game = Game()
local sfx = SFXManager()
local immortalSfx = Isaac.GetSoundIdByName("immortal")

function mod:ClotHeal()
	for _, entity in pairs(Isaac.FindByType(3, 238, 20)) do
		entity = entity:ToFamiliar()
		if entity.HitPoints > 5 then
			local healed = 0
			for _, entity2 in pairs(Isaac.FindByType(3, 238)) do
				entity2 = entity2:ToFamiliar()
				if not entity2:GetData().Healed 
				and GetPtrHash(entity2.Player) == GetPtrHash(entity.Player) 
				and entity2.HitPoints < entity2.MaxHitPoints then
					if entity2.SubType == 0 then
						entity2.HitPoints = entity2.MaxHitPoints
					elseif entity2.SubType ~= 20 then
						entity2.HitPoints = entity2.HitPoints + 2
					end
					local ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 903, 0, entity2.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
					ImmortalEffect:GetSprite().Offset = Vector(0, -10)
					entity2:GetData().Healed = true
					if not sfx:IsPlaying(immortalSfx) then
						sfx:Play(immortalSfx,1,0)
					end
				end
			end
			if entity:GetData().TC_HP < entity.MaxHitPoints then
				entity:GetData().TC_HP = entity:GetData().TC_HP + 1 / (1 + #Isaac.FindByType(3, 238))
			end
		else
			entity:GetData().TC_HP = entity:GetData().TC_HP + 2
		end
		local ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 903, 0, entity.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
		ImmortalEffect:GetSprite().Offset = Vector(0, -10)
		ImmortalEffect:GetSprite().Offset = Vector(0, -10)
		
	end

	for _, entity in pairs(Isaac.FindByType(3, 238)) do
		entity = entity:ToFamiliar()
		if entity:GetData().Healed then
			entity:GetData().Healed = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.ClotHeal)

function mod:StaticHP(clot)
	if clot.SubType == 20 then
		local clotData = clot:GetData()
		if (clotData.TC_HP == nil) then
			clotData.TC_HP = clot.HitPoints
		else
			local damageTaken = clotData.TC_HP - clot.HitPoints
			if (damageTaken > 0.19 and damageTaken < 0.21) then
				clot.HitPoints = clot.HitPoints + damageTaken
			elseif (damageTaken > 1.19 and damageTaken < 1.21) then
				clot.HitPoints = clot.HitPoints - 1.0
			else
				clotData.TC_HP = clot.HitPoints
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, mod.StaticHP, 238)

--SPAWNING
--t eve's ability
function mod:ImmortalClotSpawn(baby)
	local player = baby.Player
	if baby.SubType == 20 then
		if  ComplianceImmortal.GetImmortalHeartsNum(player) % 2 == 0 then
			SFXManager():Play(Isaac.GetSoundIdByName("ImmortalHeartBreak"),1,0)
			local shatterSPR = Isaac.Spawn(EntityType.ENTITY_EFFECT, 904, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect():GetSprite()
			shatterSPR.PlaybackSpeed = 2
		end
		local clot
		for _, s_clot in ipairs(Isaac.FindByType(3,238,20)) do
			s_clot = s_clot:ToFamiliar()
			if GetPtrHash(s_clot.Player) == GetPtrHash(player) and GetPtrHash(baby) ~= GetPtrHash(s_clot) then
				clot = s_clot
				break
			end
		end
		if clot ~= nil then
			local clotData = clot:GetData()
			clotData.TC_HP = clotData.TC_HP + 1
			local ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 903, 0, clot.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
			ImmortalEffect:GetSprite().Offset = Vector(0, -10)
			baby:Remove()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.ImmortalClotSpawn, 238)
