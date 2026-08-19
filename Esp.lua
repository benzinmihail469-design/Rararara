-- Инициализация сервисов
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer.PlayerGui

-- Определение типа устройства и динамических размеров
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local MainWidth = IsMobile and 530 or 570
local MainHeight = IsMobile and 320 or 340
local SidebarWidth = IsMobile and 140 or 150
local HeaderHeight = 36
local FooterHeight = 42

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeverloseMainWindow"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = CoreGui

-- Главный контейнер (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(MainWidth, MainHeight)
MainFrame.Position = UDim2.new(0.5, -MainWidth / 2, 0.5, -MainHeight / 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
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

-- Верхняя панель (Header / TopBar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, HeaderHeight)
TopBar.BackgroundColor3 = Color3.fromRGB(13, 14, 21)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "NEVERLOSE"
TitleLabel.TextColor3 = Color3.fromRGB(78, 127, 252)
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.fromOffset(HeaderHeight - 8, HeaderHeight - 8)
CloseButton.Position = UDim2.new(1, -HeaderHeight + 4, 0.5, -(HeaderHeight - 8) / 2)
CloseButton.BackgroundTransparency = 1
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.TextSize = 13
CloseButton.Parent = TopBar

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Боковое меню (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -(HeaderHeight + FooterHeight))
Sidebar.Position = UDim2.new(0, 0, 0, HeaderHeight)
Sidebar.BackgroundColor3 = Color3.fromRGB(11, 12, 18)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Нижняя панель (Footer)
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, FooterHeight)
Footer.Position = UDim2.new(0, 0, 1, -FooterHeight)
Footer.BackgroundColor3 = Color3.fromRGB(11, 12, 18)
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterBorder = Instance.new("Frame")
FooterBorder.Size = UDim2.new(1, 0, 0, 1)
FooterBorder.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
FooterBorder.BorderSizePixel = 0
FooterBorder.Parent = Footer

-- Область контента (Content Area)
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -SidebarWidth, 1, -(HeaderHeight + FooterHeight))
ContentArea.Position = UDim2.new(0, SidebarWidth, 0, HeaderHeight)
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
