-- Define a new trigger entity
---@class PVPZoneTrigger : Entity
local ENT = {}

ENT.Type = "brush" -- important for collision and trigger behavior
ENT.Base = "base_entity"
ENT.PrintName = "Custom Trigger Zone"
ENT.Category = "Brickwall Utilities"
ENT.Spawnable = false

function ENT:Initialize()
    self.MinBounds = nil ---@type Vector|nil
    self.MaxBounds = nil ---@type Vector|nil

    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionBounds(self.MinBounds or Vector(-32, -32, 0), self.MaxBounds or Vector(32, 32, 64))
    self:SetTrigger(true)
end

-- Called when something enters the trigger zone
function ENT:StartTouch(ent)
    if IsValid(ent) and ent:IsPlayer() then
        print("[Trigger Zone] " .. ent:Nick() .. " entered the zone!")
    end
end

-- Called when something leaves the trigger zone
function ENT:EndTouch(ent)
    if IsValid(ent) and ent:IsPlayer() then
        print("[Trigger Zone] " .. ent:Nick() .. " left the zone!")
    end
end

scripted_ents.Register(ENT, "pvpzone_trigger")
