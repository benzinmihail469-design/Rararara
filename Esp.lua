-- Slime RNG Mobile Script for Delta Executor
-- Version: 1.0

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- GUI Library (самописная, без зависимостей)
local GuiLibrary = {}
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "SlimeRNG_Mobile"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Флаг для защиты от обнаружения
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
end

-- Главное окно
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(1, 0, 0.55, 0)
MainFrame.Position = UDim2.new(0, 0, 0.45, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Заголовок
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.BorderSizePixel = 0
Title.Text = "Slime RNG | Mobile"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 12)

-- Контейнер для кнопок
local ButtonContainer = Instance.new("ScrollingFrame", MainFrame)
ButtonContainer.Size = UDim2.new(1, -10, 1, -50)
ButtonContainer.Position = UDim2.new(0, 5, 0, 45)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.BorderSizePixel = 0
ButtonContainer.ScrollBarThickness = 4
ButtonContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout", ButtonContainer)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

local UIPadding = Instance.new("UIPadding", ButtonContainer)
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingRight = UDim.new(0, 5)

-- Функция создания кнопки
function GuiLibrary:CreateButton(text, color, callback)
    local Button = Instance.new("TextButton", ButtonContainer)
    Button.Size = UDim2.new(1, -10, 0, 45)
    Button.BackgroundColor3 = color or Color3.fromRGB(50, 50, 65)
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 15
    Button.AutoButtonColor = false

    local BtnCorner = Instance.new("UICorner", Button)
    BtnCorner.CornerRadius = UDim.new(0, 8)

    Button.MouseButton1Click:Connect(function()
        callback()
        Button.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        task.wait(0.15)
        Button.BackgroundColor3 = color or Color3.fromRGB(50, 50, 65)
    end)

    ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    return Button
end

-- Функция создания переключателя
function GuiLibrary:CreateToggle(text, default, callback)
    local enabled = default or false

    local ToggleFrame = Instance.new("Frame", ButtonContainer)
    ToggleFrame.Size = UDim2.new(1, -10, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    ToggleFrame.BorderSizePixel = 0

    local ToggleCorner = Instance.new("UICorner", ToggleFrame)
    ToggleCorner.CornerRadius = UDim.new(0, 8)

    local ToggleLabel = Instance.new("TextLabel", ToggleFrame)
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.Font = Enum.Font.GothamSemibold
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Position = UDim2.new(0, 12, 0, 0)

    local ToggleButton = Instance.new("Frame", ToggleFrame)
    ToggleButton.Size = UDim2.new(0, 40, 0, 22)
    ToggleButton.Position = UDim2.new(1, -52, 0.5, -11)
    ToggleButton.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 90)
    ToggleButton.BorderSizePixel = 0

    local ToggleBall = Instance.new("Frame", ToggleButton)
    ToggleBall.Size = UDim2.new(0, 18, 0, 18)
    ToggleBall.Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    ToggleBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBall.BorderSizePixel = 0

    local BallCorner = Instance.new("UICorner", ToggleBall)
    BallCorner.CornerRadius = UDim.new(1, 0)

    local ToggleCorner2 = Instance.new("UICorner", ToggleButton)
    ToggleCorner2.CornerRadius = UDim.new(1, 0)

    local function update()
        enabled = not enabled
        local targetColor = enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 90)
        local targetPos = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)

        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(ToggleButton, tweenInfo, {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(ToggleBall, tweenInfo, {Position = targetPos}):Play()

        callback(enabled)
    end

    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            update()
        end
    end)

    ToggleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            update()
        end
    end)

    ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    return {ToggleButton = ToggleButton, ToggleBall = ToggleBall}
end

-- ============================================
-- ФУНКЦИИ СКРИПТА
-- ============================================

-- Авто-крутка
local autoRoll = false
local rollRemote = nil

-- Ищем RemoteEvent для крутки
for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") and (v.Name:lower():find("roll") or v.Name:lower():find("spin")) then
        rollRemote = v
        break
    end
end

GuiLibrary:CreateToggle("Auto Roll (0.5s)", false, function(v)
    autoRoll = v
end)

GuiLibrary:CreateButton("Single Roll", Color3.fromRGB(60, 60, 80), function()
    if rollRemote then
        rollRemote:FireServer()
    end
end)

-- Авто-продажа
local autoSell = false
local sellRemote = nil

for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") and (v.Name:lower():find("sell") or v.Name:lower():find("salvage")) then
        sellRemote = v
        break
    end
end

GuiLibrary:CreateToggle("Auto Sell (2s)", false, function(v)
    autoSell = v
end)

-- Авто-подбор лучшего слизня
local autoEquipBest = false

GuiLibrary:CreateToggle("Auto Equip Best Slime", false, function(v)
    autoEquipBest = v
end)

-- Бесконечные монеты (если есть уязвимость)
local infCoins = false

GuiLibrary:CreateToggle("Coin Exploit (Risky)", false, function(v)
    infCoins = v
end)

-- ESP для редких слизней
local espEnabled = false
local espObjects = {}

local function createESP(target, color)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color or Color3.fromRGB(255, 215, 0)
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Adornee = target
    highlight.Parent = target
    table.insert(espObjects, highlight)
end

local function clearESP()
    for _, h in pairs(espObjects) do
        if h and h.Parent then
            h:Destroy()
        end
    end
    espObjects = {}
end

GuiLibrary:CreateToggle("Rare Slime ESP", false, function(v)
    espEnabled = v
    if not v then
        clearESP()
    end
end)

-- Телепорт к биомам
local biomes = {}
if WS:FindFirstChild("Biomes") then
    for _, biome in pairs(WS.Biomes:GetChildren()) do
        if biome:IsA("BasePart") then
            table.insert(biomes, biome)
        end
    end
end

for _, biome in pairs(biomes) do
    GuiLibrary:CreateButton("TP to " .. biome.Name, Color3.fromRGB(70, 70, 90), function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = biome.CFrame + Vector3.new(0, 5, 0)
        end
    end)
end

-- Увеличение скорости
local speedSlider = 16
GuiLibrary:CreateButton("Speed: 16", Color3.fromRGB(60, 60, 80), function()
    -- Цикл скоростей: 16 -> 32 -> 64 -> 100 -> 16
    local speeds = {16, 32, 64, 100}
    local currentIndex = table.find(speeds, speedSlider) or 1
    local nextIndex = currentIndex % #speeds + 1
    speedSlider = speeds[nextIndex]
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedSlider
    end
end)

-- Jump Power
GuiLibrary:CreateButton("Jump: 50 -> 100 -> 200", Color3.fromRGB(60, 60, 80), function()
    local jumps = {50, 100, 200}
    local currentJump = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.JumpPower or 50
    local currentIndex = table.find(jumps, currentJump) or 1
    local nextIndex = currentIndex % #jumps + 1
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = jumps[nextIndex]
    end
end)

-- God Mode (бессмертие через forcefield)
local godMode = false

GuiLibrary:CreateToggle("God Mode", false, function(v)
    godMode = v
    if v then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local forcefield = Instance.new("ForceField", character)
        forcefield.Visible = false
    else
        if LocalPlayer.Character then
            for _, v2 in pairs(LocalPlayer.Character:GetChildren()) do
                if v2:IsA("ForceField") then
                    v2:Destroy()
                end
            end
        end
    end
end)

-- Noclip
local noclip = false

GuiLibrary:CreateToggle("Noclip", false, function(v)
    noclip = v
end)

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Main Loop
spawn(function()
    while task.wait(0.5) do
        -- Auto Roll
        if autoRoll and rollRemote then
            rollRemote:FireServer()
        end
        
        -- Auto Sell
        if autoSell and sellRemote then
            sellRemote:FireServer()
        end
        
        -- Auto Equip Best
        if autoEquipBest and LocalPlayer:FindFirstChild("Backpack") then
            local bestSlime = nil
            local bestRarity = 0
            
            for _, slime in pairs(LocalPlayer.Backpack:GetChildren()) do
                local rarity = slime:GetAttribute("Rarity") or 0
                if rarity > bestRarity then
                    bestRarity = rarity
                    bestSlime = slime
                end
            end
            
            if bestSlime then
                bestSlime.Parent = LocalPlayer.Character
            end
        end
        
        -- Infinite Coins (базовый подход)
        if infCoins then
            local coinRemote = nil
            for _, v in pairs(RS:GetDescendants()) do
                if v:IsA("RemoteEvent") and v.Name:lower():find("coin") then
                    coinRemote = v
                    break
                end
            end
            if coinRemote then
                coinRemote:FireServer(999999)
            end
        end
        
        -- ESP Update
        if espEnabled then
            clearESP()
            for _, obj in pairs(WS:GetDescendants()) do
                if obj:IsA("Model") and obj:GetAttribute("Rarity") and obj:GetAttribute("Rarity") >= 3 then
                    createESP(obj)
                end
            end
        end
    end
end)

-- Уведомление о загрузке
local Notification = Instance.new("Frame", ScreenGui)
Notification.Size = UDim2.new(0.85, 0, 0, 40)
Notification.Position = UDim2.new(0.075, 0, 0.05, 0)
Notification.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
Notification.BorderSizePixel = 0
Notification.BackgroundTransparency = 0.2

local NotifCorner = Instance.new("UICorner", Notification)
NotifCorner.CornerRadius = UDim.new(0, 8)

local NotifText = Instance.new("TextLabel", Notification)
NotifText.Size = UDim2.new(1, 0, 1, 0)
NotifText.BackgroundTransparency = 1
NotifText.Text = "✓ Slime RNG Script Loaded!"
NotifText.TextColor3 = Color3.fromRGB(255, 255, 255)
NotifText.Font = Enum.Font.GothamBold
NotifText.TextSize = 14

task.wait(3)
Notification:TweenPosition(UDim2.new(0.075, 0, -0.2, 0), "Out", "Quad", 0.5)
task.wait(0.5)
Notification:Destroy()
