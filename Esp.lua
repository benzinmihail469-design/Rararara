local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ПОЛНАЯ ОЧИСТКА
-- ==========================================
pcall(function()
    if CoreGui:FindFirstChild("HoshiMM2Gui") then CoreGui.HoshiMM2Gui:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("HoshiMM2Gui") then
        LocalPlayer.PlayerGui.HoshiMM2Gui:Destroy()
    end
end)

-- ==========================================
-- СОСТОЯНИЕ
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
local BVelocity, BGyro = nil, nil

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
-- ПОЛУЧЕНИЕ КОЛ-ВА МОНЕТ И ТЕЛЕПОРТ В ЛОББИ
-- ==========================================
local function GetCoinCount()
    local count = 0
    pcall(function()
        local coinText = LocalPlayer.PlayerGui.MainGUI.Game.Cashbag.Amount.Text
        count = tonumber(coinText) or 0
    end)
    return count
end

local function TeleportToLobby()
    local root = GetRoot()
    if not root then return end
    
    local lobby = workspace:FindFirstChild("Lobby")
    if lobby and lobby:FindFirstChild("Spawns") then
        local spawns = lobby.Spawns:GetChildren()
        if #spawns > 0 then
            root.CFrame = spawns[1].CFrame * CFrame.new(0, 5, 0)
            return
        end
    end
    root.CFrame = CFrame.new(-108, 145, 0) 
end

-- ==========================================
-- РАБОЧИЙ ФЛАЙ
-- ==========================================
local function StopFlying()
    if Connections.Fly then Connections.Fly:Disconnect() Connections.Fly = nil end
    if BVelocity then BVelocity:Destroy() BVelocity = nil end
    if BGyro then BGyro:Destroy() BGyro = nil end
    local hum = GetHum()
    if hum then
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    local root = GetRoot()
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

local function StartFlying()
    StopFlying()
    local root = GetRoot()
    local hum = GetHum()
    if not root or not hum then return end

    hum.PlatformStand = true
    
    BVelocity = Instance.new("BodyVelocity")
    BVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    BVelocity.Velocity = Vector3.new(0, 0, 0)
    BVelocity.Parent = root

    BGyro = Instance.new("BodyGyro")
    BGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    BGyro.P = 25000
    BGyro.CFrame = root.CFrame
    BGyro.Parent = root

    local cam = workspace.CurrentCamera
    Connections.Fly = RunService.RenderStepped:Connect(function()
        local r = GetRoot()
        if not State.Flying or not r then StopFlying() return end

        BGyro.CFrame = cam.CFrame
        
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            BVelocity.Velocity = moveDir.Unit * State.FlySpeed
        else
            BVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

-- ==========================================
-- БЕСКОНЕЧНЫЙ ПРЫЖОК
-- ==========================================
UserInputService.JumpRequest:Connect(function()
    if State.InfJump then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ==========================================
-- ПОИСК БЛИЖАЙШЕЙ МОНЕТЫ С АНТИ-УБИЙЦЕЙ
-- ==========================================
local function ScanAllCoins(safeRadius)
    local root = GetRoot()
    if not root then return nil end

    local closestCoin = nil
    local shortestDistance = math.huge
    
    local m = GetMurderer()
    local mRoot = m and m.Character and m.Character:FindFirstChild("HumanoidRootPart")

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "Coin_Server" or obj.Name == "GoldCoin" or obj.Name == "Coin" or obj.Name:lower():find("coin")) then
            if obj.Transparency < 1 and obj.Parent then
                local distance = (root.Position - obj.Position).Magnitude
                
                if distance < shortestDistance and distance < 1500 then
                    local isSafe = true
                    if mRoot and safeRadius then
                        local distFromM = (mRoot.Position - obj.Position).Magnitude
                        if distFromM < safeRadius then
                            isSafe = false
                        end
                    end
                    
                    if isSafe then
                        shortestDistance = distance
                        closestCoin = obj
                    end
                end
            end
        end
    end
    return closestCoin
end

-- ==========================================
-- УМНЫЙ АВТО-ФАРМ (ИСПРАВЛЕННЫЙ)
-- ==========================================
local isCurrentlyFarming = false 
local AntiFallBV = nil
local CurrentActiveTween = nil

local function ToggleAutoFarm(state)
    State.AutoFarmEnabled = state
    
    if Connections.Farm then Connections.Farm:Disconnect() Connections.Farm = nil end
    if Connections.FarmNoclip then Connections.FarmNoclip:Disconnect() Connections.FarmNoclip = nil end
    
    local hum = GetHum()
    if AntiFallBV then AntiFallBV:Destroy() AntiFallBV = nil end
    if CurrentActiveTween then CurrentActiveTween:Cancel() CurrentActiveTween = nil end
    
    if not state then
        isCurrentlyFarming = false
        if hum then 
            hum.PlatformStand = false 
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        return
    end

    Connections.FarmNoclip = RunService.Stepped:Connect(function()
        local root = GetRoot()
        local humanoid = GetHum()
        
        if State.AutoFarmEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then 
                    part.CanCollide = false 
                end
            end
            
            if isCurrentlyFarming and root then
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
            if humanoid then
                humanoid.PlatformStand = true
            end
        end
    end)

    task.spawn(function()
        while State.AutoFarmEnabled do
            task.wait(0.1)
            
            local root = GetRoot()
            local humanoid = GetHum()
            if not root or not humanoid or humanoid.Health <= 0 then continue end

            -- Создаем невидимый якорь для удержания высоты в воздухе
            if not AntiFallBV or not AntiFallBV.Parent then
                AntiFallBV = Instance.new("BodyVelocity")
                AntiFallBV.Name = "FarmAntiFallAnchor"
                AntiFallBV.MaxForce = Vector3.new(0, 0, 0)
                AntiFallBV.Velocity = Vector3.new(0, 0, 0)
                AntiFallBV.Parent = root
            end

            -- ИСПРАВЛЕНО: ПРОВЕРКА НА ФУЛЛ МЕШОК СРАБАТЫВАЕТ ВСЕГДА
            if GetCoinCount() >= 40 then
                isCurrentlyFarming = false
                if CurrentActiveTween then CurrentActiveTween:Cancel() CurrentActiveTween = nil end
                AntiFallBV.MaxForce = Vector3.new(0, 0, 0)
                
                if humanoid then
                    humanoid.PlatformStand = false
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
                
                TeleportToLobby()
                task.wait(2) 
                continue
            end

            local coin = ScanAllCoins(45) 
            
            if coin and coin.Parent then
                isCurrentlyFarming = true
                AntiFallBV.MaxForce = Vector3.new(0, 0, 0) -- Отключаем стопор во время движения
                
                local targetCFrame = coin.CFrame * CFrame.new(0, 1.5, 0)
                local distance = (root.Position - targetCFrame.Position).Magnitude
                
                local duration = distance / math.max(State.AutoFarmSpeed, 1)

                local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
                CurrentActiveTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
                CurrentActiveTween:Play()
                
                local tweenActive = true
                local completedConn
                completedConn = CurrentActiveTween.Completed:Connect(function()
                    tweenActive = false
                    if completedConn then completedConn:Disconnect() end
                end)
                
                while tweenActive and State.AutoFarmEnabled do
                    if root then root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
                    
                    if GetCoinCount() >= 40 then
                        break
                    end

                    local m = GetMurderer()
                    if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
                        local mDist = (root.Position - m.Character.HumanoidRootPart.Position).Magnitude
                        if mDist < 45 then
                            if CurrentActiveTween then CurrentActiveTween:Cancel() end
                            tweenActive = false
                            break
                        end
                    end
                    
                    task.wait()
                end
                
                if not State.AutoFarmEnabled then 
                    if CurrentActiveTween then CurrentActiveTween:Cancel() end
                    break 
                end

                if (root.Position - targetCFrame.Position).Magnitude < 5 then
                    if firetouchinterest then
                        firetouchinterest(root, coin, 0)
                        task.wait(0.02)
                        firetouchinterest(root, coin, 1)
                    else
                        root.CFrame = coin.CFrame
                        task.wait(0.02)
                    end
                end
            else
                -- ИСПРАВЛЕНО: ЕСЛИ РЯДОМ УБИЙЦА, ЗАВИСАЕМ В ВОЗДУХЕ, А НЕ ПАДАЕМ
                isCurrentlyFarming = false 
                if CurrentActiveTween then CurrentActiveTween:Cancel() CurrentActiveTween = nil end
                
                if root and AntiFallBV then
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    AntiFallBV.MaxForce = Vector3.new(1e6, 1e6, 1e6) -- Заставляем жестко держать позицию
                    AntiFallBV.Velocity = Vector3.new(0, 0, 0)
                end
                task.wait(0.5)
            end
        end
        
        local humAfter = GetHum()
        if humAfter then 
            humAfter.PlatformStand = false 
            humAfter:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if AntiFallBV then AntiFallBV:Destroy() AntiFallBV = nil end
    end)
end

-- ==========================================
-- АВТО-ФЛИНГ
-- ==========================================
local function ToggleFling(state)
    State.AutoFlingEnabled = state
    if Connections.Fling then Connections.Fling:Disconnect() Connections.Fling = nil end
    local root = GetRoot()

    if not state then
        if root then
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            for _, v in pairs(root:GetChildren()) do
                if v.Name == "FlingForce" then v:Destroy() end
            end
        end
        return
    end

    local bavl = Instance.new("BodyAngularVelocity")
    bavl.Name = "FlingForce"
    bavl.MaxTorque = Vector3.new(0, math.huge, 0)
    bavl.AngularVelocity = Vector3.new(0, 99999, 0)
    bavl.Parent = root

    Connections.Fling = RunService.Heartbeat:Connect(function()
        local myRoot = GetRoot()
        if not State.AutoFlingEnabled or not myRoot then return end

        local targetRoot = nil
        local maxDist = math.huge

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and GetPlayerRole(p) ~= "Murderer" then
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
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 0.2)
        end
    end)
end

-- ==========================================
-- СОЗДАНИЕ GUI
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
-- СОЗДАНИЕ СТРАНИЦ
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
-- ЗАПОЛНЕНИЕ МЕНЮ
-- ==========================================
AddToggle(MainP, "Авто-Фарм Монет", function(state) ToggleAutoFarm(state) end)
AddSlider(MainP, "Скорость Фарма", 1, 25, 25, function(v) State.AutoFarmSpeed = v end)

AddToggle(PlayerP, "Bypass Fly (Полет)", function(state)
    State.Flying = state
    if state then StartFlying() else StopFlying() end
end)
AddSlider(PlayerP, "Скорость полета", 15, 90, 35, function(v) State.FlySpeed = v end)
AddToggle(PlayerP, "Кастомный бег", function(state) State.WalkSpeedEnabled = state end)
AddSlider(PlayerP, "Скорость бега", 16, 120, 16, function(v)
    State.CustomWalkSpeed = v
    local hum = GetHum()
    if hum and State.WalkSpeedEnabled then
        hum.WalkSpeed = v
    end
end)
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
AddToggle(PlayerP, "Бесконечный Прыжок", function(state) State.InfJump = state end)

AddToggle(VisualP, "Включить ESP Ролей", function(state)
    State.ESPEnabled = state
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("MM2Highlight") then p.Character.MM2Highlight:Destroy() end
        end
    end
end)

AddToggle(MurderP, "Включить Auto Fling", function(state) ToggleFling(state) end)
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
-- РАБОЧИЙ WALK SPEED ЛУП
-- ==========================================
Connections.WalkSpeedLoop = RunService.Heartbeat:Connect(function()
    local hum = GetHum()
    if hum then
        if State.WalkSpeedEnabled and not State.AutoFarmEnabled and not State.Flying then
            hum.WalkSpeed = State.CustomWalkSpeed
        else
            if hum.WalkSpeed ~= 16 then
                hum.WalkSpeed = 16
            end
        end
    end
end)

-- ==========================================
-- АКТИВНЫЕ ПОТОКИ
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
    StopFlying()
    if Connections.Farm then Connections.Farm:Disconnect() end
    if Connections.FarmNoclip then Connections.FarmNoclip:Disconnect() end
    if Connections.Noclip then Connections.Noclip:Disconnect() end
    if Connections.Fling then Connections.Fling:Disconnect() end
    if Connections.WalkSpeedLoop then Connections.WalkSpeedLoop:Disconnect() end
    local root = GetRoot()
    if root then root.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end
    if AntiFallBV then AntiFallBV:Destroy() end
    ScreenGui:Destroy()
end)
