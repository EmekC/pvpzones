---@type string|table
local pvpjson = file.Read('pvpzones.json', 'DATA')
---@diagnostic disable-next-line: cast-local-type, param-type-mismatch
pvpjson = util.JSONToTable(pvpjson or "")
if not pvpjson then pvpjson = {} end ---@cast pvpjson table

---@param ply Player
---@param text string
---@param teamChat boolean
---@return boolean
hook.Add("PlayerSay", 'pvpzoneschat', function (ply, text, teamChat)
    ---@class Player
    ply = ply

    if not ply:IsSuperAdmin() then return end

    local msgarray = string.Explode(' ', text)

    if msgarray[1] == '!pvphelp' then 
        ply:ChatPrint([[!setzone <name> -- will set the first/second position
!removezone <name> -- remove zone or reset current !setzone <name>
!setreward <name> <amount> -- amount to reward on kill
!setpenalty <name> <amount> -- amount to remove on death]])

        return ''
    end

    ---@type {name: string, posdata: Vector}
    if msgarray[1] == '!setzone' then
        ply.zonecache = ply.zonecache or {}
        local zonecache = ply.zonecache

        local name = msgarray[2]
        if not name then ply:ChatPrint('incorrect name') return '' end

        zonecache[name] = zonecache[name] or {}
        if not zonecache[name][1] then 
            zonecache[name][1] = ply:GetPos()

            ply:ChatPrint('Added zone position 1 for zone '..name)
            return ''
        end

        zonecache[name][2] = ply:GetPos()
        ply:ChatPrint('added zone position 2 fo zone '..name)

        pvpjson[name] = {startpos = zonecache[name][1], endpos = zonecache[name][2]}

        file.Write('pvpzones.json', util.TableToJSON(pvpjson))
        ply:ChatPrint('updated pvp zones')
        hook.Run("pvpzone_update")
        
        return ''
    end

    if msgarray[1] == '!removezone' then
        
        local name = msgarray[2]
        if not name then ply:ChatPrint('incorrect name') return '' end

        -- get zones

        -- remove zone
        pvpjson[name] = nil
        file.Write('pvpzones.json', util.TableToJSON(pvpjson))
        ply:ChatPrint('removing zone')
        hook.Run('pvpzone_update')

        return ''
    end
end)