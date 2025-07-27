local mod = get_mod("NoPingSounds")
local util = mod:io_dofile(mod:get_name() .. "/scripts/util")(mod)

-- cache global functions
local Unit_world_position = Unit.world_position
local Unit_node = Unit.node
local Camera_inside_frustum = Camera.inside_frustum

-- cache settings locally for the sake of performance
local settings = util.get_settings()
local settings_ping_mute_enemy = settings.ping_mute_enemy
local settings_ping_mute_enemy_in_front = settings.ping_mute_enemy_in_front
local settings_ping_mute_item = settings.ping_mute_item
local settings_ping_mute_item_in_front = settings.ping_mute_item_in_front
local settings_ping_mute_location_ping = settings.ping_mute_location_ping
local settings_ping_mute_location_ping_in_front = settings.ping_mute_location_ping_in_front
local settings_ping_mute_location_attention = settings.ping_mute_location_attention
local settings_ping_mute_location_attention_in_front = settings.ping_mute_location_attention_in_front
local settings_ping_mute_location_threat = settings.ping_mute_location_threat
local settings_ping_mute_location_threat_in_front = settings.ping_mute_location_threat_in_front
local settings_debug = settings.debug
local settings_ping_duration = settings.ping_duration
local settings_ping_duration_seconds = settings.ping_duration_seconds

-- stylua: ignore
function mod.on_setting_changed(key)
	local value = mod:get(key)
	settings[key] = value

	-- update local settings cache
	if key == "ping_mute_enemy" then settings_ping_mute_enemy = value return end
	if key == "ping_mute_enemy_in_front" then settings_ping_mute_enemy_in_front = value return end
	if key == "ping_mute_item" then settings_ping_mute_item = value return end
	if key == "ping_mute_item_in_front" then settings_ping_mute_item_in_front = value return end
	if key == "ping_mute_location_ping" then settings_ping_mute_location_ping = value return end
	if key == "ping_mute_location_ping_in_front" then settings_ping_mute_location_ping_in_front = value return end
	if key == "ping_mute_location_attention" then settings_ping_mute_location_attention = value return end
	if key == "ping_mute_location_attention_in_front" then settings_ping_mute_location_attention_in_front = value return end
	if key == "ping_mute_location_threat" then settings_ping_mute_location_threat = value return end
	if key == "ping_mute_location_threat_in_front" then settings_ping_mute_location_threat_in_front = value return end
	if key == "debug" then settings_debug = value return end
	if key == "ping_duration" then settings_ping_duration = value return end
	if key == "ping_duration_seconds" then settings_ping_duration_seconds = value return end
end

-- cache player
local Player
local PlayerCamera

local function UIManager_grab_player(self, ...)
	local hud = self._hud
	if hud then
		Player = hud:player_unit()
		PlayerCamera = hud:player_camera()
	end
end

-- grab the player whenever it updates
mod:hook_safe("UIManager", "create_player_hud", UIManager_grab_player)
UIManager_grab_player(Managers.ui) -- don't die when reloading mods...

local groups = {
	enemy = function(tag)
		if not settings_ping_mute_enemy then
			return false
		end
		local unit = tag._target_unit
		return not settings_ping_mute_enemy_in_front
			or Camera_inside_frustum(PlayerCamera, Unit_world_position(unit, 1)) > 0
			or Camera_inside_frustum(PlayerCamera, Unit_world_position(unit, Unit_node(unit, "j_head"))) > -0.1
	end,

	object = function(tag)
		return settings_ping_mute_item
			and (
				not settings_ping_mute_item_in_front
				or Camera_inside_frustum(PlayerCamera, Unit_world_position(tag._target_unit, 1)) > 0
			)
	end,

	location_ping = function(tag)
		return settings_ping_mute_location_ping
			and (
				not settings_ping_mute_location_ping_in_front
				or Camera_inside_frustum(PlayerCamera, tag._target_location:unbox()) > 0
			)
	end,

	location_attention = function(tag)
		return settings_ping_mute_location_attention
			and (
				not settings_ping_mute_location_attention_in_front
				or Camera_inside_frustum(PlayerCamera, tag._target_location:unbox()) > 0
			)
	end,

	location_threat = function(tag)
		return settings_ping_mute_location_threat
			and (
				not settings_ping_mute_location_threat_in_front
				or Camera_inside_frustum(PlayerCamera, tag._target_location:unbox()) > 0
			)
	end,
}

mod:hook("HudElementSmartTagging", "_play_tag_sound", function(func, self, tag_instance, event_name)
	if settings_debug then
		local tagger = tag_instance._tagger_unit
		if tagger == Player then
			util.set("last_tag", {
				template = tag_instance._template,
				tagger = tagger,
				unit = tag_instance._target_unit,
				pos = tag_instance._target_location,
			})

			if settings_ping_duration then
				local t = Managers.time:time("gameplay")
				tag_instance._expire_time = t + settings_ping_duration_seconds
			end
		end
	end

	if groups[tag_instance._template.group](tag_instance) then
		return -- mute
	end

	return func(self, tag_instance, event_name)
end)

function mod.debug_repeat_ping()
	if settings_debug then
		util.get("last_tag", function(t)
			util.smart_tag(t.template.name, Player, t.unit, t.pos and t.pos:unbox())
		end)
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
