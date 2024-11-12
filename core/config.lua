--- Priority 1 = High priority, Priority 0 = Low priority ---

local config = {
	images = {
		logo = { path = "assets/images/logo.png", priority = 1 }
	},
	sounds = {
		music = { path = "assets/sounds/background_music.mp3", priority = 1 }
	},
	fonts = {
		mainFont = { path = "assets/fonts/main.ttf", size = 14, priority = 1 }
	},
	models = {
		map = { "assets/objects/scene", priority = 1 },
		player = { "assets/objects/player", priority = 1 }
	},
	data = {
		settings = { "assets/data/settings.json", priority = 1 }
	}
}

return config