--[[
    Celeron's GUI для Bite By Night
    Полный скрипт с функциями из Celeron's Loader
]]

-- Сервисы
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local StarterGui = game:GetService("StarterGui")

-- ==================== ПЛАВНЫЙ ЗАГРУЗЧИК (ИЗ CELERON'S LOADER) ====================

local function ShowLoader()
    local loaderGui = Instance.new("ScreenGui")
    loaderGui.Name = "CeleronLoader"
    loaderGui.ResetOnSpawn = false
    loaderGui.Parent = PlayerGui
    
    local blur = Instance.new("BlurEffect")
    blur.Size = 6
    blur.Parent = game:GetService("Lighting")
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 300, 0, 140)
    bg.Position = UDim2.new(0.5, -150, 0.5, -70)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    bg.BackgroundTransparency = 0.2
    bg.BorderSizePixel = 0
    bg.Parent = loaderGui
    
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 115, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 155, 170)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    }
    gradient.Parent = bg
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Celeron's GUI"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = bg
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 40)
    label.BackgroundTransparency = 1
    label.Text = "Loading Bite By Night..."
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.Parent = bg
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 18)
    frame.Position = UDim2.new(0.05, 0, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.Parent = bg
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 8)
    
    -- Анимация загрузки
    TweenService:Create(bar, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0)
    }):Play()
    
    task.wait(1.6)
    
    -- Затухание
    for _, obj in ipairs(loaderGui:GetDescendants()) do
        if obj:IsA("GuiObject") then
            local props = {BackgroundTransparency = 1}
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                props.TextTransparency = 1
            end
            TweenService:Create(obj, TweenInfo.new(0.5), props):Play()
        end
    end
    
    task.wait(0.5)
    blur:Destroy()
    loaderGui:Destroy()
end

ShowLoader()

-- ==================== НАСТРОЙКИ ====================

local Settings = {
    -- ESP
    SurvivorESP = true,
    KillerESP = true,
    GeneratorESP = true,
    BatteryESP = false,
    FuseBoxESP = false,
    
    -- Visual
    ESPEnabled = true,
    KillerColor = Color3.fromRGB(0, 255, 0),
    SurvivorColor = Color3.fromRGB(255, 0, 0),
    GeneratorColor = Color3.fromRGB(255, 255, 0),
    BatteryColor = Color3.fromRGB(0, 255, 255),
    FuseBoxColor = Color3.fromRGB(255, 0, 255),
    
    -- Main
    AutoGenerator = false,
    AutoEscape = false,
    AutoBarricade = false,
    
    -- Others
    InfiniteSprint = false,
    AllowJumping = false,
    Aimlock = false,
    AimlockBind = "Z",
    Noclip = false,
    SpeedEnabled = false,
    SpeedValue = 40
}

-- ==================== ХРАНИЛИЩЕ ====================

local ESPObjects = {}
local ObjectESPList = {}
local AutoTasks = {}
local OtherTasks = {}

-- Кэш
local KillerCache = { player = nil, lastCheck = 0 }
local GeneratorCache = { list = {}, lastCheck = 0 }
local BatteryCache = { list = {}, lastCheck = 0 }
local CameraPos = Vector3.new()

-- ==================== ОБХОД АНТИЧИТА ====================

local function setupAntiCheat()
    pcall(function()
        for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
            local n = v.Name:lower()
            if n:find("anti") or n:find("cheat") or n:find("detect") then
                v:Destroy()
            end
        end
        
        for _, v in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            local n = v.Name:lower()
            if n:find("anti") or n:find("cheat") then
                v:Destroy()
            end
        end
        
        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and (self.Name == "Kick" or self.Name:find("Ban")) then
                return nil
            end
            return oldNamecall(self, ...)
        end)
        
        local oldIndex = hookmetamethod(game, "__index", function(self, key)
            if self == LocalPlayer then
                if key == "Stamina" or key == "Energy" then
                    return 100
                end
            end
            return oldIndex(self, key)
        end)
    end)
end

setupAntiCheat()

-- ==================== ФУНКЦИИ ДЛЯ МОДЕЛЕЙ ====================

local function GetRootPart(model)
    if not model then return nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    return model.PrimaryPart or model:FindFirstChildOfClass("BasePart")
end

local function GetHumanoid(model)
    return model and model:FindFirstChildOfClass("Humanoid")
end

-- ==================== ОПРЕДЕЛЕНИЕ УБИЙЦЫ ====================

local function FindKiller()
    local now = tick()
    if now - KillerCache.lastCheck < 2 then
        return KillerCache.player
    end
    KillerCache.lastCheck = now
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = GetHumanoid(p.Character)
            if h and h.MaxHealth > 500 then
                KillerCache.player = p
                return p
            end
            
            for _, tool in ipairs(p.Character:GetDescendants()) do
                if tool:IsA("Tool") then
                    local n = tool.Name:lower()
                    if n:find("remnant") or n:find("cleaver") then
                        KillerCache.player = p
                        return p
                    end
                end
            end
        end
    end
    return KillerCache.player
end

-- ==================== ПОИСК ОБЪЕКТОВ ====================

local function FindGenerators()
    local now = tick()
    if now - GeneratorCache.lastCheck < 2 then
        return GeneratorCache.list
    end
    GeneratorCache.lastCheck = now
    GeneratorCache.list = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("generator") then
            table.insert(GeneratorCache.list, obj)
        elseif obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent.Name:lower():find("generator") then
            table.insert(GeneratorCache.list, obj.Parent)
        end
    end
    return GeneratorCache.list
end

local function FindBatteries()
    local now = tick()
    if now - BatteryCache.lastCheck < 2 then
        return BatteryCache.list
    end
    BatteryCache.lastCheck = now
    BatteryCache.list = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("battery") then
            table.insert(BatteryCache.list, obj)
        elseif obj:IsA("BasePart") and obj.Name:lower():find("battery") then
            table.insert(BatteryCache.list, obj)
        end
    end
    return BatteryCache.list
end

-- ==================== DRAWING ====================

local function CreateDrawing(className, properties)
    local s, d = pcall(function() return Drawing.new(className) end)
    if s and d then
        for k, v in pairs(properties) do pcall(function() d[k] = v end) end
        return d
    end
    return nil
end

-- ==================== СОЗДАНИЕ ESP ====================

local function CreatePlayerESP(player, color)
    if ESPObjects[player] then
        for _, d in pairs(ESPObjects[player]) do pcall(function() d:Remove() end) end
    end
    
    ESPObjects[player] = {
        Box = CreateDrawing("Square", {Visible = false, Color = color, Thickness = 2, Filled = false}),
        Name = CreateDrawing("Text", {Visible = false, Text = player.Name, Color = color, Size = 13, Center = true, Outline = true}),
        Tracer = CreateDrawing("Line", {Visible = false, Color = color, Thickness = 1})
    }
end

local function CreateObjectESP(obj, color, name)
    local id = obj:GetFullName()
    if ObjectESPList[id] then return end
    
    ObjectESPList[id] = {
        Box = CreateDrawing("Square", {Visible = false, Color = color, Thickness = 2, Filled = false}),
        Name = CreateDrawing("Text", {Visible = false, Text = name, Color = color, Size = 12, Center = true, Outline = true}),
        Obj = obj
    }
end

-- ==================== ОБНОВЛЕНИЕ ESP ====================

local function UpdateESP()
    CameraPos = Camera.CFrame.Position
    local killer = FindKiller()
    
    if Settings.ESPEnabled then
        -- Игроки
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isKiller = (p == killer)
                if (Settings.SurvivorESP and not isKiller) or (Settings.KillerESP and isKiller) then
                    if not ESPObjects[p] then
                        CreatePlayerESP(p, isKiller and Settings.KillerColor or Settings.SurvivorColor)
                    end
                end
            end
        end
    end
    
    -- Обновление позиций игроков
    for p, data in pairs(ESPObjects) do
        local player = type(p) == "string" and Players:FindFirstChild(p) or p
        if not player or not player.Character then
            data.Box.Visible = false
            data.Name.Visible = false
            data.Tracer.Visible = false
            continue
        end
        
        local root = GetRootPart(player.Character)
        if not root then
            data.Box.Visible = false
            data.Name.Visible = false
            data.Tracer.Visible = false
            continue
        end
        
        local dist = (CameraPos - root.Position).Magnitude
        if dist > 2000 or not Settings.ESPEnabled then
            data.Box.Visible = false
            data.Name.Visible = false
            data.Tracer.Visible = false
            continue
        end
        
        local pos, on = Camera:WorldToViewportPoint(root.Position)
        if not on then
            data.Box.Visible = false
            data.Name.Visible = false
            data.Tracer.Visible = false
            continue
        end
        
        local h = 1400 / dist
        local w = h * 0.45
        
        data.Box.Visible = true
        data.Box.Size = Vector2.new(w, h)
        data.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
        data.Name.Visible = true
        data.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 15)
        data.Tracer.Visible = true
        data.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        data.Tracer.To = Vector2.new(pos.X, pos.Y)
    end
    
    -- Объекты
    if Settings.ESPEnabled then
        if Settings.GeneratorESP then
            for _, gen in ipairs(FindGenerators()) do
                CreateObjectESP(gen, Settings.GeneratorColor, "GENERATOR")
            end
        end
        
        if Settings.BatteryESP then
            for _, bat in ipairs(FindBatteries()) do
                CreateObjectESP(bat, Settings.BatteryColor, "BATTERY")
            end
        end
    end
    
    -- Обновление позиций объектов
    for id, data in pairs(ObjectESPList) do
        if not Settings.ESPEnabled then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local obj = data.Obj
        if not obj or not obj.Parent then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local root = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        if not root then
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
        
        local pos, on = Camera:WorldToViewportPoint(root.Position)
        if not on then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local h = 1000 / dist
        local w = h * 0.8
        
        data.Box.Visible = true
        data.Box.Size = Vector2.new(w, h)
        data.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
        data.Name.Visible = true
        data.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 15)
    end
end

-- ==================== АВТО-ЗАДАЧИ ====================

local function AutoGeneratorTask()
    if AutoTasks.Generator then AutoTasks.Generator:Disconnect() end
    if not Settings.AutoGenerator then return end
    
    AutoTasks.Generator = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not LocalPlayer.Character then return end
            for _, gen in ipairs(FindGenerators()) do
                local prompt = gen:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    local pos = gen:IsA("BasePart") and gen.Position or (gen.PrimaryPart and gen.PrimaryPart.Position)
                    if pos then
                        LocalPlayer.Character:MoveTo(pos)
                        if (LocalPlayer.Character:GetPivot().Position - pos).Magnitude < 15 then
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
    
    AutoTasks.Escape = RunService.Heartbeat:Connect(function()
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
end

local function AutoBarricadeTask()
    if AutoTasks.Barricade then AutoTasks.Barricade:Disconnect() end
    if not Settings.AutoBarricade then return end
    
    AutoTasks.Barricade = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not LocalPlayer.Character then return end
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:lower():find("barricade") then
                    local pos = v.Parent:IsA("BasePart") and v.Parent.Position or (v.Parent.PrimaryPart and v.Parent.PrimaryPart.Position)
                    if pos then
                        LocalPlayer.Character:MoveTo(pos)
                        if (LocalPlayer.Character:GetPivot().Position - pos).Magnitude < 10 then
                            fireproximityprompt(v)
                        end
                    end
                    break
                end
            end
        end)
    end)
end

-- ==================== ДРУГИЕ ФУНКЦИИ ====================

local function SpeedTask()
    if OtherTasks.Speed then OtherTasks.Speed:Disconnect() end
    if not Settings.SpeedEnabled then return end
    
    OtherTasks.Speed = RunService.Heartbeat:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                local h = GetHumanoid(LocalPlayer.Character)
                if h then h.WalkSpeed = Settings.SpeedValue end
            end
        end)
    end)
end

local function InfiniteSprintTask()
    if OtherTasks.Sprint then OtherTasks.Sprint:Disconnect() end
    if not Settings.InfiniteSprint then return end
    
    OtherTasks.Sprint = RunService.Heartbeat:Connect(function()
        pcall(function()
            LocalPlayer:SetAttribute("Stamina", 100)
            LocalPlayer:SetAttribute("Energy", 100)
        end)
    end)
end

local function AllowJumpingTask()
    if OtherTasks.Jump then OtherTasks.Jump:Disconnect() end
    if not Settings.AllowJumping then return end
    
    OtherTasks.Jump = RunService.Heartbeat:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                local h = GetHumanoid(LocalPlayer.Character)
                if h then
                    h.JumpPower = 50
                    h.Jump = true
                end
            end
        end)
    end)
end

local function AimlockTask()
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

local function NoclipTask()
    if OtherTasks.Noclip then OtherTasks.Noclip:Disconnect() end
    if not Settings.Noclip then return end
    
    OtherTasks.Noclip = RunService.Heartbeat:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end)
end

-- ==================== GUI (В СТИЛЕ CELERON) ====================

local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CeleronGUI"
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BackgroundTransparency = 1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.05}):Play()
    
    -- Заголовок
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
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Кнопка сворачивания
    local Minimize = Instance.new("TextButton")
    Minimize.Size = UDim2.new(0, 30, 0, 30)
    Minimize.Position = UDim2.new(1, -75, 0, 5)
    Minimize.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Minimize.Text = "—"
    Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 18
    Minimize.Parent = TitleBar
    Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 6)
    
    -- Кнопка закрытия
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.Position = UDim2.new(1, -35, 0, 5)
    Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 16
    Close.Parent = TitleBar
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
    
    Close.MouseButton1Click:Connect(function()
        for _, t in pairs(AutoTasks) do if t then t:Disconnect() end end
        for _, t in pairs(OtherTasks) do if t then t:Disconnect() end end
        ScreenGui:Destroy()
    end)
    
    -- Вкладки
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
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -120, 1, -40)
    Content.Position = UDim2.new(0, 120, 0, 40)
    Content.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Content.BorderSizePixel = 0
    Content.Parent = MainFrame
    
    local Tabs = {}
    local function CreateTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = TabHolder
        
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 6
        page.Visible = false
        page.Parent = Content
        
        local list = Instance.new("UIListLayout")
        list.Parent = page
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 10)
        
        Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 10)
        
        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Page.Visible = false
                t.Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
        
        table.insert(Tabs, {Btn = btn, Page = page})
        return page
    end
    
    local function CreateToggle(parent, text, setting, callback)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -20, 0, 38)
        f.Position = UDim2.new(0, 10, 0, 0)
        f.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        f.BorderSizePixel = 0
        f.Parent = parent
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
        
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6, 0, 1, 0)
        l.Position = UDim2.new(0, 15, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(255, 255, 255)
        l.Font = Enum.Font.Gotham
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        
        local t = Instance.new("TextButton")
        t.Size = UDim2.new(0, 60, 0, 24)
        t.Position = UDim2.new(1, -75, 0.5, -12)
        t.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        t.Text = Settings[setting] and "ON" or "OFF"
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.AutoButtonColor = false
        t.Parent = f
        Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
        
        t.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            t.Text = Settings[setting] and "ON" or "OFF"
            t.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            if callback then callback() end
        end)
        
        return f
    end
    
    local function CreateButton(parent, text, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -20, 0, 35)
        b.Position = UDim2.new(0, 10, 0, 0)
        b.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.MouseButton1Click:Connect(callback)
        return b
    end
    
    local function CreateBind(parent, text, setting)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -20, 0, 50)
        f.Position = UDim2.new(0, 10, 0, 0)
        f.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        f.BorderSizePixel = 0
        f.Parent = parent
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
        
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 0, 20)
        l.Position = UDim2.new(0, 10, 0, 5)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(200, 200, 200)
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        
        local i = Instance.new("TextBox")
        i.Size = UDim2.new(0.5, 0, 0, 20)
        i.Position = UDim2.new(0, 10, 0, 25)
        i.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        i.Text = Settings[setting]
        i.TextColor3 = Color3.fromRGB(255, 255, 255)
        i.Font = Enum.Font.Gotham
        i.TextSize = 12
        i.PlaceholderText = "Key (Z, X, C...)"
        i.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        i.Parent = f
        Instance.new("UICorner", i).CornerRadius = UDim.new(0, 4)
        
        i.FocusLost:Connect(function()
            Settings[setting] = i.Text:upper()
        end)
        
        return f
    end
    
    -- Создание вкладок
    local MainTab = CreateTab("Main")
    local VisualTab = CreateTab("Visual")
    local TeleportTab = CreateTab("Teleport")
    local OthersTab = CreateTab("Others")
    
    Tabs[1].Page.Visible = true
    Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    -- Main
    CreateToggle(MainTab, "Auto Generator", "AutoGenerator", AutoGeneratorTask)
    CreateToggle(MainTab, "Auto Escape", "AutoEscape", AutoEscapeTask)
    CreateToggle(MainTab, "Auto Barricade", "AutoBarricade", AutoBarricadeTask)
    CreateButton(MainTab, "Safety Area", function()
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Part") and (v.Name:lower():find("safe") or v.Name:lower():find("spawn")) then
                    LocalPlayer.Character:MoveTo(v.Position)
                    break
                end
            end
        end)
    end)
    
    -- Visual
    CreateToggle(VisualTab, "ESP", "ESPEnabled")
    CreateToggle(VisualTab, "Survivor ESP", "SurvivorESP")
    CreateToggle(VisualTab, "Killer ESP", "KillerESP")
    CreateToggle(VisualTab, "Generator ESP", "GeneratorESP")
    CreateToggle(VisualTab, "Battery ESP", "BatteryESP")
    
    -- Teleport
    CreateButton(TeleportTab, "Safety Area", function()
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Part") and (v.Name:lower():find("safe") or v.Name:lower():find("spawn")) then
                    LocalPlayer.Character:MoveTo(v.Position)
                    break
                end
            end
        end)
    end)
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
    
    -- Others
    CreateToggle(OthersTab, "Speed 40", "SpeedEnabled", SpeedTask)
    CreateToggle(OthersTab, "Infinite Sprint", "InfiniteSprint", InfiniteSprintTask)
    CreateToggle(OthersTab, "Allow Jumping", "AllowJumping", AllowJumpingTask)
    CreateToggle(OthersTab, "Aimlock", "Aimlock", AimlockTask)
    CreateBind(OthersTab, "Aimlock Bind", "AimlockBind")
    CreateToggle(OthersTab, "Noclip", "Noclip", NoclipTask)
    
    -- Сворачивание
    local minimized = false
    local originalSize = MainFrame.Size
    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            MainFrame.Size = UDim2.new(0, 550, 0, 40)
            TabHolder.Visible = false
            Content.Visible = false
            Minimize.Text = "+"
        else
            MainFrame.Size = originalSize
            TabHolder.Visible = true
            Content.Visible = true
            Minimize.Text = "—"
        end
    end)
    
    -- Перетаскивание
    local dragging, startPos, dragStart = false
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ==================== ЗАПУСК ====================

CreateGUI()
RunService.RenderStepped:Connect(UpdateESP)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if Settings.SpeedEnabled then SpeedTask() end
    if Settings.InfiniteSprint then InfiniteSprintTask() end
    if Settings.Noclip then NoclipTask() end
end)

-- Бинды
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode[Settings.AimlockBind] then
        Settings.Aimlock = not Settings.Aimlock
        AimlockTask()
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "Celeron's GUI",
    Text = "Loaded for Bite By Night!",
    Duration = 3
})

print("Celeron's GUI for Bite By Night loaded!")
