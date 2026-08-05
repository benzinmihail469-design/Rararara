-- ========================================================
-- DARK HUB - FULL STANDALONE GUI (PC / MOBILE)
-- ========================================================

local Library do 
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")

    local gethui = gethui or function()
        return CoreGui
    end

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex

    local RGBSequence = ColorSequence.new
    local RGBSequenceKeypoint = ColorSequenceKeypoint.new
    local NumSequence = NumberSequence.new
    local NumSequenceKeypoint = NumberSequenceKeypoint.new

    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local UDim2FromOffset = UDim2.fromOffset
    local Vector2New = Vector2.new
    local Vector3New = Vector3.new

    local MathClamp = math.clamp
    local MathFloor = math.floor
    local InstanceNew = Instance.new
    local TableInsert = table.insert
    local TableClone = table.clone
    local TableUnpack = table.unpack
    local StringFormat = string.format

    local IsMobile = UserInputService.TouchEnabled or false

    Library = {
        Theme = {
            ["AccentGradient"] = FromRGB(0, 195, 255),
            ["Background 2"] = FromRGB(10, 10, 12),
            ["Background"] = FromRGB(12, 12, 14),
            ["Text"] = FromRGB(235, 235, 235),
            ["Outline"] = FromRGB(25, 25, 28),
            ["Section Top"] = FromRGB(28, 27, 31),
            ["Section Background"] = FromRGB(10, 10, 12),
            ["Section Background 2"] = FromRGB(14, 14, 16),
            ["Accent"] = FromRGB(0, 116, 224),
            ["Element"] = FromRGB(16, 16, 18)
        },
        ToClean = {},
        MenuKeybind = Enum.KeyCode.Insert,
        Flags = {},
        Tween = {
            Time = 0.25,
            Style = Enum.EasingStyle.Quad,
            Direction = Enum.EasingDirection.Out
        },
        FadeSpeed = 0.15,
        Pages = {},
        Sections = {},
        Connections = {},
        Threads = {},
        ThemeMap = {},
        ThemeItems = {},
        OpenFrames = {},
        SetFlags = {},
        UnnamedConnections = 0,
        UnnamedFlags = 0,
        Holder = nil,
        UnusedHolder = nil,
        NotifHolder = nil,
        Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    }

    Library.__index = Library

    -- Instances Builder
    local Instances = {}
    Instances.__index = Instances

    function Instances.Create(self, Class, Properties)
        local NewItem = { Instance = InstanceNew(Class) }
        setmetatable(NewItem, Instances)
        for Prop, Val in pairs(Properties or {}) do
            NewItem.Instance[Prop] = Val
        end
        return NewItem
    end

    function Instances:Connect(Event, Callback)
        if not self.Instance or not self.Instance[Event] then return end
        local Conn = self.Instance[Event]:Connect(Callback)
        TableInsert(Library.Connections, Conn)
        return Conn
    end

    function Instances:Tween(Info, Goal)
        if not self.Instance then return end
        Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)
        local T = TweenService:Create(self.Instance, Info, Goal)
        T:Play()
        return T
    end

    function Instances:Clean()
        if self.Instance then self.Instance:Destroy() end
    end

    -- Core GUI Screens
    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "DarkHub_GUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 999,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "DarkHub_Storage",
        Enabled = false,
        ResetOnSpawn = false
    })

    Library.NotifHolder = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Name = "NotifHolder",
        BackgroundTransparency = 1,
        Size = UDim2New(0, 260, 1, 0),
        Position = UDim2New(1, -270, 0, 10),
        BackgroundColor3 = FromRGB(255, 255, 255)
    })

    Instances:Create("UIListLayout", {
        Parent = Library.NotifHolder.Instance,
        Padding = UDimNew(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })

    -- Notification System
    function Library:Notify(Title, Text, Duration)
        Duration = Duration or 3
        local Frame = Instances:Create("Frame", {
            Parent = Library.NotifHolder.Instance,
            Size = UDim2New(1, 0, 0, 50),
            BackgroundColor3 = Library.Theme["Background"],
            BorderSizePixel = 0,
            BackgroundTransparency = 0.1
        })
        Instances:Create("UICorner", { Parent = Frame.Instance, CornerRadius = UDimNew(0, 6) })
        Instances:Create("UIStroke", { Parent = Frame.Instance, Color = Library.Theme["Accent"], Thickness = 1 })

        local TitleLabel = Instances:Create("TextLabel", {
            Parent = Frame.Instance,
            Text = Title,
            FontFace = Library.Font,
            TextSize = 14,
            TextColor3 = Library.Theme["Accent"],
            Position = UDim2New(0, 10, 0, 6),
            Size = UDim2New(1, -20, 0, 16),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local DescLabel = Instances:Create("TextLabel", {
            Parent = Frame.Instance,
            Text = Text,
            FontFace = Library.Font,
            TextSize = 12,
            TextColor3 = Library.Theme["Text"],
            Position = UDim2New(0, 10, 0, 24),
            Size = UDim2New(1, -20, 0, 20),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        task.delay(Duration, function()
            Frame:Tween(TweenInfo.new(0.3), {BackgroundTransparency = 1})
            TitleLabel:Tween(TweenInfo.new(0.3), {TextTransparency = 1})
            DescLabel:Tween(TweenInfo.new(0.3), {TextTransparency = 1})
            task.wait(0.3)
            Frame:Clean()
        end)
    end

    -- Window Builder
    function Library:CreateWindow(Config)
        Config = Config or {}
        local WindowName = Config.Name or "Dark Hub"
        local SubText = Config.SubName or "Universal Mobile & PC"

        -- Main Window Frame (Centered)
        local MainFrame = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            Name = "MainFrame",
            AnchorPoint = Vector2New(0.5, 0.5),
            Position = UDim2New(0.5, 0, 0.5, 0),
            Size = IsMobile and UDim2New(0, 560, 0, 340) or UDim2New(0, 650, 0, 420),
            BackgroundColor3 = Library.Theme["Background"],
            BorderSizePixel = 0,
            ClipsDescendants = true
        })

        Instances:Create("UICorner", { Parent = MainFrame.Instance, CornerRadius = UDimNew(0, 8) })
        Instances:Create("UIStroke", { Parent = MainFrame.Instance, Color = Library.Theme["Outline"], Thickness = 1.5 })

        -- Header
        local Header = Instances:Create("Frame", {
            Parent = MainFrame.Instance,
            Size = UDim2New(1, 0, 0, 45),
            BackgroundColor3 = Library.Theme["Background 2"],
            BorderSizePixel = 0
        })

        local Title = Instances:Create("TextLabel", {
            Parent = Header.Instance,
            Text = WindowName,
            FontFace = Library.Font,
            TextSize = 18,
            TextColor3 = Library.Theme["AccentGradient"],
            Position = UDim2New(0, 12, 0, 6),
            Size = UDim2New(0, 200, 0, 20),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local SubTitle = Instances:Create("TextLabel", {
            Parent = Header.Instance,
            Text = SubText,
            FontFace = Library.Font,
            TextSize = 11,
            TextColor3 = Library.Theme["Text"],
            Position = UDim2New(0, 12, 0, 25),
            Size = UDim2New(0, 200, 0, 14),
            BackgroundTransparency = 1,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Search Input
        local SearchBox = Instances:Create("TextBox", {
            Parent = Header.Instance,
            PlaceholderText = "Search...",
            Text = "",
            FontFace = Library.Font,
            TextSize = 12,
            TextColor3 = Library.Theme["Text"],
            PlaceholderColor3 = FromRGB(120, 120, 120),
            BackgroundColor3 = Library.Theme["Element"],
            Position = UDim2New(1, -210, 0, 10),
            Size = UDim2New(0, 130, 0, 25),
            BorderSizePixel = 0
        })
        Instances:Create("UICorner", { Parent = SearchBox.Instance, CornerRadius = UDimNew(0, 5) })

        -- Close Button
        local CloseBtn = Instances:Create("TextButton", {
            Parent = Header.Instance,
            Text = "X",
            FontFace = Library.Font,
            TextSize = 14,
            TextColor3 = Library.Theme["Text"],
            BackgroundColor3 = FromRGB(180, 40, 40),
            Position = UDim2New(1, -35, 0, 10),
            Size = UDim2New(0, 25, 0, 25),
            BorderSizePixel = 0
        })
        Instances:Create("UICorner", { Parent = CloseBtn.Instance, CornerRadius = UDimNew(0, 5) })

        -- Sidebar Tabs Container
        local Sidebar = Instances:Create("ScrollingFrame", {
            Parent = MainFrame.Instance,
            Position = UDim2New(0, 0, 0, 45),
            Size = UDim2New(0, 140, 1, -75),
            BackgroundColor3 = Library.Theme["Background 2"],
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            CanvasSize = UDim2New(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        Instances:Create("UIListLayout", { Parent = Sidebar.Instance, Padding = UDimNew(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
        Instances:Create("UIPadding", { Parent = Sidebar.Instance, PaddingTop = UDimNew(0, 6), PaddingLeft = UDimNew(0, 6), PaddingRight = UDimNew(0, 6) })

        -- Pages Container
        local PageContainer = Instances:Create("Frame", {
            Parent = MainFrame.Instance,
            Position = UDim2New(0, 140, 0, 45),
            Size = UDim2New(1, -140, 1, -75),
            BackgroundTransparency = 1
        })

        -- Footer / Bottom Status Bar
        local Footer = Instances:Create("Frame", {
            Parent = MainFrame.Instance,
            Position = UDim2New(0, 0, 1, -30),
            Size = UDim2New(1, 0, 0, 30),
            BackgroundColor3 = Library.Theme["Background 2"],
            BorderSizePixel = 0
        })

        local FooterText = Instances:Create("TextLabel", {
            Parent = Footer.Instance,
            Text = "Dark Hub | Ready",
            FontFace = Library.Font,
            TextSize = 11,
            TextColor3 = Library.Theme["Text"],
            Position = UDim2New(0, 10, 0, 0),
            Size = UDim2New(0.5, 0, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local TimerLabel = Instances:Create("TextLabel", {
            Parent = Footer.Instance,
            Text = "Time: 00:00:00",
            FontFace = Library.Font,
            TextSize = 11,
            TextColor3 = Library.Theme["Accent"],
            Position = UDim2New(0.5, 0, 0, 0),
            Size = UDim2New(0.5, -10, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Right
        })

        -- Live Uptime Timer
        local StartTime = os.time()
        RunService.RenderStepped:Connect(function()
            local Elapsed = os.time() - StartTime
            local Hrs = math.floor(Elapsed / 3600)
            local Mins = math.floor((Elapsed % 3600) / 60)
            local Secs = Elapsed % 60
            TimerLabel.Instance.Text = StringFormat("Uptime: %02d:%02d:%02d", Hrs, Mins, Secs)
        end)

        -- Mobile Floating Toggle Button
        if IsMobile then
            local MobileBtn = Instances:Create("TextButton", {
                Parent = Library.Holder.Instance,
                Text = "DARK",
                FontFace = Library.Font,
                TextSize = 12,
                TextColor3 = Library.Theme["Text"],
                BackgroundColor3 = Library.Theme["Accent"],
                Position = UDim2New(0, 15, 0, 15),
                Size = UDim2New(0, 45, 0, 45),
                BorderSizePixel = 0,
                ZIndex = 1000
            })
            Instances:Create("UICorner", { Parent = MobileBtn.Instance, CornerRadius = UDimNew(1, 0) })
            
            MobileBtn:Connect("MouseButton1Click", function()
                MainFrame.Instance.Visible = not MainFrame.Instance.Visible
            end)
        end

        -- Dragging Logic
        local Dragging, DragStart, StartPos
        Header:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = Input.Position
                StartPos = MainFrame.Instance.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(Input)
            if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                local Delta = Input.Position - DragStart
                MainFrame.Instance.Position = UDim2New(
                    StartPos.X.Scale, StartPos.X.Offset + Delta.X,
                    StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end)

        CloseBtn:Connect("MouseButton1Click", function()
            MainFrame.Instance.Visible = false
        end)

        -- Keybind Toggle (PC)
        UserInputService.InputBegan:Connect(function(Input, Processed)
            if not Processed and Input.KeyCode == Library.MenuKeybind then
                MainFrame.Instance.Visible = not MainFrame.Instance.Visible
            end
        end)

        -- Window Tabs Object
        local WindowObj = {
            CurrentPage = nil,
            Pages = {},
            SearchElements = {}
        }

        -- Dynamic Search Logic
        SearchBox:Connect("Changed", function()
            local Query = string.lower(SearchBox.Instance.Text)
            for _, ItemData in ipairs(WindowObj.SearchElements) do
                if Query == "" then
                    ItemData.Frame.Instance.Visible = true
                else
                    ItemData.Frame.Instance.Visible = string.find(string.lower(ItemData.Name), Query) ~= nil
                end
            end
        end)

        -- Create Page Function
        function WindowObj:CreateTab(Name)
            local TabBtn = Instances:Create("TextButton", {
                Parent = Sidebar.Instance,
                Text = Name,
                FontFace = Library.Font,
                TextSize = 13,
                TextColor3 = Library.Theme["Text"],
                BackgroundColor3 = Library.Theme["Element"],
                Size = UDim2New(1, 0, 0, 30),
                BorderSizePixel = 0
            })
            Instances:Create("UICorner", { Parent = TabBtn.Instance, CornerRadius = UDimNew(0, 5) })

            local PageScroll = Instances:Create("ScrollingFrame", {
                Parent = PageContainer.Instance,
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = false,
                ScrollBarThickness = 3,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })
            Instances:Create("UIListLayout", { Parent = PageScroll.Instance, Padding = UDimNew(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
            Instances:Create("UIPadding", { Parent = PageScroll.Instance, PaddingTop = UDimNew(0, 8), PaddingLeft = UDimNew(0, 8), PaddingRight = UDimNew(0, 8) })

            local PageObj = { PageFrame = PageScroll }

            TabBtn:Connect("MouseButton1Click", function()
                for _, P in pairs(WindowObj.Pages) do
                    P.PageFrame.Instance.Visible = false
                    P.TabBtn.Instance.BackgroundColor3 = Library.Theme["Element"]
                end
                PageScroll.Instance.Visible = true
                TabBtn.Instance.BackgroundColor3 = Library.Theme["Accent"]
                WindowObj.CurrentPage = PageObj
            end)

            PageObj.TabBtn = TabBtn
            TableInsert(WindowObj.Pages, PageObj)

            -- Auto-select first tab
            if #WindowObj.Pages == 1 then
                PageScroll.Instance.Visible = true
                TabBtn.Instance.BackgroundColor3 = Library.Theme["Accent"]
                WindowObj.CurrentPage = PageObj
            end

            -- Create Section
            function PageObj:CreateSection(SecName)
                local SecFrame = Instances:Create("Frame", {
                    Parent = PageScroll.Instance,
                    Size = UDim2New(1, 0, 0, 30),
                    BackgroundColor3 = Library.Theme["Section Background"],
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                Instances:Create("UICorner", { Parent = SecFrame.Instance, CornerRadius = UDimNew(0, 6) })
                Instances:Create("UIStroke", { Parent = SecFrame.Instance, Color = Library.Theme["Outline"], Thickness = 1 })

                local SecTitle = Instances:Create("TextLabel", {
                    Parent = SecFrame.Instance,
                    Text = SecName,
                    FontFace = Library.Font,
                    TextSize = 13,
                    TextColor3 = Library.Theme["AccentGradient"],
                    Position = UDim2New(0, 10, 0, 5),
                    Size = UDim2New(1, -20, 0, 20),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ElementContainer = Instances:Create("Frame", {
                    Parent = SecFrame.Instance,
                    Position = UDim2New(0, 0, 0, 28),
                    Size = UDim2New(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                Instances:Create("UIListLayout", { Parent = ElementContainer.Instance, Padding = UDimNew(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
                Instances:Create("UIPadding", { Parent = ElementContainer.Instance, PaddingLeft = UDimNew(0, 8), PaddingRight = UDimNew(0, 8), PaddingBottom = UDimNew(0, 8) })

                local SecObj = {}

                -- UI Element: Button
                function SecObj:AddButton(Text, Callback)
                    Callback = Callback or function() end
                    local BtnFrame = Instances:Create("TextButton", {
                        Parent = ElementContainer.Instance,
                        Text = Text,
                        FontFace = Library.Font,
                        TextSize = 12,
                        TextColor3 = Library.Theme["Text"],
                        BackgroundColor3 = Library.Theme["Element"],
                        Size = UDim2New(1, 0, 0, 28),
                        BorderSizePixel = 0
                    })
                    Instances:Create("UICorner", { Parent = BtnFrame.Instance, CornerRadius = UDimNew(0, 4) })

                    BtnFrame:Connect("MouseButton1Click", function()
                        BtnFrame:Tween(TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme["Accent"]})
                        task.wait(0.1)
                        BtnFrame:Tween(TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme["Element"]})
                        Callback()
                    end)

                    TableInsert(WindowObj.SearchElements, {Name = Text, Frame = BtnFrame})
                end

                -- UI Element: Toggle
                function SecObj:AddToggle(Text, Default, Callback)
                    Callback = Callback or function() end
                    local Toggled = Default or false

                    local TogFrame = Instances:Create("Frame", {
                        Parent = ElementContainer.Instance,
                        Size = UDim2New(1, 0, 0, 28),
                        BackgroundColor3 = Library.Theme["Element"],
                        BorderSizePixel = 0
                    })
                    Instances:Create("UICorner", { Parent = TogFrame.Instance, CornerRadius = UDimNew(0, 4) })

                    local TogLabel = Instances:Create("TextLabel", {
                        Parent = TogFrame.Instance,
                        Text = Text,
                        FontFace = Library.Font,
                        TextSize = 12,
                        TextColor3 = Library.Theme["Text"],
                        Position = UDim2New(0, 10, 0, 0),
                        Size = UDim2New(0.7, 0, 1, 0),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    local Switch = Instances:Create("Frame", {
                        Parent = TogFrame.Instance,
                        Position = UDim2New(1, -40, 0.5, -8),
                        Size = UDim2New(0, 30, 0, 16),
                        BackgroundColor3 = Toggled and Library.Theme["Accent"] or FromRGB(50, 50, 50),
                        BorderSizePixel = 0
                    })
                    Instances:Create("UICorner", { Parent = Switch.Instance, CornerRadius = UDimNew(1, 0) })

                    local Indicator = Instances:Create("Frame", {
                        Parent = Switch.Instance,
                        Position = Toggled and UDim2New(1, -14, 0.5, -6) or UDim2New(0, 2, 0.5, -6),
                        Size = UDim2New(0, 12, 0, 12),
                        BackgroundColor3 = FromRGB(255, 255, 255),
                        BorderSizePixel = 0
                    })
                    Instances:Create("UICorner", { Parent = Indicator.Instance, CornerRadius = UDimNew(1, 0) })

                    local Clicker = Instances:Create("TextButton", {
                        Parent = TogFrame.Instance,
                        Text = "",
                        BackgroundTransparency = 1,
                        Size = UDim2New(1, 0, 1, 0)
                    })

                    Clicker:Connect("MouseButton1Click", function()
                        Toggled = not Toggled
                        Switch:Tween(TweenInfo.new(0.15), {BackgroundColor3 = Toggled and Library.Theme["Accent"] or FromRGB(50, 50, 50)})
                        Indicator:Tween(TweenInfo.new(0.15), {Position = Toggled and UDim2New(1, -14, 0.5, -6) or UDim2New(0, 2, 0.5, -6)})
                        Callback(Toggled)
                    end)

                    TableInsert(WindowObj.SearchElements, {Name = Text, Frame = TogFrame})
                end

                -- UI Element: Slider
                function SecObj:AddSlider(Text, Min, Max, Default, Callback)
                    Callback = Callback or function() end
                    Default = math.clamp(Default or Min, Min, Max)

                    local SldFrame = Instances:Create("Frame", {
                        Parent = ElementContainer.Instance,
                        Size = UDim2New(1, 0, 0, 42),
                        BackgroundColor3 = Library.Theme["Element"],
                        BorderSizePixel = 0
                    })
                    Instances:Create("UICorner", { Parent = SldFrame.Instance, CornerRadius = UDimNew(0, 4) })

                    local SldLabel = Instances:Create("TextLabel", {
                        Parent = SldFrame.Instance,
                        Text = Text,
                        FontFace = Library.Font,
                        TextSize = 12,
                        TextColor3 = Library.Theme["Text"],
                        Position = UDim2New(0, 10, 0, 4),
                        Size = UDim2New(0.6, 0, 0, 16),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    local ValLabel = Instances:Create("TextLabel", {
                        Parent = SldFrame.Instance,
                        Text = tostring(Default),
                        FontFace = Library.Font,
                        TextSize = 12,
                        TextColor3 = Library.Theme["Accent"],
                        Position = UDim2New(0.6, 0, 0, 4),
                        Size = UDim2New(0.4, -10, 0, 16),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Right
                    })

                    local Track = Instances:Create("Frame", {
                        Parent = SldFrame.Instance,
                        Position = UDim2New(0, 10, 0, 26),
                        Size = UDim2New(1, -20, 0, 8),
                        BackgroundColor3 = FromRGB(40, 40, 40),
                        BorderSizePixel = 0
                    })
                    Instances:Create("UICorner", { Parent = Track.Instance, CornerRadius = UDimNew(1, 0) })

                    local Fill = Instances:Create("Frame", {
                        Parent = Track.Instance,
                        Size = UDim2New((Default - Min) / (Max - Min), 0, 1, 0),
                        BackgroundColor3 = Library.Theme["Accent"],
                        BorderSizePixel = 0
                    })
                    Instances:Create("UICorner", { Parent = Fill.Instance, CornerRadius = UDimNew(1, 0) })

                    local Sliding = false
                    local function Update(Input)
                        local Pos = math.clamp((Input.Position.X - Track.Instance.AbsolutePosition.X) / Track.Instance.AbsoluteSize.X, 0, 1)
                        local Val = math.floor(Min + (Max - Min) * Pos)
                        Fill.Instance.Size = UDim2New(Pos, 0, 1, 0)
                        ValLabel.Instance.Text = tostring(Val)
                        Callback(Val)
                    end

                    Track:Connect("InputBegan", function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            Sliding = true
                            Update(Input)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(Input)
                        if Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                            Update(Input)
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            Sliding = false
                        end
                    end)

                    TableInsert(WindowObj.SearchElements, {Name = Text, Frame = SldFrame})
                end

                -- UI Element: Dropdown
                function SecObj:AddDropdown(Text, List, Default, Callback)
                    Callback = Callback or function() end
                    List = List or {}
                    local Selected = Default or List[1] or "None"
                    local Open = false

                    local DropFrame = Instances:Create("Frame", {
                        Parent = ElementContainer.Instance,
                        Size = UDim2New(1, 0, 0, 30),
                        BackgroundColor3 = Library.Theme["Element"],
                        BorderSizePixel = 0,
                        ClipsDescendants = true
                    })
                    Instances:Create("UICorner", { Parent = DropFrame.Instance, CornerRadius = UDimNew(0, 4) })

                    local DropLabel = Instances:Create("TextLabel", {
                        Parent = DropFrame.Instance,
                        Text = Text .. ": " .. tostring(Selected),
                        FontFace = Library.Font,
                        TextSize = 12,
                        TextColor3 = Library.Theme["Text"],
                        Position = UDim2New(0, 10, 0, 0),
                        Size = UDim2New(1, -20, 0, 30),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    local TriggerBtn = Instances:Create("TextButton", {
                        Parent = DropFrame.Instance,
                        Text = "v",
                        FontFace = Library.Font,
                        TextSize = 12,
                        TextColor3 = Library.Theme["Accent"],
                        BackgroundTransparency = 1,
                        Position = UDim2New(1, -25, 0, 0),
                        Size = UDim2New(0, 25, 0, 30)
                    })

                    local ListContainer = Instances:Create("Frame", {
                        Parent = DropFrame.Instance,
                        Position = UDim2New(0, 0, 0, 30),
                        Size = UDim2New(1, 0, 0, #List * 24),
                        BackgroundTransparency = 1
                    })
                    Instances:Create("UIListLayout", { Parent = ListContainer.Instance, SortOrder = Enum.SortOrder.LayoutOrder })

                    for _, Item in ipairs(List) do
                        local ItemBtn = Instances:Create("TextButton", {
                            Parent = ListContainer.Instance,
                            Text = tostring(Item),
                            FontFace = Library.Font,
                            TextSize = 11,
                            TextColor3 = Library.Theme["Text"],
                            BackgroundColor3 = Library.Theme["Background 2"],
                            Size = UDim2New(1, 0, 0, 24),
                            BorderSizePixel = 0
                        })

                        ItemBtn:Connect("MouseButton1Click", function()
                            Selected = Item
                            DropLabel.Instance.Text = Text .. ": " .. tostring(Selected)
                            Open = false
                            DropFrame:Tween(TweenInfo.new(0.2), {Size = UDim2New(1, 0, 0, 30)})
                            Callback(Selected)
                        end)
                    end

                    TriggerBtn:Connect("MouseButton1Click", function()
                        Open = not Open
                        DropFrame:Tween(TweenInfo.new(0.2), {Size = Open and UDim2New(1, 0, 0, 30 + (#List * 24)) or UDim2New(1, 0, 0, 30)})
                    end)

                    TableInsert(WindowObj.SearchElements, {Name = Text, Frame = DropFrame})
                end

                -- UI Element: TextBox Input
                function SecObj:AddTextBox(Text, Placeholder, Callback)
                    Callback = Callback or function() end
                    local BoxFrame = Instances:Create("Frame", {
                        Parent = ElementContainer.Instance,
                        Size = UDim2New(1, 0, 0, 30),
                        BackgroundColor3 = Library.Theme["Element"],
                        BorderSizePixel = 0
                    })
                    Instances:Create("UICorner", { Parent = BoxFrame.Instance, CornerRadius = UDimNew(0, 4) })

                    local BoxLabel = Instances:Create("TextLabel", {
                        Parent = BoxFrame.Instance,
                        Text = Text,
                        FontFace = Library.Font,
                        TextSize = 12,
                        TextColor3 = Library.Theme["Text"],
                        Position = UDim2New(0, 10, 0, 0),
                        Size = UDim2New(0.5, -10, 1, 0),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })

                    local InputBox = Instances:Create("TextBox", {
                        Parent = BoxFrame.Instance,
                        PlaceholderText = Placeholder or "Type here...",
                        Text = "",
                        FontFace = Library.Font,
                        TextSize = 11,
                        TextColor3 = Library.Theme["Text"],
                        BackgroundColor3 = Library.Theme["Background 2"],
                        Position = UDim2New(0.5, 0, 0.15, 0),
                        Size = UDim2New(0.5, -10, 0.7, 0),
                        BorderSizePixel = 0
                    })
                    Instances:Create("UICorner", { Parent = InputBox.Instance, CornerRadius = UDimNew(0, 4) })

                    InputBox:Connect("FocusLost", function(EnterPressed)
                        Callback(InputBox.Instance.Text, EnterPressed)
                    end)

                    TableInsert(WindowObj.SearchElements, {Name = Text, Frame = BoxFrame})
                end

                return SecObj
            end

            return PageObj
        end

        return WindowObj
    end
end

-- ========================================================
-- INITIALIZING DARK HUB & CREATING DEMO INTERFACE
-- ========================================================

local DarkHub = Library:CreateWindow({
    Name = "Dark Hub",
    SubName = "Premium ПК / Mobile Interface"
})

Library:Notify("Dark Hub Loaded", "Press 'Insert' or Mobile Button to toggle UI", 4)

-- TAB 1: MAIN
local MainTab = DarkHub:CreateTab("Main")
local MainSec = MainTab:CreateSection("General Options")

MainSec:AddButton("Test Notification", function()
    Library:Notify("Notification", "Dark Hub successfully triggered!", 3)
end)

MainSec:AddToggle("Auto Farm Gold", false, function(Value)
    print("Auto Farm set to:", Value)
end)

MainSec:AddSlider("WalkSpeed", 16, 200, 16, function(Value)
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
end)

-- TAB 2: COMBAT
local CombatTab = DarkHub:CreateTab("Combat")
local CombatSec = CombatTab:CreateSection("Aimbot & Target")

CombatSec:AddToggle("Enable Silent Aimbot", true, function(Value)
    print("Aimbot Enabled:", Value)
end)

CombatSec:AddDropdown("Target Bone", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(Selected)
    print("Target set to:", Selected)
end)

CombatSec:AddSlider("Aimbot FOV", 30, 500, 100, function(Value)
    print("FOV updated to:", Value)
end)

-- TAB 3: VISUALS
local VisualsTab = DarkHub:CreateTab("Visuals")
local VisualsSec = VisualsTab:CreateSection("ESP Options")

VisualsSec:AddToggle("Player ESP Boxes", false, function(Value)
    print("Boxes ESP:", Value)
end)

VisualsSec:AddToggle("Show Distance", true, function(Value)
    print("Distance ESP:", Value)
end)

VisualsSec:AddTextBox("Custom ESP Title", "Enter Title...", function(Text)
    print("Custom Title Set:", Text)
end)

-- TAB 4: SETTINGS
local SettingsTab = DarkHub:CreateTab("Settings")
local ConfigSec = SettingsTab:CreateSection("UI Configurations")

ConfigSec:AddButton("Unload GUI", function()
    if Library.Holder then
        Library.Holder:Clean()
    end
end)
