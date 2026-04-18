--[[
    ESP + Speed 40 + Infinite Stamina + Generator ESP
    ПЛАВНЫЙ ЗАПУСК + ОПТИМИЗАЦИЯ (БЕЗ ЛАГОВ)
--]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Настройки производительности
local PERF = {
    ESP_UPDATE_RATE = 0.1,      -- 10 FPS (очень плавно)
    GENERATOR_CHECK_RATE = 2,    -- Раз в 2 секунды
    KILLER_CHECK_RATE = 3,       -- Раз в 3 секунды
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
    Thickness = 2,
    CornerSize = 10,
    MaxDistance = 1500,
    SpeedEnabled = false,
    SpeedValue = 40,
    StaminaEnabled = false,
    GeneratorESP = false
}

-- Кэш
local KillerCache = { player = nil, lastCheck = 0 }
local GeneratorCache = { list = {}, lastCheck = 0 }
local CameraPos = Vector3.new()
local LastESPUpdate = 0

-- ==================== ОБХОД АНТИЧИТА ====================
pcall(function()
    for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
        if v.Name:find("Anti") or v.Name:find("Cheat") then v:Destroy() end
    end
    for _, v in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
        if v.Name:find("Anti") or v.Name:find("Cheat") then v:Destroy() end
    end
end)

-- ==================== ФУНКЦИИ ДЛЯ МОДЕЛЕЙ ====================
local function GetRootPart(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
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
            local h = GetHumanoid(p.Character)
            if h and h.MaxHealth > 500 then
                KillerCache.player = p
                return p
            end
        end
    end
    return KillerCache.player
end

-- ==================== ПОИСК ГЕНЕРАТОРОВ ====================
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
        Name = CreateDrawing("Text", {Visible = false, Text = player.Name, Color = color, Size = 13, Center = true})
    }
end

local function CreateGeneratorESP(gen)
    local id = gen:GetFullName()
    if GeneratorESPList[id] then return end
    
    GeneratorESPList[id] = {
        Box = CreateDrawing("Square", {Visible = false, Color = Settings.GeneratorColor, Thickness = 2, Filled = false}),
        Name = CreateDrawing("Text", {Visible = false, Text = "GEN", Color = Settings.GeneratorColor, Size = 13, Center = true}),
        Gen = gen
    }
end

-- ==================== ОБНОВЛЕНИЕ ESP ====================
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
            continue
        end
        
        local root = GetRootPart(player.Character)
        if not root then
            data.Box.Visible = false
            data.Name.Visible = false
            continue
        end
        
        local dist = (CameraPos - root.Position).Magnitude
        if dist > PERF.MAX_DISTANCE or not Settings.Enabled then
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
        
        local h = 1200 / dist
        local w = h * 0.45
        
        data.Box.Visible = true
        data.Box.Size = Vector2.new(w, h)
        data.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
        data.Name.Visible = true
        data.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 15)
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

-- ==================== СКОРОСТЬ И СТАМИНА ====================
local function UpdateSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local h = GetHumanoid(char)
    if h then
        h.WalkSpeed = Settings.SpeedEnabled and Settings.SpeedValue or 16
    end
end

local staminaLoop = nil
local function UpdateStamina()
    if staminaLoop then staminaLoop:Disconnect() end
    if Settings.StaminaEnabled then
        staminaLoop = RunService.Heartbeat:Connect(function()
            pcall(function()
                LocalPlayer:SetAttribute("Stamina", 100)
                LocalPlayer:SetAttribute("Energy", 100)
            end)
        end)
    end
end

-- ==================== GUI ====================
local function CreateGUI()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "ESP_GUI"
    
    local f = Instance.new("Frame", gui)
    f.Size = UDim2.new(0, 180, 0, 190)
    f.Position = UDim2.new(0, 10, 0, 10)
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, 0, 0, 25)
    t.BackgroundTransparency = 1
    t.Text = "ESP + Speed + Stamina"
    t.TextColor3 = Color3.fromRGB(0, 255, 0)
    t.TextSize = 12
    t.Font = Enum.Font.GothamBold
    
    local status = Instance.new("TextLabel", f)
    status.Size = UDim2.new(1, 0, 0, 18)
    status.Position = UDim2.new(0, 0, 0, 28)
    status.BackgroundTransparency = 1
    status.Text = "Killer: ..."
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.TextSize = 10
    status.Font = Enum.Font.Gotham
    
    local function makeBtn(y, text, callback)
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(0.85, 0, 0, 26)
        b.Position = UDim2.new(0.075, 0, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextSize = 11
        b.Font = Enum.Font.Gotham
        b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        b.MouseButton1Click:Connect(callback)
        return b
    end
    
    local espBtn = makeBtn(50, "ESP: ON", function()
        Settings.Enabled = not Settings.Enabled
        espBtn.Text = Settings.Enabled and "ESP: ON" or "ESP: OFF"
        espBtn.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    end)
    espBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    
    local genBtn = makeBtn(80, "Generator: OFF", function()
        Settings.GeneratorESP = not Settings.GeneratorESP
        genBtn.Text = Settings.GeneratorESP and "Generator: ON" or "Generator: OFF"
        genBtn.BackgroundColor3 = Settings.GeneratorESP and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    end)
    
    local spdBtn = makeBtn(110, "Speed: OFF", function()
        Settings.SpeedEnabled = not Settings.SpeedEnabled
        spdBtn.Text = Settings.SpeedEnabled and "Speed: 40" or "Speed: OFF"
        spdBtn.BackgroundColor3 = Settings.SpeedEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        UpdateSpeed()
    end)
    
    local stmBtn = makeBtn(140, "Stamina: OFF", function()
        Settings.StaminaEnabled = not Settings.StaminaEnabled
        stmBtn.Text = Settings.StaminaEnabled and "Stamina: ON" or "Stamina: OFF"
        stmBtn.BackgroundColor3 = Settings.StaminaEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        UpdateStamina()
    end)
    
    local info = Instance.new("TextLabel", f)
    info.Size = UDim2.new(1, 0, 0, 15)
    info.Position = UDim2.new(0, 0, 0, 172)
    info.BackgroundTransparency = 1
    info.Text = "🟢Killer 🔴Surv 💛Gen"
    info.TextColor3 = Color3.fromRGB(200, 200, 200)
    info.TextSize = 9
    info.Font = Enum.Font.Gotham
    
    local close = Instance.new("TextButton", f)
    close.Size = UDim2.new(0, 18, 0, 18)
    close.Position = UDim2.new(1, -22, 0, 4)
    close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.TextSize = 12
    close.Font = Enum.Font.GothamBold
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 4)
    close.MouseButton1Click:Connect(function()
        if staminaLoop then staminaLoop:Disconnect() end
        gui:Destroy()
    end)
    
    task.spawn(function()
        while gui and gui.Parent do
            local k = FindKiller()
            status.Text = k and ("Killer: " .. k.Name) or "Killer: Searching..."
            status.TextColor3 = k and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
            task.wait(1)
        end
    end)
end

-- ==================== ЗАПУСК ====================
CreateGUI()
RunService.RenderStepped:Connect(UpdateESP)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    UpdateSpeed()
    UpdateStamina()
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.3) end)
end)

print("ESP loaded! Optimized - no lags!")
