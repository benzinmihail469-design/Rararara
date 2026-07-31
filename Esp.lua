local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()

-- Enable Logs
Library.LogsEnabled = true

local Window = Library:Window({
    Name = "Project Nova",
    SubName = "Release Build",
    Logo = "123456789",
    MenuKeybind = Enum.KeyCode.RightShift
})

local MainTab = Window:Page({Name = "Combat", Icon = "rbxassetid://123..."})
local MainSection = MainTab:Section({Name = "Aimbot", Side = 1})

local AimToggle = MainSection:Toggle({
    Name = "Enabled",
    Flag = "AimEnabled",
    Default = false,
    Callback = function(v)
        if v then 
            Library:Log("Aimbot Enabled", 3)
        end
    end
})

-- Nested Slider
AimToggle:Slider({
    Name = "FOV",
    Min = 0, Max = 180, Default = 90
})

-- Nested Dropdown
AimToggle:Dropdown({
    Name = "Hitbox",
    Items = {"Head", "Torso", "Legs"},
    Default = "Head"
})

-- Create Settings Page (Configs, Scale, etc.)
Library:CreateSettingsPage(Window)
