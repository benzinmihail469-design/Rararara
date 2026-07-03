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
-- ОСНОВНОЙ ЦИКЛ: ФЛАЙ И АВТО-ФАРМ (CFRAME)
-- ==========================================
if Connections.MainLoop then Connections.MainLoop:Disconnect() end

Connections.MainLoop = RunService.RenderStepped:Connect(function(dt)
    local root = GetRoot()
    local hum = GetHum()
    if not root or not hum or hum.Health <= 0 then return end
    
    local cam = workspace.CurrentCamera

    -- Принудительно гасим импульс падения от гравитации, если включен флай или фарм
    if State.Flying or State.AutoFarmEnabled then
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
    end

    -- 1. ЛОГИКА АВТОФАРМА (Приоритет)
    if State.AutoFarmEnabled then
        hum.PlatformStand = true
        
        local closestCoin = nil
        local shortestDist = math.huge
        
        -- Ищем любые монеты на карте
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "Coin_Server" or obj.Name == "GoldCoin" or obj.Name == "Coin" or obj.Name:lower():find("coin")) then
                local dist = (root.Position - obj.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestCoin = obj
                end
            end
        end

        if closestCoin then
            local dir = (closestCoin.Position - root.Position)
            local dist = dir.Magnitude

            if dist > 2.5 then
                -- Ограничение скорости фарма жестко вшито (макс 25)
                local speed = math.clamp(State.AutoFarmSpeed, 1, 25)
                root.CFrame = CFrame.new(root.Position + dir.Unit * math.min(speed * dt * 5, dist), closestCoin.Position)
            else
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

    -- 2. ЛОГИКА ОБЫЧНОГО ФЛАЯ
    if State.Flying then
        hum.PlatformStand = true

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
            -- Жестко удерживаем на месте, если кнопки не нажаты
            root.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
        end
        return
    end

    -- 3. ВОЗВРАТ В ОБЫЧНОЕ СОСТОЯНИЕ
    if hum.PlatformStand and not State.Flying and not State.AutoFarmEnabled then
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

-- ==========================================
-- КЛАССИЧЕСКИЙ СТАБИЛЬНЫЙ АВТО-ФЛИНГ
-- ==========================================
task.spawn(function()
    while true do
        task.wait()
        local myRoot = GetRoot()
        local myHum = GetHum()
        if not State.AutoFlingEnabled or not myRoot or not myHum or myHum.Health <= 0 then continue end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local tRoot = p.Character.HumanoidRootPart
                local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                
                if tHum and tHum.Health > 0 and GetPlayerRole(p) ~= "Murderer" then
                    local dist = (myRoot.Position - tRoot.Position).Magnitude
                    -- Если подошли близко к игроку — даем мощный крутящий импульс
                    if dist <= 6 then
                        local oldCFrame = myRoot.CFrame
                        myRoot.AssemblyAngularVelocity = Vector3.new(0, 99999, 0) -- Вращаем физику торса
                        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 0.1) -- Сталкиваем хитбоксы
                        task.wait(0.02)
                        myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0) -- Мгновенно тушим скорость
                        myRoot.CFrame = oldCFrame -- Возвращаем тебя на место
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- WALK SPEED И NOCLIP
-- ==========================================
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = GetHum()
    
    if not char or not hum then return end

    if State.WalkSpeedEnabled and not State.Flying and not hum.PlatformStand then
        hum.WalkSpeed = State.CustomWalkSpeed
    elseif not State.WalkSpeedEnabled and hum.WalkSpeed ~= 16 and not hum.PlatformStand then
        hum.WalkSpeed = 16
    end

    -- Авто-ноклип, чтобы не застревать во время полетов и фарма
    if State.NoclipEnabled or State.Flying or State.AutoFarmEnabled then
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

-- ==========================================
-- ПОТОКИ АУР И СБОРЩИКОВ
-- ==========================================
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

task.spawn(function()
    while task.wait(0.1) do
        local root = GetRoot()
        if root and (State.SheriffAura or State.SilentAim) then
            local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
            if gun then
                if gun.Parent == LocalPlayer.Backpack then gun.Parent = LocalPlayer.Character end
                gun:Activate()

                if State.SilentAim then
                    local m = GetMurderer()
                    if m and m.Character and m.Character:FindFirstChild("Head") then
                        local cam = workspace.CurrentCamera
                        cam.CFrame = CFrame.new(cam.CFrame.Position, m.Character.Head.Position)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
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

task.spawn(function()
    while task.wait(0.5) do
        if State.ESPEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local role = GetPlayerRole(p)
                    local hl = p.Character:FindFirstChild("MM2Highlight") or Instance.new("Highlight", p.Character)
                    hl.Name = "MM2Highlight"
                    hl.FillColor = role == "Murderer" and Color3.fromRGB(255, 30, 30) or role == "Sheriff" and Color3.fromRGB(30, 140, 255) or Color3.fromRGB(50, 255, 100)
                    hl.FillTransparency = 0.4
                end
            end
        end
    end
end)

-- ==========================================
-- ИНТЕРФЕЙС GUI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoshiMM2Gui"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 560, 0, 380)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 19)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 9)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(35, 38, 48)
MainStroke.Thickness = 1

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 9)

local HeaderFix = Instance.new("Frame", Header)
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
HeaderFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Hoshi Hub — Murder Mystery 2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 34, 1, 0)
CloseBtn.Position = UDim2.new(1, -34, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(160, 165, 175)
CloseBtn.TextSize = 13

local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 34, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -68, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(160, 165, 175)
MinimizeBtn.TextSize = 11

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -34)
Sidebar.Position = UDim2.new(0, 0, 0, 34)
Sidebar.BackgroundColor3 = Color3.fromRGB(19, 20, 25)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 9)

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 6)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 12)

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -155, 1, -49)
PageContainer.Position = UDim2.new(0, 150, 0, 44)
PageContainer.BackgroundTransparency = 1

local Pages, Tabs = {}, {}

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame", PageContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(45, 48, 60)

    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 15)
    end)

    Pages[name] = page
    return page
end

local function CreateTab(name, pageName)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.92, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(26, 28, 35)
    btn.Text = "   " .. name
    btn.TextColor3 = Color3.fromRGB(145, 150, 165)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local tabStroke = Instance.new("UIStroke", btn)
    tabStroke.Color = Color3.fromRGB(33, 36, 46)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do
            t.TextColor3 = Color3.fromRGB(145, 150, 165)
            t.BackgroundColor3 = Color3.fromRGB(26, 28, 35)
            t:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(33, 36, 46)
        end
        Pages[pageName].Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(38, 42, 53)
        tabStroke.Color = Color3.fromRGB(55, 60, 75)
    end)
    Tabs[name] = btn
end

local function AddToggle(parent, text, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.96, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(32, 35, 45)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(215, 220, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local switch = Instance.new("TextButton", frame)
    switch.Size = UDim2.new(0, 40, 0, 22)
    switch.Position = UDim2.new(1, -54, 0.5, -11)
    switch.BackgroundColor3 = Color3.fromRGB(45, 48, 60)
    switch.Text = ""
    Instance.new("UICorner", switch).CornerRadius = UDim.new(0, 11)

    local circle = Instance.new("Frame", switch)
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(0, 8)

    local toggled = false
    switch.MouseButton1Click:Connect(function()
        toggled = not toggled
        TweenService:Create(switch, TweenInfo.new(0.2), { BackgroundColor3 = toggled and Color3.fromRGB(75, 190, 115) or Color3.fromRGB(45, 48, 60) }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), { Position = toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }):Play()
        pcall(callback, toggled)
    end)
end

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.96, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 33, 43)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 245)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(45, 48, 62)

    btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

local function AddSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.96, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(32, 35, 45)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 0, 24)
    label.Position = UDim2.new(0, 14, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(215, 220, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0.3, 0, 0, 24)
    valLabel.Position = UDim2.new(0.65, 0, 0, 4)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 11
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local sliderBar = Instance.new("TextButton", frame)
    sliderBar.Size = UDim2.new(0.8, 0, 0, 6)
    sliderBar.Position = UDim2.new(0, 14, 0, 34)
    sliderBar.BackgroundColor3 = Color3.fromRGB(38, 41, 52)
    sliderBar.Text = ""
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame", sliderBar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

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
            isSliding = true
            updateSlider(input)
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
-- ИНИЦИАЛИЗАЦИЯ ВКЛАДОК
-- ==========================================
local MainP = CreatePage("Main")
local PlayerP = CreatePage("Player")
local VisualP = CreatePage("Visual")
local MurderP = CreatePage("Murderer")
local SheriffP = CreatePage("Sheriff")

CreateTab("Главная", "Main")
CreateTab("Игрок", "Player")
CreateTab("Визуал", "Visual")
CreateTab("Убийца", "Murderer")
CreateTab("Шериф", "Sheriff")

Pages["Main"].Visible = true
Tabs["Главная"].TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs["Главная"].BackgroundColor3 = Color3.fromRGB(38, 42, 53)
Tabs["Главная"]:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(55, 60, 75)

-- ==========================================
-- НАПОЛНЕНИЕ ФУНКЦИОНАЛА
-- ==========================================
AddToggle(MainP, "Авто-Фарм Монет", function(state) State.AutoFarmEnabled = state end)
AddSlider(MainP, "Скорость Фарма (Макс 25)", 1, 25, 25, function(v) State.AutoFarmSpeed = math.clamp(v, 1, 25) end)

AddToggle(PlayerP, "Обычный Полет (Fly)", function(state) State.Flying = state end)
AddSlider(PlayerP, "Скорость полета", 15, 90, 35, function(v) State.FlySpeed = v end)
AddToggle(PlayerP, "Кастомный бег", function(state) State.WalkSpeedEnabled = state end)
AddSlider(PlayerP, "Скорость бега", 16, 120, 16, function(v) State.CustomWalkSpeed = v end)
AddToggle(PlayerP, "Noclip (Сквозь стены)", function(state) State.NoclipEnabled = state end)
AddToggle(PlayerP, "Бесконечный Прыжок", function(state) State.InfJump = state end)

AddToggle(VisualP, "Включить ESP Ролей", function(state)
    State.ESPEnabled = state
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("MM2Highlight") then p.Character.MM2Highlight:Destroy() end
        end
    end
end)

AddToggle(MurderP, "Включить Нормальный Fling", function(state) State.AutoFlingEnabled = state end)
AddToggle(MurderP, "Авто-Удар Ножом (Kill Aura)", function(state) State.MurderAura = state end)
AddToggle(MurderP, "Радиусный Silent Kill", function(state) State.SilentKill = state end)
AddButton(MurderP, "Телепорт за спину Жертвы", function()
    local root = GetRoot()
    if root then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and GetPlayerRole(p) ~= "Murderer" then
                local tRoot = p.Character.HumanoidRootPart
                if p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3.5)
                    break
                end
            end
        end
    end
end)

AddToggle(SheriffP, "Авто-подбор пистолета", function(state) State.AutoPickGun = state end)
AddToggle(SheriffP, "Авто-Стрельба (Sheriff Aura)", function(state) State.SheriffAura = state end)
AddToggle(SheriffP, "Silent Aim в Убийцу", function(state) State.SilentAim = state end)

-- ==========================================
-- DRAG SYSTEM & MINIMIZE
-- ==========================================
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
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
        MainFrame:TweenSize(UDim2.new(0, 560, 0, 34), "Out", "Quart", 0.25, true)
    else
        MainFrame:TweenSize(UDim2.new(0, 560, 0, 380), "Out", "Quart", 0.25, true, function()
            Sidebar.Visible = true
            PageContainer.Visible = true
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    State.Flying, State.AutoFarmEnabled, State.WalkSpeedEnabled, State.ESPEnabled, State.MurderAura, State.SilentKill, State.SheriffAura, State.AutoPickGun, State.AutoFlingEnabled, State.InfJump, State.SilentAim = false, false, false, false, false, false, false, false, false, false, false
    if Connections.MainLoop then Connections.MainLoop:Disconnect() end
    local root = GetRoot()
    if root then 
        root.Anchored = false 
        root.AssemblyAngularVelocity = Vector3.new(0,0,0)
        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end
    ScreenGui:Destroy()
end)
