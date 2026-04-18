--[[
    Celeron's GUI для Bite By Night
    ИСПРАВЛЕНО: Модельки, Infinite Sprint, Обход античита
--]]

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

-- Состояние окна
local WindowState = {
    Minimized = false,
    MainFrame = nil,
    ContentFrame = nil,
    MinimizeBtn = nil
}

-- Хранилище для GUI
local Tabs = {}
local ToggleButtons = {}

-- ==================== ОБХОД АНТИЧИТА (ИЗ CELERON'S LOADER) ====================

-- Защита от обнаружения
local function setupAntiCheatBypass()
    -- Отключаем античит-скрипты
    for _, v in ipairs(game:GetService("Players").LocalPlayer.PlayerScripts:GetChildren()) do
        if v.Name:find("Anti") or v.Name:find("Cheat") or v.Name:find("Detect") then
            v:Destroy()
        end
    end
    
    -- Защита от kick за скорость
    local oldIndex = hookmetamethod(game, "__index", function(self, key)
        if self == LocalPlayer.Character and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and self == humanoid and key == "WalkSpeed" then
                return 16
            end
        end
        return oldIndex(self, key)
    end)
end

setupAntiCheatBypass()

-- ==================== ФУНКЦИИ ДЛЯ РАБОТЫ С МОДЕЛЯМИ (ИСПРАВЛЕНО) ====================

local function GetRootPart(model)
    if not model then return nil end
    
    -- Стандартный HumanoidRootPart
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    
    -- Для моделек: ищем Torso
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local name = part.Name:lower()
            if name:find("torso") or name:find("upper") or name:find("lower") then
                return part
            end
        end
    end
    
    -- Самая большая часть
    local biggest = nil
    local biggestSize = 0
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local size = part.Size.X + part.Size.Y + part.Size.Z
            if size > biggestSize then
                biggestSize = size
                biggest = part
            end
        end
    end
    
    return biggest or model.PrimaryPart
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
    
    -- Самая высокая часть
    local highest = nil
    local highestY = -math.huge
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Position.Y > highestY then
                highestY = part.Position.Y
                highest = part
            end
        end
    end
    return highest
end

local function GetHumanoid(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then return humanoid end
    
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("Humanoid") then
            return child
        end
    end
    
    return nil
end

-- ==================== ОПРЕДЕЛЕНИЕ УБИЙЦЫ ====================

local function FindKiller()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local model = p.Character
            if model then
                -- Проверка по здоровью
                local humanoid = GetHumanoid(model)
                if humanoid and humanoid.MaxHealth > 500 then
                    return p
                end
                
                -- Проверка по оружию
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

-- ==================== ФУНКЦИИ ESP (ИСПРАВЛЕНО ДЛЯ МОДЕЛЕК) ====================

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
    drawings.Name = CreateESP("Text", {Visible = false, Text = name, Color = color, Size = 12, Center = true, Outline = true})
    
    ESPObjects[name] = drawings
end

local function UpdateESP()
    if not Settings.SurvivorESP and not Settings.KillerESP then
        for _, data in pairs(ESPObjects) do
            for _, d in pairs(data) do d.Visible = false end
        end
        return
    end
    
    -- Обновление ESP для игроков
    if Settings.SurvivorESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p ~= FindKiller() and p.Character then
                if not ESPObjects[p.Name] then
                    CreateBoxESP(p.Character, Settings.SurvivorColor, p.Name)
                end
            end
        end
    end
    
    if Settings.KillerESP then
        local k = FindKiller()
        if k and k.Character then
            if not ESPObjects[k.Name] then
                CreateBoxESP(k.Character, Settings.KillerColor, k.Name)
            end
        end
    end
    
    -- Обновление позиций для моделек
    for name, data in pairs(ESPObjects) do
        local obj = nil
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == name then
                obj = p.Character
                break
            end
        end
        
        if not obj or not obj.Parent then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        local root = GetRootPart(obj)
        local head = GetHead(obj)
        
        if not root or not head then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end
        
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        
        -- Расчёт размеров для моделек
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
    end
end

-- ==================== ФУНКЦИИ АВТОМАТИЗАЦИИ ====================

local AutoTasks = {
    Generator = nil,
    Escape = nil,
    Barricade = nil
}

local function AutoGeneratorTask()
    if AutoTasks.Generator then AutoTasks.Generator:Disconnect() end
    if not Settings.AutoGenerator then return end
    
    AutoTasks.Generator = RunService.Heartbeat:Connect(function()
        pcall(function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:lower():find("generator") then
                    if LocalPlayer.Character then
                        local root = GetRootPart(LocalPlayer.Character)
                        if root then
                            local dist = (root.Position - v.Parent.Position).Magnitude
                            if dist < 10 then
                                fireproximityprompt(v)
                            else
                                LocalPlayer.Character:MoveTo(v.Parent.Position)
                            end
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
                        if root then
                            local dist = (root.Position - v.Parent.Position).Magnitude
                            if dist < 10 then
                                fireproximityprompt(v)
                            else
                                LocalPlayer.Character:MoveTo(v.Parent.Position)
                            end
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
        task.wait(3)
        Camera.CameraSubject = LocalPlayer.Character
    end
end

-- ==================== ФУНКЦИИ ДРУГОГО (ИСПРАВЛЕНО) ====================

local OtherTasks = {
    Sprint = nil,
    Jump = nil,
    Aimlock = nil,
    Noclip = nil
}

-- ИСПРАВЛЕННЫЙ INFINITE SPRINT
local function InfiniteSprintFunc()
    if OtherTasks.Sprint then OtherTasks.Sprint:Disconnect() end
    if not Settings.InfiniteSprint then return end
    
    -- Метод 1: Через атрибуты
    OtherTasks.Sprint = RunService.Heartbeat:Connect(function()
        pcall(function()
            LocalPlayer:SetAttribute("Stamina", 100)
            LocalPlayer:SetAttribute("stamina", 100)
            LocalPlayer:SetAttribute("Energy", 100)
            LocalPlayer:SetAttribute("energy", 100)
            LocalPlayer:SetAttribute("Endurance", 100)
            LocalPlayer:SetAttribute("endurance", 100)
        end)
    end)
    
    -- Метод 2: Поиск UI стамины
    task.spawn(function()
        while Settings.InfiniteSprint do
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in ipairs(playerGui:GetDescendants()) do
                        if gui:IsA("Frame") or gui:IsA("ImageLabel") then
                            local name = gui.Name:lower()
                            if name:find("stamina") or name:find("energy") then
                                local value = gui:FindFirstChild("Value") or gui:FindFirstChild("Bar")
                                if value and (value:IsA("NumberValue") or value:IsA("IntValue")) then
                                    value.Value = 100
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
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
            local closest = nil
            local minDist = math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local root = GetRootPart(p.Character)
                    if root then
                        local dist = (Camera.CFrame.Position - root.Position).Magnitude
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
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, root.Position)
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
    
    WindowState.MainFrame = MainFrame
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    
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
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Кнопка сворачивания
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
    
    WindowState.MinimizeBtn = MinimizeBtn
    
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
        for _, task in pairs(AutoTasks) do if task then task:Disconnect() end end
        for _, task in pairs(OtherTasks) do if task then task:Disconnect() end end
        for _, v in pairs(ESPObjects) do
            for _, d in pairs(v) do pcall(function() d:Remove() end) end
        end
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
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -120, 1, -40)
    ContentFrame.Position = UDim2.new(0, 120, 0, 40)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    WindowState.ContentFrame = ContentFrame
    
    -- Функция сворачивания/разворачивания
    local function ToggleMinimize()
        WindowState.Minimized = not WindowState.Minimized
        if WindowState.Minimized then
            MainFrame.Size = UDim2.new(0, 600, 0, 40)
            TabHolder.Visible = false
            ContentFrame.Visible = false
            MinimizeBtn.Text = "+"
        else
            MainFrame.Size = UDim2.new(0, 600, 0, 400)
            TabHolder.Visible = true
            ContentFrame.Visible = true
            MinimizeBtn.Text = "—"
        end
    end
    
    MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)
    
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
    
    -- Функция создания переключателя
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
    
    -- Функция создания кнопки
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
    
    -- Функция создания поля для бинда
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
    
    -- ===== MAIN =====
    CreateToggle(MainTab, "Auto Generator", "AutoGenerator", AutoGeneratorTask)
    CreateToggle(MainTab, "Auto Escape", "AutoEscape", AutoEscapeTask)
    CreateToggle(MainTab, "Auto Barricade", "AutoBarricade", AutoBarricadeTask)
    CreateButton(MainTab, "Safety Area", SafetyArea)
    CreateButton(MainTab, "View Killer", ViewKillerFunc)
    
    -- ===== SURVIVOR =====
    CreateToggle(SurvivorTab, "Survivor ESP", "SurvivorESP")
    CreateToggle(SurvivorTab, "Killer ESP", "KillerESP")
    
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
    CreateToggle(OthersTab, "Infinite Sprint", "InfiniteSprint", InfiniteSprintFunc)
    CreateToggle(OthersTab, "Allow Jumping", "AllowJumping", AllowJumpingFunc)
    CreateToggle(OthersTab, "Aimlock", "Aimlock", AimlockFunc)
    CreateBind(OthersTab, "Aimlock Bind", "AimlockBind")
    CreateToggle(OthersTab, "Noclip", "Noclip", NoclipFunc)
    
    -- ===== INFO =====
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -20, 0, 200)
    InfoLabel.Position = UDim2.new(0, 10, 0, 10)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Celeron's GUI for Bite By Night\n\n✓ Model support\n✓ Infinite Sprint fixed\n✓ Anti-cheat bypass\n\nClick — to minimize"
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextSize = 14
    InfoLabel.TextWrapped = true
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    InfoLabel.Parent = InfoTab
    
    -- Перетаскивание
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

-- Запуск
RunService.RenderStepped:Connect(UpdateESP)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Settings.SurvivorESP and p ~= FindKiller() then
            CreateBoxESP(p.Character, Settings.SurvivorColor, p.Name)
        end
        if Settings.KillerESP and p == FindKiller() then
            CreateBoxESP(p.Character, Settings.KillerColor, p.Name)
        end
    end)
end)

CreateWindow()

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

print("Celeron's GUI loaded! Model support + Infinite Sprint fixed + Anti-cheat bypass!")
