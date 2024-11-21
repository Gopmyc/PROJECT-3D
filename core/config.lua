--- LOADER PRIORITY : Priority 1 = High priority, Priority 0 = Low priority ---

local config = {
	engineConfig = {
		rendering = {
			autoExposure	= true,
			refraction		= true,
			dayTime			= 0.5,
			animateTime		= true
		},
	},
	states = {
		loading		=	{ path = "core/states/loading",							id = "loading"	},
		--menu		=	{ path = "core/states/menu",							id = "menu"		},
		game		=	{ path = "core/states/game",							id = "game"		},
	},
	loader = {
		assets = {
			images = {
				default		= { path = "assets/UI/items/default.png",			priority = 1 },
				backpack	= { path = "assets/UI/items/backpack.png",			priority = 1 },
				book		= { path = "assets/UI/items/book.png",				priority = 1 },
				clover		= { path = "assets/UI/items/clover.png",			priority = 1 },
				heart		= { path = "assets/UI/items/heart.png",				priority = 1 },
				spade		= { path = "assets/UI/items/spade.png",				priority = 1 },
				tile		= { path = "assets/UI/items/tile.png",				priority = 1 },
				document	= { path = "assets/UI/items/document.png",			priority = 1 },
				map			= { path = "assets/UI/items/map.png",				priority = 1 },
			},
			sounds = {
				music		= { path = "assets/sounds/background_music.mp3",	priority = 1 }
			},
			fonts = {
				mainFont	= { path = "assets/fonts/main.ttf", size = 14,		priority = 1 }
			},
			models = {
				map			= { path = "assets/models/scene",					priority = 1 },
				player		= { path = "assets/models/player",					priority = 1 }
			},
			shaders = {
				blur		= { path = "assets/shaders/blur_shader.glsl",		priority = 1 },
			},
			data = {
				settings	= { path = "assets/data/settings.json",				priority = 1 },
			},
		},
	},
	color = {
		slot_inventory			= { 36 / 255, 36 / 255, 36 / 255, 200 / 255	},
		background_inventory	= { 46 / 255, 46 / 255, 46 / 255, 75 / 255	},
	},
	-- // TODO : Make the cinematic system
	cinematics = {
		intro = {
			{ action = "fadeIn",	duration = 2 },
			{ action = "fadeOut",	duration = 2 },
		},
	},
}

return config