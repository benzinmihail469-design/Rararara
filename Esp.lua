-- ==========================================
-- SERVICES & INITIALIZATION
-- ==========================================
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Функция безопасного получения родитеского Gui
local gethui = gethui or function()
    return CoreGui
end

-- Очистка старой копии интерфейса, если она существует
local TargetParent = gethui()
if TargetParent:FindFirstChild("DarkHub_Window") then
    TargetParent:FindFirstChild("DarkHub_Window"):Destroy()
end

-- ==========================================
-- SCREEN GUI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkHub_Window"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

-- ==========================================
-- MAIN FRAME (ОСНОВНОЕ ОКНО)
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 420)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Тёмный основной фон
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Скруглённые углы
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Обводка/Бордер (UIStroke)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(40, 40, 55)
MainStroke.Thickness = 1.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- ==========================================
-- TOPBAR (ВЕРХНЯЯ ПАНЕЛЬ)
-- ==========================================
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Topbar.BorderSizePixel = 0
Topbar.Parent = MainFrame

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0, 8)
TopbarCorner.Parent = Topbar

-- Перекрытие нижних углов Topbar для ровного стыка
local TopbarFix = Instance.new("Frame")
TopbarFix.Size = UDim2.new(1, 0, 0, 10)
TopbarFix.Position = UDim2.new(0, 0, 1, -10)
TopbarFix.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TopbarFix.BorderSizePixel = 0
TopbarFix.Parent = Topbar

-- Название окна
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DARK HUB <font color=\"rgb(120, 120, 255)\">v2.0</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

-- Акцентная разделительная линия
local AccentLine = Instance.new("Frame")
AccentLine.Name = "AccentLine"
AccentLine.Size = UDim2.new(1, 0, 0, 1)
AccentLine.Position = UDim2.new(0, 0, 1, -1)
AccentLine.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
AccentLine.BorderSizePixel = 0
AccentLine.Parent = Topbar

-- ==========================================
-- SIDEBAR & CONTENT AREA
-- ==========================================
-- Боковая панель для табов
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Главная область контента
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -160, 1, -40)
ContentArea.Position = UDim2.new(0, 160, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- ==========================================
-- DRAGGING MECHANIC (ПЕРЕТАСКИВАНИЕ ОКНА)
-- ==========================================
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    local targetPos = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
    TweenService:Create(MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end

Topbar.InputBegan:Connect(function(input)
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

Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
