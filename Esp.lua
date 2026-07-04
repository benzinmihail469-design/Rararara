local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ОЧИСТКА СТАРЫХ ИНСТАНСОВ И СТРУКТУР
-- ==========================================
pcall(function()
    if CoreGui:FindFirstChild("HoshiMM2Gui") then CoreGui.HoshiMM2Gui:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("HoshiMM2Gui") then
        LocalPlayer.PlayerGui.HoshiMM2Gui:Destroy()
    end
end)

-- ==========================================
-- СОСТОЯНИЯ И НАСТРОЙКИ
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
    MenuMinimized = false
}

local Connections = {}
local lVelocity, lGyro = nil, nil
local Attachment = nil

-- Сброс физических сил
local function CleanForces()
    if lVelocity then pcall(function() lVelocity:Destroy() end); lVelocity = nil end
    if lGyro then pcall(function() lGyro:Destroy() end); lGyro = nil end
    if Attachment then pcall(function() Attachment:Destroy() end); Attachment = nil end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then root.Anchored = false end
end

local function GetRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Инициализация легального перемещения без триггера античита
local function InitForces(root)
    if not Attachment or not Attachment.Parent then
        Attachment = Instance.new("Attachment", root)
    end
    if not lVelocity or not lVelocity.Parent then
        lVelocity = Instance.new("LinearVelocity")
        lVelocity.MaxForce = math.huge
        lVelocity.VectorVelocity = Vector3.zero
        lVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
        lVelocity.Attachment0 = Attachment
        lVelocity.Parent = root
    end
    if not lGyro or not lGyro.Parent then
        lGyro = Instance.new("AlignOrientation")
        lGyro.MaxTorque = math.huge
        lGyro.Responsiveness = 200
        lGyro.Mode = Enum.OrientationMode.OneAttachment
        lGyro.Attachment0 = Attachment
        lGyro.Parent = root
    end
end

-- ==========================================
-- ОСНОВНОЙ СТАБИЛЬНЫЙ ДВИЖОК СБОРА И ПОЛЕТА
-- ==========================================
if Connections.MainLoop then Connections.MainLoop:Disconnect() end

Connections.MainLoop = RunService.Heartbeat:Connect(function(dt)
    local root = GetRoot()
    local hum = GetHum()
    if not root or not hum or hum.Health <= 0 then 
        CleanForces()
        return 
    end
    
    local cam = workspace.CurrentCamera

    -- Включение сил при активном чите
    if State.Flying or State.AutoFarmEnabled then
        InitForces(root)
    else
        CleanForces()
        return
    end

    -- 1. АВТОФАРМ ЧЕРЕЗ СИЛЫ СКОРОСТИ (БЕЗ CFRAME)
    if State.AutoFarmEnabled then
        local closestCoin = nil
        local shortestDist = math.huge
        
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

        if closestCoin and lVelocity and lGyro then
            local targetPos = closestCoin.Position
            local dir = (targetPos - root.Position)
            local dist = dir.Magnitude
            local maxSpeed = math.clamp(State.AutoFarmSpeed, 1, 25)

            if dist > 2 then
                lVelocity.VectorVelocity = dir.Unit * maxSpeed
                lGyro.CFrame = CFrame.new(root.Position, targetPos)
            else
                lVelocity.VectorVelocity = Vector3.zero
                -- Безопасный сбор монет
                if dist < 3 then
                    root.CFrame = closestCoin.CFrame
                    -- Имитация сбора через touch
                    for _, part in pairs(root.Parent:GetDescendants()) do
                        if part:IsA("BasePart") then
                            firetouchinterest(part, closestCoin, 0)
                            task.wait()
                            firetouchinterest(part, closestCoin, 1)
                        end
                    end
                end
            end
            return 
        elseif lVelocity then
            lVelocity.VectorVelocity = Vector3.zero
        end
    end

    -- 2. ПОЛНОСТЬЮ ИСПРАВЛЕННЫЙ ФЛАЙ
    if State.Flying and lVelocity and lGyro then
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            lVelocity.VectorVelocity = moveDir.Unit * State.FlySpeed
        else
            lVelocity.VectorVelocity = Vector3.zero
        end
        lGyro.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
        return
    end
end)

-- ==========================================
-- МОДЕРНИЗИРОВАННЫЙ NOCLIP И СКОРОСТЬ
-- ==========================================
local steppedConnection
steppedConnection = RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = GetHum()
    if not char or not hum then return end

    if State.WalkSpeedEnabled and not State.Flying then
        hum.WalkSpeed = State.CustomWalkSpeed
    elseif not State.WalkSpeedEnabled and hum.WalkSpeed ~= 16 then
        hum.WalkSpeed = 16
    end

    -- Жесткое отключение столкновений с объектами карты во время полета/фарма
    if State.NoclipEnabled or State.Flying or State.AutoFarmEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Исправленный Infinite Jump
local jumpConnection
jumpConnection = UserInputService.JumpRequest:Connect(function()
    if State.InfJump then
        local hum = GetHum()
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Исправленный ESP
local espTask
espTask = task.spawn(function()
    while task.wait(0.3) do
        if State.ESPEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local backpack = p:FindFirstChild("Backpack")
                    local char = p.Character
                    local isMurder = (backpack and backpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife"))
                    local isSheriff = (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun"))
                    
                    local hl = p.Character:FindFirstChild("MM2Highlight")
                    if not hl then
                        hl = Instance.new("Highlight", p.Character)
                        hl.Name = "MM2Highlight"
                    end
                    hl.FillColor = isMurder and Color3.fromRGB(255, 45, 45) or isSheriff and Color3.fromRGB(45, 140, 255) or Color3.fromRGB(50, 255, 110)
                    hl.FillTransparency = 0.4
                end
            end
        else
            -- Удаляем все ESP при выключении
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("MM2Highlight") then
                    p.Character.MM2Highlight:Destroy()
                end
            end
        end
    end
end)

-- ==========================================
-- ИНТЕРФЕЙС GUI ТОЧЬ-В-ТОЧЬ (3299.jpg)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoshiMM2Gui"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 630, 0, 410)
MainFrame.Position = UDim2.new(0.5, -315, 0.5, -205)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 18)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(26, 28, 36)
MainStroke.Thickness = 1

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = Color3.fromRGB(19, 21, 27)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 6)

local HeaderFix = Instance.new("Frame", Header)
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(19, 21, 27)
HeaderFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0, 60, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Hoshi"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

local function CreateHeaderTag(text, posX, isBlue)
    local tag = Instance.new("TextLabel", Header)
    tag.Size = UDim2.new(0, 52, 0, 18)
    tag.Position = UDim2.new(0, posX, 0.5, -9)
    tag.BackgroundColor3 = isBlue and Color3.fromRGB(32, 38, 58) or Color3.fromRGB(26, 29, 38)
    tag.Font = Enum.Font.GothamBold
    tag.Text = text
    tag.TextColor3 = isBlue and Color3.fromRGB(140, 160, 255) or Color3.fromRGB(150, 155, 165)
    tag.TextSize = 9
    Instance.new("UICorner", tag).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke", tag)
    stroke.Color = isBlue and Color3.fromRGB(42, 52, 85) or Color3.fromRGB(35, 38, 50)
    stroke.Thickness = 1
end
CreateHeaderTag("FREE", 76, true)
CreateHeaderTag("v1.4.0", 134, false)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 44, 1, 0)
CloseBtn.Position = UDim2.new(1, -44, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(120, 125, 135)
CloseBtn.TextSize = 13

local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 44, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -88, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Font = Enum.Font.GothamMedium
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(120, 125, 135)
MinimizeBtn.TextSize = 12

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, -44)
Sidebar.Position = UDim2.new(0, 0, 0, 44)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 17, 22)
Sidebar.BorderSizePixel = 0

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 3)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 12)

local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Size = UDim2.new(1, -156, 1, -60)
PageContainer.Position = UDim2.new(0, 148, 0, 52)
PageContainer.BackgroundTransparency = 1

local Pages, Tabs = {}, {}

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame", PageContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(35, 38, 48)

    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 14)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
    end)

    Pages[name] = page
    return page
end

local function CreateTab(name, pageName)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.92, 0, 0, 34)
    btn.BackgroundTransparency = 1
    btn.Text = "   " .. name
    btn.TextColor3 = Color3.fromRGB(120, 125, 135)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do
            t.TextColor3 = Color3.fromRGB(120, 125, 135)
            t.BackgroundTransparency = 1
        end
        Pages[pageName].Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    end)
    Tabs[name] = btn
end

local function CreateSection(parent, title)
    local sec = Instance.new("Frame", parent)
    sec.Size = UDim2.new(0.96, 0, 0, 30)
    sec.BackgroundColor3 = Color3.fromRGB(17, 19, 25)
    sec.BorderSizePixel = 0
    Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 5)
    
    local secStroke = Instance.new("UIStroke", sec)
    secStroke.Color = Color3.fromRGB(28, 31, 40)
    secStroke.Thickness = 1

    local secList = Instance.new("UIListLayout", sec)
    secList.Padding = UDim.new(0, 10)
    secList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pad = Instance.new("UIPadding", sec)
    pad.PaddingTop = UDim.new(0, 32)
    pad.PaddingBottom = UDim.new(0, 12)

    local headLabel = Instance.new("TextLabel", sec)
    headLabel.Size = UDim2.new(0.94, 0, 0, 20)
    headLabel.Position = UDim2.new(0, 12, 0, -25)
    headLabel.BackgroundTransparency = 1
    headLabel.Font = Enum.Font.GothamBold
    headLabel.Text = title:upper()
    headLabel.TextColor3 = Color3.fromRGB(150, 155, 170)
    headLabel.TextSize = 10
    headLabel.TextXAlignment = Enum.TextXAlignment.Left

    secList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sec.Size = UDim2.new(0.96, 0, 0, secList.AbsoluteContentSize.Y + 44)
    end)

    return sec
end

local function AddToggle(parent, text, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.94, 0, 0, 30)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(185, 190, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local switch = Instance.new("TextButton", frame)
    switch.Size = UDim2.new(0, 34, 0, 18)
    switch.Position = UDim2.new(1, -36, 0.5, -9)
    switch.BackgroundColor3 = Color3.fromRGB(40, 43, 54)
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
        TweenService:Create(switch, TweenInfo.new(0.12), { BackgroundColor3 = toggled and Color3.fromRGB(95, 110, 255) or Color3.fromRGB(40, 43, 54) }):Play()
        TweenService:Create(circle, TweenInfo.new(0.12), { Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }):Play()
        pcall(callback, toggled)
    end)
end

local function AddSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.94, 0, 0, 42)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(170, 175, 185)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0.3, 0, 0, 18)
    valLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 11
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local sliderBar = Instance.new("TextButton", frame)
    sliderBar.Size = UDim2.new(1, 0, 0, 4)
    sliderBar.Position = UDim2.new(0, 0, 0, 26)
    sliderBar.BackgroundColor3 = Color3.fromRGB(36, 39, 50)
    sliderBar.Text = ""
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 2)

    local fill = Instance.new("Frame", sliderBar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(95, 110, 255)
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
-- ИНИЦИАЛИЗАЦИЯ ВКЛАДОК
-- ==========================================
local FarmP = CreatePage("Farm")
local PlayerP = CreatePage("Player")
local VisualP = CreatePage("Visual")

CreateTab("Farm", "Farm")
CreateTab("Player", "Player")
CreateTab("Visuals", "Visual")

Pages["Farm"].Visible = true
Tabs["Farm"].TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs["Farm"].BackgroundColor3 = Color3.fromRGB(24, 26, 34)

local AutoFarmSection = CreateSection(FarmP, "Auto Farm")
AddToggle(AutoFarmSection, "Auto Farm Coins", function(state) State.AutoFarmEnabled = state end)
AddSlider(AutoFarmSection, "Farm Speed (Max 25)", 1, 25, 25, function(v) State.AutoFarmSpeed = math.clamp(v, 1, 25) end)

local MoveSection = CreateSection(PlayerP, "Movement")
AddToggle(MoveSection, "Fly Mode (Полет)", function(state) State.Flying = state end)
AddSlider(MoveSection, "Fly Speed", 15, 90, 35, function(v) State.FlySpeed = v end)
AddToggle(MoveSection, "Custom Walkspeed", function(state) State.WalkSpeedEnabled = state end)
AddSlider(MoveSection, "Walkspeed Value", 16, 100, 16, function(v) State.CustomWalkSpeed = v end)
AddToggle(MoveSection, "Noclip", function(state) State.NoclipEnabled = state end)
AddToggle(MoveSection, "Infinite Jump", function(state) State.InfJump = state end)

local VisualSection = CreateSection(VisualP, "Visuals")
AddToggle(VisualSection, "Player ESP", function(state)
    State.ESPEnabled = state
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("MM2Highlight") then p.Character.MM2Highlight:Destroy() end
        end
    end
end)

-- ==========================================
-- СИСТЕМА ДРАГА И ВЫХОДА
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
        MainFrame:TweenSize(UDim2.new(0, 630, 0, 44), "Out", "Quart", 0.2, true)
    else
        MainFrame:TweenSize(UDim2.new(0, 630, 0, 410), "Out", "Quart", 0.2, true, function()
            Sidebar.Visible = true
            PageContainer.Visible = true
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    State.Flying, State.AutoFarmEnabled, State.WalkSpeedEnabled, State.ESPEnabled = false, false, false, false
    if Connections.MainLoop then Connections.MainLoop:Disconnect() end
    if steppedConnection then steppedConnection:Disconnect() end
    if jumpConnection then jumpConnection:Disconnect() end
    if espTask then task.cancel(espTask) end
    CleanForces()
    ScreenGui:Destroy()
end)
