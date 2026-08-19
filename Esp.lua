local UserInputService = game:GetService("UserInputService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local gethui = gethui or function()
    return CoreGui
end

local FontSemiBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

-- Создаем основной ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkHub_UI"
ScreenGui.Parent = gethui()
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 677, 0, 500)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDimNew(0, 8)
MainCorner.Parent = MainFrame

-- Верхняя панель (Шапка)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDimNew(0, 8)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.FontFace = FontSemiBold
TitleLabel.Text = "DARK HUB"
TitleLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.BackgroundTransparency = 1

-- Левое меню вкладок
local LeftTabs = Instance.new("ScrollingFrame")
LeftTabs.Name = "LeftTabs"
LeftTabs.Parent = MainFrame
LeftTabs.Position = UDim2.new(0, 0, 0, 45)
LeftTabs.Size = UDim2.new(0, 180, 1, -45)
LeftTabs.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
LeftTabs.BorderSizePixel = 0
LeftTabs.ScrollBarThickness = 0

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.Parent = LeftTabs
TabsLayout.Padding = UDim.new(0, 6)
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local TabsPadding = Instance.new("UIPadding")
TabsPadding.Parent = LeftTabs
TabsPadding.PaddingTop = UDim.new(0, 10)
TabsPadding.PaddingLeft = UDim.new(0, 10)
TabsPadding.PaddingRight = UDim.new(0, 10)

-- Контейнер для страниц
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = MainFrame
Content.Position = UDim2.new(0, 180, 0, 45)
Content.Size = UDim2.new(1, -180, 1, -45)
Content.BackgroundTransparency = 1

-- Функционал управления окном
local ActivePage = nil

-- Функция добавления текста-категории в меню слева
local function AddTabSection(text)
    local Label = Instance.new("TextLabel")
    Label.Parent = LeftTabs
    Label.FontFace = FontSemiBold
    Label.Text = text:upper()
    Label.TextColor3 = Color3.fromRGB(110, 110, 115)
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
end

-- Функция создания новой вкладки
local function CreatePage(name)
    local Page = {}
    
    -- Кнопка в меню
    local TabButton = Instance.new("TextButton")
    TabButton.Parent = LeftTabs
    TabButton.FontFace = FontSemiBold
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 185)
    TabButton.TextSize = 13
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Size = UDim2.new(1, 0, 0, 30)
    TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    TabButton.BackgroundTransparency = 1
    TabButton.AutoButtonColor = false

    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent = TabButton
    TabPadding.PaddingLeft = UDim.new(0, 10)

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 5)
    TabCorner.Parent = TabButton

    -- Контейнер содержимого вкладки
    local PageContainer = Instance.new("ScrollingFrame")
    PageContainer.Parent = Content
    PageContainer.Size = UDim2.new(1, -20, 1, -20)
    PageContainer.Position = UDim2.new(0, 10, 0, 10)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Visible = false
    PageContainer.ScrollBarThickness = 2
    PageContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 116, 224)
    PageContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- Две колонки (Левая и Правая)
    local LeftColumn = Instance.new("Frame")
    LeftColumn.Parent = PageContainer
    LeftColumn.Size = UDim2.new(0.49, 0, 1, 0)
    LeftColumn.BackgroundTransparency = 1

    local RightColumn = Instance.new("Frame")
    RightColumn.Parent = PageContainer
    RightColumn.Position = UDim2.new(0.51, 0, 0, 0)
    RightColumn.Size = UDim2.new(0.49, 0, 1, 0)
    RightColumn.BackgroundTransparency = 1

    local LeftLayout = Instance.new("UIListLayout")
    LeftLayout.Parent = LeftColumn
    LeftLayout.Padding = UDim.new(0, 10)

    local RightLayout = Instance.new("UIListLayout")
    RightLayout.Parent = RightColumn
    RightLayout.Padding = UDim.new(0, 10)

    -- Функция переключения
    local function Select()
        if ActivePage then
            ActivePage.Container.Visible = false
            ActivePage.Button.BackgroundTransparency = 1
            ActivePage.Button.TextColor3 = Color3.fromRGB(180, 180, 185)
        end
        PageContainer.Visible = true
        TabButton.BackgroundTransparency = 0
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActivePage = { Container = PageContainer, Button = TabButton }
    end

    TabButton.MouseButton1Click:Connect(Select)

    -- Функция создания секции внутри страницы
    function Page:Section(title, side)
        local Target = (side == "Right" and RightColumn) or LeftColumn

        local SectionBox = Instance.new("Frame")
        SectionBox.Parent = Target
        SectionBox.Size = UDim2.new(1, 0, 0, 0)
        SectionBox.AutomaticSize = Enum.AutomaticSize.Y
        SectionBox.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
        SectionBox.BorderSizePixel = 0

        local SecCorner = Instance.new("UICorner")
        SecCorner.CornerRadius = UDim.new(0, 6)
        SecCorner.Parent = SectionBox

        local SecTopBar = Instance.new("Frame")
        SecTopBar.Parent = SectionBox
        SecTopBar.Size = UDim2.new(1, 0, 0, 26)
        SecTopBar.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
        SecTopBar.BorderSizePixel = 0

        local SecTopCorner = Instance.new("UICorner")
        SecTopCorner.CornerRadius = UDim.new(0, 6)
        SecTopCorner.Parent = SecTopBar

        local SecTitle = Instance.new("TextLabel")
        SecTitle.Parent = SecTopBar
        SecTitle.FontFace = FontSemiBold
        SecTitle.Text = title
        SecTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
        SecTitle.TextSize = 12
        SecTitle.TextXAlignment = Enum.TextXAlignment.Left
        SecTitle.Position = UDim2.new(0, 10, 0, 0)
        SecTitle.Size = UDim2.new(1, -10, 1, 0)
        SecTitle.BackgroundTransparency = 1

        local ElementsHolder = Instance.new("Frame")
        ElementsHolder.Name = "Elements"
        ElementsHolder.Parent = SectionBox
        ElementsHolder.Position = UDim2.new(0, 0, 0, 26)
        ElementsHolder.Size = UDim2.new(1, 0, 0, 0)
        ElementsHolder.AutomaticSize = Enum.AutomaticSize.Y
        ElementsHolder.BackgroundTransparency = 1

        local ElLayout = Instance.new("UIListLayout")
        ElLayout.Parent = ElementsHolder
        ElLayout.Padding = UDim.new(0, 6)

        local ElPadding = Instance.new("UIPadding")
        ElPadding.Parent = ElementsHolder
        ElPadding.PaddingTop = UDim.new(0, 8)
        ElPadding.PaddingBottom = UDim.new(0, 8)
        ElPadding.PaddingLeft = UDim.new(0, 10)
        ElPadding.PaddingRight = UDim.new(0, 10)

        return ElementsHolder
    end

    if not ActivePage then
        Select()
    end

    return Page
end

