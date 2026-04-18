--[[
    ОПИСАНИЕ: Этот скрипт добавляет кнопку на экран.
    При нажатии телепортирует вашего персонажа к выбранному игроку.
    Это демонстрация того, как взаимодействовать с объектами игры через клиент.
--]]

-- Ждем загрузки игрока
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция для телепортации
local function TeleportTo(PlayerToTeleportTo)
    -- Проверяем, есть ли у цели персонаж и есть ли у него "Торс" (часть тела для точки привязки)
    if PlayerToTeleportTo.Character and PlayerToTeleportTo.Character:FindFirstChild("HumanoidRootPart") then
        local TargetPosition = PlayerToTeleportTo.Character.HumanoidRootPart.Position
        -- Перемещаем корневую часть нашего персонажа
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(TargetPosition)
        end
    end
end

-- Создаем простой интерфейс (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextButton = Instance.new("TextButton")

-- Настройка внешнего вида
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
Frame.Parent = ScreenGui
Frame.Position = UDim2.new(0.1, 0, 0.5, 0) -- Центрируем по горизонтали, вертикали
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

TextButton.Parent = Frame
TextButton.Size = UDim2.new(1, 0, 1, 0)
TextButton.Text = "Кликни на игрока в списке"
TextButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)

-- Сама логика клика
TextButton.MouseButton1Click:Connect(function()
    -- Ищем первого попавшегося игрока, кроме нас самих
    local Target = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            Target = player
            break
        end
    end
    
    if Target then
        TeleportTo(Target)
        TextButton.Text = "Телепорт к " .. Target.Name
    else
        TextButton.Text = "Нет других игроков!"
    end
end)

print("Скрипт загружен. Ищите кнопку на экране игры!")
