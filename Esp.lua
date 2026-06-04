-- Полностью исправленный мобильный GUI хак для Roblox
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")

ScreenGui.Name = "ProMobileHubFixed"
ScreenGui.Parent = game.CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.Active = true

-- Исправление ошибки линии -1 (Современный перетаскиваемый интерфейс для телефона)
local UIS = game:GetService("UserInputService")
local dragToggle, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragToggle then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- Заголовок
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "PRO MOBILE HUB (FIXED)"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.CodeBold
Title.TextSize = 20

-- Исправление ошибки линии -24 (Фиксированные позиции вместо динамического подсчета)
local function CreateToggle(name, posY, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- Безопасное добавление кнопок с фиксированным отступом по оси Y
CreateToggle("Fly (Полет)", 60, function(s) 
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.PlatformStand = s
    end
end)

CreateToggle("Infinite Jump", 110, function(s)
    getgenv().InfJump = s
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if getgenv().InfJump and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then 
            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") 
        end
    end)
end)

CreateToggle("Auto-Farm (Тест)", 160, function(s)
    getgenv().farming = s
    task.spawn(function()
        while getgenv().farming do
            task.wait(0.5)
            -- Сюда вставляется код автоматизации
        end
    end)
end)

-- Кнопка закрытия
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0.9, 0, 0, 30)
Close.Position = UDim2.new(0.05, 0, 0.85, 0)
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.Text = "Удалить GUI"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
