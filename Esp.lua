-- 🌙 Dark Hub (Premium Edition)
-- Плавные анимации, UIStroke, умный автофарм с флаем

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer

-- Удаляем старую версию, если она есть
if CoreGui:FindFirstChild("DarkHub_Premium") then
    CoreGui.DarkHub_Premium:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkHub_Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Функция для красивых анимаций кнопок
local function RippleEffect(button)
    local originalColor = button.BackgroundColor3
    local hoverColor = Color3.new(
        math.clamp(originalColor.R + 0.08, 0, 1),
        math.clamp(originalColor.G + 0.08, 0, 1),
        math.clamp(originalColor.B + 0.12, 0, 1) -- Легкий сине-фиолетовый оттенок
    )

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = hoverColor}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = originalColor}):Play()
    end)
end

---------------------------------------------------------
-- 🎨 ГЛАВНЫЙ ИНТЕРФЕЙС
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Для анимации появления
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Красивая обводка (Stroke)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 40, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

---------------------------------------------------------
-- 🕹️ ВЕРХНЯЯ ПАНЕЛЬ (TopBar)
---------------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarBottom = Instance.new("Frame")
TopBarBottom.Size = UDim2.new(1, 0, 0, 10)
TopBarBottom.Position = UDim2.new(0, 0, 1, -10)
TopBarBottom.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBarBottom.BorderSizePixel = 0
TopBarBottom.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌙 Dark Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Кнопки управления (Свернуть и Закрыть)
local Controls = Instance.new("Frame")
Controls.Size = UDim2.new(0, 80, 1, 0)
Controls.Position = UDim2.new(1, -80, 0, 0)
Controls.BackgroundTransparency = 1
Controls.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(0, 5, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Controls
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
RippleEffect(MinBtn)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(0, 40, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Controls
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
RippleEffect(CloseBtn)

-- Логика перетаскивания окна (Draggable)
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Логика сворачивания и закрытия
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local goalSize = isMinimized and UDim2.new(0, 550, 0, 45) or UDim2.new(0, 550, 0, 360)
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = goalSize}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    tween:Play()
    tween.Completed:Wait()
    ScreenGui:Destroy()
end)

---------------------------------------------------------
-- 📋 БОКОВОЕ МЕНЮ И КОНТЕНТ
---------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -150, 1, -45)
ContentArea.Position = UDim2.new(0, 150, 0, 45)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(1, -10, 1, -20)
TabContainer.Position = UDim2.new(0, 5, 0, 10)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 0
TabContainer.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.Parent = TabContainer

local Pages = {}

local function CreateTab(name, icon, isDefault)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.BackgroundColor3 = Color3.fromRGB(130, 90, 255)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = "  " .. icon .. "  " .. name
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = TabContainer
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Position = UDim2.new(0, 10, 0, 10)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
    Page.Visible = false
    Page.Parent = ContentArea

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = Page

    Pages[name] = {Button = TabBtn, Page = Page}

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Pages) do
            TweenService:Create(t.Button, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
            t.Page.Visible = false
        end
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.1, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        Page.Visible = true
    end)

    if isDefault then
        TabBtn.BackgroundTransparency = 0.1
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Page.Visible = true
    end

    return Page
end

local function CreateToggle(parent, text, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -5, 0, 42)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local SwitchBG = Instance.new("TextButton")
    SwitchBG.Size = UDim2.new(0, 44, 0, 24)
    SwitchBG.Position = UDim2.new(1, -60, 0.5, -12)
    SwitchBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SwitchBG.Text = ""
    SwitchBG.AutoButtonColor = false
    SwitchBG.Parent = ToggleFrame
    Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 20, 0, 20)
    Circle.Position = UDim2.new(0, 2, 0.5, -10)
    Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Circle.Parent = SwitchBG
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local toggled = false
    SwitchBG.MouseButton1Click:Connect(function()
        toggled = not toggled
        local goalPos = toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local goalColor = toggled and Color3.fromRGB(130, 90, 255) or Color3.fromRGB(40, 40, 50)
        
        TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = goalPos}):Play()
        TweenService:Create(SwitchBG, TweenInfo.new(0.3), {BackgroundColor3 = goalColor}):Play()
        
        callback(toggled)
    end)
end

---------------------------------------------------------
-- 🛠️ НАСТРОЙКА ВКЛАДОК И ЛОГИКИ
---------------------------------------------------------
local FarmPage = CreateTab("Auto Farm", "💰", true)
CreateTab("Combat", "⚔️", false)
CreateTab("Visuals", "👁️", false)

-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
_G.AutoFarm = false
local FlyBody = nil

-- ФУНКЦИИ ФЛАЯ
local function EnableFly(char)
    if not char:FindFirstChild("HumanoidRootPart") then return end
    if not FlyBody then
        FlyBody = Instance.new("BodyVelocity")
        FlyBody.Name = "HubFly"
        FlyBody.MaxForce = Vector3.new(400000, 400000, 400000)
        FlyBody.Velocity = Vector3.new(0, 0, 0)
        FlyBody.Parent = char.HumanoidRootPart
    end
end

local function DisableFly(char)
    if FlyBody then
        FlyBody:Destroy()
        FlyBody = nil
    end
end

-- РАБОЧИЙ АВТОФАРМ С ПРОВЕРКОЙ ЛОББИ И ОГРАНИЧЕНИЕМ СКОРОСТИ
CreateToggle(FarmPage, "Enable Auto-Farm", function(state)
    _G.AutoFarm = state
    
    if _G.AutoFarm then
        task.spawn(function()
            while _G.AutoFarm do
                task.wait(0.1)
                local char = LP.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                    
                    -- Проверка на лобби (Обычно лобби находится высоко в небе)
                    -- Настрой это значение (например, > 100 или > 50) под конкретную игру
                    local isInLobby = (char.HumanoidRootPart.Position.Y > 100) 
                    
                    if isInLobby then
                        -- ЕСЛИ ИГРОК В ЛОББИ:
                        -- Скрипт стоит нормально, флай отключается, скорость стандартная
                        DisableFly(char)
                        char.Humanoid.WalkSpeed = 16
                    else
                        -- ЕСЛИ ИГРОК В КАТКЕ:
                        -- Включается флай и максимальная скорость фиксируется на 25
                        EnableFly(char)
                        char.Humanoid.WalkSpeed = 25
                        
                        -- Тут размещается логика телепорта к монетам:
                        -- Если используешь флай, меняй FlyBody.Velocity в сторону ближайшей монеты
                        -- Или используй TweenService для перемещения HumanoidRootPart.CFrame
                    end
                end
            end
        end)
    else
        -- Полный сброс при выключении скрипта
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            DisableFly(char)
            char.Humanoid.WalkSpeed = 16
        end
    end
end)

CreateToggle(FarmPage, "Auto-Respawn", function(state) end)
CreateToggle(FarmPage, "Anti-Fling", function(state) end)

---------------------------------------------------------
-- 🚀 ЗАПУСК GUI (Анимация появления)
---------------------------------------------------------
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 550, 0, 360)}):Play()
