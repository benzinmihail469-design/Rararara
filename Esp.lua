-- Pulse Hub UI (Точная копия по скриншоту)
-- Без сторонних библиотек

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- Защита от дубликатов
if CoreGui:FindFirstChild("PulseHub_Exact") then
    CoreGui.PulseHub_Exact:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PulseHub_Exact"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Главный фрейм (окно)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Функция перетаскивания (Draggable)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

---------------------------------------------------------
-- ЛЕВАЯ ПАНЕЛЬ (Sidebar)
---------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Логотип и Заголовок
local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 0, 40)
LogoText.Position = UDim2.new(0, 15, 0, 10)
LogoText.BackgroundTransparency = 1
LogoText.Text = "⚡ Pulse Hub\n<font size='10' color='#888888'>Murder Mystery 2</font>"
LogoText.RichText = true
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.TextSize = 14
LogoText.Font = Enum.Font.GothamBold
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = Sidebar

-- Контейнер для вкладок
local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(1, 0, 1, -110)
TabContainer.Position = UDim2.new(0, 0, 0, 60)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 0
TabContainer.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 2)
TabListLayout.Parent = TabContainer

-- Футер в сайдбаре
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 40)
Footer.Position = UDim2.new(0, 0, 1, -40)
Footer.BackgroundTransparency = 1
Footer.Parent = Sidebar

local FooterText = Instance.new("TextLabel")
FooterText.Size = UDim2.new(1, -20, 1, 0)
FooterText.Position = UDim2.new(0, 15, 0, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "discord.gg/pulsezone\nSession 02:30 — 163 FPS"
FooterText.TextColor3 = Color3.fromRGB(100, 100, 100)
FooterText.TextSize = 10
FooterText.Font = Enum.Font.Gotham
FooterText.TextXAlignment = Enum.TextXAlignment.Left
FooterText.Parent = Footer

---------------------------------------------------------
-- ПРАВАЯ ПАНЕЛЬ (Контент)
---------------------------------------------------------
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -160, 1, 0)
ContentArea.Position = UDim2.new(0, 160, 0, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Кнопка закрытия окна
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -30, 0, 10)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = ContentArea
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Pages = {}
local CurrentTab = nil

-- Функция создания вкладки
local function CreateTab(name, icon, isDefault)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -10, 0, 28)
    TabButton.Position = UDim2.new(0, 5, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = "  " .. icon .. "   " .. name
    TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabButton.TextSize = 12
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = TabContainer

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -20, 1, -50)
    Page.Position = UDim2.new(0, 10, 0, 40)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
    Page.Visible = false
    Page.Parent = ContentArea

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = Page

    -- Заголовок страницы
    local PageTitle = Instance.new("TextLabel")
    PageTitle.Size = UDim2.new(1, 0, 0, 30)
    PageTitle.Position = UDim2.new(0, 10, 0, 5)
    PageTitle.BackgroundTransparency = 1
    PageTitle.Text = name
    PageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PageTitle.TextSize = 16
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left
    PageTitle.Visible = false
    PageTitle.Parent = ContentArea

    Pages[name] = {Button = TabButton, Page = Page, Title = PageTitle}

    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(Pages) do
            t.Button.BackgroundTransparency = 1
            t.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
            t.Page.Visible = false
            t.Title.Visible = false
        end
        TabButton.BackgroundTransparency = 0
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        Page.Visible = true
        PageTitle.Visible = true
    end)

    if isDefault then
        TabButton.BackgroundTransparency = 0
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        Page.Visible = true
        PageTitle.Visible = true
    end

    return Page
end

-- Функция создания переключателя (Toggle) в стиле iOS, как на картинке
local function CreateToggle(parent, text, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 36)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent

    local TFC = Instance.new("UICorner")
    TFC.CornerRadius = UDim.new(0, 6)
    TFC.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local SwitchBG = Instance.new("TextButton")
    SwitchBG.Size = UDim2.new(0, 36, 0, 20)
    SwitchBG.Position = UDim2.new(1, -46, 0.5, -10)
    SwitchBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SwitchBG.Text = ""
    SwitchBG.AutoButtonColor = false
    SwitchBG.Parent = ToggleFrame

    local SbgCorner = Instance.new("UICorner")
    SbgCorner.CornerRadius = UDim.new(1, 0)
    SbgCorner.Parent = SwitchBG

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 2, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Circle.Parent = SwitchBG

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local toggled = false
    SwitchBG.MouseButton1Click:Connect(function()
        toggled = not toggled
        
        local goalPos = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local goalColor = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
        
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = goalPos}):Play()
        TweenService:Create(SwitchBG, TweenInfo.new(0.2), {BackgroundColor3 = goalColor}):Play()
        
        callback(toggled)
    end)
end

-- Функция создания категории внутри страницы (например, "Farm")
local function CreateSectionLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    return Label
end

---------------------------------------------------------
-- СОЗДАНИЕ ВКЛАДОК (Опираясь на картинку)
---------------------------------------------------------
CreateTab("Main", "👁", false)
CreateTab("Sheriff", "🔫", false)
CreateTab("Murder", "🔪", false)
local AutoFarmPage = CreateTab("Auto Farm", "💰", true) -- Сделано вкладкой по умолчанию для демонстрации
CreateTab("Teleport", "🔓", false)
CreateTab("Fun/Troll", "😂", false)
CreateTab("Fling Players", "🌀", false)
CreateTab("Visuals", "👁", false)
CreateTab("Settings", "⚙", false)

---------------------------------------------------------
-- НАПОЛНЕНИЕ ВКЛАДКИ AUTO FARM (Как на скриншоте)
---------------------------------------------------------
CreateSectionLabel(AutoFarmPage, "Farm")

CreateToggle(AutoFarmPage, "Auto Farm", function(state)
    -- Базовая логика для автофарма
    if state then
        _G.AutoFarmEnabled = true
        task.spawn(function()
            while _G.AutoFarmEnabled do
                task.wait(0.1)
                
                -- Проверка: фарм работает в катке (игрок должен быть жив и на карте), 
                -- а в лобби скрипт не должен пытаться фармить/двигаться хаотично.
                local inLobby = false -- Заменить на реальную проверку лобби для MM2
                
                if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                    if not inLobby then
                        -- Установка максимальной скорости на 25 для стабильного сбора монет
                        LP.Character.Humanoid.WalkSpeed = 25
                        
                        -- Место для вашей логики полета и сбора монет
                    else
                        -- Обычное поведение в лобби
                        LP.Character.Humanoid.WalkSpeed = 16 
                    end
                end
            end
        end)
    else
        _G.AutoFarmEnabled = false
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = 16 -- Сброс скорости при выключении
        end
    end
end)

CreateToggle(AutoFarmPage, "Auto-Respawn", function(state)
    -- Логика
end)

CreateToggle(AutoFarmPage, "Anti-Fling", function(state)
    -- Логика
end)

CreateToggle(AutoFarmPage, "Avoid Murderer", function(state)
    -- Логика
end)

CreateToggle(AutoFarmPage, "Auto-Fling", function(state)
    -- Логика
end)

CreateToggle(AutoFarmPage, "Kill Aura", function(state)
    -- Логика
end)
