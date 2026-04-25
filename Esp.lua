
-- Speed 35 + плавный GUI + обход античита (Mobile + PC)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Настройка
local SpeedEnabled = true
local SpeedValue = 35
local speedConnection = nil

-- Обход античита (уничтожение скриптов + глобальный хук чтения WalkSpeed)
pcall(function()
    -- Уничтожение античит скриптов
    for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
        if v.Name:lower():find("anti") or v.Name:lower():find("cheat") then
            v:Destroy()
        end
    end
    
    -- Глобальный хук __index для возврата 16 при чтении WalkSpeed
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = function(self, key)
        if key == "WalkSpeed" and self:IsA("Humanoid") then
            return 16
        end
        return oldIndex(self, key)
    end
    setreadonly(mt, true)
end)

-- Функция установки скорости
local function applySpeed()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    if not SpeedEnabled then
        pcall(function()
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
        end)
        return
    end
    speedConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = SpeedValue
                end
            end
        end)
    end)
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SpeedGUI"
gui.Parent = CoreGui
gui.IgnoreGuiInset = true  -- Для мобильных отступов

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 70)
frame.Position = UDim2.new(1, -170, 0, 10)  -- Справа сверху
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 1  -- Для анимации
frame.BorderSizePixel = 0
frame.Parent = gui
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0, 30)
label.Position = UDim2.new(0, 0, 0, 5)
label.BackgroundTransparency = 1
label.Text = "Speed: 35"
label.TextColor3 = Color3.fromRGB(0, 255, 0)
label.TextSize = 18
label.Font = Enum.Font.GothamBold
label.TextXAlignment = Enum.TextXAlignment.Center
label.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 25)
toggleBtn.Position = UDim2.new(0.5, -25, 0, 40)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleBtn.Text = "ON"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = frame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = toggleBtn

-- Плавное появление
TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0.15
}):Play()

-- Перетаскивание (PC + Mobile)
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Кнопка вкл/выкл
toggleBtn.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    toggleBtn.Text = SpeedEnabled and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    label.Text = SpeedEnabled and ("Speed: " .. SpeedValue) or "Speed: OFF"
    label.TextColor3 = SpeedEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
    
    -- Плавная анимация кнопки
    TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 50, 0, 25)
    }):Play()
    
    applySpeed()
end)

-- Запуск
applySpeed()

-- При респауне
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)  -- Увеличено для стабильности
    pcall(function()
        -- Повторно уничтожаем античит в новом чара
        for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Script") or v:IsA("LocalScript") then
                if v.Name:lower():find("anti") or v.Name:lower():find("cheat") then
                    v:Destroy()
                end
            end
        end
    end)
    applySpeed()
end)
