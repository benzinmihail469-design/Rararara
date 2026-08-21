-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local TweenInfoFast = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Dimensions Configuration
local MainWidth = 530
local MainHeight = 320
local SidebarWidth = 140
local HeaderHeight = 36
local FooterHeight = 42

-- Parent Container Detection
local TargetParent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Авто-очистка старых версий
if TargetParent:FindFirstChild("NeverloseMainWindow") then
    TargetParent.NeverloseMainWindow:Destroy()
end

-- 1. ScreenGui Initialization
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeverloseMainWindow"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

-- 2. Main Window Frame (Точный цвет главного фона)
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainFrame"
MainWindow.Size = UDim2.new(0, MainWidth, 0, MainHeight)
MainWindow.Position = UDim2.new(0.5, -MainWidth / 2, 0.5, -MainHeight / 2)
MainWindow.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainWindow

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(28, 35, 48)
MainStroke.Thickness = 1
MainStroke.Parent = MainWindow

-- 3. Left Sidebar (Точный цвет сайдбара Neverlose)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainWindow

-- Brand Logo
local LogoText = Instance.new("TextLabel")
LogoText.Name = "Logo"
LogoText.Size = UDim2.new(1, -20, 0, HeaderHeight)
LogoText.Position = UDim2.new(0, 12, 0, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "NEVERLOSE"
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 13
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = Sidebar

-- Tab Navigation Container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -16, 1, -(HeaderHeight + FooterHeight + 20))
TabContainer.Position = UDim2.new(0, 8, 0, HeaderHeight + 5)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 3)
TabListLayout.Parent = TabContainer

-- User Profile Widget (Footer)
local UserProfile = Instance.new("Frame")
UserProfile.Name = "UserProfile"
UserProfile.Size = UDim2.new(1, -16, 0, FooterHeight)
UserProfile.Position = UDim2.new(0, 8, 1, -(FooterHeight + 8))
UserProfile.BackgroundTransparency = 1
UserProfile.BorderSizePixel = 0
UserProfile.Parent = Sidebar

local AvatarSize = FooterHeight - 12
local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Name = "Avatar"
AvatarImage.Size = UDim2.new(0, AvatarSize, 0, AvatarSize)
AvatarImage.Position = UDim2.new(0, 6, 0.5, -AvatarSize / 2)
AvatarImage.BackgroundColor3 = Color3.fromRGB(28, 35, 48)
AvatarImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
AvatarImage.Parent = UserProfile

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarImage

local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Name = "Username"
UsernameLabel.Size = UDim2.new(1, -(AvatarSize + 16), 0, 15)
UsernameLabel.Position = UDim2.new(0, AvatarSize + 12, 0, 6)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = LocalPlayer.DisplayName
UsernameLabel.Font = Enum.Font.GothamBold
UsernameLabel.TextSize = 11
UsernameLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.Parent = UserProfile

local SubLabel = Instance.new("TextLabel")
SubLabel.Name = "Subscription"
SubLabel.Size = UDim2.new(1, -(AvatarSize + 16), 0, 13)
SubLabel.Position = UDim2.new(0, AvatarSize + 12, 0, 21)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Lifetime"
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextSize = 10
SubLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = UserProfile

-- 4. Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, -SidebarWidth, 0, HeaderHeight)
Header.Position = UDim2.new(0, SidebarWidth, 0, 0)
Header.BackgroundTransparency = 1
Header.Parent = MainWindow

local ActiveTabTitle = Instance.new("TextLabel")
ActiveTabTitle.Name = "ActiveTabTitle"
ActiveTabTitle.Size = UDim2.new(0, 150, 1, 0)
ActiveTabTitle.Position = UDim2.new(0, 15, 0, 0)
ActiveTabTitle.BackgroundTransparency = 1
ActiveTabTitle.Text = "RAGEBOT"
ActiveTabTitle.Font = Enum.Font.GothamBold
ActiveTabTitle.TextSize = 12
ActiveTabTitle.TextColor3 = Color3.fromRGB(240, 245, 255)
ActiveTabTitle.TextXAlignment = Enum.TextXAlignment.Left
ActiveTabTitle.Parent = Header

local WatermarkInfo = Instance.new("TextLabel")
WatermarkInfo.Name = "WatermarkInfo"
WatermarkInfo.Size = UDim2.new(0, 180, 1, 0)
WatermarkInfo.Position = UDim2.new(1, -195, 0, 0)
WatermarkInfo.BackgroundTransparency = 1
WatermarkInfo.Text = "neverlose.cc | roblox"
WatermarkInfo.Font = Enum.Font.GothamMedium
WatermarkInfo.TextSize = 11
WatermarkInfo.TextColor3 = Color3.fromRGB(70, 78, 92)
WatermarkInfo.TextXAlignment = Enum.TextXAlignment.Right
WatermarkInfo.Parent = Header

-- 5. Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -(SidebarWidth + 20), 1, -(HeaderHeight + 10))
ContentContainer.Position = UDim2.new(0, SidebarWidth + 10, 0, HeaderHeight)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainWindow

local LeftColumn = Instance.new("ScrollingFrame")
LeftColumn.Name = "LeftColumn"
LeftColumn.Size = UDim2.new(0.5, -5, 1, 0)
LeftColumn.Position = UDim2.new(0, 0, 0, 0)
LeftColumn.BackgroundTransparency = 1
LeftColumn.ScrollBarThickness = 2
LeftColumn.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
LeftColumn.Parent = ContentContainer

local RightColumn = Instance.new("ScrollingFrame")
RightColumn.Name = "RightColumn"
RightColumn.Size = UDim2.new(0.5, -5, 1, 0)
RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
RightColumn.BackgroundTransparency = 1
RightColumn.ScrollBarThickness = 2
RightColumn.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
RightColumn.Parent = ContentContainer

for _, col in ipairs({LeftColumn, RightColumn}) do
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = col
end

-- 6. Helper Functions
local ActiveTabButton = nil

local function CreateTabSection(title)
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Name = title .. "Section"
    SectionLabel.Size = UDim2.new(1, 0, 0, 16)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = string.upper(title)
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextSize = 9
    SectionLabel.TextColor3 = Color3.fromRGB(60, 68, 82)
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = TabContainer

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 6)
    Padding.Parent = SectionLabel

    return SectionLabel
end

local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 24)
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 31, 44)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = ""
    TabButton.AutoButtonColor = false
    TabButton.Parent = TabContainer

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = TabButton

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -12, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 11
    Title.TextColor3 = Color3.fromRGB(100, 110, 130)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TabButton

    TabButton.MouseButton1Click:Connect(function()
        if ActiveTabButton and ActiveTabButton ~= TabButton then
            TweenService:Create(ActiveTabButton, TweenInfoFast, {BackgroundTransparency = 1}):Play()
            TweenService:Create(ActiveTabButton:FindFirstChildOfClass("TextLabel"), TweenInfoFast, {TextColor3 = Color3.fromRGB(100, 110, 130)}):Play()
        end
        ActiveTabButton = TabButton
        ActiveTabTitle.Text = string.upper(name)
        TweenService:Create(TabButton, TweenInfoFast, {BackgroundTransparency = 0}):Play()
        TweenService:Create(Title, TweenInfoFast, {TextColor3 = Color3.fromRGB(240, 245, 255)}):Play()
    end)

    return TabButton
end

-- Populate Tabs
CreateTabSection("Main")
local DefaultTab = CreateTab("Ragebot")
CreateTab("Legitbot")

CreateTabSection("Visuals")
CreateTab("Visuals")
CreateTab("World")

CreateTabSection("Other")
CreateTab("Misc")
CreateTab("Settings")

-- Activate First Tab
ActiveTabButton = DefaultTab
DefaultTab.BackgroundTransparency = 0
DefaultTab:FindFirstChildOfClass("TextLabel").TextColor3 = Color3.fromRGB(240, 245, 255)

-- 7. Smooth Dragging Mechanism
local Dragging, DragInput, DragStart, StartPos

local function EnableDrag(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = MainWindow.Position
        end
    end)
end

EnableDrag(Header)
EnableDrag(Sidebar)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local Delta = input.Position - DragStart
        TweenService:Create(MainWindow, TweenInfoFast, {
            Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        }):Play()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)
