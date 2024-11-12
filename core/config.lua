local config = {
	images = {
		logo = "assets/images/logo.png"
	},
	sounds = {
		music = "assets/sounds/background_music.mp3"
	},
	fonts = {
		mainFont = {path = "assets/fonts/main.ttf", size = 14}
	},
	models = {
		map = "assets/objects/scene",
		player = "assets/objects/player"
	},
	data = {
		settings = "assets/data/settings.json"
	},
	threads = {
		resourceKinds = {
			image = {
				requestKey = "imagePath",
				resourceKey = "imageData",
				constructor = function(path)
					if love.image.isCompressed(path) then
						return love.image.newCompressedData(path)
					else
						return love.image.newImageData(path)
					end
				end,
				postProcess = function(data)
					return love.graphics.newImage(data)
				end
			},
			staticSource = {
				requestKey = "staticPath",
				resourceKey = "staticSource",
				constructor = function(path)
					return love.audio.newSource(path, "static")
				end
			},
			streamSource = {
				requestKey = "streamPath",
				resourceKey = "streamSource",
				constructor = function(path)
					return love.audio.newSource(path, "stream")
				end
			},
			soundData = {
				requestKey = "soundDataPathOrDecoder",
				resourceKey = "soundData",
				constructor = love.sound.newSoundData
			},
			font = {
				requestKey = "fontPath",
				resourceKey = "fontData",
				constructor = function(path) return love.filesystem.newFileData(path) end,
				postProcess = function(data, resource)
					local path, size = unpack(resource.requestParams)
					return love.graphics.newFont(data, size)
				end
			},
			BMFont = {
				requestKey = "fontBMPath",
				resourceKey = "fontBMData",
				constructor = function(path) return love.filesystem.newFileData(path) end,
				postProcess = function(data, resource)
					local imagePath, glyphsPath = unpack(resource.requestParams)
					local glyphs = love.filesystem.newFileData(glyphsPath)
					return love.graphics.newFont(glyphs, data)
				end
			},
			imageData = {
				requestKey = "imageDataPath",
				resourceKey = "rawImageData",
				constructor = love.image.newImageData
			},
			compressedData = {
				requestKey = "compressedDataPath",
				resourceKey = "rawCompressedData",
				constructor = love.image.newCompressedData
			},
			model3D = {
				requestKey = "modelPath",
				resourceKey = "model3D",
				constructor = function(path)
					return require("3DreamEngine").loadModel(path)
				end,
				postProcess = function(data)
					return data
				end
			},
			textData = {
				requestKey = "rawDataPath",
				resourceKey = "rawData",
				constructor = love.filesystem.read
			}
		}
	}
}

return config