local mod = get_mod("NoPingSounds")
local util = mod:io_dofile(mod:get_name() .. "/scripts/util")(mod)

local Player
local PlayerCamera
local LastTag

-- cache global functions
local Unit_world_position = Unit.world_position
local Unit_node = Unit.node
local Unit_has_node = Unit.has_node
local Camera_inside_frustum = Camera.inside_frustum

-- cache settings locally for the sake of performance
local settings_ping_mute_enemy = mod:get("ping_mute_enemy")
local settings_ping_mute_enemy_doubletag = mod:get("ping_mute_enemy_doubletag")
local settings_ping_mute_item = mod:get("ping_mute_item")
local settings_ping_mute_location_ping = mod:get("ping_mute_location_ping")
local settings_ping_mute_location_attention = mod:get("ping_mute_location_attention")
local settings_ping_mute_location_threat = mod:get("ping_mute_location_threat")
local settings_debug = mod:get("debug")
local settings_ping_duration = mod:get("ping_duration")
local settings_ping_duration_seconds = mod:get("ping_duration_seconds")

-- stylua: ignore
function mod.on_setting_changed(key)
	local value = mod:get(key)

	-- update local settings cache
	if key == "ping_mute_enemy" then settings_ping_mute_enemy = value return end
	if key == "ping_mute_enemy_doubletag" then settings_ping_mute_enemy_doubletag = value return end
	if key == "ping_mute_item" then settings_ping_mute_item = value return end
	if key == "ping_mute_location_ping" then settings_ping_mute_location_ping = value return end
	if key == "ping_mute_location_attention" then settings_ping_mute_location_attention = value return end
	if key == "ping_mute_location_threat" then settings_ping_mute_location_threat = value return end
	if key == "debug" then settings_debug = value return end
	if key == "ping_duration" then settings_ping_duration = value return end
	if key == "ping_duration_seconds" then settings_ping_duration_seconds = value return end
end

-- grab the player whenever it updates
local function UIManager_grab_player(self, ...)
	local hud = self and self._hud
	if hud then
		Player = hud:player_unit()
		PlayerCamera = hud:player_camera()
	end
end
mod:hook_safe("UIManager", "create_player_hud", UIManager_grab_player)
UIManager_grab_player(Managers and Managers.ui)

local groups = {
	enemy = function(tag)
		if settings_ping_mute_enemy == 0 then
			return false
		end
		local unit = tag._target_unit
		return settings_ping_mute_enemy == 1
			or Camera_inside_frustum(PlayerCamera, Unit_world_position(unit, 1)) > 0
			or Unit_has_node(unit, "j_head")
				and Camera_inside_frustum(PlayerCamera, Unit_world_position(unit, Unit_node(unit, "j_head"))) > -0.1
	end,

	double_tag = function(tag)
		if settings_ping_mute_enemy_doubletag == 0 then
			return false
		end
		local unit = tag._target_unit
		return settings_ping_mute_enemy_doubletag == 1
			or Camera_inside_frustum(PlayerCamera, Unit_world_position(unit, 1)) > 0
			or Unit_has_node(unit, "j_head")
				and Camera_inside_frustum(PlayerCamera, Unit_world_position(unit, Unit_node(unit, "j_head"))) > -0.1
	end,

	object = function(tag)
		return settings_ping_mute_item
	end,

	location_ping = function(tag)
		return settings_ping_mute_location_ping
	end,

	location_attention = function(tag)
		return settings_ping_mute_location_attention
	end,

	location_threat = function(tag)
		return settings_ping_mute_location_threat
	end,
}

local function unknown_group(tag)
	mod:echo("unknown group '%s'", tag._template.group)
	return false
end

-- -- Higher-level function that could probably be hooked instead to also change stuff like outlines:
-- local SmartTagSettings = require("scripts/settings/smart_tag/smart_tag_settings")
-- mod:hook("SmartTagSystem", "set_tag", function(original, self, template_name, tagger_unit, target_unit, target_location)
-- 	local template = SmartTagSettings[template_name]
-- 	return original(self, template_name, tagger_unit, target_unit, target_location)
-- end)

mod:hook("HudElementSmartTagging", "_play_tag_sound", function(original, self, tag_instance, event_name)
	if settings_debug then
		local tagger = tag_instance._tagger_unit
		if tagger == Player then
			LastTag = {
				template = tag_instance._template,
				tagger = tagger,
				unit = tag_instance._target_unit,
				pos = tag_instance._target_location,
			}

			if settings_ping_duration then
				local t = Managers.time:time("gameplay")
				tag_instance._expire_time = t + settings_ping_duration_seconds
			end
		end
	end

	if (groups[tag_instance._template.group] or unknown_group)(tag_instance) then
		return -- mute
	end

	return original(self, tag_instance, event_name)
end)

function mod.debug_repeat_ping()
	if settings_debug and LastTag then
		util.smart_tag(LastTag.template.name, Player, LastTag.unit, LastTag.pos and LastTag.pos:unbox())
	end
end

if settings_debug then
	mod:hook_require("scripts/managers/ui/ui_renderer", function(UIRenderer)
		mod:hook_safe(UIRenderer, "begin_pass", function(self, ui_scenegraph, input_service, dt, render_settings)
			util.debug:draw_input(UIRenderer, self, ui_scenegraph)
		end)
	end)

	Managers.event:trigger("event_clear_notifications")
end
