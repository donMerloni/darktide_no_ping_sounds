return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`NoTaggingSound` encountered an error loading the Darktide Mod Framework.")

		new_mod("NoTaggingSound", {
			mod_script       = "NoTaggingSound/scripts/Mod",
			mod_data         = "NoTaggingSound/scripts/Mod_data",
			mod_localization = "NoTaggingSound/scripts/Mod_lang",
		})
	end,
	packages = {},
}
