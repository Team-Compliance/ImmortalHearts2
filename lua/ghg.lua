local mod = ComplianceImmortal

local usesGHG = false

function mod:PrevRoom()
    for _,player in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
        player = player:ToPlayer()
        local index = mod:GetEntityIndex(player)
        if not usesGHG then
            mod.DataTable[index].PrevRoomIH = mod.GetImmortalHearts(player)
        else
            mod.DataTable[index].ComplianceImmortalHeart = mod.DataTable[index].PrevRoomIH
            usesGHG = false
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,mod.PrevRoom)

function mod:UseGHG(collectible,rng,player,flags,slot,vardata)
    usesGHG = true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseGHG, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)