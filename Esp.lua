--[[
    Celeron's GUI для Bite By Night
    МАКСИМАЛЬНАЯ ОПТИМИЗАЦИЯ (БЕЗ ЛАГОВ)
--]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Настройки производительности (СНИЖЕНЫ ДЛЯ УСТРАНЕНИЯ ЛАГОВ)
local PERF = {
    ESP_UPDATE_RATE = 0.05,      -- 20 FPS вместо 60
    GENERATOR_CHECK_RATE = 1,      -- Раз в секунду
    KILLER_CHECK_RATE = 2,        -- Раз в 2 секунды
    MAX_DISTANCE = 1000           -- Уменьшена дистанция ESP
}

-- Переменные
local ESPObjects = {}
local GeneratorESPList = {}
local Settings = {
    AutoGenerator = false, AutoEscape = false, AutoBarricade = false,
    SurvivorESP = false, KillerESP = false, GeneratorESP = false,
    BatteryESP = false, FuseBoxESP = false,
    InfiniteSprint = false, AllowJumping = false, Aimlock = false,
    AimlockBind = "Z", Noclip = false,
    KillerColor = Color3.fromRGB(0, 255, 0),
    SurvivorColor = Color3.fromRGB(255, 0, 0),
    GeneratorColor = Color3.fromRGB(255, 255, 0)
}

local WindowState = { Minimized = false, MainFrame = nil }
local Tabs = {}
local ToggleButtons = {}
local AutoTasks = {}
local OtherTasks = {}

-- Кэш для оптимизации
local KillerCache = { player = nil, lastCheck = 0 }
local GeneratorCache = { list = {}, lastCheck = 0 }
local CameraPos = Vector3.new()
local PlayerListCache = {}

-- ==================== МГНОВЕННЫЙ ЗАГРУЗЧИК (БЕЗ АНИМАЦИЙ) ====================

local function ShowLoader()
    -- Создаём минимальный загрузчик без тяжёлых анимаций
    local loader = Instance.new("ScreenGui")
    loader.Name = "Loader"
    loader.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 60)
    frame.Position = UDim2.new(0.5, -130, 0.5, -30)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = loader
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "Celeron's GUI"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 35)
    status.BackgroundTransparency = 1
    status.Text = "Loading..."
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.Parent = frame
    
    task.wait(0.5) -- Минимальная задержка
    loader:Destroy()
end

-- ==================== ОБХОД АНТИЧИТА (ЛЁГКИЙ) ====================

local function setupAntiCheatBypass()
    pcall(function()
        for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
            local name = v.Name
            if name:find("Anti") or name:find("Cheat") or name:find("Detect") then
                v:Destroy()
            end
        end
    end)
end

-- ==================== ФУНКЦИИ ДЛЯ МОДЕЛЕЙ (УПРОЩЁННЫЕ) ====================

local function GetRootPart(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
end

local function GetHead(model)
    if not model then return nil end
    return model:FindFirstChild("Head")
end

local function GetHumanoid(model)
    return model and model:FindFirstChildOfClass("Humanoid")
end

-- ==================== ОПРЕДЕЛЕНИЕ УБИЙЦЫ ====================

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

-- ==================== ПОИСК ГЕНЕРАТОРОВ (ОПТИМИЗИРОВАН) ====================

local function FindGenerators()
    local now = tick()
    if now - GeneratorCache.lastCheck < PERF.GENERATOR_CHECK_RATE then
        return GeneratorCache.list
    end
    GeneratorCache.lastCheck = now
    GeneratorCache.list = {}
    
    -- Только быстрый поиск по имени
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("generator") then
            table.insert(GeneratorCache.list, obj)
        end
    end
    return GeneratorCache.list
end

-- ==================== ESP (ОПТИМИЗИРОВАН) ====================

local function CreateDrawing(className, properties)
    local s, d = pcall(function()
        return Drawing.new(className)
    end)
    if s and d then
        for k, v in pairs(properties) do
            pcall(function() d[k] = v end)
        end
        return d
    end
    return nil
end

local function ClearESP(name)
    if ESPObjects[name] then
        for _, d in pairs(ESPObjects[name]) do
            pcall(function() d:Remove() end)
        end
        ESPObjects[name] = nil
    end
end

local function CreatePlayerESP(player, color)
    ClearESP(player.Name)
    ESPObjects[player.Name] = {
        Box = CreateDrawing("Square", {Visible = false, Color = color, Thickness = 2, Filled = false}),
        Name = CreateDrawing("Text", {Visible = false, Text = player.Name, Color = color, Size = 13, Center = true, Outline = true})
    }
end

local function CreateGeneratorESP(generator, color)
    local id = "Gen_" .. generator:GetFullName()
    if GeneratorESPList[id] then return end
    
    GeneratorESPList[id] = {
        Box = CreateDrawing("Square", {Visible = false, Color = color, Thickness = 2, Filled = false}),
        Name = CreateDrawing("Text", {Visible = false, Text = "GEN", Color = color, Size = 12, Center = true, Outline = true})
    }
end

local lastESPUpdate = 0

local function UpdateESP()
    local now = tick()
    if now - lastESPUpdate < PERF.ESP_UPDATE_RATE then return end
    lastESPUpdate = now
    
    CameraPos = Camera.CFrame.Position
    local killer = FindKiller()
    
    -- ESP игроков (только если включено)
    if Settings.SurvivorESP or Settings.KillerESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isKiller = (p == killer)
                if (Settings.SurvivorESP and not isKiller) or (Settings.KillerESP and isKiller) then
                    if not ESPObjects[p.Name] then
                        CreatePlayerESP(p, isKiller and Settings.KillerColor or Settings.SurvivorColor)
                    end
                end
            end
        end
    end
    
    -- Обновление позиций игроков
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
        
        if not root then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local dist = (CameraPos - root.Position).Magnitude
        if dist > PERF.MAX_DISTANCE then
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
        
        -- Упрощённый расчёт размеров
        local height = 1000 / dist
        local width = height * 0.45
        
        data.Box.Visible = true
        data.Box.Size = Vector2.new(width, height)
        data.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
        
        data.Name.Visible = true
        data.Name.Text = name
        data.Name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 15)
    end
    
    -- ESP генераторов
    if Settings.GeneratorESP then
        local generators = FindGenerators()
        for _, gen in ipairs(generators) do
            local id = "Gen_" .. gen:GetFullName()
            CreateGeneratorESP(gen, Settings.GeneratorColor)
        end
    end
    
    -- Обновление позиций генераторов
    for id, data in pairs(GeneratorESPList) do
        if not Settings.GeneratorESP then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local gen = nil
        pcall(function() gen = workspace:FindFirstChild(id:sub(5)) end)
        
        if not gen or not gen.Parent then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local root = gen.PrimaryPart or gen:FindFirstChildOfClass("BasePart")
        if not root then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local dist = (CameraPos - root.Position).Magnitude
        if dist > PERF.MAX_DISTANCE then
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
        
        local height = 800 / dist
        local width = height * 0.8
        
        data.Box.Visible = true
        data.Box.Size = Vector2.new(width, height)
        data.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
        
        data.Name.Visible = true
        data.Name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 12)
    end
end

-- ==================== АВТО-ЗАДАЧИ (ОПТИМИЗИРОВАНЫ) ====================

local function AutoGeneratorTask()
    if AutoTasks.Generator then AutoTasks.Generator:Disconnect() end
    if not Settings.AutoGenerator then return end
    
    AutoTasks.Generator = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not LocalPlayer.Character then return end
            for _, gen in ipairs(FindGenerators()) do
                local prompt = gen:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    local genPos = gen.PrimaryPart and gen.PrimaryPart.Position
                    if genPos then
                        LocalPlayer.Character:MoveTo(genPos)
                        if (LocalPlayer.Character:GetPivot().Position - genPos).Magnitude < 15 then
                            fireproximityprompt(prompt)
                        end
                    end
                    break
                end
            end
        end)
    end)
end

local function AutoEscapeTask()
    if AutoTasks.Escape then AutoTasks.Escape:Disconnect() end
    if not Settings.AutoEscape then return end
end

local function AutoBarricadeTask()
    if AutoTasks.Barricade then AutoTasks.Barricade:Disconnect() end
    if not Settings.AutoBarricade then return end
end

local function SafetyArea()
    pcall(function()
        if not LocalPlayer.Character then return end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Part") and (v.Name:lower():find("safe") or v.Name:lower():find("spawn")) then
                LocalPlayer.Character:MoveTo(v.Position)
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

-- ==================== INFINITE SPRINT (ЛЁГКИЙ) ====================

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
end

local function AimlockFunc()
    if OtherTasks.Aimlock then OtherTasks.Aimlock:Disconnect() end
    if not Settings.Aimlock then return end
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

-- ==================== GUI (ОПТИМИЗИРОВАН) ====================

local function CreateWindow()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CeleronGUI"
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    WindowState.MainFrame = MainFrame
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Celeron's GUI"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
    MinimizeBtn.Position = UDim2.new(1, -65, 0, 4)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 16
    MinimizeBtn.Parent = TitleBar
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 5)
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -32, 0, 4)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.Parent = TitleBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
    
    CloseBtn.MouseButton1Click:Connect(function()
        for _, task in pairs(AutoTasks) do if task then task:Disconnect() end end
        for _, task in pairs(OtherTasks) do if task then task:Disconnect() end end
        for _, v in pairs(ESPObjects) do
            for _, d in pairs(v) do pcall(function() d:Remove() end) end
        end
        for _, v in pairs(GeneratorESPList) do
            for _, d in pairs(v) do pcall(function() d:Remove() end) end
        end
        ScreenGui:Destroy()
    end)
    
    local TabHolder = Instance.new("Frame")
    TabHolder.Size = UDim2.new(0, 110, 1, -35)
    TabHolder.Position = UDim2.new(0, 0, 0, 35)
    TabHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabHolder.BorderSizePixel = 0
    TabHolder.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabHolder
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 2)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -110, 1, -35)
    ContentFrame.Position = UDim2.new(0, 110, 0, 35)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    local function ToggleMinimize()
        WindowState.Minimized = not WindowState.Minimized
        if WindowState.Minimized then
            MainFrame.Size = UDim2.new(0, 550, 0, 35)
            TabHolder.Visible = false
            ContentFrame.Visible = false
            MinimizeBtn.Text = "+"
        else
            MainFrame.Size = UDim2.new(0, 550, 0, 350)
            TabHolder.Visible = true
            ContentFrame.Visible = true
            MinimizeBtn.Text = "—"
        end
    end
    
    MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)
    
    local function CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 13
        TabBtn.Parent = TabHolder
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 5
        TabContent.Visible = false
        TabContent.Parent = ContentFrame
        
        local ContentList = Instance.new("UIListLayout")
        ContentList.Parent = TabContent
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Padding = UDim.new(0, 8)
        
        Instance.new("UIPadding", TabContent).PaddingTop = UDim.new(0, 8)
        
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
        Frame.Size = UDim2.new(1, -16, 0, 36)
        Frame.Position = UDim2.new(0, 8, 0, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Frame.BorderSizePixel = 0
        Frame.Parent = parent
        
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.6, 0, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame
        
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0, 55, 0, 22)
        Toggle.Position = UDim2.new(1, -65, 0.5, -11)
        Toggle.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        Toggle.Text = Settings[settingName] and "ON" or "OFF"
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.Font = Enum.Font.GothamBold
        Toggle.TextSize = 11
        Toggle.AutoButtonColor = false
        Toggle.Parent = Frame
        
        Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 5)
        
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
        Btn.Size = UDim2.new(1, -16, 0, 32)
        Btn.Position = UDim2.new(0, 8, 0, 0)
        Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 13
        Btn.Parent = parent
        
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        Btn.MouseButton1Click:Connect(callback)
        return Btn
    end
    
    local function CreateBind(parent, text, settingName)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -16, 0, 45)
        Frame.Position = UDim2.new(0, 8, 0, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Frame.BorderSizePixel = 0
        Frame.Parent = parent
        
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -16, 0, 18)
        Label.Position = UDim2.new(0, 8, 0, 4)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 11
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame
        
        local Input = Instance.new("TextBox")
        Input.Size = UDim2.new(0.5, 0, 0, 20)
        Input.Position = UDim2.new(0, 8, 0, 22)
        Input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Input.Text = Settings[settingName]
        Input.TextColor3 = Color3.fromRGB(255, 255, 255)
        Input.Font = Enum.Font.Gotham
        Input.TextSize = 11
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
    
    Tabs[1].Content.Visible = true
    Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
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
            if not LocalPlayer.Character then return end
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

-- ==================== ЗАПУСК (БЕЗ ЛАГОВ) ====================

ShowLoader()
setupAntiCheatBypass()
CreateWindow()

-- Только один RenderStepped для ESP
RunService.RenderStepped:Connect(UpdateESP)

-- Минимальные обработчики
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        KillerCache.lastCheck = 0
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

print("Celeron's GUI loaded! Optimized - no lags!")
