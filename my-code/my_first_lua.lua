--https://lua.neverlose.cc/documentation/events
-- Make a bot to chat the missed log (find out how to get from search) using console exec use the missed sound function and reverse it for chat loggin
-- Add the vote revealer to this script
-- Add the jumpscout function to this script
-- Add ospeek to this as well


nick.menu = { -- Accessing the menu elements
    ["ragebot"] = {
        jumpscout = nick.ref.ragebot.accuracy:switch("Jumpscout"):tooltip("Allow to static jump to stabilize accuracy"),
    },
    ["misc"] = {
        killsay  = nick.ref.misc.in_game:switch("Trashtalk on kill"):tooltip("Say something nonsense talk while kill a enemy"),
        vote     = nick.ref.misc.in_game:switch("Vote reveals"):tooltip("Print the voting information on the console")
    }
}

nick.CreateElements = { -- Creating menu elements
    ["ragebot"] = {
        ospeek = nick.menu.ragebot.os_peek:create(),
    },
    ["misc"] = {
        killsay = nick.menu.misc.killsay:create(),
    }
}

nick.Elements = {
    ["ospeek"] = {
        breaklc = nick.CreateElements.ragebot.ospeek:switch("Break LC"):tooltip("Breaking backtrack"),
    },
    ["trashtalk"] = {
        randchat = nick.CreateElements.misc.killsay:switch("Talk shit in all-chat after a kill")
    },
}

--------------------- FUNCTIONS --------------------- 

-- Vote reveler function
nick.vote_reveals = function() -- This is actually good code lmao
    events.vote_cast:set(function(e)
        -- Source from: https://en.neverlose.cc/market/item?id=7IeKYA
        -- This event only on https://wiki.alliedmods.net/Generic_Source_Events
    
        if not nick.menu.misc.vote:get() then return end
    
        local team = e.team
        local voteOption = e.vote_option == 0 and "YES" or "NO"
    
        local user = entity.get(e.entityid)
    	local userName = user:get_name()
    
        print(("%s voted %s"):format(userName, voteOption))
        print_dev(("%s voted %s"):format(userName, voteOption))
    end)
end

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

-- OS peek function
nick.os_peek = function ()

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local my_weapon = localplayer:get_player_weapon()

    if nick.Elements.ospeek.breaklc:get() then
        nick.ref.ragebot.hs_options:override("Break LC")
    else
        nick.ref.ragebot.hs_options:override()
    end

    if my_weapon then
        local last_shot_time = my_weapon["m_fLastShotTime"]
		local time_difference = globals.curtime - last_shot_time

        if nick.menu.ragebot.os_peek:get() then
            nick.ref.ragebot.autopeek:override(true)
            if time_difference <= 0.5 and time_difference >= 0.255 then
                nick.ref.ragebot.hs:override(false)
            elseif time_difference >= 0.5 then
                nick.ref.ragebot.hs:override(true)
            end
        else
            nick.ref.ragebot.hs_options:override()
            nick.ref.ragebot.autopeek:override()
            nick.ref.ragebot.hs:override()
        end
    end

end

-- Rage jumpscout fix (menu switch)
nick.jumpscout_fix = function ()

    local localplayer = entity.get_local_player()
    if not localplayer then return end
    
    local vel = localplayer.m_vecVelocity
    local speed = math.sqrt(vel.x * vel.x + vel.y * vel.y)

    if nick.menu.ragebot.jumpscout:get() then
        nick.ref.misc.air_strafe:override(math.floor(speed) > 15)
    end

end

-- Pasted example function for trashtalk
nick.trashtalk = function ()
  -- Need to make a menu element
  events.aim_ack:set(function(e)
      local target = e.target
      local get_target_entity = entity.get(target)
      if not get_target_entity then return end
      
      local health = get_target_entity.m_iHealth
  
      if not target:get_name() or not health then return end
      
      if not nick.menu.misc.killsay:get() then
          return end
      if health == 0 then
        if nick.Elements.trashtalk.randchat:get() then -- Random trashtalk
          utils.console_exec("say " .. (nick.Elements.trashtalk.text:get()):format(target:get_name()))
        end
          
      end
  end)
end

--------------------- INIT --------------------- 

events.createmove:set(function(cmd)
    nick.jumpscout_fix()
    nick.os_peek()
end)

nick.once_callback = function ()
    nick.vote_reveals()
    nick.trashtalk()
end

events.shutdown:set(function()
    nick.unload()
end)

nick.once_callback()