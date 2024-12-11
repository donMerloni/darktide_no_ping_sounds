local mod = get_mod("NoTaggingSound")
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
					util.debug:draw_sphere("1", pos, Color.green(), 0.25)
					util.debug:draw_sphere("2", j_head, Color.red(), 0.25)
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
