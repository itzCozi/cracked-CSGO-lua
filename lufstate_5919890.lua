_STABLE = true
local x, y = render.screen_size().x, render.screen_size().y
local base64 = require("neverlose/base64")
local clipboard = require('neverlose/clipboard')
local version = "stable"
local function gradient_text(r1, g1, b1, a1, r2, g2, b2, a2, text)
    local output = ''
    local len = #text-1
    local rinc = (r2 - r1) / len
    local ginc = (g2 - g1) / len
    local binc = (b2 - b1) / len
    local ainc = (a2 - a1) / len
    for i=1, len+1 do
        output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, a1, text:sub(i, i))
        r1 = r1 + rinc
        g1 = g1 + ginc
        b1 = b1 + binc
        a1 = a1 + ainc
    end

    return output
end

local function logsclr(color)
    local output = ''
    output = output .. ('\a%02x%02x%02x'):format(color.r, color.g, color.b)
    return output
end
ui.sidebar(gradient_text(0, 40, 255, 255, 245, 0, 245, 255, "$ LUFTSTATE.lua"))
local shot_time = 0
local miss_count = 1
local hit_count = 1
local missgroup = 1
local disableTime = 0
local hitmarkerTime = 0
local alp = 0
local refs = {
    yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw"),
	pitch = ui.find("Aimbot", "Anti Aim", "Angles", "Pitch"),
    yaw_base = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"),
    yaw_offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
    yaw_mod = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"),
    yaw_mod_offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"),
    byaw = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
    inverter = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"),
    left_limit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"),
    right_limit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"),
    options = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"),
    fs_desync = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"),
    fs = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"),
    os_aa = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"),
    dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"),
    fd = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
}

local hitboxes = {[0] = "generic", [1] = "head", [2] = "chest", [3] = "stomach", [4] = "left arm", [5] = "right arm", [6] = "left leg", [7] = "right leg", [10] = "gear"}
local trashtalk = {"ＢＵＲＮ ＩＮ ＨＥＬＬ", "Ｚ & Ｖ ＭＹ ＩＤＯＬＳ", "WHAT 何が起こったか?!LUFTSTATE 支配する tech", "LUFT全球最佳 TOP 1 期待购买STATE #1", "ты ебаный подсос моего хуя",
"卐ich habe auf das grab deiner eltern gepisst卐", "𝘧𝘶𝘤𝘬𝘦𝘥 𝘣𝘺 𝘳𝘶 𝘱𝘢𝘴𝘵𝘦", "ты че мне в яйца там гавкаешь", "че с ебалом ублюдок)", "самосвалом тебе по ебалу проехал",
"by LUFTSTATE пидарас", "sit be patient pig", "ａｌｌ ｍｙ ｈｏｍｉｅｓ ｒｅａｄｉｎ ` Ｍａｉｎ Ｋａｍｐｈ`", "выебан", "HELLO CRIP, UR NEXT MAP IS ✈ DE_AIRPORT ✈", "голова пидараса в сумке у папы", "твоя телка скачет на моем хуе как биткоин", "your chick rides my dick like bitcoin", "your bitch is so dumb my bitch is a fighter","you are very bad, I even feel sorry for you", "you can't compare to LUFTSTATE technologies", "cry about it dog", "get clapped hhh","back in ur cage monkey", "ez degenerate", "eat shit dog","ｉｎ ｍｅｉｎｅｍ ａｕｄｉ ｎｕｒ Ｒａｆ Ｃａｍｏｒａ", "залетаю такой на брянск и фип оооо добро пожаловать", "owned by ru product", "ＦＵＣＫ ＹＯＵ ＡＮＤ ＹＯＵＲ ＦＡＭＩＬＹ $$$", "вышел нахуй хуесос", "i hope your family gets burnt alive in a house fire while you sleep","have you heard what’s happening in kenya..kenya suck my balls","i hope your nan gets terminal ovarian cancer you somalian third worlder", "Ｗｈｏ ａｓｋｅｄ ｙｏｕ？ ：Ｄ", "get out of the game, dont be embarrassed", "by godeless, kid" , "майкрай сегодня бодрый", "たか?!LUFTSTATE 支配する, НЕТ БЛЯТЬ LUFTSTATE", "ＩＴ ＷＡＳ ＥＺ ＦＯＲ ＭＥ", "че боксер да? красавчик", "не дай шайтану сбить себя во время намаза", "LUFTSTATE - самые быстрые авиалинии", "LUFTSTATE is the fastest airline",
"ＣＯＣＫ ＡＮＤ ＭＹ ＴＷＯ ＢＡＬＬＳ ＩＮ ＹＯＵ","𝘍𝘙𝘌𝘌 𝘎𝘈𝘔𝘌 𝘈𝘎𝘈𝘐𝘕", "Anyone can hit a woman.But to hit her finances - units...", "я курю газ, но не газпром ( лукойл бро )", "однажды я быканул на океан, теперь он тихий","знаешь почему тебе надо учиться в детдоме? родителей в школу не вызывают","ＭＡＹＣＲＹ!>>>[ＤＥＢＵＧ]", "𝙾𝚠𝙽𝚎𝙳 𝙱𝚘𝚃 𝙱𝚈 LUFTSTATE[STABLE] 𝚃𝙴𝙲𝙷𝙽𝙾𝙻𝙾𝙶𝙸𝙴𝚂 ", "sᴘᴏɴsᴏʀ ᴏꜰ ʏᴏᴜʀ ᴅᴇᴀᴛʜ >>> LUFTSTATE[STABLE]",
"▄︻デ₲Ꝋ ꞨŁɆɆꝐ ⱲɆȺҞ ĐꝊ₲ ══━一", "☆꧁✬◦°˚°◦. ɮʏ ɮɛֆȶ ʟʊǟ .◦°˚°◦✬꧂☆", "🎅 Ꮆ乇ㄒ ㄩ丂乇ᗪ ㄒㄖ 爪ㄚ 丂卩乇尺爪 🎅", "пей бабушкин рассол пидарас", "go sleep", "ur rank - bober premium",
"get good, get LUFTSTATE.lua", "устал улетать с 1 пули? радуйся, что зубы целые", "быть лучшим, не уходя из тени", "go to hell, bitch", "BY LUFTSTATE 美國人 ? WACHINA ( TEXAS ) يورپ technology",
"꧁༺rJloTau mOu Pir()zh()]{ (c) SoSiS]{oY:XD ", "h$ bitch", "卐lass deine eltern sterben卐", "Ｉ`Ｍ ＧＯＤ ＷＩＴＨ ＧＯＤＭＯＤＥ ＡＡ", "спи ебанный ублюдок", "B𝙗𝙡6𝙚𝙅𝙡𝙪𝙅𝙡 3𝙮6𝙗𝙡 𝘾𝘽𝙤𝙀𝙪 𝙘Jl𝙚𝙥𝙈𝙤𝙪", "ＭＡＹＣＲＹ ？ Ｉ ＵＳＥ Ｖ３.１","BY TAP1337 LEGEND","как тебе мой хуй?вкусный?","cry some more into my dick", "ｙｏｕ ｃａｎ ｄｉｇ ａ ｈｏｌｅ ｉｎ ｙｏｕｒ ｏｗｎ ｇｒａｖｅ", "РНБ БЛЯ КЛУБ ЕБАЛИ ТВОЮ МАТЬ", "ＧＯＤ ＢＬＥＳＳ ＲＵＳＳＩＡ ","何が起こったか?!LUFTSTATE","LUFTSTATE>𝔹𝔼𝕊𝕋 𝕃𝕌𝔸","LUFTSTATE>乃乇丂ㄒ ㄥㄩ卂","ＡＬＬ ＤＯＧＳ ＷＡＮＮＡ ＢＥ ＬＩＫＥ ＭＥ","𝗰𝗮𝗰𝗵𝗼𝗿𝗿𝗼 𝗳𝗿𝗮𝗰𝗼 𝘃𝗮𝗶 𝗱𝗼𝗿𝗺𝗶𝗿","Ｉ ｗｉｌｌ ｂｕｒｎ ｄｏｗｎ ｙｏｕｒ ｈｏｕｓｅ",

 }

local gif = ui.create("Home", "$ LUFTSTATE.lua - premium lua [stable]")
local infotab = ui.create("Home", "Information")
local cfgtab = ui.create("Home", "Config System")
local mafia3 = ui.create("Home","Recomendations")
local misctab = ui.create("Settings", "Misc")
local visualstab = ui.create("Settings", "Visuals")
local ragebot111 = ui.create("Settings", "Ragebot")
local aatab = ui.create("Anti-Aim", "Main")
local buildertab = ui.create("Anti-Aim", "Settings")




local infotext = infotab:label("Welcome back, \a0764FFFF"..common.get_username()..'\a89A4B5FF!')
local infotext = infotab:label("Current Build: 3.1 \a0764FFFF[stable]")
local infotext = infotab:label("Latest Update: \a0764FFFF05/11/22")
local infotext = infotab:label("Staff -> \a0764FFFFru nn")

local dss = mafia3:button("\a000000FFJoin Discord")
--dss:set_callback(function() panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://discord.gg/ogleaks") end)
local cfg = mafia3:button("\a000000FFOwned this lua and everyone")
--cfg:set_callback(function() panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://discord.gg/ogleaks") end)



local import_cfg = cfgtab:button("       \a000000FFImport config       ")
local export_cfg = cfgtab:button("        \a000000FFExport config       ")

local cross_inds = visualstab:switch(" Indicators", false)
local tsarrows = visualstab:switch(" Manual Arrows", false)
local inds_settings = cross_inds:create()
local inds_style = inds_settings:combo(" Style", {"Default"})
local crosshm = inds_settings:switch(" Hitmarker")
local inds_color = inds_style:color_picker(color(255, 255, 255, 255))
local debugpanel = visualstab:switch(" Info panel", false)
local custom_scope = visualstab:switch(" Custom scope", false)
local custom_scope_color = custom_scope:create():color_picker(" Color", color(255, 255, 255, 255))
local custom_scope_inverted = custom_scope:create():switch(" Inverted", false)
local custom_scope_gap = custom_scope:create():slider(" Gap", 0, 500, 100)
local custom_scope_size = custom_scope:create():slider(" Size", 0, 500, 100)
local velocity_ind = visualstab:switch(" Velocity modifier")
local velocity_ind_col = velocity_ind:color_picker(color(255, 255, 255, 255))
local ct = misctab:switch(" Clan Tag", false)
local tt = misctab:switch(" Trash Talk", false)
local ar = misctab:switch(" Aspect Ratio", false)
local alllogs = misctab:switch(" Hit Logs", false)
local onscreen = alllogs:create():switch(" Custom logs", false)
local arv = ar:create()
local aspectslider = arv:slider("A R Value", 0, 200, 100)
local solus_windows = misctab:selectable(" Solus", {" Watermark", " Hotkey list"})
local solus_color = solus_windows:color_picker(color(255, 255, 255))
local image_loaded = render.load_image(network.get("https://pbs.twimg.com/media/F5n11qJW4AEPsbX?format=jpg&name=medium"), vector(350, 350))
gif:texture(image_loaded, vector(250, 280), color(255, 255, 255, 255), 'f')


local aimlogs = ragebot111:selectable(" Notifications", {" On damage deal", " Anti-bruteforce"})
local dtfl = ragebot111:switch(" DT in Air", false)
local auto_tp = ragebot111:switch(" Automatic Teleport", false)
local auto_tp_weapons = auto_tp:create():selectable(" Weapons", {" Default", " Pistols", " Heavy pistols", " Scout", " AWP", " Autosnipers", " Nades"})
local aa_enable = aatab:switch(" Master switch", true)
local aa_preset = aatab:combo(" Preset", {" Custom"})
local manual = aatab:combo(" Manual Yaw Base", {" Freestanding"," Right"," Left"," At Target"})
local condition = aatab:combo(" Condition", {" Standing", " Moving", " Slowwalk", " Ducking", " Air", " Air-ducking"})
manual:set(" At Target")
local vars = {angle = 0}
local i_state = {[1] = " [S]", [2] = " [M]", [3] = " [SW]", [4] = " [D]", [5] = " [A]", [6] = " [A-D]"}
antiaim = {}
for i=1, 6 do
	antiaim[i] = {
        yaw_add_left = buildertab:slider(i_state[i].."Yaw Add Left", -180, 180, 0),
        yaw_add_right = buildertab:slider(i_state[i].."Yaw Add Right", -180, 180, 0),
        yaw_mod = buildertab:combo(i_state[i].."Yaw Modifier", {"Disabled", "Center", "Offset", "Random", "Spin"}),
        mod_deg = buildertab:slider(i_state[i].."Modifier Degree", -180, 180, 0),
        fake_limit_type = buildertab:combo(i_state[i].."Fake Limit Type", {"Static", "Jitter"}),
        left_limit = buildertab:slider(i_state[i].."Fake Limit Left", 0, 60, 60),
        right_limit = buildertab:slider(i_state[i].."Fake Limit Right", 0, 60, 60),
        options = buildertab:selectable(i_state[i].."Fake Options", {"Avoid Overlap", "Jitter", "Randomize Jitter"}),
        fs_desync = buildertab:combo(i_state[i].."FS Desync", {"Off", "Peek Fake", "Peek Real"}),
        dsy_onshot = buildertab:combo(i_state[i].."Desync on shot", {"Default", "Opposite", "Freestanding", "Switch"}),
        lby_mode = buildertab:combo(i_state[i].."LBY Mode", {"Disabled", "Opposite", "Sway"}),
	}
end

states = {
    [1] = " Standing", 
    [2] = " Moving", 
    [3] = " Slowwalk", 
    [4] = " Ducking", 
    [5] = " Air", 
    [6] = " Air-ducking"
}

-- @region 

local lerp = function (a, b, percentage) return math.floor(a + (b - a) * percentage) end
function lerpx(time,a,b) return a * (1-time) + b * time end
function daun(x, y, w, h, name, alpha) local name_size = render.measure_text(1, "", name) render.rect(vector(x, y), vector(x + w + 3, y + h + 2),color(18, alpha - 85), 5, true) render.rect_outline(vector(x-1, y-1), vector(x + w + 4, y + h + 3), color(solus_color:get().r, solus_color:get().g, solus_color:get().b, alpha),1, 6, true) render.text(1, vector(x+1 + w / 2 + 1 - name_size.x / 2, y + 2), color(255, 255, 255, alpha), "", name) end
local function bind_mode(x) if x == 2 then return "Toggled" elseif x == 1 then return "Holding" end end
local is_in_bounds = function(bound_a, bound_b, position) return position.x >= bound_a.x and position.y >= bound_a.y and position.x <= bound_b.x and position.y <= bound_b.y end
local latency_text = ""
local alphabinds = 0
alpha_k = 1
data_k = { [''] = {alpha_k = 0}}
local vdragging = false
drag_offset = vector(0, 0)
vdrag_offset = vector(0, 0)
width_k = 0
width_ka = 0
local pos_x = solus_windows:create():slider("posx", 0, x, 150)
local pos_y = solus_windows:create():slider("posy", 0, y, 150)

local pmoram = misctab:combo(" Time Format", {" ru", " eng"})
local width_value = misctab:slider(" Min. Width", 80, 165, 145)

-- @endregion

function setup_menu()
    condition:visibility(aa_enable:get() and aa_preset:get() == " Custom")
    aa_preset:visibility(aa_enable:get())
	manual:visibility(aa_enable:get())
    inds_style:visibility(cross_inds:get())
    pmoram:visibility(solus_windows:get() and solus_windows:get(1))
    width_value:visibility(solus_windows:get() and solus_windows:get(2))
    pos_x:visibility(false)
    for i=1, 6 do
        local current_preset = aa_preset:get()
        local current_cond = condition:get()
        antiaim[i].yaw_add_left:visibility(aa_enable:get() and current_preset == " Custom" and current_cond == states[i])
        antiaim[i].yaw_add_right:visibility(aa_enable:get() and current_preset == " Custom" and current_cond == states[i])
        antiaim[i].yaw_mod:visibility(aa_enable:get() and current_preset == " Custom" and current_cond == states[i])
        antiaim[i].mod_deg:visibility(aa_enable:get() and current_preset == " Custom" and current_cond == states[i])
        antiaim[i].fake_limit_type:visibility(aa_enable:get() and current_preset == " Custom" and current_cond == states[i])
        antiaim[i].left_limit:visibility(aa_enable:get() and current_preset == " Custom" and current_cond == states[i])
        antiaim[i].right_limit:visibility(aa_enable:get() and current_preset == " Custom" and current_cond == states[i])
        antiaim[i].options:visibility(aa_enable:get() and current_preset == " Custom" and current_cond == states[i])
        antiaim[i].fs_desync:visibility(aa_enable:get() and current_preset == " Custom" and current_cond == states[i])
        antiaim[i].dsy_onshot:visibility(aa_enable:get() and current_preset == " Custom" and current_cond == states[i])
        antiaim[i].lby_mode:visibility(aa_enable:get() and current_preset == " Custom" and current_cond == states[i])
    end
end
-- @endregion

function state()
    if not entity.get_local_player() then return end
    local flags = entity.get_local_player().m_fFlags
    local first_velocity = entity.get_local_player()['m_vecVelocity[0]']
    local second_velocity = entity.get_local_player()['m_vecVelocity[1]']
    local velocity = math.floor(math.sqrt(first_velocity*first_velocity+second_velocity*second_velocity))
    if bit.band(flags, 1) == 1 then
        if bit.band(flags, 4) == 4 then
            return 4
        else
            if velocity <= 3 then
                return 1
            else
                if ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"):get() then 
                    return 3
                else
                    return 2
                end
            end
        end
    elseif bit.band(flags, 1) == 0 then
        if bit.band(flags, 4) == 4 then
            return 6
        else
            return 5
        end
    end
end
		
local function manualfunc()
	return (manual:get() == " Right" and 90 or 0) + (manual:get() == " Left" and -90 or 0)
end


local function antiaim_func(cmd)
    if not aa_enable:get() then return end
    local bodyyaw = entity.get_local_player().m_flPoseParameter[11] * 120 - 60
	local side = bodyyaw > 0 and 1 or -1
	if manual:get() == " At Target" then refs.yaw_base:set(" At Target") else refs.yaw_base:set(" Local View") end
	if manual:get() == " Freestanding" then refs.fs:set(true) else refs.fs:set(false) end
	if not (aa_enable:get()) then refs.pitch:set("Disabled") end
        if (aa_preset:get() == " Custom") and (aa_enable:get()) then
			refs.pitch:set(" Down")
            local m_antiaim = antiaim[state()] or nil
            if not m_antiaim then return end
            if cmd.choked_commands == 0 then
                refs.yaw_offset:set((side == 1 and m_antiaim.yaw_add_left:get() or m_antiaim.yaw_add_right:get()) + manualfunc())
            end
			refs.yaw:set(" Backward")
            refs.yaw_mod:set(m_antiaim.yaw_mod:get())
            refs.yaw_mod_offset:set(m_antiaim.mod_deg:get())
            refs.byaw:set(true)
            refs.left_limit:set(m_antiaim.fake_limit_type:get() ~= 'Static' and (globals.tickcount % 4 > 1 and 18 or m_antiaim.left_limit:get()) or m_antiaim.left_limit:get())
            refs.right_limit:set(m_antiaim.fake_limit_type:get() ~= 'Static' and (globals.tickcount % 4 > 1 and 18 or m_antiaim.right_limit:get()) or m_antiaim.right_limit:get())
            refs.options:set(m_antiaim.options:get())
            refs.fs_desync:set(m_antiaim.fs_desync:get())
    end
end
		
local notify=(function() notify_cache={} local a={callback_registered=false,maximum_count=4} 
    function a:set_callback()
        if self.callback_registered then return end; 
        events.render:set(function() 
            local c={x,y} 
            local d={0,0,0} 
            local e=1; 
            local f=notify_cache; 
            for g=#f,1,-1 do 
                notify_cache[g].time=notify_cache[g].time-globals.frametime; 
                local h,i=255,0; 
                local i2 = 0; 
                local lerpy = 150; 
                local lerp_circ1 = 0.5; 
                local j=f[g] 
                if j.time<0 then 
                    table.remove(notify_cache,g) 
                else 
                    local k=j.def_time-j.time; 
                    local k=k>1 and 1 or k; 
                    if j.time<1 or k<1 then 
                        i=(k<1 and k or j.time)/1; 
                        i2=(k<1 and k or j.time)/1; 
                        h=i*255; lerpy=i*150; 
                        lerp_circ1=i*0.5;
                        if i<0.2 then e=e+8*(1.0-i/0.2) end 
                    end; 
                    local m={math.floor(render.measure_text(1, nil, "[LUFTSTATE.lua]  "..j.draw).x*1.03),math.floor(render.measure_text(1, nil, "[LUFTSTATE.lua]  "..j.draw).y*1.03)} 
                    local n={render.measure_text(1, nil, "[LUFTSTATE.lua]  ").x,render.measure_text(1, nil, "[LUFTSTATE.lua]  ").y} 
                    local o={render.measure_text(1, nil, j.draw).x,render.measure_text(1, nil, j.draw).y} 
                    local p={c[1]/2-m[1]/2+3,c[2]-c[2]/100*13.4+e} 
                    local col = inds_color:get()
                    render.circle_outline(vector(p[1]-1,p[2]-9), color(col.r, col.g, col.b, h>255 and 255 or h), 12, 90, lerp_circ1, 2) 
                    render.circle_outline(vector(p[1]+m[1]+1,p[2]-9), color(col.r, col.g, col.b, h>255 and 255 or h), 12, -90, lerp_circ1, 2)
                    render.rect(vector(p[1]-2, p[2]-21), vector(p[1]-149+m[1]+lerpy, p[2]-19), color(col.r, col.g, col.b, h>255 and 255 or h))
					--render.rect(vector(p[1]-149+m[1]+lerpy, p[2]+3), vector(p[1]-2, p[2]+1), color(col.r, col.g, col.b, h>255 and 255 or h), 0, true)
					render.rect(vector(p[1]+m[1]+1,p[2]+1), vector(p[1]+149-lerpy,p[2]+3), color(col.r, col.g, col.b, h>255 and 255 or h), 0, true)
                    render.text(1, vector(p[1]+m[1]/2-o[1]/2-2,p[2] - 10), color(col.r, col.g, col.b,h), "c", "[LUFTSTATE.lua]")
                    render.text(1, vector(p[1]+m[1]/2+n[1]/2-2,p[2] - 10), color(255, 255, 255,h), "c", j.draw)
                    e=e-33
                end 
            end; 
            self.callback_registered=true 
        end) 
    end;
    function a:push(q,r) 
        local s=tonumber(q)+1; 
        for g=self.maximum_count,2,-1 do 
            notify_cache[g]=notify_cache[g-1] 
        end; 
        notify_cache[1]={time=s,def_time=s,draw=r} 
        self:set_callback()
    end;
    return a 
end)() 
local state_string = {[1] = " standing", [2] = " running", [3] = " slowwalk", [4] = " crouch", [5] = " air", [6] = " air-duck"}
notify:push(4, " Load Script\aA9ACFFFF")
local x78 = 255
local x79 = 1

local round = function(num, numDecimalPlaces) return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num)) end
			
local verd = render.load_font("Verdana", 10, 'abd')

local function watermark()
    if solus_windows:get(1) and solus_windowse:get() then
    local ticks = math.floor(1.0 / globals.tickinterval)
    local user_name = common.get_username()
    local actual_time = ""
    if pmoram:get() == "ru" then 
        actual_time = common.get_date("%H:%M")
    else
        actual_time = common.get_date("%I:%M %p")
    end
	if globals.is_in_game then
        local latency = utils.net_channel().avg_latency[0]
        if latency == nil then return end
        local latency_text = ' | delay: '..math.floor(latency*1000).."ms"
    else
        latency_text = ""
    end
	local nexttext = ('LUFTSTATE.lua [stable] | '..common.get_username()..latency_text.." | "..actual_time)
    local text_size = render.measure_text(1, "", nexttext).x
	render.rect(vector(x-20-text_size, 10), vector(x-12, 28), color(17, 17, 17, 100), 5, true)
    --render.blur(vector(x-20-text_size, 10), vector(x-12, 28), 255, 0.4, 5)
	render.rect_outline(vector(x-21-text_size, 9), vector(x-11, 29), color(solus_color:get().r, solus_color:get().g, solus_color:get().b, 255), 1, 6, true)
    render.text(1, vector(x-12-text_size-3,12), color(255), '', nexttext)
end
end

local iosize = 15
local iosize2 = 18
local iosize3 = 20
local bodyyawn = ''
local gradsize = 0

local function antiaimsolus()
	if globals.is_in_game then
    if solus_windows:get(3) and vis_enable:get() then
    local bodyyaw = entity.get_local_player().m_flPoseParameter[11] * 120 - 60
    if bodyyaw < 0 then bodyyaw = bodyyaw * -1 end
    bodyyaw = math.floor(bodyyaw*10)/10
    local frametime = globals.frametime * 16
    local dtstate = refs.dt:get() and " | SHIFTING" or ""
    if globals.tickcount%11 == 5 then
	    nexttext = globals.choked_commands
        bodyyawn = bodyyaw
    else
        nexttext = nexttext
        bodyyawn = bodyyawn
    end
    local text_size = render.measure_text(1, "", "FL:  "..nexttext..dtstate)
    local text2_size = render.measure_text(1, "", "FAKE ("..bodyyawn.."Â°)")
    gradsize = lerpx(frametime, gradsize, math.min(bodyyaw/6, 7))
    iosize = lerpx(frametime*2, iosize, text_size.x)
    iosize2 = lerpx(frametime*2, iosize2, text2_size.x)
	render.rect(vector(x-21-iosize, 38), vector(x-12, 56), color(17, 17, 17, 100), 5, true)
	render.rect_outline(vector(x-22-iosize, 37), vector(x-11, 57), color(solus_color:get().r, solus_color:get().g, solus_color:get().b, 255), 1, 6, true)
    render.text(1, vector(x-13-iosize-3,40), color(255, (text_size.x/iosize)*255), '', "FL:  "..nexttext..dtstate)
    render.text(1, vector(x-13-iosize-11-iosize2, 40), color(255, (text2_size.x/iosize2)*255), '', "FAKE ("..bodyyawn.."Â°)")
    render.gradient(vector(x-17-iosize-11-iosize2, 47), vector(x-15-iosize-11-iosize2, 47+gradsize), color(10, 215, 10, 255), color(10, 215, 10, 255), color(10, 215, 10, 40), color(10, 215, 10, 40))
    render.gradient(vector(x-17-iosize-11-iosize2, 47), vector(x-15-iosize-11-iosize2, 47-gradsize), color(10, 215, 10, 255), color(10, 215, 10, 255), color(10, 215, 10, 40), color(10, 215, 10, 40))
end
end
end

function keybinds()
    if solus_windows:get(2) and vis_enable:get() then
    local x_k, y_k = pos_x:get(), pos_y:get()
    local max_width = 0
    local frametime = globals.frametime * 16
    local add_y = 0
    local total_width = 66
    local active_binds = {}
   local binds = ui.get_binds()
   for i = 1, #binds do local bind = binds[i] 
        local bind_state_size = render.measure_text(1, "", bind_mode(bind.mode))
        local bind_name_size = render.measure_text(1, "", bind.name)
		if data_k[bind.name] == nil then data_k[bind.name] = {alpha_k = 0} end
		data_k[bind.name].alpha_k = lerpx(frametime, data_k[bind.name].alpha_k, (bind.active and 255 or 0))

        --render.text(1, vector(x_k+4, y_k + 21 + add_y), color(0, 0, 0, data_k[bind.name].alpha_k), '', bind.name)
        --render.text(1, vector(x_k+1 + (width_ka - bind_state_size.x - 8), y_k + 21 + add_y), color(0, data_k[bind.name].alpha_k), '['..bind_mode(bind.mode)..']')

        render.text(1, vector(x_k+3, y_k + 20 + add_y), color(255, data_k[bind.name].alpha_k), '', bind.name)
        render.text(1, vector(x_k + (width_ka - bind_state_size.x- 8), y_k + 20 + add_y), color(255, data_k[bind.name].alpha_k), '',  '['..bind_mode(bind.mode)..']')

        add_y = add_y + 16 * data_k[bind.name].alpha_k/255

        
        local width_k = bind_state_size.x + bind_name_size.x + 18
        if width_k > width_value:get()-11 then
            if width_k > max_width then
                max_width = width_k
            end
        end
        if binds.active then
            table.insert(active_binds, binds)
        end
    end
    alpha_k = lerpx(frametime, alpha_k, (ui.get_alpha() > 0 or add_y > 0) and 1 or 0)
    width_ka = lerpx(frametime,width_ka, math.max(max_width, width_value:get()-11))
	if ui.get_alpha()>0 or add_y > 6 then alphabinds = lerpx(frametime, alphabinds, math.max(ui.get_alpha()*255, (add_y > 1 and 255 or 0)))
	elseif add_y < 15.99 and ui.get_alpha() == 0 then alphabinds = lerpx(frametime, alphabinds, 0) end
    if ui.get_alpha() or #active_binds > 0 then
        daun(x_k, y_k, width_ka, 16, 'keybinds', alphabinds)

        local mouse_position = ui.get_mouse_position()
        if common.is_button_down(0x01) and ui.get_alpha() > 0 then
            if dragging == false and is_in_bounds(vector(pos_x:get(), pos_y:get()), vector(pos_x:get() + width_ka, pos_y:get()+16), mouse_position) == true then
                drag_offset.x = mouse_position.x - pos_x:get()
                drag_offset.y = mouse_position.y - pos_y:get()
                dragging = true
            end
            if dragging == true then
                pos_x:set(mouse_position.x - drag_offset.x)
                pos_y:set(mouse_position.y - drag_offset.y)
            end
        else
            dragging = false
        end
    end
end
end

local function customscope()
    if not custom_scope:get() then return end
    if not entity.get_local_player() then return end
    if not entity.get_local_player():is_alive() then return end
    local r, g, b, a = custom_scope_color:get().r, custom_scope_color:get().b, custom_scope_color:get().g, custom_scope_color:get().a
    local inverted = custom_scope_inverted:get()
    ui.find("Visuals", "World", "Main", "Override Zoom", "Scope Overlay"):set("Remove All")
    if entity.get_local_player().m_bIsScoped then
        render.gradient(vector(x/2 + custom_scope_gap:get() + 1, y/2), vector(x/2 + custom_scope_gap:get() + custom_scope_size:get() + 1, y/2+1), color(r, g, b, not inverted and a or 0), color(r, g, b, inverted and a or 0), color(r, g, b, not inverted and a or 0), color(r, g, b, inverted and a or 0)) --right
        render.gradient(vector(x/2 - custom_scope_gap:get(), y/2), vector(x/2 - custom_scope_gap:get() - custom_scope_size:get(), y/2+1), color(r, g, b, not inverted and a or 0), color(r, g, b, inverted and a or 0), color(r, g, b, not inverted and a or 0), color(r, g, b, inverted and a or 0)) --left
        render.gradient(vector(x/2, y/2-custom_scope_gap:get()), vector(x/2+1, y/2 - custom_scope_gap:get() - custom_scope_size:get()), color(r, g, b, not inverted and a or 0), color(r, g, b, not inverted and a or 0), color(r, g, b, inverted and a or 0), color(r, g, b, inverted and a or 0)) --up
        render.gradient(vector(x/2, y/2+custom_scope_gap:get() + 1), vector(x/2+1, y/2 + custom_scope_gap:get() + custom_scope_size:get() + 1), color(r, g, b, not inverted and a or 0), color(r, g, b, not inverted and a or 0), color(r, g, b, inverted and a or 0), color(r, g, b, inverted and a or 0)) --down
    end
end
local function cshm()
    alp = alp - 14
    if crosshm:get() and crosshm:get() then
    render.line(vector(x/2 - 9, y/2 - 9), vector(x/2 - 4, y/2 - 4), color(255, alp))
    render.line(vector(x/2 - 9, y/2 + 9), vector(x/2 - 4, y/2 + 4), color(255, alp))
    render.line(vector(x/2 + 9, y/2 + 9), vector(x/2 + 4, y/2 + 4), color(255, alp))
    render.line(vector(x/2 + 9, y/2 - 9), vector(x/2 + 4, y/2 - 4), color(255, alp))
    end
end

local function visuals_func()
    customscope()
    watermark()
    keybinds()
    antiaimsolus()
	if x78 > 128 and x79 == 1 then x78 = x78 - 3 if x78 == 129 then x79 = 0 end end if x78 > 128 and x79 == 0 then x78 = x78 + 3 if x78 == 255 then x79 = 1 end end
	if entity.get_local_player() then
    cshm()
	local bodyyaw = entity.get_local_player().m_flPoseParameter[11] * 120 - 60
	if dtfl:get() and (state() > 4) then
		ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"):override("Always On")
	else
		ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"):override(ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"):get())
	end

    if debugpanel:get() and debugpanel:get() then
	render.text(1, vector(15, y/2-17), color(), nil, ">LUFTSTATE.lua - \a"..color(inds_color:get().r, inds_color:get().g, inds_color:get().b, 255):to_hex()..common.get_username())
	render.text(1, vector(15, y/2-6), color(), nil, ">Version: \a"..color(169, 172, 255, x78):to_hex()..version)
	render.text(1, vector(15, y/2+5), color(), nil, ">desync range: \aA9ACFFFF"..math.floor(bodyyaw))
	render.text(1, vector(15, y/2+16), color(), nil, ">player conditional: \aA9ACFFFF"..state_string[state()])
	end
	end
	if solus_windows:get(2) then end
	if ar:get() then cvar.r_aspectratio:float(aspectslider:get()/100) end
    if not entity.get_local_player() then return end
    if not entity.get_local_player():is_alive() then return end
	local bodyyaw = entity.get_local_player().m_flPoseParameter[11] * 120 - 60
    if bodyyaw < 0 then angle = bodyyaw*-1 else angle = bodyyaw end
    local alpha = math.max(math.floor(math.sin((globals.realtime%4)*1)*255+25.5),55)
    local e = 0
    local dmg = false
    local binds = ui.get_binds()
    for i = 1, #binds do local bind = binds[i] if bind.name == "Minimum Damage" then dmg = true end end
    if cross_inds:get() then   
        if inds_style:get() == "Modern" then
            render.text(2, vector(x/2+1,y/2+30), color(inds_color:get().r, inds_color:get().g, inds_color:get().b, 255), 'c', string.upper("LUFTSTATE"))
            render.text(2, vector(x/2+1,y/2+40), color(inds_color:get().r, inds_color:get().g, inds_color:get().b, 255), 'c', round(bodyyaw, 1)..'Â°')
            if refs.dt:get() then render.text(2, vector(x/2+1,y/2+50+e), (rage.exploit:get() == 1 and color(255, 255, 255, 255) or color(255, 0, 0, 255)), 'c', 'DT') e = e + 10 end
            if refs.os_aa:get() and not refs.dt:get() then render.text(2, vector(x/2+1,y/2+50+e), color(255, 255, 255, 255), 'c', 'OS') e = e + 10 end
            if dmg then render.text(2, vector(x/2+1,y/2+50+e), color(255, 255, 255, 255), 'c', 'DMG') e = e + 10 end
        end
        if inds_style:get() == "Default" then
            render.text(2, vector(x/2+3, y/2+29), color(255, 255, 255, 255), '', 'LUFTSTATE')  
            render.text(2, vector(x/2+3+render.measure_text(2, 'o', 'LUFTSTATE').x+1, y/2+29), color(inds_color:get().r, inds_color:get().g, inds_color:get().b, alpha), '', string.upper(version))
            render.rect_outline(vector(x/2+3, y/2+40), vector(x/2+4+render.measure_text(2, 'o', 'LUFTSTATE'..string.upper(version)).x+1, y/2+45), color(0, 0, 0, 255))
            render.rect(vector(x/2+3, y/2+41), vector(x/2+4+render.measure_text(2, 'o', 'LUFTSTATE'..string.upper(version)).x+1, y/2+44), color(0, 0, 0, 155))
            render.gradient(vector(x/2+4, y/2+41), vector(x/2+4+angle, y/2+44), color(inds_color:get().r, inds_color:get().g, inds_color:get().b, 255), color(inds_color:get().r, inds_color:get().g, inds_color:get().b, 0), color(inds_color:get().r, inds_color:get().g, inds_color:get().b, 255), color(inds_color:get().r, inds_color:get().g, inds_color:get().b, 0))
            render.text(2, vector(x/2+3, y/2+43), color(inds_color:get().r, inds_color:get().g, inds_color:get().b, 255), '', (refs.fd:get() and "FAKEDUCK" or string.upper(states[state()])))
            if refs.dt:get() then render.text(2, vector(x/2+3,y/2+52+e), color(255, rage.exploit:get()*255, rage.exploit:get()*255, 255), '', 'DOUBLETAP') e = e + 9 end
            if dmg then render.text(2, vector(x/2+3,y/2+52+e), color(255, 255, 255, 255), '', 'DAMAGE') e = e + 9 end
            if refs.os_aa:get() and not refs.dt:get() then render.text(2, vector(x/2+3,y/2+52+e), color(255, 255, 255, 255), '', 'ONSHOT') e = e + 9 end
        end
    end
		if tsarrows:get() then
            render.poly(color(manual:get() == " Left" and aa_enable:get() and inds_color:get().r or 35, manual:get() == " Left" and aa_enable:get() and inds_color:get().g or 35, manual:get() == " Left" and aa_enable:get() and inds_color:get().b or 35, manual:get() == " Left" and aa_enable:get() and 255 or 150), vector(x / 2 - 55, y / 2 + 2), vector(x / 2 - 42, y / 2 - 7), vector(x / 2 - 42, y / 2 + 11))
            render.poly(color(manual:get() == " Right" and aa_enable:get() and inds_color:get().r or 35, manual:get() == " Right" and aa_enable:get() and inds_color:get().g or 35, manual:get() == " Right" and aa_enable:get() and inds_color:get().b or 35, manual:get() == " Right" and aa_enable:get() and 255 or 150), vector(x / 2 + 55, y / 2 + 2), vector(x / 2 + 42, y / 2 - 7), vector(x / 2 + 42, y / 2 + 11))
            render.rect(vector(x / 2 + 38, y / 2 - 7), vector(x / 2 + 38 + 2, y / 2 - 7 + 18), color(bodyyaw > 0 and inds_color:get().r or 35, bodyyaw > 0 and inds_color:get().g or 35, bodyyaw > 0 and inds_color:get().b or 35, bodyyaw > 0 and 255 or 150))
            render.rect(vector(x / 2 - 40, y / 2 - 7), vector(x / 2 - 40 + 2, y / 2 - 7 + 18), color(bodyyaw < 0 and inds_color:get().r or 35, bodyyaw < 0 and inds_color:get().g or 35, bodyyaw < 0 and inds_color:get().b or 35, bodyyaw < 0 and 255 or 150))
        end
end

local ffi = require("ffi")
ffi.cdef[[
    typedef uintptr_t (__thiscall* GetClientEntity_4242425_t)(void*, int);
    typedef int(__fastcall* clantag_t)(const char*, const char*);
    bool DeleteUrlCacheEntryA(const char* lpszUrlName);
    void* __stdcall URLDownloadToFileA(void* LPUNKNOWN, const char* LPCSTR, const char* LPCSTR2, int a, int LPBINDSTATUSCALLBACK);
    void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
    bool CreateDirectoryA(const char* lpPathName, void* lpSecurityAttributes);
    void* __stdcall URLDownloadToFileA(void* LPUNKNOWN, const char* LPCSTR, const char* LPCSTR2, int a, int LPBINDSTATUSCALLBACK); 
    typedef struct {
        unsigned short wYear;
        unsigned short wMonth;
        unsigned short wDayOfWeek;
        unsigned short wDay;
        unsigned short wHour;
        unsigned short wMinute;
        unsigned short wMilliseconds;
    } SYSTEMTIME, *LPSYSTEMTIME;
    void GetSystemTime(LPSYSTEMTIME lpSystemTime);
    void GetLocalTime(LPSYSTEMTIME lpSystemTime);
]]

local _set_clantag = ffi.cast('int(__fastcall*)(const char*, const char*)', utils.opcode_scan('engine.dll', '53 56 57 8B DA 8B F9 FF 15'))
local _last_clantag = nil
local set_clantag = function(v)
  if v == _last_clantag then return end
  _set_clantag(v, v)
  _last_clantag = v
end

local function clantag()
    if ct:get() then
        local tag =
        {
            "g",
            "ga",
            "gam",
            "game",
            "games",
            "gamese",
            "gamesen",
            "gamesens",
            "gamesense",
            "gamesens",
            "gamesen",
            "gamese",
            "games",
            "game",
            "gam",
            "ga",
            "g",

        }

        if not globals.is_connected then return end

        local netchann_info = utils.net_channel()
        if netchann_info == nil then return end
    
        local latency = netchann_info.latency[0] / globals.tickinterval
        local tickcount_pred = globals.tickcount + latency
        local iter = math.floor(math.fmod(tickcount_pred / 32, #tag + 1) + 1)
        if entity.get_game_rules()['m_gamePhase'] == 16 then
            set_clantag("LUFTSTATE.lua")
        else
            set_clantag(tag[iter])
        end
    else
        set_clantag("")    
    end
end

local a_width = 0
local vpos_x = visualstab:slider("vdrag_offset", 0, x, x / 2 - 82):visibility(false)
local vpos_y = visualstab:slider("vdragging", 0, y, y / 2 - 200):visibility(false)

local function velocity_modifier()
    local local_player = entity.get_local_player()
    if not local_player then
        return
    end

    if not local_player:is_alive() then
        return
    end
    if velocity_ind:get() then
        local velocity_warning_color = velocity_ind_col:get()

        local modifier_vel = local_player.m_flVelocityModifier + 0.01
        if ui.get_alpha() == 1 then
            modifier_vel = local_player.m_flVelocityModifier
        end
        if modifier_vel == 1.01 then return end

        local text_vel = string.format('Slowed down %.0f%%', math.floor(modifier_vel*100))
        local text_width_vel = 95

        a_width = lerpx(globals.frametime * 8, a_width, math.floor((text_width_vel - 2) * modifier_vel))

        local xv, yv = vpos_x:get(), vpos_y:get()
      
        render.text(1, vector(xv+55+11, yv+4), velocity_warning_color, nil, text_vel)

        render.rect(vector(xv+55, yv+17+4), vector(xv+165+20, yv+31), color(25, 25, 25, 200))
        render.rect(vector(xv+56, yv+18+4), vector(xv+65+(a_width*1.2 + 7), yv+30), velocity_warning_color)
      
        render.rect_outline(vector(xv+55, yv+17+4), vector(xv+165+20, yv+31), color(55, 55, 55, 200))
      
        if common.is_button_down(0x01) and ui.get_alpha() == 1 then
            local mouse_position = ui.get_mouse_position()
            if dragging == false and vdragging == false and is_in_bounds(vector(vpos_x:get(), vpos_y:get()-10), vector(vpos_x:get()+185, vpos_y:get()+31), mouse_position) == true then
                vdrag_offset.x = mouse_position.x - vpos_x:get()
                vdrag_offset.y = mouse_position.y - vpos_y:get()
                vdragging = true
            end
            if vdragging == true then
                vpos_x:set(mouse_position.x - vdrag_offset.x)
                vpos_y:set(mouse_position.y - vdrag_offset.y)
            end
        else
            vdragging = false
        end
    end
end

--[[local function auto_teleport()
    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local active_weapon = localplayer:get_player_weapon()
    if not active_weapon then return end

    local classname = active_weapon:get_classname()
    if not classname then return end

    if not globals.is_connected and not localplayer:is_alive() then return end

    local is_active = function()
        local table = {"Default", "Pistols", "Heavy pistols", "Scout", "AWP", "Autosnipers", "Nades"}
        for i = 1, #table do
            local directory = menu_database.handler.elements["Breaking lagcomp weapons"]
            if bit.band(directory, bit.lshift(1, i - 1)) ~= 0 then
                local current_weapon = table[i]

                if active_weapon:IsPistol() then
                    if current_weapon == "Heavy pistols" and classname == "CDEagle" then
                        return true
                    elseif current_weapon == "Pistols" and classname ~= "CDEagle" then
                        return true
                    end
                elseif classname == "CWeaponSSG08" and current_weapon == "Scout" then
                    return true
                elseif classname == "CWeaponAWP" and current_weapon == "AWP" then
                    return true
                elseif (
                    classname == "CWeaponSCAR20" or
                    classname == "CWeaponG3SG1"
                ) and current_weapon == "Autosnipers" then
                    return true
                elseif current_weapon == "Nades" and active_weapon:IsGrenade() then
                    return true
                elseif current_weapon == "Default" and active_weapon:IsRifle() then
                    return true
                end
            end
        end
        return false
    end

end]]

events.render:set(function()
    
    velocity_modifier()
    clantag()
    setup_menu() 
    visuals_func()
end)

events.round_start:set(function(e)
    miss_counter = 0
    shot_time = 0
    if aimlogs:get(2) and aimlogs:get() then
        notify:push(4, "New round start")
    end
end)
			
events.player_death:set(function(e)
    local localplayer = entity.get_local_player()
    local victim = entity.get(e.userid, true)
    local attacker = entity.get(e.attacker, true)
				
	if attacker == localplayer then 
		if tt:get()then
			utils.console_exec("say "..(trashtalk[utils.random_int(1, #trashtalk)]))
		end
	end

    if victim ~= localplayer then return end

    miss_counter = 0
    shot_time = 0
    if aimlogs:get(1) and aimlogs:get() then
        notify:push(4, "Reset due to player death")
    end
end)
			
events.render:set(function()
    setup_menu() 
    visuals_func()
end)

events.round_start:set(function(e)
    miss_counter = 0
    shot_time = 0
    if aimlogs:get(2) and aimlogs:get() then
        notify:push(4, "New round start")
    end
end)
			
events.player_death:set(function(e)
    local localplayer = entity.get_local_player()
    local victim = entity.get(e.userid, true)
    local attacker = entity.get(e.attacker, true)
				
	if attacker == localplayer then 
		if tt:get()then
			utils.console_exec("say "..(trashtalk[utils.random_int(1, #trashtalk)]))
		end
	end

    if victim ~= localplayer then return end

    miss_counter = 0
    shot_time = 0
    if aimlogs:get(1) and aimlogs:get() then
        notify:push(4, "Reset due to player death")
    end
end)
			
events.player_hurt:set(function(e)
    	local localplayer = entity.get_local_player()
        local target = entity.get(e.userid, true)
        local attacker = entity.get(e.attacker, true)
        local weapon = e.weapon
        local target_name = target:get_name()
        local dmg = e.dmg_health
        local health = e.health
        local isgrenadeorknife = 0
        if weapon == "knife" then
            text = string.format("Knifed %s for %s damage (%s remaining)", target_name, dmg, health)
            isgrenadeorknife = 1
        elseif weapon == "hegrenade" then
            text = string.format("Naded %s for %s damage (%s remaining)", target_name, dmg, health)
            isgrenadeorknife = 1
        elseif weapon == "inferno" then
            text = string.format("Burned %s for %s damage (%s remaining)", target_name, dmg, health)
            isgrenadeorknife = 1
        else
            isgrenadeorknife = 0
        end
        if attacker == localplayer then
            disableTime = globals.curtime + 0.3
            hitmarkerTime = 0.3
            alp = 350
            if aimlogs:get(1) and aimlogs:get() and isgrenadeorknife == 1 then
                notify:push(4, text)
            end
			if alllogs:get() and vis_enable:get() and isgrenadeorknife == 1 then
				print_raw("\aFFFFFF[\a95B806LUFTSTATE\aFFFFFF] "..text)		
			end
            if alllogs:get() and onscreen:get() and vis_enable:get() and isgrenadeorknife== 1 then
				print_dev(text)		
			end
        end
    end)					
				
events.aim_ack:set(function(e)
	local postfix = ""
	local postfixmiss = ""
    local postfixsc = ""
	local postfixmisssc = ""
	if hit_count%10 == 1 then postfix = "\aFFFFFFst" postfixsc = "st" elseif hit_count%10 == 2 then postfix = "\aFFFFFFnd" postfixsc = "nd" elseif hit_count%10 == 3 then postfix = "\aFFFFFFrd" postfixsc = "rd" else postfix = "\aFFFFFFth" postfixsc = "th" end
	if miss_count%10 == 1 then postfixmiss = "\aFFFFFFst" postfixmisssc = "st" elseif miss_count%10 == 2 then postfixmiss = "\aFFFFFFnd" postfixmisssc = "nd" elseif miss_count%10 == 3 then postfixmiss = "\aFFFFFFrd" postfixmisssc = "rd" else postfixmiss = "\aFFFFFFth" postfixmisssc = "th" end
	local dt = (refs.dt:get() and 1 or 0)
	local hs = (refs.os_aa:get() and 1 or 0)
	local safety = math.random(0, 1)
    if not e.target then return end
    if not e.target.m_flPoseParameter then return end
	if e.state == nil then
        if alllogs:get() and vis_enable:get() then
            print_raw("\aFFFFFF[\a95B806LUFTSTATE\aFFFFFF] Registered "..hit_count, postfix.."\aFFFFFF shot in ".. e.target:get_name().."\aFFFFFF's "..hitboxes[e.hitgroup].."\aFFFFFF for "..e.damage.."\aFFFFFF [angle: "..round(e.target.m_flPoseParameter[11] * 120 - 60, 2).."\aFFFFFFÂ°] (hitchance: "..e.hitchance.."\aFFFFFF% | safety: "..safety.."\aFFFFFF | history(Î”): " ..e.backtrack.."\aFFFFFF | flags: " ..dt..hs..safety.."\aFFFFFF )")
            if alllogs:get() and vis_enable:get() and onscreen:get() then
                print_dev("[LUFTSTATE] Registered "..hit_count, postfixsc.." shot in "..e.target:get_name().."'s "..hitboxes[e.hitgroup].." for "..e.damage.." [angle: "..round(e.target.m_flPoseParameter[11] * 120 - 60, 2).."Â°] (hitchance: "..e.hitchance.."% | safety: "..safety.." | history(Î”): "..e.backtrack.." | flags: "..dt..hs..safety.." )")
            end
            hit_count = hit_count + 1
        end
    else
        if alllogs:get() and vis_enable:get() then
            print_raw("\aFFFFFF[\aFF0000LUFTSTATE\aFFFFFF] Missed "..miss_count, postfixmiss.. " shot in "..e.target:get_name().."\aFFFFFF's "..hitboxes[e.wanted_hitgroup].."\aFFFFFF due to \aFF0000"..e.state.."\aFFFFFF [angle: "..round(e.target.m_flPoseParameter[11] * 120 - 60, 2).."\aFFFFFFÂ°] (hitchance: "..e.hitchance.."\aFFFFFF% | safety: "..safety.."\aFFFFFF | history(Î”): "..e.backtrack.."\aFFFFFF | flags: "..dt..hs..safety.."\aFFFFFF )")
            if alllogs:get() and vis_enable:get() and onscreen:get() then
                print_dev("[LUFTSTATE] Missed "..miss_count, postfixmisssc.. " shot in "..e.target:get_name().."'s "..hitboxes[e.wanted_hitgroup].." due to "..e.state.." [angle: "..round(e.target.m_flPoseParameter[11] * 120 - 60, 2).."Â°] (hitchance: "..e.hitchance.."% | safety: "..safety.." | history(Î”): "..e.backtrack.." | flags: "..dt..hs..safety.." )")
            end
            miss_count = miss_count + 1
        end
    end
end)
			

events.createmove:set(function(cmd)
    antiaim_func(cmd)
end)

local function str_to_sub(text, sep)
	local t = {}
	for str in string.gmatch(text, "([^"..sep.."]+)") do
		t[#t + 1] = string.gsub(str, "\n", " ")
	end
	return t
end

local function to_boolean(str)
	if str == "true" or str == "false" then
		return (str == "true")
	else
		return str
    end
end

export_cfg:set_callback(function()
    local str = ""

	local str = tostring(common.get_username()).."|"
    ..tostring(aa_enable:get()).."|"
    for i = 1, 6 do
        str = str..tostring(antiaim[i].yaw_add_left:get()).."|"
        ..tostring(antiaim[i].yaw_add_right:get()).."|"
        ..tostring(antiaim[i].yaw_mod:get()).."|"
        ..tostring(antiaim[i].mod_deg:get()).."|"
        ..tostring(antiaim[i].fake_limit_type:get()).."|"
        ..tostring(antiaim[i].left_limit:get()).."|"
        ..tostring(antiaim[i].right_limit:get()).."|"
        ..json.stringify(antiaim[i].options:get()).."|"
        ..tostring(antiaim[i].fs_desync:get()).."|"
        ..tostring(antiaim[i].dsy_onshot:get()).."|"
        ..tostring(antiaim[i].lby_mode:get()).."|"
    end
    clipboard.set("LUFTSTATE_"..base64.encode(str))
    common.add_notify("LUFTSTATE.lua", "Saved config to clipboard")
end)

import_cfg:set_callback(function()
    local protected = function()
        local json_config = clipboard.get():gsub("LUFTSTATE_", "")
        json_config = base64.decode(json_config)
        local tbl = str_to_sub(json_config, "|")

        aa_enable:set(to_boolean(tbl[2]))

        for i = 1, 6 do
            antiaim[i].yaw_add_left:set(tonumber(tbl[3 + (11 * (i-1))]))
            antiaim[i].yaw_add_right:set(tonumber(tbl[4 + (11 * (i-1))]))
            antiaim[i].yaw_mod:set(tbl[5 + (11 * (i-1))])
            antiaim[i].mod_deg:set(tonumber(tbl[6 + (11 * (i-1))]))
            antiaim[i].fake_limit_type:set(tbl[7 + (11 * (i-1))])
            antiaim[i].left_limit:set(tonumber(tbl[8 + (11 * (i-1))]))
            antiaim[i].right_limit:set(tonumber(tbl[9 + (11 * (i-1))]))
            antiaim[i].options:set(json.parse(tbl[10 + (11 * (i-1))]) ~= nil and json.parse(tbl[10 + (11 * (i-1))]) or { })
            antiaim[i].fs_desync:set(tbl[11 + (11 * (i-1))])
            antiaim[i].dsy_onshot:set(tbl[12 + (11 * (i-1))])
            antiaim[i].lby_mode:set(tbl[13 + (11 * (i-1))])
        end
        common.add_notify("LUFTSTATE.lua", "Loaded config by "..tbl[1])
    end

    local status, message = pcall(protected)

    if not status then
        common.add_notify("LUFTSTATE.lua", "Failed to load config")
        print(status)
        return
    end
    
end)