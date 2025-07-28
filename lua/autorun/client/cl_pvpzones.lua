
net.Receive("pvpzone_notifyclient", function ()
    local isInside = net.ReadBool()

    local time = CurTime()
    -- if isInside then
        -- inside zone
        
    local message = 
        isInside and "You entered the PVP zone" or "You left the PVP zone"               

    hook.Add("HUDPaint", 'pvpzonehud', function ()
        local alpha = Lerp(math.ease.InCubic(CurTime() - time), 0, 255)
        if CurTime() - time > 5 then
            alpha = -alpha
        end
        draw.SimpleText(message, 'DermaLarge', ScrW() / 2, ScrH() / 4, Color(255,255,255,alpha), TEXT_ALIGN_CENTER)
    end)
    -- else
    --     -- left zone
    --     hook.Remove("HUDPaint", 'pvpzonehud')
    -- end
end)