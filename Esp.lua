local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ali-lov3/AstraUiLib/refs/heads/main/Source.lua"))()

local Window = Library.CreateWindow({
	Title = "Astra",
	Logo = 0,
	Anonymous = false,
	ConfigFolder = "AstraConfigs"
})

local ExampleTab = Window:CreateTab({
	Name = "Example",
	Icon = "layout"
})

local LeftSection = ExampleTab:CreateSection({
	Name = "Example Left",
	Side = "Left"
})

local RightSection = ExampleTab:CreateSection({
	Name = "Example Right",
	Side = "Right"
})

LeftSection:AddLabel("Example Label")

LeftSection:AddToggle({
	Name = "Example Toggle",
	Default = false,
	ConfigKey = "example_toggle",
	Callback = function(state) end
})

LeftSection:AddSlider({
	Name = "Example Slider",
	Min = 0,
	Max = 100,
	Default = 50,
	ConfigKey = "example_slider",
	Callback = function(val) end
})

LeftSection:AddInput({
	Name = "Example Input",
	Placeholder = "type here...",
	Default = "",
	ConfigKey = "example_input",
	Callback = function(text, entered) end
})

LeftSection:AddDropdown({
	Name = "Example Dropdown",
	Options = { "Option 1", "Option 2", "Option 3" },
	Default = "Option 1",
	ConfigKey = "example_dropdown",
	Callback = function(selected) end
})

local PlayerSearch = LeftSection:AddSearchDropdown({
	Name = "Target Player",
	Player = true,
	Team = false,
	ConfigKey = "target_player",
	Callback = function(name, type, object)
		Library.Notify({
			Title = "Player Selected",
			Text = "Selected: " .. tostring(name),
			Icon = "user",
			Duration = 3
		})
	end
})

local TeamSearch = LeftSection:AddSearchDropdown({
	Name = "Target Team",
	Player = false,
	Team = true,
	ConfigKey = "target_team",
	Callback = function(name, type, object)
		Library.Notify({
			Title = "Team Selected",
			Text = "Selected: " .. tostring(name),
			Icon = "users",
			Duration = 3
		})
	end
})

local CombinedSearch = LeftSection:AddSearchDropdown({
	Name = "Player or Team",
	Player = true,
	Team = true,
	ConfigKey = "combined_search",
	Callback = function(name, entryType, object)
		Library.Notify({
			Title = entryType == "player" and "Player" or "Team",
			Text = "Selected: " .. tostring(name),
			Icon = "search",
			Duration = 3
		})
	end
})

RightSection:AddMultiDropdown({
	Name = "Example Multi Dropdown",
	Options = { "Choice A", "Choice B", "Choice C", "Choice D" },
	Default = { "Choice A" },
	ConfigKey = "example_multidrop",
	Callback = function(selected) end
})

RightSection:AddColorPicker({
	Name = "Example Color",
	Default = Color3.fromRGB(0, 230, 150),
	ConfigKey = "example_color",
	Callback = function(color) end
})

RightSection:AddKeybind({
	Name = "Example Keybind",
	Default = Enum.KeyCode.E,
	ConfigKey = "example_keybind",
	Callback = function(key) end
})

local ExampleImage = RightSection:AddImage({
	Name = "Example Image",
	ImageId = 6023426926,
	Width = 80,
	Height = 80,
	Rotation = 0,
	Color = Color3.fromRGB(255, 255, 255),
	Transparency = 0,
	ScaleType = Enum.ScaleType.Fit
})

RightSection:AddSlider({
	Name = "Image Rotation",
	Min = 0,
	Max = 360,
	Default = 0,
	Callback = function(val)
		ExampleImage.SetRotation(val)
	end
})

RightSection:AddSlider({
	Name = "Image Transparency",
	Min = 0,
	Max = 100,
	Default = 0,
	Callback = function(val)
		ExampleImage.SetTransparency(val / 100)
	end
})

RightSection:AddInput({
	Name = "Image ID",
	Placeholder = "enter asset id...",
	Default = "",
	Callback = function(text, entered)
		if entered then
			local id = tonumber(text)
			if id then
				ExampleImage.SetImageId(id)
			end
		end
	end
})

RightSection:AddButton({
	Name = "Example Button",
	Callback = function()
		Library.Notify({
			Title = "Astra",
			Text = "Example button pressed.",
			Icon = "check",
			Duration = 3
		})
	end
})

local ConfigTab = Window:CreateTab({
	Name = "Config",
	Icon = "settings"
})

local ConfigLeft = ConfigTab:CreateSection({
	Name = "Config Manager",
	Side = "Left"
})

ConfigLeft:ApplyConfigManager({})
