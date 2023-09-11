events.createmove:set(function(e)
    local local_player = entity.get_local_player()

    if local_player.m_MoveType == 9 and common.is_button_down(0x57) then
        e.view_angles.y = math.floor(e.view_angles.y+0.5)
        e.roll = 0

        if e.view_angles.x < 45 then
            e.view_angles.x = 89
            e.in_moveright = 1
            e.in_moveleft = 0
            e.in_forward = 0
            e.in_back = 1
            if e.sidemove == 0 then
                e.view_angles.y = e.view_angles.y + 90
            end
            if e.sidemove < 0 then
                e.view_angles.y = e.view_angles.y + 150
            end
            if e.sidemove > 0 then
                e.view_angles.y = e.view_angles.y + 30
            end
        end
    end
end)