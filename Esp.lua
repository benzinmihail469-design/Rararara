-- Ожидание загрузки игры
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

-- Получение сервисов
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

if not PlayerGui then return end

-- Удаление старой копии меню
if PlayerGui:FindFirstChild("MM2FlyFollowGui") then
    PlayerGui.MM2FlyFollowGui:Destroy()
end

-- Подключение к официальному управлению Roblox (для мобильного джойстика)
local MasterControl = nil
local CharacterScripts = LocalPlayer:WaitForChild("PlayerScripts", 10)
if CharacterScripts then
    local PlayerModule = CharacterScripts:FindFirstChild("PlayerModule")
    if PlayerModule then
        local requireModule = require(PlayerModule)
        if requireModule and requireModule.GetControls then
            MasterControl = requireModule:GetControls()
        end
    end
end

-- ГЛОБАЛЬНЫЕ НАСТРОЙКИ
local Flying = false
local FlySpeed = 35 
local NormalWalkSpeed = 16
local WalkSpeedEnabled = false -- Статус кнопки включения скорости
local AutoFarmEnabled = false  -- Статус авто-фарма
local FlyConnection = nil
local NoclipConnection = nil
local WalkSpeedConnection = nil
local AutoFarmConnection = nil
local CurrentTween = nil

-- Физические объекты для полета
local BVelocity = nil
local BGyro = nil

-- СОЗДАНИЕ ИНТЕРФЕЙСА (500x300)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2FlyFollowGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(0, 255, 140) -- Мятный неоновый цвет
Stroke.Transparency = 0.2
Stroke.Parent = MainFrame

-- Шапка меню
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "MM2 CAMERA FOLLOW FLY (Tabs)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Кнопка Свернуть
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -75, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize = 14
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Кнопка Закрыть
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Панель для вкладок (Слева)
local TabPanel = Instance.new("Frame")
TabPanel.Name = "TabPanel"
TabPanel.Size = UDim2.new(0, 130, 1, -50)
TabPanel.Position = UDim2.new(0, 10, 0, 45)
TabPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TabPanel.Parent = MainFrame
Instance.new("UICorner", TabPanel).CornerRadius = UDim.new(0, 8)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabPanel
Instance.new("UIPadding", TabPanel).PaddingTop = UDim.new(0, 5)

-- Контейнер для страниц (Справа)
local PagesContainer = Instance.new("Frame")
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -160, 1, -50)
PagesContainer.Position = UDim2.new(0, 150, 0, 45)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

-- Скрипт перетаскивания (Драг)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Логика сворачивания
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 500, 0, 40) or UDim2.new(0, 500, 0, 300)
    MinBtn.Text = isMinimized and "+" or "—"
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- СИСТЕМА ВКЛАДОК И СТРАНИЦ
local tabs = {}
local activeTab = nil

local function CreateTab(name, order)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 140)
    Page.Visible = false
    Page.Parent = PagesContainer

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = Page

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
    end)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "Tab"
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.Position = UDim2.new(0, 5, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.TextSize = 13
    TabBtn.LayoutOrder = order
    TabBtn.Parent = TabPanel
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local function select()
        if activeTab then
            activeTab.TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            activeTab.TabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
            activeTab.Page.Visible = false
        end
        TabBtn.TextColor3 = Color3.fromRGB(0, 255, 140)
        TabBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
        Page.Visible = true
        activeTab = {TabBtn = TabBtn, Page = Page}
    end

    TabBtn.MouseButton1Click:Connect(select)

    tabs[name] = {TabBtn = TabBtn, Page = Page, Select = select}
    return Page
end

-- КОНСТРУКТОРЫ ЭЛЕМЕНТОВ
local function CreateToggle(parentPage, text, default, callback)
    local TglFrame = Instance.new("Frame")
    TglFrame.Size = UDim2.new(1, -6, 0, 40)
    TglFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    TglFrame.Parent = parentPage
    Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6)

    local TglLabel = Instance.new("TextLabel")
    TglLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TglLabel.Position = UDim2.new(0, 10, 0, 0)
    TglLabel.BackgroundTransparency = 1
    TglLabel.Font = Enum.Font.GothamSemibold
    TglLabel.Text = text
    TglLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    TglLabel.TextSize = 13
    TglLabel.TextXAlignment = Enum.TextXAlignment.Left
    TglLabel.Parent = TglFrame

    local TglBtn = Instance.new("TextButton")
    TglBtn.Size = UDim2.new(0, 45, 0, 22)
    TglBtn.Position = UDim2.new(1, -55, 0.5, -11)
    TglBtn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(50, 50, 55)
    TglBtn.Text = ""
    TglBtn.Parent = TglFrame
    Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(0, 11)

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 16, 0, 16)
    Switch.Position = default and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    Switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Switch.Parent = TglBtn
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 8)

    local state = default
    TglBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(50, 50, 55)
        local targetPos = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
        TweenService:Create(TglBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Switch, TweenInfo.new(0.2), {Position = targetPos}):Play()
        callback(state)
    end)
end

local function CreateSlider(parentPage, text, min, max, default, callback)
    local SldFrame = Instance.new("Frame")
    SldFrame.Size = UDim2.new(1, -6, 0, 50)
    SldFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    SldFrame.Parent = parentPage
    Instance.new("UICorner", SldFrame).CornerRadius = UDim.new(0, 6)

    local SldLabel = Instance.new("TextLabel")
    SldLabel.Size = UDim2.new(0.6, 0, 0, 25)
    SldLabel.Position = UDim2.new(0, 10, 0, 2)
    SldLabel.BackgroundTransparency = 1
    SldLabel.Font = Enum.Font.GothamSemibold
    SldLabel.Text = text
    SldLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    SldLabel.TextSize = 13
    SldLabel.TextXAlignment = Enum.TextXAlignment.Left
    SldLabel.Parent = SldFrame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.3, 0, 0, 25)
    ValLabel.Position = UDim2.new(0.7, -10, 0, 2)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
    ValLabel.TextSize = 13
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = SldFrame

    local SliderBar = Instance.new("TextButton")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 0, 34)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.Text = ""
    SliderBar.Parent = SldFrame
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(0, 3)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 3)

    local function MoveSlider(input)
        local totalWidth = SliderBar.AbsoluteSize.X
        local clickX = input.Position.X - SliderBar.AbsolutePosition.X
        local scale = math.clamp(clickX / totalWidth, 0, 1)
        SliderFill.Size = UDim2.new(scale, 0, 1, 0)
        local value = math.floor(min + (max - min) * scale)
        ValLabel.Text = tostring(value)
        callback(value)
    end

    local sliding = false
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            MoveSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then MoveSlider(input) end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
end

-- ==========================================
-- ЛОГИКА ФЛАЯ (СТАБИЛЬНАЯ ВЕРСИЯ С BODYGYRO)
-- ==========================================

local function StopFlying()
    if FlyConnection then FlyConnection:Disconnect(); FlyConnection = nil end
    if BVelocity then BVelocity:Destroy(); BVelocity = nil end
    if BGyro then BGyro:Destroy(); BGyro = nil end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
end

local function StartFlying()
    StopFlying()

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then return end
    
    hum.PlatformStand = true

    BVelocity = Instance.new("BodyVelocity")
    BVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    BVelocity.Velocity = Vector3.new(0, 0, 0)
    BVelocity.Parent = root

    BGyro = Instance.new("BodyGyro")
    BGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    BGyro.P = 15000 
    BGyro.D = 100   
    BGyro.CFrame = root.CFrame
    BGyro.Parent = root

    local cam = workspace.CurrentCamera

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Flying or not root or not LocalPlayer.Character then 
            StopFlying()
            return 
        end

        BGyro.CFrame = cam.CFrame

        local moveDir = Vector3.new(0, 0, 0)

        if MasterControl and MasterControl.GetMoveVector then
            local moveVector = MasterControl:GetMoveVector()
            if moveVector.Magnitude > 0 then
                moveDir = (cam.CFrame.LookVector * -moveVector.Z) + (cam.CFrame.RightVector * moveVector.X)
            end
        end

        if moveDir.Magnitude == 0 and UserInputService.KeyboardEnabled then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        end

        if moveDir.Magnitude > 0 then
            BVelocity.Velocity = moveDir.Unit * FlySpeed
        else
            BVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

-- ==========================================
-- ЛОГИКА АВТО-ФАРМА МОНЕТ (СКОРОСТЬ 30)
-- ==========================================

local function GetTargetCoin()
    local Bank2 = workspace:FindFirstChild("Bank2")
    if Bank2 then
        local CoinContainer = Bank2:FindFirstChild("CoinContainer")
        if CoinContainer then
            -- Ищем первую попавшуюся монетку Coin_server
            for _, child in pairs(CoinContainer:GetChildren()) do
                if child.Name == "Coin_server" and child:IsA("BasePart") then
                    return child
                end
            end
        end
    end
    return nil
end

local function StopAutoFarm()
    if AutoFarmConnection then AutoFarmConnection:Disconnect(); AutoFarmConnection = nil end
    if CurrentTween then CurrentTween:Cancel(); CurrentTween = nil end
end

local function StartAutoFarm()
    StopAutoFarm()
    
    AutoFarmConnection = RunService.Heartbeat:Connect(function()
        if not AutoFarmEnabled then 
            StopAutoFarm()
            return 
        end
        
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        -- Если мы уже летим куда-то, ждем окончания полета
        if CurrentTween and CurrentTween.PlaybackState == Enum.PlaybackState.Playing then 
            return 
        end
        
        local coin = GetTargetCoin()
        if coin then
            -- Рассчитываем время полета на основе расстояния, чтобы скорость была ровно 30
            local distance = (root.Position - coin.Position).Magnitude
            local duration = distance / 30
            
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
            CurrentTween = TweenService:Create(root, tweenInfo, {CFrame = coin.CFrame})
            CurrentTween:Play()
        end
    end)
end


-- АВТО-ОБНОВЛЕНИЕ СКОРОСТИ ХОДЬБЫ ПРИ РЕСПАВНЕ И БЕГЕ
if WalkSpeedConnection then WalkSpeedConnection:Disconnect() end
WalkSpeedConnection = RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and not Flying then
        -- Скорость меняется только если кнопка WalkSpeed активна
        hum.WalkSpeed = WalkSpeedEnabled and NormalWalkSpeed or 16
    end
end)

-- СОЗДАНИЕ СТРАНИЦ ЧЕРЕЗ ВКЛАДКИ
local MainTab = CreateTab("Главная", 1)
local PlayerTab = CreateTab("Игрок", 2)

-- ЭЛЕМЕНТЫ ВКЛАДКИ "ГЛАВНАЯ"
CreateToggle(MainTab, "Auto Farm Coins (Банк)", false, function(state)
    AutoFarmEnabled = state
    if state then
        -- Отключаем флай, чтобы они не конфликтовали
        Flying = false
        StopFlying()
        StartAutoFarm()
    else
        StopAutoFarm()
    end
end)

-- ЭЛЕМЕНТЫ ВКЛАДКИ "ИГРОК"
CreateToggle(PlayerTab, "Bypass Fly (Следование за камерой)", false, function(state)
    Flying = state
    if state then
        -- Отключаем фарм при ручном полете
        AutoFarmEnabled = false
        StopAutoFarm()
        StartAutoFarm() -- Запустит логику выключения внутри себя
        StartFlying()
    else
        StopFlying()
    end
end)

CreateSlider(PlayerTab, "Скорость полета", 15, 90, 35, function(value)
    FlySpeed = value
end)

-- Включатель/выключатель скорости ходьбы
CreateToggle(PlayerTab, "Toggle WalkSpeed (Вкл/Выкл скорость)", false, function(state)
    WalkSpeedEnabled = state
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and not Flying then 
        hum.WalkSpeed = state and NormalWalkSpeed or 16 
    end
end)

-- Ползунок настройки скорости
CreateSlider(PlayerTab, "Cкорость ходьбы (WalkSpeed)", 16, 120, 16, function(value)
    NormalWalkSpeed = value
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and WalkSpeedEnabled and not Flying then 
        hum.WalkSpeed = value 
    end
end)

CreateToggle(PlayerTab, "Noclip (Сквозь стены)", false, function(state)
    if state then
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NoclipConnection then NoclipConnection:Disconnect(); NoclipConnection = nil end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

CreateToggle(PlayerTab, "Inf Jump (Бесконечный прыжок)", false, function(state)
    _G.InfJump = state
    if state then
        UserInputService.JumpRequest:Connect(function()
            if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end)

-- Авто-активация первой вкладки при старте
if tabs["Главная"] then
    tabs["Главная"].Select()
end

-- Сброс настроек и закрытие меню
CloseBtn.MouseButton1Click:Connect(function()
    Flying = false
    AutoFarmEnabled = false
    StopFlying()
    StopAutoFarm()
    if NoclipConnection then NoclipConnection:Disconnect() end
    if WalkSpeedConnection then WalkSpeedConnection:Disconnect() end
    
    -- Возвращаем стандартную скорость игроку перед удалением скрипта
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
    
    ScreenGui:Destroy()
end)
