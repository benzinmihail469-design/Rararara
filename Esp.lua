local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ОЧИСТКА СТАРОГО ИНТЕРФЕЙСА
-- ==========================================
pcall(function()
    if CoreGui:FindFirstChild("HoshiMM2Gui") then CoreGui.HoshiMM2Gui:Destroy() end
end)

-- ==========================================
-- СОСТОЯНИЕ И НАСТРОЙКИ С КЭШЕМ
-- ==========================================
local State = {
    Flying = false, FlySpeed = 35,
    AutoFarmEnabled = false, AutoFarmSpeed = 15, -- Максимум 25
    WalkSpeedEnabled = false, CustomWalkSpeed = 16,
    NoclipEnabled = false,
    ESPEnabled = false,
    AutoCombat = false, AutoPickGun = false,
    AutoFlingEnabled = false
}

local Connections = {}
local CachedCoin = nil
local NextCoinScan = 0

-- Безопасные геттеры компонентов персонажа
local function GetRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

-- Динамическое определение ролей в MM2
local function GetPlayerRole(player)
    if not player or not player.Character then return "Innocent" end
    if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
        return "Murderer"
    elseif player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun") then
        return "Sheriff"
    end
    return "Innocent"
end

-- ==========================================
-- ПОЛНАЯ ИСПРАВЛЕННАЯ ЛОГИКА ФУНКЦИЙ
-- ==========================================

-- 1. Исправленный и стабильный Auto Fling (Без багов физики)
local function ToggleFling(state)
    State.AutoFlingEnabled = state
    if Connections.Fling then Connections.Fling:Disconnect() Connections.Fling = nil end
    
    local root = GetRoot()
    if not state then
        if root then 
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            for _, v in pairs(root:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v.Name == "FlingForce" then 
                    v:Destroy() 
                end
            end
        end
        return
    end
    
    local bgv = Instance.new("BodyAngularVelocity")
    bgv.Name = "FlingForce"
    bgv.MaxTorque = Vector3.new(0, math.huge, 0)
    bgv.AngularVelocity = Vector3.new(0, 99999, 0)
    bgv.Parent = root

    Connections.Fling = RunService.Heartbeat:Connect(function()
        local myRoot = GetRoot()
        if not State.AutoFlingEnabled or not myRoot then return end
        
        if not myRoot:FindFirstChild("FlingForce") then
            bgv.Parent = myRoot
        end

        local targetRoot = nil
        local maxDist = 45
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < maxDist then
                        maxDist = dist
                        targetRoot = p.Character.HumanoidRootPart
                    end
                end
            end
        end
        
        if targetRoot then
            myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            -- Наведение без разноса физического движка в бесконечность
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(math.sin(tick() * 25) * 0.1, 0, math.cos(tick() * 25) * 0.1)
        else
            myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

-- Поиск монет на карте
local function ScanForCoin()
    if CachedCoin and CachedCoin.Parent and CachedCoin:IsA("BasePart") and CachedCoin.Transparency < 1 then
        return CachedCoin
    end
    if tick() < NextCoinScan then return nil end
    NextCoinScan = tick() + 0.1
    
    local containers = {workspace:FindFirstChild("Normal"), workspace:FindFirstChild("Map"), workspace:FindFirstChild("CoinContainer")}
    for _, container in pairs(containers) do
        if container then
            for _, obj in pairs(container:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name == "Coin_Server" or obj.Name:lower():find("coin")) and obj.Transparency < 1 then
                    if obj:FindFirstChildOfClass("TouchTransmitter") then
                        CachedCoin = obj
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

-- 2. Стабильный Авто-Фарм
local function ToggleAutoFarm(state)
    State.AutoFarmEnabled = state
    if Connections.Farm then Connections.Farm:Disconnect() Connections.Farm = nil end
    
    if not state then
        local hum = GetHum()
        if hum then hum.PlatformStand = false end
        return
    end
    
    Connections.Farm = RunService.Heartbeat:Connect(function()
        local root = GetRoot()
        local hum = GetHum()
        if not State.AutoFarmEnabled or not root or not hum then return end
        
        local coin = ScanForCoin()
        if coin then
            hum.PlatformStand = true
            -- State.AutoFarmSpeed ограничен слайдером максимум до 25
            local lerpFactor = math.clamp(State.AutoFarmSpeed / 100, 0.01, 0.25)
            root.CFrame = root.CFrame:Lerp(coin.CFrame * CFrame.new(0, 0.3, 0), lerpFactor)
            
            pcall(function()
                firetouchinterest(root, coin, 0)
                firetouchinterest(root, coin, 1)
            end)
        else
            hum.PlatformStand = false
        end
    end)
end

-- ==========================================
-- ПОСТРОЕНИЕ ИНТЕРФЕЙСА (ПОЛНЫЕ СТАРЫЕ ВКЛАДКИ)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "HoshiMM2Gui"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 560, 0, 380)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 19)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 9)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(35, 38, 48)
MainStroke.Thickness = 1

-- Сайдбар меню
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(19, 20, 25)
Sidebar.BorderSizePixel = 0
local SideCorner = Instance.new("UICorner", Sidebar)
SideCorner.CornerRadius = UDim.new(0, 9)

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 6)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SidebarPadding = Instance.new("UIPadding", Sidebar)
SidebarPadding.PaddingTop = UDim.new(0, 15)

-- Контейнер для страниц
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -155, 1, -25)
PageContainer.Position = UDim2.new(0, 150, 0, 15)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local Tabs = {}

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame", PageContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(45, 48, 60)
    
    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 7)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 15)
    end)
    
    Pages[name] = page
    return page
end

local function CreateTab(name, pageName)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(26, 28, 35)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(150, 155, 170)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do t.TextColor3 = Color3.fromRGB(150, 155, 170) t.BackgroundColor3 = Color3.fromRGB(26, 28, 35) end
        Pages[pageName].Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(38, 42, 53)
    end)
    
    Tabs[name] = btn
end

-- Конструкторы элементов UI
local function AddToggle(parent, text, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.96, 0, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(32, 35, 45)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(215, 220, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 38, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = Color3.fromRGB(45, 48, 60)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.BackgroundColor3 = toggled and Color3.fromRGB(75, 190, 115) or Color3.fromRGB(45, 48, 60)
        pcall(callback, toggled)
    end)
end

local function AddSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.96, 0, 0, 48)
    frame.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(32, 35, 45)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 0, 22)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(215, 220, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0.3, 0, 0, 22)
    valLabel.Position = UDim2.new(1, -75, 0, 4)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 11
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBar = Instance.new("TextButton", frame)
    sliderBar.Size = UDim2.new(0.93, 0, 0, 5)
    sliderBar.Position = UDim2.new(0, 12, 0, 32)
    sliderBar.BackgroundColor3 = Color3.fromRGB(38, 41, 52)
    sliderBar.Text = ""
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 2)
    
    local fill = Instance.new("Frame", sliderBar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
    
    local isSliding = false
    local function updateSlider(input)
        local scale = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(scale, 0, 1, 0)
        local value = math.floor(min + (max - min) * scale)
        valLabel.Text = tostring(value)
        pcall(callback, value)
    end
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = true updateSlider(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = false end
    end)
end

-- Инициализация всех вкладок (Полное восстановление структуры)
local MainP = CreatePage("Main")
local PlayerP = CreatePage("Player")
local VisualP = CreatePage("Visual")
local CombatP = CreatePage("Combat")

CreateTab("Главная", "Main")
CreateTab("Игрок", "Player")
CreateTab("Визуал", "Visual")
CreateTab("Бой", "Combat")

-- Старт с первой вкладки
Pages["Main"].Visible = true
Tabs["Главная"].TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs["Главная"].BackgroundColor3 = Color3.fromRGB(38, 42, 53)

-- ==========================================
-- ЗАПОЛНЕНИЕ ВКЛАДОК КОНТЕНТОМ
-- ==========================================

-- Вкладка: Главная
AddToggle(MainP, "Авто-Фарм Монет", function(state) ToggleAutoFarm(state) end)
AddSlider(MainP, "Скорость Авто-Фарма (Макс 25)", 1, 25, 15, function(v) State.AutoFarmSpeed = v end)

-- Вкладка: Игрок
AddToggle(PlayerP, "Кастомная WalkSpeed", function(state) State.WalkSpeedEnabled = state end)
AddSlider(PlayerP, "Скорость Скольжения/Бега", 16, 120, 16, function(v) State.CustomWalkSpeed = v end)
AddToggle(PlayerP, "Noclip (Сквозь стены)", function(state)
    State.NoclipEnabled = state
    if Connections.Noclip then Connections.Noclip:Disconnect() Connections.Noclip = nil end
    if state then
        Connections.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end)

-- Вкладка: Визуал
AddToggle(VisualP, "Включить ESP Ролей игроков", function(state)
    State.ESPEnabled = state
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("MM2Highlight") then p.Character.MM2Highlight:Destroy() end
        end
    end
end)

-- Вкладка: Бой
AddToggle(CombatP, "Включить Улучшенный Auto Fling", function(state) ToggleFling(state) end)
AddToggle(CombatP, "Авто-Атака (Combat Aura)", function(state) State.AutoCombat = state end)
AddToggle(CombatP, "Авто-подбор оружия (Gun Pick)", function(state) State.AutoPickGun = state end)


-- ==========================================
-- СЕРВИСНЫЕ ЦИКЛЫ И ФОНОВЫЕ ПОТОКИ
-- ==========================================

-- Поток изменения скорости
Connections.WalkSpeedLoop = RunService.Heartbeat:Connect(function()
    local hum = GetHum()
    if hum and State.WalkSpeedEnabled and not State.AutoFarmEnabled then
        hum.WalkSpeed = State.CustomWalkSpeed
    end
end)

-- Поток Боя и Автоматического Удара/Стрельбы
task.spawn(function()
    while task.wait(0.2) do
        if State.AutoCombat and LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and (tool.Name == "Knife" or tool.Name == "Gun") then 
                tool:Activate() 
            end
        end
    end
end)

-- Поток Автоподбора Пистолета (Если Шериф умер)
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoPickGun then
            local root = GetRoot()
            if root then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name == "GunDrop" or obj.Name == "Gun_Server") then
                        root.CFrame = obj.CFrame
                        firetouchinterest(root, obj, 0)
                        firetouchinterest(root, obj, 1)
                        break
                    end
                end
            end
        end
    end
end)

-- Поток отрисовки ESP (Цвета в зависимости от Роли)
task.spawn(function()
    while task.wait(0.5) do
        if State.ESPEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local role = GetPlayerRole(p)
                    local hl = p.Character:FindFirstChild("MM2Highlight")
                    if not hl then
                        hl = Instance.new("Highlight", p.Character)
                        hl.Name = "MM2Highlight"
                    end
                    
                    if role == "Murderer" then
                        hl.FillColor = Color3.fromRGB(255, 30, 30)
                    elseif role == "Sheriff" then
                        hl.FillColor = Color3.fromRGB(30, 140, 255)
                    else
                        hl.FillColor = Color3.fromRGB(50, 255, 100)
                    end
                    hl.FillTransparency = 0.4
                end
            end
        end
    end
end)

-- Система перемещения GUI пальцем/мышкой
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
