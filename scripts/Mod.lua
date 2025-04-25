local mod = get_mod("NoPingSounds")
local util = mod:io_dofile(mod:get_name() .. "/scripts/util")(mod)

local Unit_world_position = Unit.world_position
local Unit_node = Unit.node
local Camera_inside_frustum = Camera.inside_frustum
local print = util.print

local settings = util.get_settings()

function mod.on_setting_changed(setting_id)
	settings[setting_id] = mod:get(setting_id)
end

local function player()
	local player = Managers.player:local_player_safe(1)
	return player and player.player_unit
end

local groups = {
	enemy = function(tag)
		if settings.ping_mute_enemy then
			if settings.ping_mute_in_front then
				local unit = tag._target_unit
				local camera = Managers.state.camera:camera("player1")

				if settings.debug then
					local pos = Unit_world_position(unit, 1)
					local j_head = Unit_world_position(unit, Unit_node(unit, "j_head"))
					-- util.debug:draw_sphere("1", pos, Color.green(), 0.25)
					-- util.debug:draw_sphere("2", j_head, Color.red(), 0.25)
					print("pos %s", Camera_inside_frustum(camera, pos))
					print("head %s", Camera_inside_frustum(camera, j_head))
				end

				local pos = Unit_world_position(unit, 1)
				if Camera_inside_frustum(camera, pos) > 0 then
					return true
				end

				local j_head = Unit_world_position(unit, Unit_node(unit, "j_head"))
				if Camera_inside_frustum(camera, j_head) > -0.1 then
					return true
				end

				if settings.debug then
					print("enemy NOT visible")
				end
				return false
			end

			return true
		end

		return false
	end,
	object = function(tag)
		return settings.ping_mute_item
	end,
	location_ping = function(tag)
		return settings.ping_mute_location_ping
	end,
	location_attention = function(tag)
		return settings.ping_mute_location_attention
	end,
	location_threat = function(tag)
		return settings.ping_mute_location_threat
	end,
}

mod:hook("HudElementWorldMarkers", "_create_widget", function(func, self, name, definition)
	for k, v in pairs(definition.style) do
		definition.style[k].color = Color.green(255, true)
	end
	-- mod:dtf(definition, "dump.json", 5)
	return func(self, name, definition)
end)
mod:hook("HudElementWorldMarkers", "_template_by_type", function(func, self, marker_type, clone)
	local template = func(self, marker_type, clone)
	mod:hook_safe(template, "update_function", function(parent, ui_renderer, widget, marker, template, dt, t)
		print(marker.data.distance_text)
	end)
	return template
end)
-- mod:hook("HudElementWorldMarkers", "_create_widget_by_type", function(func, self, name, template)
-- 	local widget = func(self, name, template)
-- 	for k, v in pairs(widget.style) do
-- 		v.color = Color.blue(255, true)
-- 	end
-- 	--mod:dtf({ name, template, widget }, "dump.json", 5)
-- 	return widget
-- end)

mod:hook_safe("OutlineSystem", "update", function(self, context, dt, t)
	-- if not self._visible or self._total_num_outlines == 0 then
	-- 	return
	-- end

	for unit, extension in pairs(self._unit_extension_data) do
		-- for _, outline in ipairs(extension.outlines) do
		-- 	for _, material_layer in ipairs(outline.material_layers) do
		-- 		Unit.set_vector3_for_material(unit, material_layer, "outline_color", Vector3(1, 1, 1))
		-- 		print("%s", material_layer)
		-- 		Unit.set_vector3_for_materials(unit, "outline_color", Vector3(1, 1, 1), true)
		-- 		print("%s", material_layer)
		-- 	end
		-- end
		if util.keybind:hold("h") then
			print(Unit.get_data(unit, "blood_color"))
		end
		Unit.set_vector3_for_materials_in_unit_and_childs(unit, "outline_color", Vector3(1, 1, 0))

		-- if outline then
		-- 	Unit.set_vector3_for_materials(unit, "outline_color", Vector3(0, 0, 1), true)
		-- end
	end
end)

mod:dtf(Color.yellow(127, true), "dump.json", 5)
mod:hook("HudElementSmartTagging", "_play_tag_sound", function(func, self, tag_instance, event_name)
	local group = tag_instance._template.group

	if settings.debug then
		local tag = {
			template = tag_instance._template,
			tagger = tag_instance._tagger_unit,
			unit = tag_instance._target_unit,
			pos = tag_instance._target_location,
		}
		if tag.tagger == player() then
			util.set("last_tag", tag)
		end
	end

	if settings.ping_duration then
		local t = Managers.time:time("gameplay")
		tag_instance._expire_time = t + settings.ping_duration_seconds
	end

	if groups[group](tag_instance) then
		return -- mute
	end

	return func(self, tag_instance, event_name)
end)

function mod.debug_repeat_ping()
	if settings.debug then
		util.get("last_tag", function(t)
			if not t.unit or (Unit.is_valid(t.unit) and SmartTag.validate_target_unit(t.unit)) then
				util.smart_tag(t.template.name, player(), t.unit, t.pos and t.pos:unbox())
			end
		end)
	end
end

if settings.debug then
	mod:hook_require("scripts/managers/ui/ui_renderer", function(UIRenderer)
		mod:hook_safe(UIRenderer, "begin_pass", function(self, ui_scenegraph, input_service, dt, render_settings)
			util.debug:draw_input(UIRenderer, self, ui_scenegraph)
		end)
	end)

	Managers.event:trigger("event_clear_notifications")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- local RelicActive = false

-- mod:hook_safe("ActionZealotChannel", "start", function(self, action_settings, t, time_scale, action_start_params)
-- 	print("RELIC START")
-- 	RelicActive = true
-- end)

-- mod:hook_safe("ActionZealotChannel", "finish", function(self, reason, data, t, time_in_action)
-- 	print("RELIC FINISH (%s)", reason)
-- 	RelicActive = false
-- end)

-- mod:hook_require("scripts/settings/equipment/weapon_templates/combat_abilities/zealot_relic", function(weapon_templates)
-- 	weapon_templates.actions["action_wield"].prevent_sprint = true
-- 	weapon_templates.actions["action_zealot_channel"].prevent_sprint = true
-- 	weapon_templates.actions["action_zealot_channel"].stop_input = nil
-- 	return weapon_templates
-- end)

-- mod:hook(
-- 	"ActionHandler",
-- 	"start_action",
-- 	function(
-- 		func,
-- 		self,
-- 		id,
-- 		action_objects,
-- 		action_name,
-- 		action_params,
-- 		action_settings,
-- 		used_input,
-- 		t,
-- 		transition_type,
-- 		condition_func_params,
-- 		automatic_input,
-- 		reset_combo_override
-- 	)
-- 		if RelicActive and action_name ~= "action_zealot_channel" then
-- 			return
-- 		end

-- 		if action_settings and action_settings.anim_event == "equip_relic" then
-- 			RelicActive = true
-- 			print("RELIC EQUIPPING")
-- 		end

-- 		return func(
-- 			self,
-- 			id,
-- 			action_objects,
-- 			action_name,
-- 			action_params,
-- 			action_settings,
-- 			used_input,
-- 			t,
-- 			transition_type,
-- 			condition_func_params,
-- 			automatic_input,
-- 			reset_combo_override
-- 		)
-- 	end
-- )

-- mod:hook("ActionHandler", "_update_stop_input", function(func, ...)
-- 	if RelicActive then
-- 		return
-- 	end
-- 	return func(...)
-- end)
