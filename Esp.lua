local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()

-- Создание главного окна
local Window = Library:Window({ 
    Name = "KITI", 
    SubName = "Release", 
    MenuKeybind = Enum.KeyCode.RightShift 
})

-- Создание вкладок
local MainTab = Window:Tab({ Name = "Main", Icon = "rbxassetid://6023426915" })
local SettingsTab = Window:Tab({ Name = "Settings", Icon = "rbxassetid://6031280882" })

-- Создание секций (Левая и Правая колонки)
local CombatSection = MainTab:Section({ Name = "Combat", Side = "Left" })
local VisualsSection = MainTab:Section({ Name = "Visuals", Side = "Right" })
local ConfigSection = SettingsTab:Section({ Name = "Menu Config", Side = "Left" })

-- 1. Переключатель (Toggle)
CombatSection:Toggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(Value)
        print("Aimbot state:", Value)
    end
})

-- 2. Слайдер (Slider)
CombatSection:Slider({
    Name = "FOV Radius",
    Min = 10,
    Max = 500,
    Default = 90,
    Unit = "px",
    Callback = function(Value)
        print("FOV:", Value)
    end
})

-- 3. Выпадающий список (Dropdown)
CombatSection:Dropdown({
    Name = "Target Bone",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(Value)
        print("Target:", Value)
    end
})

-- 4. Выбор цвета (Colorpicker)
VisualsSection:Colorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(0, 255, 150),
    Callback = function(Value)
        print("Color changed:", Value)
    end
})

-- 5. Кнопка с уведомлением (Button)
VisualsSection:Button({
    Name = "Trigger Notification",
    Callback = function()
        Library:Notification({
            Title = "KITI UI",
            Text = "Функция успешно активирована!",
            Duration = 3
        })
    end
})

-- 6. Настройка горячей клавиши (Keybind)
ConfigSection:Keybind({
    Name = "Menu Keybind",
    Default = Enum.KeyCode.RightShift,
    Callback = function(Key)
        print("New menu key:", Key)
    end
})
