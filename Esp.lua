local DarkHub = {} -- Dark Hub UI
-- Оптимизировано для ПК и мобильных устройств (Исправлены наложения и тач-перетаскивание)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local IsMobile = UserInputService.TouchEnabled

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

-- Функция универсального перетаскивания (ПК + Мобильные)
local function MakeDraggable(Frame, Handle)
    Handle = Handle or Frame
    local Dragging = false
    local DragStart = nil
    local StartPos = nil
    
    Handle.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = Frame.Position
            
            local Connection
            Connection = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    Connection:Disconnect()
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - DragStart
            Frame.Position = UDim2.new(
                StartPos.X.Scale,
                StartPos.X.Offset + Delta.X,
                StartPos.Y.Scale,
                StartPos.Y.Offset + Delta.Y
            )
        end
    end)
end

-- Цветовая схема
local Theme = {
    Background = Color3.fromRGB(12, 12, 14),
    Background2 = Color3.fromRGB(10, 10, 12),
    SectionBackground = Color3.fromRGB(10, 10, 12),
    SectionBackground2 = Color3.fromRGB(14, 14, 16),
    SectionTop = Color3.fromRGB(28, 27, 31),
    Element = Color3.fromRGB(16, 16, 18),
    Outline = Color3.fromRGB(25, 25, 28),
    Text = Color3.fromRGB(235, 235, 235),
    Accent = Color3.fromRGB(0, 116, 224),
    AccentGradient = Color3.fromRGB(0, 195, 255),
}

-- Шрифты
local FontSemiBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
local FontRegular = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

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

Create("UIListLayout", {
    Parent = NotificationHolder,
    Padding = UDim.new(0, 12),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

Create("UIPadding", {
    Parent = NotificationHolder,
    PaddingTop = UDim.new(0, 12),
    PaddingBottom = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
    PaddingLeft = UDim.new(0, 12),
})

-- Список флагов
local Flags = {}
local SetFlags = {}

-- === ГЛАВНОЕ ОКНО ===
local MainFrame = Create("Frame", {
    Parent = Holder,
    Name = "MainFrame",
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0, 560, 0, 480),
    ClipsDescendants = true,
})

Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 8) })
MakeDraggable(MainFrame)

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
            
            local function GetPlanePosition(PlaneOrigin, PlaneNormal, RayOrigin, RayDirection)
                local N = PlaneNormal
                local D = RayDirection
                local V = RayOrigin - PlaneOrigin
                local Number = (N.X * V.X) + (N.Y * V.Y) + (N.Z * V.Z)
                local Den = (N.X * D.X) + (N.Y * D.Y) + (N.Z * D.Z)
                local A = -Number / Den
                return RayOrigin + (A * RayDirection)
            end
            
            local Position0 = GetPlanePosition(Origin, Normal, Ray0.Origin, Ray0.Direction)
            local Position1 = GetPlanePosition(Origin, Normal, Ray1.Origin, Ray1.Direction)
            
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

-- Логотип и заголовок
local Logo = Create("ImageLabel", {
    Parent = MainFrame,
    Name = "Logo",
    ImageColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(0, 12, 0, 12),
    Image = "rbxassetid://1l20959262762131",
    ScaleType = Enum.ScaleType.Fit,
})

Create("UIGradient", {
    Parent = Logo,
    Rotation = -115,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentGradient),
    })
})

Create("TextLabel", {
    Parent = MainFrame,
    Name = "Title",
    Text = "Dark Hub",
    TextColor3 = Theme.Text,
    BackgroundTransparency = 1,
    FontFace = FontSemiBold,
    TextSize = 18,
    Position = UDim2.new(0, 52, 0, 13),
    Size = UDim2.new(0, 0, 0, 15),
    AutomaticSize = Enum.AutomaticSize.X,
})

Create("TextLabel", {
    Parent = MainFrame,
    Name = "SubTitle",
    Text = "Premium Cheat",
    TextColor3 = Theme.Text,
    TextTransparency = 0.4,
    BackgroundTransparency = 1,
    FontFace = FontRegular,
    TextSize = 14,
    Position = UDim2.new(0, 52, 0, 32),
    Size = UDim2.new(0, 0, 0, 15),
    AutomaticSize = Enum.AutomaticSize.X,
})

-- Кнопка закрытия
local CloseButton = Create("TextButton", {
    Parent = MainFrame,
    Text = "",
    AutoButtonColor = false,
    BackgroundColor3 = Theme.Element,
    BackgroundTransparency = 0.2,
    Position = UDim2.new(1, -14, 0, 11),
    AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.new(0, 32, 0, 32),
    ZIndex = 2,
})

Create("UICorner", { Parent = CloseButton, CornerRadius = UDim.new(0, 7) })

Create("ImageLabel", {
    Parent = CloseButton,
    Image = "rbxassetid://130510492706892",
    ImageColor3 = Theme.Text,
    ImageTransparency = 0.3,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 11, 0, 11),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    ZIndex = 3,
})

local CloseAccent = Create("Frame", {
    Parent = CloseButton,
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
})

Create("UICorner", { Parent = CloseAccent, CornerRadius = UDim.new(0, 7) })

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
end)

CloseButton.MouseLeave:Connect(function()
    CreateTween(CloseAccent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    })
end)

CloseButton.MouseButton1Down:Connect(function()
    MainFrame.Visible = false
end)

-- Кнопка настроек
local SettingsButton = Create("TextButton", {
    Parent = MainFrame,
    Text = "",
    AutoButtonColor = false,
    BackgroundColor3 = Theme.Element,
    BackgroundTransparency = 0.2,
    Position = UDim2.new(1, -56, 0, 11),
    AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.new(0, 32, 0, 32),
    ZIndex = 2,
})

Create("UICorner", { Parent = SettingsButton, CornerRadius = UDim.new(0, 7) })

Create("ImageLabel", {
    Parent = SettingsButton,
    Image = "rbxassetid://122669828593160",
    ImageColor3 = Theme.Text,
    ImageTransparency = 0.3,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 15, 0, 14),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    ZIndex = 3,
})

local SettingsAccent = Create("Frame", {
    Parent = SettingsButton,
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
})

Create("UICorner", { Parent = SettingsAccent, CornerRadius = UDim.new(0, 7) })

Create("UIGradient", {
    Parent = SettingsAccent,
    Rotation = -115,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentGradient),
    })
})

SettingsButton.MouseEnter:Connect(function()
    CreateTween(SettingsAccent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0,
    })
end)

SettingsButton.MouseLeave:Connect(function()
    CreateTween(SettingsAccent, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    })
end)

-- Панель вкладок (левая)
local LeftTabs = Create("Frame", {
    Parent = MainFrame,
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.15,
    Size = UDim2.new(0, 170, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BorderSizePixel = 0,
    ClipsDescendants = true,
})

Create("UICorner", { Parent = LeftTabs, CornerRadius = UDim.new(0, 8) })

Create("UIListLayout", {
    Parent = LeftTabs,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

Create("UIPadding", {
    Parent = LeftTabs,
    PaddingTop = UDim.new(0, 60),
    PaddingBottom = UDim.new(0, 15),
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
})

-- Контент
local Content = Create("Frame", {
    Parent = MainFrame,
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.75,
    Position = UDim2.new(0, 170, 0, 55),
    Size = UDim2.new(1, -170, 1, -55),
    BorderSizePixel = 0,
})

Create("UICorner", { Parent = Content, CornerRadius = UDim.new(0, 8) })

-- Страницы
local Pages = {}
local CurrentPage = nil

-- Функция создания страницы
local function CreatePage(PageData)
    local PageName = PageData.Name or "Page"
    local PageIcon = PageData.Icon or "100050851789190"
    
    local TabButton = Create("TextButton", {
        Parent = LeftTabs,
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    
    Create("UICorner", { Parent = TabButton, CornerRadius = UDim.new(0, 6) })
    
    local TabIcon = Create("ImageLabel", {
        Parent = TabButton,
        Image = "rbxassetid://" .. PageIcon,
        ImageColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
    })
    
    Create("UIGradient", {
        Parent = TabIcon,
        Rotation = -115,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentGradient),
        })
    })
    
    Create("TextLabel", {
        Parent = TabButton,
        Text = PageName,
        TextColor3 = Theme.Text,
        TextTransparency = 0.3,
        BackgroundTransparency = 1,
        FontFace = FontRegular,
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = UDim2.new(0, 34, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, -38, 0, 15),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
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
    
    Create("UICorner", { Parent = PageFrame, CornerRadius = UDim.new(0, 8) })
    
    local PageContent = Create("Frame", {
        Parent = PageFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 8),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    
    Create("UIListLayout", {
        Parent = PageContent,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    local PageObj = {
        Name = PageName,
        Frame = PageFrame,
        Content = PageContent,
        TabButton = TabButton,
        Sections = {},
        Active = false,
    }
    
    local function SetActive(Active)
        if Active == PageObj.Active then return end
        
        if Active then
            if CurrentPage then
                CurrentPage.Active = false
                CurrentPage.Frame.Visible = false
                CurrentPage.TabButton.BackgroundTransparency = 1
            end
            
            PageObj.Active = true
            PageObj.Frame.Visible = true
            PageObj.TabButton.BackgroundTransparency = 0.25
            CurrentPage = PageObj
        else
            PageObj.Active = false
            PageObj.Frame.Visible = false
            PageObj.TabButton.BackgroundTransparency = 1
        end
    end
    
    TabButton.MouseButton1Down:Connect(function()
        SetActive(true)
    end)
    
    PageObj.SetActive = SetActive
    
    -- Функция создания секции
    local function CreateSection(SectionData)
        local SectionName = SectionData.Name or "Section"
        local SectionDesc = SectionData.Description or ""
        local SectionIcon = SectionData.Icon or "123944728972740"
        
        local SectionFrame = Create("Frame", {
            Parent = PageContent,
            BackgroundColor3 = Theme.SectionBackground2,
            BackgroundTransparency = 0.65,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true,
            BorderSizePixel = 0,
        })
        
        Create("UICorner", { Parent = SectionFrame, CornerRadius = UDim.new(0, 6) })
        
        local SectionTop = Create("Frame", {
            Parent = SectionFrame,
            BackgroundColor3 = Theme.Outline,
            BackgroundTransparency = 0.65,
            Size = UDim2.new(1, 0, 0, 42),
            BorderSizePixel = 0,
        })
        
        local SectionTopBg = Create("Frame", {
            Parent = SectionTop,
            BackgroundColor3 = Theme.SectionTop,
            BackgroundTransparency = 0.65,
            Position = UDim2.new(0, 1, 0, 1),
            Size = UDim2.new(1, -2, 1, -2),
            BorderSizePixel = 0,
        })
        
        Create("UICorner", { Parent = SectionTopBg, CornerRadius = UDim.new(0, 5) })
        
        local SectionIconImg = Create("ImageLabel", {
            Parent = SectionTopBg,
            Image = "rbxassetid://" .. SectionIcon,
            ImageColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 10, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
        })
        
        Create("UIGradient", {
            Parent = SectionIconImg,
            Rotation = -115,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.Accent),
                ColorSequenceKeypoint.new(1, Theme.AccentGradient),
            })
        })
        
        Create("TextLabel", {
            Parent = SectionTopBg,
            Text = SectionName,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            FontFace = FontSemiBold,
            TextSize = 14,
            Position = UDim2.new(0, 36, 0, SectionDesc ~= "" and 6 or 13),
            Size = UDim2.new(1, -42, 0, 15),
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        if SectionDesc ~= "" then
            Create("TextLabel", {
                Parent = SectionTopBg,
                Text = SectionDesc,
                TextColor3 = Theme.Text,
                TextTransparency = 0.4,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 12,
                Position = UDim2.new(0, 36, 0, 22),
                Size = UDim2.new(1, -42, 0, 14),
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
        end
        
        local SectionContent = Create("Frame", {
            Parent = SectionFrame,
            BackgroundColor3 = Theme.SectionBackground,
            BackgroundTransparency = 0.65,
            Position = UDim2.new(0, 1, 0, 43),
            Size = UDim2.new(1, -2, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0,
        })
        
        Create("UICorner", { Parent = SectionContent, CornerRadius = UDim.new(0, 6) })
        
        Create("UIListLayout", {
            Parent = SectionContent,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        
        Create("UIPadding", {
            Parent = SectionContent,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
        })
        
        local SectionObj = {
            Frame = SectionFrame,
            Content = SectionContent,
            Elements = {},
        }
        
        -- ЭЛЕМЕНТЫ УПРАВЛЕНИЯ
        
        -- Toggle
        function SectionObj:Toggle(Data)
            local ToggleName = Data.Name or "Toggle"
            local Flag = Data.Flag or "toggle_" .. (#Flags + 1)
            local Default = Data.Default or false
            local Callback = Data.Callback or function() end
            
            local ToggleFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
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
                Size = UDim2.new(0, 20, 0, 20),
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
                Image = "rbxassetid://121760666525660",
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
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 28, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, -30, 0, 15),
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
                        Size = UDim2.new(0, 10, 0, 9),
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
            
            return {
                Set = SetValue,
                Get = function() return Value end,
            }
        end
        
        -- Button
        function SectionObj:Button(Data)
            local ButtonName = Data.Name or "Button"
            local Icon = Data.Icon
            local Callback = Data.Callback or function() end
            
            local ButtonFrame = Create("TextButton", {
                Parent = SectionContent,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 30),
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
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(1, -20, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Center,
            })
            
            if Icon then
                Create("ImageLabel", {
                    Parent = ButtonText,
                    Image = "rbxassetid://" .. Icon,
                    ImageColor3 = Theme.Text,
                    ImageTransparency = 0.3,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, -18, 0.5, 0),
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
            
            return ButtonFrame
        end
        
        -- Slider
        function SectionObj:Slider(Data)
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
                Size = UDim2.new(1, 0, 0, 32),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = SliderFrame,
                Text = SliderName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0.7, -10, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ValueText = Create("TextLabel", {
                Parent = SliderFrame,
                Text = tostring(Default) .. Suffix,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 13,
                Position = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(1, 0),
                Size = UDim2.new(0.3, 0, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Right,
            })
            
            local SliderBar = Create("TextButton", {
                Parent = SliderFrame,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Position = UDim2.new(0, 0, 1, -4),
                Size = UDim2.new(1, 0, 0, 6),
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
                local NewValue = Min + (Max - Min) * X
                SetValue(NewValue)
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
            
            return {
                Set = SetValue,
                Get = function() return Value end,
            }
        end
        
        -- Dropdown
        function SectionObj:Dropdown(Data)
            local DropdownName = Data.Name or "Dropdown"
            local Flag = Data.Flag or "dropdown_" .. (#Flags + 1)
            local Items = Data.Items or {"Option 1", "Option 2", "Option 3"}
            local Default = Data.Default
            local Callback = Data.Callback or function() end
            
            local DropdownFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = DropdownFrame,
                Text = DropdownName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.5, -5, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local DropdownButton = Create("TextButton", {
                Parent = DropdownFrame,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0.48, 0, 0, 26),
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
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 8, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, -24, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            Create("ImageLabel", {
                Parent = DropdownButton,
                Image = "rbxassetid://123317177279443",
                ImageColor3 = Color3.fromRGB(141, 141, 150),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 12, 0, 6),
                Position = UDim2.new(1, -6, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
            })
            
            local DropdownList = Create("Frame", {
                Parent = Holder,
                BackgroundColor3 = Theme.Background,
                Size = UDim2.new(0, 140, 0, 120),
                Position = UDim2.new(0, 0, 0, 0),
                Visible = false,
                BorderSizePixel = 0,
                ZIndex = 100,
            })
            
            Create("UICorner", { Parent = DropdownList, CornerRadius = UDim.new(0, 6) })
            Create("UIStroke", { Parent = DropdownList, Color = Theme.Outline, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
            
            local ListScroller = Create("ScrollingFrame", {
                Parent = DropdownList,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -6, 1, -6),
                Position = UDim2.new(0, 3, 0, 3),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
            })
            
            Create("UIListLayout", {
                Parent = ListScroller,
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            
            local Options = {}
            local Selected = nil
            local IsOpen = false
            
            local function UpdatePosition()
                local Pos = DropdownButton.AbsolutePosition
                local Size = DropdownButton.AbsoluteSize
                local Viewport = Camera.ViewportSize
                
                local ListWidth = Size.X
                local ListHeight = math.min(120, #Options * 26 + 10)
                
                local X = Pos.X
                local Y = Pos.Y + Size.Y + 4
                
                -- Проверка выхода за границы экрана
                if X + ListWidth > Viewport.X - 10 then X = Viewport.X - ListWidth - 10 end
                if X < 10 then X = 10 end
                if Y + ListHeight > Viewport.Y - 10 then Y = Pos.Y - ListHeight - 4 end
                if Y < 10 then Y = 10 end
                
                DropdownList.Position = UDim2.new(0, X, 0, Y)
                DropdownList.Size = UDim2.new(0, ListWidth, 0, ListHeight)
            end
            
            local function SetOpen(Open)
                IsOpen = Open
                DropdownList.Visible = Open
                if Open then
                    UpdatePosition()
                end
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
                    Size = UDim2.new(1, 0, 0, 24),
                    BorderSizePixel = 0,
                })
                
                Create("TextLabel", {
                    Parent = OptionButton,
                    Text = Item,
                    TextColor3 = Theme.Text,
                    TextTransparency = 0.3,
                    BackgroundTransparency = 1,
                    FontFace = FontRegular,
                    TextSize = 13,
                    Position = UDim2.new(0, 6, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(1, -6, 0, 15),
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                Options[Item] = OptionButton
                OptionButton.MouseButton1Down:Connect(function() SetValue(Item) end)
            end
            
            DropdownButton.MouseButton1Down:Connect(function()
                SetOpen(not IsOpen)
            end)
            
            UserInputService.InputBegan:Connect(function(Input)
                if IsOpen and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                    if not DropdownList.Visible then return end
                    local Pos = Input.Position
                    if Pos.X >= DropdownList.AbsolutePosition.X and Pos.X <= DropdownList.AbsolutePosition.X + DropdownList.AbsoluteSize.X and
                       Pos.Y >= DropdownList.AbsolutePosition.Y and Pos.Y <= DropdownList.AbsolutePosition.Y + DropdownList.AbsoluteSize.Y then
                        return
                    end
                    SetOpen(false)
                end
            end)
            
            if Default and Options[Default] then SetValue(Default) end
            SetFlags[Flag] = function(Val) if Options[Val] then SetValue(Val) end end
            
            return {
                Set = function(Val) if Options[Val] then SetValue(Val) end end,
                Get = function() return Selected end,
                IsOpen = IsOpen,
                SetOpen = SetOpen,
            }
        end
        
        -- Keybind
        function SectionObj:Keybind(Data)
            local KeybindName = Data.Name or "Keybind"
            local Flag = Data.Flag or "keybind_" .. (#Flags + 1)
            local Default = Data.Default or Enum.KeyCode.Z
            local Callback = Data.Callback or function() end
            
            local KeybindFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = KeybindFrame,
                Text = KeybindName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.5, -5, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local KeybindButton = Create("TextButton", {
                Parent = KeybindFrame,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0.45, 0, 0, 26),
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
                TextSize = 13,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(1, -6, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Center,
            })
            
            local Key = Default
            local Picking = false
            
            local KeyNames = {
                ["LeftShift"] = "LShift", ["RightShift"] = "RShift",
                ["LeftControl"] = "LCtrl", ["RightControl"] = "RCtrl",
                ["LeftAlt"] = "LAlt", ["RightAlt"] = "RAlt", ["Backspace"] = "None"
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
            
            return {
                Set = SetKey,
                Get = function() return Key end,
            }
        end
        
        -- Textbox
        function SectionObj:Textbox(Data)
            local TextboxName = Data.Name or "Textbox"
            local Flag = Data.Flag or "textbox_" .. (#Flags + 1)
            local Placeholder = Data.Placeholder or "Enter text..."
            local Default = Data.Default or ""
            local Numeric = Data.Numeric or false
            local Callback = Data.Callback or function() end
            
            local TextboxFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = TextboxFrame,
                Text = TextboxName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.45, -5, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local TextboxInput = Create("TextBox", {
                Parent = TextboxFrame,
                Text = "",
                PlaceholderText = Placeholder,
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0.52, 0, 0, 26),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
                FontFace = FontRegular,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
            })
            
            Create("UICorner", { Parent = TextboxInput, CornerRadius = UDim.new(0, 6) })
            Create("UIPadding", { Parent = TextboxInput, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
            
            local Value = Default
            local function SetValue(NewValue)
                if Numeric and NewValue ~= "" and not tonumber(NewValue) then return end
                Value = NewValue
                TextboxInput.Text = NewValue
                Flags[Flag] = NewValue
                Callback(NewValue)
            end
            
            TextboxInput:GetPropertyChangedSignal("Text"):Connect(function()
                SetValue(TextboxInput.Text)
            end)
            
            SetValue(Default)
            SetFlags[Flag] = SetValue
            
            return {
                Set = SetValue,
                Get = function() return Value end,
            }
        end
        
        -- Colorpicker
        function SectionObj:Colorpicker(Data)
            local ColorpickerName = Data.Name or "Colorpicker"
            local Flag = Data.Flag or "color_" .. (#Flags + 1)
            local Default = Data.Default or Color3.new(1, 1, 1)
            local Callback = Data.Callback or function() end
            
            local ColorFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = ColorFrame,
                Text = ColorpickerName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0.5, -5, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ColorButton = Create("TextButton", {
                Parent = ColorFrame,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0.45, 0, 0, 26),
                Position = UDim2.new(1, 0, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = ColorButton, CornerRadius = UDim.new(0, 6) })
            
            local ColorPreview = Create("Frame", {
                Parent = ColorButton,
                BackgroundColor3 = Default,
                Size = UDim2.new(0, 16, 0, 16),
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
                TextSize = 12,
                Position = UDim2.new(0, 26, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, -30, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ColorPicker = Create("Frame", {
                Parent = Holder,
                BackgroundColor3 = Theme.Background,
                Size = UDim2.new(0, 200, 0, 230),
                Visible = false,
                BorderSizePixel = 0,
                ZIndex = 100,
            })
            
            Create("UICorner", { Parent = ColorPicker, CornerRadius = UDim.new(0, 8) })
            Create("UIStroke", { Parent = ColorPicker, Color = Theme.Outline, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
            
            local Palette = Create("TextButton", {
                Parent = ColorPicker,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Color3.new(1, 0, 0),
                Size = UDim2.new(1, -20, 1, -100),
                Position = UDim2.new(0, 10, 0, 10),
                BorderSizePixel = 0,
            })
            
            Create("UICorner", { Parent = Palette, CornerRadius = UDim.new(0, 6) })
            
            local SatOverlay = Create("Frame", {
                Parent = Palette,
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
            })
            Create("UIGradient", { Parent = SatOverlay, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}) })
            
            local ValOverlay = Create("Frame", {
                Parent = Palette,
                BackgroundColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                BorderSizePixel = 0,
            })
            Create("UIGradient", { Parent = ValOverlay, Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}) })
            
            local Cursor = Create("Frame", {
                Parent = Palette,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(0.8, -5, 0.2, -5),
                BorderSizePixel = 0,
            })
            Create("UIStroke", { Parent = Cursor, Color = Color3.new(1, 1, 1), Thickness = 2 })
            Create("UICorner", { Parent = Cursor, CornerRadius = UDim.new(1, 0) })
            
            local HueSlider = Create("TextButton", {
                Parent = ColorPicker,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(1, -20, 0, 8),
                Position = UDim2.new(0, 10, 1, -75),
                BorderSizePixel = 0,
            })
            Create("UICorner", { Parent = HueSlider, CornerRadius = UDim.new(1, 0) })
            
            local HueGradient = Create("Frame", { Parent = HueSlider, Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0 })
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
                Size = UDim2.new(0, 10, 0, 14),
                Position = UDim2.new(0.5, -5, 0.5, -7),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
            })
            Create("UICorner", { Parent = HueCursor, CornerRadius = UDim.new(1, 0) })
            
            local HexInput = Create("TextBox", {
                Parent = ColorPicker,
                Text = "#" .. Default:ToHex(),
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(0, 100, 0, 24),
                Position = UDim2.new(1, -10, 1, -10),
                AnchorPoint = Vector2.new(1, 1),
                BorderSizePixel = 0,
                FontFace = FontRegular,
                TextSize = 13,
                ClearTextOnFocus = false,
            })
            Create("UICorner", { Parent = HexInput, CornerRadius = UDim.new(0, 6) })
            Create("UIPadding", { Parent = HexInput, PaddingLeft = UDim.new(0, 6) })
            
            Create("TextLabel", {
                Parent = ColorPicker,
                Text = "Hex:",
                TextColor3 = Theme.Text,
                TextTransparency = 0.5,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 13,
                Position = UDim2.new(0, 10, 1, -10),
                AnchorPoint = Vector2.new(0, 1),
                Size = UDim2.new(0, 30, 0, 24),
            })
            
            local Color = Default
            local Hue, Sat, Val = 0, 1, 1
            local IsOpen = false
            local DraggingPalette, DraggingHue = false, false
            
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
                local Viewport = Camera.ViewportSize
                
                local PickerWidth = 200
                local PickerHeight = 230
                
                local X = Pos.X + Size.X + 5
                local Y = Pos.Y
                
                if X + PickerWidth > Viewport.X - 10 then X = Pos.X - PickerWidth - 5 end
                if X < 10 then X = 10 end
                if Y + PickerHeight > Viewport.Y - 10 then Y = Viewport.Y - PickerHeight - 10 end
                if Y < 10 then Y = 10 end
                
                ColorPicker.Position = UDim2.new(0, X, 0, Y)
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
                    Cursor.Position = UDim2.new(X, -5, Y, -5)
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
                    HueCursor.Position = UDim2.new(X, -5, 0.5, -7)
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
                    Cursor.Position = UDim2.new(X, -5, Y, -5)
                    UpdateColor()
                end
                if DraggingHue and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    local X = math.clamp((Input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                    Hue = X
                    HueCursor.Position = UDim2.new(X, -5, 0.5, -7)
                    UpdateColor()
                end
            end)
            
            HexInput.FocusLost:Connect(function()
                local Hex = HexInput.Text:gsub("#", "")
                local Success, NewColor = pcall(Color3.fromHex, Hex)
                if Success then
                    local H, S, V = NewColor:ToHSV()
                    Hue, Sat, Val = H, S, V
                    Cursor.Position = UDim2.new(Sat, -5, 1 - Val, -5)
                    HueCursor.Position = UDim2.new(Hue, -5, 0.5, -7)
                    UpdateColor()
                end
            end)
            
            ColorButton.MouseButton1Down:Connect(function() SetOpen(not IsOpen) end)
            
            UserInputService.InputBegan:Connect(function(Input)
                if IsOpen and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                    if not ColorPicker.Visible then return end
                    local Pos = Input.Position
                    if Pos.X >= ColorPicker.AbsolutePosition.X and Pos.X <= ColorPicker.AbsolutePosition.X + ColorPicker.AbsoluteSize.X and
                       Pos.Y >= ColorPicker.AbsolutePosition.Y and Pos.Y <= ColorPicker.AbsolutePosition.Y + ColorPicker.AbsoluteSize.Y then
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
                    Cursor.Position = UDim2.new(Sat, -5, 1 - Val, -5)
                    HueCursor.Position = UDim2.new(Hue, -5, 0.5, -7)
                    UpdateColor()
                end
            end
            
            return {
                Set = SetFlags[Flag],
                Get = function() return Color end,
                SetOpen = SetOpen,
                IsOpen = IsOpen,
            }
        end
        
        -- Listbox (Searchable Dropdown)
        function SectionObj:Listbox(Data)
            local ListboxName = Data.Name or "Listbox"
            local Flag = Data.Flag or "listbox_" .. (#Flags + 1)
            local Items = Data.Items or {"Item 1", "Item 2", "Item 3"}
            local Default = Data.Default
            local Multi = Data.Multi or false
            local Callback = Data.Callback or function() end
            
            local ListboxFrame = Create("Frame", {
                Parent = SectionContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                BorderSizePixel = 0,
            })
            
            Create("TextLabel", {
                Parent = ListboxFrame,
                Text = ListboxName,
                TextColor3 = Theme.Text,
                TextTransparency = 0.3,
                BackgroundTransparency = 1,
                FontFace = FontRegular,
                TextSize = 13,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 15),
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local SearchBox = Create("TextBox", {
                Parent = ListboxFrame,
                Text = "",
                PlaceholderText = "Search...",
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 1, -24),
                AnchorPoint = Vector2.new(0, 1),
                BorderSizePixel = 0,
                FontFace = FontRegular,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
            })
            
            Create("UICorner", { Parent = SearchBox, CornerRadius = UDim.new(0, 6) })
            Create("UIPadding", { Parent = SearchBox, PaddingLeft = UDim.new(0, 8) })
            
            local ListContainer = Create("Frame", {
                Parent = ListboxFrame,
                BackgroundColor3 = Theme.Element,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 42),
                BorderSizePixel = 0,
                ClipsDescendants = true,
            })
            
            Create("UICorner", { Parent = ListContainer, CornerRadius = UDim.new(0, 6) })
            
            local ListScroller = Create("ScrollingFrame", {
                Parent = ListContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -6, 1, -6),
                Position = UDim2.new(0, 3, 0, 3),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
            })
            
            Create("UIListLayout", {
                Parent = ListScroller,
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            
            local Selected = {}
            local FilteredItems = {}
            
            local function UpdateListHeight()
                local Count = #FilteredItems
                local Height = math.min(100, Count * 24 + 6)
                ListContainer.Size = UDim2.new(1, 0, 0, Height)
                ListboxFrame.Size = UDim2.new(1, 0, 0, Height + 44)
            end
            
            local function FilterItems(Query)
                Query = string.lower(Query)
                FilteredItems = {}
                for _, Item in ipairs(Items) do
                    if Query == "" or string.find(string.lower(Item), Query) then
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
                        Size = UDim2.new(1, 0, 0, 22),
                        BorderSizePixel = 0,
                    })
                    
                    local OptionText = Create("TextLabel", {
                        Parent = OptionButton,
                        Text = Item,
                        TextColor3 = Theme.Text,
                        TextTransparency = 0.3,
                        BackgroundTransparency = 1,
                        FontFace = FontRegular,
                        TextSize = 13,
                        Position = UDim2.new(0, 8, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(1, -8, 0, 15),
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    
                    if table.find(Selected, Item) then
                        OptionText.TextTransparency = 0
                        OptionText.Position = UDim2.new(0, 16, 0.5, 0)
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
                Selected = type(Default) == "table" and Default or {Default}
                Flags[Flag] = table.clone(Selected)
                FilterItems("")
            end
            
            return {
                Set = function(Value)
                    Selected = type(Value) == "table" and Value or {Value}
                    FilterItems(SearchBox.Text)
                    Callback(table.clone(Selected))
                end,
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
        
        table.insert(SectionObj.Elements, SectionObj)
        table.insert(PageObj.Sections, SectionObj)
        return SectionObj
    end
    
    PageObj.CreateSection = CreateSection
    Pages[#Pages + 1] = PageObj
    
    return PageObj
end

-- === СОЗДАНИЕ СТРАНИЦ ===

-- Aimbot
local AimbotPage = CreatePage({Name = "Aimbot", Icon = "100050851789190"})
local AimbotSection = AimbotPage:CreateSection({Name = "Aimbot Settings"})
AimbotSection:Toggle({Name = "Enable Aimbot", Default = false})
AimbotSection:Slider({Name = "FOV Radius", Min = 0, Max = 360, Default = 90, Suffix = "°"})
AimbotSection:Slider({Name = "Smoothness", Min = 0, Max = 100, Default = 50, Suffix = "%"})
AimbotSection:Dropdown({Name = "Target Bone", Items = {"Head", "Body", "Legs"}, Default = "Head"})
AimbotSection:Keybind({Name = "Aimbot Key", Default = Enum.KeyCode.LeftShift})

-- Ragebot
local RagebotPage = CreatePage({Name = "Ragebot", Icon = "123944728972740"})
local RagebotSection = RagebotPage:CreateSection({Name = "Ragebot Main"})
RagebotSection:Toggle({Name = "Enable Ragebot", Default = false})
RagebotSection:Slider({Name = "Min Damage", Min = 0, Max = 100, Default = 70, Suffix = "%"})
RagebotSection:Dropdown({Name = "Hitbox Priority", Items = {"Head", "Body", "Legs"}, Default = "Head"})
RagebotSection:Toggle({Name = "Auto Wallbang", Default = true})

-- Visuals
local VisualsPage = CreatePage({Name = "Visuals", Icon = "122669828593160"})
local VisualsSection = VisualsPage:CreateSection({Name = "Player ESP"})
VisualsSection:Toggle({Name = "Player ESP", Default = true})
VisualsSection:Toggle({Name = "Box ESP", Default = true})
VisualsSection:Colorpicker({Name = "Box Color", Default = Color3.new(0, 1, 1)})
VisualsSection:Toggle({Name = "Snaplines", Default = false})
VisualsSection:Dropdown({Name = "ESP Type", Items = {"Box", "Circle", "Glow"}, Default = "Box"})

local VisualsSection2 = VisualsPage:CreateSection({Name = "World Settings"})
VisualsSection2:Toggle({Name = "Chams", Default = false})
VisualsSection2:Colorpicker({Name = "Chams Color", Default = Color3.new(0, 1, 0)})
VisualsSection2:Slider({Name = "Brightness", Min = 0, Max = 100, Default = 50, Suffix = "%"})

-- Movement
local MovementPage = CreatePage({Name = "Movement", Icon = "101636617799068"})
local MovementSection = MovementPage:CreateSection({Name = "Movement Mechanics"})
MovementSection:Toggle({Name = "Auto Jump", Default = false})
MovementSection:Toggle({Name = "Auto Strafe", Default = false})
MovementSection:Slider({Name = "Strafe Speed", Min = 0, Max = 100, Default = 60, Suffix = "%"})
MovementSection:Toggle({Name = "Quick Stop", Default = false})

-- Miscellaneous
local MiscPage = CreatePage({Name = "Misc", Icon = "81598136527047"})
local MiscSection = MiscPage:CreateSection({Name = "Main Misc"})
MiscSection:Toggle({Name = "Anti Untrusted", Default = true})
MiscSection:Toggle({Name = "Fast Reload", Default = false})
MiscSection:Textbox({Name = "Server Filter", Placeholder = "Enter filter..."})

-- Configs
local ConfigsPage = CreatePage({Name = "Configs", Icon = "101500482366184"})
local ConfigsSection = ConfigsPage:CreateSection({Name = "Configuration"})
local ConfigDropdown = ConfigsSection:Listbox({Name = "Config Presets", Items = {}, Multi = false})

ConfigsSection:Textbox({Name = "Config Name", Placeholder = "Enter name..."})

ConfigsSection:Button({Name = "Create Config", Callback = function()
    local Name = Flags["Config Name"] or "config"
    if Name and Name ~= "" then
        local Config = {}
        for Flag, Value in pairs(Flags) do
            if Flag ~= "Config Name" and Flag ~= "Config Presets" then
                Config[Flag] = Value
            end
        end
        if not _G.ConfigsData then _G.ConfigsData = {} end
        _G.ConfigsData[Name] = HttpService:JSONEncode(Config)
        
        local Keys = {}
        for K in pairs(_G.ConfigsData) do table.insert(Keys, K) end
        ConfigDropdown:Refresh(Keys)
    end
end})

ConfigsSection:Button({Name = "Load Config", Callback = function()
    local Selected = ConfigDropdown:Get()
    if Selected and #Selected > 0 and _G.ConfigsData then
        local Data = _G.ConfigsData[Selected[1]]
        if Data then
            local Decoded = HttpService:JSONEncode(Data)
            for Flag, Value in pairs(Decoded) do
                if SetFlags[Flag] then SetFlags[Flag](Value) end
            end
        end
    end
end})

-- Активация первой страницы
if Pages[1] then Pages[1]:SetActive(true) end

-- === ПЛАВАЮЩАЯ КНОПКА (С ТАЧ-ПЕРЕТАСКИВАНИЕМ) ===
if IsMobile then
    local FloatButton = Create("TextButton", {
        Parent = Holder,
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 15, 0.4, 0),
        BorderSizePixel = 0,
        ZIndex = 127,
    })
    
    Create("UICorner", { Parent = FloatButton, CornerRadius = UDim.new(1, 0) })
    Create("UIStroke", { Parent = FloatButton, Color = Theme.Accent, Thickness = 2 })
    MakeDraggable(FloatButton)
    
    local FloatLogo = Create("ImageLabel", {
        Parent = FloatButton,
        Image = "rbxassetid://1l20959262762131",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ScaleType = Enum.ScaleType.Fit,
    })
    
    Create("UIGradient", {
        Parent = FloatLogo,
        Rotation = -115,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentGradient),
        })
    })
    
    FloatButton.MouseButton1Down:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
end

-- === НАСТРОЙКА РАЗМЕРА ДЛЯ МОБИЛЬНЫХ ===
if IsMobile then
    local Viewport = Camera.ViewportSize
    local TargetWidth = math.min(480, Viewport.X - 20)
    local TargetHeight = math.min(360, Viewport.Y - 20)
    
    MainFrame.Size = UDim2.new(0, TargetWidth, 0, TargetHeight)
    LeftTabs.Size = UDim2.new(0, 130, 1, 0)
    Content.Position = UDim2.new(0, 130, 0, 55)
    Content.Size = UDim2.new(1, -130, 1, -55)
end

-- === УВЕДОМЛЕНИЯ ===
function DarkHub:Notify(Data)
    Data = Data or {}
    local Title = Data.Title or "Notification"
    local Description = Data.Description or ""
    local Duration = Data.Duration or 3
    local Icon = Data.Icon or "101636617799068"
    
    local Notification = Create("Frame", {
        Parent = NotificationHolder,
        BackgroundTransparency = 0.35,
        BackgroundColor3 = Theme.SectionBackground,
        AutomaticSize = Enum.AutomaticSize.XY,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    
    Create("UICorner", { Parent = Notification, CornerRadius = UDim.new(0, 6) })
    
    Create("UIPadding", {
        Parent = Notification,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    })
    
    Create("TextLabel", {
        Parent = Notification,
        Text = Title,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        FontFace = FontSemiBold,
        TextSize = 13,
        Size = UDim2.new(0, 0, 0, 15),
        AutomaticSize = Enum.AutomaticSize.XY,
    })
    
    Create("TextLabel", {
        Parent = Notification,
        Text = Description,
        TextColor3 = Theme.Text,
        TextTransparency = 0.3,
        BackgroundTransparency = 1,
        FontFace = FontRegular,
        TextSize = 12,
        Position = UDim2.new(0, 0, 0, 18),
        Size = UDim2.new(0, 0, 0, 14),
        AutomaticSize = Enum.AutomaticSize.XY,
    })
    
    local Accent = Create("Frame", {
        Parent = Notification,
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.new(0, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BorderSizePixel = 0,
    })
    
    Create("UICorner", { Parent = Accent, CornerRadius = UDim.new(1, 0) })
    Create("UIGradient", {
        Parent = Accent,
        Rotation = -115,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentGradient),
        })
    })
    
    CreateTween(Accent, TweenInfo.new(Duration, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 0, 2) })
    
    task.delay(Duration + 0.2, function()
        Notification:Destroy()
    end)
end

getgenv().DarkHub = DarkHub
