--[[
    Celeron's GUI для Bite By Night
    ИСПРАВЛЕНО: Все генераторы + Speed + Infinite Sprint + Обход античита
--]]

-- Сервисы
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- ==================== МГНОВЕННЫЙ ЗАГРУЗЧИК ====================
local function QuickLoader()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "Loader"
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 260, 0, 50)
    frame.Position = UDim2.new(0.5, -130, 0.5, -25)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Celeron's GUI - Loading..."
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    
    task.wait(0.3)
    gui:Destroy()
end

QuickLoader()

-- ==================== НАСТРОЙКИ ====================
local Settings = {
    ESPEnabled = true,
    SurvivorESP = true,
    KillerESP = true,
    GeneratorESP = true,
    
    KillerColor = Color3.fromRGB(0, 255, 0),
    SurvivorColor = Color3.fromRGB(255, 0, 0),
    GeneratorColor = Color3.fromRGB(255, 255, 0),
    
    AutoGenerator = false,
    AutoEscape = false,
    
    SpeedEnabled = false,
    SpeedValue = 40,
    InfiniteSprint = false,
    Noclip = false,
    Aimlock = false,
    AimlockBind = "Z"
}

-- ==================== ХРАНИЛИЩЕ ====================
local ESPObjects = {}
local ObjectESPList = {}
local Tasks = {}
local Cache = {
    Killer = { player = nil, time = 0 },
    Generators = { list = {}, time = 0 },
    CameraPos = Vector3.new(),
    ESPUpdate = 0
}

-- ==================== УСИЛЕННЫЙ ОБХОД АНТИЧИТА ====================
local function setupAntiCheat()
    pcall(function()
        -- Удаляем все античит-скрипты
        for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
            if v.Name:find("Anti") or v.Name:find("Cheat") or v.Name:find("Detect") or v.Name:find("Ban") then
                v:Destroy()
            end
        end
        
        for _, v in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            local n = v.Name:lower()
            if n:find("anti") or n:find("cheat") or n:find("detect") then
                v:Destroy()
            end
        end
        
        -- Перехват RemoteEvent (блокировка kick/ban)
        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" then
                local name = self.Name:lower()
                if name:find("kick") or name:find("ban") or name:find("detect") or name:find("report") then
                    return nil
                end
                if name:find("stamina") or name:find("energy") or name:find("sprint") then
                    return nil
                end
            end
            return oldNamecall(self, ...)
        end)
        
        -- Подмена проверяемых значений
        local oldIndex = hookmetamethod(game, "__index", function(self, key)
            if self == LocalPlayer then
                if key == "Stamina" or key == "stamina" or key == "Energy" or key == "energy" then
                    return 100
                end
                if key == "WalkSpeed" then
                    return 16
                end
            end
            return oldIndex(self, key)
        end)
        
        -- Постоянное восстановление стамины
        RunService.Heartbeat:Connect(function()
            pcall(function()
                LocalPlayer:SetAttribute("Stamina", 100)
                LocalPlayer:SetAttribute("stamina", 100)
                LocalPlayer:SetAttribute("Energy", 100)
                LocalPlayer:SetAttribute("energy", 100)
                LocalPlayer:SetAttribute("Endurance", 100)
            end)
        end)
    end)
end

setupAntiCheat()

-- ==================== ФУНКЦИИ ДЛЯ МОДЕЛЕЙ ====================
local function GetRootPart(m)
    if not m then return nil end
    return m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart or m:FindFirstChildOfClass("BasePart")
end

local function GetHumanoid(m)
    return m and m:FindFirstChildOfClass("Humanoid")
end

-- ==================== ОПРЕДЕЛЕНИЕ УБИЙЦЫ ====================
local function FindKiller()
    local now = tick()
    if now - Cache.Killer.time < 2 then
        return Cache.Killer.player
    end
    Cache.Killer.time = now
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = GetHumanoid(p.Character)
            if h and h.MaxHealth > 500 then
                Cache.Killer.player = p
                return p
            end
        end
    end
    return Cache.Killer.player
end

-- ==================== ПОИСК ВСЕХ ГЕНЕРАТОРОВ (ИСПРАВЛЕНО) ====================
local function FindGenerators()
    local now = tick()
    if now - Cache.Generators.time < 2 then
        return Cache.Generators.list
    end
    Cache.Generators.time = now
    Cache.Generators.list = {}
    
    -- Ищем ВСЕ генераторы
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("generator") then
            table.insert(Cache.Generators.list, obj)
        elseif obj:IsA("ProximityPrompt") and obj.Parent then
            if obj.Parent.Name:lower():find("generator") then
                local found = false
                for _, g in ipairs(Cache.Generators.list) do
                    if g == obj.Parent then found = true; break end
                end
                if not found then
                    table.insert(Cache.Generators.list, obj.Parent)
                end
            end
        end
    end
    return Cache.Generators.list
end

-- ==================== DRAWING ====================
local function CreateDrawing(class, props)
    local s, d = pcall(function() return Drawing.new(class) end)
    if s and d then
        for k, v in pairs(props) do pcall(function() d[k] = v end) end
        return d
    end
end

-- ==================== ESP ====================
local function CreatePlayerESP(p, color)
    if ESPObjects[p] then
        for _, d in pairs(ESPObjects[p]) do pcall(function() d:Remove() end) end
    end
    ESPObjects[p] = {
        Box = CreateDrawing("Square", {Visible = false, Color = color, Thickness = 2, Filled = false}),
        Name = CreateDrawing("Text", {Visible = false, Text = p.Name, Color = color, Size = 13, Center = true, Outline = true})
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

local function UpdateESP()
    local now = tick()
    if now - Cache.ESPUpdate < 0.1 then return end
    Cache.ESPUpdate = now
    
    Cache.CameraPos = Camera.CFrame.Position
    local killer = FindKiller()
    
    -- Создание ESP для игроков
    if Settings.ESPEnabled then
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
        
        -- Создание ESP для ВСЕХ генераторов
        if Settings.GeneratorESP then
            for _, gen in ipairs(FindGenerators()) do
                CreateObjectESP(gen, Settings.GeneratorColor, "GENERATOR")
            end
        end
    end
    
    -- Обновление игроков
    for p, data in pairs(ESPObjects) do
        local player = type(p) == "string" and Players:FindFirstChild(p) or p
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
        
        local dist = (Cache.CameraPos - root.Position).Magnitude
        if dist > 1500 or not Settings.ESPEnabled then
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
    
    -- Обновление объектов
    for id, data in pairs(ObjectESPList) do
        if not Settings.ESPEnabled or not Settings.GeneratorESP then
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
        
        local dist = (Cache.CameraPos - root.Position).Magnitude
        if dist > 1500 then
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

-- ==================== ЗАДАЧИ (ИСПРАВЛЕНО) ====================
local function AutoGeneratorTask()
    if Tasks.Generator then Tasks.Generator:Disconnect() end
    if not Settings.AutoGenerator then return end
    
    Tasks.Generator = RunService.Heartbeat:Connect(function()
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
    if Tasks.Escape then Tasks.Escape:Disconnect() end
    if not Settings.AutoEscape then return end
    
    Tasks.Escape = RunService.Heartbeat:Connect(function()
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

local function SpeedTask()
    if Tasks.Speed then Tasks.Speed:Disconnect() end
    if not Settings.SpeedEnabled then return end
    
    Tasks.Speed = RunService.Heartbeat:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                local h = GetHumanoid(LocalPlayer.Character)
                if h then 
                    h.WalkSpeed = Settings.SpeedValue
                end
            end
        end)
    end)
end

local function SprintTask()
    if Tasks.Sprint then Tasks.Sprint:Disconnect() end
    if not Settings.InfiniteSprint then return end
    
    Tasks.Sprint = RunService.Heartbeat:Connect(function()
        pcall(function()
            LocalPlayer:SetAttribute("Stamina", 100)
            LocalPlayer:SetAttribute("stamina", 100)
            LocalPlayer:SetAttribute("Energy", 100)
            LocalPlayer:SetAttribute("energy", 100)
            LocalPlayer:SetAttribute("Endurance", 100)
        end)
    end)
end

local function NoclipTask()
    if Tasks.Noclip then Tasks.Noclip:Disconnect() end
    if not Settings.Noclip then return end
    
    Tasks.Noclip = RunService.Heartbeat:Connect(function()
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
    if Tasks.Aimlock then Tasks.Aimlock:Disconnect() end
    if not Settings.Aimlock then return end
    
    Tasks.Aimlock = RunService.RenderStepped:Connect(function()
        pcall(function()
            local closest, minDist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local root = GetRootPart(p.Character)
                    if root then
                        local dist = (Cache.CameraPos - root.Position).Magnitude
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
                    Camera.CFrame = CFrame.new(Cache.CameraPos, root.Position)
                end
            end
        end)
    end)
end

-- ==================== GUI ====================
local function CreateGUI()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "CeleronGUI"
    
    local Main = Instance.new("Frame", gui)
    Main.Size = UDim2.new(0, 200, 0, 230)
    Main.Position = UDim2.new(0, 10, 0, 10)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BackgroundTransparency = 0.15
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    
    -- Заголовок
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TitleBar.BorderSizePixel = 0
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Celeron's GUI"
    Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Кнопка сворачивания
    local Minimize = Instance.new("TextButton", TitleBar)
    Minimize.Size = UDim2.new(0, 24, 0, 24)
    Minimize.Position = UDim2.new(1, -54, 0, 3)
    Minimize.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Minimize.Text = "—"
    Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 14
    Minimize.AutoButtonColor = false
    Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 4)
    
    -- Кнопка закрытия
    local Close = Instance.new("TextButton", TitleBar)
    Close.Size = UDim2.new(0, 24, 0, 24)
    Close.Position = UDim2.new(1, -28, 0, 3)
    Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 12
    Close.AutoButtonColor = false
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 4)
    
    Close.MouseButton1Click:Connect(function()
        for _, t in pairs(Tasks) do if t then t:Disconnect() end end
        gui:Destroy()
    end)
    
    -- Контент
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, 0, 1, -30)
    Content.Position = UDim2.new(0, 0, 0, 30)
    Content.BackgroundTransparency = 1
    
    local contentElements = {Content}
    
    -- Функция создания кнопки
    local yPos = 5
    local function CreateButton(text, setting, callback)
        local btn = Instance.new("TextButton", Content)
        btn.Size = UDim2.new(0.85, 0, 0, 28)
        btn.Position = UDim2.new(0.075, 0, 0, yPos)
        btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        btn.Font = Enum.Font.Gotham
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        table.insert(contentElements, btn)
        
        btn.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            btn.Text = Settings[setting] and text:gsub("OFF", "ON") or text:gsub("ON", "OFF")
            btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            if callback then callback() end
        end)
        
        yPos = yPos + 32
        return btn
    end
    
    CreateButton("ESP: ON", "ESPEnabled")
    CreateButton("Generator: ON", "GeneratorESP")
    CreateButton("Speed 40: OFF", "SpeedEnabled", SpeedTask)
    CreateButton("Inf Sprint: OFF", "InfiniteSprint", SprintTask)
    CreateButton("Auto Gen: OFF", "AutoGenerator", AutoGeneratorTask)
    CreateButton("Noclip: OFF", "Noclip", NoclipTask)
    CreateButton("Aimlock: OFF", "Aimlock", AimlockTask)
    
    -- Сворачивание
    local minimized = false
    local originalSize = Main.Size
    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Main.Size = UDim2.new(0, 200, 0, 30)
            for _, el in pairs(contentElements) do
                el.Visible = false
            end
            Minimize.Text = "+"
        else
            Main.Size = originalSize
            for _, el in pairs(contentElements) do
                el.Visible = true
            end
            Minimize.Text = "—"
        end
    end)
    
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
    
    UserInputService.InputEnded:Connect(function()
        dragging = false
    end)
end

-- ==================== ЗАПУСК ====================
CreateGUI()
RunService.RenderStepped:Connect(UpdateESP)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if Settings.SpeedEnabled then SpeedTask() end
    if Settings.InfiniteSprint then SprintTask() end
    if Settings.Noclip then NoclipTask() end
end)

UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode[Settings.AimlockBind] then
        Settings.Aimlock = not Settings.Aimlock
        AimlockTask()
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "Celeron's GUI",
    Text = "Loaded! All functions fixed!",
    Duration = 3
})

print("Celeron's GUI loaded! All generators + Speed + Sprint fixed!")
