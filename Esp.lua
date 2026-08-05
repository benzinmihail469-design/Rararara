-- Dark Hub GUI
-- Created with DarkHub UI Library
-- Optimized for PC/Mobile

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local isMobile = UserInputService.TouchEnabled

-- Create GUI Holder
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Theme Colors
local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Background2 = Color3.fromRGB(22, 22, 28),
    Section = Color3.fromRGB(26, 26, 32),
    SectionTop = Color3.fromRGB(30, 30, 36),
    Element = Color3.fromRGB(32, 32, 38),
    Outline = Color3.fromRGB(40, 40, 46),
    Text = Color3.fromRGB(235, 235, 240),
    TextDim = Color3.fromRGB(180, 180, 190),
    Accent = Color3.fromRGB(100, 80, 255),
    AccentGradient = Color3.fromRGB(150, 60, 255),
}

-- Utility Functions
local function Create(className, properties)
    local obj = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        obj[prop] = value
    end
    return obj
end

local function Tween(obj, properties, duration, style, direction)
    duration = duration or 0.3
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function IsMouseOver(frame)
    local mouse = LocalPlayer:GetMouse()
    local pos = Vector2.new(mouse.X, mouse.Y)
    local absPos = frame.AbsolutePosition
    local absSize = frame.AbsoluteSize
    return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
        and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
end

-- Main Frame
local MainFrame = Create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 680, 0, 580),
    Position = UDim2.new(0.5, -340, 0.5, -290),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 2,
})
Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})

if isMobile then
    Create("UIScale", {Parent = MainFrame, Scale = 0.75})
end

-- Blur Effect (for background)
local BlurPart = Create("Part", {
    Parent = Workspace,
    Material = Enum.Material.Glass,
    Transparency = 1,
    Reflectance = 1,
    CastShadow = false,
    Anchored = true,
    CanCollide = false,
    CanQuery = false,
    Size = Vector3.new(1, 1, 1) * 0.01,
    Color = Color3.new(0, 0, 0),
    CollisionGroup = " ",
})
local BlurMesh = Create("BlockMesh", {Parent = BlurPart})
local BlurEffect = Create("DepthOfFieldEffect", {
    Parent = Lighting,
    Enabled = true,
    FarIntensity = 0,
    FocusDistance = 0,
    InFocusRadius = 1000,
    NearIntensity = 1,
})

-- Left Sidebar
local Sidebar = Create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(0, 220, 1, 0),
    BackgroundColor3 = Theme.Background2,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    ZIndex = 3,
})
Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 8)})

-- Logo
local Logo = Create("ImageLabel", {
    Parent = Sidebar,
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(0.5, -20, 0, 16),
    BackgroundTransparency = 1,
    Image = "rbxassetid://123944728972740",
    ZIndex = 4,
})
Create("UIGradient", {
    Parent = Logo,
    Rotation = -115,
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentGradient),
    }
})

local TitleLabel = Create("TextLabel", {
    Parent = Sidebar,
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 62),
    BackgroundTransparency = 1,
    Text = "Dark Hub",
    TextColor3 = Theme.Text,
    TextSize = 20,
    Font = Enum.Font.GothamSemibold,
    ZIndex = 4,
})
local SubTitleLabel = Create("TextLabel", {
    Parent = Sidebar,
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 0, 82),
    BackgroundTransparency = 1,
    Text = "Premium Script Hub",
    TextColor3 = Theme.TextDim,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextTransparency = 0.5,
    ZIndex = 4,
})

-- Sidebar Pages Container
local PagesContainer = Create("Frame", {
    Parent = Sidebar,
    Size = UDim2.new(1, -16, 0, 0),
    Position = UDim2.new(0, 8, 0, 110),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    ZIndex = 4,
})
local PagesLayout = Create("UIListLayout", {
    Parent = PagesContainer,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})

-- Pages
local Pages = {}
local CurrentPage = nil

local function CreatePage(name, icon)
    local page = {
        Name = name,
        Icon = icon,
        Buttons = {},
        Sections = {},
        Frame = Create("Frame", {
            Parent = MainFrame,
            Size = UDim2.new(1, -240, 1, -20),
            Position = UDim2.new(0, 230, 0, 10),
            BackgroundTransparency = 1,
            ZIndex = 2,
            Visible = false,
        }),
    }
    page.Frame.Visible = false
    
    local button = Create("TextButton", {
        Parent = PagesContainer,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Background2,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
    })
    Create("UICorner", {Parent = button, CornerRadius = UDim.new(0, 6)})
    
    local btnIcon = Create("ImageLabel", {
        Parent = button,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 12, 0.5, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. (icon or "122669828593160"),
        ZIndex = 6,
    })
    Create("UIGradient", {
        Parent = btnIcon,
        Rotation = -115,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.TextDim),
            ColorSequenceKeypoint.new(1, Theme.TextDim),
        }
    })
    
    local btnText = Create("TextLabel", {
        Parent = button,
        Size = UDim2.new(1, -44, 0, 20),
        Position = UDim2.new(0, 44, 0.5, -10),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextDim,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local accentLine = Create("Frame", {
        Parent = button,
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, -12),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        ZIndex = 6,
    })
    Create("UICorner", {Parent = accentLine, CornerRadius = UDim.new(0, 3)})
    
    function page:Select()
        for _, p in pairs(Pages) do
            p.Frame.Visible = false
            local btn = p.Button
            if btn then
                local icon = btn:FindFirstChildOfClass("ImageLabel")
                local text = btn:FindFirstChildOfClass("TextLabel")
                local line = btn:FindFirstChildOfClass("Frame")
                if icon then
                    local grad = icon:FindFirstChildOfClass("UIGradient")
                    if grad then
                        grad.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Theme.TextDim),
                            ColorSequenceKeypoint.new(1, Theme.TextDim),
                        }
                    end
                end
                if text then
                    text.TextColor3 = Theme.TextDim
                end
                if line then
                    line.BackgroundTransparency = 1
                end
                btn.BackgroundTransparency = 1
            end
        end
        
        page.Frame.Visible = true
        CurrentPage = page
        if page.Button then
            local icon = page.Button:FindFirstChildOfClass("ImageLabel")
            local text = page.Button:FindFirstChildOfClass("TextLabel")
            local line = page.Button:FindFirstChildOfClass("Frame")
            if icon then
                local grad = icon:FindFirstChildOfClass("UIGradient")
                if grad then
                    grad.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Theme.Accent),
                        ColorSequenceKeypoint.new(1, Theme.AccentGradient),
                    }
                end
            end
            if text then
                text.TextColor3 = Theme.Text
            end
            if line then
                line.BackgroundTransparency = 0
            end
            page.Button.BackgroundTransparency = 0.15
        end
    end
    
    button.MouseButton1Click:Connect(function()
        page:Select()
    end)
    
    page.Button = button
    table.insert(Pages, page)
    
    -- Create sections container in page
    local sectionsContainer = Create("ScrollingFrame", {
        Parent = page.Frame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 3,
    })
    local sectionsLayout = Create("UIListLayout", {
        Parent = sectionsContainer,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    Create("UIPadding", {
        Parent = sectionsContainer,
        PaddingTop = UDim.new(0, 0),
        PaddingBottom = UDim.new(0, 8),
    })
    page.SectionsContainer = sectionsContainer
    page.SectionsLayout = sectionsLayout
    
    return page
end

local function CreateSection(page, name, icon, side)
    side = side or 1
    local section = {
        Name = name,
        Page = page,
        Elements = {},
        Frame = Create("Frame", {
            Parent = page.SectionsContainer,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Theme.Background2,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 4,
        }),
    }
    Create("UICorner", {Parent = section.Frame, CornerRadius = UDim.new(0, 6)})
    
    -- Section Header
    local header = Create("Frame", {
        Parent = section.Frame,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.SectionTop,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    Create("UICorner", {Parent = header, CornerRadius = UDim.new(0, 6)})
    
    local iconLabel = Create("ImageLabel", {
        Parent = header,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 12, 0.5, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://" .. (icon or "123944728972740"),
        ZIndex = 6,
    })
    Create("UIGradient", {
        Parent = iconLabel,
        Rotation = -115,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentGradient),
        }
    })
    
    local titleText = Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -44, 0, 20),
        Position = UDim2.new(0, 44, 0.5, -10),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local descText = Create("TextLabel", {
        Parent = header,
        Size = UDim2.new(1, -44, 0, 16),
        Position = UDim2.new(0, 44, 0.5, 8),
        BackgroundTransparency = 1,
        Text = "Section description",
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 0.5,
        ZIndex = 6,
    })
    
    -- Content
    local content = Create("Frame", {
        Parent = section.Frame,
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 52),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 5,
    })
    local contentLayout = Create("UIListLayout", {
        Parent = content,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    Create("UIPadding", {
        Parent = content,
        PaddingBottom = UDim.new(0, 10),
    })
    section.Content = content
    section.ContentLayout = contentLayout
    
    function section:AddElement(element)
        table.insert(self.Elements, element)
        return element
    end
    
    return section
end

-- Element Creation Functions
local function CreateToggle(section, name, flag, default, callback)
    local frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        ZIndex = 5,
    })
    
    local button = Create("TextButton", {
        Parent = frame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
    })
    
    local indicator = Create("Frame", {
        Parent = frame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 6,
    })
    Create("UICorner", {Parent = indicator, CornerRadius = UDim.new(0, 4)})
    
    local checkIcon = Create("ImageLabel", {
        Parent = indicator,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, -6, 0.5, -6),
        BackgroundTransparency = 1,
        Image = "rbxassetid://121760666525660",
        ImageColor3 = Theme.Text,
        ImageTransparency = 1,
        ZIndex = 7,
    })
    
    local textLabel = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -28, 0, 20),
        Position = UDim2.new(0, 28, 0.5, -10),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local value = default or false
    
    local function setValue(newValue)
        value = newValue
        if value then
            Tween(indicator, {BackgroundColor3 = Theme.Accent}, 0.15)
            Tween(checkIcon, {Size = UDim2.new(0, 12, 0, 12), ImageTransparency = 0}, 0.2, Enum.EasingStyle.Back)
        else
            Tween(indicator, {BackgroundColor3 = Theme.Element}, 0.15)
            Tween(checkIcon, {Size = UDim2.new(0, 0, 0, 0), ImageTransparency = 1}, 0.15)
        end
        if callback then callback(value) end
    end
    
    button.MouseButton1Click:Connect(function()
        setValue(not value)
    end)
    
    setValue(value)
    
    return {
        Set = setValue,
        Get = function() return value end,
        Frame = frame,
    }
end

local function CreateButton(section, name, callback, icon)
    local frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 5,
    })
    
    local button = Create("TextButton", {
        Parent = frame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.2,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
    })
    Create("UICorner", {Parent = button, CornerRadius = UDim.new(0, 4)})
    
    local accent = Create("Frame", {
        Parent = button,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        ZIndex = 7,
    })
    Create("UICorner", {Parent = accent, CornerRadius = UDim.new(0, 4)})
    
    local textLabel = Create("TextLabel", {
        Parent = button,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0.5, -10, 0.5, -10),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        ZIndex = 7,
    })
    
    button.MouseEnter:Connect(function()
        Tween(accent, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0.3}, 0.2)
    end)
    button.MouseLeave:Connect(function()
        Tween(accent, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return {
        Press = function()
            if callback then callback() end
        end,
        Frame = frame,
    }
end

local function CreateSlider(section, name, flag, min, max, default, decimals, suffix, callback)
    min = min or 0
    max = max or 100
    default = default or 50
    decimals = decimals or 1
    suffix = suffix or ""
    
    local frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        ZIndex = 5,
    })
    
    local textLabel = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local valueLabel = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(0, 70, 0, 20),
        Position = UDim2.new(1, -70, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default) .. suffix,
        TextColor3 = Theme.TextDim,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 6,
    })
    
    local sliderBg = Create("TextButton", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -6),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.3,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
    })
    Create("UICorner", {Parent = sliderBg, CornerRadius = UDim.new(0, 3)})
    
    local sliderFill = Create("Frame", {
        Parent = sliderBg,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 7,
    })
    Create("UICorner", {Parent = sliderFill, CornerRadius = UDim.new(0, 3)})
    
    local value = default
    local sliding = false
    
    local function setValue(newValue)
        value = math.clamp(newValue, min, max)
        if decimals then
            value = math.floor(value / decimals + 0.5) * decimals
            value = math.round(value * (1/decimals)) / (1/decimals)
        end
        local percent = (value - min) / (max - min)
        Tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
        valueLabel.Text = tostring(value) .. suffix
        if callback then callback(value) end
    end
    
    sliderBg.MouseButton1Down:Connect(function(input)
        sliding = true
        local pos = input.Position.X - sliderBg.AbsolutePosition.X
        local percent = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
        setValue(min + (max - min) * percent)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and sliding then
            local pos = input.Position.X - sliderBg.AbsolutePosition.X
            local percent = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
            setValue(min + (max - min) * percent)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    
    setValue(default)
    
    return {
        Set = setValue,
        Get = function() return value end,
        Frame = frame,
    }
end

local function CreateDropdown(section, name, flag, items, default, callback)
    local frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 5,
    })
    
    local textLabel = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -160, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local dropdownBtn = Create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0, 150, 0, 32),
        Position = UDim2.new(1, -150, 0.5, -16),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.2,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
    })
    Create("UICorner", {Parent = dropdownBtn, CornerRadius = UDim.new(0, 4)})
    
    local valueLabel = Create("TextLabel", {
        Parent = dropdownBtn,
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 10, 0.5, -10),
        BackgroundTransparency = 1,
        Text = default or items[1] or "Select",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7,
    })
    
    local arrow = Create("ImageLabel", {
        Parent = dropdownBtn,
        Size = UDim2.new(0, 14, 0, 8),
        Position = UDim2.new(1, -20, 0.5, -4),
        BackgroundTransparency = 1,
        Image = "rbxassetid://123317177279443",
        ImageColor3 = Theme.TextDim,
        ZIndex = 7,
    })
    
    local dropdownOpen = false
    local dropdownFrame = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 150, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Background2,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
    })
    Create("UICorner", {Parent = dropdownFrame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {
        Parent = dropdownFrame,
        Color = Theme.Outline,
        Thickness = 1,
        Transparency = 0.5,
    })
    
    local dropdownList = Create("ScrollingFrame", {
        Parent = dropdownFrame,
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 51,
    })
    local dropdownLayout = Create("UIListLayout", {
        Parent = dropdownList,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    local selected = default or items[1] or ""
    local optionObjects = {}
    
    local function updateDropdown()
        for _, obj in ipairs(optionObjects) do
            obj:Destroy()
        end
        optionObjects = {}
        for _, item in ipairs(items) do
            local btn = Create("TextButton", {
                Parent = dropdownList,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Theme.Background2,
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 52,
            })
            local label = Create("TextLabel", {
                Parent = btn,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0.5, -10),
                BackgroundTransparency = 1,
                Text = item,
                TextColor3 = item == selected and Theme.Accent or Theme.TextDim,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 53,
            })
            btn.MouseButton1Click:Connect(function()
                selected = item
                valueLabel.Text = item
                dropdownOpen = false
                dropdownFrame.Visible = false
                for _, obj in ipairs(optionObjects) do
                    local lbl = obj:FindFirstChildOfClass("TextLabel")
                    if lbl then
                        lbl.TextColor3 = obj.Name == item and Theme.Accent or Theme.TextDim
                    end
                end
                if callback then callback(item) end
            end)
            btn.Name = item
            table.insert(optionObjects, btn)
        end
        dropdownFrame.Size = UDim2.new(0, 150, 0, math.min(#items * 30 + 10, 200))
    end
    updateDropdown()
    
    dropdownBtn.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        dropdownFrame.Visible = dropdownOpen
        if dropdownOpen then
            local absPos = dropdownBtn.AbsolutePosition
            dropdownFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + dropdownBtn.AbsoluteSize.Y + 4)
            dropdownFrame.Size = UDim2.new(0, 150, 0, math.min(#items * 30 + 10, 200))
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dropdownOpen and not IsMouseOver(dropdownFrame) and not IsMouseOver(dropdownBtn) then
                dropdownOpen = false
                dropdownFrame.Visible = false
            end
        end
    end)
    
    return {
        Set = function(value)
            selected = value
            valueLabel.Text = value
            for _, obj in ipairs(optionObjects) do
                local lbl = obj:FindFirstChildOfClass("TextLabel")
                if lbl then
                    lbl.TextColor3 = obj.Name == value and Theme.Accent or Theme.TextDim
                end
            end
            if callback then callback(value) end
        end,
        Get = function() return selected end,
        Frame = frame,
    }
end

local function CreateTextbox(section, name, flag, placeholder, default, callback)
    local frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 5,
    })
    
    local textLabel = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -160, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local input = Create("TextBox", {
        Parent = frame,
        Size = UDim2.new(0, 150, 0, 32),
        Position = UDim2.new(1, -150, 0.5, -16),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.2,
        Text = default or "",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        PlaceholderText = placeholder or "Enter...",
        PlaceholderColor3 = Theme.TextDim,
        ClearTextOnFocus = false,
        ZIndex = 6,
    })
    Create("UICorner", {Parent = input, CornerRadius = UDim.new(0, 4)})
    Create("UIPadding", {Parent = input, PaddingLeft = UDim.new(0, 10)})
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            if callback then callback(input.Text) end
        end
    end)
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        if callback then callback(input.Text) end
    end)
    
    return {
        Set = function(value) input.Text = value end,
        Get = function() return input.Text end,
        Frame = frame,
    }
end

local function CreateColorpicker(section, name, flag, default, callback)
    default = default or Color3.new(1, 1, 1)
    
    local frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 5,
    })
    
    local textLabel = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -140, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local colorBtn = Create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0, 130, 0, 30),
        Position = UDim2.new(1, -130, 0.5, -15),
        BackgroundColor3 = default,
        BackgroundTransparency = 0.1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
    })
    Create("UICorner", {Parent = colorBtn, CornerRadius = UDim.new(0, 4)})
    
    local colorPreview = Create("Frame", {
        Parent = colorBtn,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 5, 0.5, -10),
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        ZIndex = 7,
    })
    Create("UICorner", {Parent = colorPreview, CornerRadius = UDim.new(1, 0)})
    
    local hexLabel = Create("TextLabel", {
        Parent = colorBtn,
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 30, 0.5, -10),
        BackgroundTransparency = 1,
        Text = default:ToHex(),
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7,
    })
    
    local pickerOpen = false
    local pickerFrame = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 200, 0, 180),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Background2,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
    })
    Create("UICorner", {Parent = pickerFrame, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {
        Parent = pickerFrame,
        Color = Theme.Outline,
        Thickness = 1,
        Transparency = 0.5,
    })
    
    local hueSlider = Create("TextButton", {
        Parent = pickerFrame,
        Size = UDim2.new(0, 20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.new(1, 0, 0),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 51,
    })
    Create("UICorner", {Parent = hueSlider, CornerRadius = UDim.new(0, 3)})
    local hueGradient = Create("UIGradient", {
        Parent = hueSlider,
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.new(1, 1, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.new(0, 1, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
            ColorSequenceKeypoint.new(0.67, Color3.new(0, 0, 1)),
            ColorSequenceKeypoint.new(0.83, Color3.new(1, 0, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0)),
        }
    })
    
    local colorPicker = Create("Frame", {
        Parent = pickerFrame,
        Size = UDim2.new(1, -50, 1, -20),
        Position = UDim2.new(0, 40, 0, 10),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 51,
    })
    Create("UICorner", {Parent = colorPicker, CornerRadius = UDim.new(0, 4)})
    
    local satGrad = Create("UIGradient", {
        Parent = colorPicker,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }
    })
    local valGrad = Create("UIGradient", {
        Parent = colorPicker,
        Rotation = 90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }
    })
    
    local pickerDot = Create("Frame", {
        Parent = colorPicker,
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0.5, -4, 0.5, -4),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 52,
    })
    Create("UICorner", {Parent = pickerDot, CornerRadius = UDim.new(1, 0)})
    Create("UIStroke", {Parent = pickerDot, Color = Color3.new(0, 0, 0), Thickness = 1})
    
    local colorValue = default
    local hue = 0
    local sat = 1
    local val = 1
    
    local function updateColor(newHue, newSat, newVal)
        hue = newHue or hue
        sat = newSat or sat
        val = newVal or val
        colorValue = Color3.fromHSV(hue, sat, val)
        colorBtn.BackgroundColor3 = colorValue
        colorPreview.BackgroundColor3 = colorValue
        hexLabel.Text = colorValue:ToHex()
        colorPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        pickerDot.Position = UDim2.new(sat, -4, 1 - val, -4)
        if callback then callback(colorValue) end
    end
    
    local function updateHue(pos)
        local y = math.clamp((pos.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
        hue = 1 - y
        updateColor(hue, sat, val)
    end
    
    local function updatePicker(pos)
        local x = math.clamp((pos.X - colorPicker.AbsolutePosition.X) / colorPicker.AbsoluteSize.X, 0, 1)
        local y = math.clamp((pos.Y - colorPicker.AbsolutePosition.Y) / colorPicker.AbsoluteSize.Y, 0, 1)
        sat = x
        val = 1 - y
        updateColor(hue, sat, val)
    end
    
    local hueDragging = false
    local pickerDragging = false
    
    hueSlider.MouseButton1Down:Connect(function(input)
        hueDragging = true
        updateHue(input)
    end)
    
    colorPicker.MouseButton1Down:Connect(function(input)
        pickerDragging = true
        updatePicker(input)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if hueDragging then updateHue(input) end
            if pickerDragging then updatePicker(input) end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
            pickerDragging = false
        end
    end)
    
    colorBtn.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        pickerFrame.Visible = pickerOpen
        if pickerOpen then
            local absPos = colorBtn.AbsolutePosition
            pickerFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + colorBtn.AbsoluteSize.Y + 4)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if pickerOpen and not IsMouseOver(pickerFrame) and not IsMouseOver(colorBtn) then
                pickerOpen = false
                pickerFrame.Visible = false
            end
        end
    end)
    
    updateColor(0, 1, 1)
    
    return {
        Set = function(color)
            local h, s, v = color:ToHSV()
            updateColor(h, s, v)
        end,
        Get = function() return colorValue end,
        Frame = frame,
    }
end

-- Keybind Element
local function CreateKeybind(section, name, flag, default, callback)
    local frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        ZIndex = 5,
    })
    
    local textLabel = Create("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -200, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local keyBtn = Create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0, 120, 0, 30),
        Position = UDim2.new(1, -120, 0.5, -15),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.2,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
    })
    Create("UICorner", {Parent = keyBtn, CornerRadius = UDim.new(0, 4)})
    
    local keyLabel = Create("TextLabel", {
        Parent = keyBtn,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Text = default and default.Name or "None",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ZIndex = 7,
    })
    
    local modeBtn = Create("TextButton", {
        Parent = frame,
        Size = UDim2.new(0, 70, 0, 30),
        Position = UDim2.new(1, -196, 0.5, -15),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.2,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
    })
    Create("UICorner", {Parent = modeBtn, CornerRadius = UDim.new(0, 4)})
    
    local modeLabel = Create("TextLabel", {
        Parent = modeBtn,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "Toggle",
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ZIndex = 7,
    })
    
    local key = default or Enum.KeyCode.None
    local mode = "Toggle"
    local toggled = false
    local picking = false
    
    local function updateKey()
        keyLabel.Text = key and key.Name or "None"
        if callback then callback(key, mode, toggled) end
    end
    
    keyBtn.MouseButton1Click:Connect(function()
        picking = true
        keyLabel.Text = "..."
        local con
        con = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                picking = false
                keyLabel.Text = key.Name
                if con then con:Disconnect() end
                updateKey()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                key = input.UserInputType
                picking = false
                keyLabel.Text = input.UserInputType.Name
                if con then con:Disconnect() end
                updateKey()
            end
        end)
    end)
    
    modeBtn.MouseButton1Click:Connect(function()
        if mode == "Toggle" then
            mode = "Hold"
            modeLabel.Text = "Hold"
        elseif mode == "Hold" then
            mode = "Always"
            modeLabel.Text = "Always"
        else
            mode = "Toggle"
            modeLabel.Text = "Toggle"
        end
        updateKey()
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if key and key ~= Enum.KeyCode.None then
            if input.KeyCode == key or input.UserInputType == key then
                if mode == "Toggle" then
                    toggled = not toggled
                elseif mode == "Hold" then
                    toggled = true
                elseif mode == "Always" then
                    toggled = true
                end
                updateKey()
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if key and key ~= Enum.KeyCode.None then
            if input.KeyCode == key or input.UserInputType == key then
                if mode == "Hold" then
                    toggled = false
                    updateKey()
                end
            end
        end
    end)
    
    updateKey()
    
    return {
        Set = function(newKey, newMode)
            if newKey then key = newKey end
            if newMode then mode = newMode end
            keyLabel.Text = key and key.Name or "None"
            modeLabel.Text = mode or "Toggle"
            updateKey()
        end,
        Get = function() return key, mode, toggled end,
        Frame = frame,
    }
end

-- Create Pages
local mainPage = CreatePage("Main", "123944728972740")
local settingsPage = CreatePage("Settings", "122669828593160")
local aboutPage = CreatePage("About", "81598136527047")

-- Main Page Sections
local mainSection1 = CreateSection(mainPage, "Combat", "100050851789190")
local mainSection2 = CreateSection(mainPage, "Movement", "101636617799068")
local mainSection3 = CreateSection(mainPage, "Visuals", "130510492706892")

-- Combat Section
CreateToggle(mainSection1, "Auto Aim", "autoaim", false, function(v)
    print("Auto Aim: " .. tostring(v))
end)
CreateToggle(mainSection1, "Silent Aim", "silentaim", false)
CreateToggle(mainSection1, "Aimbot FOV", "aimbotfov", false)
CreateSlider(mainSection1, "Aim Smoothness", "aimsmoothness", 0, 100, 50, 1, "%")
CreateDropdown(mainSection1, "Aim Part", "aimpart", {"Head", "Torso", "HumanoidRootPart"}, "Head")
CreateButton(mainSection1, "Refresh Targets", function()
    print("Refreshing targets...")
end)

-- Movement Section
CreateToggle(mainSection2, "Speed Boost", "speedboost", false)
CreateSlider(mainSection2, "Speed Amount", "speedamount", 0, 100, 50, 1, "%")
CreateToggle(mainSection2, "Jump Boost", "jumpboost", false)
CreateSlider(mainSection2, "Jump Power", "jumppower", 0, 100, 50, 1, "%")
CreateToggle(mainSection2, "Fly Mode", "flymode", false)
CreateKeybind(mainSection2, "Fly Keybind", "flykey", Enum.KeyCode.F)

-- Visuals Section
CreateToggle(mainSection3, "ESP", "esp", false)
CreateToggle(mainSection3, "Box ESP", "boxesp", false)
CreateToggle(mainSection3, "Name ESP", "nameesp", false)
CreateToggle(mainSection3, "Health Bar", "healthbar", false)
CreateColorpicker(mainSection3, "ESP Color", "espcolor", Color3.new(0, 0.8, 1))
CreateSlider(mainSection3, "ESP Distance", "espdistance", 0, 1000, 500, 1, "m")

-- Settings Page
local settingsSection1 = CreateSection(settingsPage, "General", "122669828593160")
CreateToggle(settingsSection1, "Watermark", "watermark", true)
CreateToggle(settingsSection1, "Keybind List", "keybindlist", false)
CreateDropdown(settingsSection1, "Theme", "theme", {"Dark", "Light", "Purple", "Blue"}, "Dark")

local settingsSection2 = CreateSection(settingsPage, "Configs", "121760666525660")
CreateTextbox(settingsSection2, "Config Name", "configname", "Enter name...", "")
CreateButton(settingsSection2, "Save Config", function()
    print("Saving config...")
end)
CreateButton(settingsSection2, "Load Config", function()
    print("Loading config...")
end)
CreateButton(settingsSection2, "Delete Config", function()
    print("Deleting config...")
end)

-- About Page
local aboutSection = CreateSection(aboutPage, "About", "81598136527047")
CreateButton(aboutSection, "Dark Hub v1.0", function()
    print("Dark Hub v1.0 - Premium Script Hub")
end)
CreateButton(aboutSection, "Discord", function()
    print("Discord: discord.gg/darkhub")
end)
CreateButton(aboutSection, "GitHub", function()
    print("GitHub: github.com/darkhub")
end)

-- Select default page
mainPage:Select()

-- Watermark
local watermarkFrame = Create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 0, 0, 28),
    Position = UDim2.new(0, 15, 0, 15),
    BackgroundColor3 = Theme.Background2,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    AutomaticSize = Enum.AutomaticSize.X,
    Visible = true,
    ZIndex = 10,
})
Create("UICorner", {Parent = watermarkFrame, CornerRadius = UDim.new(0, 4)})
Create("UIStroke", {Parent = watermarkFrame, Color = Theme.Outline, Thickness = 1, Transparency = 0.5})

local watermarkAccent = Create("Frame", {
    Parent = watermarkFrame,
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    ZIndex = 11,
})
Create("UICorner", {Parent = watermarkAccent, CornerRadius = UDim.new(0, 4)})
Create("UIGradient", {
    Parent = watermarkAccent,
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentGradient),
    }
})

local watermarkContent = Create("Frame", {
    Parent = watermarkFrame,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 11,
})
Create("UIListLayout", {
    Parent = watermarkContent,
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 6),
})
Create("UIPadding", {
    Parent = watermarkContent,
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
    PaddingTop = UDim.new(0, 2),
})

local wmText = Create("TextLabel", {
    Parent = watermarkContent,
    BackgroundTransparency = 1,
    Text = "Dark Hub v1.0",
    TextColor3 = Theme.Text,
    TextSize = 13,
    Font = Enum.Font.GothamSemibold,
    AutomaticSize = Enum.AutomaticSize.XY,
    ZIndex = 11,
})
local wmSep = Create("TextLabel", {
    Parent = watermarkContent,
    BackgroundTransparency = 1,
    Text = "|",
    TextColor3 = Theme.TextDim,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    AutomaticSize = Enum.AutomaticSize.XY,
    ZIndex = 11,
})
local wmStatus = Create("TextLabel", {
    Parent = watermarkContent,
    BackgroundTransparency = 1,
    Text = "Online",
    TextColor3 = Color3.fromRGB(50, 200, 50),
    TextSize = 13,
    Font = Enum.Font.Gotham,
    AutomaticSize = Enum.AutomaticSize.XY,
    ZIndex = 11,
})

-- Make watermark draggable
local dragging = false
local dragStart
local startPos

watermarkFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = watermarkFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        watermarkFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Keybind List
local keybindListFrame = Create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.new(0, 200, 0, 0),
    Position = UDim2.new(0, 20, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Theme.Background2,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    AutomaticSize = Enum.AutomaticSize.Y,
    Visible = false,
    ZIndex = 10,
})
Create("UICorner", {Parent = keybindListFrame, CornerRadius = UDim.new(0, 6)})
Create("UIStroke", {Parent = keybindListFrame, Color = Theme.Outline, Thickness = 1, Transparency = 0.5})

local kblHeader = Create("Frame", {
    Parent = keybindListFrame,
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = Theme.SectionTop,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = 11,
})
Create("UICorner", {Parent = kblHeader, CornerRadius = UDim.new(0, 6)})

local kblTitle = Create("TextLabel", {
    Parent = kblHeader,
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 12, 0.5, -10),
    BackgroundTransparency = 1,
    Text = "Keybinds",
    TextColor3 = Theme.Text,
    TextSize = 15,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12,
})

local kblList = Create("ScrollingFrame", {
    Parent = keybindListFrame,
    Size = UDim2.new(1, -16, 0, 0),
    Position = UDim2.new(0, 8, 0, 44),
    BackgroundTransparency = 1,
    ScrollBarThickness = 0,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ZIndex = 11,
})
local kblLayout = Create("UIListLayout", {
    Parent = kblList,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
Create("UIPadding", {
    Parent = kblList,
    PaddingBottom = UDim.new(0, 8),
})

-- Add keybinds to list
local function addKeybindToList(name, key)
    local item = Create("Frame", {
        Parent = kblList,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        ZIndex = 12,
    })
    local label = Create("TextLabel", {
        Parent = item,
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextDim,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
    })
    local keyLabel = Create("TextLabel", {
        Parent = item,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -60, 0.5, -10),
        BackgroundTransparency = 1,
        Text = key,
        TextColor3 = Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 13,
    })
    return {
        Set = function(newKey)
            keyLabel.Text = newKey
        end,
        SetStatus = function(status)
            keyLabel.TextColor3 = status and Theme.Accent or Theme.TextDim
        end,
    }
end

-- Create keybind list items
local keybindItems = {}
keybindItems.Fly = addKeybindToList("Fly", "F")

-- Show keybind list if enabled
local function updateKeybindList(visible)
    keybindListFrame.Visible = visible
end

-- Toggle watermark visibility
local watermarkVisible = true
local function toggleWatermark(visible)
    watermarkVisible = visible
    watermarkFrame.Visible = visible
end

-- Close GUI with Insert
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Initial setup
mainPage:Select()

-- Cleanup on exit
local function cleanup()
    BlurPart:Destroy()
    BlurEffect:Destroy()
    ScreenGui:Destroy()
end

-- Store cleanup function
game:GetService("RunService").Heartbeat:Connect(function()
    if not ScreenGui.Parent then
        cleanup()
    end
end)

print("Dark Hub GUI loaded successfully!")
