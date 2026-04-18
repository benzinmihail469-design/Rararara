--[[
    Celeron's GUI для Bite By Night
    Полноценный хаб с ESP, телепортами, автовыполнением и визуалом
]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Переменные
local ESPObjects = {}
local Settings = {
    -- Main
    AutoGenerator = false,
    AutoEscape = false,
    AutoBarricade = false,
    ViewKiller = false,
    
    -- Visual
    SurvivorESP = false,
    KillerESP = false,
    GeneratorESP = false,
    BatteryESP = false,
    FuseBoxESP = false,
    
    -- Others
    InfiniteSprint = false,
    AllowJumping = false,
    Aimlock = false,
    AimlockBind = "Z",
    Noclip = false,
    
    -- ESP Colors
    KillerColor = Color3.fromRGB(0, 255, 0),
    SurvivorColor = Color3.fromRGB(255, 0, 0),
    GeneratorColor = Color3.fromRGB(255, 255, 0),
    BatteryColor = Color3.fromRGB(0, 255, 255),
    FuseBoxColor = Color3.fromRGB(255, 0, 255)
}

-- Хранилище для GUI
local Tabs = {}
local Window

-- ==================== ФУНКЦИИ ДЛЯ РАБОТЫ С МОДЕЛЯМИ ====================

local function GetRootPart(model)
    if not model then return nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("torso") then
            return part
        end
    end
    return model.PrimaryPart
end

local function GetHead(model)
    if not model then return nil end
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("head") then
            return part
        end
    end
    return nil
end

local function GetHumanoid(model)
    return model and model:FindFirstChildOfClass("Humanoid")
end

-- ==================== ОПРЕДЕЛЕНИЕ УБИЙЦЫ ====================

local function FindKiller()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local model = p.Character
            if model then
                local humanoid = GetHumanoid(model)
                if humanoid and humanoid.MaxHealth > 500 then
                    return p
                end
                for _, child in ipairs(model:GetDescendants()) do
                    if child:IsA("Tool") then
                        local n = child.Name:lower()
                        if n:find("remnant") or n:find("cleaver") or n:find("beartrap") then
                            return p
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- ==================== ФУНКЦИИ ESP ====================

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
    
    local drawings = {}
    drawings.Box = CreateESP("Square", {Visible = false, Color = color, Thickness = 2, Filled = false})
    drawings.Tracer = CreateESP("Line", {Visible = false, Color = color, Thickness = 1})
    drawings.Name = CreateESP("Text", {Visible = false, Text = name, Color = color, Size = 12, Center = true, Outline = true})
    
    ESPObjects[name] = drawings
end

local function UpdateESP()
    for name, data in pairs(ESPObjects) do
        local obj = nil
        local isPlayer = false
        
        -- Поиск объекта (игрок или предмет)
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == name then
                obj = p.Character
                isPlayer = true
                break
            end
        end
        
        if not obj then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == name or (v:IsA("Model") and v.Name:find(name)) then
                    obj = v
                    break
                end
            end
        end
        
        if not obj or (isPlayer and not obj:FindFirstChild("HumanoidRootPart")) then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        local root = isPlayer and GetRootPart(obj) or (obj:IsA("BasePart") and obj or obj.PrimaryPart)
        local head = isPlayer and GetHead(obj)
        
        if not root then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        
        if isPlayer and head then
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
            local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2, 0))
            local height = math.abs(headPos.Y - footPos.Y)
            local width = height / 2
            
            data.Box.Visible = true
            data.Box.Size = Vector2.new(width, height)
            data.Box.Position = Vector2.new(rootPos.X - width/2, headPos.Y)
            
            data.Name.Visible = true
            data.Name.Text = name .. " [" .. math.floor(dist) .. "]"
            data.Name.Position = Vector2.new(rootPos.X, headPos.Y - 15)
        else
            local size = obj:IsA("BasePart") and obj.Size or Vector3.new(4, 4, 4)
            local objHeight = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, size.Y/2, 0))
            local objFoot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, size.Y/2, 0))
            local height = math.abs(objHeight.Y - objFoot.Y)
            local width = height / 2
            
            data.Box.Visible = true
            data.Box.Size = Vector2.new(width, height)
            data.Box.Position = Vector2.new(rootPos.X - width/2, objHeight.Y)
            
            data.Name.Visible = true
            data.Name.Text = name .. " [" .. math.floor(dist) .. "]"
            data.Name.Position = Vector2.new(rootPos.X, objHeight.Y - 15)
        end
        
        data.Tracer.Visible = true
        data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        data.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
    end
end

-- ==================== ФУНКЦИИ АВТОМАТИЗАЦИИ ====================

local function AutoGeneratorTask()
    task.spawn(function()
        while Settings.AutoGenerator do
            pcall(function()
                local gens = {}
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:lower():find("generator") then
                        table.insert(gens, v)
                    end
                end
                for _, gen in ipairs(gens) do
                    if Settings.AutoGenerator and LocalPlayer.Character then
                        LocalPlayer.Character:MoveTo(gen.Parent.Position)
                        task.wait(0.5)
                        fireproximityprompt(gen)
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

local function AutoEscapeTask()
    task.spawn(function()
        while Settings.AutoEscape do
            pcall(function()
                local exits = {}
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Part") and v.Name:lower():find("exit") or v.Name:lower():find("escape") then
                        table.insert(exits, v)
                    end
                end
                if #exits > 0 and LocalPlayer.Character then
                    LocalPlayer.Character:MoveTo(exits[1].Position)
                end
            end)
            task.wait(3)
        end
    end)
end

local function AutoBarricadeTask()
    task.spawn(function()
        while Settings.AutoBarricade do
            pcall(function()
                local barricades = {}
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:lower():find("barricade") then
                        table.insert(barricades, v)
                    end
                end
                for _, bar in ipairs(barricades) do
                    if Settings.AutoBarricade and LocalPlayer.Character then
                        LocalPlayer.Character:MoveTo(bar.Parent.Position)
                        task.wait(0.5)
                        fireproximityprompt(bar)
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

local function SafetyArea()
    pcall(function()
        local safe = nil
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Part") and (v.Name:lower():find("safe") or v.Name:lower():find("spawn")) then
                safe = v
                break
            end
        end
        if safe and LocalPlayer.Character then
            LocalPlayer.Character:MoveTo(safe.Position)
        end
    end)
end

local function ViewKillerFunc()
    local killer = FindKiller()
    if killer and killer.Character then
        Camera.CameraSubject = killer.Character
    end
end

-- ==================== ФУНКЦИИ ДРУГОГО ====================

local function InfiniteSprintFunc()
    task.spawn(function()
        while Settings.InfiniteSprint do
            pcall(function()
                LocalPlayer:SetAttribute("Stamina", 100)
                LocalPlayer:SetAttribute("Energy", 100)
            end)
            task.wait(0.1)
        end
    end)
end

local function AllowJumpingFunc()
    task.spawn(function()
        while Settings.AllowJumping do
            pcall(function()
                if LocalPlayer.Character then
                    local humanoid = GetHumanoid(LocalPlayer.Character)
                    if humanoid then
                        humanoid.JumpPower = 50
                        humanoid.Jump = true
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

local function AimlockFunc()
    task.spawn(function()
        while Settings.Aimlock do
            pcall(function()
                local closest = nil
                local minDist = math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (Camera.CFrame.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = p
                        end
                    end
                end
                if closest and closest.Character then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.HumanoidRootPart.Position)
                end
            end)
            task.wait()
        end
    end)
end

local function NoclipFunc()
    task.spawn(function()
        while Settings.Noclip do
            pcall(function()
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- ==================== СОЗДАНИЕ GUI ====================

local function CreateWindow()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CeleronGUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    
    -- Заголовок
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Celeron's GUI (Bite By Night)"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Кнопка закрытия
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
        ScreenGui:Destroy()
        for _, v in pairs(ESPObjects) do
            for _, d in pairs(v) do pcall(function() d:Remove() end) end
        end
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
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -120, 1, -40)
    ContentFrame.Position = UDim2.new(0, 120, 0, 40)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    -- Функция создания вкладки
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
    
    -- Функция создания кнопки-переключателя
    local function CreateToggle(parent, text, settingName, callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -20, 0, 40)
        Frame.Position = UDim2.new(0, 10, 0, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Frame.BorderSizePixel = 0
        Frame.Parent = parent
        
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame
        
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0, 50, 0, 24)
        Toggle.Position = UDim2.new(1, -65, 0.5, -12)
        Toggle.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        Toggle.Text = Settings[settingName] and "ON" or "OFF"
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.Font = Enum.Font.GothamBold
        Toggle.TextSize = 12
        Toggle.AutoButtonColor = false
        Toggle.Parent = Frame
        
        Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)
        
        Toggle.MouseButton1Click:Connect(function()
            Settings[settingName] = not Settings[settingName]
            Toggle.Text = Settings[settingName] and "ON" or "OFF"
            Toggle.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
            if callback then callback(Settings[settingName]) end
        end)
        
        return Frame
    end
    
    -- Функция создания кнопки действия
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
    
    -- Функция создания поля ввода для бинда
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
        Input.PlaceholderText = "Enter Key (Z, X, C...)"
        Input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        Input.Parent = Frame
        
        Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 4)
        
        Input.FocusLost:Connect(function(enterPressed)
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
    
    -- Активация первой вкладки
    Tabs[1].Content.Visible = true
    Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    -- ===== MAIN =====
    CreateToggle(MainTab, "Auto Generator", "AutoGenerator", function(enabled)
        if enabled then AutoGeneratorTask() end
    end)
    CreateToggle(MainTab, "Auto Escape", "AutoEscape", function(enabled)
        if enabled then AutoEscapeTask() end
    end)
    CreateToggle(MainTab, "Auto Barricade", "AutoBarricade", function(enabled)
        if enabled then AutoBarricadeTask() end
    end)
    CreateButton(MainTab, "Safety Area", SafetyArea)
    CreateButton(MainTab, "View Killer", ViewKillerFunc)
    
    -- ===== SURVIVOR =====
    CreateButton(SurvivorTab, "Survivor ESP", function()
        Settings.SurvivorESP = not Settings.SurvivorESP
        if Settings.SurvivorESP then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p ~= FindKiller() then
                    CreateBoxESP(p.Character, Settings.SurvivorColor, p.Name)
                end
            end
        end
    end)
    CreateButton(SurvivorTab, "Killer ESP", function()
        Settings.KillerESP = not Settings.KillerESP
        if Settings.KillerESP then
            local k = FindKiller()
            if k then CreateBoxESP(k.Character, Settings.KillerColor, k.Name) end
        end
    end)
    
    -- ===== VISUAL =====
    CreateToggle(VisualTab, "Generator ESP", "GeneratorESP")
    CreateToggle(VisualTab, "Battery ESP", "BatteryESP")
    CreateToggle(VisualTab, "Fuse Box ESP", "FuseBoxESP")
    
    -- ===== TELEPORT =====
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
    
    -- ===== OTHERS =====
    CreateToggle(OthersTab, "Infinite Sprint", "InfiniteSprint", function(enabled)
        if enabled then InfiniteSprintFunc() end
    end)
    CreateToggle(OthersTab, "Allow Jumping", "AllowJumping", function(enabled)
        if enabled then AllowJumpingFunc() end
    end)
    CreateToggle(OthersTab, "Aimlock", "Aimlock", function(enabled)
        if enabled then AimlockFunc() end
    end)
    CreateBind(OthersTab, "Aimlock Bind", "AimlockBind")
    CreateToggle(OthersTab, "Noclip", "Noclip", function(enabled)
        if enabled then NoclipFunc() end
    end)
    
    -- ===== INFO =====
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -20, 0, 200)
    InfoLabel.Position = UDim2.new(0, 10, 0, 10)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Celeron's GUI for Bite By Night\n\nMade with ♥\n\nFeatures:\n- Auto tasks\n- ESP for all objects\n- Teleports\n- Character modifications"
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextSize = 14
    InfoLabel.TextWrapped = true
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    InfoLabel.Parent = InfoTab
    
    -- Перетаскивание окна
    local dragging = false
    local dragStart, startPos
    
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
    
    return ScreenGui
end

-- Запуск ESP обновления
RunService.RenderStepped:Connect(UpdateESP)

-- Обработчики игроков
Players.PlayerAdded:Connect(function(p)
    if Settings.SurvivorESP and p ~= FindKiller() then
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            CreateBoxESP(p.Character, Settings.SurvivorColor, p.Name)
        end)
    end
end)

-- Создание окна
CreateWindow()

-- Обработка биндов
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[Settings.AimlockBind] then
        Settings.Aimlock = not Settings.Aimlock
        if Settings.Aimlock then AimlockFunc() end
    end
end)

print("Celeron's GUI for Bite By Night loaded!")
