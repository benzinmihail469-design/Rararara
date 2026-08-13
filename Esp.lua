local DarkHub = {} -- Dark Hub UI (Pulse Hub Styled Sizes - Compact)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera

local IsMobile = UserInputService.TouchEnabled

-- === ОБНОВЛЕННЫЕ НАСТРОЙКИ РАЗМЕРОВ ГУИ ===
local MainWidth = IsMobile and 530 or 570     -- Ширина главного окна
local MainHeight = IsMobile and 320 or 340    -- Высота главного окна
local SidebarWidth = IsMobile and 140 or 150  -- Ширина боковой панели
local HeaderHeight = 36                       -- Высота шапки
local FooterHeight = 42                       -- Высота подвала с профилем

-- Функция авто-форматирования ID иконки
local function GetIconUri(Icon)
    if not Icon or Icon == "" then return "" end
    local StrIcon = tostring(Icon)
    if string.find(StrIcon, "rbxthumb://") then
        return StrIcon
    end
    local Id = string.match(StrIcon, "%d+")
    if Id then
        return "rbxthumb://type=Asset&id=" .. Id .. "&w=150&h=150"
    end
    return StrIcon
end

-- Иконка для Dark Hub рядом с заголовком
local DarkHubIcon = GetIconUri("91508433366374")

-- Вспомогательные функции
local function Create(Class, Properties)
    local Instance = Instance.new(Class)
    for Property, Value in pairs(Properties) do
        Instance[Property] = Value
    end
    return Instance
end

local function CreateTween(Instance, Info, Goal)
    local Tween = TweenService:Create(Instance, Info, Goal)
    Tween:Play()
    return Tween
end

-- Функция очистки строк
local function CleanString(Str)
    if not Str then return "" end
    local Cleaned = string.lower(tostring(Str))
    Cleaned = string.gsub(Cleaned, "[%s%p]", "")
    return Cleaned
end

-- Цветовая схема (AMOLED Black)
local Theme = {
    Background = Color3.fromRGB(0, 0, 0),
    Background2 = Color3.fromRGB(5, 5, 5),
    SectionBackground = Color3.fromRGB(6, 6, 6),
    SectionBackground2 = Color3.fromRGB(10, 10, 10),
    SectionTop = Color3.fromRGB(16, 16, 16),
    Element = Color3.fromRGB(12, 12, 12),
    Outline = Color3.fromRGB(22, 22, 22),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(0, 116, 224),
    AccentGradient = Color3.fromRGB(0, 195, 255),
}

-- Шрифты
local FontSemiBold = Font.fromEnum(Enum.Font.FredokaOne)
local FontRegular = Font.fromEnum(Enum.Font.FredokaOne)

-- Холдер
local Holder = Create("ScreenGui", {
    Parent = CoreGui,
    Name = "DarkHub",
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    DisplayOrder = 2,
    ResetOnSpawn = false,
})

-- Контейнер для уведомлений
local NotificationHolder = Create("Frame", {
    Parent = Holder,
    Name = "Notifications",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 0, 1, 0),
    AutomaticSize = Enum.AutomaticSize.X,
    BorderSizePixel = 0,
})

local NotificationLayout = Create("UIListLayout", {
    Parent = NotificationHolder,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

Create("UIPadding", {
    Parent = NotificationHolder,
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 8),
})

-- Список флагов
local Flags = {}
local SetFlags = {}

-- === ГЛАВНОЕ ОКНО ===
local MainFrame = Create("Frame", {
    Parent = Holder,
    Name = "MainFrame",
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0, MainWidth, 0, MainHeight),
    ClipsDescendants = false,
})

Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 10) })

-- Затемнение фона (Blur)
do
    local BlurPart = Create("Part", {
        Parent = Camera,
        Material = Enum.Material.Glass,
        Transparency = 1,
        Reflectance = 1,
        CastShadow = false,
        Anchored = true,
        CanCollide = false,
        CanQuery = false,
        Size = Vector3.new(1, 1, 1) * 0.01,
        Color = Color3.new(0, 0, 0),
    })
    
    local BlockMesh = Create("BlockMesh", { Parent = BlurPart })
    
    Create("DepthOfFieldEffect", {
        Parent = Lighting,
        Enabled = true,
        FarIntensity = 0,
        FocusDistance = 0,
        InFocusRadius = 1000,
        NearIntensity = 1,
    })
    
    RunService.RenderStepped:Connect(function()
        if MainFrame.Visible then
            local Corner0 = MainFrame.AbsolutePosition
            local Corner1 = Corner0 + MainFrame.AbsoluteSize
            
            local Ray0 = Camera:ScreenPointToRay(Corner0.X, Corner0.Y, 1)
            local Ray1 = Camera:ScreenPointToRay(Corner1.X, Corner1.Y, 1)
            
            local Origin = Camera.CFrame.Position + Camera.CFrame.LookVector * (0.05 - Camera.NearPlaneZ)
            local Normal = Camera.CFrame.LookVector
            
            local function GetPlanePosition(RayOrigin, RayDirection)
                local N = Normal
                local D = RayDirection
                local V = RayOrigin - Origin
                local Number = (N.X * V.X) + (N.Y * V.Y) + (N.Z * V.Z)
                local Den = (N.X * D.X) + (N.Y * D.Y) + (N.Z * D.Z)
                local A = -Number / Den
                return RayOrigin + (A * RayDirection)
            end
            
            local Position0 = GetPlanePosition(Ray0.Origin, Ray0.Direction)
            local Position1 = GetPlanePosition(Ray1.Origin, Ray1.Direction)
            
            Position0 = Camera.CFrame:PointToObjectSpace(Position0)
            Position1 = Camera.CFrame:PointToObjectSpace(Position1)
            
            local Size = Position1 - Position0
            local Center = (Position0 + Position1) / 2
            
            BlockMesh.Offset = Center
            BlockMesh.Scale = Size / 0.0101
            BlurPart.CFrame = Camera.CFrame
            BlurPart.Transparency = 0.97
        end
    end)
end

-- ИКОНКА В ГЛАВНОМ ОКНЕ
local Logo = Create("ImageLabel", {
    Parent = MainFrame,
    Name = "Logo",
    ImageColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(0, 8, 0, 5),
    Image = DarkHubIcon,
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 5,
})

Create("TextLabel", {
    Parent = MainFrame,
    Name = "Title",
    Text = "Dark Hub",
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    FontFace = FontSemiBold,
    TextSize = 12,
    Position = UDim2.new(0, 40, 0, 5),
    Size = UDim2.new(0, 0, 0, 13),
    AutomaticSize = Enum.AutomaticSize.X,
    ZIndex = 5,
})

Create("TextLabel", {
    Parent = MainFrame,
    Name = "SubTitle",
    Text = "Premium Cheat",
    TextColor3 = Theme.Text,
    TextTransparency = 0.4,
    BackgroundTransparency = 1,
    FontFace = FontRegular,
    TextSize = 9,
    Position = UDim2.new(0, 40, 0, 18),
    Size = UDim2.new(0, 0, 0, 11),
    AutomaticSize = Enum.AutomaticSize.X,
    ZIndex = 5,
})

-- КНОПКА ЗАКРЫТИЯ
local CloseButton = Create("TextButton", {
    Parent = MainFrame,
    Text = "",
    AutoButtonColor = false,
    BackgroundColor3 = Theme.Element,
    BackgroundTransparency = 0.2,
    Position = UDim2.new(1, -8, 0, 5),
    AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.new(0, 26, 0, 26),
    ZIndex = 5,
})

Create("UICorner", { Parent = CloseButton, CornerRadius = UDim.new(0, 6) })

local CloseText = Create("TextLabel", {
    Parent = CloseButton,
    Text = "×",
    TextColor3 = Theme.Text,
    TextTransparency = 0.3,
    BackgroundTransparency = 1,
    FontFace = FontSemiBold,
    TextSize = 20,
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0.5, 0, 0.5, -1),
    AnchorPoint = Vector2.new(0.5, 0.5),
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    ZIndex = 6,
})

local CloseAccent = Create("Frame", {
    Parent = CloseButton,
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
})

Create("UICorner", { Parent = CloseAccent, CornerRadius = UDim.new(0, 6) })

Create("UIGradient", {
    Parent = CloseAccent,
    Rotation = -115,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentGradient),
    })
})

CloseButton.MouseEnter:Connect(function()
    CreateTween(CloseAccent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0,
    })
    CloseText.TextTransparency = 0
end)

CloseButton.MouseLeave:Connect(function()
    CreateTween(CloseAccent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    })
    CloseText.TextTransparency = 0.3
end)

CloseButton.MouseButton1Down:Connect(function()
    MainFrame.Visible = false
end)

-- ПОЛЕ ПОИСКА В ШАПКЕ
local HeaderSearchContainer = Create("Frame", {
    Parent = MainFrame,
    Name = "HeaderSearch",
    BackgroundColor3 = Theme.Element,
    BackgroundTransparency = 0.2,
    Position = UDim2.new(1, -40, 0, 5),
    AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.new(0, 130, 0, 26),
    ZIndex = 5,
})

Create("UICorner", { Parent = HeaderSearchContainer, CornerRadius = UDim.new(0, 6) })

local HeaderSearchInput = Create("TextBox", {
    Parent = HeaderSearchContainer,
    Text = "",
    PlaceholderText = "Search...",
    PlaceholderColor3 = Color3.fromRGB(130, 130, 130),
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 0),
    Size = UDim2.new(1, -12, 1, 0),
    FontFace = FontRegular,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 6,
})

-- Левая панель вкладок (Сайдбар)
local LeftTabs = Create("ScrollingFrame", {
    Parent = MainFrame,
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.1,
    Size = UDim2.new(0, SidebarWidth, 1, -FooterHeight),
    Position = UDim2.new(0, 0, 0, 0),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
})

Create("UICorner", { Parent = LeftTabs, CornerRadius = UDim.new(0, 10) })

Create("UIListLayout", {
    Parent = LeftTabs,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

Create("UIPadding", {
    Parent = LeftTabs,
    PaddingTop = UDim.new(0, HeaderHeight + 4),
    PaddingBottom = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
})

-- ПОДВАЛ (ПРОФИЛЬ ИГРОКА)
local ProfileFooter = Create("Frame", {
    Parent = MainFrame,
    Name = "ProfileFooter",
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    Size = UDim2.new(0, SidebarWidth, 0, FooterHeight),
    Position = UDim2.new(0, 0, 1, -FooterHeight),
    BorderSizePixel = 0,
    ZIndex = 8,
})

Create("UICorner", { Parent = ProfileFooter, CornerRadius = UDim.new(0, 10) })

Create("Frame", {
    Parent = ProfileFooter,
    BackgroundColor3 = Theme.Outline,
    BackgroundTransparency = 0.4,
    Size = UDim2.new(1, -12, 0, 1),
    Position = UDim2.new(0.5, 0, 0, 0),
    AnchorPoint = Vector2.new(0.5, 0),
    BorderSizePixel = 0,
})

local AvatarImage = Create("ImageLabel", {
    Parent = ProfileFooter,
    Name = "Avatar",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(0, 8, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
    ZIndex = 9,
})

Create("UICorner", { Parent = AvatarImage, CornerRadius = UDim.new(1, 0) })

Create("TextLabel", {
    Parent = ProfileFooter,
    Name = "Username",
    Text = LocalPlayer.DisplayName,
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    FontFace = FontSemiBold,
    TextSize = 11,
    Position = UDim2.new(0, 40, 0.5, -6),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.new(0, SidebarWidth - 60, 0, 12),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 9,
})

Create("TextLabel", {
    Parent = ProfileFooter,
    Name = "Subtext",
    Text = "@" .. LocalPlayer.Name,
    TextColor3 = Theme.Text,
    TextTransparency = 0.5,
    BackgroundTransparency = 1,
    FontFace = FontRegular,
    TextSize = 9,
    Position = UDim2.new(0, 40, 0.5, 6),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.new(0, SidebarWidth - 60, 0, 10),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 9,
})

local ArrowIcon = Create("ImageLabel", {
    Parent = ProfileFooter,
    Name = "Arrow",
    Image = GetIconUri("130510492706892"),
    ImageColor3 = Theme.Text,
    ImageTransparency = 0.5,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 8, 0, 8),
    Position = UDim2.new(1, -10, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    Rotation = -90,
    ZIndex = 9,
})

local ActiveIndicator = Create("Frame", {
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(0, 3, 0, 19),
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 6, 0, 0),
    Visible = false,
    BorderSizePixel = 0,
    ZIndex = 10,
})

Create("UICorner", { Parent = ActiveIndicator, CornerRadius = UDim.new(1, 0) })

-- Контентная зона
local Content = Create("Frame", {
    Parent = MainFrame,
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.5,
    Position = UDim2.new(0, SidebarWidth, 0, HeaderHeight),
    Size = UDim2.new(1, -SidebarWidth, 1, -HeaderHeight),
    BorderSizePixel = 0,
    ClipsDescendants = true,
})

Create("UICorner", { Parent = Content, CornerRadius = UDim.new(0, 10) })

-- Контейнер для результатов глобального поиска
local GlobalSearchFrame = Create("ScrollingFrame", {
    Parent = Content,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ScrollBarThickness = 3,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Visible = false,
    BorderSizePixel = 0,
    VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
})

Create("UICorner", { Parent = GlobalSearchFrame, CornerRadius = UDim.new(0, 10) })

local GlobalSearchContent = Create("Frame", {
    Parent = GlobalSearchFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -10, 0, 0),
    Position = UDim2.new(0, 5, 0, 5),
    AutomaticSize = Enum.AutomaticSize.Y,
})

Create("UIListLayout", {
    Parent = GlobalSearchContent,
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

-- Страницы
local Pages = {}
local CurrentPage = nil

-- Глобальная система поиска
local function GlobalSearch(Query)
    local CleanQuery = CleanString(Query)

    if CleanQuery == "" then
        GlobalSearchFrame.Visible = false
        
        for _, Page in ipairs(Pages) do
            for _, Section in ipairs(Page.Sections) do
                Section.Frame.Parent = Section.OriginalParent
                Section.Frame.Visible = true
                for _, Element in ipairs(Section.Elements) do
                    if Element.Frame then
                        Element.Frame.Visible = true
                    end
                end
            end
        end

        if CurrentPage then
            CurrentPage.Frame.Visible = true
        end
    else
        if CurrentPage then
            CurrentPage.Frame.Visible = false
        end
        GlobalSearchFrame.Visible = true

        for _, Page in ipairs(Pages) do
            for _, Section in ipairs(Page.Sections) do
                local CleanSectionName = CleanString(Section.Name)
                local SectionMatch = (CleanSectionName ~= "") and (string.find(CleanSectionName, CleanQuery, 1, true) ~= nil)
                local HasAnyElementMatch = false

                for _, Element in ipairs(Section.Elements) do
                    local CleanElementName = CleanString(Element.Name)
                    local ElementMatch = (CleanElementName ~= "") and (string.find(CleanElementName, CleanQuery, 1, true) ~= nil)
                    local IsVisible = SectionMatch or ElementMatch

                    if Element.Frame then
                        Element.Frame.Visible = IsVisible
                    end

                    if IsVisible then
                        HasAnyElementMatch = true
                    end
                end

                if SectionMatch or HasAnyElementMatch then
                    Section.Frame.Parent = GlobalSearchContent
                    Section.Frame.Visible = true
                else
                    Section.Frame.Visible = false
                    Section.Frame.Parent = Section.OriginalParent
                end
            end
        end
    end
end

HeaderSearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    GlobalSearch(HeaderSearchInput.Text)
end)

local function CreatePage(PageConfig)
    local PageName = PageConfig.Name or "Page"
    local PageIcon = PageConfig.Icon or "100050851789190"
    
    local TabButton = Create("TextButton", {
        Parent = LeftTabs,
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    
    Create("UICorner", { Parent = TabButton, CornerRadius = UDim.new(0, 8) })
    
    local TabIcon = Create("ImageLabel", {
        Parent = TabButton,
        Image = GetIconUri(PageIcon),
        ImageColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
    })
    
    local TabLabel = Create("TextLabel", {
        Parent = TabButton,
        Text = PageName,
        TextColor3 = Theme.Text,
        TextTransparency = 0.5,
        BackgroundTransparency = 1,
        FontFace = FontRegular,
        TextSize = 11,
        Position = UDim2.new(0, 36, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, -52, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local DotsContainer = Create("Frame", {
        Parent = TabButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 3, 0, 13),
        BorderSizePixel = 0,
    })

    Create("UIListLayout", {
        Parent = DotsContainer,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    for i = 1, 3 do
        local Dot = Create("Frame", {
            Parent = DotsContainer,
            BackgroundColor3 = Theme.Text,
            BackgroundTransparency = 0.6,
            Size = UDim2.new(0, 3, 0, 3),
            BorderSizePixel = 0,
            LayoutOrder = i,
        })
        Create("UICorner", { Parent = Dot, CornerRadius = UDim.new(1, 0) })
    end
    
    local PageFrame = Create("ScrollingFrame", {
        Parent = Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        BorderSizePixel = 0,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
    })
    
    Create("UICorner", { Parent = PageFrame, CornerRadius = UDim.new(0, 10) })
    
    local PageContent = Create("Frame", {
        Parent = PageFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 0),
        Position = UDim2.new(0, 5, 0, 5),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    
    Create("UIListLayout", {
        Parent = PageContent,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    local PageData = {
        Name = PageName,
        Frame = PageFrame,
        Content = PageContent,
        TabButton = TabButton,
        TabLabel = TabLabel,
        Sections = {},
        Active = false,
    }
    
    TabButton.MouseEnter:Connect(function()
        if not PageData.Active then
            CreateTween(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.92
            })
            CreateTween(TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 0.25
            })
        end
    end)

    TabButton.MouseLeave:Connect(function()
        if not PageData.Active then
            CreateTween(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            })
            CreateTween(TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 0.5
            })
        end
    end)
    
    local function SetActive(Active)
        if Active == PageData.Active and not GlobalSearchFrame.Visible then return end
        
        if HeaderSearchInput.Text ~= "" then
            HeaderSearchInput.Text = ""
        end

        if Active then
            if CurrentPage then
                CurrentPage.Active = false
                CurrentPage.Frame.Visible = false
                CreateTween(CurrentPage.TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                })
                CreateTween(CurrentPage.TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    TextTransparency = 0.5
                })
                CurrentPage.TabLabel.FontFace = FontRegular
            end
            
            PageData.Active = true
            PageData.Frame.Visible = true
            CreateTween(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.88
            })
            CreateTween(TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 0
            })
            PageData.TabLabel.FontFace = FontSemiBold
            CurrentPage = PageData

            task.defer(function()
                local TargetY = TabButton.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y + (TabButton.AbsoluteSize.Y / 2)
                local TargetPos = UDim2.new(0, 6, 0, TargetY)

                if not ActiveIndicator.Visible then
                    ActiveIndicator.Position = TargetPos
                    ActiveIndicator.Visible = true
                else
                    CreateTween(ActiveIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Position = TargetPos
                    })
                end
            end)
        else
            PageData.Active = false
            PageData.Frame.Visible = false
            CreateTween(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            })
            CreateTween(TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextTransparency = 0.5
            })
            PageData.TabLabel.FontFace = FontRegular
        end
    end
    
    TabButton.MouseButton1Down:Connect(function()
        SetActive(true)
    end)
    
    PageData.SetActive = SetActive
    
    local function CreateSection(SectionConfig)
        local SectionName = SectionConfig.Name or "Section"
        local SectionDesc = SectionConfig.Description or ""
        
        local SectionFrame = Create("Frame", {
            Parent = PageContent,
            BackgroundColor3 = Theme.SectionBackground2,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = false,
            BorderSizePixel = 0,
        })
        
        Create("UICorner", { Parent = SectionFrame, CornerRadius = UDim.new(0, 8) })
        
        local SectionTop = Create("Frame", {
            Parent = SectionFrame,
            BackgroundColor3 = Theme.Outline,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, 26),
            BorderSizePixel = 0,
        })
        
        Create("UICorner", { Parent = SectionTop, CornerRadius = UDim.new(0, 8) })

        local SectionTopBg = Create("Frame", {
            Parent = SectionTop,
            BackgroundColor3 = Theme.SectionTop,
            BackgroundTransparency = 0.3,
            Position = UDim2.new(0, 1, 0, 1),
            Size = UDim2.new(1, -2, 1, -2),
            BorderSizePixel = 0,
        })
        
        Create("UICorner", { Parent = SectionTopBg, CornerRadius = UDim.new(0, 7) })
        
        local AccentBar = Create("Frame", {
            Parent = SectionTopBg,
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0, 2, 0, 10),
            Position = UDim2.new(0, 6, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0,
        })
        Create("UICorner", { Parent = AccentBar, CornerRadius = UDim.new(1, 0) })
        
        Create("TextLabel", {
            Parent = SectionTopBg,
            Text = SectionName,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            FontFace = FontSemiBold,
            TextSize = 11,
            Position = UDim2.new(0, 14, 0.5, SectionDesc ~= "" and -5 or 0),
            AnchorPoint = Vector2.new(0, SectionDesc ~= "" and 0 or 0.5),
            Size = UDim2.new(0, 0, 0, 12),
            AutomaticSize = Enum.AutomaticSize.X,
        })
        
        if SectionDesc ~= "" then
            Create("TextLabel", {
                Parent = SectionTopBg,
                Text = SectionDesc,
                TextColor3 = Theme.Text,
                TextTransparency = 0.4,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 9,
                Position = UDim2.new(0, 14, 0, 13),
                Size = UDim2.new(0, 0, 0, 10),
                AutomaticSize = Enum.AutomaticSize.X,
            })
        end
        
        local SectionContent = Create("Frame", {
            Parent = SectionFrame,
            BackgroundColor3 = Theme.SectionBackground,
            BackgroundTransparency = 0.4,
            Position = UDim2.new(0, 1, 0, 27),
            Size = UDim2.new(1, -2, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0,
        })
        
        Create("UICorner", { Parent = SectionContent, CornerRadius = UDim.new(0, 7) })
        
        Create("UIListLayout", {
            Parent = SectionContent,
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        
        Create("UIPadding", {
            Parent = SectionContent,
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
        })
        
        local SectionData = {
            Name = SectionName,
            Frame = SectionFrame,
            OriginalParent = PageContent,
            Content = SectionContent,
            Elements = {},
        }
        
        -- Toggle
        function SectionData:Toggle(Data)
            local ToggleName = Data.Name or "Toggle"
            local Flag = Data.Flag or "toggle_" .. (#Flags + 1)
            local Default = Data.Default or false
            local Callback = Data.Callback or function() end
            
            local ToggleFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                BorderSizePixel = 0,
            })
            
            local ToggleButton = Create("TextButton", {
                Parent = ToggleFrame,
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
            })
            
            local Indicator = Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = Indicator, CornerRadius = UDim.new(0, 4) })
            
            local Accent = Create("Frame", {
                Parent = Indicator,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
            })
            
            Create("UICorner", { Parent = Accent, CornerRadius = UDim.new(0, 4) })
            
            Create("UIGradient", {
                Parent = Accent,
                Rotation = -115,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.AccentGradient),
                })
            })
            
            local CheckImage = Create("ImageLabel", {
                Parent = Accent,
                Image = GetIconUri("121760666525660"),
                ImageColor3 = Theme.Text,
                ImageTransparency = 1,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
            })
            
            Create("TextLabel", {
                Parent = ToggleFrame,
                Text = ToggleName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 20, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, -22, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local Value = Default
            
            local function SetValue(NewValue)
                Value = NewValue
                Flags[Flag] = Value
                
                if Value then
                    CreateTween(Accent, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                    })
                    CreateTween(CheckImage, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        ImageTransparency = 0,
                        Size = UDim2.new(0, 8, 0, 7),
                    })
                else
                    CreateTween(Accent, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 0),
                    })
                    CreateTween(CheckImage, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        ImageTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 0),
                    })
                end
                
                Callback(Value)
            end
            
            ToggleButton.MouseButton1Down:Connect(function()
                SetValue(not Value)
            end)
            
            SetValue(Default)
            SetFlags[Flag] = SetValue
            
            table.insert(SectionData.Elements, { Frame = ToggleFrame, Name = ToggleName })
            return { Set = SetValue, Get = function() return Value end }
        end
        
        -- Button
        function SectionData:Button(Data)
            local ButtonName = Data.Name or "Button"
            local Icon = Data.Icon
            local Callback = Data.Callback or function() end
            
            local ButtonFrame = Create("TextButton", {
                Parent = SectionContent,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 26),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = ButtonFrame, CornerRadius = UDim.new(0, 6) })
            
            local Accent = Create("Frame", {
                Parent = ButtonFrame,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
            })
            
            Create("UICorner", { Parent = Accent, CornerRadius = UDim.new(0, 6) })
            
            Create("UIGradient", {
                Parent = Accent,
                Rotation = -115,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.AccentGradient),
                })
            })
            
            local ButtonText = Create("TextLabel", {
                Parent = ButtonFrame,
                Text = ButtonName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.2,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(1, -10, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Center,
            })
            
            if Icon then
                Create("ImageLabel", {
                    Parent = ButtonText,
                    Image = GetIconUri(Icon),
                    ImageColor3 = Theme.Text,
                    ImageTransparency = 0.3,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(0, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                })
            end
            
            ButtonFrame.MouseEnter:Connect(function()
                CreateTween(Accent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 0,
                })
            end)
            
            ButtonFrame.MouseLeave:Connect(function()
                CreateTween(Accent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                })
            end)
            
            ButtonFrame.MouseButton1Down:Connect(function()
                CreateTween(ButtonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Theme.Accent,
                })
                task.wait(0.1)
                CreateTween(ButtonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Theme.Element,
                })
                Callback()
            end)
            
            table.insert(SectionData.Elements, { Frame = ButtonFrame, Name = ButtonName })
            return ButtonFrame
        end
        
        -- Slider
        function SectionData:Slider(Data)
            local SliderName = Data.Name or "Slider"
            local Flag = Data.Flag or "slider_" .. (#Flags + 1)
            local Min = Data.Min or 0
            local Max = Data.Max or 100
            local Default = Data.Default or 0
            local Suffix = Data.Suffix or ""
            local Decimals = Data.Decimals or 1
            local Callback = Data.Callback or function() end
            
            local SliderFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = SliderFrame,
                Text = SliderName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 0, 12),
                AutomaticSize = Enum.AutomaticSize.X,
            })
            
            local ValueText = Create("TextLabel", {
                Parent = SliderFrame,
                Text = tostring(Default) .. Suffix,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(1, 0),
                Size = UDim2.new(0, 0, 0, 12),
                AutomaticSize = Enum.AutomaticSize.X,
            })
            
            local SliderBar = Create("TextButton", {
                Parent = SliderFrame,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Position = UDim2.new(0, 0, 1, -4),
                Size = UDim2.new(1, 0, 0, 5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = SliderBar, CornerRadius = UDim.new(1, 0) })
            
            local SliderFill = Create("Frame", {
                Parent = SliderBar,
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(0.5, 0, 1, 0),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = SliderFill, CornerRadius = UDim.new(1, 0) })
            
            Create("UIGradient", {
                Parent = SliderFill,
                Rotation = -102,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(1, Theme.AccentGradient),
                })
            })
            
            local Value = Default
            local Sliding = false
            
            local function SetValue(NewValue)
                Value = math.clamp(NewValue, Min, Max)
                if Decimals then
                    Value = math.floor(Value / Decimals + 0.5) * Decimals
                    Value = math.round(Value * (1 / Decimals)) / (1 / Decimals)
                end
                
                local Percent = (Value - Min) / (Max - Min)
                SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
                ValueText.Text = tostring(Value) .. Suffix
                
                Flags[Flag] = Value
                Callback(Value)
            end
            
            local function UpdateFromInput(Input)
                local X = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                SetValue(Min + (Max - Min) * X)
            end
            
            SliderBar.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Sliding = true
                    UpdateFromInput(Input)
                end
            end)
            
            SliderBar.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Sliding = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(Input)
                if Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateFromInput(Input)
                end
            end)
            
            SetValue(Default)
            SetFlags[Flag] = SetValue
            
            table.insert(SectionData.Elements, { Frame = SliderFrame, Name = SliderName })
            return { Set = SetValue, Get = function() return Value end }
        end
        
        -- Dropdown
        function SectionData:Dropdown(Data)
            local DropdownName = Data.Name or "Dropdown"
            local Flag = Data.Flag or "dropdown_" .. (#Flags + 1)
            local Items = Data.Items or {"Option 1", "Option 2", "Option 3"}
            local Default = Data.Default
            local Callback = Data.Callback or function() end
            
            local DropdownFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = DropdownFrame,
                Text = DropdownName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.45, -5, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local DropdownButton = Create("TextButton", {
                Parent = DropdownFrame,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0.55, 0, 1, 0),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = DropdownButton, CornerRadius = UDim.new(0, 6) })
            
            local DropdownValue = Create("TextLabel", {
                Parent = DropdownButton,
                Text = "...",
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 6, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, -18, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            Create("ImageLabel", {
                Parent = DropdownButton,
                Image = GetIconUri("123317177279443"),
                ImageColor3 = Color3.fromRGB(141, 141, 150),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 8, 0, 4),
                Position = UDim2.new(1, -6, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
            })
            
            local DropdownList = Create("Frame", {
                Parent = Holder,
                BackgroundColor3 = Theme.Background,
                Size = UDim2.new(0, 100, 0, 100),
                Visible = false,
                BorderSizePixel = 0,
                ZIndex = 100,
            })
            
            Create("UICorner", { Parent = DropdownList, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = DropdownList, Color = Theme.Outline, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
            
            local ListScroller = Create("ScrollingFrame", {
                Parent = DropdownList,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                ZIndex = 101,
            })
            
            Create("UIListLayout", {
                Parent = ListScroller,
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            
            local Options = {}
            local Selected = nil
            local IsOpen = false
            
            local function UpdatePosition()
                local Pos = DropdownButton.AbsolutePosition
                local Size = DropdownButton.AbsoluteSize
                DropdownList.Position = UDim2.new(0, Pos.X, 0, Pos.Y + Size.Y + 3)
                DropdownList.Size = UDim2.new(0, Size.X, 0, math.min(90, #Items * 20 + 4))
            end
            
            local function SetOpen(Open)
                IsOpen = Open
                DropdownList.Visible = Open
                if Open then UpdatePosition() end
            end
            
            local function SetValue(Option)
                Selected = Option
                DropdownValue.Text = Option
                Flags[Flag] = Option
                Callback(Option)
                SetOpen(false)
            end
            
            for _, Item in ipairs(Items) do
                local OptionButton = Create("TextButton", {
                    Parent = ListScroller,
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    BorderSizePixel = 0,
                    ZIndex = 102,
                })
                
                Create("TextLabel", {
                    Parent = OptionButton,
                    Text = Item,
                    TextColor3 = Theme.Text,
                    TextTransparency = 0.3,
                    BackgroundTransparency = 1,
                    FontFace = FontRegular,
                    TextSize = 11,
                    Position = UDim2.new(0, 5, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(1, -5, 0, 12),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 103,
                })
                
                Options[Item] = OptionButton
                OptionButton.MouseButton1Down:Connect(function() SetValue(Item) end)
            end
            
            DropdownButton.MouseButton1Down:Connect(function() SetOpen(not IsOpen) end)
            
            UserInputService.InputBegan:Connect(function(Input)
                if IsOpen and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                    if Input.Position.X >= DropdownList.AbsolutePosition.X and Input.Position.X <= DropdownList.AbsolutePosition.X + DropdownList.AbsoluteSize.X and
                       Input.Position.Y >= DropdownList.AbsolutePosition.Y and Input.Position.Y <= DropdownList.AbsolutePosition.Y + DropdownList.AbsoluteSize.Y then
                        return
                    end
                    SetOpen(false)
                end
            end)
            
            if Default and Options[Default] then SetValue(Default) end
            
            SetFlags[Flag] = function(Val) if Options[Val] then SetValue(Val) end end
            
            table.insert(SectionData.Elements, { Frame = DropdownFrame, Name = DropdownName })
            return {
                Set = function(Val) if Options[Val] then SetValue(Val) end end,
                Get = function() return Selected end,
                SetOpen = SetOpen,
                IsOpen = function() return IsOpen end,
            }
        end
        
        -- Keybind
        function SectionData:Keybind(Data)
            local KeybindName = Data.Name or "Keybind"
            local Flag = Data.Flag or "keybind_" .. (#Flags + 1)
            local Default = Data.Default or Enum.KeyCode.Z
            local Callback = Data.Callback or function() end
            
            local KeybindFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = KeybindFrame,
                Text = KeybindName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.6, -5, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local KeybindButton = Create("TextButton", {
                Parent = KeybindFrame,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0.4, 0, 1, 0),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = KeybindButton, CornerRadius = UDim.new(0, 6) })
            
            local KeybindValue = Create("TextLabel", {
                Parent = KeybindButton,
                Text = "None",
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(1, -4, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Center,
            })
            
            local Key = Default
            local Picking = false
            
            local KeyNames = {
                ["LeftShift"] = "LShift",
                ["RightShift"] = "RShift",
                ["LeftControl"] = "LCtrl",
                ["RightControl"] = "RCtrl",
                ["LeftAlt"] = "LAlt",
                ["RightAlt"] = "RAlt",
                ["Backspace"] = "None",
            }
            
            local function GetKeyName(KeyCode)
                if type(KeyCode) == "string" then return KeyNames[KeyCode] or KeyCode end
                return KeyNames[KeyCode.Name] or KeyCode.Name
            end
            
            local function SetKey(NewKey)
                Key = NewKey
                KeybindValue.Text = GetKeyName(NewKey)
                Flags[Flag] = NewKey
                Picking = false
                Callback(NewKey)
            end
            
            KeybindButton.MouseButton1Down:Connect(function()
                if Picking then SetKey(Key) return end
                Picking = true
                KeybindValue.Text = "..."
                
                local Connection
                Connection = UserInputService.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        SetKey(Input.KeyCode)
                        Connection:Disconnect()
                    end
                end)
            end)
            
            SetKey(Default)
            SetFlags[Flag] = SetKey
            
            table.insert(SectionData.Elements, { Frame = KeybindFrame, Name = KeybindName })
            return { Set = SetKey, Get = function() return Key end }
        end
        
        -- Textbox
        function SectionData:Textbox(Data)
            local TextboxName = Data.Name or "Textbox"
            local Flag = Data.Flag or "textbox_" .. (#Flags + 1)
            local Placeholder = Data.Placeholder or "Enter text..."
            local Default = Data.Default or ""
            local Numeric = Data.Numeric or false
            local Callback = Data.Callback or function() end
            
            local TextboxFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = TextboxFrame,
                Text = TextboxName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.4, -5, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local TextboxInput = Create("TextBox", {
                Parent = TextboxFrame,
                Text = "",
                PlaceholderText = Placeholder,
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
                FontFace = FontRegular,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
            })
            
            Create("UICorner", { Parent = TextboxInput, CornerRadius = UDim.new(0, 6) })
            Create("UIPadding", { Parent = TextboxInput, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })
            
            local Value = Default
            
            local function SetValue(NewValue)
                if Numeric and NewValue ~= "" and not tonumber(NewValue) then return end
                Value = NewValue
                TextboxInput.Text = NewValue
                Flags[Flag] = NewValue
                Callback(NewValue)
            end
            
            TextboxInput:GetPropertyChangedSignal("Text"):Connect(function() SetValue(TextboxInput.Text) end)
            
            SetValue(Default)
            SetFlags[Flag] = SetValue
            
            table.insert(SectionData.Elements, { Frame = TextboxFrame, Name = TextboxName })
            return { Set = SetValue, Get = function() return Value end }
        end
        
        -- Colorpicker
        function SectionData:Colorpicker(Data)
            local ColorpickerName = Data.Name or "Colorpicker"
            local Flag = Data.Flag or "color_" .. (#Flags + 1)
            local Default = Data.Default or Color3.new(1, 1, 1)
            local Callback = Data.Callback or function() end
            
            local ColorFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = ColorFrame,
                Text = ColorpickerName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.55, -5, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ColorButton = Create("TextButton", {
                Parent = ColorFrame,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0, 65, 1, 0),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = ColorButton, CornerRadius = UDim.new(0, 6) })
            
            local ColorPreview = Create("Frame", {
                Parent = ColorButton,
                BackgroundColor3 = Default,
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 5, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = ColorPreview, CornerRadius = UDim.new(1, 0) })
            
            local ColorValue = Create("TextLabel", {
                Parent = ColorButton,
                Text = "#" .. Default:ToHex(),
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 10,
                Position = UDim2.new(0, 20, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, -22, 0, 12),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ColorPicker = Create("Frame", {
                Parent = Holder,
                BackgroundColor3 = Theme.Background,
                Size = UDim2.new(0, 150, 0, 160),
                Visible = false,
                BorderSizePixel = 0,
                ZIndex = 100,
            })
            
            Create("UICorner", { Parent = ColorPicker, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = ColorPicker, Color = Theme.Outline, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
            
            local Palette = Create("TextButton", {
                Parent = ColorPicker,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Color3.new(1, 0, 0),
                Size = UDim2.new(1, -12, 1, -65),
                Position = UDim2.new(0, 6, 0, 6),
                BorderSizePixel = 0,
                ZIndex = 101,
            })
            
            Create("UICorner", { Parent = Palette, CornerRadius = UDim.new(0, 5) })
            
            local SatOverlay = Create("Frame", {
                Parent = Palette,
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
                ZIndex = 102,
            })
            
            Create("UIGradient", {
                Parent = SatOverlay,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            })
            
            local ValOverlay = Create("Frame", {
                Parent = Palette,
                BackgroundColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
                ZIndex = 103,
            })
            
            Create("UIGradient", {
                Parent = ValOverlay,
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                })
            })
            
            local Cursor = Create("Frame", {
                Parent = Palette,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 5, 0, 5),
                Position = UDim2.new(0.8, -2, 0.2, -2),
                BorderSizePixel = 0,
                ZIndex = 104,
            })
            
            Create("UIStroke", { Parent = Cursor, Color = Color3.new(1, 1, 1), Thickness = 1.5 })
            Create("UICorner", { Parent = Cursor, CornerRadius = UDim.new(1, 0) })
            
            local HueSlider = Create("TextButton", {
                Parent = ColorPicker,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(1, -12, 0, 5),
                Position = UDim2.new(0, 6, 1, -50),
                BorderSizePixel = 0,
                ZIndex = 101,
            })
            
            Create("UICorner", { Parent = HueSlider, CornerRadius = UDim.new(1, 0) })
            
            local HueGradient = Create("Frame", {
                Parent = HueSlider,
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
                ZIndex = 102,
            })
            
            Create("UIGradient", {
                Parent = HueGradient,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.new(1, 1, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.new(0, 1, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
                    ColorSequenceKeypoint.new(0.67, Color3.new(0, 0, 1)),
                    ColorSequenceKeypoint.new(0.83, Color3.new(1, 0, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0)),
                })
            })
            
            local HueCursor = Create("Frame", {
                Parent = HueSlider,
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(0, 5, 0, 8),
                Position = UDim2.new(0.5, -2, 0.5, -4),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
                ZIndex = 103,
            })
            
            Create("UICorner", { Parent = HueCursor, CornerRadius = UDim.new(1, 0) })
            
            local HexInput = Create("TextBox", {
                Parent = ColorPicker,
                Text = "#" .. Default:ToHex(),
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0, 75, 0, 18),
                Position = UDim2.new(1, -6, 1, -6),
                AnchorPoint = Vector2.new(1, 1),
                BorderSizePixel = 0,
                FontFace = FontRegular,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                ZIndex = 101,
            })
            
            Create("UICorner", { Parent = HexInput, CornerRadius = UDim.new(0, 5) })
            Create("UIPadding", { Parent = HexInput, PaddingLeft = UDim.new(0, 4) })
            
            Create("TextLabel", {
                Parent = ColorPicker,
                Text = "Hex:",
                TextColor3 = Theme.Text,
                TextTransparency = 0.5,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 10,
                Position = UDim2.new(0, 6, 1, -6),
                AnchorPoint = Vector2.new(0, 1),
                Size = UDim2.new(0, 22, 0, 18),
                ZIndex = 101,
            })
            
            local Color = Default
            local Hue, Sat, Val = 0, 1, 1
            local IsOpen = false
            local DraggingPalette = false
            local DraggingHue = false
            
            local function UpdateColor(H, S, V)
                Hue = H or Hue
                Sat = S or Sat
                Val = V or Val
                Color = Color3.fromHSV(Hue, Sat, Val)
                ColorPreview.BackgroundColor3 = Color
                ColorValue.Text = "#" .. Color:ToHex()
                Palette.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
                HexInput.Text = "#" .. Color:ToHex()
                Flags[Flag] = Color
                Callback(Color)
            end
            
            local function UpdatePosition()
                local Pos = ColorButton.AbsolutePosition
                local Size = ColorButton.AbsoluteSize
                ColorPicker.Position = UDim2.new(0, Pos.X - 70, 0, Pos.Y + Size.Y + 3)
                ColorPicker.Visible = IsOpen
            end
            
            local function SetOpen(Open)
                IsOpen = Open
                if Open then
                    UpdatePosition()
                    ColorPicker.Visible = true
                else
                    ColorPicker.Visible = false
                end
            end
            
            Palette.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    DraggingPalette = true
                    local X = math.clamp((Input.Position.X - Palette.AbsolutePosition.X) / Palette.AbsoluteSize.X, 0, 1)
                    local Y = math.clamp((Input.Position.Y - Palette.AbsolutePosition.Y) / Palette.AbsoluteSize.Y, 0, 1)
                    Sat = X
                    Val = 1 - Y
                    Cursor.Position = UDim2.new(X, -2, Y, -2)
                    UpdateColor()
                end
            end)
            
            Palette.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    DraggingPalette = false
                end
            end)
            
            HueSlider.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    DraggingHue = true
                    local X = math.clamp((Input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                    Hue = X
                    HueCursor.Position = UDim2.new(X, -2, 0.5, -4)
                    UpdateColor()
                end
            end)
            
            HueSlider.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    DraggingHue = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(Input)
                if DraggingPalette and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    local X = math.clamp((Input.Position.X - Palette.AbsolutePosition.X) / Palette.AbsoluteSize.X, 0, 1)
                    local Y = math.clamp((Input.Position.Y - Palette.AbsolutePosition.Y) / Palette.AbsoluteSize.Y, 0, 1)
                    Sat = X
                    Val = 1 - Y
                    Cursor.Position = UDim2.new(X, -2, Y, -2)
                    UpdateColor()
                end
                if DraggingHue and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    local X = math.clamp((Input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                    Hue = X
                    HueCursor.Position = UDim2.new(X, -2, 0.5, -4)
                    UpdateColor()
                end
            end)
            
            HexInput.FocusLost:Connect(function()
                local Hex = HexInput.Text:gsub("#", "")
                local Success, NewColor = pcall(Color3.fromHex, Hex)
                if Success then
                    local H, S, V = NewColor:ToHSV()
                    Hue, Sat, Val = H, S, V
                    Cursor.Position = UDim2.new(Sat, -2, 1 - Val, -2)
                    HueCursor.Position = UDim2.new(Hue, -2, 0.5, -4)
                    UpdateColor()
                end
            end)
            
            ColorButton.MouseButton1Down:Connect(function() SetOpen(not IsOpen) end)
            
            UserInputService.InputBegan:Connect(function(Input)
                if IsOpen and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                    if Input.Position.X >= ColorPicker.AbsolutePosition.X and Input.Position.X <= ColorPicker.AbsolutePosition.X + ColorPicker.AbsoluteSize.X and
                       Input.Position.Y >= ColorPicker.AbsolutePosition.Y and Input.Position.Y <= ColorPicker.AbsolutePosition.Y + ColorPicker.AbsoluteSize.Y then
                        return
                    end
                    SetOpen(false)
                end
            end)
            
            UpdateColor()
            SetFlags[Flag] = function(NewColor)
                if type(NewColor) == "Color3" then
                    local H, S, V = NewColor:ToHSV()
                    Hue, Sat, Val = H, S, V
                    Cursor.Position = UDim2.new(Sat, -2, 1 - Val, -2)
                    HueCursor.Position = UDim2.new(Hue, -2, 0.5, -4)
                    UpdateColor()
                end
            end
            
            table.insert(SectionData.Elements, { Frame = ColorFrame, Name = ColorpickerName })
            return { Set = SetFlags[Flag], Get = function() return Color end, SetOpen = SetOpen, IsOpen = function() return IsOpen end }
        end
        
        -- Listbox
        function SectionData:Listbox(Data)
            local ListboxName = Data.Name or "Listbox"
            local Flag = Data.Flag or "listbox_" .. (#Flags + 1)
            local Items = Data.Items or {"Item 1", "Item 2", "Item 3"}
            local Default = Data.Default
            local Multi = Data.Multi or false
            local Callback = Data.Callback or function() end
            
            local ListboxFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 35),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = ListboxFrame,
                Text = ListboxName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 11,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 0, 12),
                AutomaticSize = Enum.AutomaticSize.X,
            })
            
            local SearchBox = Create("TextBox", {
                Parent = ListboxFrame,
                Text = "",
                PlaceholderText = "Search...",
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 1, -20),
                AnchorPoint = Vector2.new(0, 1),
                BorderSizePixel = 0,
                FontFace = FontRegular,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
            })
            
            Create("UICorner", { Parent = SearchBox, CornerRadius = UDim.new(0, 5) })
            Create("UIPadding", { Parent = SearchBox, PaddingLeft = UDim.new(0, 5) })
            
            local ListContainer = Create("Frame", {
                Parent = ListboxFrame,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 36),
                BorderSizePixel = 0,
                ClipsDescendants = true,
            })
            
            Create("UICorner", { Parent = ListContainer, CornerRadius = UDim.new(0, 5) })
            
            local ListScroller = Create("ScrollingFrame", {
                Parent = ListContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
            })
            
            Create("UIListLayout", {
                Parent = ListScroller,
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            
            local Selected = {}
            local FilteredItems = {}
            
            local function UpdateListHeight()
                local Count = #FilteredItems
                local Height = math.min(75, Count * 18 + 4)
                ListContainer.Size = UDim2.new(1, 0, 0, Height)
                ListboxFrame.Size = UDim2.new(1, 0, 0, 36 + Height)
            end
            
            local function FilterItems(Query)
                local CleanQ = CleanString(Query)
                FilteredItems = {}
                for _, Item in ipairs(Items) do
                    if CleanQ == "" or string.find(CleanString(Item), CleanQ, 1, true) then
                        table.insert(FilteredItems, Item)
                    end
                end
                
                for _, Child in ipairs(ListScroller:GetChildren()) do
                    if Child:IsA("TextButton") then Child:Destroy() end
                end
                
                for _, Item in ipairs(FilteredItems) do
                    local OptionButton = Create("TextButton", {
                        Parent = ListScroller,
                        Text = "",
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                        BorderSizePixel = 0,
                    })
                    
                    local OptionText = Create("TextLabel", {
                        Parent = OptionButton,
                        Text = Item,
                        TextColor3 = Theme.Text,
                        TextTransparency = 0.3,
                        BackgroundTransparency = 1,
                        FontFace = FontRegular,
                        TextSize = 10,
                        Position = UDim2.new(0, 5, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(1, -5, 0, 11),
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    
                    if table.find(Selected, Item) then
                        OptionText.TextTransparency = 0
                        OptionText.Position = UDim2.new(0, 8, 0.5, 0)
                    end
                    
                    OptionButton.MouseButton1Down:Connect(function()
                        if Multi then
                            local Index = table.find(Selected, Item)
                            if Index then table.remove(Selected, Index) else table.insert(Selected, Item) end
                        else
                            Selected = {Item}
                        end
                        Flags[Flag] = table.clone(Selected)
                        Callback(table.clone(Selected))
                        FilterItems(SearchBox.Text)
                    end)
                end
                
                UpdateListHeight()
            end
            
            SearchBox:GetPropertyChangedSignal("Text"):Connect(function() FilterItems(SearchBox.Text) end)
            FilterItems("")
            
            if Default then
                local ItemsList = type(Default) == "table" and Default or {Default}
                for _, Item in ipairs(ItemsList) do
                    if table.find(Items, Item) and not table.find(Selected, Item) then
                        table.insert(Selected, Item)
                    end
                end
                Flags[Flag] = table.clone(Selected)
                Callback(table.clone(Selected))
                FilterItems(SearchBox.Text)
            end
            
            SetFlags[Flag] = function(Value)
                Selected = type(Value) == "table" and table.clone(Value) or {Value}
                FilterItems(SearchBox.Text)
                Callback(table.clone(Selected))
            end
            
            table.insert(SectionData.Elements, { Frame = ListboxFrame, Name = ListboxName })
            return {
                Set = SetFlags[Flag],
                Get = function() return table.clone(Selected) end,
                Refresh = function(NewItems)
                    Items = NewItems or {}
                    Selected = {}
                    FilterItems(SearchBox.Text)
                    Flags[Flag] = {}
                    Callback({})
                end,
            }
        end
        
        table.insert(PageData.Sections, SectionData)
        return SectionData
    end
    
    PageData.CreateSection = CreateSection
    Pages[#Pages + 1] = PageData
    
    return PageData
end

-- === НАДЁЖНАЯ СИСТЕМА ФЛИНГА (БЕЗ ДЕТЕКТА АНТИЧИТА SAN DIEGO) ===
local IsFlinging = false
local function FlingPlayer(TargetPlayer)
    if IsFlinging or not TargetPlayer or TargetPlayer == LocalPlayer then return end

    local MyChar = LocalPlayer.Character
    local TargetChar = TargetPlayer.Character
    if not MyChar or not TargetChar then return end

    local MyRoot = MyChar:FindFirstChild("HumanoidRootPart") or MyChar:FindFirstChild("Torso") or MyChar:FindFirstChild("UpperTorso")
    local TargetRoot = TargetChar:FindFirstChild("HumanoidRootPart") or TargetChar:FindFirstChild("Torso") or TargetChar:FindFirstChild("UpperTorso")
    local MyHumanoid = MyChar:FindFirstChildOfClass("Humanoid")
    local TargetHumanoid = TargetChar:FindFirstChildOfClass("Humanoid")

    if not MyRoot or not TargetRoot then return end

    IsFlinging = true

    local OldCFrame = MyRoot.CFrame
    local OldVelocity = MyRoot.AssemblyLinearVelocity
    local OldRotVelocity = MyRoot.AssemblyAngularVelocity

    -- Используем легитимную физику через VectorForce вместо подозрительных BodyVelocity/AngularVelocity
    local Attachment = Instance.new("Attachment", MyRoot)
    local VectorForce = Instance.new("VectorForce")
    VectorForce.Attachment0 = Attachment
    VectorForce.Force = Vector3.new(0, 0, 0)
    VectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
    VectorForce.Parent = MyRoot

    -- Безопасный обход коллизий для персонажа
    local NoclipConn = RunService.Stepped:Connect(function()
        if MyChar then
            for _, Part in ipairs(MyChar:GetDescendants()) do
                if Part:IsA("BasePart") then
                    if Part == MyRoot then
                        Part.CanCollide = true
                    else
                        Part.CanCollide = false
                    end
                end
            end
        end
    end)

    if MyHumanoid then
        pcall(function()
            MyHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end)
    end

    local StartTime = tick()
    local Timeout = 2.0

    while IsFlinging and TargetPlayer and TargetPlayer.Parent and TargetChar and TargetChar.Parent do
        if tick() - StartTime >= Timeout then break end
        if TargetHumanoid and TargetHumanoid.Health <= 0 then break end

        TargetRoot = TargetChar:FindFirstChild("HumanoidRootPart") or TargetChar:FindFirstChild("Torso") or TargetChar:FindFirstChild("UpperTorso")
        if not TargetRoot then break end

        -- Плавное и точное преследование без скачков скорости, триггерящих античит San Diego
        local Direction = (TargetRoot.Position - MyRoot.Position)
        if Direction.Magnitude > 3 then
            MyRoot.CFrame = CFrame.new(TargetRoot.Position + Vector3.new(0, 0.5, 0))
            MyRoot.AssemblyLinearVelocity = Vector3.new(35000, 35000, 35000)
        else
            MyRoot.CFrame = TargetRoot.CFrame * CFrame.new(0, 0, 0)
            MyRoot.AssemblyLinearVelocity = Vector3.new(50000, 50000, 50000)
        end

        RunService.RenderStepped:Wait()
    end

    if NoclipConn then NoclipConn:Disconnect() end
    if VectorForce then VectorForce:Destroy() end
    if Attachment then Attachment:Destroy() end

    if MyHumanoid then
        pcall(function()
            MyHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end

    if MyRoot then
        MyRoot.AssemblyLinearVelocity = OldVelocity or Vector3.zero
        MyRoot.AssemblyAngularVelocity = OldRotVelocity or Vector3.zero
        MyRoot.CFrame = OldCFrame
    end

    IsFlinging = false
end

-- === СОЗДАНИЕ СТРАНИЦ ===

-- Aimbot
local AimbotPage = CreatePage({Name = "Aimbot", Icon = "100050851789190"})
local AimbotSection = AimbotPage:CreateSection({Name = "Aimbot Settings"})
AimbotSection:Toggle({Name = "Enable Aimbot", Default = false})
AimbotSection:Slider({Name = "FOV", Min = 0, Max = 360, Default = 90, Suffix = "°"})
AimbotSection:Slider({Name = "Smoothness", Min = 0, Max = 100, Default = 50, Suffix = "%"})
AimbotSection:Dropdown({Name = "Target", Items = {"Head", "Body", "Legs"}, Default = "Head"})
AimbotSection:Keybind({Name = "Aimbot Key", Default = Enum.KeyCode.LeftShift})

-- Ragebot
local RagebotPage = CreatePage({Name = "Ragebot", Icon = "123944728972740"})
local RagebotSection = RagebotPage:CreateSection({Name = "Ragebot Settings"})
RagebotSection:Toggle({Name = "Enable Ragebot", Default = false})
RagebotSection:Slider({Name = "Min Damage", Min = 0, Max = 100, Default = 70, Suffix = "%"})
RagebotSection:Dropdown({Name = "Hitbox", Items = {"Head", "Body", "Legs"}, Default = "Head"})
RagebotSection:Toggle({Name = "Auto Wallbang", Default = true})

-- Visuals
local VisualsPage = CreatePage({Name = "Visuals", Icon = "122669828593160"})
local VisualsSection = VisualsPage:CreateSection({Name = "Players"})
VisualsSection:Toggle({Name = "Player ESP", Default = true})
VisualsSection:Toggle({Name = "Box ESP", Default = true})
VisualsSection:Colorpicker({Name = "Box Color", Default = Color3.new(0, 1, 1)})
VisualsSection:Toggle({Name = "Snaplines", Default = false})
VisualsSection:Dropdown({Name = "ESP Type", Items = {"Box", "Circle", "Glow"}, Default = "Box"})

local VisualsSection2 = VisualsPage:CreateSection({Name = "World"})
VisualsSection2:Toggle({Name = "Chams", Default = false})
VisualsSection2:Colorpicker({Name = "Chams Color", Default = Color3.new(0, 1, 0)})
VisualsSection2:Slider({Name = "Brightness", Min = 0, Max = 100, Default = 50, Suffix = "%"})

-- Movement
local MovementPage = CreatePage({Name = "Movement", Icon = "101636617799068"})
local MovementSection = MovementPage:CreateSection({Name = "Movement Options"})
MovementSection:Toggle({Name = "Auto Jump", Default = false})
MovementSection:Toggle({Name = "Auto Strafe", Default = false})
MovementSection:Slider({Name = "Strafe Speed", Min = 0, Max = 100, Default = 60, Suffix = "%"})

-- === ВКЛАДКА FLING PLAYERS ===
local FlingIcon = "10709781323"
local FlingPage = CreatePage({Name = "Fling Players", Icon = FlingIcon})
local FlingSection = FlingPage:CreateSection({
    Name = "Fling Players", 
    Description = "Tap a player to fling them"
})

local PlayerListContainer = Create("Frame", {
    Parent = FlingSection.Content,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BorderSizePixel = 0,
})

Create("UIListLayout", {
    Parent = PlayerListContainer,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

local function RefreshFlingPlayerList()
    for _, Child in ipairs(PlayerListContainer:GetChildren()) do
        if Child:IsA("TextButton") then
            Child:Destroy()
        end
    end

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Card = Create("TextButton", {
                Parent = PlayerListContainer,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.3,
                Size = UDim2.new(1, 0, 0, 36),
                BorderSizePixel = 0,
            })

            Create("UICorner", { Parent = Card, CornerRadius = UDim.new(0, 6) })

            local Avatar = Create("ImageLabel", {
                Parent = Card,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 26, 0, 26),
                Position = UDim2.new(0, 6, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150",
                Active = false,
            })

            Create("UICorner", { Parent = Avatar, CornerRadius = UDim.new(1, 0) })

            Create("TextLabel", {
                Parent = Card,
                Text = Player.DisplayName,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                FontFace = FontSemiBold,
                TextSize = 11,
                Position = UDim2.new(0, 38, 0, 5),
                Size = UDim2.new(1, -45, 0, 13),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Active = false,
            })

            Create("TextLabel", {
                Parent = Card,
                Text = "Lobby",
                TextColor3 = Theme.Text,
                TextTransparency = 0.5,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 9,
                Position = UDim2.new(0, 38, 0, 18),
                Size = UDim2.new(1, -45, 0, 11),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Active = false,
            })

            Card.MouseEnter:Connect(function()
                CreateTween(Card, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Theme.SectionTop,
                    BackgroundTransparency = 0.1
                })
            end)

            Card.MouseLeave:Connect(function()
                CreateTween(Card, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.3
                })
            end)

            Card.Activated:Connect(function()
                task.spawn(function()
                    FlingPlayer(Player)
                end)
            end)
        end
    end
end

Players.PlayerAdded:Connect(RefreshFlingPlayerList)
Players.PlayerRemoving:Connect(RefreshFlingPlayerList)
RefreshFlingPlayerList()

-- Server
local MiscPage = CreatePage({Name = "Server", Icon = "81598136527047"})
local ServerSection = MiscPage:CreateSection({Name = "Server Control"})
ServerSection:Button({Name = "Rejoin Server"})
ServerSection:Button({Name = "Server Hop"})
ServerSection:Button({Name = "Join Small Server"})

local JobSection = MiscPage:CreateSection({Name = "Job ID"})
JobSection:Button({Name = "Copy Job ID"})
JobSection:Textbox({Name = "Job ID...", Placeholder = "Job ID..."})
JobSection:Button({Name = "Join"})

-- Configs
local ConfigsPage = CreatePage({Name = "Configs", Icon = "101500482366184"})
local ConfigsSection = ConfigsPage:CreateSection({Name = "Configs"})
local ConfigDropdown = ConfigsSection:Listbox({Name = "Configs", Items = {}, Multi = false})

ConfigsSection:Textbox({Name = "Config Name", Placeholder = "Enter name..."})

ConfigsSection:Button({Name = "Create", Callback = function()
    local Name = Flags["Config Name"] or "config"
    if Name and Name ~= "" then
        local Config = {}
        for Flag, Value in pairs(Flags) do
            if Flag ~= "Config Name" and Flag ~= "Configs" then
                Config[Flag] = Value
            end
        end
        local Data = HttpService:JSONEncode(Config)
        if not _G.ConfigsData then _G.ConfigsData = {} end
        _G.ConfigsData[Name] = Data
        
        local Keys = {}
        for K in pairs(_G.ConfigsData) do table.insert(Keys, K) end
        ConfigDropdown:Refresh(Keys)
    end
end})

ConfigsSection:Button({Name = "Load", Callback = function()
    local Selected = ConfigDropdown:Get()
    if Selected and #Selected > 0 and _G.ConfigsData then
        local Data = _G.ConfigsData[Selected[1]]
        if Data then
            local Decoded = HttpService:JSONDecode(Data)
            for Flag, Value in pairs(Decoded) do
                if SetFlags[Flag] then
                    SetFlags[Flag](Value)
                end
            end
        end
    end
end})

-- Активация первой страницы
if Pages[1] then
    Pages[1]:SetActive(true)
end

-- === ЗАГОЛОВОК-ТУГГЛ (DARK HUB) ===
local FloatHeader = Create("TextButton", {
    Parent = Holder,
    Name = "DarkHubToggleHeader",
    Text = "",
    AutoButtonColor = false,
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.08,
    Size = UDim2.new(0, 138, 0, 32),
    Position = UDim2.new(0, IsMobile and 50 or 20, 0, IsMobile and 50 or 20),
    BorderSizePixel = 0,
    ZIndex = 127,
    ClipsDescendants = false,
})

Create("UICorner", { Parent = FloatHeader, CornerRadius = UDim.new(0, 8) })

local FloatStroke = Create("UIStroke", {
    Parent = FloatHeader,
    Color = Theme.Outline,
    Thickness = 1.2,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
})

Create("UIGradient", {
    Parent = FloatStroke,
    Rotation = 45,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Theme.Outline),
        ColorSequenceKeypoint.new(1, Theme.AccentGradient),
    })
})

local FloatAccent = Create("Frame", {
    Parent = FloatHeader,
    BackgroundColor3 = Color3.new(1, 1, 1),
    Size = UDim2.new(0, 3, 0, 18),
    Position = UDim2.new(0, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BorderSizePixel = 0,
    ZIndex = 128,
})
Create("UICorner", { Parent = FloatAccent, CornerRadius = UDim.new(1, 0) })
Create("UIGradient", {
    Parent = FloatAccent,
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentGradient),
    })
})

local FloatLogo = Create("ImageLabel", {
    Parent = FloatHeader,
    Image = DarkHubIcon,
    ImageColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(0, 10, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 128,
})

local FloatTitle = Create("TextLabel", {
    Parent = FloatHeader,
    Text = "Dark Hub",
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    FontFace = FontSemiBold,
    TextSize = 11,
    Position = UDim2.new(0, 34, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.new(0, 0, 0, 12),
    AutomaticSize = Enum.AutomaticSize.X,
    ZIndex = 128,
})

local StatusContainer = Create("Frame", {
    Parent = FloatHeader,
    BackgroundColor3 = Theme.SectionBackground2,
    BackgroundTransparency = 0.2,
    Size = UDim2.new(0, 14, 0, 14),
    Position = UDim2.new(1, -8, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    BorderSizePixel = 0,
    ZIndex = 128,
})
Create("UICorner", { Parent = StatusContainer, CornerRadius = UDim.new(1, 0) })

local StatusDot = Create("Frame", {
    Parent = StatusContainer,
    BackgroundColor3 = Color3.fromRGB(0, 230, 120),
    Size = UDim2.new(0, 6, 0, 6),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BorderSizePixel = 0,
    ZIndex = 129,
})
Create("UICorner", { Parent = StatusDot, CornerRadius = UDim.new(1, 0) })

-- Перетаскивание плашки
local Dragging = false
local DragInput, DragStart, StartPos

FloatHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = FloatHeader.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

FloatHeader.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local Delta = input.Position - DragStart
        FloatHeader.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)

FloatHeader.MouseEnter:Connect(function()
    CreateTween(FloatHeader, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    })
    CreateTween(FloatStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Thickness = 1.8
    })
end)

FloatHeader.MouseLeave:Connect(function()
    CreateTween(FloatHeader, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundColor3 = Theme.Background
    })
    CreateTween(FloatStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Thickness = 1.2
    })
end)

FloatHeader.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        StatusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 120)
        CreateTween(StatusDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 6, 0, 6)
        })
    else
        StatusDot.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
        CreateTween(StatusDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 4, 0, 4)
        })
    end
end)
