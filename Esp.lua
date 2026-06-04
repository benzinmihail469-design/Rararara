-- Полностью рабочий мобильный GUI с исправлением отображения элементов
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаем ScreenGui в доступном для мобилок PlayerGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProMobileHubUltimate"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 280, 0, 300)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -150)
MainFrame.Active = true
MainFrame.ZIndex = 1

-- Скрипт перетаскивания (Drag) для мобильного экрана
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

-- Черный заголовок панели
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0.75, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "  PRO HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.CodeBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2

-- КНОПКА ЗАКРЫТИЯ (Принудительный ZIndex = 5, чтобы была поверх всего)
local Close = Instance.new("TextButton", MainFrame)
Close.Name = "CloseButton"
Close.Size = UDim2.new(0.25, 0, 0, 40)
Close.Position = UDim2.new(0.75, 0, 0, 0)
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 22
Close.ZIndex = 5
Close.Visible = true

Close.MouseButton1Click:Connect(function() 
    ScreenGui:Destroy() 
end)

-- Функция создания кнопок читов (С высоким приоритетом отображения)
local function CreateToggle(name, posY, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.ZIndex = 3
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- Отрисовка кнопок функций поверх фона
CreateToggle("Fly (Полет)", 60, function(s) 
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.PlatformStand = s
    end
end)

CreateToggle("Infinite Jump", 115, function(s)
    getgenv().InfJump = s
    UIS.JumpRequest:Connect(function()
        if getgenv().InfJump and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then 
            player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") 
        end
    end)
end)

CreateToggle("Auto-Farm", 170, function(s)
    getgenv().farming = s
    task.spawn(function()
        while getgenv().farming do
            task.wait(0.5)
        end
    end)
end)
