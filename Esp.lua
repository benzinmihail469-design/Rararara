-- Защита от дублирования интерфейса при повторном запуске
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("CustomMM2Hub") then
    CoreGui.CustomMM2Hub:Destroy()
end

-- ==========================================
-- ОСНОВНОЕ ОКНО
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMM2Hub"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Темный фон (как в Hoshi)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Скругление углов главного окна
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = " 🔪 MM2 Hub (Raw Lua)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Отступ для текста заголовка
local TitlePadding = Instance.new("UIPadding")
TitlePadding.PaddingLeft = UDim.new(0, 15)
TitlePadding.Parent = Title

-- Боковая панель для вкладок
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Авто-расположение кнопок вкладок
local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

-- Зона для контента (где будут кнопки)
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -130, 1, -35)
ContentArea.Position = UDim2.new(0, 130, 0, 35)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- ==========================================
-- ЛОГИКА ВКЛАДОК И КНОПОК
-- ==========================================
local firstTab = true

local function CreateTab(name)
    -- Кнопка вкладки в боковой панели
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabBtn.BackgroundTransparency = firstTab and 0 or 1
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 14
    TabBtn.Parent = Sidebar
    
    -- Страница вкладки
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.ScrollBarThickness = 4
    TabPage.Visible = firstTab
    TabPage.Parent = ContentArea
    
    -- Авто-расположение элементов на странице
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = TabPage
    
    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 10)
    PagePadding.PaddingLeft = UDim.new(0, 10)
    PagePadding.PaddingRight = UDim.new(0, 10)
    PagePadding.Parent = TabPage

    -- Переключение вкладок
    TabBtn.MouseButton1Click:Connect(function()
        for _, child in pairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") then child.BackgroundTransparency = 1 end
        end
        for _, child in pairs(ContentArea:GetChildren()) do
            if child:IsA("ScrollingFrame") then child.Visible = false end
        end
        TabBtn.BackgroundTransparency = 0
        TabPage.Visible = true
    end)
    
    firstTab = false
    return TabPage
end

local function CreateButton(parentPage, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.AutoButtonColor = true
    Btn.Parent = parentPage
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- СОЗДАЕМ ИНТЕРФЕЙС ДЛЯ MM2
-- ==========================================

-- Вкладка 1: Фарм
local FarmTab = CreateTab("🏠 Main")
CreateButton(FarmTab, "Авто-монеты (Coin Farm)", function()
    print("Скрипт на монеты запущен")
    -- Твой код на фарм монет
end)

CreateButton(FarmTab, "Подобрать пистолет", function()
    print("Телепорт к пистолету")
    -- Твой код на тп к дропу
end)

-- Вкладка 2: Визуалы (ESP)
local VisualsTab = CreateTab("👁️ Visuals")
CreateButton(VisualsTab, "ESP Убийца (Красный)", function()
    print("ESP Murderer включен")
    -- Твой код на подсветку убийцы
end)

CreateButton(VisualsTab, "ESP Шериф (Синий)", function()
    print("ESP Sheriff включен")
    -- Твой код на подсветку шерифа
end)

-- Вкладка 3: Игрок
local PlayerTab = CreateTab("🏃 Player")
CreateButton(PlayerTab, "Скорость бега (WalkSpeed 50)", function()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 50
    end
end)

CreateButton(PlayerTab, "Прыжок (JumpPower 100)", function()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = 100
    end
end)

-- ==========================================
-- ПЛАВНОЕ ПЕРЕТАСКИВАНИЕ (DRAG)
-- ==========================================
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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
