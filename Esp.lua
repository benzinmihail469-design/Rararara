--[[
    Celeron's GUI для Bite By Night
    ПЛАВНАЯ ЗАГРУЗКА + ОПТИМИЗАЦИЯ (БЕЗ ЛАГОВ)
--]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Настройки производительности
local PERF = {
    ESP_UPDATE_RATE = 0.016, -- 60 FPS
    AUTO_UPDATE_RATE = 0.1,  -- 10 раз в секунду
    KILLER_CHECK_RATE = 2    -- раз в 2 секунды
}

-- Переменные
local ESPObjects = {}
local Settings = {
    AutoGenerator = false, AutoEscape = false, AutoBarricade = false,
    SurvivorESP = false, KillerESP = false, GeneratorESP = false,
    BatteryESP = false, FuseBoxESP = false,
    InfiniteSprint = false, AllowJumping = false, Aimlock = false,
    AimlockBind = "Z", Noclip = false,
    KillerColor = Color3.fromRGB(0, 255, 0),
    SurvivorColor = Color3.fromRGB(255, 0, 0)
}

local WindowState = { Minimized = false, MainFrame = nil }
local Tabs = {}
local ToggleButtons = {}
local AutoTasks = {}
local OtherTasks = {}

-- Кэш для оптимизации
local KillerCache = { player = nil, lastCheck = 0 }
local CameraPos = Vector3.new()

-- ==================== ПЛАВНЫЙ ЗАГРУЗЧИК ====================

local function ShowLoader()
    local loader = Instance.new("ScreenGui")
    loader.Name = "Loader"
    loader.Parent = CoreGui
    loader.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = game:GetService("Lighting")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0.5, -150, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Parent = loader
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Celeron's GUI"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 45)
    status.BackgroundTransparency = 1
    status.Text = "Loading..."
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.Parent = frame
    
    local barFrame = Instance.new("Frame")
    barFrame.Size = UDim2.new(0.8, 0, 0, 6)
    barFrame.Position = UDim2.new(0.1, 0, 0, 75)
    barFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    barFrame.BorderSizePixel = 0
    barFrame.Parent = frame
    
    Instance.new("UICorner", barFrame).CornerRadius = UDim.new(0, 3)
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    bar.BorderSizePixel = 0
    bar.Parent = barFrame
    
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)
    
    -- Анимация появления
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 6}):Play()
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(status, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    -- Анимация загрузки
    local steps = {0.3, 0.6, 0.9, 1}
    for _, progress in ipairs(steps) do
        TweenService:Create(bar, TweenInfo.new(0.4), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
        task.wait(0.35)
    end
    
    status.Text = "Ready!"
    task.wait(0.3)
    
    -- Затухание
    TweenService:Create(blur, TweenInfo.new(0.4), {Size = 0}):Play()
    TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(status, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    
    task.wait(0.4)
    loader:Destroy()
end

-- ==================== ОБХОД АНТИЧИТА ====================

local function setupAntiCheatBypass()
    pcall(function()
        for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
            if v.Name:find("Anti") or v.Name:find("Cheat") then
                v:Destroy()
            end
        end
    end)
end

-- ==================== ФУНКЦИИ ДЛЯ МОДЕЛЕЙ (ОПТИМИЗИРОВАНО) ====================

local function GetRootPart(model)
    if not model then return nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    return model.PrimaryPart
end

local function GetHead(model)
    if not model then return nil end
    return model:FindFirstChild("Head")
end

local function GetHumanoid(model)
    return model and model:FindFirstChildOfClass("Humanoid")
end

-- ==================== ОПРЕДЕЛЕНИЕ УБИЙЦЫ (С КЭШЕМ) ====================

local function FindKiller()
    local now = tick()
    if now - KillerCache.lastCheck < PERF.KILLER_CHECK_RATE then
        return KillerCache.player
    end
    
    KillerCache.lastCheck = now
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local humanoid = GetHumanoid(p.Character)
            if humanoid and humanoid.MaxHealth > 500 then
                KillerCache.player = p
                return p
            end
        end
    end
    
    return KillerCache.player
end

-- ==================== ESP (ОПТИМИЗИРОВАНО) ====================

local function CreateESP(className, properties)
    local s, d = pcall(function()
        local dr = Drawing.new(className)
        for k, v in pairs(properties) do pcall(function() dr[k] = v end) end
        return dr
    end)
    return s and d or nil
end

local function CreateBoxESP(obj, color, name)
    if ESPObjects[name] then
        for _, d in pairs(ESPObjects[name]) do
            pcall(function() d:Remove() end)
        end
    end
    
    ESPObjects[name] = {
        Box = CreateESP("Square", {Visible = false, Color = color, Thickness = 2, Filled = false}),
        Name = CreateESP("Text", {Visible = false, Text = name, Color = color, Size = 13, Center = true, Outline = true})
    }
end

local lastESPUpdate = 0

local function UpdateESP()
    local now = tick()
    if now - lastESPUpdate < PERF.ESP_UPDATE_RATE then return end
    lastESPUpdate = now
    
    CameraPos = Camera.CFrame.Position
    
    if not Settings.SurvivorESP and not Settings.KillerESP then
        for _, data in pairs(ESPObjects) do
            data.Box.Visible = false
            data.Name.Visible = false
        end
        return
    end
    
    local killer = FindKiller()
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local isKiller = (p == killer)
            
            if (Settings.SurvivorESP and not isKiller) or (Settings.KillerESP and isKiller) then
                if not ESPObjects[p.Name] then
                    local color = isKiller and Settings.KillerColor or Settings.SurvivorColor
                    CreateBoxESP(p.Character, color, p.Name)
                end
            end
        end
    end
    
    for name, data in pairs(ESPObjects) do
        local player = Players:FindFirstChild(name)
        if not player or not player.Character then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local char = player.Character
        local root = GetRootPart(char)
        local head = GetHead(char)
        
        if not root or not head then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local dist = (CameraPos - root.Position).Magnitude
        if dist > 2000 then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
        local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        
        local height = math.abs(headPos.Y - footPos.Y)
        local width = height * 0.45
        
        data.Box.Visible = true
        data.Box.Size = Vector2.new(width, height)
        data.Box.Position = Vector2.new(rootPos.X - width/2, headPos.Y)
        
        data.Name.Visible = true
        data.Name.Text = name .. " [" .. math.floor(dist) .. "]"
        data.Name.Position = Vector2.new(rootPos.X, headPos.Y - 15)
    end
end

-- ==================== АВТО-ЗАДАЧИ ====================

local function AutoGeneratorTask()
    if AutoTasks.Generator then AutoTasks.Generator:Disconnect() end
    if not Settings.AutoGenerator then return end
    
    AutoTasks.Generator = RunService.Heartbeat:Connect(function()
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:lower():find("generator") then
                    if LocalPlayer.Character then
                        local root = GetRootPart(LocalPlayer.Character)
                        if root and (root.Position - v.Parent.Position).Magnitude < 15 then
                            fireproximityprompt(v)
                        else
                            LocalPlayer.Character:MoveTo(v.Parent.Position)
                        end
                        break
                    end
                end
            end
        end)
    end)
end

local function AutoEscapeTask()
    if AutoTasks.Escape then AutoTasks.Escape:Disconnect() end
    if not Settings.AutoEscape then return end
    
    AutoTasks.Escape = RunService.Heartbeat:Connect(function()
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Part") and (v.Name:lower():find("exit") or v.Name:lower():find("escape")) then
                    if LocalPlayer.Character then
                        LocalPlayer.Character:MoveTo(v.Position)
                    end
                    break
                end
            end
        end)
    end)
end

local function AutoBarricadeTask()
    if AutoTasks.Barricade then AutoTasks.Barricade:Disconnect() end
    if not Settings.AutoBarricade then return end
    
    AutoTasks.Barricade = RunService.Heartbeat:Connect(function()
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:lower():find("barricade") then
                    if LocalPlayer.Character then
                        local root = GetRootPart(LocalPlayer.Character)
                        if root and (root.Position - v.Parent.Position).Magnitude < 15 then
                            fireproximityprompt(v)
                        else
                            LocalPlayer.Character:MoveTo(v.Parent.Position)
                        end
                        break
                    end
                end
            end
        end)
    end)
end

local function SafetyArea()
    pcall(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Part") and (v.Name:lower():find("safe") or v.Name:lower():find("spawn")) then
                if LocalPlayer.Character then
                    LocalPlayer.Character:MoveTo(v.Position)
                end
                break
            end
        end
    end)
end

local function ViewKillerFunc()
    local killer = FindKiller()
    if killer and killer.Character then
        Camera.CameraSubject = killer.Character
        task.wait(3)
        Camera.CameraSubject = LocalPlayer.Character
    end
end

-- ==================== ДРУГИЕ ФУНКЦИИ ====================

local function InfiniteSprintFunc()
    if OtherTasks.Sprint then OtherTasks.Sprint:Disconnect() end
    if not Settings.InfiniteSprint then return end
    
    OtherTasks.Sprint = RunService.Heartbeat:Connect(function()
        pcall(function()
            LocalPlayer:SetAttribute("Stamina", 100)
            LocalPlayer:SetAttribute("Energy", 100)
        end)
    end)
end

local function AllowJumpingFunc()
    if OtherTasks.Jump then OtherTasks.Jump:Disconnect() end
    if not Settings.AllowJumping then return end
    
    OtherTasks.Jump = RunService.Heartbeat:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                local humanoid = GetHumanoid(LocalPlayer.Character)
                if humanoid then
                    humanoid.JumpPower = 50
                    humanoid.Jump = true
                end
            end
        end)
    end)
end

local function AimlockFunc()
    if OtherTasks.Aimlock then OtherTasks.Aimlock:Disconnect() end
    if not Settings.Aimlock then return end
    
    OtherTasks.Aimlock = RunService.RenderStepped:Connect(function()
        pcall(function()
            local closest, minDist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local root = GetRootPart(p.Character)
                    if root then
                        local dist = (CameraPos - root.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = p
                        end
                    end
                end
            end
            if closest and closest.Character then
                local root = GetRootPart(closest.Character)
                if root then
                    Camera.CFrame = CFrame.new(CameraPos, root.Position)
                end
            end
        end)
    end)
end

local function NoclipFunc()
    if OtherTasks.Noclip then OtherTasks.Noclip:Disconnect() end
    if not Settings.Noclip then return end
    
    OtherTasks.Noclip = RunService.Heartbeat:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end

-- ==================== GUI ====================

local function CreateWindow()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CeleronGUI"
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BackgroundTransparency = 1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    
    -- Плавное появление
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.05}):Play()
    
    WindowState.MainFrame = MainFrame
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Celeron's GUI (Bite By Night)"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -75, 0, 5)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 18
    MinimizeBtn.Parent = TitleBar
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Parent = TitleBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    
    CloseBtn.MouseButton1Click:Connect(function()
        for _, task in pairs(AutoTasks) do if task then task:Disconnect() end end
        for _, task in pairs(OtherTasks) do if task then task:Disconnect() end end
        for _, v in pairs(ESPObjects) do
            for _, d in pairs(v) do pcall(function() d:Remove() end) end
        end
        ScreenGui:Destroy()
    end)
    
    local TabHolder = Instance.new("Frame")
    TabHolder.Size = UDim2.new(0, 120, 1, -40)
    TabHolder.Position = UDim2.new(0, 0, 0, 40)
    TabHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabHolder.BorderSizePixel = 0
    TabHolder.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabHolder
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 2)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -120, 1, -40)
    ContentFrame.Position = UDim2.new(0, 120, 0, 40)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    local function ToggleMinimize()
        WindowState.Minimized = not WindowState.Minimized
        if WindowState.Minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 600, 0, 40)}):Play()
            TabHolder.Visible = false
            ContentFrame.Visible = false
            MinimizeBtn.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 600, 0, 400)}):Play()
            TabHolder.Visible = true
            ContentFrame.Visible = true
            MinimizeBtn.Text = "—"
        end
    end
    
    MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    local function CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 14
        TabBtn.Parent = TabHolder
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 6
        TabContent.Visible = false
        TabContent.Parent = ContentFrame
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local ContentList = Instance.new("UIListLayout")
        ContentList.Parent = TabContent
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Padding = UDim.new(0, 10)
        
        Instance.new("UIPadding", TabContent).PaddingTop = UDim.new(0, 10)
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, tab in ipairs(Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
            TabContent.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
        
        table.insert(Tabs, {Button = TabBtn, Content = TabContent})
        return TabContent
    end
    
    local function CreateToggle(parent, text, settingName, callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -20, 0, 40)
        Frame.Position = UDim2.new(0, 10, 0, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Frame.BorderSizePixel = 0
        Frame.Parent = parent
        
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.6, 0, 1, 0)
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame
        
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0, 60, 0, 24)
        Toggle.Position = UDim2.new(1, -75, 0.5, -12)
        Toggle.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        Toggle.Text = Settings[settingName] and "ON" or "OFF"
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.Font = Enum.Font.GothamBold
        Toggle.TextSize = 12
        Toggle.AutoButtonColor = false
        Toggle.Parent = Frame
        
        Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)
        
        ToggleButtons[settingName] = Toggle
        
        Toggle.MouseButton1Click:Connect(function()
            Settings[settingName] = not Settings[settingName]
            Toggle.Text = Settings[settingName] and "ON" or "OFF"
            Toggle.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            if callback then callback(Settings[settingName]) end
        end)
        
        return Frame
    end
    
    local function CreateButton(parent, text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -20, 0, 35)
        Btn.Position = UDim2.new(0, 10, 0, 0)
        Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 14
        Btn.Parent = parent
        
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        Btn.MouseButton1Click:Connect(callback)
        return Btn
    end
    
    local function CreateBind(parent, text, settingName)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -20, 0, 50)
        Frame.Position = UDim2.new(0, 10, 0, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Frame.BorderSizePixel = 0
        Frame.Parent = parent
        
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Position = UDim2.new(0, 10, 0, 5)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame
        
        local Input = Instance.new("TextBox")
        Input.Size = UDim2.new(0.5, 0, 0, 20)
        Input.Position = UDim2.new(0, 10, 0, 25)
        Input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Input.Text = Settings[settingName]
        Input.TextColor3 = Color3.fromRGB(255, 255, 255)
        Input.Font = Enum.Font.Gotham
        Input.TextSize = 12
        Input.PlaceholderText = "Key (Z, X, C...)"
        Input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        Input.Parent = Frame
        
        Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 4)
        
        Input.FocusLost:Connect(function()
            Settings[settingName] = Input.Text:upper()
        end)
        
        return Frame
    end
    
    -- Создание вкладок
    local MainTab = CreateTab("Main")
    local SurvivorTab = CreateTab("Survivor")
    local VisualTab = CreateTab("Visual")
    local TeleportTab = CreateTab("Teleport")
    local OthersTab = CreateTab("Others")
    local InfoTab = CreateTab("Info")
    
    Tabs[1].Content.Visible = true
    Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    -- Заполнение вкладок
    CreateToggle(MainTab, "Auto Generator", "AutoGenerator", AutoGeneratorTask)
    CreateToggle(MainTab, "Auto Escape", "AutoEscape", AutoEscapeTask)
    CreateToggle(MainTab, "Auto Barricade", "AutoBarricade", AutoBarricadeTask)
    CreateButton(MainTab, "Safety Area", SafetyArea)
    CreateButton(MainTab, "View Killer", ViewKillerFunc)
    
    CreateToggle(SurvivorTab, "Survivor ESP", "SurvivorESP")
    CreateToggle(SurvivorTab, "Killer ESP", "KillerESP")
    
    CreateToggle(VisualTab, "Generator ESP", "GeneratorESP")
    CreateToggle(VisualTab, "Battery ESP", "BatteryESP")
    CreateToggle(VisualTab, "Fuse Box ESP", "FuseBoxESP")
    
    CreateButton(TeleportTab, "Safety Area", SafetyArea)
    CreateButton(TeleportTab, "Escape Area", function()
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Part") and (v.Name:lower():find("exit") or v.Name:lower():find("escape")) then
                    LocalPlayer.Character:MoveTo(v.Position)
                    break
                end
            end
        end)
    end)
    
    CreateToggle(OthersTab, "Infinite Sprint", "InfiniteSprint", InfiniteSprintFunc)
    CreateToggle(OthersTab, "Allow Jumping", "AllowJumping", AllowJumpingFunc)
    CreateToggle(OthersTab, "Aimlock", "Aimlock", AimlockFunc)
    CreateBind(OthersTab, "Aimlock Bind", "AimlockBind")
    CreateToggle(OthersTab, "Noclip", "Noclip", NoclipFunc)
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -20, 0, 200)
    InfoLabel.Position = UDim2.new(0, 10, 0, 10)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Celeron's GUI for Bite By Night\n\n✓ Optimized (no lags)\n✓ Smooth loading\n✓ Model support\n✓ Anti-cheat bypass\n\nClick — to minimize"
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextSize = 14
    InfoLabel.TextWrapped = true
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    InfoLabel.Parent = InfoTab
    
    -- Перетаскивание
    local dragging, dragStart, startPos = false, nil, nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ==================== ЗАПУСК ====================

-- Показываем загрузчик
ShowLoader()

-- Обход античита
setupAntiCheatBypass()

-- Создаём GUI
CreateWindow()

-- Оптимизированные обработчики
RunService.RenderStepped:Connect(UpdateESP)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.3)
        KillerCache.lastCheck = 0 -- Сброс кэша
    end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[Settings.AimlockBind] then
        Settings.Aimlock = not Settings.Aimlock
        if ToggleButtons["Aimlock"] then
            ToggleButtons["Aimlock"].Text = Settings.Aimlock and "ON" or "OFF"
            ToggleButtons["Aimlock"].BackgroundColor3 = Settings.Aimlock and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        end
        AimlockFunc()
    end
end)

print("Celeron's GUI loaded! Smooth + Optimized!")
