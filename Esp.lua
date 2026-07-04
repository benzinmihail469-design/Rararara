local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ОЧИСТКА СТАРЫХ UI
-- ==========================================
pcall(function()
    if CoreGui:FindFirstChild("HoshiMM2Gui") then CoreGui.HoshiMM2Gui:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("HoshiMM2Gui") then
        LocalPlayer.PlayerGui.HoshiMM2Gui:Destroy()
    end
end)

-- ==========================================
-- СОСТОЯНИЯ
-- ==========================================
local State = {
    Flying = false,
    FlySpeed = 35,
    AutoFarmEnabled = false,
    AutoFarmSpeed = 25,
    WalkSpeedEnabled = false,
    CustomWalkSpeed = 16,
    NoclipEnabled = false,
    InfJump = false,
    ESPEnabled = false,
    MurderAura = false,
    SilentKill = false,
    AutoPickGun = false,
    SheriffAura = false,
    SilentAim = false,
    AutoFlingEnabled = false,
    MenuMinimized = false
}

local Connections = {}

-- ==========================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ==========================================
local function GetRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

-- Динамическая проверка лобби в MM2
local function IsInLobby()
    local root = GetRoot()
    if not root then return true end
    
    -- В MM2 во время раунда карта загружается в папку "Normal"
    local currentMap = workspace:FindFirstChild("Normal")
    if not currentMap then 
        return true -- Если карты нет, мы точно в лобби
    end

    -- Дополнительная проверка по расстоянию до спавна лобби
    local lobbyLvl = workspace:FindFirstChild("Lobby")
    if lobbyLvl then
        local spawnLoc = lobbyLvl:FindFirstChildOfClass("SpawnLocation")
        if spawnLoc and (root.Position - spawnLoc.Position).Magnitude < 130 then
            return true
        end
    end

    return false
end

local function GetPlayerRole(player)
    if not player or not player.Character then return "Innocent" end
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    if (backpack and backpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local function GetMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if GetPlayerRole(p) == "Murderer" then return p end
    end
    return nil
end

-- ==========================================
-- ИСПРАВЛЕННЫЙ ЦИКЛ ПЕРЕМЕЩЕНИЯ (ФЛАЙ И ПЛАВНЫЙ ФАРМ)
-- ==========================================
if Connections.MainLoop then Connections.MainLoop:Disconnect() end

Connections.MainLoop = RunService.RenderStepped:Connect(function(dt)
    local root = GetRoot()
    local hum = GetHum()
    if not root or not hum or hum.Health <= 0 then return end
    
    local cam = workspace.CurrentCamera
    local inLobby = IsInLobby()

    -- Полный сброс сил физики при активных режимах левитации
    if State.Flying or (State.AutoFarmEnabled and not inLobby) then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        if hum:GetState() ~= Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end

    -- 1. ЛОГИКА АВТОФАРМА (Только вне лобби)
    if State.AutoFarmEnabled and not inLobby then
        local closestCoin = nil
        local shortestDist = math.huge
        
        -- Поиск валидных монет на активной карте
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "Coin_Server" or obj.Name == "GoldCoin" or obj.Name == "Coin" or obj.Name:lower():find("coin")) then
                if obj.Transparency < 1 and obj:IsDescendantOf(workspace) then
                    local dist = (root.Position - obj.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestCoin = obj
                    end
                end
            end
        end

        if closestCoin then
            local dir = (closestCoin.Position - root.Position)
            local dist = dir.Magnitude
            local maxSpeed = math.clamp(State.AutoFarmSpeed, 1, 25) -- Ограничение скорости до 25

            if dist > 1.2 then
                -- Плавный подлет к монетке без рывков
                root.CFrame = CFrame.new(root.Position + dir.Unit * math.min(maxSpeed * dt, dist), closestCoin.Position)
            else
                -- Сбор
                if firetouchinterest then
                    firetouchinterest(root, closestCoin, 0)
                    task.wait(0.01)
                    firetouchinterest(root, closestCoin, 1)
                else
                    root.CFrame = closestCoin.CFrame
                end
            end
            return 
        end
    end

    -- 2. ИСПРАВЛЕННАЯ СТАБИЛЬНАЯ ЛОГИКА ФЛАЯ
    if State.Flying then
        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            root.CFrame = CFrame.new(root.Position + moveDir.Unit * (State.FlySpeed * dt), root.Position + cam.CFrame.LookVector)
        else
            root.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
        end
        return
    end

    -- Возврат стандартного стейта персонажа
    if hum:GetState() == Enum.HumanoidStateType.Physics and not State.Flying and not (State.AutoFarmEnabled and not inLobby) then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

-- ==========================================
-- ДОПОЛНИТЕЛЬНЫЕ СИСТЕМЫ И ПОТОКИ (Noclip, Aura, ESP)
-- ==========================================
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = GetHum()
    if not char or not hum then return end

    if State.WalkSpeedEnabled and not State.Flying and hum:GetState() ~= Enum.HumanoidStateType.Physics then
        hum.WalkSpeed = State.CustomWalkSpeed
    elseif not State.WalkSpeedEnabled and hum.WalkSpeed ~= 16 and hum:GetState() ~= Enum.HumanoidStateType.Physics then
        hum.WalkSpeed = 16
    end

    if State.NoclipEnabled or State.Flying or (State.AutoFarmEnabled and not IsInLobby()) then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJump then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.ESPEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local role = GetPlayerRole(p)
                    local hl = p.Character:FindFirstChild("MM2Highlight") or Instance.new("Highlight", p.Character)
                    hl.Name = "MM2Highlight"
                    hl.FillColor = role == "Murderer" and Color3.fromRGB(255, 50, 50) or role == "Sheriff" and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(100, 255, 100)
                    hl.FillTransparency = 0.4
                end
            end
        end
    end
end)

-- Ограниченные циклы для остальных функций (Aura / Pick Gun)
task.spawn(function()
    while task.wait(0.05) do
        local root = GetRoot()
        if root and (State.MurderAura or State.SilentKill) then
            local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
            if knife then
                if knife.Parent == LocalPlayer.Backpack then knife.Parent = LocalPlayer.Character end
                knife:Activate()
                if State.SilentKill then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local tRoot = p.Character.HumanoidRootPart
                            if (root.Position - tRoot.Position).Magnitude <= 18 and GetPlayerRole(p) ~= "Murderer" then
                                pcall(function()
                                    firetouchinterest(tRoot, knife.Handle, 0)
                                    firetouchinterest(tRoot, knife.Handle, 1)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- ОБНОВЛЕННЫЙ ИНТЕРФЕЙС GUI (ДИЗАЙН HOSHI HUB)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoshiMM2Gui"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 620, 0, 400)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(28, 30, 38)
MainStroke.Thickness = 1

-- Верхняя панель заголовка
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(20, 22, 29)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local HeaderFix = Instance.new("Frame", Header)
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(20, 22, 29)
HeaderFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0, 70, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Hoshi"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Декоративные теги из шапки (как на фото)
local function CreateTag(text, posX, color)
    local tag = Instance.new("TextLabel", Header)
    tag.Size = UDim2.new(0, 55, 0, 18)
    tag.Position = UDim2.new(0, posX, 0.5, -9)
    tag.BackgroundColor3 = color or Color3.fromRGB(28, 31, 42)
    tag.Font = Enum.Font.GothamBold
    tag.Text = text
    tag.TextColor3 = Color3.fromRGB(180, 185, 200)
    tag.TextSize = 9
    Instance.new("UICorner", tag).CornerRadius = UDim.new(0, 4)
end
CreateTag("FREE", 85, Color3.fromRGB(35, 40, 55))
CreateTag("v1.4.0", 146)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(130, 135, 145)
CloseBtn.TextSize = 14

local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 40, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -80, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Font = Enum.Font.GothamMedium
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(130, 135, 145)
MinimizeBtn.TextSize = 12

-- Сайдбар слева
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 135, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(17, 18, 24)
Sidebar.BorderSizePixel = 0

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 2)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 8)

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -151, 1, -58)
PageContainer.Position = UDim2.new(0, 143, 0, 50)
PageContainer.BackgroundTransparency = 1

local Pages, Tabs = {}, {}

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame", PageContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(40, 43, 55)

    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
    end)

    Pages[name] = page
    return page
end

local function CreateTab(name, pageName)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(130, 135, 145)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do
            t.TextColor3 = Color3.fromRGB(130, 135, 145)
            t.BackgroundTransparency = 1
        end
        Pages[pageName].Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(26, 29, 38)
    end)
    Tabs[name] = btn
end

-- Создание секций контейнеров (как "AUTO PLANT" на фото)
local function CreateSection(parent, title)
    local sec = Instance.new("Frame", parent)
    sec.Size = UDim2.new(0.96, 0, 0, 20)
    sec.BackgroundColor3 = Color3.fromRGB(19, 21, 28)
    sec.BorderSizePixel = 0
    Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 6)
    local secStroke = Instance.new("UIStroke", sec)
    secStroke.Color = Color3.fromRGB(30, 33, 44)

    local secList = Instance.new("UIListLayout", sec)
    secList.Padding = UDim.new(0, 8)
    secList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pad = Instance.new("UIPadding", sec)
    pad.PaddingTop = UDim.new(0, 30)
    pad.PaddingBottom = UDim.new(0, 10)

    local headLabel = Instance.new("TextLabel", sec)
    headLabel.Size = UDim2.new(0.92, 0, 0, 20)
    headLabel.Position = UDim2.new(0, 12, 0, -24)
    headLabel.BackgroundTransparency = 1
    headLabel.Font = Enum.Font.GothamBold
    headLabel.Text = title:upper()
    headLabel.TextColor3 = Color3.fromRGB(165, 170, 185)
    headLabel.TextSize = 10
    headLabel.TextXAlignment = Enum.TextXAlignment.Left

    secList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sec.Size = UDim2.new(0.96, 0, 0, secList.AbsoluteContentSize.Y + 40)
    end)

    return sec
end

local function AddToggle(parent, text, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.92, 0, 0, 32)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(190, 195, 205)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local switch = Instance.new("TextButton", frame)
    switch.Size = UDim2.new(0, 36, 0, 18)
    switch.Position = UDim2.new(1, -38, 0.5, -9)
    switch.BackgroundColor3 = Color3.fromRGB(45, 48, 60)
    switch.Text = ""
    Instance.new("UICorner", switch).CornerRadius = UDim.new(0, 9)

    local circle = Instance.new("Frame", switch)
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = UDim2.new(0, 2, 0.5, -7)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(0, 7)

    local toggled = false
    switch.MouseButton1Click:Connect(function()
        toggled = not toggled
        TweenService:Create(switch, TweenInfo.new(0.15), { BackgroundColor3 = toggled and Color3.fromRGB(100, 115, 255) or Color3.fromRGB(45, 48, 60) }):Play()
        TweenService:Create(circle, TweenInfo.new(0.15), { Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }):Play()
        pcall(callback, toggled)
    end)
end

local function AddSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.92, 0, 0, 44)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 185, 195)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 11
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local sliderBar = Instance.new("TextButton", frame)
    sliderBar.Size = UDim2.new(1, 0, 0, 4)
    sliderBar.Position = UDim2.new(0, 0, 0, 28)
    sliderBar.BackgroundColor3 = Color3.fromRGB(40, 43, 55)
    sliderBar.Text = ""
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 2)

    local fill = Instance.new("Frame", sliderBar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 115, 255)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true; updateSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)
end

-- ==========================================
-- ИНИЦИАЛИЗАЦИЯ И СТРУКТУРА ВКЛАДОК
-- ==========================================
local FarmP = CreatePage("Farm")
local PlayerP = CreatePage("Player")
local VisualP = CreatePage("Visual")

CreateTab("Farm", "Farm")
CreateTab("Player", "Player")
CreateTab("Visuals", "Visual")

Pages["Farm"].Visible = true
Tabs["Farm"].TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs["Farm"].BackgroundColor3 = Color3.fromRGB(26, 29, 38)

-- Наполнение секций элементами управления
local AutoFarmSection = CreateSection(FarmP, "Auto Farm")
AddToggle(AutoFarmSection, "Включить Сбор Монет", function(state) State.AutoFarmEnabled = state end)
AddSlider(AutoFarmSection, "Скорость Полета (Макс 25)", 1, 25, 25, function(v) State.AutoFarmSpeed = math.clamp(v, 1, 25) end)

local MovementSection = CreateSection(PlayerP, "Movement Controls")
AddToggle(MovementSection, "Обычный Fly (Полет)", function(state) State.Flying = state end)
AddSlider(MovementSection, "Скорость Полета", 15, 90, 35, function(v) State.FlySpeed = v end)
AddToggle(MovementSection, "Кастомная Скорость Бега", function(state) State.WalkSpeedEnabled = state end)
AddSlider(MovementSection, "Скорость Бега", 16, 100, 16, function(v) State.CustomWalkSpeed = v end)
AddToggle(MovementSection, "Noclip (Сквозь Стены)", function(state) State.NoclipEnabled = state end)
AddToggle(MovementSection, "Бесконечный Прыжок", function(state) State.InfJump = state end)

local VisualSection = CreateSection(VisualP, "ESP Options")
AddToggle(VisualSection, "ESP Ролей (Murderer/Sheriff)", function(state)
    State.ESPEnabled = state
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("MM2Highlight") then p.Character.MM2Highlight:Destroy() end
        end
    end
end)

-- ==========================================
-- СИСТЕМНЫЕ ОКНА (DRAG & MINIMIZE)
-- ==========================================
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    State.MenuMinimized = not State.MenuMinimized
    if State.MenuMinimized then
        Sidebar.Visible = false
        PageContainer.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 620, 0, 42), "Out", "Quart", 0.2, true)
    else
        MainFrame:TweenSize(UDim2.new(0, 620, 0, 400), "Out", "Quart", 0.2, true, function()
            Sidebar.Visible = true
            PageContainer.Visible = true
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    State.Flying, State.AutoFarmEnabled, State.WalkSpeedEnabled, State.ESPEnabled = false, false, false, false
    if Connections.MainLoop then Connections.MainLoop:Disconnect() end
    local root = GetRoot()
    if root then 
        root.AssemblyAngularVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
    end
    ScreenGui:Destroy()
end)
