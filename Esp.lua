-- Загружаем библиотеку
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/laderite/siernlib/main/library.lua"))()

-- 1. Создаём окно
local Window = Library:Create({ Name = "Super Tool v2.0" })

-- 2. Создаём вкладки
local PlayerTab = Window:Tab("Игрок")
local VisualTab = Window:Tab("Визуал")

-- 3. Создаём секции
local MovementSection = PlayerTab:Section("Движение")
local PlayerInfoSection = PlayerTab:Section("Информация")
local ESPsection = VisualTab:Section("ESP")

-- 4. Добавляем элементы
local speedSlider = MovementSection:Slider("Скорость бега", 16, 250, 16, 1, function(val)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
end)

local flyToggle = MovementSection:Toggle("Режим полёта", function(state)
    -- Здесь нужна более сложная логика полёта, но для примера сойдёт
    local char = game.Players.LocalPlayer.Character
    if state then
        -- Включить полёт
        char.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
        -- ... код полёта
    else
        -- Выключить полёт
    end
end)

local coordLabel = PlayerInfoSection:Label("Координаты: ...")

-- Простое обновление информации
task.spawn(function()
    while true do
        task.wait(0.5)
        local char = game.Players.LocalPlayer.Character
        if char and char.HumanoidRootPart then
            local pos = char.HumanoidRootPart.Position
            coordLabel:Set(string.format("Координаты: X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z))
        end
    end
end)

local espToggle = ESPsection:Toggle("ESP Игроков", function(state)
    if state then
        print("Включён ESP")
        -- Код для включения ESP
    else
        print("Выключен ESP")
    end
end)
