--[[
    Celeron's GUI для Bite By Night
    ПОЛНЫЙ ФУНКЦИОНАЛ + ПЛАВНЫЙ ЗАПУСК
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Настройки
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

local ESPObjects = {}
local ObjectESPList = {}
local Tasks = {}
local Cache = {
    Killer = { player = nil, time = 0 },
    Generators = { list = {}, time = 0 },
    CameraPos = Vector3.new(),
    ESPUpdate = 0
}

-- Обход античита
pcall(function()
    for _, v in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
        if v.Name:find("Anti") or v.Name:find("Cheat") then v:Destroy() end
    end
    local oldIndex = hookmetamethod(game, "__index", function(self, k)
        if self == LocalPlayer then
            if k == "Stamina" or k == "Energy" then return 100 end
            if k == "WalkSpeed" then return 16 end
        end
        return oldIndex(self, k)
    end)
end)

-- Функции моделей
local function GetRootPart(m)
    if not m then return nil end
    return m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart or m:FindFirstChildOfClass("BasePart")
end
local function GetHumanoid(m)
    return m and m:FindFirstChildOfClass("Humanoid")
end

-- Поиск убийцы
local function FindKiller()
    local now = tick()
    if now - Cache.Killer.time < 2 then return Cache.Killer.player end
    Cache.Killer.time = now
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = GetHumanoid(p.Character)
            if h and h.MaxHealth > 500 then Cache.Killer.player = p; return p end
        end
    end
    return Cache.Killer.player
end

-- Поиск генераторов
local function FindGenerators()
    local now = tick()
    if now - Cache.Generators.time < 2 then return Cache.Generators.list end
    Cache.Generators.time = now
    Cache.Generators.list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("generator") then
            table.insert(Cache.Generators.list, obj)
        elseif obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent.Name:lower():find("generator") then
            local found = false
            for _, g in ipairs(Cache.Generators.list) do
                if g == obj.Parent then found = true; break end
            end
            if not found then table.insert(Cache.Generators.list, obj.Parent) end
        end
    end
    return Cache.Generators.list
end

-- Drawing
local function CreateDrawing(class, props)
    local s, d = pcall(function() return Drawing.new(class) end)
    if s and d then for k, v in pairs(props) do pcall(function() d[k] = v end) end return d end
end

-- ESP
local function UpdateESP()
    local now = tick()
    if now - Cache.ESPUpdate < 0.15 then return end
    Cache.ESPUpdate = now
    Cache.CameraPos = Camera.CFrame.Position
    local killer = FindKiller()
    
    if Settings.ESPEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isKiller = (p == killer)
                if (Settings.SurvivorESP and not isKiller) or (Settings.KillerESP and isKiller) then
                    if not ESPObjects[p] then
                        if ESPObjects[p] then for _, d in pairs(ESPObjects[p]) do d:Remove() end end
                        local c = isKiller and Settings.KillerColor or Settings.SurvivorColor
                        ESPObjects[p] = {
                            Box = CreateDrawing("Square", {Visible = false, Color = c, Thickness = 2, Filled = false}),
                            Name = CreateDrawing("Text", {Visible = false, Text = p.Name, Color = c, Size = 13, Center = true})
                        }
                    end
                end
            end
        end
        
        if Settings.GeneratorESP then
            for _, gen in ipairs(FindGenerators()) do
                local id = gen:GetFullName()
                if not ObjectESPList[id] then
                    ObjectESPList[id] = {
                        Box = CreateDrawing("Square", {Visible = false, Color = Settings.GeneratorColor, Thickness = 2, Filled = false}),
                        Name = CreateDrawing("Text", {Visible = false, Text = "GEN", Color = Settings.GeneratorColor, Size = 12, Center = true}),
                        Obj = gen
                    }
                end
            end
        end
    end
    
    for p, data in pairs(ESPObjects) do
        local player = type(p) == "string" and Players:FindFirstChild(p) or p
        if not player or not player.Character then data.Box.Visible = false; data.Name.Visible = false; continue end
        local root = GetRootPart(player.Character)
        if not root then data.Box.Visible = false; data.Name.Visible = false; continue end
        local dist = (Cache.CameraPos - root.Position).Magnitude
        if dist > 1500 or not Settings.ESPEnabled then data.Box.Visible = false; data.Name.Visible = false; continue end
        local pos, on = Camera:WorldToViewportPoint(root.Position)
        if not on then data.Box.Visible = false; data.Name.Visible = false; continue end
        local h = 1200 / dist
        local w = h * 0.45
        data.Box.Visible = true
        data.Box.Size = Vector2.new(w, h)
        data.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
        data.Name.Visible = true
        data.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 15)
    end
    
    for _, data in pairs(ObjectESPList) do
        if not Settings.ESPEnabled or not Settings.GeneratorESP then data.Box.Visible = false; data.Name.Visible = false; continue end
        local obj = data.Obj
        if not obj or not obj.Parent then data.Box.Visible = false; data.Name.Visible = false; continue end
        local root = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        if not root then data.Box.Visible = false; data.Name.Visible = false; continue end
        local dist = (Cache.CameraPos - root.Position).Magnitude
        if dist > 1500 then data.Box.Visible = false; data.Name.Visible = false; continue end
        local pos, on = Camera:WorldToViewportPoint(root.Position)
        if not on then data.Box.Visible = false; data.Name.Visible = false; continue end
        local h = 1000 / dist
        local w = h * 0.8
        data.Box.Visible = true
        data.Box.Size = Vector2.new(w, h)
        data.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
        data.Name.Visible = true
        data.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 15)
    end
end

-- Задачи
local function SpeedTask()
    if Tasks.Speed then Tasks.Speed:Disconnect() end
    if not Settings.SpeedEnabled then return end
    Tasks.Speed = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character then
            local h = GetHumanoid(LocalPlayer.Character)
            if h then h.WalkSpeed = Settings.SpeedValue end
        end
    end)
end

local function SprintTask()
    if Tasks.Sprint then Tasks.Sprint:Disconnect() end
    if not Settings.InfiniteSprint then return end
    Tasks.Sprint = RunService.Heartbeat:Connect(function()
        LocalPlayer:SetAttribute("Stamina", 100)
        LocalPlayer:SetAttribute("Energy", 100)
    end)
end

local function NoclipTask()
    if Tasks.Noclip then Tasks.Noclip:Disconnect() end
    if not Settings.Noclip then return end
    Tasks.Noclip = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character then
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end

local function AimlockTask()
    if Tasks.Aimlock then Tasks.Aimlock:Disconnect() end
    if not Settings.Aimlock then return end
    Tasks.Aimlock = RunService.RenderStepped:Connect(function()
        local closest, minDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local root = GetRootPart(p.Character)
                if root then
                    local dist = (Cache.CameraPos - root.Position).Magnitude
                    if dist < minDist then minDist = dist; closest = p end
                end
            end
        end
        if closest and closest.Character then
            local root = GetRootPart(closest.Character)
            if root then Camera.CFrame = CFrame.new(Cache.CameraPos, root.Position) end
        end
    end)
end

local function AutoGeneratorTask()
    if Tasks.Generator then Tasks.Generator:Disconnect() end
    if not Settings.AutoGenerator then return end
    Tasks.Generator = RunService.Heartbeat:Connect(function()
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
end

local function AutoEscapeTask()
    if Tasks.Escape then Tasks.Escape:Disconnect() end
    if not Settings.AutoEscape then return end
    Tasks.Escape = RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character then return end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Part") and (v.Name:lower():find("exit") or v.Name:lower():find("escape")) then
                LocalPlayer.Character:MoveTo(v.Position)
                break
            end
        end
    end)
end

-- GUI
local function CreateGUI()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "CeleronGUI"
    
    local Main = Instance.new("Frame", gui)
    Main.Size = UDim2.new(0, 500, 0, 350)
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BackgroundTransparency = 0.05
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    -- Заголовок
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.BorderSizePixel = 0
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
    
    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Celeron's GUI (Bite By Night)"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local Minimize = Instance.new("TextButton", TitleBar)
    Minimize.Size = UDim2.new(0, 28, 0, 28)
    Minimize.Position = UDim2.new(1, -65, 0, 4)
    Minimize.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    Minimize.Text = "—"
    Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
    Minimize.Font = Enum.Font.GothamBold
    Minimize.TextSize = 16
    Minimize.AutoButtonColor = false
    Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 5)
    
    local Close = Instance.new("TextButton", TitleBar)
    Close.Size = UDim2.new(0, 28, 0, 28)
    Close.Position = UDim2.new(1, -32, 0, 4)
    Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Close.Text = "X"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.AutoButtonColor = false
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 5)
    Close.MouseButton1Click:Connect(function()
        for _, t in pairs(Tasks) do if t then t:Disconnect() end end
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
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, -20, 0, 36)
        f.Position = UDim2.new(0, 10, 0, 0)
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
            if callback then callback() end
        end)
    end
    
    local function CreateButton(parent, text, callback)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, -20, 0, 32)
        b.Position = UDim2.new(0, 10, 0, 0)
        b.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.Gotham
        b.TextSize = 13
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(callback)
    end
    
    local MainTab = CreateTab("Main")
    local VisualTab = CreateTab("Visual")
    local TeleportTab = CreateTab("Teleport")
    local OthersTab = CreateTab("Others")
    
    Tabs[1].Page.Visible = true
    Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    CreateToggle(MainTab, "Auto Generator", "AutoGenerator", AutoGeneratorTask)
    CreateToggle(MainTab, "Auto Escape", "AutoEscape", AutoEscapeTask)
    CreateButton(MainTab, "Safety Area", function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Part") and (v.Name:lower():find("safe") or v.Name:lower():find("spawn")) then
                LocalPlayer.Character:MoveTo(v.Position)
                break
            end
        end
    end)
    CreateButton(MainTab, "View Killer", function()
        local k = FindKiller()
        if k and k.Character then Camera.CameraSubject = k.Character; task.wait(3); Camera.CameraSubject = LocalPlayer.Character end
    end)
    
    CreateToggle(VisualTab, "ESP", "ESPEnabled")
    CreateToggle(VisualTab, "Survivor ESP", "SurvivorESP")
    CreateToggle(VisualTab, "Killer ESP", "KillerESP")
    CreateToggle(VisualTab, "Generator ESP", "GeneratorESP")
    
    CreateButton(TeleportTab, "Safety Area", function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Part") and (v.Name:lower():find("safe") or v.Name:lower():find("spawn")) then
                LocalPlayer.Character:MoveTo(v.Position)
                break
            end
        end
    end)
    CreateButton(TeleportTab, "Escape Area", function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Part") and (v.Name:lower():find("exit") or v.Name:lower():find("escape")) then
                LocalPlayer.Character:MoveTo(v.Position)
                break
            end
        end
    end)
    
    CreateToggle(OthersTab, "Speed 40", "SpeedEnabled", SpeedTask)
    CreateToggle(OthersTab, "Infinite Sprint", "InfiniteSprint", SprintTask)
    CreateToggle(OthersTab, "Noclip", "Noclip", NoclipTask)
    CreateToggle(OthersTab, "Aimlock", "Aimlock", AimlockTask)
    
    -- Сворачивание
    local minimized = false
    local originalSize = Main.Size
    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Main.Size = UDim2.new(0, 500, 0, 35)
            TabHolder.Visible = false
            Content.Visible = false
            Minimize.Text = "+"
        else
            Main.Size = originalSize
            TabHolder.Visible = true
            Content.Visible = true
            Minimize.Text = "—"
        end
    end)
    
    -- Перетаскивание
    local dragging, dragStart, startPos = false
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end

-- Запуск
task.wait(0.5) -- Даём игре загрузиться
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
