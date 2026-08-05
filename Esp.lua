--[[
    Dark Hub GUI
    Основано на библиотеке Library.lua
    Адаптировано для ПК и мобильных устройств
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local gethui = gethui or function() return CoreGui end

-- Вспомогательные функции
local function Create(Class, Properties)
    local Instance = Instance.new(Class)
    for Property, Value in pairs(Properties or {}) do
        Instance[Property] = Value
    end
    return Instance
end

local function CreateTween(Instance, Info, Goal)
    local Tween = TweenService:Create(Instance, Info or TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Goal)
    Tween:Play()
    return Tween
end

local function IsMobile()
    return UserInputService.TouchEnabled
end

-- ============================================================
-- Основное GUI
-- ============================================================

local DarkHub = {
    Theme = {
        Background = Color3.fromRGB(12, 12, 14),
        Background2 = Color3.fromRGB(10, 10, 12),
        SectionBackground = Color3.fromRGB(14, 14, 16),
        SectionTop = Color3.fromRGB(28, 27, 31),
        Element = Color3.fromRGB(18, 18, 20),
        Outline = Color3.fromRGB(25, 25, 28),
        Text = Color3.fromRGB(235, 235, 235),
        Accent = Color3.fromRGB(0, 116, 224),
        AccentGradient = Color3.fromRGB(0, 195, 255),
    },
    IsOpen = false,
    Pages = {},
    CurrentPage = nil,
    Flags = {},
    Connections = {},
    ToClean = {},
}

-- Создаем основной ScreenGui
local ScreenGui = Create("ScreenGui", {
    Name = "DarkHub",
    Parent = gethui(),
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    DisplayOrder = 2,
    ResetOnSpawn = false,
})

table.insert(DarkHub.ToClean, ScreenGui)

-- Создаем основной фрейм
local MainFrame = Create("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 620, 0, 550),
    BackgroundColor3 = DarkHub.Theme.Background,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ZIndex = 2,
    Visible = false,
})

-- Скругление углов
Create("UICorner", {
    Parent = MainFrame,
    CornerRadius = UDim.new(0, 6),
})

-- Адаптация для мобильных устройств
if IsMobile() then
    Create("UIScale", {
        Parent = MainFrame,
        Scale = 0.75,
    })
end

-- ============================================================
-- Заголовок
-- ============================================================

local TopBar = Create("Frame", {
    Name = "TopBar",
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = DarkHub.Theme.Background2,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 2,
})

Create("UICorner", {
    Parent = TopBar,
    CornerRadius = UDim.new(0, 6),
})

-- Логотип (иконка)
local Logo = Create("ImageLabel", {
    Name = "Logo",
    Parent = TopBar,
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(0, 12, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    Image = "rbxassetid://81598136527047",
    ZIndex = 3,
})

-- Градиент для логотипа
local LogoGradient = Create("UIGradient", {
    Parent = Logo,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, DarkHub.Theme.Accent),
        ColorSequenceKeypoint.new(1, DarkHub.Theme.AccentGradient),
    }),
})

-- Заголовок
local Title = Create("TextLabel", {
    Name = "Title",
    Parent = TopBar,
    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
    Text = "Dark Hub",
    TextColor3 = DarkHub.Theme.Text,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 46, 0.5, -2),
    AnchorPoint = Vector2.new(0, 0.5),
    AutomaticSize = Enum.AutomaticSize.X,
    ZIndex = 3,
})

-- Подзаголовок
local SubTitle = Create("TextLabel", {
    Name = "SubTitle",
    Parent = TopBar,
    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Light, Enum.FontStyle.Normal),
    Text = "Premium Quality",
    TextColor3 = DarkHub.Theme.Text,
    TextSize = 12,
    TextTransparency = 0.5,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 46, 0.5, 14),
    AnchorPoint = Vector2.new(0, 0.5),
    AutomaticSize = Enum.AutomaticSize.X,
    ZIndex = 3,
})

-- ============================================================
-- Кнопки управления (Закрыть, Свернуть)
-- ============================================================

local CloseButton = Create("TextButton", {
    Name = "CloseButton",
    Parent = TopBar,
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -36, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = DarkHub.Theme.Element,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 3,
})

Create("UICorner", {
    Parent = CloseButton,
    CornerRadius = UDim.new(0, 6),
})

local CloseIcon = Create("ImageLabel", {
    Parent = CloseButton,
    Size = UDim2.new(0, 12, 0, 12),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Image = "rbxassetid://130510492706892",
    ImageColor3 = DarkHub.Theme.Text,
    ImageTransparency = 0.3,
    ZIndex = 4,
})

-- Ближняя подсветка для кнопки закрытия
local CloseAccent = Create("Frame", {
    Parent = CloseButton,
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = DarkHub.Theme.Accent,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 2,
})

Create("UICorner", {
    Parent = CloseAccent,
    CornerRadius = UDim.new(0, 6),
})

-- ============================================================
-- Левая панель с вкладками
-- ============================================================

local LeftPanel = Create("Frame", {
    Name = "LeftPanel",
    Parent = MainFrame,
    Size = UDim2.new(0, 190, 1, -50),
    Position = UDim2.new(0, 0, 0, 50),
    BackgroundColor3 = DarkHub.Theme.Background2,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 2,
})

Create("UICorner", {
    Parent = LeftPanel,
    CornerRadius = UDim.new(0, 6),
})

-- Контейнер для вкладок (с прокруткой)
local TabsScrolling = Create("ScrollingFrame", {
    Parent = LeftPanel,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 2,
})

Create("UIListLayout", {
    Parent = TabsScrolling,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

Create("UIPadding", {
    Parent = TabsScrolling,
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
})

-- ============================================================
-- Основной контент
-- ============================================================

local ContentArea = Create("Frame", {
    Name = "ContentArea",
    Parent = MainFrame,
    Size = UDim2.new(1, -190, 1, -50),
    Position = UDim2.new(0, 190, 0, 50),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 2,
})

-- Область страниц
local PagesContainer = Create("Frame", {
    Parent = ContentArea,
    Size = UDim2.new(1, -16, 1, -16),
    Position = UDim2.new(0, 8, 0, 8),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 2,
})

Create("UIListLayout", {
    Parent = PagesContainer,
    Padding = UDim.new(0, 0),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

-- ============================================================
-- Водяной знак (Watermark)
-- ============================================================

local WatermarkFrame = Create("Frame", {
    Name = "Watermark",
    Parent = ScreenGui,
    Position = UDim2.new(0, 12, 0, 12),
    Size = UDim2.new(0, 0, 0, 28),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundColor3 = DarkHub.Theme.Background2,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 10,
})

Create("UICorner", {
    Parent = WatermarkFrame,
    CornerRadius = UDim.new(0, 4),
})

Create("UIStroke", {
    Parent = WatermarkFrame,
    Color = DarkHub.Theme.Outline,
    Thickness = 1,
    Transparency = 0,
})

local WatermarkAccent = Create("Frame", {
    Parent = WatermarkFrame,
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = DarkHub.Theme.Accent,
    BorderSizePixel = 0,
})

Create("UICorner", {
    Parent = WatermarkAccent,
    CornerRadius = UDim.new(0, 4),
})

Create("UIGradient", {
    Parent = WatermarkAccent,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, DarkHub.Theme.Accent),
        ColorSequenceKeypoint.new(1, DarkHub.Theme.AccentGradient),
    }),
})

local WatermarkContent = Create("Frame", {
    Parent = WatermarkFrame,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
})

Create("UIListLayout", {
    Parent = WatermarkContent,
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 4),
})

Create("UIPadding", {
    Parent = WatermarkContent,
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
    PaddingTop = UDim.new(0, 4),
})

-- ============================================================
-- Уведомления
-- ============================================================

local NotificationHolder = Create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.X,
    Position = UDim2.new(0, 8, 0, 0),
    ZIndex = 50,
})

Create("UIListLayout", {
    Parent = NotificationHolder,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

Create("UIPadding", {
    Parent = NotificationHolder,
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
})

-- ============================================================
-- Функции GUI
-- ============================================================

function DarkHub:IsOpen()
    return self.IsOpen
end

function DarkHub:Open()
    if self.IsOpen then return end
    self.IsOpen = true
    MainFrame.Visible = true
    
    local Descendants = MainFrame:GetDescendants()
    table.insert(Descendants, MainFrame)
    
    for _, Value in Descendants do
        if Value:IsA("Frame") and Value ~= MainFrame then
            Value.BackgroundTransparency = 0
        elseif Value:IsA("TextLabel") or Value:IsA("TextButton") or Value:IsA("TextBox") then
            Value.TextTransparency = 0
        elseif Value:IsA("ImageLabel") or Value:IsA("ImageButton") then
            Value.ImageTransparency = 0
        end
    end
    
    MainFrame.BackgroundTransparency = 0.12
end

function DarkHub:Close()
    if not self.IsOpen then return end
    self.IsOpen = false
    
    local Descendants = MainFrame:GetDescendants()
    table.insert(Descendants, MainFrame)
    
    for _, Value in Descendants do
        if Value:IsA("Frame") and Value ~= MainFrame then
            Value.BackgroundTransparency = 1
        elseif Value:IsA("TextLabel") or Value:IsA("TextButton") or Value:IsA("TextBox") then
            Value.TextTransparency = 1
        elseif Value:IsA("ImageLabel") or Value:IsA("ImageButton") then
            Value.ImageTransparency = 1
        end
    end
    
    MainFrame.BackgroundTransparency = 1
    task.wait(0.2)
    MainFrame.Visible = false
end

function DarkHub:Toggle()
    if self.IsOpen then
        self:Close()
    else
        self:Open()
    end
end

-- ============================================================
-- Создание страницы
-- ============================================================

function DarkHub:CreatePage(Name, Icon)
    local Page = {
        Name = Name,
        Icon = Icon or "100050851789190",
        Frame = nil,
        Button = nil,
        Sections = {},
        Active = false,
    }
    
    -- Кнопка вкладки
    local Button = Create("TextButton", {
        Parent = TabsScrolling,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = DarkHub.Theme.Element,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 3,
    })
    
    Create("UICorner", {
        Parent = Button,
        CornerRadius = UDim.new(0, 4),
    })
    
    -- Акцент для кнопки
    local ButtonAccent = Create("Frame", {
        Parent = Button,
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = DarkHub.Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    
    Create("UICorner", {
        Parent = ButtonAccent,
        CornerRadius = UDim.new(0, 4),
    })
    
    -- Иконка вкладки
    local ButtonIcon = Create("ImageLabel", {
        Parent = Button,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. Icon,
        ImageColor3 = DarkHub.Theme.Text,
        ImageTransparency = 0.3,
        ZIndex = 3,
    })
    
    local ButtonIconGradient = Create("UIGradient", {
        Parent = ButtonIcon,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, DarkHub.Theme.Accent),
            ColorSequenceKeypoint.new(1, DarkHub.Theme.AccentGradient),
        }),
        Enabled = false,
    })
    
    -- Текст вкладки
    local ButtonText = Create("TextLabel", {
        Parent = Button,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = Name,
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 0.3,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0.5, -1),
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 3,
    })
    
    -- Фрейм страницы
    local PageFrame = Create("Frame", {
        Parent = PagesContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 2,
    })
    
    Create("UIListLayout", {
        Parent = PageFrame,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    Page.Button = Button
    Page.Frame = PageFrame
    Page.ButtonIcon = ButtonIcon
    Page.ButtonText = ButtonText
    Page.ButtonAccent = ButtonAccent
    Page.ButtonIconGradient = ButtonIconGradient
    
    -- Функция переключения страницы
    function Page:Activate()
        for _, P in pairs(DarkHub.Pages) do
            if P == self then
                P.Active = true
                P.Frame.Visible = true
                P.Button.BackgroundTransparency = 0.1
                P.ButtonText.TextTransparency = 0
                P.ButtonIcon.ImageTransparency = 0
                P.ButtonIconGradient.Enabled = true
                P.ButtonAccent.BackgroundTransparency = 0
            else
                P.Active = false
                P.Frame.Visible = false
                P.Button.BackgroundTransparency = 1
                P.ButtonText.TextTransparency = 0.3
                P.ButtonIcon.ImageTransparency = 0.3
                P.ButtonIconGradient.Enabled = false
                P.ButtonAccent.BackgroundTransparency = 1
            end
        end
        DarkHub.CurrentPage = self
    end
    
    Button.MouseButton1Click:Connect(function()
        Page:Activate()
    end)
    
    table.insert(DarkHub.Pages, Page)
    
    -- Если это первая страница, активируем её
    if #DarkHub.Pages == 1 then
        Page:Activate()
    end
    
    return Page
end

-- ============================================================
-- Создание секции
-- ============================================================

function DarkHub:CreateSection(Page, Name, Description, Icon)
    local Section = {
        Page = Page,
        Name = Name,
        Description = Description or "",
        Icon = Icon or "123944728972740",
        Frame = nil,
        Elements = {},
        IsActive = true,
    }
    
    local SectionFrame = Create("Frame", {
        Parent = Page.Frame,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = DarkHub.Theme.SectionBackground,
        BackgroundTransparency = 0.65,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    })
    
    Create("UICorner", {
        Parent = SectionFrame,
        CornerRadius = UDim.new(0, 4),
    })
    
    -- Верхняя часть секции
    local SectionTop = Create("Frame", {
        Parent = SectionFrame,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = DarkHub.Theme.Outline,
        BackgroundTransparency = 0.65,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    
    local SectionTopBG = Create("Frame", {
        Parent = SectionTop,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = DarkHub.Theme.SectionTop,
        BackgroundTransparency = 0.65,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    
    Create("UICorner", {
        Parent = SectionTopBG,
        CornerRadius = UDim.new(0, 4),
    })
    
    -- Иконка секции
    local SectionIcon = Create("ImageLabel", {
        Parent = SectionTopBG,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. Icon,
        ZIndex = 4,
    })
    
    Create("UIGradient", {
        Parent = SectionIcon,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, DarkHub.Theme.Accent),
            ColorSequenceKeypoint.new(1, DarkHub.Theme.AccentGradient),
        }),
    })
    
    -- Заголовок секции
    local SectionTitle = Create("TextLabel", {
        Parent = SectionTopBG,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = Name,
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 38, 0, 12),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 4,
    })
    
    -- Описание секции
    if Description ~= "" then
        local SectionDesc = Create("TextLabel", {
            Parent = SectionTopBG,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Light, Enum.FontStyle.Normal),
            Text = Description,
            TextColor3 = DarkHub.Theme.Text,
            TextSize = 12,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 38, 0, 30),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = 4,
        })
    end
    
    -- Контент секции
    local SectionContent = Create("Frame", {
        Parent = SectionFrame,
        Size = UDim2.new(1, -24, 0, 0),
        Position = UDim2.new(0, 12, 0, 55),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 2,
    })
    
    Create("UIListLayout", {
        Parent = SectionContent,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    Create("UIPadding", {
        Parent = SectionContent,
        PaddingBottom = UDim.new(0, 10),
    })
    
    Section.Frame = SectionFrame
    Section.Content = SectionContent
    Section.Top = SectionTop
    
    table.insert(Page.Sections, Section)
    
    return Section
end

-- ============================================================
-- Элементы GUI
-- ============================================================

-- Кнопка
function DarkHub:Button(Section, Data)
    local Element = {
        Section = Section,
        Name = Data.Name or "Button",
        Callback = Data.Callback or function() end,
        Frame = nil,
    }
    
    local Frame = Create("Frame", {
        Parent = Section.Content,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        ZIndex = 2,
    })
    
    local Button = Create("TextButton", {
        Parent = Frame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = DarkHub.Theme.Element,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
    })
    
    Create("UICorner", {
        Parent = Button,
        CornerRadius = UDim.new(0, 4),
    })
    
    -- Акцент при наведении
    local ButtonAccent = Create("Frame", {
        Parent = Button,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = DarkHub.Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    
    Create("UICorner", {
        Parent = ButtonAccent,
        CornerRadius = UDim.new(0, 4),
    })
    
    Create("UIGradient", {
        Parent = ButtonAccent,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, DarkHub.Theme.Accent),
            ColorSequenceKeypoint.new(1, DarkHub.Theme.AccentGradient),
        }),
    })
    
    local ButtonText = Create("TextLabel", {
        Parent = Button,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = Element.Name,
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 14,
        TextTransparency = 0.3,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 3,
    })
    
    -- Наведение
    Button.MouseEnter:Connect(function()
        CreateTween(ButtonAccent, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 0,
        })
    end)
    
    Button.MouseLeave:Connect(function()
        CreateTween(ButtonAccent, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
        })
    end)
    
    -- Нажатие
    Button.MouseButton1Click:Connect(function()
        Element.Callback()
        
        -- Анимация нажатия
        CreateTween(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0.95, 0, 0.95, 0),
        })
        task.wait(0.1)
        CreateTween(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(1, 0, 1, 0),
        })
    end)
    
    Element.Frame = Frame
    table.insert(Section.Elements, Element)
    
    return Element
end

-- Переключатель (Toggle)
function DarkHub:Toggle(Section, Data)
    local Element = {
        Section = Section,
        Name = Data.Name or "Toggle",
        Flag = Data.Flag or "toggle_" .. tostring(#DarkHub.Flags + 1),
        Default = Data.Default or false,
        Callback = Data.Callback or function() end,
        Value = false,
        Frame = nil,
    }
    
    local Frame = Create("Frame", {
        Parent = Section.Content,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        ZIndex = 2,
    })
    
    local Button = Create("TextButton", {
        Parent = Frame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
    })
    
    -- Индикатор
    local Indicator = Create("Frame", {
        Parent = Frame,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = DarkHub.Theme.Element,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    
    Create("UICorner", {
        Parent = Indicator,
        CornerRadius = UDim.new(0, 3),
    })
    
    -- Акцент переключателя
    local IndicatorAccent = Create("Frame", {
        Parent = Indicator,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = DarkHub.Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    
    Create("UICorner", {
        Parent = IndicatorAccent,
        CornerRadius = UDim.new(0, 3),
    })
    
    Create("UIGradient", {
        Parent = IndicatorAccent,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, DarkHub.Theme.Accent),
            ColorSequenceKeypoint.new(1, DarkHub.Theme.AccentGradient),
        }),
    })
    
    -- Галочка
    local CheckIcon = Create("ImageLabel", {
        Parent = IndicatorAccent,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://121760666525660",
        ImageColor3 = DarkHub.Theme.Text,
        ImageTransparency = 1,
        ZIndex = 3,
    })
    
    local Label = Create("TextLabel", {
        Parent = Frame,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = Element.Name,
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 14,
        TextTransparency = 0.3,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0.5, -1),
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 2,
    })
    
    function Element:Set(Value)
        Element.Value = Value
        DarkHub.Flags[Element.Flag] = Value
        
        if Value then
            CreateTween(IndicatorAccent, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 0,
            })
            CreateTween(CheckIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 10, 0, 9),
                ImageTransparency = 0,
            })
        else
            CreateTween(IndicatorAccent, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
            })
            CreateTween(CheckIcon, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 0, 0, 0),
                ImageTransparency = 1,
            })
        end
        
        Element.Callback(Value)
    end
    
    function Element:Get()
        return Element.Value
    end
    
    -- Наведение
    Button.MouseEnter:Connect(function()
        CreateTween(Indicator, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 21, 0, 21),
            Position = UDim2.new(0, -3, 0.5, 0),
        })
    end)
    
    Button.MouseLeave:Connect(function()
        CreateTween(Indicator, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 0, 0.5, 0),
        })
    end)
    
    Button.MouseButton1Click:Connect(function()
        Element:Set(not Element.Value)
    end)
    
    Element:Set(Element.Default)
    Element.Frame = Frame
    table.insert(Section.Elements, Element)
    
    return Element
end

-- Ползунок (Slider)
function DarkHub:Slider(Section, Data)
    local Element = {
        Section = Section,
        Name = Data.Name or "Slider",
        Flag = Data.Flag or "slider_" .. tostring(#DarkHub.Flags + 1),
        Min = Data.Min or 0,
        Max = Data.Max or 100,
        Default = Data.Default or 50,
        Suffix = Data.Suffix or "",
        Decimals = Data.Decimals or 1,
        Callback = Data.Callback or function() end,
        Value = 0,
        Frame = nil,
        Sliding = false,
    }
    
    local Frame = Create("Frame", {
        Parent = Section.Content,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        ZIndex = 2,
    })
    
    local Label = Create("TextLabel", {
        Parent = Frame,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = Element.Name,
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 14,
        TextTransparency = 0.3,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 2,
    })
    
    -- Значение
    local ValueLabel = Create("TextLabel", {
        Parent = Frame,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = tostring(Element.Default) .. Element.Suffix,
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 14,
        TextTransparency = 0.3,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 2,
    })
    
    -- Слайдер
    local SliderTrack = Create("TextButton", {
        Parent = Frame,
        Size = UDim2.new(1, -40, 0, 6),
        Position = UDim2.new(0, 20, 1, -4),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = DarkHub.Theme.Element,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
    })
    
    Create("UICorner", {
        Parent = SliderTrack,
        CornerRadius = UDim.new(1, 0),
    })
    
    -- Заполнение
    local SliderFill = Create("Frame", {
        Parent = SliderTrack,
        Size = UDim2.new((Element.Default - Element.Min) / (Element.Max - Element.Min), 0, 1, 0),
        BackgroundColor3 = DarkHub.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    
    Create("UICorner", {
        Parent = SliderFill,
        CornerRadius = UDim.new(1, 0),
    })
    
    Create("UIGradient", {
        Parent = SliderFill,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, DarkHub.Theme.Accent),
            ColorSequenceKeypoint.new(1, DarkHub.Theme.AccentGradient),
        }),
    })
    
    -- Ручка
    local SliderHandle = Create("Frame", {
        Parent = SliderTrack,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((Element.Default - Element.Min) / (Element.Max - Element.Min), -7, 0.5, -7),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = DarkHub.Theme.Text,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    
    Create("UICorner", {
        Parent = SliderHandle,
        CornerRadius = UDim.new(1, 0),
    })
    
    function Element:Set(Value)
        local Clamped = math.clamp(Value, Element.Min, Element.Max)
        local Rounded = math.round(Clamped / Element.Decimals) * Element.Decimals
        Element.Value = Rounded
        DarkHub.Flags[Element.Flag] = Rounded
        
        local Percent = (Rounded - Element.Min) / (Element.Max - Element.Min)
        
        CreateTween(SliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(Percent, 0, 1, 0),
        })
        
        CreateTween(SliderHandle, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Position = UDim2.new(Percent, -7, 0.5, -7),
        })
        
        ValueLabel.Text = tostring(Rounded) .. Element.Suffix
        
        Element.Callback(Rounded)
    end
    
    function Element:Get()
        return Element.Value
    end
    
    -- События перетаскивания
    SliderTrack.MouseButton1Down:Connect(function(X, Y)
        Element.Sliding = true
        local Position = (X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
        local Value = Element.Min + (Element.Max - Element.Min) * math.clamp(Position, 0, 1)
        Element:Set(Value)
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement and Element.Sliding then
            local Position = (Input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
            local Value = Element.Min + (Element.Max - Element.Min) * math.clamp(Position, 0, 1)
            Element:Set(Value)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Element.Sliding = false
        end
    end)
    
    Element:Set(Element.Default)
    Element.Frame = Frame
    table.insert(Section.Elements, Element)
    
    return Element
end

-- Выпадающий список (Dropdown)
function DarkHub:Dropdown(Section, Data)
    local Element = {
        Section = Section,
        Name = Data.Name or "Dropdown",
        Flag = Data.Flag or "dropdown_" .. tostring(#DarkHub.Flags + 1),
        Items = Data.Items or {"Option 1", "Option 2", "Option 3"},
        Default = Data.Default or nil,
        Callback = Data.Callback or function() end,
        Value = nil,
        Frame = nil,
        IsOpen = false,
        Options = {},
    }
    
    local Frame = Create("Frame", {
        Parent = Section.Content,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        ZIndex = 2,
    })
    
    local Label = Create("TextLabel", {
        Parent = Frame,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = Element.Name,
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 14,
        TextTransparency = 0.3,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -1),
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 2,
    })
    
    local Button = Create("TextButton", {
        Parent = Frame,
        Size = UDim2.new(0, 140, 0, 28),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = DarkHub.Theme.Element,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
    })
    
    Create("UICorner", {
        Parent = Button,
        CornerRadius = UDim.new(0, 4),
    })
    
    local ValueText = Create("TextLabel", {
        Parent = Button,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = "...",
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 14,
        TextTransparency = 0.3,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -1),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, -30, 0, 0),
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 3,
    })
    
    local Arrow = Create("ImageLabel", {
        Parent = Button,
        Size = UDim2.new(0, 12, 0, 8),
        Position = UDim2.new(1, -8, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://123317177279443",
        ImageColor3 = DarkHub.Theme.Text,
        ImageTransparency = 0.3,
        ZIndex = 3,
    })
    
    -- Выпадающий список
    local DropdownFrame = Create("TextButton", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 140, 0, 100),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = DarkHub.Theme.Background2,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 20,
    })
    
    Create("UIStroke", {
        Parent = DropdownFrame,
        Color = DarkHub.Theme.Outline,
        Thickness = 1,
    })
    
    Create("UICorner", {
        Parent = DropdownFrame,
        CornerRadius = UDim.new(0, 4),
    })
    
    local DropdownList = Create("ScrollingFrame", {
        Parent = DropdownFrame,
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 21,
    })
    
    Create("UIListLayout", {
        Parent = DropdownList,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    local RenderStepped
    
    function Element:SetOpen(Open)
        Element.IsOpen = Open
        
        if Open then
            DropdownFrame.Visible = true
            DropdownFrame.Parent = ScreenGui
            
            RenderStepped = RunService.RenderStepped:Connect(function()
                DropdownFrame.Position = UDim2.new(0, Button.AbsolutePosition.X, 0, Button.AbsolutePosition.Y + Button.AbsoluteSize.Y + 4)
                DropdownFrame.Size = UDim2.new(0, Button.AbsoluteSize.X, 0, math.min(120, #Element.Items * 28 + 12))
            end)
            
            CreateTween(Arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Rotation = 180,
            })
        else
            if RenderStepped then
                RenderStepped:Disconnect()
                RenderStepped = nil
            end
            
            CreateTween(Arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Rotation = 0,
            })
            
            DropdownFrame.Visible = false
            DropdownFrame.Parent = ScreenGui
        end
    end
    
    function Element:Set(Value)
        Element.Value = Value
        DarkHub.Flags[Element.Flag] = Value
        
        ValueText.Text = Value or "..."
        Element.Callback(Value)
        
        Element:SetOpen(false)
    end
    
    function Element:Get()
        return Element.Value
    end
    
    -- Создание опций
    for _, Item in pairs(Element.Items) do
        local Option = Create("TextButton", {
            Parent = DropdownList,
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = DarkHub.Theme.Element,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 22,
        })
        
        local OptionText = Create("TextLabel", {
            Parent = Option,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Text = Item,
            TextColor3 = DarkHub.Theme.Text,
            TextSize = 13,
            TextTransparency = 0.3,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0.5, -1),
            AnchorPoint = Vector2.new(0, 0.5),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = 23,
        })
        
        Option.MouseEnter:Connect(function()
            CreateTween(Option, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 0.5,
            })
        end)
        
        Option.MouseLeave:Connect(function()
            CreateTween(Option, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 1,
            })
        end)
        
        Option.MouseButton1Click:Connect(function()
            Element:Set(Item)
        end)
    end
    
    Button.MouseButton1Click:Connect(function()
        Element:SetOpen(not Element.IsOpen)
    end)
    
    -- Закрытие при клике вне
    UserInputService.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Element.IsOpen then
                local MousePos = UserInputService:GetMouseLocation()
                local FramePos = DropdownFrame.AbsolutePosition
                local FrameSize = DropdownFrame.AbsoluteSize
                
                if not (MousePos.X >= FramePos.X and MousePos.X <= FramePos.X + FrameSize.X and
                        MousePos.Y >= FramePos.Y and MousePos.Y <= FramePos.Y + FrameSize.Y) then
                    Element:SetOpen(false)
                end
            end
        end
    end)
    
    if Element.Default then
        Element:Set(Element.Default)
    end
    
    Element.Frame = Frame
    table.insert(Section.Elements, Element)
    
    return Element
end

-- Текстовое поле (Textbox)
function DarkHub:Textbox(Section, Data)
    local Element = {
        Section = Section,
        Name = Data.Name or "Textbox",
        Flag = Data.Flag or "textbox_" .. tostring(#DarkHub.Flags + 1),
        Placeholder = Data.Placeholder or "Enter text...",
        Default = Data.Default or "",
        Callback = Data.Callback or function() end,
        Value = "",
        Frame = nil,
    }
    
    local Frame = Create("Frame", {
        Parent = Section.Content,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        ZIndex = 2,
    })
    
    local Label = Create("TextLabel", {
        Parent = Frame,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = Element.Name,
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 14,
        TextTransparency = 0.3,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -1),
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 2,
    })
    
    local Input = Create("TextBox", {
        Parent = Frame,
        Size = UDim2.new(0, 140, 0, 28),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = "",
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        PlaceholderText = Element.Placeholder,
        PlaceholderColor3 = DarkHub.Theme.Text,
        BackgroundColor3 = DarkHub.Theme.Element,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        ZIndex = 2,
    })
    
    Create("UICorner", {
        Parent = Input,
        CornerRadius = UDim.new(0, 4),
    })
    
    Create("UIPadding", {
        Parent = Input,
        PaddingLeft = UDim.new(0, 10),
    })
    
    function Element:Set(Value)
        Element.Value = Value
        DarkHub.Flags[Element.Flag] = Value
        Input.Text = Value
        Element.Callback(Value)
    end
    
    function Element:Get()
        return Element.Value
    end
    
    Input:GetPropertyChangedSignal("Text"):Connect(function()
        Element:Set(Input.Text)
    end)
    
    if Element.Default then
        Element:Set(Element.Default)
    end
    
    Element.Frame = Frame
    table.insert(Section.Elements, Element)
    
    return Element
end

-- ============================================================
-- Уведомления
-- ============================================================

function DarkHub:Notify(Data)
    local Notification = Create("Frame", {
        Parent = NotificationHolder,
        BackgroundColor3 = DarkHub.Theme.Background2,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.XY,
        ZIndex = 50,
    })
    
    Create("UICorner", {
        Parent = Notification,
        CornerRadius = UDim.new(0, 4),
    })
    
    Create("UIStroke", {
        Parent = Notification,
        Color = DarkHub.Theme.Outline,
        Thickness = 1,
        Transparency = 0,
    })
    
    Create("UIPadding", {
        Parent = Notification,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    })
    
    local Title = Create("TextLabel", {
        Parent = Notification,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = Data.Title or "Notification",
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        ZIndex = 51,
    })
    
    local Desc = Create("TextLabel", {
        Parent = Notification,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Light, Enum.FontStyle.Normal),
        Text = Data.Description or "",
        TextColor3 = DarkHub.Theme.Text,
        TextSize = 13,
        TextTransparency = 0.3,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, Title.TextBounds.Y + 4),
        AutomaticSize = Enum.AutomaticSize.XY,
        ZIndex = 51,
    })
    
    -- Акцентная линия
    local Accent = Create("Frame", {
        Parent = Notification,
        Size = UDim2.new(0, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = DarkHub.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 51,
    })
    
    Create("UICorner", {
        Parent = Accent,
        CornerRadius = UDim.new(1, 0),
    })
    
    Create("UIGradient", {
        Parent = Accent,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, DarkHub.Theme.Accent),
            ColorSequenceKeypoint.new(1, DarkHub.Theme.AccentGradient),
        }),
    })
    
    -- Анимация появления
    Notification.Size = UDim2.new(0, 0, 0, 0)
    Notification.BackgroundTransparency = 1
    
    for _, Child in pairs(Notification:GetDescendants()) do
        if Child:IsA("TextLabel") then
            Child.TextTransparency = 1
        end
    end
    
    task.wait(0.05)
    
    CreateTween(Notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, Notification.AbsoluteSize.X, 0, Notification.AbsoluteSize.Y),
        BackgroundTransparency = 0.35,
    })
    
    for _, Child in pairs(Notification:GetDescendants()) do
        if Child:IsA("TextLabel") then
            CreateTween(Child, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                TextTransparency = 0,
            })
        end
    end
    
    -- Анимация акцента
    CreateTween(Accent, TweenInfo.new(Data.Duration or 3, Enum.EasingStyle.Linear), {
        Size = UDim2.new(1, 0, 0, 3),
    })
    
    -- Удаление
    task.delay((Data.Duration or 3) + 0.3, function()
        CreateTween(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
        })
        
        for _, Child in pairs(Notification:GetDescendants()) do
            if Child:IsA("TextLabel") then
                CreateTween(Child, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    TextTransparency = 1,
                })
            end
        end
        
        task.wait(0.3)
        Notification:Destroy()
    end)
end

-- ============================================================
-- Водяной знак (Watermark)
-- ============================================================

function DarkHub:SetWatermark(Elements)
    -- Очищаем старые элементы
    for _, Child in pairs(WatermarkContent:GetChildren()) do
        Child:Destroy()
    end
    
    for i, Element in pairs(Elements) do
        if i > 1 then
            local Sep = Create("TextLabel", {
                Parent = WatermarkContent,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Light, Enum.FontStyle.Normal),
                Text = "|",
                TextColor3 = DarkHub.Theme.Text,
                TextSize = 14,
                TextTransparency = 0.5,
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.XY,
                ZIndex = 11,
            })
        end
        
        local Item = Create("TextLabel", {
            Parent = WatermarkContent,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Text = tostring(Element),
            TextColor3 = DarkHub.Theme.Text,
            TextSize = 13,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            ZIndex = 11,
        })
    end
end

function DarkHub:ShowWatermark(Show)
    WatermarkFrame.Visible = Show
end

-- ============================================================
-- Управление перетаскиванием
-- ============================================================

do
    local Dragging = false
    local DragStart, DragPosition
    
    TopBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            DragPosition = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - DragStart
            MainFrame.Position = UDim2.new(
                DragPosition.X.Scale,
                DragPosition.X.Offset + Delta.X,
                DragPosition.Y.Scale,
                DragPosition.Y.Offset + Delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
end

-- ============================================================
-- Управление открытием/закрытием
-- ============================================================

CloseButton.MouseButton1Click:Connect(function()
    DarkHub:Close()
end)

-- Горячая клавиша Insert
UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.Insert then
        DarkHub:Toggle()
    end
end)

-- ============================================================
-- Создание GUI
-- ============================================================

-- Главная страница
local MainPage = DarkHub:CreatePage("Main", "100050851789190")

-- Секция "Общее"
local GeneralSection = DarkHub:CreateSection(MainPage, "General", "Main settings and controls", "123944728972740")

DarkHub:Toggle(GeneralSection, {
    Name = "Enable Feature",
    Flag = "feature_enabled",
    Default = true,
    Callback = function(Value)
        DarkHub:Notify({
            Title = "Feature",
            Description = Value and "Enabled" or "Disabled",
            Duration = 1,
        })
    end,
})

DarkHub:Slider(GeneralSection, {
    Name = "Speed",
    Flag = "speed_value",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
    Callback = function(Value)
        -- Обработка значения
    end,
})

DarkHub:Button(GeneralSection, {
    Name = "Execute Action",
    Callback = function()
        DarkHub:Notify({
            Title = "Action",
            Description = "Action executed successfully!",
            Duration = 2,
        })
    end,
})

-- Секция "Настройки"
local SettingsSection = DarkHub:CreateSection(MainPage, "Settings", "Customize your experience", "122669828593160")

DarkHub:Dropdown(SettingsSection, {
    Name = "Theme",
    Flag = "theme_select",
    Items = {"Dark", "Light", "Blue", "Purple"},
    Default = "Dark",
    Callback = function(Value)
        DarkHub:Notify({
            Title = "Theme",
            Description = "Selected: " .. Value,
            Duration = 1.5,
        })
    end,
})

DarkHub:Textbox(SettingsSection, {
    Name = "Custom Text",
    Flag = "custom_text",
    Placeholder = "Enter custom text...",
    Default = "",
    Callback = function(Value)
        -- Обработка текста
    end,
})

-- Секция "Информация"
local InfoSection = DarkHub:CreateSection(MainPage, "Information", "About Dark Hub", "81598136527047")

DarkHub:Button(InfoSection, {
    Name = "Show Info",
    Callback = function()
        DarkHub:Notify({
            Title = "Dark Hub v1.0",
            Description = "Premium quality GUI for Roblox",
            Duration = 3,
        })
    end,
})

-- ============================================================
-- Инициализация
-- ============================================================

-- Открываем GUI с задержкой для анимации
task.delay(0.5, function()
    DarkHub:Open()
    
    -- Показываем уведомление
    DarkHub:Notify({
        Title = "Dark Hub",
        Description = "Loaded successfully!",
        Duration = 2,
    })
    
    -- Показываем водяной знак
    DarkHub:SetWatermark({"Dark Hub", "v1.0", "Premium"})
    DarkHub:ShowWatermark(true)
end)

-- Возвращаем объект
return DarkHub
