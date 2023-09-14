--https://lua.neverlose.cc/documentation/events
-- Make a bot to chat the missed log (find out how to get from search) using console exec

-- Fast ladder function (passive)
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

-- Pasted example function for trashtalk
nick.trashtalk = function ()
  -- Think i have to make a menu element
  events.aim_ack:set(function(e)
      local target = e.target
      local get_target_entity = entity.get(target)
      if not get_target_entity then return end
      
      local health = get_target_entity.m_iHealth
  
      if not target:get_name() or not health then return end
      
      if not nick.menu.misc.killsay:get() then
          return end
      if health == 0 then
          utils.console_exec("say " .. (nick.Elements.trashtalk.text:get()):format(target:get_name()))
        end
          
      end
  end)
end