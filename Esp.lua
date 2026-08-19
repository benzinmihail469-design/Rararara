-- Инициализация сервисов и базовых переменных
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer.PlayerGui

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeverloseMainWindow"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = CoreGui

-- Главный контейнер (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(640, 380)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 13) -- Основной цвет Neverlose
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 48, 58)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

-- Верхняя панель (Top Bar / Drag Frame)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(13, 14, 21)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "NEVERLOSE"
TitleLabel.TextColor3 = Color3.fromRGB(78, 127, 252) -- Акцентный цвет Neverlose
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.fromOffset(30, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundTransparency = 1
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.TextSize = 14
CloseButton.Parent = TopBar

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Боковое меню под вкладки (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(11, 12, 18)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Основная область контента (Content)
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -160, 1, -40)
ContentArea.Position = UDim2.new(0, 160, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Функция перетаскивания (Drag & Drop)
local dragging, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
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

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.05), {
            Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        }):Play()
    end
end)
