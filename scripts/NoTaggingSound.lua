local mod = get_mod("NoTaggingSound")
local dmf = get_mod("DMF")
local util = mod:io_dofile("NoTaggingSound/scripts/util")
local Data = mod:io_dofile("NoTaggingSound/scripts/NoTaggingSound_data")
dmf:echo("lol")

-- local function _update_widgets(setting_id)
-- 	local view = Managers.ui:view_instance("dmf_options_view")
-- 	local widgets = view._settings_category_widgets[mod:get_name()]
-- 	mod:dtf(view, "widgets", 99)
-- 	for _, option in pairs(Data.options.widgets) do
-- 		local val = mod:get(option.setting_id)
-- 		if option.type == "checkbox" and option.sub_widgets then
-- 			for _, sub_option in pairs(option.sub_widgets) do
-- 				for _, w in pairs(widgets) do
-- 					if w.widget and w.widget.content and w.widget.content.entry then
-- 						if w.widget.content.entry.display_name == mod:localize(sub_option.setting_id) then
-- 							--w.widget.visible = mod:get(option.setting_id)
-- 							w.widget.content.disabled = not val
-- 							w.widget.content.hotspot.disabled = not val
-- 							-- if not val then
-- 							-- end
-- 							break
-- 						end
-- 					end
-- 				end
-- 			end
-- 			if option.setting_id == setting_id then return end
-- 		end
-- 	end
-- end

-- function mod.on_setting_changed(setting_id) _update_widgets(setting_id) end

-- mod:hook_safe(CLASS.BaseView, "_on_view_load_complete", function(self, loaded, ...)
-- 	if self.view_name == "dmf_options_view" then _update_widgets() end
-- end)

local function _check_pos_within_view(pos)
	local player = util.player()
	local first_person_system = ScriptUnit.has_extension(player, "first_person_system")
	if not first_person_system then return false end

	local R = first_person_system:is_within_default_view(pos)
	if not R then
		dmf:echo("NOT IN VIEW")
		Managers.ui:play_3d_sound("wwise/events/ui/play_smart_tag_location_threat_enter_others", pos)
	end
	return R
end

local function _check_unit_within_view(unit)
	if not unit then return false end
	-- local pos = POSITION_LOOKUP[unit] --Unit.world_position(unit, 1)
	local pos = Unit.world_position(unit, 1)
	return _check_pos_within_view(pos)
end

local function _tag_unit_pos(tag_instance)
	local unit = tag_instance:target_unit()
	return unit, unit and Unit.world_position(unit, 1) or tag_instance:target_location()
	-- if unit then
	--     local pos = Unit.world_position(unit, 1)
	--     return unit, pos
	-- else
	--     return nil, tag_instance:target_location()
	-- end
end

mod:hook("HudElementSmartTagging", "_play_tag_sound", function(func, self, tag_instance, event_name)
	local unit, pos = _tag_unit_pos(tag_instance)
	util.set("last_tag", {
		template = tag_instance._template,
		tagger = tag_instance._tagger_unit,
		unit = tag_instance._target_unit,
		pos = Vector3Box(pos),
	})

	util.debug:draw_sphere("test", pos, Color.red())

	if unit then
		local is_item = unit and ScriptUnit.has_extension(unit, "interactee_system")
		if is_item and mod:get("ping_mute_items") then
			return -- mute items
		end

		if
			mod:get("ping_mute_enemies") and (not mod:get("ping_unmute_enemies_behind") or _check_pos_within_view(pos))
		then
			mod:echo("mute enemy")
			return -- mute enemies
		end
	else
		local marker_type = tag_instance:template().marker_type
		if marker_type == "location_ping" and mod:get("ping_mute_location_ping") then return end
		if marker_type == "location_attention" and mod:get("ping_mute_location_attention") then return end
		if marker_type == "location_threat" and mod:get("ping_mute_location_threat") then return end
	end

	-- if mod:get("ping_mute_all") then
	--     local unit, pos = _tag_unit_pos(tag_instance)
	--     local is_item = unit and ScriptUnit.has_extension(unit, "interactee_system")

	--     -- OVERRIDE DURATION
	--     -- local t = Managers.time:time("gameplay")
	--     -- local expire_time = t + 3
	--     -- tag_instance:set_expire_time(expire_time)

	--     if is_item then -- items
	--         should_mute = mod:get("ping_mute_items")
	--     elseif not unit then -- loose markers
	--         print("a")
	--     else -- units
	--         if not mod:get("ping_unmute_all_behind") or _check_pos_within_view(pos) then

	--         end
	--     end

	--     _last_pos = Vector3Box(pos)
	--     if not mod:get("ping_unmute_all_behind") or _check_pos_within_view(pos) then
	--         return -- mute sound
	--     end
	-- end

	-- wwise/events/ui/play_smart_tag_location_threat_enter_others
	return func(self, tag_instance, event_name)
end)

function map(t, fn)
	local result = {}
	for i, v in ipairs(t) do
		result[i] = fn(v)
	end
	return result
end

local UIRenderer = require("scripts/managers/ui/ui_renderer")
local UIFonts = require("scripts/managers/ui/ui_fonts")
mod:hook_safe(UIRenderer, "begin_pass", function(self, ui_scenegraph, input_service, dt, render_settings)
	-- for i = 0, Keyboard.num_buttons() - 1 do
	-- 	if Keyboard.button(i) > 0 then
	-- 		local name = Keyboard.button_name(i)
	-- 		local id = Keyboard.button_id(name)
	-- 		local index = Keyboard.button_index(name)
	-- 		local locale_name = Keyboard.button_locale_name(id)

	-- 		overlay = string.format("%s\n%s", overlay, name)
	-- 	end
	-- end

	if rawget(ui_scenegraph, "software_cursor") then
		local overlay = ""
		for _, device in ipairs(Managers.input:debug_get_all_used_devices()) do
			local held = device:buttons_held()
			-- if #held > 0 then
			-- 	local indent = table.concat(map(held, function(x) return "\t" .. x end), "\n")
			-- 	overlay = overlay .. device:debug_name() .. "\n" .. indent .. "\n"
			-- end
			if #held > 0 then
				local text = table.concat(held, "\n")
				overlay = overlay .. text .. "\n"
			end
		end

		-- -- dump scenegraphs
		-- if Keyboard.button(Keyboard.button_index("h")) > 0 then
		-- 	local s = string.sub(tostring(ui_scenegraph), 8)
		-- 	mod:dtf(ui_scenegraph, "ui_scenegraph_" .. s, 5)
		-- end

		if overlay ~= "" then
			local text = overlay
			local font_size = 16
			local font_type = "proxima_nova_bold"
			local position = { 100, 100, 0 }
			local size = ui_scenegraph.screen.size
			local color = Color.white(255, true)
			local text_options = {
				shadow = true,
			}
			UIRenderer.draw_text(self, text, font_size, font_type, position, size, color, text_options)
		end
	end
end)

-- quick and dirty keybinds without using NoTaggingSound_data.lua
mod:hook_safe(CLASS.InputManager, "update", function(self, dt, t)
	if Keyboard.pressed(Keyboard.button_index("6")) then
		mod:set("ping_unmute_enemies_behind", true, false)
		-- dmf.mod_setting_changed_event(mod, "ping_unmute_enemies_behind")
		return
	end
	if Keyboard.pressed(Keyboard.button_index("7")) then
		mod:set("ping_unmute_enemies_behind", false, false)
		-- dmf.mod_setting_changed_event(mod, "ping_unmute_enemies_behind")
		return
	end

	if Keyboard.pressed(Keyboard.button_index("f2")) then
		dmf:echo("Pressed F2")

		Managers.event:trigger("event_clear_notifications")

		local tag = util.get("last_tag")
		if tag then util.debug:draw_sphere("test", tag.pos, Color.green()) end
		return
	end

	if Keyboard.pressed(Keyboard.button_index("t")) then
		local tag = util.get("last_tag")
		if tag and (not tag.unit or HEALTH_ALIVE[tag.unit]) then
			util.smart_tag(tag.template.name, tag.tagger, tag.unit, tag.unit and nil or tag.pos:unbox())
		end
		return
	end
end)
