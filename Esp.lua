local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Создание главного окна
local Window = OrionLib:MakeWindow({
    Name = "Dark Hub | Orion Edition",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DarkHubOrionConfig",
    IntroEnabled = true,
    IntroText = "Dark Hub",
    IntroIcon = "rbxassetid://4483345998"
})

-- ==========================================
-- === ВКЛАДКА: MAIN ===
-- ==========================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddSection({
    Name = "Параметры персонажа"
})

MainTab:AddToggle({
    Name = "Включить усилитель",
    Default = false,
    Save = true,
    Flag = "Toggle_SpeedBoost",
    Callback = function(Value)
        print("Статус:", Value)
    end    
})

MainTab:AddSlider({
    Name = "Скорость ходьбы (WalkSpeed)",
    Min = 16,
    Max = 250,
    Default = 16,
    Color = Color3.fromRGB(80, 120, 255),
    Increment = 1,
    ValueName = "Speed",
    Save = true,
    Flag = "Slider_WalkSpeed",
    Callback = function(Value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
        end
    end    
})

MainTab:AddSlider({
    Name = "Высота прыжка (JumpPower)",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(80, 255, 120),
    Increment = 1,
    ValueName = "Power",
    Save = true,
    Flag = "Slider_JumpPower",
    Callback = function(Value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end    
})

-- ==========================================
-- === ВКЛАДКА: VISUALS ===
-- ==========================================
local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

VisualsTab:AddSection({
    Name = "Настройки отображения"
})

VisualsTab:AddDropdown({
    Name = "Режим подсветки",
    Default = "Boxes",
    Options = {"Boxes", "Chams", "Tracers", "Head Dots"},
    Save = true,
    Flag = "Dropdown_ESPMode",
    Callback = function(Value)
        print("Выбран режим:", Value)
    end
})

VisualsTab:AddColorpicker({
    Name = "Цвет элементов",
    Default = Color3.fromRGB(255, 0, 85),
    Save = true,
    Flag = "Color_Accent",
    Callback = function(Value)
        print("Новый цвет:", Value)
    end
})

-- ==========================================
-- === ВКЛАДКА: SETTINGS ===
-- ==========================================
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SettingsTab:AddSection({
    Name = "Управление скриптом"
})

SettingsTab:AddBind({
    Name = "Горячая клавиша меню",
    Default = Enum.KeyCode.RightControl,
    Hold = false,
    Callback = function()
        print("Клавиша нажата")
    end
})

SettingsTab:AddTextbox({
    Name = "Поле ввода текста",
    Default = "Текст по умолчанию",
    TextDisappear = true,
    Callback = function(Value)
        print("Введено:", Value)
    end
})

SettingsTab:AddButton({
    Name = "Уведомление",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Dark Hub",
            Content = "Настройки успешно сохранены!",
            Image = "rbxassetid://4483345998",
            Time = 4
        })
    end
})

SettingsTab:AddButton({
    Name = "Закрыть и выгрузить UI",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- Инициализация библиотеки
OrionLib:Init()
