--https://lua.neverlose.cc/documentation/events
-- Make a bot to chat the missed log (find out how to get from search) using console exec use the missed sound function and reverse it for chat loggin
-- Add the clan tag changer to this
-- Add ospeek to this as well


----------------------- FFI CODE ---------------------
local ffi = require("ffi")

ffi.cdef[[
	bool PlaySound(
		const char* pszSound,
		void* hmod,
		unsigned int fdwSound
	);

    typedef void* HANDLE;
    typedef HANDLE HWND;
    typedef const char* LPCSTR;
    typedef int BOOL;
    typedef unsigned int UINT;
    typedef long LONG;
    typedef LONG LPARAM;
    typedef LONG LRESULT;
    typedef UINT WPARAM;

    HWND FindWindowA(LPCSTR lpClassName, LPCSTR lpWindowName);
    BOOL SetWindowTextA(HWND hWnd, LPCSTR lpString);

    void* __stdcall URLDownloadToFileA(void* LPUNKNOWN, const char* LPCSTR, const char* LPCSTR2, int a, int LPBINDSTATUSCALLBACK); 
    bool DeleteUrlCacheEntryA(const char* lpszUrlName);
]]

------------------------------------------------------


local urlmon = ffi.load 'UrlMon'
local wininet = ffi.load 'WinInet'


local nick = {} -- You can't replace/change this name

nick.unload = function () -- Unloads ffi
    local user32 = ffi.load("User32.dll")
    local game_window_class = "Valve001" -- Don't move this
    local game_window_title = "Counter-Strike: Global Offensive - Direct3D 9" -- And Thiz!
    local new_title = "Counter-Strike: Global Offensive - Direct3D 9 Running neverlose.cc | "..common.get_username().." [Live] | THE ART OF FINDING YOUR FREEDOM, IS LETTING GO ALL THAT IS HOLDING YOUR BACK."

    ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"):disabled(false)

    cvar["sv_competitive_minspec"]:int(1)
    cvar["r_aspectratio"]:float(0)
    cvar.sv_cheats:int()
    cvar.sv_pure:int()
    cvar.cl_lagcompensation:int(1)

    user32.SetWindowTextA(user32.FindWindowA(game_window_class, new_title), "Counter-Strike: Global Offensive - Direct3D 9")

end

nick.ref = {
    ["ragebot"] = {
        main = ui.find("Aimbot", "Ragebot", "Main"),
        autopeek = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist"),
        hs = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"),
        dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"),
        lag_options = ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"),
        hs_options = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options"),
        hitboxes = ui.find("Aimbot", "Ragebot", "Selection", "Hitboxes"),
        multipoint = ui.find("Aimbot", "Ragebot", "Selection", "Multipoint"),
        safepoint = ui.find("Aimbot", "Ragebot", "Safety", "Safe Points"),
        baim = ui.find("Aimbot", "Ragebot", "Safety", "Body Aim"),
        safety = ui.find("Aimbot", "Ragebot", "Safety"),
        accuracy = ui.find("Aimbot", "Ragebot", "Accuracy", "SSG-08"),
        da = ui.find("Aimbot", "Ragebot", "Main", "Enabled", "Dormant Aimbot"),
    },
    ["antiaim"] = {
        angles = ui.find("Aimbot", "Anti Aim", "Angles"),
        pitch = ui.find("Aimbot", "Anti Aim", "Angles", "Pitch"),
        yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw"),
        base = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"),
        offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
        fakelag = ui.find("Aimbot", "Anti Aim", "Fake Lag"),
        misc = ui.find("Aimbot", "Anti Aim", "Misc"),
        bodyyaw = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
        fs = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"):disabled(true),
        fl_enabled = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"),
        aa_enabled = ui.find("Aimbot", "Anti Aim", "Angles", "Enabled"),
        limit = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit"),
        fd = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
        hidden = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Hidden"),
        slowwalk = ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"),
    },
    ["world"] = {
        main = ui.find("Visuals", "World", "Main"),
        other = ui.find("Visuals", "World", "Other"),
    },
    ["misc"] = {
        in_game = ui.find("Miscellaneous", "Main", "In-Game"),
        other = ui.find("Miscellaneous", "Main", "Other"),
        air_strafe = ui.find("Miscellaneous", "Main", "Movement", "Air Strafe"),
    }
}

nick.menu = {
    ["ragebot"] = {
        jumpscout = nick.ref.ragebot.accuracy:switch("Jumpscout"):tooltip("Allow to static jump to stabilize accuracy")
    },
    ["misc"] = {
        killsay  = nick.ref.misc.in_game:switch("Trashtalk on kill"):tooltip("Say something nonsense talk while kill a enemy"),
        vote     = nick.ref.misc.in_game:switch("Vote reveals"):tooltip("Print the voting information on the console")
    }
}

nick.CreateElements = {
    ["misc"] = {
        killsay = nick.menu.misc.killsay:create()
    }
}


local current_phase = 0
local trashtalktt = {
"If you want to play against enemies of your skill level just go to the main menu and click 'Offline with Bots'.",
"You don't deserve to play this game. Go back to playing with crayons and shitting yourself",
"On a scale from 1 to 10, how old are you?",
"Is that a decoy, or are you trying to shoot somebody?",
"How did i get here from watching dog porn? o_O",
"It's time for a mapchange, isn't it ?",
"You can feel the autism",
"Isn't it uncomfortable playing Counterstrike in the kitchen?",
"Cheer up, your small dick isnt noticealbe under ur badness.",
"Who are you sponsored by? Parkinson's?",
"I am sorry to inform you that your lack of practice, has lead to a underwhelming display of skill aim wise.",
"Even Noah can't carry these animals...",
"How much did you tag that wall for??",
"My dead dad has better aim than you, it only took him one bullet",
"Buy sound next time...",
"You dropped that bomb just like your mom dropped you on your head as a kid.",
"Safest place for us to stand is in front of your gun...",
"This isn't a turn-based game, it's okay to shoot back at the same time.",
"I need an apology letter, can I borrow your birth certificate?",
"Is your ass jealous of the amount of shit that just came out of your mouth?",
"I bet you're the type of dude that likes it when your toilet paper breaks and your finger slides up your asshole.",
"Was that your spray on the wall or are you just happy to see me?",
"Your nans like my ak vulcan, battle-scarred.",
"If I wanted to listen to an asshole I would fart.",
"If CS:GO is too hard for you maybe consider a game that requires less skill, like idk.... solitaire?",
"Go rub your cock against a cheese grater you titcrapping twigfucker.",
"I'm surprised you've got the brain power to keep your heart beating",
"Get the bomb, at least you will carry something this game.",
"My knife is well-worn, just like your mother.",
"The only thing you can throw are rounds.",
"Shut up kid and talk to me when your balls have reached the bottom of your spiderman underwear...",
"If you would chew your food you wouldn't be choking so hard.",
"You're about as useful as pedals on a wheelchair.",
"Options -> How To Play",
"Some day you'll go far.. and I hope you stay there.",
"Mirros can't talk. Lucky for you, they can't laugh either.",
"I thought I put bots on hard, why are they on easy?",
"You define autism",
"Go climb a wall of dicks.",
"Did you learn your spray downs in a bukkake video?",
"I PLAY WITH A RACING WHEEL...",
"So next time I scratch my ass I will think of you, now do everyone a favor and FUCK OFF.",
"LISTEN HERE YOU LITTLE FUCKER, WHEN I WAS YOUR AGE, PLUTO WAS A PLANET!",
"You're the human equivalent of a participation award.",
"Imagine your potential if you didn't have parkinsons.",
"LOL watchin u play this game is like watching helen keller play tennis.",
"You suck so much dick, that you turn your entire team gay.",
"Theres more silver here than in the cutlery drawer...",
"Yo momma's so damn fat they named her after your throwing skills.",
"────────⚪─── ◄◄⠀▐▐⠀►► 𝟸:𝟷𝟾 / 𝟹:𝟻𝟼⠀───○ 🔊",
"When I see your face there's not a thing I would change... Except the direction I was walking in.",
"Aha! I see the fuck-up fairy has visited us again.",
"FYI: Warmup is over already.",
"Can't hear you from the bottom of the scoreboard.",
"At least I don't live in the world's most corrupt country.",
"I kissed your mom last night. Her breath was globally offensive",
"Stop buying an awp you $4750 decoy...",
"If this guy was the shooter harambe would still be alive.",
"I could swallow bullets and shit out a better spray than that...",
"Maybe if you stopped taking loads in the mouth you wouldn't be so salty.",
"Sell your computer and buy a Wii.",
"You're the human equivalent to biting into an oatmeal raisin cookie thinking it's chocolate chip.",
"If laughter is the best medicine, your face must be curing the world.",
"Did you know that csgo is free to uninstall?",
"Did your parents meet at a family reunion by any chance?",
"Some babies were dropped on their heads but you were clearly thrown at a wall.",
"I thought I was ugly but evolution really took a step back with you.",
"Stop playing like KQLY why cant you play more like Tarik?",
"It's not that you're intimidating, youre face is just difficult to look at.",
"Protip: Using a mouse is recommended.",
"Hey mate, what controller are you using?",
"It's impossible to underestimate you.",
"If we learn from our mistakes, your parents must be geniuses now.",
"Are you one of those special kids?",
"Kick your teammate, he's flooring.",
"At least you did 100 damage to the wall behind me.",
"At least my country has indoor plumbing.",
"You have a reaction time slower than coastal erosion.",
"You're almost as salty as the semen dripping from your mum's mouth.",
"When you were born the doctor threw you out the window, and the window threw you back.",
"If I had a face like yours, I'd sue my parents.",
"Nice $4750 decoy.",
"Watching you play is making my brain cells want commit suicide.",
"Which one of your 2 dads taught you how to play CS?",
"You shoot like an AI designed by a 10 year old",
"I'm glad to see you're not letting your education get in the way of your ignorance.",
"Your family tree must be a circle.",
"Your family must have a motto of Incest is Wincest for you to be that retarded.",
"ez katka 8)",
"Is this casual? I have 16k...",
"Bro you couldn't hit an elephant in the ass with a shotgun with aim like that.",
"If you were a CSGO match, your mother would have a 7day cooldown all the time, because she kept abandoning you.",
"You sound like your parents beat each other in front of you.",
"You make NiP look good.",
"Don't be upsetti, have some spaghetti",
"Mad cuz bad",
"I have not met with anything in natural history more amusing and entertaining than your personal appearance.",
"Oops, I must have chosen easy bots by accident...",
"If I were to commit suicide, I would jump from your ego to your elo.",
"Your shots are like a bad girlfriend: No Head",
"Shut up, you have two dads.",
"SORRY JUST CLEANING THE JIZZ OF MY KEYBOARD!!",
"Choose your excuse: 1.Lags | 2.New mouse | 3.Low FPS | 4.Low team | 5.Hacker | 6.Lucker | 7.Smurf | 8.Hitbox | 9.Tickrate",
"Guys, if we want to win this, stop writing fucking Klingon, can't understand shit.",
"Yo mama so fat when she plays Overpass, you can shoot her on Mirage.",
"If I wanted a comeback, I'd get it off your moms face.",
"Atleast hitler knew when to kill himself.",
"Do you make eye-contact when you're fucking your dad in the ass?",
"Server cvar 'sv_rekt' changed to 1",
"Rest in spaghetti never forgetti",
"Hey, you have something on your chin... No, the 3rd one down.",
"Like what your mother did to you, can I get a drop?",
"Even if you would play tetris you would tie up",
"With aim like that, I pity whoever has to clean the floor around your toilet.",
"Yo momma so fat, she gets stuck at long doors.",
"Your idea of a comeback is jerking off into a fan.",
"Did you grow up near by Tschernobyl or why are you so toxic?",
"Id rather rub my dick with sandpaper than play with you guys.",
"bvfndsubmdsj vudsa,vsjnfn   ., .,.,",
"I'm the reason your dad's gay.",
"I'm not trash talking, I'm talking to trash.",
"Everyone who loves you is wrong.",
"You have the reaction time of a dead puppy.",
"They do not deserve like this, they do not deserve for rekt...",
"You must be russian, I smell your drunk mom.",
"So, a thought crossed your mind? Must have been a long and lonely journey.",
"Your only chance of getting laid is to crawl up a chicken's ass and wait.",
"Sorry, I don't speak star wars.",
"You know all those times your parents said video games would get you nowhere? They were right.",
"Bhopped to your mom's house last Sunday, top kek.",
"I'd say your aim is cancer, but cancer kills.",
"Сука блять, иди нахуй пидор бля",
"We may have lost the game, but at the end of the day we, unlike you, are not Russians",
"You look like you have parkinsons you shake and bake fuck-knuckle.",
"The only thing you carry is an extra chromosome.",
"CRY HERE ---> \\__/ <--- Africans need water.",
"Light travels faster than sound which is why you seemed bright until you spoke.",
"Why can't I take control of this bot?",
"Your mom is so fat when she boosts she teamkills",
"You only killed me because I ran out of health...",
"I support abortion up to whatever age you are.",
"Dude you're so fat you run out of breath rushing B",
"Go have a 3 sum with your sister and your cousin you fucking hill billy redneck.",
"You guys were ecoing as well?",
"You must have been born on a highway cos' that's where most accidents happen.",
"Hey man, dont worry about being bad. It's called a trashCAN not a trashCAN'T.",
"You can't even carry groceries in from the car",
"I thought I already finished chemistry.. So much NaCl around here...",
"Do you feel special? Please try suicide again... Hopefully you will be successful this time.",
"You’re the reason God created the middle finger.",
"How'd you hit the ACCEPT button with that aim?",
"You're going to give me an aneurysm.",
"You must be fat because you have a nice voice, and the air needs enough space in your lungs to articulate the sound right.",
"I'd love to see things from your perspective, but I don't think I could shove my head that far up my ass.",
"It was a sad day at the hospital when you crawled out of the abortion bucket.",
"I'd say uninstall but you'd probably miss that too",
"now ᴘʟᴀʏɪɴɢ: Who asked (Feat: Nobody did)",
"I PRAY TO GOD A PACK OF WOLVES RAPES YOU IN THE DEAD OF WINTER AND FORCES YOU TO WALK HOME BAREFOOT!",
"Internet Explorer is faster than your reactions.",
"When I wake up in the morning I have better spray control than your garbage AK47 spray, delete CS kid...",
"You're as useless as the 'ueue' in 'queue'",
"You're the reason the gene pool should have a life guard.",
"You could not pre-fire a marching band full of elephants.",
"Don't be a loser, buy a rope and hang yourself.",
"Deranking?",
"Is your monitor on?",
"Shut up, I fucked your dad."
}
get_word = function(words)  current_phase = current_phase + 1 if current_phase > #words then current_phase = 1 end return words[current_phase]:gsub('\'', '') end

-- Staic in air with scout
nick.jumpscout_fix = function ()
    local localplayer = entity.get_local_player()
    if not localplayer then return end
    
    local vel = localplayer.m_vecVelocity
    local speed = math.sqrt(vel.x * vel.x + vel.y * vel.y)

    if nick.menu.ragebot.jumpscout:get() then
        nick.ref.misc.air_strafe:override(math.floor(speed) > 15)
    end

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

-- Reveals votes...
nick.vote_reveals = function() -- This is actually good code lmao
    events.vote_cast:set(function(e)
        -- Source from: https://en.neverlose.cc/market/item?id=7IeKYA (COOPER LOOK INTO THIS LMAO)
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

-- Pasted example function for trashtalk
nick.trashtalk = function ()
  -- Need to make a menu element
  events.aim_ack:set(function(e)
      local target = e.target
      local get_target_entity = entity.get(target)
      if not get_target_entity then return end
      local health = get_target_entity.m_iHealth
      local local_player = entity.get_local_player()

      if not nick.menu.misc.killsay:get() then return end
  
      if not target:get_name() or not health then return end
      
      if get_target_entity:is_alive() == false then
          utils.console_exec("say " .. (get_word(trashtalktt)))
        
    end
  end)
end

--------------------- INIT --------------------- 

events.createmove:set(function(cmd)
    nick.jumpscout_fix()
end)

nick.once_callback = function ()
    nick.trashtalk()
    nick.vote_reveals()
end

events.shutdown:set(function()
    nick.unload()
end)

nick.once_callback()