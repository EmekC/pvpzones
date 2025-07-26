print("Initializing pvpzones")

-- prevent player from spawning props in pvpzone
hook.Add("PlayerSpawnProp", 'pvpzonespawnprop', function (ply, model)
    if ply.IsPVP then return false end
end)

local penalty = 2500
local reward  = 2500

hook.Add("Emek_ShouldNLR", "disablenlrpvpzone", function(ply)
    if ply.IsPVP then return true end
end)

---Take money from player on ddeath
---@param victim Player
---@param inflictor Entity
---@param attacker Entity
hook.Add("PlayerDeath", 'pvpzonedeath', function (victim, inflictor, attacker)
    if not victim:IsPlayer() then return end
    if not victim.IsPVP then return end

    local money = victim:getDarkRPVar('money')
    local plyPenalty = penalty
    if money < penalty then plyPenalty = money end

    -- penaltize on death
    victim:addMoney(-plyPenalty)
    victim:ChatPrint("You lost 2500 dollars")

    -- reward killer
    if inflictor == victim then return end -- suicide
    if not inflictor:IsPlayer() then return end ---@cast inflictor Player

    inflictor:addMoney(reward)
    inflictor:ChatPrint("You got 2500 for killing player")
end)

---@param player Player
local function onPlayerEnter(player)
    ---@class Player
    player = player
    --- strip cp weapons
    -- ["weapons"]:
    -- 	[1]	=	arrest_stick
    -- 	[2]	=	unarrest_stick
    -- 	[3]	=	weapon_glock2
    -- 	[4]	=	stunstick
    -- 	[5]	=	door_ram
    -- 	[6]	=	weaponchecker

    if player:isCP() then
        local jobtable = player:getJobTable()
        for k, wpn in ipairs(jobtable.weapons) do
            player:StripWeapon(wpn)
        end
    end
    -- update player variables
    player.IsPVP = true
    player.BeforePVPStats = {
        health = player:Health(),
        maxarmor = player:GetMaxArmor(),
        armor  = player:Armor()
    }
    player:SetHealth(100)
    player:SetMaxArmor(25)
    player:SetArmor(25)
    
end

---@param player Player
local function onPlayerExit(player)
    -- give back stripped weapons
    if player:Alive() and player:isCP() then
        local jobtable = player:getJobTable()
        for k, wpn in ipairs(jobtable.weapons) do
            player:Give(wpn)
        end
    end//

    if player.BeforePVPStats and player:Alive() then
        player:SetHealth(player.BeforePVPStats.health or 100)
        player:SetMaxArmor(player.BeforePVPStats.maxarmor or 100) 
        player:SetArmor(player.BeforePVPStats.armor or 0)
    end

    player.BeforePVPStats = nil
    player.IsPVP = false
end

local function createZones()
    ---@type string|table|nil
    local pvpzones = file.Read('pvpzones.json', 'DATA')
    ---@diagnostic disable-next-line: param-type-mismatch
    pvpzones = util.JSONToTable(pvpzones or "") ---@cast pvpzones table

    -- entities zones created
    local entZones = {}

    for name, data in pairs(pvpzones) do
        ---@class Entity
        local trigger = ents.Create('base_entity')
        trigger.Type = 'brush'
        -- set origin to center of pvpzone
        trigger:SetPos((data.startpos + data.endpos)/ 2)
        -- dunno
        trigger:SetMoveType(MOVETYPE_NONE)
        -- bounding box
        trigger:SetSolid(SOLID_BBOX)
        -- mark entity as trigger
        trigger:SetTrigger(true)
        -- make players be able to enter to area
        trigger:SetNotSolid(true)
        -- on ent enter
        function trigger:StartTouch(ent)
            if not ent:IsPlayer() then return end
            onPlayerEnter(ent)
        end

        function trigger:EndTouch(ent)
            if not ent:IsPlayer() then return end
            onPlayerExit(ent)
        end
        trigger:Spawn()
        entZones[trigger:EntIndex()] = trigger
        -- important !! set collision bounds after spawn
        trigger:SetCollisionBoundsWS(data.startpos, data.endpos)
    end 

    return entZones
end

--- the brush trigger entities for current zones
local zoneEnts = {}
-- create pvp zones
hook.Add("InitPostEntity", 'pvpzonespawn', function ()
    zoneEnts = createZones()
end)

hook.Add("pvpzone_update", 'update_pvp_zones', function ()
    if zoneEnts then
        for k, ent in pairs(zoneEnts) do
            ent:Remove()
            print('deleting old zone ' .. tostring(k))
        end
    end

    --- create new zones
    print("Creating new pvp zones")
    zoneEnts = createZones()
end)