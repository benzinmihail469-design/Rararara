-- Полноценный мобильный GUI хак для Roblox
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TabFolder = Instance.new("Folder")
local TabButtonContainer = Instance.new("ScrollingFrame")

ScreenGui.Name = "ProMobileHub"
ScreenGui.Parent = game.CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.Active = true
MainFrame.Draggable = true -- Поддержка касаний для перемещения

-- Заголовок
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "PRO MOBILE HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.CodeBold
Title.TextSize = 20

-- Основные функции (Логика)
local function CreateToggle(name, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, #MainFrame:GetChildren() * 45)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- Добавляем функции
CreateToggle("Fly (Полет)", function(s) 
    local hum = game.Players.LocalPlayer.Character.Humanoid
    hum.PlatformStand = s
end)

CreateToggle("Infinite Jump", function(s)
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if s then game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping") end
    end)
end)

CreateToggle("Auto-Farm (Пример)", function(s)
    -- Скрипт для автоматического сбора ресурсов
    getgenv().farming = s
    while getgenv().farming do
        task.wait(0.1)
        -- Здесь логика фарма (зависит от игры)
    end
end)

-- Кнопка закрытия
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0.9, 0, 0, 30)
Close.Position = UDim2.new(0.05, 0, 0.9, 0)
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.Text = "Удалить GUI"
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
