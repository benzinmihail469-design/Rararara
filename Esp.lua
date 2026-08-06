-- ====================================================================
-- NEVERLOSE GUI - FULL STANDALONE SCRIPT
-- ====================================================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local gethui = gethui or function() return CoreGui end

-- Clean previous instances if re-executed
if getgenv().NeverloseGUI then
    getgenv().NeverloseGUI:Unload()
end

local Neverlose = {
    Flags = {},
    Connections = {},
    OpenDropdowns = {},
    Minimized = false,
    IsOpen = true,
    CurrentTab = nil,
    Tabs = {}
}

getgenv().NeverloseGUI = Neverlose

-- Theme Definitions (Neverlose Dark Blue Theme)
local Theme = {
    Background = Color3.fromRGB(11, 14, 20),
    Sidebar = Color3.fromRGB(14, 18, 26),
    SectionBackground = Color3.fromRGB(18, 23, 33),
    ElementBackground = Color3.fromRGB(24, 30, 43),
    Accent = Color3.fromRGB(0, 168, 255),
    AccentGradient = Color3.fromRGB(0, 116, 224),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(130, 140, 160),
    Outline = Color3.fromRGB(28, 35, 50)
}

-- Utility Functions
local function CreateInstance(className, properties)
    local inst = Instance.new(className)
    for prop, val in pairs(properties) do
        inst[prop] = val
    end
    return inst
end

local function Tween(inst, info, properties)
    local tween = TweenService:Create(inst, info or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

-- ScreenGui Container
local ScreenGui = CreateInstance("ScreenGui", {
    Name = "Neverlose_GUI",
    Parent = gethui(),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- ====================================================================
-- 1. WATERMARK SYSTEM
-- ====================================================================
local WatermarkFrame = CreateInstance("Frame", {
    Parent = ScreenGui,
    Name = "Watermark",
    Size = UDim2.new(0, 280, 0, 30),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ZIndex = 100
})

CreateInstance("UICorner", { Parent = WatermarkFrame, CornerRadius = UDim.new(0, 6) })
CreateInstance("UIStroke", { Parent = WatermarkFrame, Color = Theme.Outline, Thickness = 1 })

local WatermarkAccent = CreateInstance("Frame", {
    Parent = WatermarkFrame,
    Size = UDim2.new(0, 3, 1, 0),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0
})
CreateInstance("UICorner", { Parent = WatermarkAccent, CornerRadius = UDim.new(0, 6) })

local WatermarkText = CreateInstance("TextLabel", {
    Parent = WatermarkFrame,
    Size = UDim2.new(1, -15, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "NEVERLOSE | user | 60 FPS | 15 ms",
    TextColor3 = Theme.Text,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
})

local lastTime = os.clock()
local frameCount = 0
local fps = 60

local fpsConnection = RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = os.clock()
    if currentTime - lastTime >= 1 then
        fps = frameCount
        frameCount = 0
        lastTime = currentTime
        local ping = math.floor((Stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 0))
        WatermarkText.Text = string.format("NEVERLOSE | %s | %d FPS | %d ms", LocalPlayer.Name, fps, ping)
    end
end)
table.insert(Neverlose.Connections, fpsConnection)

-- ====================================================================
-- 2. NOTIFICATION SYSTEM
-- ====================================================================
local NotifHolder = CreateInstance("Frame", {
    Parent = ScreenGui,
    Name = "NotifHolder",
    Size = UDim2.new(0, 250, 1, -40),
    Position = UDim2.new(1, -260, 0, 20),
    BackgroundTransparency = 1,
    ZIndex = 200
})

local NotifLayout = CreateInstance("UIListLayout", {
    Parent = NotifHolder,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8),
    VerticalAlignment = Enum.VerticalAlignment.Bottom
})

function Neverlose:Notification(title, description, duration)
    duration = duration or 3
    local notif = CreateInstance("Frame", {
        Parent = NotifHolder,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        BackgroundTransparency = 1
    })
    CreateInstance("UICorner", { Parent = notif, CornerRadius = UDim.new(0, 6) })
    CreateInstance("UIStroke", { Parent = notif, Color = Theme.Outline, Thickness = 1 })

    local notifAccent = CreateInstance("Frame", {
        Parent = notif,
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0
    })
    CreateInstance("UICorner", { Parent = notifAccent, CornerRadius = UDim.new(0, 6) })

    local tLabel = CreateInstance("TextLabel", {
        Parent = notif,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -20, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local dLabel = CreateInstance("TextLabel", {
        Parent = notif,
        Position = UDim2.new(0, 12, 0, 24),
        Size = UDim2.new(1, -20, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = description,
        TextColor3 = Theme.SubText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Tween(notif, nil, { BackgroundTransparency = 0.1 })
    
    task.delay(duration, function()
        Tween(notif, nil, { BackgroundTransparency = 1 })
        Tween(tLabel, nil, { TextTransparency = 1 })
        Tween(dLabel, nil, { TextTransparency = 1 })
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- ====================================================================
-- 3. MAIN WINDOW CREATION
-- ====================================================================
local MainFrame = CreateInstance("Frame", {
    Parent = ScreenGui,
    Name = "MainFrame",
    Size = UDim2.new(0, 750, 0, 520),
    Position = UDim2.new(0.5, -375, 0.5, -260),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = false
})

CreateInstance("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 8) })
CreateInstance("UIStroke", { Parent = MainFrame, Color = Theme.Outline, Thickness = 1 })

-- Dragging Functionality
local dragging, dragInput, dragStart, startPos
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
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Window Top Header Bar
local Header = CreateInstance("Frame", {
    Parent = MainFrame,
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundTransparency = 1
})

local Logo = CreateInstance("ImageLabel", {
    Parent = Header,
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(0, 15, 0.5, -12),
    BackgroundTransparency = 1,
    Image = "rbxassetid://12187365364", -- Placeholder icon
    ImageColor3 = Theme.Accent
})

local Title = CreateInstance("TextLabel", {
    Parent = Header,
    Position = UDim2.new(0, 48, 0.5, -10),
    Size = UDim2.new(0, 200, 0, 20),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "NEVERLOSE",
    TextColor3 = Theme.Text,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Top Right Buttons (Minimize & Close)
local CloseBtn = CreateInstance("TextButton", {
    Parent = Header,
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -38, 0.5, -14),
    BackgroundColor3 = Theme.ElementBackground,
    Text = "✕",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    AutoButtonColor = false
})
CreateInstance("UICorner", { Parent = CloseBtn, CornerRadius = UDim.new(0, 6) })

local MinimizeBtn = CreateInstance("TextButton", {
    Parent = Header,
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -72, 0.5, -14),
    BackgroundColor3 = Theme.ElementBackground,
    Text = "—",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    AutoButtonColor = false
})
CreateInstance("UICorner", { Parent = MinimizeBtn, CornerRadius = UDim.new(0, 6) })

-- Floating Minimize Icon
local FloatingIcon = CreateInstance("TextButton", {
    Parent = ScreenGui,
    Name = "FloatingIcon",
    Size = UDim2.new(0, 45, 0, 45),
    Position = UDim2.new(0, 20, 0.5, -22),
    BackgroundColor3 = Theme.Background,
    Text = "NL",
    TextColor3 = Theme.Accent,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    Visible = false,
    ZIndex = 300
})
CreateInstance("UICorner", { Parent = FloatingIcon, CornerRadius = UDim.new(1, 0) })
CreateInstance("UIStroke", { Parent = FloatingIcon, Color = Theme.Accent, Thickness = 2 })

MinimizeBtn.MouseButton1Click:Connect(function()
    Neverlose.Minimized = not Neverlose.Minimized
    MainFrame.Visible = not Neverlose.Minimized
    FloatingIcon.Visible = Neverlose.Minimized
end)

FloatingIcon.MouseButton1Click:Connect(function()
    Neverlose.Minimized = false
    MainFrame.Visible = true
    FloatingIcon.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    Neverlose:Unload()
end)

-- Sidebar (Left Container for Tabs)
local Sidebar = CreateInstance("Frame", {
    Parent = MainFrame,
    Name = "Sidebar",
    Size = UDim2.new(0, 180, 1, -55),
    Position = UDim2.new(0, 10, 0, 45),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0
})
CreateInstance("UICorner", { Parent = Sidebar, CornerRadius = UDim.new(0, 6) })

local SidebarScroll = CreateInstance("ScrollingFrame", {
    Parent = Sidebar,
    Size = UDim2.new(1, 0, 1, -10),
    Position = UDim2.new(0, 0, 0, 5),
    BackgroundTransparency = 1,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Theme.Accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
})

local SidebarLayout = CreateInstance("UIListLayout", {
    Parent = SidebarScroll,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4)
})

CreateInstance("UIPadding", {
    Parent = SidebarScroll,
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8)
})

-- Content Area (Right Container for Sections)
local ContentArea = CreateInstance("Frame", {
    Parent = MainFrame,
    Name = "ContentArea",
    Size = UDim2.new(1, -210, 1, -55),
    Position = UDim2.new(0, 200, 0, 45),
    BackgroundTransparency = 1
})

-- ====================================================================
-- 4. TAB & SECTION CREATION ENGINE
-- ====================================================================
local TabList = {
    { Name = "Aimbot", Icon = "rbxassetid://7733658504" },
    { Name = "Ragebot", Icon = "rbxassetid://7733658504" },
    { Name = "Anti Aim", Icon = "rbxassetid://7733673987" },
    { Name = "Legitbot", Icon = "rbxassetid://7733674670" },
    { Name = "Visuals", Icon = "rbxassetid://7733674931" },
    { Name = "Players", Icon = "rbxassetid://7733674079" },
    { Name = "Weapon", Icon = "rbxassetid://7733674204" },
    { Name = "Grenades", Icon = "rbxassetid://7733674319" },
    { Name = "World", Icon = "rbxassetid://7733674442" },
    { Name = "View", Icon = "rbxassetid://7733674550" },
    { Name = "Miscellaneous", Icon = "rbxassetid://7733674670" },
    { Name = "Main", Icon = "rbxassetid://7733674753" },
    { Name = "Inventory", Icon = "rbxassetid://7733674841" },
    { Name = "Scripts", Icon = "rbxassetid://7733674931" },
    { Name = "Configs", Icon = "rbxassetid://7733675026" }
}

function Neverlose:CreateTab(tabData)
    local tabObj = { Name = tabData.Name, PageFrame = nil, Button = nil, Sections = {} }

    -- Page Container
    local PageFrame = CreateInstance("ScrollingFrame", {
        Parent = ContentArea,
        Name = tabData.Name .. "_Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    local PageGrid = CreateInstance("UIGridLayout", {
        Parent = PageFrame,
        CellSize = UDim2.new(0, 255, 0, 440),
        CellPadding = UDim2.new(0, 15, 0, 15),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    tabObj.PageFrame = PageFrame

    -- Tab Button in Sidebar
    local TabBtn = CreateInstance("TextButton", {
        Parent = SidebarScroll,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.ElementBackground,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    CreateInstance("UICorner", { Parent = TabBtn, CornerRadius = UDim.new(0, 6) })

    local TabIcon = CreateInstance("ImageLabel", {
        Parent = TabBtn,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        BackgroundTransparency = 1,
        Image = tabData.Icon,
        ImageColor3 = Theme.SubText
    })

    local TabText = CreateInstance("TextLabel", {
        Parent = TabBtn,
        Position = UDim2.new(0, 34, 0, 0),
        Size = UDim2.new(1, -34, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = tabData.Name,
        TextColor3 = Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    tabObj.Button = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Neverlose.Tabs) do
            t.PageFrame.Visible = false
            Tween(t.Button, nil, { BackgroundTransparency = 1 })
            local tText = t.Button:FindFirstChildOfClass("TextLabel")
            local tImg = t.Button:FindFirstChildOfClass("ImageLabel")
            if tText then Tween(tText, nil, { TextColor3 = Theme.SubText }) end
            if tImg then Tween(tImg, nil, { ImageColor3 = Theme.SubText }) end
        end

        PageFrame.Visible = true
        Neverlose.CurrentTab = tabObj
        Tween(TabBtn, nil, { BackgroundTransparency = 0 })
        Tween(TabText, nil, { TextColor3 = Theme.Accent })
        Tween(TabIcon, nil, { ImageColor3 = Theme.Accent })
    end)

    function tabObj:CreateSection(title)
        local secObj = {}
        local SectionFrame = CreateInstance("Frame", {
            Parent = PageFrame,
            Name = title .. "_Section",
            BackgroundColor3 = Theme.SectionBackground,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0)
        })
        CreateInstance("UICorner", { Parent = SectionFrame, CornerRadius = UDim.new(0, 6) })
        CreateInstance("UIStroke", { Parent = SectionFrame, Color = Theme.Outline, Thickness = 1 })

        local SecHeader = CreateInstance("Frame", {
            Parent = SectionFrame,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1
        })

        local SecTitle = CreateInstance("TextLabel", {
            Parent = SecHeader,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -24, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local Container = CreateInstance("ScrollingFrame", {
            Parent = SectionFrame,
            Size = UDim2.new(1, -16, 1, -36),
            Position = UDim2.new(0, 8, 0, 32),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0,0,0,0)
        })

        local ContainerLayout = CreateInstance("UIListLayout", {
            Parent = Container,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })

        -- ============================================================
        -- ELEMENT CREATORS (1 OF EACH REQUIRED TYPE)
        -- ============================================================
        
        -- 1. TOGGLE
        function secObj:AddToggle(text, default, flag, callback)
            Neverlose.Flags[flag] = default or false
            local toggleFrame = CreateInstance("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1
            })

            local box = CreateInstance("TextButton", {
                Parent = toggleFrame,
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 0, 0.5, -9),
                BackgroundColor3 = default and Theme.Accent or Theme.ElementBackground,
                Text = "",
                AutoButtonColor = false
            })
            CreateInstance("UICorner", { Parent = box, CornerRadius = UDim.new(0, 4) })

            local check = CreateInstance("TextLabel", {
                Parent = box,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "✓",
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                Visible = default or false
            })

            local label = CreateInstance("TextLabel", {
                Parent = toggleFrame,
                Position = UDim2.new(0, 26, 0, 0),
                Size = UDim2.new(1, -26, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            box.MouseButton1Click:Connect(function()
                local val = not Neverlose.Flags[flag]
                Neverlose.Flags[flag] = val
                check.Visible = val
                Tween(box, nil, { BackgroundColor3 = val and Theme.Accent or Theme.ElementBackground })
                if callback then callback(val) end
            end)
        end

        -- 2. SLIDER
        function secObj:AddSlider(text, min, max, default, flag, callback)
            Neverlose.Flags[flag] = default or min
            local sliderFrame = CreateInstance("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1
            })

            local label = CreateInstance("TextLabel", {
                Parent = sliderFrame,
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local valLabel = CreateInstance("TextLabel", {
                Parent = sliderFrame,
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = tostring(default or min),
                TextColor3 = Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local track = CreateInstance("Frame", {
                Parent = sliderFrame,
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.new(0, 0, 0, 22),
                BackgroundColor3 = Theme.ElementBackground,
                BorderSizePixel = 0
            })
            CreateInstance("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })

            local fill = CreateInstance("Frame", {
                Parent = track,
                Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0
            })
            CreateInstance("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })

            local sliding = false
            local function update(input)
                local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + ((max - min) * pos))
                Neverlose.Flags[flag] = val
                valLabel.Text = tostring(val)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                if callback then callback(val) end
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    update(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
        end

        -- 3. DROPDOWN
        function secObj:AddDropdown(text, options, default, flag, callback)
            Neverlose.Flags[flag] = default or options[1]
            local dropFrame = CreateInstance("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1
            })

            local label = CreateInstance("TextLabel", {
                Parent = dropFrame,
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local btn = CreateInstance("TextButton", {
                Parent = dropFrame,
                Size = UDim2.new(1, 0, 0, 22),
                Position = UDim2.new(0, 0, 0, 18),
                BackgroundColor3 = Theme.ElementBackground,
                Text = "  " .. tostring(Neverlose.Flags[flag]),
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false
            })
            CreateInstance("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })

            local arrow = CreateInstance("TextLabel", {
                Parent = btn,
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -20, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme.SubText,
                TextSize = 10
            })

            local listContainer = CreateInstance("Frame", {
                Parent = ScreenGui,
                Size = UDim2.new(0, 200, 0, #options * 22),
                BackgroundColor3 = Theme.ElementBackground,
                Visible = false,
                ZIndex = 250
            })
            CreateInstance("UICorner", { Parent = listContainer, CornerRadius = UDim.new(0, 4) })
            CreateInstance("UIStroke", { Parent = listContainer, Color = Theme.Outline, Thickness = 1 })

            local listLayout = CreateInstance("UIListLayout", { Parent = listContainer, SortOrder = Enum.SortOrder.LayoutOrder })

            for _, opt in ipairs(options) do
                local optBtn = CreateInstance("TextButton", {
                    Parent = listContainer,
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    Text = "  " .. opt,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                optBtn.MouseButton1Click:Connect(function()
                    Neverlose.Flags[flag] = opt
                    btn.Text = "  " .. opt
                    listContainer.Visible = false
                    if callback then callback(opt) end
                end)
            end

            btn.MouseButton1Click:Connect(function()
                listContainer.Visible = not listContainer.Visible
                if listContainer.Visible then
                    listContainer.Position = UDim2.new(0, btn.AbsolutePosition.X, 0, btn.AbsolutePosition.Y + 25)
                    listContainer.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, #options * 22)
                end
            end)
        end

        -- 4. BUTTON
        function secObj:AddButton(text, callback)
            local btn = CreateInstance("TextButton", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Theme.ElementBackground,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                AutoButtonColor = false
            })
            CreateInstance("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
            CreateInstance("UIStroke", { Parent = btn, Color = Theme.Outline, Thickness = 1 })

            btn.MouseButton1Click:Connect(function()
                Tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = Theme.Accent })
                task.wait(0.1)
                Tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = Theme.ElementBackground })
                if callback then callback() end
            end)
        end

        -- 5. TEXTBOX
        function secObj:AddTextbox(text, placeholder, flag, callback)
            Neverlose.Flags[flag] = ""
            local boxFrame = CreateInstance("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1
            })

            local label = CreateInstance("TextLabel", {
                Parent = boxFrame,
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local input = CreateInstance("TextBox", {
                Parent = boxFrame,
                Size = UDim2.new(1, 0, 0, 22),
                Position = UDim2.new(0, 0, 0, 18),
                BackgroundColor3 = Theme.ElementBackground,
                PlaceholderText = placeholder or "Type here...",
                PlaceholderColor3 = Theme.SubText,
                Text = "",
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                ClearTextOnFocus = false
            })
            CreateInstance("UICorner", { Parent = input, CornerRadius = UDim.new(0, 4) })

            input.FocusLost:Connect(function()
                Neverlose.Flags[flag] = input.Text
                if callback then callback(input.Text) end
            end)
        end

        -- 6. COLORPICKER
        function secObj:AddColorpicker(text, default, flag, callback)
            Neverlose.Flags[flag] = default or Color3.fromRGB(0, 168, 255)
            local cpFrame = CreateInstance("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1
            })

            local label = CreateInstance("TextLabel", {
                Parent = cpFrame,
                Size = UDim2.new(1, -30, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local colorPreview = CreateInstance("TextButton", {
                Parent = cpFrame,
                Size = UDim2.new(0, 20, 0, 14),
                Position = UDim2.new(1, -20, 0.5, -7),
                BackgroundColor3 = Neverlose.Flags[flag],
                Text = "",
                AutoButtonColor = false
            })
            CreateInstance("UICorner", { Parent = colorPreview, CornerRadius = UDim.new(0, 3) })

            colorPreview.MouseButton1Click:Connect(function()
                -- Cycle simple preset colors for demonstration/functional usage
                local palette = {
                    Color3.fromRGB(0, 168, 255),
                    Color3.fromRGB(255, 60, 60),
                    Color3.fromRGB(60, 255, 60),
                    Color3.fromRGB(255, 220, 0),
                    Color3.fromRGB(180, 60, 255)
                }
                local currIdx = 1
                for i, col in ipairs(palette) do
                    if col == Neverlose.Flags[flag] then currIdx = i break end
                end
                local nextCol = palette[(currIdx % #palette) + 1]
                Neverlose.Flags[flag] = nextCol
                colorPreview.BackgroundColor3 = nextCol
                if callback then callback(nextCol) end
            end)
        end

        -- 7. KEYBIND
        function secObj:AddKeybind(text, defaultKey, flag, callback)
            Neverlose.Flags[flag] = defaultKey or Enum.KeyCode.E
            local keyFrame = CreateInstance("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1
            })

            local label = CreateInstance("TextLabel", {
                Parent = keyFrame,
                Size = UDim2.new(1, -60, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local keyBtn = CreateInstance("TextButton", {
                Parent = keyFrame,
                Size = UDim2.new(0, 50, 0, 18),
                Position = UDim2.new(1, -50, 0.5, -9),
                BackgroundColor3 = Theme.ElementBackground,
                Text = Neverlose.Flags[flag].Name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 10
            })
            CreateInstance("UICorner", { Parent = keyBtn, CornerRadius = UDim.new(0, 4) })

            local listening = false
            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        Neverlose.Flags[flag] = input.KeyCode
                        keyBtn.Text = input.KeyCode.Name
                        listening = false
                        conn:Disconnect()
                        if callback then callback(input.KeyCode) end
                    end
                end)
            end)
        end

        -- 8. SEARCH & LISTBOX COMBINED
        function secObj:AddListboxWithSearch(text, items, flag, callback)
            Neverlose.Flags[flag] = items[1] or ""
            local lbFrame = CreateInstance("Frame", {
                Parent = Container,
                Size = UDim2.new(1, 0, 0, 130),
                BackgroundTransparency = 1
            })

            local label = CreateInstance("TextLabel", {
                Parent = lbFrame,
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            -- Search Input
            local searchBox = CreateInstance("TextBox", {
                Parent = lbFrame,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 18),
                BackgroundColor3 = Theme.ElementBackground,
                PlaceholderText = "🔍 Search...",
                PlaceholderColor3 = Theme.SubText,
                Text = "",
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 11
            })
            CreateInstance("UICorner", { Parent = searchBox, CornerRadius = UDim.new(0, 4) })

            -- Listbox Container
            local listScroll = CreateInstance("ScrollingFrame", {
                Parent = lbFrame,
                Size = UDim2.new(1, 0, 0, 85),
                Position = UDim2.new(0, 0, 0, 42),
                BackgroundColor3 = Theme.ElementBackground,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Accent,
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })
            CreateInstance("UICorner", { Parent = listScroll, CornerRadius = UDim.new(0, 4) })

            local listLayout = CreateInstance("UIListLayout", { Parent = listScroll, SortOrder = Enum.SortOrder.LayoutOrder })

            local itemBtns = {}
            local function populate(filter)
                for _, child in ipairs(listScroll:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, item in ipairs(items) do
                    if filter == "" or string.find(string.lower(item), string.lower(filter)) then
                        local itemBtn = CreateInstance("TextButton", {
                            Parent = listScroll,
                            Size = UDim2.new(1, 0, 0, 20),
                            BackgroundTransparency = 1,
                            Text = "  " .. item,
                            TextColor3 = (Neverlose.Flags[flag] == item) and Theme.Accent or Theme.Text,
                            Font = Enum.Font.Gotham,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })
                        itemBtn.MouseButton1Click:Connect(function()
                            Neverlose.Flags[flag] = item
                            populate(searchBox.Text)
                            if callback then callback(item) end
                        end)
                    end
                end
            end

            searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                populate(searchBox.Text)
            end)

            populate("")
        end

        return secObj
    end

    table.insert(Neverlose.Tabs, tabObj)
    return tabObj
end

-- ====================================================================
-- 5. BUILD INTERFACE & SECTIONS ACCORDING TO REFERENCED DESIGN
-- ====================================================================
for _, tabData in ipairs(TabList) do
    Neverlose:CreateTab(tabData)
end

-- Select default active tab (Miscellaneous)
local miscTab = Neverlose.Tabs[11] -- Miscellaneous
if miscTab then
    miscTab.Button.MouseButton1Click:Fire()
end

-- Populate Sections in Miscellaneous tab (Movement, Other, About Neverlose)
if miscTab then
    -- Section 1: Movement
    local movement = miscTab:CreateSection("Movement")
    movement:AddToggle("Bunny Hop", true, "bhop_flag", function(val)
        Neverlose:Notification("Movement", "Bunny Hop set to " .. tostring(val))
    end)
    movement:AddSlider("Speed Multiplier", 16, 100, 32, "speed_flag", function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end)
    movement:AddKeybind("Bhop Key", Enum.KeyCode.Space, "bhop_key")

    -- Section 2: Other
    local other = miscTab:CreateSection("Other")
    other:AddDropdown("UI Theme Mode", { "Default Blue", "Dark Violet", "Emerald Green" }, "Default Blue", "theme_flag")
    other:AddTextbox("Custom Tag", "Enter clantag...", "clantag_flag")
    other:AddColorpicker("Accent Color", Color3.fromRGB(0, 168, 255), "accent_color_flag", function(col)
        Theme.Accent = col
    end)
    other:AddButton("Show Test Notification", function()
        Neverlose:Notification("Neverlose GUI", "Notification Triggered Successfully!", 3)
    end)

    -- Section 3: About Neverlose / Configs
    local about = miscTab:CreateSection("About Neverlose")
    about:AddListboxWithSearch("Presets / Configs", { "Legit_v1", "Rage_HvH", "Semirage_Pro", "Visuals_Only", "Default_CFG" }, "cfg_select", function(selected)
        Neverlose:Notification("Config Manager", "Selected Config: " .. selected)
    end)
end

-- Function to safely unload script & destroy GUI
function Neverlose:Unload()
    for _, conn in ipairs(Neverlose.Connections) do
        if conn then conn:Disconnect() end
    end
    if ScreenGui then ScreenGui:Destroy() end
    getgenv().NeverloseGUI = nil
end

-- Notify execution finished
Neverlose:Notification("NEVERLOSE", "Loaded successfully!", 4)
