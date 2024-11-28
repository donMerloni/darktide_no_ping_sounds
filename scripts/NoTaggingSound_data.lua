local mod = get_mod("NoTaggingSound")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		collapsed_widgets = { "ping_mute_enemies", "ping_unmute_enemies_behind" },
		widgets = {
			{
				setting_id = "ping_mute_enemies",
				type = "checkbox",
				default_value = false,
				sub_widgets = {
					{
						setting_id = "ping_unmute_enemies_behind",
						type = "checkbox",
						default_value = false,
					},
				},
			},
			{
				setting_id = "ping_mute_items",
				type = "checkbox",
				default_value = false,
			},
			{
				setting_id = "ping_mute_location_ping",
				type = "checkbox",
				default_value = false,
			},
			{
				setting_id = "ping_mute_location_attention",
				type = "checkbox",
				default_value = false,
			},
			{
				setting_id = "ping_mute_location_threat",
				type = "checkbox",
				default_value = false,
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
			{
				setting_id = "debug_mode",
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
				},
			},
		},
	},
}
