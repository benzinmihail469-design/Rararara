--[[
    ESP + Speed 40 + Infinite Stamina + Generator ESP
    Функции из Celeron's Loader + Плавный запуск + Оптимизация
--]]

-- Загружаем функции из Celeron's Loader
local success, result = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ghostofcelleron/Celeron/refs/heads/main/Celeron's%20Loader"))()
end)

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Оптимизированные настройки
local PERF = {
    ESP_UPDATE_RATE = 0.1,
    GENERATOR_CHECK_RATE = 2,
    KILLER_CHECK_RATE = 3,
    MAX_DISTANCE = 1500
}

-- Хранилище
local ESPObjects = {}
local GeneratorESPList = {}

-- Настройки
local Settings = {
    Enabled = true,
    KillerColor = Color3.fromRGB(0, 255, 0),
    SurvivorColor = Color3.fromRGB(255, 0, 0),
    GeneratorColor = Color3.fromRGB(255, 255, 0),
    SpeedEnabled = false,
    SpeedValue = 40,
    StaminaEnabled = false,
    GeneratorESP = false,
    AutoGenerator = false,
    AutoEscape = false,
    Noclip = false,
    Aimlock = false,
    AimlockBind = "Z"
}

-- Кэш
local KillerCache = { player = nil, lastCheck = 0 }
local GeneratorCache = { list = {}, lastCheck = 0 }
local CameraPos = Vector3.new()
local LastESPUpdate = 0

-- ==================== ФУНКЦИИ ИЗ CELERON'S LOADER ====================

-- Обход античита (из Celeron's Loader)
local function setupAntiCheat()
    pcall(function()
        for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
            if v.Name:find("Anti") or v.Name:find("Cheat") or v.Name:find("Detect") then
                v:Destroy()
            end
        end
        for _, v in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if v.Name:find("Anti") or v.Name:find("Cheat") then
                v:Destroy()
            end
        end
    end)
end

-- Функции для моделей
local function GetRootPart(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
end

local function GetHumanoid(model)
    return model and model:FindFirstChildOfClass("Humanoid")
end

-- Определение убийцы
local function FindKiller()
    local now = tick()
    if now - KillerCache.lastCheck < PERF.KILLER_CHECK_RATE then
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
        end
    end
    return KillerCache.player
end

-- Поиск генераторов
local function FindGenerators()
    local now = tick()
    if now - GeneratorCache.lastCheck < PERF.GENERATOR_CHECK_RATE then
        return GeneratorCache.list
    end
    GeneratorCache.lastCheck = now
    GeneratorCache.list = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("generator") then
            table.insert(GeneratorCache.list, obj)
        elseif obj:IsA("ProximityPrompt") and obj.Parent then
            if obj.Parent.Name:lower():find("generator") then
                table.insert(GeneratorCache.list, obj.Parent)
            end
        end
    end
    return GeneratorCache.list
end

-- Drawing объекты
local function CreateDrawing(className, properties)
    local s, d = pcall(function() return Drawing.new(className) end)
    if s and d then
        for k, v in pairs(properties) do pcall(function() d[k] = v end) end
        return d
    end
    return nil
end

-- Создание ESP
local function CreatePlayerESP(player, color)
    if ESPObjects[player] then
        for _, d in pairs(ESPObjects[player]) do pcall(function() d:Remove() end) end
    end
    
    ESPObjects[player] = {
        Box = CreateDrawing("Square", {Visible = false, Color = color, Thickness = 2, Filled = false}),
        Name = CreateDrawing("Text", {Visible = false, Text = player.Name, Color = color, Size = 13, Center = true}),
        Tracer = CreateDrawing("Line", {Visible = false, Color = color, Thickness = 1})
    }
end

local function CreateGeneratorESP(gen)
    local id = gen:GetFullName()
    if GeneratorESPList[id] then return end
    
    GeneratorESPList[id] = {
        Box = CreateDrawing("Square", {Visible = false, Color = Settings.GeneratorColor, Thickness = 2, Filled = false}),
        Name = CreateDrawing("Text", {Visible = false, Text = "GENERATOR", Color = Settings.GeneratorColor, Size = 12, Center = true}),
        Gen = gen
    }
end

-- Обновление ESP
local function UpdateESP()
    local now = tick()
    if now - LastESPUpdate < PERF.ESP_UPDATE_RATE then return end
    LastESPUpdate = now
    
    CameraPos = Camera.CFrame.Position
    local killer = FindKiller()
    
    -- Игроки
    if Settings.Enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isKiller = (p == killer)
                if not ESPObjects[p] then
                    CreatePlayerESP(p, isKiller and Settings.KillerColor or Settings.SurvivorColor)
                end
            end
        end
    end
    
    for p, data in pairs(ESPObjects) do
        local player = p
        if type(p) == "string" then player = Players:FindFirstChild(p) end
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
        if dist > PERF.MAX_DISTANCE or not Settings.Enabled then
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
        
        local h = 1200 / dist
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
    
    -- Генераторы
    if Settings.GeneratorESP and Settings.Enabled then
        for _, gen in ipairs(FindGenerators()) do
            CreateGeneratorESP(gen)
        end
    end
    
    for id, data in pairs(GeneratorESPList) do
        if not Settings.GeneratorESP or not Settings.Enabled then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local gen = data.Gen
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

-- ==================== ФУНКЦИИ АВТОМАТИЗАЦИИ ====================

local AutoTasks = {}

local function AutoGeneratorTask()
    if AutoTasks.Generator then AutoTasks.Generator:Disconnect() end
    if not Settings.AutoGenerator then return end
    
    AutoTasks.Generator = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not LocalPlayer.Character then return end
            for _, gen in ipairs(FindGenerators()) do
                local prompt = gen:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    local pos = gen.PrimaryPart and gen.PrimaryPart.Position
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

local function NoclipTask()
    if AutoTasks.Noclip then AutoTasks.Noclip:Disconnect() end
    if not Settings.Noclip then return end
    
    AutoTasks.Noclip = RunService.Heartbeat:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end)
end

local function AimlockTask()
    if AutoTasks.Aimlock then AutoTasks.Aimlock:Disconnect() end
    if not Settings.Aimlock then return end
    
    AutoTasks.Aimlock = RunService.RenderStepped:Connect(function()
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

-- ==================== СКОРОСТЬ И СТАМИНА ====================

local function UpdateSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local h = GetHumanoid(char)
    if h then
        h.WalkSpeed = Settings.SpeedEnabled and Settings.SpeedValue or 16
    end
end

local StaminaLoop = nil
local function UpdateStamina()
    if StaminaLoop then StaminaLoop:Disconnect() end
    if Settings.StaminaEnabled then
        StaminaLoop = RunService.Heartbeat:Connect(function()
            pcall(function()
                LocalPlayer:SetAttribute("Stamina", 100)
                LocalPlayer:SetAttribute("Energy", 100)
            end)
        end)
    end
end

-- ==================== ПЛАВНЫЙ GUI ====================

local function CreateGUI()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "Celeron_Style_GUI"
    
    -- Главное окно
    local Main = Instance.new("Frame", gui)
    Main.Size = UDim2.new(0, 550, 0, 350)
    Main.Position = UDim2.new(0.5, -275, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BackgroundTransparency = 1
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    -- Плавное появление
    TweenService:Create(Main, TweenInfo.new(0.3), {BackgroundTransparency = 0.05}):Play()
    
    -- Заголовок
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.BorderSizePixel = 0
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
    
    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Celeron's GUI (Bite By Night)"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Кнопка сворачивания
    local Minimize = Instance.new("TextButton", TitleBar)
    Minimize.Size = UDim2.new(0, 28, 0, 28)
    Minimize.Position = UDim2.new(1, -65, 0, 4)
    Minimize.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    Minimize.Text = "—"
    Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 16
    Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 5)
    
    -- Кнопка закрытия
    local Close = Instance.new("TextButton", TitleBar)
    Close.Size = UDim2.new(0, 28, 0, 28)
    Close.Position = UDim2.new(1, -32, 0, 4)
    Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 5)
    
    Close.MouseButton1Click:Connect(function()
        for _, t in pairs(AutoTasks) do if t then t:Disconnect() end end
        if StaminaLoop then StaminaLoop:Disconnect() end
        for _, d in pairs(ESPObjects) do for _, v in pairs(d) do pcall(function() v:Remove() end) end end
        gui:Destroy()
    end)
    
    -- Вкладки
    local TabHolder = Instance.new("Frame", Main)
    TabHolder.Size = UDim2.new(0, 110, 1, -35)
    TabHolder.Position = UDim2.new(0, 0, 0, 35)
    TabHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabHolder.BorderSizePixel = 0
    
    local TabList = Instance.new("UIListLayout", TabHolder)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 2)
    
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -110, 1, -35)
    Content.Position = UDim2.new(0, 110, 0, 35)
    Content.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Content.BorderSizePixel = 0
    
    local Tabs = {}
    local function CreateTab(name)
        local btn = Instance.new("TextButton", TabHolder)
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        
        local page = Instance.new("ScrollingFrame", Content)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 5
        page.Visible = false
        
        local list = Instance.new("UIListLayout", page)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 8)
        Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 8)
        
        btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(Tabs) do
                t.Page.Visible = false
                t.Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
        
        table.insert(Tabs, {Btn = btn, Page = page})
        return page
    end
    
    -- Функция создания кнопки
    local function CreateToggle(parent, text, setting, callback)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, -16, 0, 36)
        f.Position = UDim2.new(0, 8, 0, 0)
        f.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        f.BorderSizePixel = 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(0.6, 0, 1, 0)
        l.Position = UDim2.new(0, 12, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(255, 255, 255)
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        
        local t = Instance.new("TextButton", f)
        t.Size = UDim2.new(0, 55, 0, 22)
        t.Position = UDim2.new(1, -65, 0.5, -11)
        t.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        t.Text = Settings[setting] and "ON" or "OFF"
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 11
        t.AutoButtonColor = false
        Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
        
        t.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            t.Text = Settings[setting] and "ON" or "OFF"
            t.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            if callback then callback(Settings[setting]) end
        end)
        
        return f, t
    end
    
    -- Создание вкладок
    local Visual = CreateTab("Visual")
    local Main = CreateTab("Main")
    local Others = CreateTab("Others")
    
    Tabs[1].Page.Visible = true
    Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    -- Visual
    CreateToggle(Visual, "ESP", "Enabled")
    CreateToggle(Visual, "Generator ESP", "GeneratorESP")
    
    -- Main
    CreateToggle(Main, "Auto Generator", "AutoGenerator", AutoGeneratorTask)
    CreateToggle(Main, "Auto Escape", "AutoEscape", AutoEscapeTask)
    
    -- Others
    CreateToggle(Others, "Speed 40", "SpeedEnabled", function(e) UpdateSpeed() end)
    CreateToggle(Others, "Infinite Stamina", "StaminaEnabled", function(e) UpdateStamina() end)
    CreateToggle(Others, "Noclip", "Noclip", NoclipTask)
    CreateToggle(Others, "Aimlock", "Aimlock", AimlockTask)
    
    -- Перетаскивание
    local dragging, startPos, dragStart = false
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = Main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    -- Сворачивание
    local minimized = false
    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Main.Size = UDim2.new(0, 550, 0, 35)
            TabHolder.Visible = false
            Content.Visible = false
            Minimize.Text = "+"
        else
            Main.Size = UDim2.new(0, 550, 0, 350)
            TabHolder.Visible = true
            Content.Visible = true
            Minimize.Text = "—"
        end
    end)
end

-- ==================== ЗАПУСК ====================

setupAntiCheat()
CreateGUI()

RunService.RenderStepped:Connect(UpdateESP)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    UpdateSpeed()
    UpdateStamina()
end)

-- Бинд для Aimlock
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode[Settings.AimlockBind] then
        Settings.Aimlock = not Settings.Aimlock
        AimlockTask()
    end
end)

print("Celeron's Style GUI loaded! Optimized + Smooth!")
