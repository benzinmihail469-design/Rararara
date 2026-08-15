local Neverlose_Main = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mana42138/Neverlose-UI/main/Source.lua"))()

-- Создание главного окна
local Window = Neverlose_Main:Window({
    Title = "KITI",
    SubTitle = "Release",
    Size = UDim2.fromOffset(600, 400)
})

-- Создание вкладок
local MainTab = Window:Tab("Main", "rbxassetid://6023426915")
local SettingsTab = Window:Tab("Settings", "rbxassetid://6031280882")

-- Секции (Левая и Правая стороны)
local CombatSection = MainTab:Section("Combat", "Left")
local VisualsSection = MainTab:Section("Visuals", "Right")
local ConfigSection = SettingsTab:Section("Config", "Left")

-- 1. Переключатель (Toggle)
CombatSection:Toggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(State)
        print("Aimbot включен:", State)
    end
})

-- 2. Ползунок (Slider)
CombatSection:Slider({
    Name = "FOV Radius",
    Min = 10,
    Max = 300,
    Default = 90,
    Callback = function(Value)
        print("Текущий FOV:", Value)
    end
})

-- 3. Выпадающий список (Dropdown)
CombatSection:Dropdown({
    Name = "Target Bone",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(Option)
        print("Выбранная цель:", Option)
    end
})

-- 4. Выбор цвета (Colorpicker)
VisualsSection:Colorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(0, 255, 120),
    Callback = function(Color)
        print("Выбран цвет:", Color)
    end
})

-- 5. Кнопка (Button)
VisualsSection:Button({
    Name = "Reset Settings",
    Callback = function()
        print("Настройки сброшены!")
    end
})
