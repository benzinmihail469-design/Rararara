function NeverLose:CreateWindow(Config)
    Config = NeverLose:ProcessParams(Config, {
        Title = "NEVERLOSE",
        Size = Vector2.new(720, 500),
        ToggleKey = Enum.KeyCode.RightShift,
    })

    -- Главный контейнер
    local MainFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")

    -- Левый Сайдбар
    local Sidebar = Instance.new("Frame")
    local SidebarCorner = Instance.new("UICorner")
    local LogoLabel = Instance.new("TextLabel")
    local TabScroll = Instance.new("ScrollingFrame")
    local TabList = Instance.new("UIListLayout")
    local TabPadding = Instance.new("UIPadding")

    -- Верхняя панель (TopBar)
    local TopBar = Instance.new("Frame")
    local SaveBtn = Instance.new("TextButton")
    local SaveBtnCorner = Instance.new("UICorner")
    local SaveIcon = Instance.new("ImageLabel")
    local SaveLabel = Instance.new("TextLabel")
    
    local ActionHolder = Instance.new("Frame")
    local ActionList = Instance.new("UIListLayout")
    local SettingsIcon = Instance.new("ImageButton")
    local SearchIcon = Instance.new("ImageButton")

    -- Контейнер страниц
    local PageContainer = Instance.new("Frame")

    -- 1. Настройка MainFrame
    MainFrame.Name = NeverLose.RandomString()
    MainFrame.Parent = ScreenGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, Config.Size.X, 0, Config.Size.Y)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true

    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = MainFrame

    UIStroke.Color = Color3.fromRGB(28, 32, 42)
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.4
    UIStroke.Parent = MainFrame

    -- 2. Настройка Sidebar
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.Size = UDim2.new(0, 165, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(12, 15, 20)
    Sidebar.BorderSizePixel = 0

    SidebarCorner.CornerRadius = UDim.new(0, 6)
    SidebarCorner.Parent = Sidebar

    LogoLabel.Name = "Logo"
    LogoLabel.Parent = Sidebar
    LogoLabel.Position = UDim2.new(0, 16, 0, 16)
    LogoLabel.Size = UDim2.new(1, -32, 0, 22)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Text = Config.Title
    LogoLabel.Font = Enum.Font.GothamBold
    LogoLabel.TextSize = 17
    LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoLabel.TextXAlignment = Enum.TextXAlignment.Left

    TabScroll.Name = "TabScroll"
    TabScroll.Parent = Sidebar
    TabScroll.Position = UDim2.new(0, 0, 0, 52)
    TabScroll.Size = UDim2.new(1, 0, 1, -52)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0

    TabList.Parent = TabScroll
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 2)

    TabPadding.Parent = TabScroll
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)

    -- 3. Настройка TopBar
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.Position = UDim2.new(0, 165, 0, 0)
    TopBar.Size = UDim2.new(1, -165, 0, 48)
    TopBar.BackgroundTransparency = 1

    -- Кнопка Save
    SaveBtn.Name = "SaveButton"
    SaveBtn.Parent = TopBar
    SaveBtn.Position = UDim2.new(0, 12, 0, 11)
    SaveBtn.Size = UDim2.new(0, 68, 0, 26)
    SaveBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
    SaveBtn.Text = ""

    SaveBtnCorner.CornerRadius = UDim.new(0, 4)
    SaveBtnCorner.Parent = SaveBtn

    SaveIcon.Parent = SaveBtn
    SaveIcon.Position = UDim2.new(0, 8, 0.5, -6)
    SaveIcon.Size = UDim2.new(0, 12, 0, 12)
    SaveIcon.BackgroundTransparency = 1
    SaveIcon.Image = "rbxassetid://6031068426"
    SaveIcon.ImageColor3 = Color3.fromRGB(160, 170, 190)

    SaveLabel.Parent = SaveBtn
    SaveLabel.Position = UDim2.new(0, 26, 0, 0)
    SaveLabel.Size = UDim2.new(1, -26, 1, 0)
    SaveLabel.BackgroundTransparency = 1
    SaveLabel.Text = "Save"
    SaveLabel.Font = Enum.Font.GothamMedium
    SaveLabel.TextSize = 11
    SaveLabel.TextColor3 = Color3.fromRGB(180, 190, 205)
    SaveLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Правые иконки (Settings & Search)
    ActionHolder.Parent = TopBar
    ActionHolder.Position = UDim2.new(1, -65, 0, 15)
    ActionHolder.Size = UDim2.new(0, 50, 0, 18)
    ActionHolder.BackgroundTransparency = 1

    ActionList.Parent = ActionHolder
    ActionList.FillDirection = Enum.FillDirection.Horizontal
    ActionList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ActionList.SortOrder = Enum.SortOrder.LayoutOrder
    ActionList.Padding = UDim.new(0, 14)

    SettingsIcon.Parent = ActionHolder
    SettingsIcon.Size = UDim2.new(0, 16, 0, 16)
    SettingsIcon.BackgroundTransparency = 1
    SettingsIcon.Image = "rbxassetid://6031280882"
    SettingsIcon.ImageColor3 = Color3.fromRGB(120, 130, 150)

    SearchIcon.Parent = ActionHolder
    SearchIcon.Size = UDim2.new(0, 16, 0, 16)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = "rbxassetid://6031154871"
    SearchIcon.ImageColor3 = Color3.fromRGB(120, 130, 150)

    -- 4. Настройка PageContainer
    PageContainer.Name = "PageContainer"
    PageContainer.Parent = MainFrame
    PageContainer.Position = UDim2.new(0, 175, 0, 48)
    PageContainer.Size = UDim2.new(1, -185, 1, -58)
    PageContainer.BackgroundTransparency = 1

    -- Логика перетаскивания (Drag)
    local Dragging, DragStart, StartPos
    local function UpdateDrag(input)
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end

    local function BindDrag(frame)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPos = MainFrame.Position
            end
        end)
    end

    BindDrag(Sidebar)
    BindDrag(TopBar)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateDrag(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)

    -- Горячая клавиша скрытия
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Config.ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    return {
        MainFrame = MainFrame,
        Sidebar = Sidebar,
        TabScroll = TabScroll,
        PageContainer = PageContainer,
        SaveButton = SaveBtn,
        SettingsButton = SettingsIcon,
        SearchButton = SearchIcon
    }
end
