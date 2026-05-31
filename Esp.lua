-- Загружаем библиотеку
local DrRay = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()

-- Создаём окно
local Window = DrRay:Load("Super Script v1.0", "rbxassetid://14133403065")

-- Создаём вкладки
local Main = Window:newTab("Главная")
local Visual = Window:newTab("Визуал")
local Player = Window:newTab("Игрок")

-- Переменные
local flyEnabled = false
local espEnabled = false

-- Главная вкладка
Main:Button("Телепорт в центр", "Телепортироваться на координаты 0, 100, 0", function()
    local char = game.Players.LocalPlayer.Character
    if char then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
        print("Телепортирован!")
    end
end)

Main:Slider("Скорость бега", "Изменить скорость ходьбы", 16, 250, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

-- Визуал вкладка
Visual:Toggle("ESP игроков", "Показывать игроков через стены", function(state)
    espEnabled = state
    if state then
        print("ESP включён")
        -- Ваш код ESP
    else
        print("ESP выключен")
    end
end)

Visual:Toggle("Режим полёта", "Включить полёт (Нажмите F для подъёма)", function(state)
    flyEnabled = state
    -- Ваш код полёта
end)

-- Игрок вкладка
Player:Textbox("Имя игрока", "Введите имя для телепортации", function(name)
    local target = game.Players:FindFirstChild(name)
    if target then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        print("Телепортирован к " .. name)
    else
        print("Игрок не найден!")
    end
end)

Player:Label("Настройки игрока")
Player:Label("Полёт: F")
