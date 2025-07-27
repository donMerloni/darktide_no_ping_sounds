local mod = get_mod("NoPingSounds")
local widgets = {}

-- common mute settings
local function ping_mute_setting(name, default, default_in_front)
	local key = "ping_mute_" .. name
	widgets[#widgets + 1] = {
		setting_id = key,
		type = "checkbox",
		default_value = default,
		sub_widgets = {
			{
				setting_id = key .. "_in_front",
				type = "checkbox",
				default_value = default_in_front,
			},
		},
	}
end

-- enemy ping
ping_mute_setting("enemy", true, true)

-- item ping
ping_mute_setting("item", true, false)

-- location marker
ping_mute_setting("location_ping", true, false)

-- eye marker
ping_mute_setting("location_attention", true, false)

-- red skull marker
ping_mute_setting("location_threat", true, false)

widgets[#widgets + 1] = {
	setting_id = "debug",
	type = "checkbox",
	default_value = false,
	sub_widgets = {
		{
			setting_id = "debug_repeat_ping",
			type = "keybind",
			default_value = {},
			keybind_trigger = "pressed",
			keybind_type = "function_call",
			function_name = "debug_repeat_ping",
		},
		{
			setting_id = "ping_duration",
			type = "checkbox",
			default_value = false,
			sub_widgets = {
				{
					setting_id = "ping_duration_seconds",
					type = "numeric",
					default_value = 15,
					range = { 1, 60 * 2 },
				},
			},
		},
	},
}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets,
	},
}
