-- Speed 35 + плавный GUI + обход античита (Mobile)
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

-- Обход античита
pcall(function()
    for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
        if v.Name:find("Anti") or v.Name:find("Cheat") then v:Destroy() end
    end
    local old = hookmetamethod(game, "__index", function(self, k)
        if k == "WalkSpeed" then return 16 end
        return old(self, k)
    end)
end)

-- Функция установки скорости
local function applySpeed()
    if speedConnection then speedConnection:Disconnect() end
    if not SpeedEnabled then
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
        return
    end
    speedConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = SpeedValue end
            end
        end)
    end)
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SpeedGUI"
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 45)
frame.Position = UDim2.new(1, -170, 0, 10)  -- справа сверху
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 1  -- прозрачный для анимации
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "Speed: 35"
label.TextColor3 = Color3.fromRGB(0, 255, 0)
label.TextSize = 18
label.Font = Enum.Font.GothamBold
label.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 25)
toggleBtn.Position = UDim2.new(0.5, -25, 1, 5) -- ниже центра, но мы лучше оставим кнопку внутри? 
-- Изменим: разместим кнопку прямо на frame, увеличив его высоту до 70
frame.Size = UDim2.new(0, 160, 0, 70)
toggleBtn.Position = UDim2.new(0.5, -25, 0, 40) -- по центру внизу
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleBtn.Text = "ON"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)

label.Text = "Speed: 35"
label.Size = UDim2.new(1, 0, 0, 30)
label.Position = UDim2.new(0, 0, 0, 5)

-- Плавное появление
TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.2}):Play()

-- Перетаскивание (опционально)
local dragging, dragStart, startPos = false
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Кнопка вкл/выкл
toggleBtn.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    toggleBtn.Text = SpeedEnabled and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = SpeedEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    label.Text = SpeedEnabled and "Speed: 35" or "Speed: OFF"
    applySpeed()
end)

-- Запуск
applySpeed()

-- При респауне
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    applySpeed()
end)
