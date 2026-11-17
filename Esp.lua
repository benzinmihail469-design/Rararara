--[[
    ================================================================================
    ⚡ CYBERCORE UI LIBRARY v2.4 (LUNA-STYLE ARCHITECTURE)
    ================================================================================
    Style:         Dark Glassmorphism & Cybercore Neon (Cyan #00F0FF / Magenta #FF0055)
    Compatibility: Universal (All PC & Mobile Executors: SynapseZ, Wave, Delta, Codex, ArceusX, Fluxus)
    Optimization:  UIScale-aware math, zero RenderStepped spam, Connection Janitor, Tween Engine
    Elements:      Window, Tab, Section, Divider, Label, Paragraph, Button, Toggle,
                   Slider, Dropdown (Single/Multi), Colorpicker (HSV + UIScale fix),
                   Input (TextBox), Keybind, Notification, Search Bar, Mobile Floating Pill
    ================================================================================
]]

local CyberCore = {
    Version = "2.4.0",
    Flags = {},
    Theme = {
        Background       = Color3.fromRGB(10, 11, 16),
        Topbar           = Color3.fromRGB(13, 15, 22),
        Sidebar          = Color3.fromRGB(12, 13, 20),
        Section          = Color3.fromRGB(16, 18, 27),
        Element          = Color3.fromRGB(20, 23, 34),
        ElementHover     = Color3.fromRGB(26, 30, 44),
        Stroke           = Color3.fromRGB(36, 42, 62),
        Accent           = Color3.fromRGB(0, 240, 255),   -- Cyber Cyan
        AccentSecondary  = Color3.fromRGB(255, 0, 85),    -- Cyber Magenta
        AccentDark       = Color3.fromRGB(0, 135, 155),
        Text             = Color3.fromRGB(242, 245, 255),
        SubText          = Color3.fromRGB(140, 150, 178),
        Muted            = Color3.fromRGB(88, 96, 122),
        Success          = Color3.fromRGB(0, 255, 157),
        Warning          = Color3.fromRGB(255, 196, 0),
        Error            = Color3.fromRGB(255, 42, 85),
    },
    Connections = {},
    Unloaded = false
}

-- ============================================================================
-- [1] SERVICES & EXECUTOR FALLBACKS
-- ============================================================================
local cloneref = cloneref or function(ref) return ref end
local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))
local GuiService = cloneref(game:GetService("GuiService"))

local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function GetSafeGuiParent()
    local success, parent = pcall(function()
        if gethui then
            return gethui()
        elseif syn and syn.protect_gui then
            local folder = Instance.new("ScreenGui")
            syn.protect_gui(folder)
            folder.Parent = CoreGui
            return folder
        elseif CoreGui:FindFirstChild("RobloxGui") then
            return CoreGui
        end
        return nil
    end)
    if success and parent then
        return parent
    end
    local plrGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
    return plrGui or CoreGui
end

-- ============================================================================
-- [2] CORE UTILITIES (JANITOR, TWEEN ENGINE, INSTANCE BUILDER, ICONS)
-- ============================================================================
local Utility = {}

function Utility:Connect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(CyberCore.Connections, conn)
    return conn
end

function Utility:Tween(instance, info, properties)
    if not instance then return end
    local tweenInfo = type(info) == "table"
        and TweenInfo.new(info[1] or 0.25, info[2] or Enum.EasingStyle.Quart, info[3] or Enum.EasingDirection.Out)
        or TweenInfo.new(info or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility:Create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if properties and properties.Parent then
        inst.Parent = properties.Parent
    end
    return inst
end

function Utility:Corner(parent, radius)
    return Utility:Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent
    })
end

function Utility:Stroke(parent, color, thickness, transparency)
    return Utility:Create("UIStroke", {
        Color = color or CyberCore.Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

function Utility:Padding(parent, top, bottom, left, right)
    return Utility:Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        Parent = parent
    })
end

function Utility:NeonGradient(parent, rotation)
    return Utility:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CyberCore.Theme.Accent),
            ColorSequenceKeypoint.new(1, CyberCore.Theme.AccentSecondary)
        }),
        Rotation = rotation or 45,
        Parent = parent
    })
end

-- Built-in Cyber Icons (Fallback to clean Unicode/Vector glyphs or rbxassetid)
local IconMap = {
    combat   = "rbxassetid://10734975692",
    visuals  = "rbxassetid://10723346959",
    player   = "rbxassetid://10747373176",
    world    = "rbxassetid://10734949856",
    settings = "rbxassetid://10734950309",
    search   = "rbxassetid://10734943674",
    check    = "rbxassetid://10709790644",
    chevron  = "rbxassetid://10709790948",
    key      = "rbxassetid://10723416652",
    palette  = "rbxassetid://10734910430",
    sparkle  = "rbxassetid://10734966248",
}

function Utility:ResolveIcon(icon)
    if not icon or icon == "" then return "" end
    local lower = tostring(icon):lower()
    if IconMap[lower] then
        return IconMap[lower]
    elseif tonumber(icon) then
        return "rbxassetid://" .. tostring(icon)
    elseif tostring(icon):find("rbxassetid://") then
        return tostring(icon)
    end
    return ""
end

-- UIScale-aware Dragging System (PC Mouse + Mobile Touch)
function Utility:MakeDraggable(triggerFrame, targetFrame, scaleInstance)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    Utility:Connect(triggerFrame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position

            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)

    Utility:Connect(triggerFrame.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    Utility:Connect(UserInputService.InputChanged, function(input)
        if input == dragInput and dragging then
            local scale = (scaleInstance and scaleInstance.Scale > 0) and scaleInstance.Scale or 1
            local delta = (input.Position - dragStart) / scale
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================================
-- [3] SCREEN GUI & NOTIFICATION HOLDER
-- ============================================================================
local ExistingGui = GetSafeGuiParent():FindFirstChild("CyberCore_UI")
if ExistingGui then
    ExistingGui:Destroy()
end

local ScreenGui = Utility:Create("ScreenGui", {
    Name = "CyberCore_UI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = GetSafeGuiParent()
})

local UIScale = Utility:Create("UIScale", {
    Scale = 1,
    Parent = ScreenGui
})

local function UpdateAdaptiveScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    if IsMobile or vp.X < 850 or vp.Y < 560 then
        local scaleX = vp.X / 860
        local scaleY = vp.Y / 580
        UIScale.Scale = math.clamp(math.min(scaleX, scaleY), 0.58, 0.95)
    else
        UIScale.Scale = 1
    end
end
UpdateAdaptiveScale()
if workspace.CurrentCamera then
    Utility:Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), UpdateAdaptiveScale)
end

local NotificationHolder = Utility:Create("Frame", {
    Name = "Notifications",
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -20, 1, -20),
    Size = UDim2.new(0, 310, 1, -40),
    BackgroundTransparency = 1,
    Parent = ScreenGui
}, {
    Utility:Create("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
})

function CyberCore:Notify(config)
    config = config or {}
    local title = config.Title or "CYBERCORE"
    local content = config.Content or ""
    local duration = config.Duration or 4
    local nType = (config.Type or "Info"):lower()

    local accentColor = CyberCore.Theme.Accent
    if nType == "success" then accentColor = CyberCore.Theme.Success
    elseif nType == "warning" then accentColor = CyberCore.Theme.Warning
    elseif nType == "error" then accentColor = CyberCore.Theme.Error end

    local card = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 74),
        Position = UDim2.new(1, 340, 0, 0),
        BackgroundColor3 = CyberCore.Theme.Topbar,
        BackgroundTransparency = 0.06,
        ClipsDescendants = true,
        Parent = NotificationHolder
    })
    Utility:Corner(card, 8)
    local stroke = Utility:Stroke(card, accentColor, 1, 0.35)

    -- Left Cyber Accent Bar
    local sideBar = Utility:Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = card
    })

    Utility:Create("TextLabel", {
        Position = UDim2.new(0, 14, 0, 10),
        Size = UDim2.new(1, -24, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = string.upper(title),
        TextColor3 = accentColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })

    Utility:Create("TextLabel", {
        Position = UDim2.new(0, 14, 0, 30),
        Size = UDim2.new(1, -24, 0, 34),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = content,
        TextColor3 = CyberCore.Theme.Text,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card
    })

    local progressBar = Utility:Create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = card
    })

    Utility:Tween(card, {0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
        Position = UDim2.new(0, 0, 0, 0)
    })
    Utility:Tween(progressBar, {duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out}, {
        Size = UDim2.new(0, 0, 0, 2)
    })

    task.delay(duration, function()
        if not card or not card.Parent then return end
        Utility:Tween(card, {0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In}, {
            BackgroundTransparency = 1
        })
        Utility:Tween(stroke, {0.25}, {Transparency = 1})
        Utility:Tween(sideBar, {0.25}, {BackgroundTransparency = 1})
        task.wait(0.26)
        if card then card:Destroy() end
    end)
end

-- ============================================================================
-- [4] WINDOW BUILDER (LUNA-INSPIRED API + CYBERCORE HUD)
-- ============================================================================
function CyberCore:CreateWindow(config)
    config = config or {}
    local WindowTitle    = config.Name or config.Title or "CYBERCORE"
    local WindowSubtitle = config.Subtitle or "NEURAL INTERFACE // v2.4"
    local ToggleKey      = config.ToggleKey or Enum.KeyCode.RightShift
    local WindowSize     = config.Size or (IsMobile and UDim2.new(0, 650, 0, 430) or UDim2.new(0, 720, 0, 480))

    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Minimized = false,
        ToggleKey = ToggleKey,
        AllSearchableElements = {}
    }

    -- Main Window Container
    local MainFrame = Utility:Create("Frame", {
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = WindowSize,
        BackgroundColor3 = CyberCore.Theme.Background,
        BackgroundTransparency = 0.04,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    Utility:Corner(MainFrame, 12)

    local OuterStroke = Utility:Stroke(MainFrame, Color3.fromRGB(255, 255, 255), 1.4, 0.25)
    Utility:NeonGradient(OuterStroke, 35)

    -- Subtle Cyber Top Glow Bar
    local TopNeonLine = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = MainFrame
    })
    Utility:NeonGradient(TopNeonLine, 0)

    -- ========================================================================
    -- TOPBAR (TITLE, SUBTITLE, SEARCH BAR, MINIMIZE/CLOSE)
    -- ========================================================================
    local Topbar = Utility:Create("Frame", {
        Name = "Topbar",
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = CyberCore.Theme.Topbar,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = MainFrame
    })

    Utility:Create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = CyberCore.Theme.Stroke,
        BorderSizePixel = 0,
        Parent = Topbar
    })

    -- Cyber Status Dot
    local StatusDot = Utility:Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 18, 0.5, 0),
        Size = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = CyberCore.Theme.Accent,
        Parent = Topbar
    })
    Utility:Corner(StatusDot, 99)

    local TitleLabel = Utility:Create("TextLabel", {
        Position = UDim2.new(0, 34, 0, 9),
        Size = UDim2.new(0, 220, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBlack,
        Text = string.upper(WindowTitle),
        TextColor3 = CyberCore.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Topbar
    })

    local SubLabel = Utility:Create("TextLabel", {
        Position = UDim2.new(0, 34, 0, 27),
        Size = UDim2.new(0, 220, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        Text = WindowSubtitle,
        TextColor3 = CyberCore.Theme.Accent,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Topbar
    })

    -- Search Box in Topbar
    local SearchBar = Utility:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -92, 0.5, 0),
        Size = UDim2.new(0, 195, 0, 32),
        BackgroundColor3 = CyberCore.Theme.Element,
        Parent = Topbar
    })
    Utility:Corner(SearchBar, 8)
    local SearchStroke = Utility:Stroke(SearchBar, CyberCore.Theme.Stroke, 1, 0.2)

    local SearchInput = Utility:Create("TextBox", {
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        PlaceholderText = "Search modules...",
        PlaceholderColor3 = CyberCore.Theme.Muted,
        Text = "",
        TextColor3 = CyberCore.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = SearchBar
    })

    Utility:Connect(SearchInput.Focused, function()
        Utility:Tween(SearchStroke, {0.2}, {Color = CyberCore.Theme.Accent, Transparency = 0})
    end)
    Utility:Connect(SearchInput.FocusLost, function()
        Utility:Tween(SearchStroke, {0.2}, {Color = CyberCore.Theme.Stroke, Transparency = 0.2})
    end)

    Utility:Connect(SearchInput:GetPropertyChangedSignal("Text"), function()
        local query = SearchInput.Text:lower()
        for _, entry in ipairs(Window.AllSearchableElements) do
            if entry.Frame and entry.Frame.Parent then
                if query == "" or entry.Title:lower():find(query, 1, true) then
                    entry.Frame.Visible = true
                else
                    entry.Frame.Visible = false
                end
            end
        end
    end)

    -- Minimize / Hide Button
    local MinimizeBtn = Utility:Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -50, 0.5, 0),
        Size = UDim2.new(0, 32, 0, 32),
        BackgroundColor3 = CyberCore.Theme.Element,
        Font = Enum.Font.GothamBold,
        Text = "—",
        TextColor3 = CyberCore.Theme.SubText,
        TextSize = 13,
        AutoButtonColor = false,
        Parent = Topbar
    })
    Utility:Corner(MinimizeBtn, 8)
    Utility:Stroke(MinimizeBtn, CyberCore.Theme.Stroke, 1, 0.3)

    -- Close / Unload Button
    local CloseBtn = Utility:Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 32, 0, 32),
        BackgroundColor3 = CyberCore.Theme.Element,
        Font = Enum.Font.GothamBold,
        Text = "✕",
        TextColor3 = CyberCore.Theme.AccentSecondary,
        TextSize = 13,
        AutoButtonColor = false,
        Parent = Topbar
    })
    Utility:Corner(CloseBtn, 8)
    Utility:Stroke(CloseBtn, CyberCore.Theme.Stroke, 1, 0.3)

    Utility:MakeDraggable(Topbar, MainFrame, UIScale)

    -- ========================================================================
    -- MOBILE & PC FLOATING HUD PILL (QUICK TOGGLE)
    -- ========================================================================
    local FloatingPill = Utility:Create("TextButton", {
        Name = "CyberCore_Pill",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 14),
        Size = UDim2.new(0, 136, 0, 36),
        BackgroundColor3 = CyberCore.Theme.Topbar,
        BackgroundTransparency = 0.08,
        AutoButtonColor = false,
        Text = "",
        Visible = IsMobile,
        ZIndex = 50,
        Parent = ScreenGui
    })
    Utility:Corner(FloatingPill, 99)
    local PillStroke = Utility:Stroke(FloatingPill, Color3.fromRGB(255, 255, 255), 1.4, 0.15)
    Utility:NeonGradient(PillStroke, 45)

    local PillDot = Utility:Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = CyberCore.Theme.Accent,
        Parent = FloatingPill
    })
    Utility:Corner(PillDot, 99)

    Utility:Create("TextLabel", {
        Position = UDim2.new(0, 28, 0, 0),
        Size = UDim2.new(1, -36, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBlack,
        Text = "CYBERCORE",
        TextColor3 = CyberCore.Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = FloatingPill
    })

    Utility:MakeDraggable(FloatingPill, FloatingPill, UIScale)

    function Window:ToggleVisibility(state)
        if state == nil then
            Window.Minimized = not Window.Minimized
        else
            Window.Minimized = not state
        end

        if Window.Minimized then
            FloatingPill.Visible = true
            MainFrame.Visible = false
            Utility:Tween(PillDot, {0.25}, {BackgroundColor3 = CyberCore.Theme.AccentSecondary})
        else
            MainFrame.Visible = true
            if not IsMobile then
                FloatingPill.Visible = false
            end
            Utility:Tween(PillDot, {0.25}, {BackgroundColor3 = CyberCore.Theme.Accent})
        end
    end

    Utility:Connect(MinimizeBtn.Activated, function()
        Window:ToggleVisibility(false)
    end)

    Utility:Connect(FloatingPill.Activated, function()
        Window:ToggleVisibility()
    end)

    Utility:Connect(CloseBtn.Activated, function()
        CyberCore:Destroy()
    end)

    Utility:Connect(UserInputService.InputBegan, function(input, gpe)
        if gpe then return end
        if input.KeyCode == Window.ToggleKey then
            Window:ToggleVisibility()
        end
    end)

    -- ========================================================================
    -- SIDEBAR (NAVIGATION TABS & USER FOOTER)
    -- ========================================================================
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Position = UDim2.new(0, 0, 0, 54),
        Size = UDim2.new(0, 185, 1, -54),
        BackgroundColor3 = CyberCore.Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })

    Utility:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = CyberCore.Theme.Stroke,
        BorderSizePixel = 0,
        Parent = Sidebar
    })

    local TabContainer = Utility:Create("ScrollingFrame", {
        Name = "TabList",
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -68),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CyberCore.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar
    }, {
        Utility:Padding(nil, 4, 8, 10, 10),
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })
    })

    -- User Profile Badge at bottom of Sidebar
    local UserFooter = Utility:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -10),
        Size = UDim2.new(1, -20, 0, 44),
        BackgroundColor3 = CyberCore.Theme.Element,
        Parent = Sidebar
    })
    Utility:Corner(UserFooter, 8)
    Utility:Stroke(UserFooter, CyberCore.Theme.Stroke, 1, 0.35)

    local AvatarBadge = Utility:Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = CyberCore.Theme.AccentDark,
        Parent = UserFooter
    })
    Utility:Corner(AvatarBadge, 99)

    Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBlack,
        Text = string.sub(LocalPlayer and LocalPlayer.Name or "U", 1, 1):upper(),
        TextColor3 = CyberCore.Theme.Text,
        TextSize = 13,
        Parent = AvatarBadge
    })

    Utility:Create("TextLabel", {
        Position = UDim2.new(0, 44, 0, 7),
        Size = UDim2.new(1, -50, 0, 15),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = LocalPlayer and LocalPlayer.DisplayName or "Operator",
        TextColor3 = CyberCore.Theme.Text,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = UserFooter
    })

    Utility:Create("TextLabel", {
        Position = UDim2.new(0, 44, 0, 22),
        Size = UDim2.new(1, -50, 0, 14),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        Text = "ONLINE // SYNCED",
        TextColor3 = CyberCore.Theme.Success,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = UserFooter
    })

    -- ========================================================================
    -- CONTENT PAGES CONTAINER
    -- ========================================================================
    local PagesHolder = Utility:Create("Frame", {
        Name = "PagesHolder",
        Position = UDim2.new(0, 185, 0, 54),
        Size = UDim2.new(1, -185, 1, -54),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = MainFrame
    })

    -- ========================================================================
    -- [5] TAB BUILDER
    -- ========================================================================
    function Window:CreateTab(tabConfig)
        tabConfig = type(tabConfig) == "string" and {Name = tabConfig} or (tabConfig or {})
        local TabName = tabConfig.Name or tabConfig.Title or "Tab"
        local TabIcon = Utility:ResolveIcon(tabConfig.Icon)

        local Tab = {
            Name = TabName,
            Active = false
        }

        local TabBtn = Utility:Create("TextButton", {
            Name = TabName .. "_Btn",
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = CyberCore.Theme.Element,
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            Parent = TabContainer
        })
        Utility:Corner(TabBtn, 8)
        local TabStroke = Utility:Stroke(TabBtn, CyberCore.Theme.Accent, 1, 1)

        local ActiveBar = Utility:Create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 3, 0, 0),
            BackgroundColor3 = CyberCore.Theme.Accent,
            BorderSizePixel = 0,
            Parent = TabBtn
        })
        Utility:Corner(ActiveBar, 4)

        local textOffset = 14
        local IconImg
        if TabIcon ~= "" then
            textOffset = 36
            IconImg = Utility:Create("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 12, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Image = TabIcon,
                ImageColor3 = CyberCore.Theme.SubText,
                Parent = TabBtn
            })
        end

        local TabTitle = Utility:Create("TextLabel", {
            Position = UDim2.new(0, textOffset, 0, 0),
            Size = UDim2.new(1, -(textOffset + 8), 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = TabName,
            TextColor3 = CyberCore.Theme.SubText,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabBtn
        })

        local Page = Utility:Create("ScrollingFrame", {
            Name = TabName .. "_Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CyberCore.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = PagesHolder
        }, {
            Utility:Padding(nil, 14, 18, 14, 14),
            Utility:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            })
        })

        function Tab:Activate()
            for _, t in ipairs(Window.Tabs) do
                t.Active = false
                t.Page.Visible = false
                Utility:Tween(t.Button, {0.2}, {BackgroundTransparency = 1})
                Utility:Tween(t.Stroke, {0.2}, {Transparency = 1})
                Utility:Tween(t.Title, {0.2}, {TextColor3 = CyberCore.Theme.SubText})
                Utility:Tween(t.Indicator, {0.2}, {Size = UDim2.new(0, 3, 0, 0)})
                if t.Icon then
                    Utility:Tween(t.Icon, {0.2}, {ImageColor3 = CyberCore.Theme.SubText})
                end
            end

            Tab.Active = true
            Window.ActiveTab = Tab
            Page.Visible = true
            Utility:Tween(TabBtn, {0.25}, {BackgroundTransparency = 0.15})
            Utility:Tween(TabStroke, {0.25}, {Transparency = 0.55})
            Utility:Tween(TabTitle, {0.25}, {TextColor3 = CyberCore.Theme.Text})
            Utility:Tween(ActiveBar, {0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
                Size = UDim2.new(0, 3, 0, 20)
            })
            if IconImg then
                Utility:Tween(IconImg, {0.25}, {ImageColor3 = CyberCore.Theme.Accent})
            end
        end

        Utility:Connect(TabBtn.Activated, function()
            Tab:Activate()
        end)

        Tab.Button = TabBtn
        Tab.Stroke = TabStroke
        Tab.Title = TabTitle
        Tab.Indicator = ActiveBar
        Tab.Icon = IconImg
        Tab.Page = Page
        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            Tab:Activate()
        end

        -- ====================================================================
        -- [6] ELEMENT ATTACHMENTS (CAN BE USED ON TAB OR SECTION)
        -- ====================================================================
        local function AttachElements(containerParent)
            local Elements = {}

            local function RegisterSearchable(title, frame)
                table.insert(Window.AllSearchableElements, {
                    Title = tostring(title or ""),
                    Frame = frame
                })
            end

            -- ----------------------------------------------------------------
            -- SECTION (COLLAPSIBLE CARD)
            -- ----------------------------------------------------------------
            function Elements:CreateSection(secConfig)
                secConfig = type(secConfig) == "string" and {Name = secConfig} or (secConfig or {})
                local SectionTitle = secConfig.Name or secConfig.Title or "Section"
                local Opened = secConfig.Opened ~= false

                local SectionCard = Utility:Create("Frame", {
                    Name = SectionTitle .. "_Section",
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = CyberCore.Theme.Section,
                    BorderSizePixel = 0,
                    Parent = containerParent
                })
                Utility:Corner(SectionCard, 10)
                Utility:Stroke(SectionCard, CyberCore.Theme.Stroke, 1, 0.2)

                local HeaderBtn = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = SectionCard
                })

                Utility:Create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 12, 0.5, 0),
                    Size = UDim2.new(0, 3, 0, 14),
                    BackgroundColor3 = CyberCore.Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = HeaderBtn
                })

                Utility:Create("TextLabel", {
                    Position = UDim2.new(0, 22, 0, 0),
                    Size = UDim2.new(1, -55, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = string.upper(SectionTitle),
                    TextColor3 = CyberCore.Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = HeaderBtn
                })

                local ArrowLabel = Utility:Create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0, 18, 0, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = Opened and "▾" or "▸",
                    TextColor3 = CyberCore.Theme.Accent,
                    TextSize = 14,
                    Parent = HeaderBtn
                })

                local SectionContent = Utility:Create("Frame", {
                    Position = UDim2.new(0, 0, 0, 34),
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Visible = Opened,
                    Parent = SectionCard
                }, {
                    Utility:Padding(nil, 2, 12, 10, 10),
                    Utility:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 8)
                    })
                })

                Utility:Connect(HeaderBtn.Activated, function()
                    Opened = not Opened
                    SectionContent.Visible = Opened
                    ArrowLabel.Text = Opened and "▾" or "▸"
                end)

                return AttachElements(SectionContent)
            end

            -- ----------------------------------------------------------------
            -- DIVIDER
            -- ----------------------------------------------------------------
            function Elements:CreateDivider()
                local div = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = CyberCore.Theme.Stroke,
                    BorderSizePixel = 0,
                    Parent = containerParent
                })
                return div
            end

            -- ----------------------------------------------------------------
            -- LABEL
            -- ----------------------------------------------------------------
            function Elements:CreateLabel(text)
                local LabelObj = {}
                local Frame = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = CyberCore.Theme.Element,
                    BackgroundTransparency = 0.35,
                    Parent = containerParent
                })
                Utility:Corner(Frame, 7)
                Utility:Stroke(Frame, CyberCore.Theme.Stroke, 1, 0.4)

                local Lbl = Utility:Create("TextLabel", {
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    Text = tostring(text or "Label"),
                    TextColor3 = CyberCore.Theme.SubText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Frame
                })

                function LabelObj:Set(newText)
                    Lbl.Text = tostring(newText)
                end
                RegisterSearchable(text, Frame)
                return LabelObj
            end

            -- ----------------------------------------------------------------
            -- PARAGRAPH
            -- ----------------------------------------------------------------
            function Elements:CreateParagraph(pConfig)
                pConfig = pConfig or {}
                local PTitle = pConfig.Title or "Information"
                local PContent = pConfig.Content or ""
                local ParagraphObj = {}

                local Card = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = CyberCore.Theme.Element,
                    Parent = containerParent
                }, {
                    Utility:Padding(nil, 10, 10, 12, 12),
                    Utility:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 4)
                    })
                })
                Utility:Corner(Card, 8)
                Utility:Stroke(Card, CyberCore.Theme.Stroke, 1, 0.3)

                local TLabel = Utility:Create("TextLabel", {
                    LayoutOrder = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = PTitle,
                    TextColor3 = CyberCore.Theme.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Card
                })

                local CLabel = Utility:Create("TextLabel", {
                    LayoutOrder = 2,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = PContent,
                    TextColor3 = CyberCore.Theme.SubText,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Card
                })

                function ParagraphObj:Set(newConfig)
                    if newConfig.Title then TLabel.Text = newConfig.Title end
                    if newConfig.Content then CLabel.Text = newConfig.Content end
                end
                RegisterSearchable(PTitle, Card)
                return ParagraphObj
            end

            -- ----------------------------------------------------------------
            -- BUTTON
            -- ----------------------------------------------------------------
            function Elements:CreateButton(bConfig)
                bConfig = bConfig or {}
                local BName = bConfig.Name or bConfig.Title or "Button"
                local BDesc = bConfig.Description or ""
                local Callback = bConfig.Callback or function() end

                local BtnFrame = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, BDesc ~= "" and 50 or 38),
                    BackgroundColor3 = CyberCore.Theme.Element,
                    AutoButtonColor = false,
                    Text = "",
                    Parent = containerParent
                })
                Utility:Corner(BtnFrame, 8)
                local BtnStroke = Utility:Stroke(BtnFrame, CyberCore.Theme.Stroke, 1, 0.2)

                Utility:Create("TextLabel", {
                    Position = UDim2.new(0, 12, 0, BDesc ~= "" and 8 or 0),
                    Size = UDim2.new(1, -60, 0, BDesc ~= "" and 18 or 38),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = BName,
                    TextColor3 = CyberCore.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = BtnFrame
                })

                if BDesc ~= "" then
                    Utility:Create("TextLabel", {
                        Position = UDim2.new(0, 12, 0, 26),
                        Size = UDim2.new(1, -60, 0, 16),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        Text = BDesc,
                        TextColor3 = CyberCore.Theme.SubText,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = BtnFrame
                    })
                end

                local ExecBadge = Utility:Create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0, 26, 0, 22),
                    BackgroundColor3 = CyberCore.Theme.Section,
                    Parent = BtnFrame
                })
                Utility:Corner(ExecBadge, 6)
                local BadgeStroke = Utility:Stroke(ExecBadge, CyberCore.Theme.Accent, 1, 0.45)

                Utility:Create("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = "⚡",
                    TextColor3 = CyberCore.Theme.Accent,
                    TextSize = 11,
                    Parent = ExecBadge
                })

                Utility:Connect(BtnFrame.MouseEnter, function()
                    Utility:Tween(BtnFrame, {0.2}, {BackgroundColor3 = CyberCore.Theme.ElementHover})
                    Utility:Tween(BtnStroke, {0.2}, {Color = CyberCore.Theme.Accent, Transparency = 0.25})
                end)
                Utility:Connect(BtnFrame.MouseLeave, function()
                    Utility:Tween(BtnFrame, {0.2}, {BackgroundColor3 = CyberCore.Theme.Element})
                    Utility:Tween(BtnStroke, {0.2}, {Color = CyberCore.Theme.Stroke, Transparency = 0.2})
                end)

                Utility:Connect(BtnFrame.Activated, function()
                    Utility:Tween(BadgeStroke, {0.12}, {Transparency = 0})
                    Utility:Tween(BtnFrame, {0.12}, {BackgroundColor3 = Color3.fromRGB(30, 36, 54)})
                    task.delay(0.14, function()
                        Utility:Tween(BadgeStroke, {0.25}, {Transparency = 0.45})
                        Utility:Tween(BtnFrame, {0.25}, {BackgroundColor3 = CyberCore.Theme.Element})
                    end)
                    task.spawn(Callback)
                end)

                RegisterSearchable(BName, BtnFrame)
                return BtnFrame
            end

            -- ----------------------------------------------------------------
            -- TOGGLE
            -- ----------------------------------------------------------------
            function Elements:CreateToggle(tConfig)
                tConfig = tConfig or {}
                local TName = tConfig.Name or tConfig.Title or "Toggle"
                local TDesc = tConfig.Description or ""
                local Default = tConfig.CurrentValue or tConfig.Default or false
                local Flag = tConfig.Flag or TName
                local Callback = tConfig.Callback or function() end

                local ToggleObj = {Value = Default}
                CyberCore.Flags[Flag] = Default

                local Row = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, TDesc ~= "" and 50 or 38),
                    BackgroundColor3 = CyberCore.Theme.Element,
                    AutoButtonColor = false,
                    Text = "",
                    Parent = containerParent
                })
                Utility:Corner(Row, 8)
                local RowStroke = Utility:Stroke(Row, CyberCore.Theme.Stroke, 1, 0.2)

                Utility:Create("TextLabel", {
                    Position = UDim2.new(0, 12, 0, TDesc ~= "" and 8 or 0),
                    Size = UDim2.new(1, -70, 0, TDesc ~= "" and 18 or 38),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = TName,
                    TextColor3 = CyberCore.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row
                })

                if TDesc ~= "" then
                    Utility:Create("TextLabel", {
                        Position = UDim2.new(0, 12, 0, 26),
                        Size = UDim2.new(1, -70, 0, 16),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        Text = TDesc,
                        TextColor3 = CyberCore.Theme.SubText,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Row
                    })
                end

                local SwitchBg = Utility:Create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0, 42, 0, 22),
                    BackgroundColor3 = Default and CyberCore.Theme.Accent or CyberCore.Theme.Section,
                    Parent = Row
                })
                Utility:Corner(SwitchBg, 99)
                local SwitchStroke = Utility:Stroke(SwitchBg, Default and CyberCore.Theme.Accent or CyberCore.Theme.Stroke, 1, 0.2)

                local Knob = Utility:Create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = Default and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    BackgroundColor3 = Default and CyberCore.Theme.Background or CyberCore.Theme.SubText,
                    Parent = SwitchBg
                })
                Utility:Corner(Knob, 99)

                function ToggleObj:Set(state)
                    ToggleObj.Value = state
                    CyberCore.Flags[Flag] = state
                    Utility:Tween(SwitchBg, {0.22}, {
                        BackgroundColor3 = state and CyberCore.Theme.Accent or CyberCore.Theme.Section
                    })
                    Utility:Tween(SwitchStroke, {0.22}, {
                        Color = state and CyberCore.Theme.Accent or CyberCore.Theme.Stroke
                    })
                    Utility:Tween(Knob, {0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
                        Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                        BackgroundColor3 = state and CyberCore.Theme.Background or CyberCore.Theme.SubText
                    })
                    Utility:Tween(RowStroke, {0.22}, {
                        Color = state and CyberCore.Theme.Accent or CyberCore.Theme.Stroke,
                        Transparency = state and 0.45 or 0.2
                    })
                    task.spawn(Callback, state)
                end

                Utility:Connect(Row.Activated, function()
                    ToggleObj:Set(not ToggleObj.Value)
                end)

                if Default then
                    task.spawn(Callback, Default)
                end

                RegisterSearchable(TName, Row)
                return ToggleObj
            end

            -- ----------------------------------------------------------------
            -- SLIDER (UISCALE & TOUCH OPTIMIZED)
            -- ----------------------------------------------------------------
            function Elements:CreateSlider(sConfig)
                sConfig = sConfig or {}
                local SName = sConfig.Name or sConfig.Title or "Slider"
                local Range = sConfig.Range or {sConfig.Min or 0, sConfig.Max or 100}
                local Min = Range[1] or 0
                local Max = Range[2] or 100
                local Increment = sConfig.Increment or 1
                local Suffix = sConfig.Suffix or ""
                local Default = math.clamp(sConfig.CurrentValue or sConfig.Default or Min, Min, Max)
                local Flag = sConfig.Flag or SName
                local Callback = sConfig.Callback or function() end

                local SliderObj = {Value = Default}
                CyberCore.Flags[Flag] = Default

                local Card = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundColor3 = CyberCore.Theme.Element,
                    Parent = containerParent
                })
                Utility:Corner(Card, 8)
                local CardStroke = Utility:Stroke(Card, CyberCore.Theme.Stroke, 1, 0.2)

                Utility:Create("TextLabel", {
                    Position = UDim2.new(0, 12, 0, 7),
                    Size = UDim2.new(1, -100, 0, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = SName,
                    TextColor3 = CyberCore.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Card
                })

                local ValueLabel = Utility:Create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -12, 0, 7),
                    Size = UDim2.new(0, 90, 0, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code,
                    Text = tostring(Default) .. Suffix,
                    TextColor3 = CyberCore.Theme.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Card
                })

                local TrackHitbox = Utility:Create("TextButton", {
                    Position = UDim2.new(0, 12, 0, 28),
                    Size = UDim2.new(1, -24, 0, 18),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Card
                })

                local Track = Utility:Create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 0, 6),
                    BackgroundColor3 = CyberCore.Theme.Section,
                    Parent = TrackHitbox
                })
                Utility:Corner(Track, 99)

                local initialPercent = (Default - Min) / math.max(Max - Min, 0.0001)
                local Fill = Utility:Create("Frame", {
                    Size = UDim2.new(initialPercent, 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = Track
                })
                Utility:Corner(Fill, 99)
                Utility:NeonGradient(Fill, 0)

                local Knob = Utility:Create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(initialPercent, 0, 0.5, 0),
                    Size = UDim2.new(0, 13, 0, 13),
                    BackgroundColor3 = CyberCore.Theme.Text,
                    Parent = Track
                })
                Utility:Corner(Knob, 99)
                Utility:Stroke(Knob, CyberCore.Theme.Accent, 2, 0)

                local function RoundToStep(val)
                    local snapped = math.floor((val - Min) / Increment + 0.5) * Increment + Min
                    local decimals = tostring(Increment):match("%.(%d+)")
                    if decimals then
                        return tonumber(string.format("%." .. #decimals .. "f", snapped))
                    end
                    return math.clamp(snapped, Min, Max)
                end

                function SliderObj:Set(val)
                    val = math.clamp(RoundToStep(val), Min, Max)
                    SliderObj.Value = val
                    CyberCore.Flags[Flag] = val
                    local pct = (val - Min) / math.max(Max - Min, 0.0001)
                    ValueLabel.Text = tostring(val) .. Suffix
                    Utility:Tween(Fill, {0.08}, {Size = UDim2.new(pct, 0, 1, 0)})
                    Utility:Tween(Knob, {0.08}, {Position = UDim2.new(pct, 0, 0.5, 0)})
                    task.spawn(Callback, val)
                end

                local function UpdateFromInput(inputPos)
                    local absPos = Track.AbsolutePosition.X
                    local absSize = math.max(Track.AbsoluteSize.X, 1)
                    local pct = math.clamp((inputPos.X - absPos) / absSize, 0, 1)
                    local rawVal = Min + (Max - Min) * pct
                    SliderObj:Set(rawVal)
                end

                local sliding = false
                Utility:Connect(TrackHitbox.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        Utility:Tween(CardStroke, {0.15}, {Color = CyberCore.Theme.Accent})
                        UpdateFromInput(input.Position)
                    end
                end)

                Utility:Connect(UserInputService.InputChanged, function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateFromInput(input.Position)
                    end
                end)

                Utility:Connect(UserInputService.InputEnded, function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        sliding = false
                        Utility:Tween(CardStroke, {0.2}, {Color = CyberCore.Theme.Stroke})
                    end
                end)

                RegisterSearchable(SName, Card)
                return SliderObj
            end

            -- ----------------------------------------------------------------
            -- DROPDOWN (SINGLE & MULTI-SELECT)
            -- ----------------------------------------------------------------
            function Elements:CreateDropdown(dConfig)
                dConfig = dConfig or {}
                local DName = dConfig.Name or dConfig.Title or "Dropdown"
                local Options = dConfig.Options or {}
                local Multi = dConfig.MultipleOptions or dConfig.Multi or false
                local Default = dConfig.CurrentOption or dConfig.Default
                local Flag = dConfig.Flag or DName
                local Callback = dConfig.Callback or function() end

                local DropdownObj = {
                    Options = Options,
                    Value = Multi and (type(Default) == "table" and Default or {}) or (Default or Options[1] or "None"),
                    Opened = false
                }
                CyberCore.Flags[Flag] = DropdownObj.Value

                local Wrapper = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundColor3 = CyberCore.Theme.Element,
                    ClipsDescendants = true,
                    Parent = containerParent
                })
                Utility:Corner(Wrapper, 8)
                local WrapStroke = Utility:Stroke(Wrapper, CyberCore.Theme.Stroke, 1, 0.2)

                local Header = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Text = "",
                    Parent = Wrapper
                })

                Utility:Create("TextLabel", {
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(0.5, -12, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = DName,
                    TextColor3 = CyberCore.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Header
                })

                local function FormatValueText()
                    if Multi then
                        if #DropdownObj.Value == 0 then return "None" end
                        return table.concat(DropdownObj.Value, ", ")
                    end
                    return tostring(DropdownObj.Value or "None")
                end

                local SelectedLabel = Utility:Create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -28, 0, 0),
                    Size = UDim2.new(0.5, -20, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code,
                    Text = FormatValueText(),
                    TextColor3 = CyberCore.Theme.Accent,
                    TextSize = 12,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Header
                })

                local Arrow = Utility:Create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = "▾",
                    TextColor3 = CyberCore.Theme.SubText,
                    TextSize = 13,
                    Parent = Header
                })

                local OptionList = Utility:Create("ScrollingFrame", {
                    Position = UDim2.new(0, 8, 0, 40),
                    Size = UDim2.new(1, -16, 0, 120),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = CyberCore.Theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = Wrapper
                }, {
                    Utility:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 4)
                    })
                })

                local function RebuildOptions()
                    for _, child in ipairs(OptionList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end

                    for _, opt in ipairs(DropdownObj.Options) do
                        local isSelected = false
                        if Multi then
                            isSelected = table.find(DropdownObj.Value, opt) ~= nil
                        else
                            isSelected = (DropdownObj.Value == opt)
                        end

                        local OptBtn = Utility:Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = isSelected and CyberCore.Theme.Section or CyberCore.Theme.Background,
                            AutoButtonColor = false,
                            Font = Enum.Font.GothamMedium,
                            Text = "   " .. tostring(opt),
                            TextColor3 = isSelected and CyberCore.Theme.Accent or CyberCore.Theme.SubText,
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = OptionList
                        })
                        Utility:Corner(OptBtn, 6)

                        Utility:Connect(OptBtn.Activated, function()
                            if Multi then
                                local idx = table.find(DropdownObj.Value, opt)
                                if idx then
                                    table.remove(DropdownObj.Value, idx)
                                else
                                    table.insert(DropdownObj.Value, opt)
                                end
                            else
                                DropdownObj.Value = opt
                                DropdownObj.Opened = false
                                Utility:Tween(Wrapper, {0.22}, {Size = UDim2.new(1, 0, 0, 38)})
                                Utility:Tween(WrapStroke, {0.22}, {Color = CyberCore.Theme.Stroke})
                            end
                            CyberCore.Flags[Flag] = DropdownObj.Value
                            SelectedLabel.Text = FormatValueText()
                            RebuildOptions()
                            task.spawn(Callback, DropdownObj.Value)
                        end)
                    end
                end

                RebuildOptions()

                Utility:Connect(Header.Activated, function()
                    DropdownObj.Opened = not DropdownObj.Opened
                    local targetHeight = 38
                    if DropdownObj.Opened then
                        local listHeight = math.min(#DropdownObj.Options * 32, 132)
                        targetHeight = 46 + listHeight
                        OptionList.Size = UDim2.new(1, -16, 0, listHeight)
                    end
                    Utility:Tween(Wrapper, {0.25}, {Size = UDim2.new(1, 0, 0, targetHeight)})
                    Utility:Tween(WrapStroke, {0.25}, {
                        Color = DropdownObj.Opened and CyberCore.Theme.Accent or CyberCore.Theme.Stroke
                    })
                end)

                function DropdownObj:Refresh(newOptions, newDefault)
                    DropdownObj.Options = newOptions or {}
                    if newDefault ~= nil then
                        DropdownObj.Value = newDefault
                    end
                    SelectedLabel.Text = FormatValueText()
                    RebuildOptions()
                end

                function DropdownObj:Set(val)
                    DropdownObj.Value = val
                    CyberCore.Flags[Flag] = val
                    SelectedLabel.Text = FormatValueText()
                    RebuildOptions()
                    task.spawn(Callback, val)
                end

                RegisterSearchable(DName, Wrapper)
                return DropdownObj
            end

            -- ----------------------------------------------------------------
            -- COLORPICKER (HSV + UISCALE-SAFE DRAG)
            -- ----------------------------------------------------------------
            function Elements:CreateColorPicker(cConfig)
                cConfig = cConfig or {}
                local CName = cConfig.Name or cConfig.Title or "Colorpicker"
                local Default = cConfig.Color or cConfig.Default or CyberCore.Theme.Accent
                local Flag = cConfig.Flag or CName
                local Callback = cConfig.Callback or function() end

                local H, S, V = Default:ToHSV()
                local ColorObj = {
                    Value = Default,
                    Opened = false
                }
                CyberCore.Flags[Flag] = Default

                local Wrapper = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundColor3 = CyberCore.Theme.Element,
                    ClipsDescendants = true,
                    Parent = containerParent
                })
                Utility:Corner(Wrapper, 8)
                local WrapStroke = Utility:Stroke(Wrapper, CyberCore.Theme.Stroke, 1, 0.2)

                local Header = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Text = "",
                    Parent = Wrapper
                })

                Utility:Create("TextLabel", {
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -90, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = CName,
                    TextColor3 = CyberCore.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Header
                })

                local PreviewBox = Utility:Create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.new(0, 44, 0, 20),
                    BackgroundColor3 = Default,
                    Parent = Header
                })
                Utility:Corner(PreviewBox, 6)
                Utility:Stroke(PreviewBox, Color3.fromRGB(255, 255, 255), 1, 0.5)

                -- Saturation / Value Canvas
                local SVBox = Utility:Create("TextButton", {
                    Position = UDim2.new(0, 12, 0, 44),
                    Size = UDim2.new(1, -24, 0, 95),
                    BackgroundColor3 = Color3.fromHSV(H, 1, 1),
                    AutoButtonColor = false,
                    Text = "",
                    Parent = Wrapper
                })
                Utility:Corner(SVBox, 6)

                local SatOverlay = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = SVBox
                })
                Utility:Corner(SatOverlay, 6)
                Utility:Create("UIGradient", {
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                    Parent = SatOverlay
                })

                local ValOverlay = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Parent = SVBox
                })
                Utility:Corner(ValOverlay, 6)
                Utility:Create("UIGradient", {
                    Rotation = 90,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }),
                    Parent = ValOverlay
                })

                local SVCursor = Utility:Create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(S, 0, 1 - V, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.2,
                    Parent = SVBox
                })
                Utility:Corner(SVCursor, 99)
                Utility:Stroke(SVCursor, Color3.fromRGB(0, 0, 0), 1.5, 0)

                -- Hue Slider Bar
                local HueBar = Utility:Create("TextButton", {
                    Position = UDim2.new(0, 12, 0, 147),
                    Size = UDim2.new(1, -24, 0, 12),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    AutoButtonColor = false,
                    Text = "",
                    Parent = Wrapper
                })
                Utility:Corner(HueBar, 99)
                Utility:Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
                    }),
                    Parent = HueBar
                })

                local HueCursor = Utility:Create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(H, 0, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = HueBar
                })
                Utility:Corner(HueCursor, 99)
                Utility:Stroke(HueCursor, Color3.fromRGB(0, 0, 0), 1.5, 0)

                local function ApplyColor()
                    local col = Color3.fromHSV(H, S, V)
                    ColorObj.Value = col
                    CyberCore.Flags[Flag] = col
                    PreviewBox.BackgroundColor3 = col
                    SVBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                    SVCursor.Position = UDim2.new(S, 0, 1 - V, 0)
                    HueCursor.Position = UDim2.new(H, 0, 0.5, 0)
                    task.spawn(Callback, col)
                end

                local draggingSV, draggingHue = false, false

                local function UpdateSV(pos)
                    local absPos = SVBox.AbsolutePosition
                    local absSize = SVBox.AbsoluteSize
                    S = math.clamp((pos.X - absPos.X) / math.max(absSize.X, 1), 0, 1)
                    V = 1 - math.clamp((pos.Y - absPos.Y) / math.max(absSize.Y, 1), 0, 1)
                    ApplyColor()
                end

                local function UpdateHue(pos)
                    local absPos = HueBar.AbsolutePosition.X
                    local absSize = HueBar.AbsoluteSize.X
                    H = math.clamp((pos.X - absPos) / math.max(absSize, 1), 0, 1)
                    ApplyColor()
                end

                Utility:Connect(SVBox.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = true
                        UpdateSV(input.Position)
                    end
                end)

                Utility:Connect(HueBar.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingHue = true
                        UpdateHue(input.Position)
                    end
                end)

                Utility:Connect(UserInputService.InputChanged, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if draggingSV then UpdateSV(input.Position)
                        elseif draggingHue then UpdateHue(input.Position) end
                    end
                end)

                Utility:Connect(UserInputService.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = false
                        draggingHue = false
                    end
                end)

                Utility:Connect(Header.Activated, function()
                    ColorObj.Opened = not ColorObj.Opened
                    Utility:Tween(Wrapper, {0.25}, {
                        Size = UDim2.new(1, 0, 0, ColorObj.Opened and 172 or 38)
                    })
                    Utility:Tween(WrapStroke, {0.25}, {
                        Color = ColorObj.Opened and CyberCore.Theme.Accent or CyberCore.Theme.Stroke
                    })
                end)

                function ColorObj:Set(newColor)
                    H, S, V = newColor:ToHSV()
                    ApplyColor()
                end

                RegisterSearchable(CName, Wrapper)
                return ColorObj
            end

            -- ----------------------------------------------------------------
            -- INPUT / TEXTBOX
            -- ----------------------------------------------------------------
            function Elements:CreateInput(iConfig)
                iConfig = iConfig or {}
                local IName = iConfig.Name or iConfig.Title or "Input"
                local Placeholder = iConfig.PlaceholderText or "Enter value..."
                local Default = iConfig.CurrentValue or iConfig.Default or ""
                local ClearOnFocus = iConfig.RemoveTextAfterFocusLost or false
                local Flag = iConfig.Flag or IName
                local Callback = iConfig.Callback or function() end

                local InputObj = {Value = Default}
                CyberCore.Flags[Flag] = Default

                local Row = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundColor3 = CyberCore.Theme.Element,
                    Parent = containerParent
                })
                Utility:Corner(Row, 8)
                Utility:Stroke(Row, CyberCore.Theme.Stroke, 1, 0.2)

                Utility:Create("TextLabel", {
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(0.5, -12, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = IName,
                    TextColor3 = CyberCore.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row
                })

                local BoxHolder = Utility:Create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.new(0.45, 0, 0, 26),
                    BackgroundColor3 = CyberCore.Theme.Section,
                    Parent = Row
                })
                Utility:Corner(BoxHolder, 6)
                local BoxStroke = Utility:Stroke(BoxHolder, CyberCore.Theme.Stroke, 1, 0.3)

                local TextBox = Utility:Create("TextBox", {
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -16, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code,
                    PlaceholderText = Placeholder,
                    PlaceholderColor3 = CyberCore.Theme.Muted,
                    Text = Default,
                    TextColor3 = CyberCore.Theme.Accent,
                    TextSize = 12,
                    ClearTextOnFocus = false,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = BoxHolder
                })

                Utility:Connect(TextBox.Focused, function()
                    Utility:Tween(BoxStroke, {0.2}, {Color = CyberCore.Theme.Accent, Transparency = 0})
                end)

                Utility:Connect(TextBox.FocusLost, function()
                    Utility:Tween(BoxStroke, {0.2}, {Color = CyberCore.Theme.Stroke, Transparency = 0.3})
                    InputObj.Value = TextBox.Text
                    CyberCore.Flags[Flag] = TextBox.Text
                    task.spawn(Callback, TextBox.Text)
                    if ClearOnFocus then
                        TextBox.Text = ""
                    end
                end)

                function InputObj:Set(txt)
                    TextBox.Text = tostring(txt)
                    InputObj.Value = tostring(txt)
                    CyberCore.Flags[Flag] = tostring(txt)
                    task.spawn(Callback, tostring(txt))
                end

                RegisterSearchable(IName, Row)
                return InputObj
            end

            -- ----------------------------------------------------------------
            -- KEYBIND
            -- ----------------------------------------------------------------
            function Elements:CreateKeybind(kConfig)
                kConfig = kConfig or {}
                local KName = kConfig.Name or kConfig.Title or "Keybind"
                local DefaultKey = kConfig.CurrentKeybind or kConfig.Default or Enum.KeyCode.E
                if type(DefaultKey) == "string" then
                    DefaultKey = Enum.KeyCode[DefaultKey] or Enum.KeyCode.E
                end
                local Flag = kConfig.Flag or KName
                local Callback = kConfig.Callback or function() end

                local KeyObj = {Value = DefaultKey, Binding = false}
                CyberCore.Flags[Flag] = DefaultKey

                local Row = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundColor3 = CyberCore.Theme.Element,
                    Parent = containerParent
                })
                Utility:Corner(Row, 8)
                Utility:Stroke(Row, CyberCore.Theme.Stroke, 1, 0.2)

                Utility:Create("TextLabel", {
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -110, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = KName,
                    TextColor3 = CyberCore.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row
                })

                local KeyBtn = Utility:Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.new(0, 82, 0, 24),
                    BackgroundColor3 = CyberCore.Theme.Section,
                    AutoButtonColor = false,
                    Font = Enum.Font.Code,
                    Text = "[" .. DefaultKey.Name .. "]",
                    TextColor3 = CyberCore.Theme.Accent,
                    TextSize = 11,
                    Parent = Row
                })
                Utility:Corner(KeyBtn, 6)
                local KeyStroke = Utility:Stroke(KeyBtn, CyberCore.Theme.Stroke, 1, 0.25)

                Utility:Connect(KeyBtn.Activated, function()
                    KeyObj.Binding = true
                    KeyBtn.Text = "[ ... ]"
                    Utility:Tween(KeyStroke, {0.2}, {Color = CyberCore.Theme.Accent})
                end)

                Utility:Connect(UserInputService.InputBegan, function(input, gpe)
                    if KeyObj.Binding then
                        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                            KeyObj.Binding = false
                            KeyObj.Value = input.KeyCode
                            CyberCore.Flags[Flag] = input.KeyCode
                            KeyBtn.Text = "[" .. input.KeyCode.Name .. "]"
                            Utility:Tween(KeyStroke, {0.2}, {Color = CyberCore.Theme.Stroke})
                        end
                        return
                    end
                    if not gpe and input.KeyCode == KeyObj.Value then
                        task.spawn(Callback, KeyObj.Value)
                    end
                end)

                RegisterSearchable(KName, Row)
                return KeyObj
            end

            return Elements
        end

        -- Allow calling elements directly on Tab OR inside Tab:CreateSection()
        local TabElements = AttachElements(Page)
        for k, v in pairs(TabElements) do
            Tab[k] = v
        end

        return Tab
    end

    return Window
end

-- ============================================================================
-- [7] CLEANUP / UNLOAD
-- ============================================================================
function CyberCore:Destroy()
    CyberCore.Unloaded = true
    for _, conn in ipairs(CyberCore.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(CyberCore.Connections)
    if ScreenGui then
        ScreenGui:Destroy()
    end
end

return CyberCore
