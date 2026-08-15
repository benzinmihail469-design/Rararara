-- KITI UI Custom Script (Pure Roblox Instance Creation)
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KitiUI_Custom"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Colors & Constants
local COLOR_BG = Color3.fromRGB(12, 12, 15)
local COLOR_SIDEBAR = Color3.fromRGB(16, 16, 20)
local COLOR_CARD = Color3.fromRGB(20, 20, 26)
local COLOR_ELEMENT = Color3.fromRGB(28, 28, 36)
local COLOR_TEXT = Color3.fromRGB(220, 220, 230)
local COLOR_SUBTEXT = Color3.fromRGB(120, 120, 140)
local COLOR_ACCENT = Color3.fromRGB(65, 130, 255)
local COLOR_TOGGLE_OFF = Color3.fromRGB(60, 60, 70)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 720, 0, 480)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
MainFrame.BackgroundColor3 = COLOR_BG
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 45)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

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
        updateDrag(input)
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = COLOR_SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Title Box
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0, 60)
TitleFrame.BackgroundTransparency = 1
TitleFrame.Parent = Sidebar

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, -20, 0, 24)
LogoText.Position = UDim2.new(0, 15, 0, 12)
LogoText.Text = "KITI"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.TextSize = 20
LogoText.Font = Enum.Font.GothamBold
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.BackgroundTransparency = 1
LogoText.Parent = TitleFrame

local SubtitleText = Instance.new("TextLabel")
SubtitleText.Size = UDim2.new(1, -20, 0, 16)
SubtitleText.Position = UDim2.new(0, 15, 0, 34)
SubtitleText.Text = "TГK - t.me/KITI_RBB"
SubtitleText.TextColor3 = COLOR_SUBTEXT
SubtitleText.TextSize = 10
SubtitleText.Font = Enum.Font.Gotham
SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
SubtitleText.BackgroundTransparency = 1
SubtitleText.Parent = TitleFrame

-- Profile Box (Bottom Sidebar)
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(1, -20, 0, 45)
ProfileFrame.Position = UDim2.new(0, 10, 1, -55)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
ProfileFrame.Parent = Sidebar

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 8)
ProfileCorner.Parent = ProfileFrame

local ProfileName = Instance.new("TextLabel")
ProfileName.Size = UDim2.new(1, -30, 0, 18)
ProfileName.Position = UDim2.new(0, 10, 0, 6)
ProfileName.Text = LocalPlayer and LocalPlayer.Name or "ayaka"
ProfileName.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfileName.Font = Enum.Font.GothamBold
ProfileName.TextSize = 12
ProfileName.TextXAlignment = Enum.TextXAlignment.Left
ProfileName.BackgroundTransparency = 1
ProfileName.Parent = ProfileFrame

local ProfileSub = Instance.new("TextLabel")
ProfileSub.Size = UDim2.new(1, -30, 0, 14)
ProfileSub.Position = UDim2.new(0, 10, 0, 24)
ProfileSub.Text = "Never"
ProfileSub.TextColor3 = COLOR_SUBTEXT
ProfileSub.Font = Enum.Font.Gotham
ProfileSub.TextSize = 10
ProfileSub.TextXAlignment = Enum.TextXAlignment.Left
ProfileSub.BackgroundTransparency = 1
ProfileSub.Parent = ProfileFrame

-- Navigation Menu List
local TabHolder = Instance.new("ScrollingFrame")
TabHolder.Size = UDim2.new(1, 0, 1, -125)
TabHolder.Position = UDim2.new(0, 0, 0, 60)
TabHolder.BackgroundTransparency = 1
TabHolder.ScrollBarThickness = 0
TabHolder.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabHolder

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 10)
TabPadding.PaddingRight = UDim.new(0, 10)
TabPadding.Parent = TabHolder

-- Content Area (Right Side)
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -180, 1, 0)
ContentArea.Position = UDim2.new(0, 180, 0, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Top Bar inside Content Area
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1
TopBar.Parent = ContentArea

local ConfigSelect = Instance.new("TextButton")
ConfigSelect.Size = UDim2.new(0, 120, 0, 28)
ConfigSelect.Position = UDim2.new(0, 15, 0, 10)
ConfigSelect.BackgroundColor3 = COLOR_CARD
ConfigSelect.Text = "  💾 Default  ▼"
ConfigSelect.TextColor3 = COLOR_TEXT
ConfigSelect.Font = Enum.Font.Gotham
ConfigSelect.TextSize = 11
ConfigSelect.TextXAlignment = Enum.TextXAlignment.Left
ConfigSelect.Parent = TopBar

local ConfigCorner = Instance.new("UICorner")
ConfigCorner.CornerRadius = UDim.new(0, 6)
ConfigCorner.Parent = ConfigSelect

-- Pages Container
local PagesFolder = Instance.new("Folder")
PagesFolder.Name = "Pages"
PagesFolder.Parent = ContentArea

local Tabs = {}
local ActiveTab = nil

-- UI Component Builder Helpers
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, -30, 1, -55)
    Page.Position = UDim2.new(0, 15, 0, 45)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = COLOR_SUBTEXT
    Page.Visible = false
    Page.Parent = PagesFolder

    local PageLayout = Instance.new("UIGridLayout")
    PageLayout.CellSize = UDim2.new(0.485, 0, 0, 200)
    PageLayout.CellPadding = UDim2.new(0.03, 0, 0, 12)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = Page

    return Page
end

local function AddTab(name, icon)
    local Page = CreatePage(name)

    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 34)
    TabButton.BackgroundColor3 = COLOR_SIDEBAR
    TabButton.Text = "    " .. (icon or "⚙") .. "   " .. name
    TabButton.TextColor3 = COLOR_SUBTEXT
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.TextSize = 12
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = TabHolder

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = TabButton

    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Button.BackgroundColor3 = COLOR_SIDEBAR
            tab.Button.TextColor3 = COLOR_SUBTEXT
            tab.Page.Visible = false
        end
        TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        Page.Visible = true
    end)

    table.insert(Tabs, {Button = TabButton, Page = Page})

    if #Tabs == 1 then
        TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        Page.Visible = true
    end

    return Page
end

local function CreateSection(page, title)
    local Section = Instance.new("Frame")
    Section.BackgroundColor3 = COLOR_CARD
    Section.Parent = page

    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 8)
    SectionCorner.Parent = Section

    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, -20, 0, 25)
    SectionTitle.Position = UDim2.new(0, 10, 0, 5)
    SectionTitle.Text = title
    SectionTitle.TextColor3 = COLOR_SUBTEXT
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextSize = 10
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Parent = Section

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 1, -30)
    Container.Position = UDim2.new(0, 10, 0, 30)
    Container.BackgroundTransparency = 1
    Container.Parent = Section

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout.Parent = Container

    return Container
end

-- Controls (Toggle, Button, Input)
local function CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 26)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -45, 1, 0)
    Label.Text = text
    Label.TextColor3 = COLOR_TEXT
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 36, 0, 18)
    Switch.Position = UDim2.new(1, -36, 0.5, -9)
    Switch.BackgroundColor3 = default and COLOR_ACCENT or COLOR_TOGGLE_OFF
    Switch.Text = ""
    Switch.Parent = Frame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.Parent = Switch

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    local toggled = default
    Switch.MouseButton1Click:Connect(function()
        toggled = not toggled
        local targetColor = toggled and COLOR_ACCENT or COLOR_TOGGLE_OFF
        local targetPos = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = targetPos}):Play()

        if callback then callback(toggled) end
    end)
end

local function CreateInput(parent, text, defaultVal, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 26)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Text = text
    Label.TextColor3 = COLOR_TEXT
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.38, 0, 0, 20)
    TextBox.Position = UDim2.new(0.62, 0, 0.5, -10)
    TextBox.BackgroundColor3 = COLOR_ELEMENT
    TextBox.Text = tostring(defaultVal or "")
    TextBox.TextColor3 = COLOR_TEXT
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 10
    TextBox.Parent = Frame

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = TextBox

    TextBox.FocusLost:Connect(function()
        if callback then callback(TextBox.Text) end
    end)
end

local function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 24)
    Button.BackgroundColor3 = COLOR_ELEMENT
    Button.Text = text
    Button.TextColor3 = COLOR_TEXT
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 11
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

-- POPULATE TABS & SECTIONS (Matching Screenshots)

-- 1. General Tab
local GeneralPage = AddTab("General", "⚙")
local FlySection = CreateSection(GeneralPage, "Fly")
CreateToggle(FlySection, "OP Fly", false)
CreateInput(FlySection, "Fly Speed", "50")

local MovementSection = CreateSection(GeneralPage, "Movement")
CreateInput(MovementSection, "Walkspeed", "16")
CreateInput(MovementSection, "FOV", "100")
CreateToggle(MovementSection, "CTRL+Click TP", true)

local MiscSection = CreateSection(GeneralPage, "Misc")
CreateButton(MiscSection, "⚡ FPS Boost")
CreateButton(MiscSection, "📈 Get Ping")
CreateButton(MiscSection, "🔄 Rejoin")
CreateToggle(MiscSection, "AntiFling", false)

-- 2. MM2 Tab
local MM2Page = AddTab("MM2", "🎯")
local EspSection = CreateSection(MM2Page, "ESP")
CreateToggle(EspSection, "Players", false)
CreateToggle(EspSection, "Dropped Gun", true)
CreateToggle(EspSection, "Traps", true)

local MurdererSection = CreateSection(MM2Page, "Murderer")
CreateButton(MurdererSection, "🗡 Knife Throw to Nearest")
CreateToggle(MurdererSection, "Auto Knife Throw", false)
CreateButton(MurdererSection, "⚔ Kill Nearest")

-- 3. Visuals Tab
local VisualsPage = AddTab("Visuals", "👁")
local GunModelSec = CreateSection(VisualsPage, "Gun Model")
CreateToggle(GunModelSec, "Custom Model", true)

local EffectsSec = CreateSection(VisualsPage, "Effects")
CreateToggle(EffectsSec, "Trails", true)
CreateToggle(EffectsSec, "Magic Aura", false)
CreateToggle(EffectsSec, "Shader (RTX)", true)

-- 4. Other Tabs
AddTab("Target", "👤")
AddTab("Fun", "⭐")
AddTab("Emotes", "🏃")
AddTab("Sound", "🔊")
AddTab("Configs", "📁")

print("KITI UI Loaded Successfully!")
