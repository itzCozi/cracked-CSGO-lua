---@diagnostic disable: undefined-global
local inspect = require("neverlose/inspect")
local print = function(...)
    local text = {...}
    local new_text = {}
    if type(...) ~= 'boolean' and type(...) ~= 'number' and type(...) ~= 'string' then
        text = inspect(...)
    else
        for i = 1, #text do
            new_text[i] = tostring(text[i])
        end
        text = table.concat(new_text, ", ")
    end
    print_raw('\aB6E717FF[gamesense]\aD9D9D9FF '..text)
end
local brenderer = require("neverlose/renderer")
local renderer = require("neverlose/b_renderer")

local legsSaved = false
local legsTypes = {[1] = 0.1, [2] = 0.5, [3] = 1}
local ground_ticks = 0

local globals = {
    chocked_commands = function()
        return globals.chocked_commands
    end,
    curtime = function()
        return globals.curtime
    end,
    realtime = function()
        return globals.realtime
    end,
    frametime = function()
        return globals.frametime
    end,
    framecount = function()
        return globals.framecount
    end,
    absoluteframetime = function()
        return globals.absoluteframetime
    end,
    tickcount = function()
        return globals.tickcount
    end,
    tickinterval = function()
        return globals.tickinterval
    end,
    maxplayers = function()
        return globals.max_players
    end,
    is_connected = function()
        return globals.is_connected
    end,
    is_in_game = function()
        return globals.is_in_game
    end,
    choked_commands = function()
        return globals.choked_commands
    end,
    commandack = function()
        return globals.commandack
    end,
    commandack_prev = function()
        return globals.commandack_prev
    end,
    last_outgoing_command = function()
        return globals.last_outgoing_command
    end,
    server_tick = function()
        return globals.server_tick
    end,
    client_tick = function()
        return globals.client_tick
    end,
    delta_tick = function()
        return globals.delta_tick
    end,
    clock_offset = function()
        return globals.clock_offset
    end,
	mapname = function()
		if not common.get_map_data() then return nil else return common.get_map_data().shortname end
	end
}

globals.helpers = {
    class = function ()
        local class = {}
        local m_class = {__index = class}

        function class.instance() return setmetatable({}, m_class) end
        return class
    end
}

local client = globals.helpers.class()
client.create_interface = utils.create_interface
client.screen_size = function()
    return render.screen_size():unpack()
end
client.key_state = function(code)
    return common.is_button_down(code)
end
client.system_time = function()
    return common.get_date("%H"), common.get_date("%M"), common.get_date("%S")
end
client.latency = function(id)
    id = id or 1
    local net_channel = utils.net_channel()
    if net_channel == nil then
        return
    end
    return net_channel.latency[id] or 0
end

client.random_int = function(int1, int2)
    return utils.random_int(int1, int2)
end
client.random_float = function(int1, int2)
    return utils.random_float(int1, int2)
end
client.set_event_callback = function(callback_name, fn)
    local callback_names = {
        ["run_command"] = 'createmove_run',
        ["predict_command"] = 'createmove',
        ["paint_ui"] = 'render',
        ["setup_command"] = 'createmove',
        ["paint"] = 'render',
        ["aim_miss"] = 'aim_ack',
        ["aim_hit"] = 'aim_ack'
    }

    callback_name = callback_names[callback_name] == nil and callback_name or callback_names[callback_name]
    return events[callback_name]:set(fn)
end
client.unset_event_callback = function(callback_name, fn)
    local callback_names = {
        ["run_command"] = 'createmove_run',
        ["predict_command"] = 'createmove',
        ["paint_ui"] = 'render',
        ["setup_command"] = 'createmove',
        ["paint"] = 'render',
        ["aim_miss"] = 'aim_ack',
        ["aim_hit"] = 'aim_ack'
    }
    callback_name = callback_names[callback_name] == nil and callback_name or callback_names[callback_name]
    return events[callback_name]:unset(fn)
end
client.timestamp = function()
    return common.get_timestamp()
end
client.find_signature = function(module, signature)
    return utils.opcode_scan(module, signature)
end
client.eye_position = function()
    return entity.get_local_player():get_eye_position():unpack()
end
client.camera_angles = function(pitch, yaw)
	if pitch ~= nil then
    	return render.camera_angles(vector(pitch, yaw))
	else
		return render.camera_angles():unpack()
	end
end

client.camera_position = function()
    return render.camera_position():unpack()
end

client.current_threat = function()
    return entity.get_threat()
end

client.trace_bullet = function(ent, x1, y1, z1, x2, y2, z2, skip)
    if type(ent) == "number" then
        ent = entity.get(ent)
    end
    if ent == nil then return end
    local damage, trace = utils.trace_bullet(ent, vector(x1, y1, z1), vector(x2, y2, z2), skip)
    return trace, damage
end

client.trace_line = function(skip, x1, y1, z1, x2, y2, z2, mask)
    local trace = utils.trace_line(vector(x1, y1, z1), vector(x2, y2, z2), skip, mask)
    return trace.fraction, trace.entity, trace.end_pos
end
client.userid_to_entindex = function(userid)
    return entity.get(userid, true)
end

client.log = function(...)
    return print_raw('\aB6E717[gamesense]\aD9D9D9 '..(...)), print_dev(...)
end
client.exec = utils.console_exec
client.error_log = function(...)
    client.exec("play resource/warning.wav")
    return print_raw('\aB6E717[gamesense]\aFF2323 '..(...)), print_dev(...)
end
client.delay_call = function(delay, callback, ...)
    return utils.execute_after(delay, callback, ...)
end

entity.get_classname = function(ent)
    if type(ent) == "number" then
        ent = entity.get(ent)
    end
    if ent == nil then return end
    return ent:get_classname()
end
entity.get_player_name = function(ent)
    if type(ent) == "number" then
        ent = entity.get(ent)
    end
    if ent == nil then return end
    return ent:get_name()
end
entity.get_player_weapon = function(ent)
    if type(ent) == "number" then
        ent = entity.get(ent)
    end
    if ent == nil then return end
    return ent:get_player_weapon()
end
entity.get_player_resource = function()
    for ent_idx = 1, 64 do
        local ent = entity.get(ent_idx)

        if ent == nil then return end
        return ent:get_resource()
    end
end
entity.get_prop = function(ent, prop_name, idx)
    if type(ent) == "number" then
        ent = entity.get(ent)
    end
    if not ent or ent == nil then 
        return 
    end
	if idx ~= nil then
        if type(ent[prop_name][idx]) == 'userdata' then
            if ent[prop_name][idx]['x'] ~= nil and ent[prop_name][idx]['y'] ~= nil then
                return ent[prop_name][idx]:unpack()
            end
        end
        local l = ent[prop_name][idx]
        return type(l) == 'boolean' and (l and 1 or 0) or l
    else
        if type(ent[prop_name]) == 'userdata' then
            if ent[prop_name]['x'] ~= nil and ent[prop_name]['y'] ~= nil then
                return ent[prop_name]:unpack()
            end
        end
        return prop_name == 'm_iItemDefinitionIndex' and bit.band(ent["m_iItemDefinitionIndex"], 0xFFFF) or type(ent[prop_name]) == 'boolean' and (ent[prop_name] and 1 or 0) or ent[prop_name]
    end
end
entity.set_prop = function(ent, prop_name, value)
    if type(ent) == "number" then
        ent = entity.get(ent)
    end
    if ent == nil then return end
    ent[prop_name] = value
end
entity.is_alive = function(ent)
    if type(ent) == "number" then
        ent = entity.get(ent)
    end
    if ent == nil then return end
    return ent:is_alive()
end
entity.is_dormant = function(ent)
    if type(ent) == "number" then
        ent = entity.get(ent)
    end
    if ent == nil then return end
    return ent:is_dormant()
end
entity.is_enemy = function(ent)
    if type(ent) == "number" then
        ent = entity.get(ent)
    end
    if ent == nil then return end
    return ent:is_enemy()
end
entity.get_all = function(ent)
    return entity.get_entities(ent)
end
entity.hitbox_position = function(ent, hitbox)
    if type(ent) == "number" then
        ent = entity.get(ent)
    end
    if ent == nil then return end
    return ent:get_hitbox_position(hitbox):unpack()
end
entity.get_origin = function(ent)
    if type(ent) == "number" then
        ent = entity.get(ent)
    end
    if ent == nil then return end
    return ent:get_origin():unpack()
end
entity.get_bounding_box = function(ent)
    if ent:get_bbox().pos1 == nil then return end
    return ent:get_bbox().pos1.x, ent:get_bbox().pos1.y, ent:get_bbox().pos2.x, ent:get_bbox().pos2.y, ent:get_bbox().alpha
end
renderer.default_verdana = 1
renderer.large_verdana = render.load_font('verdana', 33, 'ad')
renderer.bold_verdana = render.load_font('verdana', 12, 'bad')
renderer.large_bold_verdana = render.load_font('verdana', 14, 'abd')

renderer.measure_text = function(flags, ...)
	flags=flags or ''
	local cur_flag = ''
	local font = renderer.default_verdana
	if flags:find('+') then
		font = renderer.large_verdana
	end
	if flags:find('-') then
		font = 2
	end
	if flags:find('c') then
		cur_flag = cur_flag..'c'
	end
	if flags:find('r') then
		cur_flag = cur_flag..'r'
	end
	if flags:find('b') then
		font = renderer.bold_verdana
	end

	if flags:find('b') and flags:find('+') then
		font = renderer.large_bold_verdana
	end

	if flags:find('d') then
		cur_flag = cur_flag..'s'
	end

	return render.measure_text(font, cur_flag, ...):unpack()
end
renderer.blur = function(x,y,w,h,a,o)
    return render.blur(vector(x, y), vector(x+w, y+h), 1, a, o)
end
renderer.renderer_text = renderer.text
renderer.text = function(x, y, r, g, b, a, flags, max_width, ...)
	flags=flags or ''
	local cur_flag = ''
	local font = renderer.default_verdana
	if flags:find('+') then
		font = renderer.large_verdana
	end
	if flags:find('-') then
		font = 2
	end
	if flags:find('c') then
		cur_flag = cur_flag..'c'
	end
	if flags:find('r') then
		cur_flag = cur_flag..'r'
	end
	if flags:find('b') then
		font = renderer.bold_verdana
	end

	if flags:find('b') and flags:find('+') then
		font = renderer.large_bold_verdana
	end

	if flags:find('d') then
		cur_flag = cur_flag..'s'
	end
    
	return render.text(font, vector(x, y), color(r, g, b, a), cur_flag, ...)
	--[[ 
    if flags == '' or flags == nil then
        render.text(1, vector(x, y), color(r,g,b,a), flags, ...)
    elseif flags == 'c' then
        render.text(1, vector(x, y), color(r,g,b,a), flags, ...)
    else
        renderer.renderer_text(x, y, r, g, b, a, flags, max_width, ...)
    end ]]
end
renderer.texture = function(id, x, y, w, h, r, g, b, a, mode)
	return render.texture(id, vector(x, y), vector(w, h), color(r, g, b, a), mode)
end
renderer.world_to_screen = function(x, y, z)
    local world = brenderer.world_to_screen(vector(x, y, z))
    if world ~= nil then
        return world.x, world.y, world.z
    end
end
local renderer_circle = renderer.circle
renderer.circle = function(x, y, r, g, b, a, radius, start_degrees, percentage, ...)
    return renderer_circle(x, y, r, g, b, a, radius, start_degrees-90, percentage, ...)
end
renderer.triangle = function(x0, y0, x1, y1, x2, y2, r, g, b, a)
	return render.poly(color(r, g, b, a), vector(x0, y0), vector(x1, y1), vector(x2, y2))
end
ui.is_menu_open = function()
    return ui.get_alpha() > 0.01
end

local au = {}
local data_db = db.helper123 or { }
local av = data_db
function au.read(aw)
    return av[aw]
end
function au.write(aw, ax)
    av[aw] = ax
end
function au.flush()
    for aw in pairs(av) do
        av[aw] = nil
    end
end
ui.reference = function(...)
    return ui.find(...)
end
ui.override = function(item, value)
    if not item then return end
    item = type(item) == 'userdata' and item or item[1]
    item:override(value)
    pcall(function()
        item:name(value)
    end)
end

ui.set = function(item, value)
    if not item then return end
    item = type(item) == 'userdata' and item or item[1]
	item:set(value)
	pcall(function()
		item:name(value)
	end)
end
ui.update = function(item, value)
	return item:update(value)
end
ui.get = function(element)
    if not element then return end
    element = type(element) == 'userdata' and element or element[1]
    if type(element:get()) == 'userdata' then
        return element:get():unpack()
    else
        return element:get()
    end
end
ui.set_visible = function(element, value)
    return element:visibility(value)
end
ui.name = function(element)
    return element:name()
end
ui.mouse_position = function()
    return ui.get_mouse_position():unpack()
end
ui.set_callback = function(element, fn)
    return element:set_callback(fn)
end
ui.new_label = function(tab, container, name)
    local group = ui.create(tab, container)
    return group:label(name)
end
ui.new_string = function(container, name)
    local group = ui.create('LUA', container)
    return group:label(name):visibility(false)
end
ui.new_checkbox = function(tab, container, name)
    local group = ui.create(tab, container)
    return group:switch(name)
end
ui.new_hotkey = function(tab, container, name, inline, default_hotkey)
    local group = ui.create(tab, container)
    return group:hotkey(name)
end
ui.new_color_picker = function(tab, container, name, r, g, b, a)
    local group = ui.create(tab, container)
    return group:color_picker(name, color(r, g, b, a))
end
ui.new_multiselect = function(tab, container, name, ...)
    local group = ui.create(tab, container)
    return group:selectable(name, ...)
end
ui.new_combobox = function(tab, container, name, ...)
    local group = ui.create(tab, container)
    return group:combo(name, ...)
end
ui.new_slider = function(tab, container, name, min, max, init_value, show_tooltip, unit, scale, tooltips)
    local group = ui.create(tab, container)
    return group:slider(name, min, max, init_value, scale, tooltips == nil and (unit or '') or function(val) if tooltips[val] ~= nil then return tooltips[val] else return val..tostring(unit) end end)
end
ui.new_button = function(tab, container, name, fn)
    local group = ui.create(tab, container)
    return group:button(name, fn)
end

ui.new_listbox = function(tab, container, name, items)
    local group = ui.create(tab, container)
    return group:list(name, unpack(items) == nil and {''} or items)
end
ui.new_textbox = function(tab, container, name)
    local group = ui.create(tab, container)
    return group:input(name)
end

client.old_require = require
local require = function(modname)
    return client.old_require(modname:gsub('gamesense', 'neverlose'))
end

local clipboard = require("gamesense/clipboard")
local slow, key = ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk")
local limitfl = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit")
return (function(z)
    z.items = {
        aa = {
            enabled = z.ref("Aimbot", "Anti Aim", "Angles", "Enabled"),
            pitch = z.ref("Aimbot", "Anti Aim", "Angles", "Pitch"),
            base = z.ref("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"),
            jitter = { ui.reference("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"), ui.reference("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset") },
            yaw = z.ref("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
            body = z.ref("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"),
            fsbody = z.ref("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"),

            bodyleft = ui.reference("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"),
            bodyright = ui.reference("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"),
            --edge = z.ref("aa", "anti-aimbot angles", "edge yaw"),

            legMovement = z.ref("Aimbot", "Anti Aim", "Misc", "Leg Movement"), -- z.items.aa.legMovement
            roll = z.ref("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Roll"),
            fs = z.ref("Aimbot", "Anti Aim", "Angles", "Freestanding")
        },
					keys = { 
						dt = z.ref("Aimbot", "Ragebot", "Main", "Double Tap"),
						mode = z.ref("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"),
						hs = z.ref("Aimbot", "Ragebot", "Main", "Hide Shots"),
						fd = z.ref("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
						sp = z.ref("Aimbot", "Ragebot", "Safety", "Global", "Safe Points"),
						fb = z.ref("Aimbot", "Ragebot", "Safety", "Global", "Body Aim")
					}
    }
    z.hex = function(arg)
        local result = "\a"
        for key, value in next, arg do
            local output = ""
            while value > 0 do
                local index = math.fmod(value, 16) + 1
                value = math.floor(value / 16)
                output = string.sub("0123456789ABCDEF", index, index) .. output 
            end
            if #output == 0 then 
                output = "00" 
            elseif #output == 1 then 
                output = "0" .. output 
            end 
            result = result .. output
        end 
        return result .. "FF"
    end
    z.prefix = {
        section = z.hex({55,55,55}) .. "[" .. z.hex({69, 255, 55}) .. "%s" .. z.hex({55,55,55}) .. "] " .. z.hex({255, 255, 255}) .. "- " .. z.hex({55,55,55}) .. "[" .. z.hex({169,169,169}) .. "%s" .. z.hex({55,55,55}) .. "] " .. z.hex({123,123,123}) .. "%s",
        x = z.hex({69, 255, 55}) .. "LS " .. z.hex({255, 255, 255}) .. "- " .. z.hex({123,123,123}) .. "%s"
    }
    z.item = function(type, args)
        return ui[type]("aa", "anti-aimbot angles", unpack(args))
    end
    z.menu = {
        label = z.item("new_label", {z.prefix.x:format("L U A S E N S E")}),
        select = z.item("new_combobox", {"\n", "Anti Aim", "Keybinds", "Visuals", "Misc", "Cfg"}),
        ["Anti Aim"] = {
            state = z.item("new_combobox", {z.prefix.x:format("State"), z.states}),
            builder = {},
			custom = {}
        },
		["Keybinds"] = {
			left = z.item("new_hotkey", {z.prefix.x:format("Left")}),
			right = z.item("new_hotkey", {z.prefix.x:format("Right")}),
			forward = z.item("new_hotkey", {z.prefix.x:format("Forward")}),
        },
        ["Visuals"] = {
			watermark = z.item("new_combobox", {z.prefix.x:format("Watermark"), {"Right", "Left"}}),
			luacolor = z.item("new_color_picker", {z.prefix.x:format("Lua Color"), 179, 255, 18,255}),
			spaces = z.item("new_checkbox", {z.prefix.x:format("Remove spaces")}),
			indicator = z.item("new_checkbox", {z.prefix.x:format("Indicator")}),
			arrows = z.item("new_checkbox", {z.prefix.x:format("Arrows")}),
			keys = z.item("new_combobox", {"\nArrows", {"b", " ", "+", "ts", "best"}}),
			keycolor = z.item("new_color_picker", {z.prefix.x:format("Key Color"), 55, 55, 55,255}),
			colorkey = z.item("new_color_picker", {z.prefix.x:format("Color Key"), 179, 255, 18,255}),
			center = z.item("new_checkbox", {z.prefix.x:format("Center")}),
			label = z.item("new_label", {z.prefix.x:format("Color")}),
			color = z.item("new_color_picker", {z.prefix.x:format("Color Picker"), 179, 255, 18,255})
        },
		["Misc"] = {
			backstab = z.item("new_checkbox", {z.prefix.x:format("Anti backstab")}),
			hideshot = z.item("new_checkbox", {z.prefix.x:format("Hideshot fix")}),
			disabler = z.item("new_multiselect", {z.prefix.x:format("FS Disablers"), {"Air", "Duck", "Slow"}}),
            animations = z.item("new_multiselect", {z.prefix.x:format("Animations"), "Static legs", "Moonwalk", "Leg fucker", "0 pitch on landing"}),
		},
		["Cfg"] = {
			export = z.item("new_button", {"Export", function()
				local cfg = {}
				for index, value in next, z.menu["Anti Aim"] do
					if type(value) == "table" then
						cfg[index] = {}
						for i, v in next, value do
							if type(v) == "table" then
								cfg[index][i] = {}
								for z, x in next, v do
									if z ~= "button" then
										cfg[index][i][z] = ui.get(x)
									end
								end
							else
								cfg[index][i] = ui.get(v)
							end
						end
					else
						cfg[index] = ui.get(value)
					end
				end
				clipboard.set(json.stringify(cfg))
			end}),
			import = z.item("new_button", {"Import", function()
				--pcall(function()
					local cfg = json.parse(clipboard.get())
                    for index, value in next, z.menu["Anti Aim"] do
						if type(value) == "table" then
							for i, v in next, value do
								if type(v) == "table" then
									for z, x in next, v do
										if z ~= "button" then
											ui.set(x, cfg[index][i][z])
										end
									end
								else
									ui.set(v, cfg[index][i])
								end
							end
						else
							ui.set(value, cfg[index])
						end
					end
				--end)
			end})
		}
    }
    local function movecfg(arg)
        local x = string.find(ui.name(arg), "CT") and "CT" or "T"
        local xxx = string.find(ui.name(arg), "CT") and "T" or "CT"
        local tbl = z.menu["Anti Aim"].builder[ui.get(z.menu["Anti Aim"].state) .. " " .. xxx]
        for i, v in next, z.menu["Anti Aim"].builder[ui.get(z.menu["Anti Aim"].state) .. " " .. x] do
            if i ~= "button" then
                ui.set(v, ui.get(tbl[i]))
            end
        end
    end
	local logic = {}
	local customjitter = false
	local temp_bool = false
	local ladder = false
	local temp_way = 1
	local function get_value(x, z)
		if z < 3 then
			temp_bool = not temp_bool
			return temp_bool and -x or x
		end
		local list = {}
		for loop = 1, z do
			if loop % 4 == 0 then
				list[#list+1] = x
			end
			if loop % 4 == 1 then
				list[#list+1] = x/2
			end
			if loop % 4 == 2 then
				list[#list+1] = -(x/2)
			end
			if loop % 4 == 3 then
				list[#list+1] = -x
			end
		end
		if temp_way <= z then
			temp_way = temp_way + 1
			if temp_way == z+1 then
				temp_way = 1
			end
		end
		return list[temp_way-1]
	end
	local function desyncfunc(z, x, speed)
		local selected = entity.get_player_weapon(z)
		local throw = entity.get_prop(selected, "m_fThrowTime")
		if (throw ~= nil and throw ~= 0) then 
			return false 
		else 
			if x.in_attack then 
				local weapon = entity.get_classname(selected) 
				if not weapon:find("Grenade") then 
					return false 
				end 
			end 
		end
		if entity.get_prop(entity.get_game_rules(), "m_bFreezePeriod") == 1 then return false end
		if ladder or (entity.get_prop(z, "m_MoveType") == 9 and speed ~= 0) then return false end
		if x.in_use then return false end
		return true
	end
	local function split(str, arg) 
		local result = {} 
		for loop in string.gmatch(str, "([^" .. arg .. "]+)") do 
			result[#result+1] = loop 
		end 
		return result 
	end
	local function nodesync(aatbl)
		ui.override(aatbl.enabled[1], true)
		ui.override(aatbl.roll[1], 0)
		--ui.set(aatbl.edge[1], false)
		ui.override(aatbl.fsbody[1], 'Off')
		ui.override(aatbl.yaw[1], 0)
		ui.override(aatbl.pitch[1], "down")
		ui.override(aatbl.base[1], "at targets")
		ui.override(aatbl.body[1], {})
		ui.override(aatbl.body[2], 0)
		ui.override(aatbl.jitter[1], "disabled")
		ui.override(aatbl.yaw[2], 0)
	end
	local script = {
		cache = {
			manual = {
				aa = 0,
				tick = 0
			}
		}
	}
	for i, v in next, z.states do
        z.menu["Anti Aim"].custom[v] = {
			desync = z.item("new_combobox", {z.prefix.section:format("AA", v, "Desync"), "Default ", "Custom"}),
			team = z.item("new_combobox", {z.prefix.section:format("AA", v, "Team"), "CT", "T"}),
            enable = z.item("new_multiselect", {z.prefix.section:format("AA", v, "Status"), "Enabled"}),
			yawteam = z.item("new_combobox", {z.prefix.section:format("AA", v, "Team"), {"CT", "T"}}),
			yawoption = z.item("new_combobox", {z.prefix.section:format("AA", v, "Yaw mode"), {"Left right (FS: Yes)", "Left right (FS: No)", "Automatic (FS: No)"}}),
            tyawleft = z.item("new_slider", {z.prefix.section:format("AA", v, "Yaw left\nT"), -180, 180, -10}),
            tyawright = z.item("new_slider", {z.prefix.section:format("AA", v, "Yaw right\nT"), -180, 180, 10}),
			ctyawleft = z.item("new_slider", {z.prefix.section:format("AA", v, "Yaw left\nCT"), -180, 180, -10}),
            ctyawright = z.item("new_slider", {z.prefix.section:format("AA", v, "Yaw right\nCT"), -180, 180, 10}),
			yawauto = z.item("new_combobox", {z.prefix.section:format("AA", v, "Automatic"), {"Default", "Ways"}}),
			yawways =  z.item("new_slider", {z.prefix.section:format("AA", v, "Ways\n"), 2, 5, 5}),
			options = z.item("new_multiselect", {z.prefix.section:format("AA", v, "Defensive"), {"Pitch up", "Random yaw", "Offensive", "Always on"}})
        }
		ui["set_callback"](z.menu["Anti Aim"].custom[v].yawways,function()
			logic = {}
		end)
    end
    z.cache = {}
    for i, v in next, z.states do
        z.cache[#z.cache+1] = v .. " CT"
        z.cache[#z.cache+1] = v .. " T"
    end
    for i, v in next, z.cache do
        z.menu["Anti Aim"].builder[v] = {
            enable = z.item("new_multiselect", {z.prefix.section:format("AA", v, "Status"), "Enabled"}),
            yawmode = z.item("new_combobox", {z.prefix.section:format("AA", v, "Yaw options"), "Off", "Customize", "Customize + l & r", "Left and right"}),
            yaw = z.item("new_slider", {z.prefix.section:format("AA", v, "Yaw"), -180, 180, 0}),
            leftright = z.item("new_combobox", {z.prefix.section:format("AA", v, "Left right"), "Normal", "Simple", "Advanced"}),
            yawleft = z.item("new_slider", {z.prefix.section:format("AA", v, "Yaw left"), -100, 100, -10}),
            yawright = z.item("new_slider", {z.prefix.section:format("AA", v, "Yaw right"), -100, 100, 10}),
			yawtimer = z.item("new_slider", {z.prefix.section:format("AA", v, "Yaw timer"), 1, 10, 1}),
            jitteryaw = z.item("new_combobox", {z.prefix.section:format("AA", v, "Jitter mode"), "Off", "Center", "Left right", "Random center", "Automatic small", "Automatic big"}),
            jitter = z.item("new_slider", {z.prefix.section:format("AA", v, "Jitter"), -180, 180, 0}),
            jitterlr = z.item("new_slider", {z.prefix.section:format("AA", v, "Left right"), -180, 180, 0}),
			jitterrandom = z.item("new_slider", {z.prefix.section:format("AA", v, "Jitter\n\n\n"), 0, 90, 60}),
            jitterrnd = z.item("new_slider", {z.prefix.section:format("AA", v, "Random"), 0, 30, 15}),
            fakeyaw = z.item("new_combobox", {z.prefix.section:format("AA", v, "Fake yaw"), "Default skeet", "Automatic fake", "Random skeet fake"}),
			bodymode = z.item("new_combobox", {z.prefix.section:format("AA", v, "Body yaw"), "Jitter", "Static", "Opposite", "Off"}),
            limityaw = z.item("new_slider", {z.prefix.section:format("AA", v, "Limit yaw"), 0, 60, 60}),
            options = z.item("new_multiselect", {z.prefix.section:format("AA", v, "Options"), {"Static freestanding", "Defensive", "Prioritize manual"}}),
            defensive = z.item("new_multiselect", {z.prefix.section:format("AA", v, "Defensive"), {"Pitch up", "Random yaw", "Switch cycle", "Always on"}}),
            button = z.item("new_button", {"Send to: " .. (string.find(v, "CT") and "T" or "CT"), movecfg}),
        }
    end
    z.hideshowetc = {
        handler = function()
			if not ui.is_menu_open() then return nil end
            local selected = ui.get(z.menu.select)
            local toggle = true
            for index, value in next, z.menu do
                if type(value) == "table" then
                    for i, v in next, value do
                        if type(v) == "table" then
                            for ii, vv in next, v do
                                if type(vv) == "table" then
                                    for iii, vvv in next, vv do
										if (i == "custom") then
											if iii == "desync" then
												ui.set_visible(vvv, index == selected and ii == ui.get(z.menu["Anti Aim"].state))
											end
											if iii == "team" then
												ui.set_visible(vvv, index == selected and ii == ui.get(z.menu["Anti Aim"].state) and ui.get(z.menu["Anti Aim"]["custom"][ui.get(z.menu["Anti Aim"].state)].desync) == "Default ")
											end
											if iii == "enable" and ii == "Global" and ui.get(z.menu["Anti Aim"].state) == "Global" then
												ui.set_visible(vvv, false)
											else
												if iii ~= "team" and iii ~= "desync" then
													local shortcut = z.menu["Anti Aim"]["custom"][ui.get(z.menu["Anti Aim"].state)]

													toggle = z.contains(ui.get(shortcut.enable), "Enabled") or iii == "enable" or ii == "Global"
													if (toggle) and (iii == "ctyawleft" or iii == "ctyawright" or iii == "tyawleft" or iii == "tyawright" or iii == "yawteam") then
														local team = true
														if (iii == "ctyawleft" or iii == "ctyawright") then
															team = ui.get(shortcut.yawteam) == "CT"
														end
														if (iii == "tyawleft" or iii == "tyawright") then
															team = ui.get(shortcut.yawteam) == "T"
														end
														toggle = ui.get(shortcut.yawoption) ~= "Automatic (FS: No)" and team
													end
													if (toggle) and (iii == "yawauto") then
														toggle = ui.get(shortcut.yawoption) == "Automatic (FS: No)"
													end
													if (toggle) and (iii == "yawways") then
														toggle = ui.get(shortcut.yawauto) == "Ways" and ui.get(shortcut.yawoption) == "Automatic (FS: No)"
													end
													ui.set_visible(vvv, toggle and index == selected and ii == ui.get(z.menu["Anti Aim"].state) and ui.get(shortcut.desync) == "Custom")
												end
											end
										else
                                            local shortcut = z.menu["Anti Aim"].builder[ui.get(z.menu["Anti Aim"].state) .. " " .. ui.get(z.menu["Anti Aim"]["custom"][ui.get(z.menu["Anti Aim"].state)].team)]

											toggle = true
											if (iii == "leftright" or iii == "yawleft" or iii == "yawright") then
												toggle = ui.get(shortcut.yawmode) == "Left and right" or ui.get(shortcut.yawmode) == "Customize + l & r"
											end
											if (iii == "yawtimer") then
												toggle = ui.get(shortcut.leftright) == "Timer"
											end
											if (iii == "jitter") then
												toggle = ui.get(shortcut.jitteryaw) == "Left right" or ui.get(shortcut.jitteryaw) == "Center"
											end
                                            if (iii == "jitterlr") then
												toggle = ui.get(shortcut.jitteryaw) == "Left right"
											end
                                            if (iii == "jitterrnd") then
												toggle = ui.get(shortcut.jitteryaw) == "Random center"
											end
											if (iii == "jitterrandom") then
												toggle = ui.get(shortcut.jitteryaw) == "Random center"
											end
											if (iii == "defensive") then
												toggle = z.contains(ui.get(shortcut.options), "Defensive")
											end
											if (iii == "yaw") then
												toggle = ui.get(shortcut.yawmode) == "Customize" or ui.get(shortcut.yawmode) == "Customize + l & r"
											end
											if (iii == "bodymode" or iii == "limityaw") then
												toggle = ui.get(shortcut.fakeyaw) == "Default skeet"
											end
											if (iii == "bodyyaw") then
												toggle = ui.get(shortcut.fakeyaw) == "Default skeet" and (ui.get(shortcut.bodymode) == "Jitter" or ui.get(shortcut.bodymode) == "Static")
											end
											if (toggle) then
												if (ui.get(z.menu["Anti Aim"].state):find("Global")) then
													toggle = iii ~= "enable"
												else
													toggle = z.contains(ui.get(shortcut.enable), "Enabled") or iii == "enable"
												end
											end
											ui.set_visible(vvv, index == selected and ii == ui.get(z.menu["Anti Aim"].state) .. " " .. ui.get(z.menu["Anti Aim"]["custom"][ui.get(z.menu["Anti Aim"].state)].team) and toggle and ui.get(z.menu["Anti Aim"]["custom"][ui.get(z.menu["Anti Aim"].state)].desync) == "Default ")
										end
                                    end
                                end
                            end
                        else
							toggle = true
							if (i == "team") then
								toggle = ui.get(z.menu["Anti Aim"].desync) == "Default "
							end
							if (i == "label" or i == "color" or i == "arrows" or i == "center") then
								toggle = ui.get(z.menu["Visuals"].indicator)
							end
                            ui.set_visible(v, index == selected and toggle)
                        end
                    end
                end
            end
        end,
        title = function()
			if not ui.is_menu_open() then return nil end
            do
				local r2, g2, b2, a2 = 255,255,255,255
				local highlight_fraction =  (globals.realtime() / 2 % 1.2 * 2) - 1.2
				local output = ""
				local text_to_draw = "L U A S E N S E"
				for idx = 1, #text_to_draw do
					local character = text_to_draw:sub(idx, idx)
					local character_fraction = idx / #text_to_draw
					local r1, g1, b1, a1 = 123, 123, 123, 255
					local highlight_delta = (character_fraction - highlight_fraction)
					if highlight_delta >= 0 and highlight_delta <= 1.4 then
						if highlight_delta > 0.7 then
						   highlight_delta = 1.4 - highlight_delta
						end
						local r_fraction, g_fraction, b_fraction, a_fraction = r2 - r1, g2 - g1, b2 - b1
						r1 = r1 + r_fraction * highlight_delta / 0.8
						g1 = g1 + g_fraction * highlight_delta / 0.8
						b1 = b1 + b_fraction * highlight_delta / 0.8
					end
					output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, 255, text_to_draw:sub(idx, idx))
                    ui.set(z.menu.label, z.prefix.x:format(output))
				end
            end
        end,
        resetmenu = function()
			local aatbl = z.items.aa
			ui.override(aatbl.enabled[1], true)
			ui.override(aatbl.roll[1], 0)
			--ui.set(aatbl.edge[1], false)
			ui.override(aatbl.fsbody[1], 'off')
			ui.override(aatbl.yaw[1], 0)
			ui.override(aatbl.pitch[1], "down")
			ui.override(aatbl.base[1], "at targets")
			ui.override(aatbl.fs, false)
			--ui.set(aatbl.fs, "")
			ui.override(aatbl.body[1], {})
			ui.override(aatbl.body[2], 0)
			ui.override(aatbl.jitter[1], "disabled")
			ui.override(aatbl.jitter[2], 0)
        end
    }
	local data = {
		tickbool = false,
		chokebool = false,
		timerbool = false,
		jitterbool = false,
		custombool = false,
		autobool = false,
		offensivebool = false,
		jitterlist = {},
		jittersize = {},
		fakelist = {},
		customlog = {},
		fakecache = "",
		cacheyaw = 0,
		doubletap = 0,
		last = 0
	}
	local delays = {
		choked = 0,
		mouse1 = 0,
		dt = 0,
		dt2 = 0,
	}
	local aa = {
		jitter = 0,
		yaw = 0
	}
	z.can_desync = function(cmd)
		local localplayer = entity.get_local_player()
		if (entity.get_prop(localplayer, "m_MoveType") or 0) == 9 then
			return false
		end
		local get_wpn = entity.get_player_weapon(localplayer)
		if get_wpn == nil then return false end
		local weapon = entity.get_classname(get_wpn)
		local in_use = cmd.in_use
		local attack1 = cmd.in_attack
		local attack2 = cmd.in_attack2
		if in_use then return end
		if attack1 or attack2 then
			if weapon:find("Grenade") then
				delays.mouse1 = globals_curtime() + 0.15
			end
		end
		if delays.mouse1 > globals.curtime() then return false end
		if attack1 then
			local weapon = entity.get_player_weapon(localplayer)
			if weapon == nil then return false end
			local player_weapon = entity.get_classname(weapon)
			if attack2 then
				return false
			end
			return false
		end
		return true
	end
	z.get_choke = function(cmd)
		local fakelag = ui.get(limitfl)
		local check_fakelag = fakelag % 2 == 1
		if check_fakelag and fakelag > 1 then
			ui.override(limitfl, fakelag-1)
		end
		local choked = cmd.choked_commands
		local check_choke = choked % 2 == 0
		local dt_on = (ui.get(z.items.keys.dt[1]))
		local hs_on = (ui.get(z.items.keys.hs[1]))
		local fd_on = ui.get(z.items.keys.fd[1])
		local xv, yv, zv = entity.get_prop(entity.get_local_player(), "m_vecVelocity")
		local vel = math.sqrt(xv*xv + yv*yv + zv*zv)
		if dt_on then
			if delays.choked > 2 then
				if cmd.choked_commands >= 0 then
					check_choke = false
				end
			end
		end
		delays.choked = cmd.choked_commands
		if delays.dt ~= dt_on then
			delays.dt2 = globals.curtime() + 0.25
		end
		if not dt_on and not hs_on and not cmd.no_choke or fd_on then
			if not check_fakelag then
				if delays.dt2 > globals.curtime() then
					if cmd.choked_commands >= 0 and cmd.choked_commands < fakelag then
						check_choke = choked % 2 == 0
					else
						check_choke = choked % 2 == 1
					end
				else
					check_choke = choked % 2 == 1
				end
			end
		end
		delays.dt = dt_on
		return check_choke
	end
	local distance = function(x1,y1,z1,x2,y2,z2)
		return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
	end
	local extrapolate = function(player, ticks, x,y,z)
		local xv, yv, zv =  entity.get_prop(player, "m_vecVelocity")
		local new_x = x + globals.tickinterval() * xv * ticks
		local new_y = y + globals.tickinterval() * yv * ticks
		local new_z = z + globals.tickinterval() * zv * ticks
		return new_x, new_y, new_z
	end
    z.aa = {
		yawhandler = function(yawbody, nochoke, left, right)
			local result = nil
			if nochoke then
				result = (yawbody > 0 and left or right)
			end
			return result
		end,
        builder = function(arg)
			ui.override(z.items.keys.mode[1], "on peek")
            local myself = entity.get_local_player()
			local air = bit.band(entity.get_prop(myself, "m_fFlags"), 1) == 0
            local xv, yv, zv = entity.get_prop(myself, "m_vecVelocity")
			local duck = (entity.get_prop(myself, "m_flDuckAmount") > 0.1)
            local state = z.getstate(myself, arg.in_jump  or air, duck, math.sqrt(xv*xv + yv*yv + zv*zv), fakelag, (ui.get(slow) and ui.get(key)))

			local cache = (ui.get(z.menu["Anti Aim"].custom[state].desync) == "Default " and "builder" or string.lower(ui.get(z.menu["Anti Aim"].custom[state].desync)))
			local fix = state
            local team = entity.get_prop(myself, "m_iTeamNum")
            if team == 2 then
                fix = fix .. " T"
            else
                fix = fix .. " CT"
            end
            if not z.contains(ui.get(z.menu["Anti Aim"][cache][(cache == "builder" and fix or state)].enable), "Enabled") then
				cache = (ui.get(z.menu["Anti Aim"].custom["Global"].desync) == "Default " and "builder" or string.lower(ui.get(z.menu["Anti Aim"].custom["Global"].desync)))
				if cache == "builder" then
					fix = (team == 2 and "Global T" or "Global CT")
				else
					state = "Global"
				end
			end
			local tickcount = globals.tickcount()
			local enemy = client.current_threat()
			if enemy == nil then
				enemy = myself
			end
			local defensive = (z.defensive.defensive > 1 and z.defensive.defensive < 14)
			local menutbl = z.menu["Anti Aim"][cache][(cache == "builder" and fix or state)]
			local aatbl = z.items.aa
			ui.override(aatbl.enabled[1], true)
			ui.override(aatbl.roll[1], 0)
			--ui.set(aatbl.edge[1], false)
			ui.override(aatbl.fsbody[1], 'Off')
			ui.override(aatbl.yaw[1], 0)
			ui.override(aatbl.pitch[1], "Down")
			ui.override(aatbl.base[1], script.cache.manual.aa == 0 and "at targets" or "local view")
			if script.cache.manual.aa ~= 0 and z.contains(ui.get(menutbl.options), "Prioritize manual") then
				ui.override(aatbl.fs, false)
			end
			if z.contains(ui.get(z.menu["Misc"].disabler), "Air") and (air or arg.in_jump) then
				ui.override(aatbl.fs, false)
			end
			if z.contains(ui.get(z.menu["Misc"].disabler), "Duck") and duck then
				ui.override(aatbl.fs, false)
			end
			if z.contains(ui.get(z.menu["Misc"].disabler), "Slow") and (ui.get(slow) and ui.get(key)) then
			    ui.override(aatbl.fs, false)
			end

			if ui.get(z.menu["Misc"].hideshot) then
				if (ui.get(z.items.keys.hs[1])) and not ui.get(z.items.keys.fd[1]) then
					ui.override(limitfl, 1)
				else
					ui.override(limitfl, 14)
				end
			end
			if ui.get(z.menu["Misc"].backstab) then
				local weapon = entity.get_player_weapon(enemy)
				if myself ~= enemy and myself ~= nil and weapon ~= nil and entity.get_classname(weapon) == "CKnife" then
					local ex,ey,ez = entity.get_origin(enemy)
					local lx,ly,lz = entity.get_origin(myself)
					if ex ~= nil and lx ~= nil then 
						for ticks = 1,9 do
							local tex,tey,tez = extrapolate(myself,ticks,lx,ly,lz)
							local distance = distance(ex,ey,ez,tex,tey,tez)
							if math.abs(distance) < 169 then
								ui.override(aatbl.body[1], {"jitter"})
								ui.override(aatbl.body[2], 0)
								ui.override(aatbl.jitter[1], "center")
								ui.override(aatbl.jitter[2], -69)
								ui.override(aatbl.yaw[1], 0)
								return
							end
						end
					end
				end
			end
			if cache == "builder" then
				local yaw_body = math.max(-60, math.min(60, math.floor((entity.get_prop(myself,"m_flPoseParameter",11) or 0)*120-60+0.5)))
				if yaw_body > 0 and yaw_body > 60 then yaw_body = 60 end
				if yaw_body < 0 and yaw_body < -60 then yaw_body = -60 end
				local yawfix = 0
				if ui.get(menutbl.yawmode) == "Customize" then
					yawfix = ui.get(menutbl.yaw)
				end
				if ui.get(menutbl.yawmode) == "Left and right" or ui.get(menutbl.yawmode) == "Customize + l & r" then
					if ui.get(menutbl.leftright) == "Advanced" then
						yawfix = z.aa.yawhandler(yaw_body, arg.choked_commands ~= 0, ui.get(menutbl.yawleft), ui.get(menutbl.yawright))
					else
						if ui.get(menutbl.leftright) == "Simple" then
							if arg.choked_commands ~= 0 then
								yawfix = (yaw_body > 0 and ui.get(menutbl.yawleft) or ui.get(menutbl.yawright))
							end
						else
							if arg.choked_commands == 0 then
								local delta = entity.get_prop(myself, "m_flPoseParameter", 11) * 120 - 60
								yawfix = (delta > 0 and ui.get(menutbl.yawleft) or ui.get(menutbl.yawright))
							else
								yawfix = nil
							end
						end
					end
					if ui.get(menutbl.yawmode) == "Customize + l & r" and yawfix ~= nil then
						yawfix = yawfix + ui.get(menutbl.yaw)
					end
				end
				if yawfix ~= nil then
					ui.override(aatbl.yaw[1], z.clamp(yawfix + script.cache.manual.aa))
					data.cacheyaw = yawfix
				end
                
                ui.override(aatbl.bodyleft, ui.get(menutbl.limityaw))
                ui.override(aatbl.bodyright, ui.get(menutbl.limityaw))

				ui.override(aatbl.jitter[1], ui.get(menutbl.jitteryaw) == "Off" and "disabled" or "center")
				if ui.get(menutbl.jitteryaw) == "Center" then
					ui.override(aatbl.jitter[2], -ui.get(menutbl.jitter))
				end
				if ui.get(menutbl.jitteryaw) == "Random center" then
					ui.override(aatbl.jitter[2], -client.random_int(ui.get(menutbl.jitterrandom), ui.get(menutbl.jitterrandom)+ui.get(menutbl.jitterrnd)))
				end
				if ui.get(menutbl.jitteryaw) == "Left right" then
					if arg.choked_commands == 0 then
						data.jitterbool = not data.jitterbool
						ui.override(aatbl.jitter[2], -(data.jitterbool and ui.get(menutbl.jitter) or ui.get(menutbl.jitterlr)))
					end
				end
				if data.fakecache ~= ui.get(menutbl.jitteryaw) then
					data.fakecache = ui.get(menutbl.jitteryaw)
					data.jitterlist = {}
				end
				if ui.get(menutbl.jitteryaw) == "Automatic big" then
					if data.jitterlist[enemy] == nil then
						if data.jittersize[enemy] == nil then
							data.jitterlist[enemy] = client.random_int(59,79)
						else
							if data.jittersize[enemy] == "big" then
								data.jitterlist[enemy] = client.random_int(59,69)
							else
								data.jitterlist[enemy] = client.random_int(70,79)
							end
						end
						data.jittersize[enemy] = data.jitterlist[enemy] > 69 and "big" or "small"
					end
					ui.override(aatbl.jitter[2], -data.jitterlist[enemy])
				end
				if ui.get(menutbl.jitteryaw) == "Automatic small" then
					if data.jitterlist[enemy] == nil then
						if data.jittersize[enemy] == nil then
							data.jitterlist[enemy] = client.random_int(39,59)
						else
							if data.jittersize[enemy] == "big" then
								data.jitterlist[enemy] = client.random_int(39,49)
							else
								data.jitterlist[enemy] = client.random_int(50,59)
							end
						end
						data.jittersize[enemy] = data.jitterlist[enemy] > 49 and "big" or "small"
						
                    end
					ui.override(aatbl.jitter[2], -data.jitterlist[enemy])
				end
				if ui.get(menutbl.fakeyaw) == "Default skeet" then
					ui.override(aatbl.body[1], {ui.get(menutbl.bodymode)})
					ui.override(aatbl.body[2], ui.get(menutbl.bodyyaw))
				end
				if ui.get(menutbl.fakeyaw) == "Random skeet fake" then
					ui.override(aatbl.body[1], {"jitter"})
					ui.override(aatbl.body[2], 0)
				end
				if ui.get(menutbl.fakeyaw) == "Automatic fake" then
					if data.fakelist[enemy] == nil then
						data.fakelist[enemy] = client.random_int(29,59)
					end
					ui.override(aatbl.body[1], {"jitter"})
					ui.override(aatbl.body[2], 0)
				end
				if z.contains(ui.get(menutbl.options), "Static freestanding") and (script.cache.manual.aa ~= 0) then
					ui.override(aatbl.body[1], {})
					ui.override(aatbl.body[2], 0)
					ui.override(aatbl.jitter[1], "disabled")
					ui.override(aatbl.yaw[1], script.cache.manual.aa)
				end
				if z.contains(ui.get(menutbl.options), "Defensive") then
					if z.contains(ui.get(menutbl.defensive), "Pitch up") and defensive then
						ui.override(aatbl.pitch[1], "fake up")
					end
					if z.contains(ui.get(menutbl.defensive), "Random yaw") and defensive then
						local randomyaw = client.random_int(69,169)
						ui.override(aatbl.yaw[1], z.clamp((tickcount % 6 < 3 and randomyaw or -randomyaw) + script.cache.manual.aa))
					end
					if z.contains(ui.get(menutbl.defensive), "Switch cycle") then
						if tickcount % 3 == 1 then
							--ui.set(z.items.keys.mode[1], "disabled")
						end
						ui.override(z.items.keys.mode[1], tickcount % 3 ~= 1 and 'always on' or 'on peek')
					end
					if z.contains(ui.get(menutbl.defensive), "Always on") then
						ui.override(z.items.keys.mode[1], tickcount % 5 ~= 1 and 'always on' or 'on peek')
					end
				end
			else
				local myteam = "ct"
				if team == 2 then
					myteam = "t"
				end
				local yawleft = ui.get(menutbl[myteam .. "yawleft"])
				local yawright = ui.get(menutbl[myteam .. "yawright"])
				if ui.get(menutbl.yawoption) == "Left right (FS: Yes)" then
					ui.override(aatbl.body[1], {})
					ui.override(aatbl.body[2], 0)
					ui.override(aatbl.jitter[1], "disabled")
					ui.override(aatbl.jitter[2], 0)
					arg.send_packet = false
					if arg.choked_commands == 1 then
						data.custombool = not data.custombool
						ui.override(aatbl.yaw[1], z.clamp((data.custombool and yawright or yawleft) +script.cache.manual.aa))
					else
						ui.override(aatbl.yaw[1], z.clamp((data.custombool and yawright or yawleft) + script.cache.manual.aa))
					end
					if z.contains(ui.get(menutbl.options), "Pitch up") and defensive then
						ui.override(aatbl.pitch[1], "fake up")
					end
					if z.contains(ui.get(menutbl.options), "Random yaw") and defensive then
						local randomyaw = client.random_int(69,169)
						ui.override(aatbl.yaw[1], z.clamp((tickcount % 6 < 3 and randomyaw or -randomyaw) + script.cache.manual.aa))
					end
					if z.contains(ui.get(menutbl.options), "Always on") then
						ui.override(z.items.keys.mode[1], 'always on')
					end
					if z.contains(ui.get(menutbl.options), "Offensive") then
						data.doubletap = (data.last ~= 1 or z.defensive.defensive ~= 1)
						data.last = z.defensive.defensive
						local tickbase = entity.get_prop(myself, "m_nTickBase")
						ui.override(z.items.keys.mode[1], "on peek")
						if tickbase % 7 == 0 then
							data.offensivebool = not data.offensivebool
							ui.override(aatbl.body[1], {})
							ui.override(aatbl.yaw[1], z.clamp((yawleft*2) + script.cache.manual.aa))
						else
							if not (data.last > 2 and data.last < 14) then
								ui.override(aatbl.body[1], data.doubletap and "jitter" or "static")
								ui.override(aatbl.yaw[1], z.clamp((data.doubletap and -yawright or (-(yawright/2))) + script.cache.manual.aa))
							end
						end
						ui.override(z.items.keys.mode[1], (data.doubletap and tickbase % 3 ~= 1) and 'always on' or 'on peek')
						ui.override(aatbl.body[2], data.doubletap and 0 or (data.offensivebool and -60 or 60))
					end
				else
					ui.override(aatbl.enabled[1], false)
					local ents = entity.get_players(true)
					for i=1, #ents do
						local current = ents[i]
						if current ~= nil and player ~= myself then
							if entity.is_enemy(current) then
								if data.customlog[current] == nil then
									data.customlog[current] = {
										idx = current,
										yaw = {left = 0, right = 0},
										fake = {fake = 0, lby = 0},
										should_update = true,
									}
									for i, x in next, data.customlog do
										local hp = entity.get_prop(x.idx, "m_iHealth")
										local team = entity.get_prop(x.idx, "m_iTeamNum")
										if hp == nil or team == nil then
											table.remove(data.customlog, j)
										else
											if team == entity.get_prop(me, "m_iTeamNum") then
												table.remove(data.customlog, i)
											end
										end
									end
								end
							end
						end
					end
					local values = { -23, 43, 120, -120, true }
					local autoyaw = ui.get(menutbl.yawauto) == "Default"
					if ui.get(menutbl.yawoption) == "Left right (FS: No)" then
						autoyaw = true
						values = { yawright, yawleft, 120, -120, true }
					else
						if autoyaw then
							if taget ~= myself and data.customlog[enemy] then
								if data.customlog[enemy].should_update then
									if data.customlog[enemy].yaw == nil then data.customlog[enemy].yaw = {left = 0, right = 0} end
									data.customlog[enemy].yaw.left = client.random_int(-28, -22)
									data.customlog[enemy].yaw.right = math.abs(data.customlog[enemy].yaw.left) + client.random_int(10, 15) + 5
									data.customlog[enemy].fake.fake = client.random_int(65, 121)
									data.customlog[enemy].fake.lby = -data.customlog[enemy].fake.fake - 5
									data.customlog[enemy].should_update = false
									
                                end
								values = { data.customlog[enemy].yaw.left, data.customlog[enemy].yaw.right, data.customlog[enemy].fake.fake, data.customlog[enemy].fake.lby, true }
							end
						end
					end
					if autoyaw then
						local _, yaw = client.camera_angles()
						yaw = yaw + 180
						if enemy ~= myself and script.cache.manual.aa == 0 then
							local eyepos = vector(client.eye_position())
							local origin = vector(entity.get_origin(enemy))
							local target = origin + vector(0, 0, 40)
							yaw = eyepos:to(target):angles().y
							yaw = yaw + 180
						end
						local hs_on = (ui.get(z.items.keys.hs[1]))
						if not hs_on then
							arg.send_packet = false
						end
						if (bit.band(entity.get_prop(myself, "m_fFlags"), bit.lshift(1, 0)) == 1) then
							if not (arg.in_forward or arg.in_moveleft or arg.in_moveright or arg.in_back) then
								local amount = (entity.get_prop(myself, "m_flDuckAmount") > 0.7) and 3.25 or 1.1
								if math.floor(math.sqrt(xv*xv + yv*yv + zv*zv)) < 1.1 then
									arg.sidemove = (globals.tickcount() % 2 == 0) and amount or -amount
								end
							end
						end
						if z.can_desync(arg) then
							if z.get_choke(arg) then
								if hs_on then
									arg.send_packet = false
								end
								aa.jitter = not aa.jitter
								if aa.jitter then
									aa.yaw = values[3]
								else
									aa.yaw = values[4]
								end
							else
								if aa.jitter then
									aa.yaw = values[1]
								else
									aa.yaw = values[2]
								end
							end
							arg.yaw = yaw + aa.yaw + script.cache.manual.aa
							arg.pitch = 90
						end
						if z.contains(ui.get(menutbl.options), "Pitch up") and defensive then
							arg.pitch = -90
						end
						if z.contains(ui.get(menutbl.options), "Random yaw") and defensive then
							local randomyaw = client.random_int(69,169)
							arg.yaw = (tickcount % 6 < 3 and randomyaw or -randomyaw)
						end
						if z.contains(ui.get(menutbl.options), "Offensive") then
							if tickcount % 3 == 1 then
								ui.override(z.items.keys.mode[1], "on peek")
							end
							ui.override(z.items.keys.mode[1], tickcount % 5 ~= 1 and 'always on' or 'on peek')
						end
						if z.contains(ui.get(menutbl.options), "Always on") then
							ui.override(z.items.keys.mode[1], 'always on')
						end
					else
						ui.override(aatbl.enabled[1], true)
						ui.override(aatbl.roll[1], 0)
						--ui.set(aatbl.edge[1], false)
						ui.override(aatbl.fsbody[1], 'Peek Fake')
						ui.override(aatbl.yaw[1], 0)
						ui.override(aatbl.pitch[1], "Down")
						ui.override(aatbl.base[1], script.cache.manual.aa == 0 and "at targets" or "local view")
						--ui.set(aatbl.fs, "")
						ui.override(aatbl.body[1], {})
						ui.override(aatbl.body[2], 0)
						ui.override(aatbl.jitter[1], "disabled")
						ui.override(aatbl.jitter[2], 0)
						ui.override(aatbl.yaw[2], 0)
						if desyncfunc(myself, arg, math.sqrt(xv*xv + yv*yv + zv*zv)) then
							local angle = ({client.camera_angles()})[2]
							local junk = 0
							if enemy ~= nil and enemy ~= myself and script.cache.manual.aa == 0 then
								local eyepos = vector(client.eye_position())
								local origin = vector(entity.get_origin(enemy))
								local target = origin + vector(0, 0, 40)
								angle = eyepos:to(target):angles().y
							end
							angle = angle + 180 + script.cache.manual.aa
							local desync = (arg.choked_commands % 2 == 0)
							if arg.choked_commands > 1 then
								desync = (arg.choked_commands % 3 == 1)
							end
							if logic[enemy] == nil then
								logic[enemy] = {
									yaw = client.random_int(30,50),
									desync = client.random_int(90,120),
									angle = client.random_int(-11,11)
								}
							end
							if desync then
								customjitter = not customjitter
								arg.send_packet = false
								arg.yaw = (customjitter and logic[enemy]["desync"] or -logic[enemy]["desync"])
							else
								local result = get_value(logic[enemy]["yaw"], ui.get(menutbl.yawways))
								if result == nil then
									result = get_value(logic[enemy]["yaw"], ui.get(menutbl.yawways))
									if result == nil then
										result = logic[enemy]["yaw"]
									end
								end
								if z.contains(ui.get(menutbl.options), "Always on") then
									ui.override(z.items.keys.mode[1], 'always on')
								end
								if arg.choked_commands > 1 then
									arg.send_packet = false
								else
									arg.send_packet = true
								end
								arg.yaw = angle + result + logic[enemy]["angle"]
							end
							arg.pitch = 89
							arg.roll = 0
							if z.contains(ui.get(menutbl.options), "Pitch up") and defensive then
								arg.pitch = -89
							end
							if z.contains(ui.get(menutbl.options), "Random yaw") and defensive then
								local randomyaw = client.random_int(69,169)
								arg.yaw = (tickcount % 6 < 3 and randomyaw or -randomyaw)
							end
							if z.contains(ui.get(menutbl.options), "Offensive") then
								if tickcount % 3 == 1 then
									ui.override(z.items.keys.mode[1], "on peek")
								end
								ui.override(z.items.keys.mode[1], tickcount % 5 ~= 1 and 'always on' or 'on peek')
							end
						end
					end
				end
			end
        end,
        breakers = function(arg)
            if not entity.get_local_player() then return end
            local flags = entity.get_prop(entity.get_local_player(), "m_fFlags")

            local path = ui.get(z.menu["Misc"].animations)
            ground_ticks = bit.band(flags, 1) == 0 and 0 or (ground_ticks < 5 and ground_ticks + 1 or ground_ticks)
        
            if z.contains(path, "Static legs") then
                entity.get_local_player().m_flPoseParameter[6] = 1
            end
        
            if z.contains(path, "Leg fucker") then
                if not legsSaved then
                    legsSaved = ui.get(z.items.aa.legMovement)
                end
                --if z.contains(path, "Leg fucker") then
                ui.set(z.items.aa.legMovement, "Sliding")
                entity.get_local_player().m_flPoseParameter[0] = legsTypes[math.random(1, 3)]
                --end
        
            elseif (legsSaved == "Off" or legsSaved == "Always slide" or legsSaved == "Never slide") then
                ui.set(z.items.aa.legMovement, legsSaved)
                legsSaved = false
            end
        
            if z.contains(path, "0 pitch on landing") then
                ground_ticks = bit.band(flags, 1) == 1 and ground_ticks + 1 or 0
        
                if ground_ticks > 20 and ground_ticks < 150 then
                    entity.get_local_player().m_flPoseParameter[12] = 0.5
                end
            end
        
            if z.contains(path, "Moonwalk") then
                if not legsSaved then
                    legsSaved = ui.get(z.items.aa.legMovement)
                end
                entity.get_local_player().m_flPoseParameter[7] = 0

                ui.set(z.items.aa.legMovement, "Walking")
            end
        end
    }
	z.antibf = {
		get_camera_pos = function(entindex)
			local e_x, e_y, e_z = entity.get_prop(entindex, "m_vecOrigin")
			if e_x == nil then return end
			local _, _, ofs = entity.get_prop(entindex, "m_vecViewOffset")
			e_z = e_z + (ofs - (entity.get_prop(entindex, "m_flDuckAmount") * 16))
			return e_x, e_y, e_z
		end,
		fired = function(target, shooter, shot)
			local shooter_cam = { z.antibf.get_camera_pos(shooter) }
			if shooter_cam[1] == nil then return end
			local player_head = { entity.hitbox_position(target, 0) }
			local shooter_cam_to_head = { 
				player_head[1] - shooter_cam[1],
				player_head[2] - shooter_cam[2],
				player_head[3] - shooter_cam[3] 
			}
			local shooter_cam_to_shot = { 
				shot[1] - shooter_cam[1], 
				shot[2] - shooter_cam[2],
				shot[3] - shooter_cam[3]
			}
			local tt = (
				(shooter_cam_to_head[1]*shooter_cam_to_shot[1]) + 
				(shooter_cam_to_head[2]*shooter_cam_to_shot[2]) + 
				(shooter_cam_to_head[3]*shooter_cam_to_shot[3])
			) / (
				math.pow(shooter_cam_to_shot[1], 2) + 
				math.pow(shooter_cam_to_shot[2], 2) + 
				math.pow(shooter_cam_to_shot[3], 2)
			)
			local closest = { shooter_cam[1] + shooter_cam_to_shot[1]*tt, shooter_cam[2] + shooter_cam_to_shot[2]*tt, shooter_cam[3] + shooter_cam_to_shot[3]*tt}
			local length = math.abs(
				math.sqrt(
					math.pow((player_head[1]-closest[1]), 2) + 
					math.pow((player_head[2]-closest[2]), 2) + 
					math.pow((player_head[3]-closest[3]), 2)
				)
			)
			local frac_shot, trace_hit = client.trace_line(shooter, shot[1], shot[2], shot[3], player_head[1], player_head[2], player_head[3])
			local frac_final, trace_hit = client.trace_line(target, closest[1], closest[2], closest[3], player_head[1], player_head[2], player_head[3])
			return (length < 169) and (frac_shot > 0.99 or frac_final > 0.99)
		end,
		event = function(event)
			local lp = entity.get_local_player()
			if lp == nil or not entity.is_alive(lp) then return end
			local entindex = client.userid_to_entindex(event.userid)
			if entindex == lp or not entity.is_enemy(entindex) then return end
			if z.antibf.fired(lp, entindex, {event.x, event.y, event.z}) then
				data.jitterlist[entindex] = nil
				data.fakelist[entindex] = nil
				if data.customlog[entindex] == nil then
					data.customlog[entindex] = {
						idx = entindex,
						yaw = {left = 0, right = 0},
						fake = {fake = 0, lby = 0},
						should_update = true,
					}
				else
					data.customlog[entindex].should_update = true
				end
			end
		end
	}
	z.defensive = {
		cmd = 0,
		check = 0,
		defensive = 0,
		run = function(arg)
			z.defensive.cmd = arg.command_number
			ladder = (entity.get_prop(z, "m_MoveType") == 9)
		end,
		predict = function(arg)
			if arg.command_number == z.defensive.cmd + 1 then
				local tickbase = entity.get_prop(entity.get_local_player(), "m_nTickBase")
				z.defensive.defensive = math.abs(tickbase - z.defensive.check)
				z.defensive.check = math.max(tickbase, z.defensive.check or 0)
				z.defensive.cmd = 0
			end
		end
	}
	client.set_event_callback("level_init", function()
		z.defensive.check, z.defensive.defensive = 0, 0
	end)
	local scope_fix = false
	local scope_int = 0
	local shift_int = 0
	local list_shift = (function()
		local index, max = { }, 16
		for i=1, max do
			index[#index+1] = 0
			if i == max then
				return index
			end
		end
	end)()
	z.dtshift = function()
		local local_player = entity.get_local_player()
		local sim_time = entity.get_prop(local_player, "m_flSimulationTime")
		if local_player == nil or sim_time == nil then
			return
		end
		local tick_count = globals.tickcount()
		local shifted = math.max(unpack(list_shift))
		shift_int = shifted < 0 and math.abs(shifted) or 0
		list_shift[#list_shift+1] = sim_time/globals.tickinterval() - tick_count
		table.remove(list_shift, 1)
	end
	local animkeys = {
		dt = 0,
		duck = 0,
		hide = 0,
		safe = 0,
		baim = 0,
		fs = 0
	}
	local gradient = function(r1, g1, b1, a1, r2, g2, b2, a2, text)
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
	z.indicator = function()
		local me = entity.get_local_player()
		if me == nil then return end
		local rr,gg,bb = ui.get(z.menu["Visuals"].color)
		local width, height = client.screen_size()
		local r2, g2, b2, a2 = 55,55,55,255
		local highlight_fraction =  (globals.realtime() / 2 % 1.2 * 2) - 1.2
		local output = ""
		local text_to_draw = " S E N S E"
		for idx = 1, #text_to_draw do
			local character = text_to_draw:sub(idx, idx)
			local character_fraction = idx / #text_to_draw
			local r1, g1, b1, a1 = 255, 255, 255, 255
			local highlight_delta = (character_fraction - highlight_fraction)
			if highlight_delta >= 0 and highlight_delta <= 1.4 then
				if highlight_delta > 0.7 then
				   highlight_delta = 1.4 - highlight_delta
				end
				local r_fraction, g_fraction, b_fraction, a_fraction = r2 - r1, g2 - g1, b2 - b1
				r1 = r1 + r_fraction * highlight_delta / 0.8
				g1 = g1 + g_fraction * highlight_delta / 0.8
				b1 = b1 + b_fraction * highlight_delta / 0.8
			end
			output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, 255, text_to_draw:sub(idx, idx))
		end
		output = "L U A" .. output
		if ui.get(z.menu["Visuals"].spaces) then
			output = output:gsub(" ", "")
		end
		local menutbl = z.menu["Visuals"]
		local r,g,b,a = ui.get(menutbl.luacolor)
		renderer.text(width - (ui.get(menutbl.watermark) == "Right" and 55 or (width-55)), height - 555, r,g,b, 255, "c", 0, output)
		r,g,b,a = ui.get(menutbl.color)
		local w = width/2
		local h = height/2
		local tick = globals.tickcount()
		menutbl = z.menu["Keybinds"]
        --[[ ui.set(menutbl.left, "on hotkey")
        ui.set(menutbl.right, "on hotkey") ]]
        if ui.get(menutbl.left) and (script.cache.manual["tick"] < tick - 11) then
            script.cache.manual["aa"] = (script.cache.manual["aa"] == -90) and 0 or -90
            script.cache.manual["tick"] = tick
        end
        if ui.get(menutbl.right) and (script.cache.manual["tick"] < tick - 11) then
            script.cache.manual["aa"] = (script.cache.manual["aa"] == 90) and 0 or 90
            script.cache.manual["tick"] = tick
        end
		if ui.get(menutbl.forward) and (script.cache.manual["tick"] < tick - 11) then
            script.cache.manual["aa"] = (script.cache.manual["aa"] == 180) and 0 or 180
            script.cache.manual["tick"] = tick
        end
		menutbl = z.menu["Visuals"]
		local lifestate = entity.get_prop(me, "m_lifeState") ~= 0
		if lifestate or not ui.get(menutbl.indicator) then return end
		if ui.get(menutbl.arrows) then
			local rrr, ggg, bbb, aaa = ui.get(menutbl.keycolor)
			local rrrr, gggg, bbbb = ui.get(menutbl.colorkey)
			local leftkey = "<"
			local rightkey = ">"
			local flag = ui.get(menutbl.keys)
			if flag == "ts" then
				leftkey = "⯇"
				rightkey = "⯈"
				flag = "+"
				local yaw_body = math.max(-60, math.min(60, math.floor((entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11) or 0)*120-60+0.5)))
				if yaw_body > 0 and yaw_body > 60 then yaw_body = 60 end
				if yaw_body < 0 and yaw_body < -60 then yaw_body = -60 end
				renderer.line(w + -(42), h-8, w + -(42), h+8, rrrr, gggg, bbbb, yaw_body > 0 and 55 or 255)
				renderer.line(w + (42), h-8, w + (42), h+8, rrrr, gggg, bbbb, yaw_body < 0 and 55 or 255)
				h = h - 2.5
			end
			if flag == "best" then
				leftkey = "⮜"
				rightkey = "⮞"
				flag = "b"
			end
			if script.cache.manual["aa"] == 90 then
				renderer.text(w + 50, h, rrrr, gggg, bbbb, 255, "c" .. flag, 0, rightkey)
			else
				renderer.text(w + 50, h, rrr, ggg, bbb, aaa, "c" .. flag, 0, rightkey)
			end
			if script.cache.manual["aa"] == -90 then
				renderer.text(w + -(50), h, rrrr, gggg, bbbb, 255, "c" .. flag, 0, leftkey)
			else
				renderer.text(w + -(50), h, rrr, ggg, bbb, aaa, "c" .. flag, 0, leftkey)
			end
		end
		if ui.get(menutbl.center) then
			local yaw_body = math.max(-60, math.min(60, math.floor((entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11) or 0)*120-60+0.5)))
			if yaw_body > 0 and yaw_body > 60 then yaw_body = 60 end
			if yaw_body < 0 and yaw_body < -60 then yaw_body = -60 end
			scope_fix = entity.get_prop(me, "m_bIsScoped") ~= 0
			if scope_fix then 
				if scope_int < 40 then
					scope_int = scope_int + 1
				end
			else
				if scope_int > 0 then
					scope_int = scope_int - 1
				end
			end
			w = w + scope_int
			w = w - 2
			local ind_height = 25
			local r1, g1, b1, a1 = r,g,b, 255
			local r2, g2, b2, a2 = 155, 155, 155, 255
			if yaw_body > 0 then
				renderer.text( w, h + ind_height - 2.5, 255, 255, 255, 255, "cb", nil, gradient(r2, g2, b2, a2, r1, g1, b1, a1, "luasense") )
			else
				renderer.text( w, h + ind_height - 2.5, 255, 255, 255, 255, "cb", nil, gradient(r1, g1, b1, a1, r2, g2, b2, a2, "luasense") )
			end
			local dt_on = (ui.get(z.items.keys.dt[1]))
			local hs_on = (ui.get(z.items.keys.hs[1]))
			if ui.get(z.items.keys.fd[1]) then
				ind_height = ind_height + 8
				renderer.text( w, h + ind_height, r2, g2, b2, a2, "c-", nil, "DUCK" )
				if entity.get_prop(me, "m_flDuckAmount") > 0.1 then
					if animkeys.duck < 255 then
						animkeys.duck = animkeys.duck + 2.5
					end
					renderer.text( w, h + ind_height, r1, g1, b1, animkeys.duck, "c-", nil, "DUCK" )
				else
					animkeys.duck = 0
				end
			else
				animkeys.duck = 0
			end

			if ui.get(z.items.keys.sp[1]) == 'Force' then
				ind_height = ind_height + 8
				if animkeys.safe  < 255 then
					animkeys.safe = animkeys.safe  + 2.5
				end
				renderer.text( w, h + ind_height, r1, g1, b1, animkeys.safe , "c-", nil, "SAFE" )
			else
				animkeys.safe = 0
			end
			if ui.get(z.items.keys.fb[1]) == 'Force' then
				ind_height = ind_height + 8
				if animkeys.baim  < 255 then
					animkeys.baim = animkeys.baim  + 2.5
				end
				renderer.text( w, h + ind_height, r1, g1, b1, animkeys.baim , "c-", nil, "BAIM" )
			else
				animkeys.baim = 0
			end
			if dt_on then
				ind_height = ind_height + 8
				renderer.text( w, h + ind_height, r2, g2, b2, a2, "c-", nil, "DT" )
				if (shift_int > 0) or (z.defensive.defensive > 1) then
					if animkeys.dt  < 255 then
						animkeys.dt  = animkeys.dt  + 2.5
					end
					renderer.text( w, h + ind_height, r1, g1, b1, animkeys.dt , "c-", nil, "DT" )
				else
					animkeys.dt = 0
				end
			else
				animkeys.dt = 0
			end
			if hs_on then
				ind_height = ind_height + 8
				renderer.text( w, h + ind_height, r2, g2, b2, a2, "c-", nil, "HS" )
				if not (dt_on) then
					if animkeys.hide  < 255 then
						animkeys.hide  = animkeys.hide  + 2.5
					end
					renderer.text( w, h + ind_height, r1, g1, b1, animkeys.hide , "c-", nil, "HS" )
				else
					animkeys.hide = 0
				end
			else
				animkeys.hide = 0
			end
			if ui.get(z.menu["Keybinds"].fs) then
				ind_height = ind_height + 8
				if animkeys.fs  < 255 then
					animkeys.fs = animkeys.fs  + 2.5
				end
				renderer.text( w, h + ind_height, r1, g1, b1, animkeys.fs , "c-", nil, "FS" )
			else
				animkeys.fs = 0
			end
		end
	end
	z.reset = function()
		script.cache.manual["tick"] = 0
		script.cache.manual["aa"] = 0
	end
    z.events = {
        post_update_clientside_animation = { z.aa.breakers },
        paint_ui = { z.hideshowetc.title, z.hideshowetc.handler, z.indicator },
        setup_command = { z.aa.builder },
		run_command = { z.defensive.run },
		predict_command = { z.defensive.predict },
		bullet_impact = { z.antibf.event },
        shutdown = { z.hideshowetc.resetmenu },
		net_update_start = { z.dtshift },
		round_prestart = { z.reset }
    }
    for index, value in next, z.events do 
        for i, v in next, value do client.set_event_callback(index, v) end
    end
end)({
    ref = function(...) return { ui.reference(...) } end,
    clamp = function(x) if x == nil then return 0 end x = (x % 360 + 360) % 360 return x > 180 and x - 360 or x end,
    contains = function(z,x) for i, v in next, z do if v == x then return true end end return false end,
    states = { "Global", "Standing", "Moving", "Air", "Air duck", "Duck", "Duck moving", "Slow motion" },
    getstate = function(me, air, duck, speed, fl, slowcheck)
        local state = "Global"
        if air and duck then state = "Air duck" end
        if air and not duck then state = "Air" end
        if duck and not air and speed < 1.1 then state = "Duck" end
        if duck and not air and speed > 1.1 then state = "Duck moving" end
        if speed < 1.1 and not air and not duck then state = "Standing" end
        if speed > 1.1 and not air and not duck then state = "Moving" end
		if slowcheck and not air and not duck and speed > 1.1 then state = "Slow motion" end
        return state
    end,
})
