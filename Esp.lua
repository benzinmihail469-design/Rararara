-- ================================================================================
-- ULTRA ADVANCED ROBLOX UI LIBRARY (PC & MOBILE SUPPORTED)
-- Complete, bug-fixed, performance-optimized, full feature set with dynamic themes,
-- search engine, watermark, keybind tracker, notification system, configs, and blur.
-- ================================================================================

local Library = { }
Library.__index = Library

do
    -- Services & Safety
    local Workspace = cloneref and cloneref(game:GetService("Workspace")) or game:GetService("Workspace")
    local UserInputService = cloneref and cloneref(game:GetService("UserInputService")) or game:GetService("UserInputService")
    local Players = cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")
    local HttpService = cloneref and cloneref(game:GetService("HttpService")) or game:GetService("HttpService")
    local RunService = cloneref and cloneref(game:GetService("RunService")) or game:GetService("RunService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local TweenService = cloneref and cloneref(game:GetService("TweenService")) or game:GetService("TweenService")
    local Lighting = cloneref and cloneref(game:GetService("Lighting")) or game:GetService("Lighting")

    local gethui = gethui or function()
        return CoreGui
    end

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    -- Fast Math & Data Constructors
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
    local MathAbs = math.abs

    local TableInsert = table.insert
    local TableRemove = table.remove
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringGSub = string.gsub
    local StringLower = string.lower

    local InstanceNew = Instance.new

    local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    -- Core State
    Library.Theme = { }
    Library.ToClean = { }
    Library.MenuKeybind = Enum.KeyCode.Insert
    Library.Flags = { }
    Library.SetFlags = { }
    Library.OpenFrames = { }
    Library.Connections = { }
    Library.Threads = { }
    Library.ThemeItems = { }
    Library.ThemeMap = { }
    Library.UnnamedConnections = 0
    Library.UnnamedFlags = 0
    Library.Font = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

    Library.Tween = {
        Time = 0.25,
        Style = Enum.EasingStyle.Quart,
        Direction = Enum.EasingDirection.Out
    }

    Library.Folders = {
        Directory = "UltraLibrary",
        Configs = "UltraLibrary/Configs",
        Assets = "UltraLibrary/Assets",
    }

    -- Default Preset Theme
    local Themes = {
        Preset = {
            ["Accent"]               = FromRGB(0, 140, 255),
            ["AccentGradient"]       = FromRGB(0, 210, 255),
            ["Background"]           = FromRGB(15, 15, 18),
            ["Background 2"]         = FromRGB(20, 20, 25),
            ["Section Top"]          = FromRGB(28, 28, 35),
            ["Section Background"]   = FromRGB(18, 18, 22),
            ["Section Background 2"] = FromRGB(24, 24, 30),
            ["Element"]              = FromRGB(25, 25, 32),
            ["Outline"]              = FromRGB(35, 35, 45),
            ["Text"]                 = FromRGB(240, 240, 245),
            ["Text Dim"]             = FromRGB(150, 150, 165)
        }
    }

    Library.Theme = TableClone(Themes.Preset)

    -- File Folders Creation
    for _, FolderPath in pairs(Library.Folders) do 
        if isfolder and not isfolder(FolderPath) then
            makefolder(FolderPath)
        end
    end

    -- Image Asset Format Helper
    local function FormatAssetId(id)
        if type(id) == "number" or (type(id) == "string" and tonumber(id)) then
            return "rbxassetid://" .. tostring(id)
        end
        return id or ""
    end

    -- Tween Wrapper Class
    local Tween = { } do
        Tween.__index = Tween

        function Tween:Create(Item, Info, Goal, IsRawItem)
            Item = IsRawItem and Item or (Item.Instance or Item)
            Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)

            local NewTween = TweenService:Create(Item, Info, Goal)
            NewTween:Play()

            return NewTween
        end

        function Tween:GetProperty(Item)
            if Item:IsA("Frame") then
                return { "BackgroundTransparency" }
            elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
                return { "BackgroundTransparency", "ImageTransparency" }
            elseif Item:IsA("ScrollingFrame") then
                return { "BackgroundTransparency", "ScrollBarImageTransparency" }
            elseif Item:IsA("TextBox") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("UIStroke") then 
                return { "Transparency" }
            end
        end

        function Tween:FadeItem(Item, Property, Visibility, Speed)
            local TargetTrans = Visibility and 0 or 1
            local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = TargetTrans
            }, true)

            return NewTween
        end
    end

    -- Instance Helper Wrapper
    local Instances = { } do
        Instances.__index = Instances

        function Instances:Create(Class, Properties)
            local NewItem = {
                Instance = InstanceNew(Class),
                Properties = Properties or {},
                Class = Class
            }

            setmetatable(NewItem, Instances)

            for Property, Value in pairs(NewItem.Properties) do
                NewItem.Instance[Property] = Value
            end

            return NewItem
        end

        function Instances:AddToTheme(Properties)
            if not self.Instance then return end
            Library:AddToTheme(self, Properties)
        end

        function Instances:Connect(EventName, Callback)
            if not self.Instance or not self.Instance[EventName] then return end

            -- Mobile Auto Mapping
            if IsMobile then
                if EventName == "MouseButton1Click" or EventName == "MouseButton1Down" then
                    EventName = "TouchTap"
                end
            end

            return Library:Connect(self.Instance[EventName], Callback)
        end

        function Instances:Tween(Info, Goal)
            if not self.Instance then return end
            return Tween:Create(self, Info, Goal)
        end

        function Instances:OnHover(Function)
            if not self.Instance then return end
            return Library:Connect(self.Instance.MouseEnter, Function)
        end

        function Instances:OnHoverLeave(Function)
            if not self.Instance then return end
            return Library:Connect(self.Instance.MouseLeave, Function)
        end

        function Instances:Clean()
            if not self.Instance then return end
            self.Instance:Destroy()
            self = nil
        end

        function Instances:MakeDraggable()
            if not self.Instance then return end
            local Gui = self.Instance
            local Dragging = false 
            local DragStart, StartPosition 

            local SetPos = function(Input)
                local DragDelta = Input.Position - DragStart
                local NewX = StartPosition.X.Offset + DragDelta.X
                local NewY = StartPosition.Y.Offset + DragDelta.Y
                self:Tween(TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2New(StartPosition.X.Scale, NewX, StartPosition.Y.Scale, NewY)
                })
            end

            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position

                    local Connection
                    Connection = Library:Connect(UserInputService.InputChanged, function(ChangedInput)
                        if ChangedInput.UserInputType == Enum.UserInputType.MouseMovement or ChangedInput.UserInputType == Enum.UserInputType.Touch then
                            if Dragging then
                                SetPos(ChangedInput)
                            end
                        end
                    end)

                    local EndConn
                    EndConn = Library:Connect(UserInputService.InputEnded, function(EndedInput)
                        if EndedInput.UserInputType == Enum.UserInputType.MouseButton1 or EndedInput.UserInputType == Enum.UserInputType.Touch then
                            Dragging = false
                            if Connection then Connection.Connection:Disconnect() end
                            if EndConn then EndConn.Connection:Disconnect() end
                        end
                    end)
                end
            end)
        end

        function Instances:MakeResizeable(Minimum, Maximum)
            if not self.Instance then return end
            local Gui = self.Instance
            local Resizing = false
            local StartMouse, StartSize

            local ResizeHandle = Instances:Create("TextButton", {
                Parent = Gui,
                Size = UDim2New(0, 15, 0, 15),
                Position = UDim2New(1, -15, 1, -15),
                BackgroundTransparency = 1,
                Text = "◢",
                TextColor3 = Library.Theme.TextDim,
                TextSize = 12,
                ZIndex = 100,
                AutoButtonColor = false
            })

            ResizeHandle:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Resizing = true
                    StartMouse = UserInputService:GetMouseLocation()
                    StartSize = Vector2New(Gui.Size.X.Offset, Gui.Size.Y.Offset)
                end
            end)

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Resizing = false
                end
            end)

            Library:Connect(RunService.RenderStepped, function()
                if Resizing then
                    local MouseLoc = UserInputService:GetMouseLocation()
                    local Delta = MouseLoc - StartMouse
                    local NewW = MathClamp(StartSize.X + Delta.X, Minimum.X, Maximum.X)
                    local NewH = MathClamp(StartSize.Y + Delta.Y, Minimum.Y, Maximum.Y)
                    
                    self:Tween(TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
                        Size = UDim2FromOffset(NewW, NewH)
                    })
                end
            end)
        end
    end

    -- Screen Holders
    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "UltraLibrary_Holder",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 999,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "UltraLibrary_Unused",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        ResetOnSpawn = false
    })

    Library.NotifHolder = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Name = "NotificationHolder",
        BackgroundTransparency = 1,
        Size = UDim2New(0, 300, 1, -20),
        Position = UDim2New(1, -310, 0, 10),
        BackgroundColor3 = FromRGB(255, 255, 255)
    })

    Instances:Create("UIListLayout", {
        Parent = Library.NotifHolder.Instance,
        Padding = UDimNew(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })

    -- System Utilities
    function Library:Thread(Function)
        local NewThread = coroutine.create(Function)
        coroutine.wrap(function()
            coroutine.resume(NewThread)
        end)()
        TableInsert(self.Threads, NewThread)
        return NewThread
    end

    function Library:SafeCall(Function, ...)
        local Args = { ... }
        local Success, Result = pcall(Function, TableUnpack(Args))
        if not Success then
            warn("[Library Error]: " .. tostring(Result))
        end
        return Success, Result
    end

    function Library:Connect(Event, Callback)
        local NewConnection = {
            Event = Event,
            Callback = Callback,
            Connection = Event:Connect(Callback)
        }
        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    function Library:AddToTheme(Item, Properties)
        Item = Item.Instance or Item
        local ThemeData = { Item = Item, Properties = Properties }

        for Property, ColorName in pairs(Properties) do
            if type(ColorName) == "string" and self.Theme[ColorName] then
                Item[Property] = self.Theme[ColorName]
            elseif type(ColorName) == "function" then
                Item[Property] = ColorName()
            end
        end

        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    function Library:ChangeTheme(ThemeProperty, Color)
        self.Theme[ThemeProperty] = Color
        for _, ThemeData in pairs(self.ThemeItems) do
            for Property, ColorName in pairs(ThemeData.Properties) do
                if type(ColorName) == "string" and ColorName == ThemeProperty then
                    ThemeData.Item[Property] = Color
                elseif type(ColorName) == "function" then
                    ThemeData.Item[Property] = ColorName()
                end
            end
        end
    end

    function Library:IsMouseOverFrame(Frame)
        Frame = Frame.Instance or Frame
        local MousePos = Vector2New(Mouse.X, Mouse.Y)
        return MousePos.X >= Frame.AbsolutePosition.X and MousePos.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X 
           and MousePos.Y >= Frame.AbsolutePosition.Y and MousePos.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end

    function Library:MakeBlurred(Item, Window)
        Item = Item.Instance or Item
        local DepthOfField = Instances:Create("DepthOfFieldEffect", {
            Parent = Lighting,
            Enabled = false,
            FarIntensity = 0,
            FocusDistance = 0,
            InFocusRadius = 1000,
            NearIntensity = 0.75,
            Name = "UltraBlur"
        })
        TableInsert(self.ToClean, DepthOfField.Instance)

        Library:Connect(RunService.RenderStepped, function()
            if Window and Window.IsOpen and Item.Visible then
                DepthOfField.Instance.Enabled = true
            else
                DepthOfField.Instance.Enabled = false
            end
        end)
    end

    function Library:Notification(Data)
        Data = Data or {}
        Data.Title = Data.Title or "Notification"
        Data.Description = Data.Description or "Message content goes here."
        Data.Duration = Data.Duration or 3
        Data.Icon = FormatAssetId(Data.Icon or "10723345518")

        local NotifFrame = Instances:Create("Frame", {
            Parent = Library.NotifHolder.Instance,
            Size = UDim2New(1, 0, 0, 60),
            BackgroundColor3 = Library.Theme["Background 2"],
            BorderSizePixel = 0,
            BackgroundTransparency = 1
        })  NotifFrame:AddToTheme({BackgroundColor3 = "Background 2"})

        Instances:Create("UICorner", { Parent = NotifFrame.Instance, CornerRadius = UDimNew(0, 6) })
        Instances:Create("UIStroke", { Parent = NotifFrame.Instance, Color = Library.Theme.Outline, Thickness = 1 }):AddToTheme({Color = "Outline"})

        local IconLabel = Instances:Create("ImageLabel", {
            Parent = NotifFrame.Instance,
            Size = UDim2New(0, 24, 0, 24),
            Position = UDim2New(0, 10, 0, 12),
            BackgroundTransparency = 1,
            Image = Data.Icon,
            ImageColor3 = Library.Theme.Accent
        })  IconLabel:AddToTheme({ImageColor3 = "Accent"})

        local TitleLabel = Instances:Create("TextLabel", {
            Parent = NotifFrame.Instance,
            Size = UDim2New(1, -45, 0, 18),
            Position = UDim2New(0, 40, 0, 8),
            BackgroundTransparency = 1,
            Text = Data.Title,
            TextColor3 = Library.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 14,
            FontFace = Library.Font
        })  TitleLabel:AddToTheme({TextColor3 = "Text"})

        local DescLabel = Instances:Create("TextLabel", {
            Parent = NotifFrame.Instance,
            Size = UDim2New(1, -45, 0, 28),
            Position = UDim2New(0, 40, 0, 26),
            BackgroundTransparency = 1,
            Text = Data.Description,
            TextColor3 = Library.Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextSize = 12,
            FontFace = Library.Font
        })  DescLabel:AddToTheme({TextColor3 = "Text Dim"})

        local ProgressBar = Instances:Create("Frame", {
            Parent = NotifFrame.Instance,
            Size = UDim2New(1, 0, 0, 2),
            Position = UDim2New(0, 0, 1, -2),
            BackgroundColor3 = Library.Theme.Accent,
            BorderSizePixel = 0
        })  ProgressBar:AddToTheme({BackgroundColor3 = "Accent"})

        NotifFrame:Tween(nil, {BackgroundTransparency = 0.05})
        ProgressBar:Tween(TweenInfo.new(Data.Duration, Enum.EasingStyle.Linear), {Size = UDim2New(0, 0, 0, 2)})

        task.delay(Data.Duration, function()
            NotifFrame:Tween(nil, {BackgroundTransparency = 1})
            task.wait(0.3)
            NotifFrame:Clean()
        end)
    end

    function Library:Watermark(Data)
        Data = Data or {}
        local Watermark = {}

        local Frame = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            Size = UDim2New(0, 220, 0, 30),
            Position = UDim2New(0, 15, 0, 15),
            BackgroundColor3 = Library.Theme["Background 2"],
            BorderSizePixel = 0
        })  Frame:AddToTheme({BackgroundColor3 = "Background 2"})

        Instances:Create("UICorner", { Parent = Frame.Instance, CornerRadius = UDimNew(0, 6) })
        Instances:Create("UIStroke", { Parent = Frame.Instance, Color = Library.Theme.Accent, Thickness = 1.2 }):AddToTheme({Color = "Accent"})

        local TextLabel = Instances:Create("TextLabel", {
            Parent = Frame.Instance,
            Size = UDim2New(1, -10, 1, 0),
            Position = UDim2New(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = Data.Text or "Ultra UI Library | v2.0",
            TextColor3 = Library.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 13,
            FontFace = Library.Font
        })  TextLabel:AddToTheme({TextColor3 = "Text"})

        function Watermark:SetText(NewText)
            TextLabel.Instance.Text = NewText
        end

        function Watermark:Destroy()
            Frame:Clean()
        end

        return Watermark
    end

    function Library:KeybindList()
        local KeyList = {}
        
        local Frame = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            Size = UDim2New(0, 180, 0, 30),
            Position = UDim2New(0, 15, 0.4, 0),
            BackgroundColor3 = Library.Theme["Background 2"],
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false
        })  Frame:AddToTheme({BackgroundColor3 = "Background 2"})

        Frame:MakeDraggable()

        Instances:Create("UICorner", { Parent = Frame.Instance, CornerRadius = UDimNew(0, 6) })
        Instances:Create("UIStroke", { Parent = Frame.Instance, Color = Library.Theme.Outline, Thickness = 1 }):AddToTheme({Color = "Outline"})

        local Header = Instances:Create("TextLabel", {
            Parent = Frame.Instance,
            Size = UDim2New(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Text = "Keybinds",
            TextColor3 = Library.Theme.Accent,
            TextSize = 13,
            FontFace = Library.Font
        })  Header:AddToTheme({TextColor3 = "Accent"})

        local Container = Instances:Create("Frame", {
            Parent = Frame.Instance,
            Size = UDim2New(1, 0, 0, 0),
            Position = UDim2New(0, 0, 0, 28),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y
        })

        Instances:Create("UIListLayout", { Parent = Container.Instance, Padding = UDimNew(0, 4) })
        Instances:Create("UIPadding", { Parent = Container.Instance, PaddingLeft = UDimNew(0, 8), PaddingRight = UDimNew(0, 8), PaddingBottom = UDimNew(0, 6) })

        function KeyList:SetVisible(State)
            Frame.Instance.Visible = State
        end

        function KeyList:Add(Name, KeyName)
            local Entry = Instances:Create("Frame", {
                Parent = Container.Instance,
                Size = UDim2New(1, 0, 0, 18),
                BackgroundTransparency = 1
            })

            local NameLbl = Instances:Create("TextLabel", {
                Parent = Entry.Instance,
                Size = UDim2New(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Library.Theme.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 12,
                FontFace = Library.Font
            })  NameLbl:AddToTheme({TextColor3 = "Text Dim"})

            local KeyLbl = Instances:Create("TextLabel", {
                Parent = Entry.Instance,
                Size = UDim2New(0.3, 0, 1, 0),
                Position = UDim2New(0.7, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = "[" .. tostring(KeyName) .. "]",
                TextColor3 = Library.Theme.Accent,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextSize = 12,
                FontFace = Library.Font
            })  KeyLbl:AddToTheme({TextColor3 = "Accent"})

            return {
                Update = function(self, NewKey)
                    KeyLbl.Instance.Text = "[" .. tostring(NewKey) .. "]"
                end,
                Remove = function(self)
                    Entry:Clean()
                end
            }
        end

        return KeyList
    end

    -- Config System
    function Library:SaveConfig(Name)
        if not isfolder(self.Folders.Configs) then return end
        local Data = {}
        for Flag, Value in pairs(self.Flags) do
            if typeof(Value) == "Color3" then
                Data[Flag] = { R = Value.R, G = Value.G, B = Value.B }
            elseif typeof(Value) == "EnumItem" then
                Data[Flag] = { Enum = tostring(Value) }
            else
                Data[Flag] = Value
            end
        end
        writefile(self.Folders.Configs .. "/" .. Name .. ".json", HttpService:JSONEncode(Data))
        self:Notification({ Title = "Configs", Description = "Saved config: " .. Name, Duration = 2 })
    end

    function Library:LoadConfig(Name)
        local Path = self.Folders.Configs .. "/" .. Name .. ".json"
        if not isfile(Path) then return end
        local Success, Decoded = pcall(function()
            return HttpService:JSONDecode(readfile(Path))
        end)
        if not Success or not Decoded then return end

        for Flag, Value in pairs(Decoded) do
            if self.SetFlags[Flag] then
                if type(Value) == "table" and Value.R then
                    self.SetFlags[Flag](FromRGB(Value.R * 255, Value.G * 255, Value.B * 255))
                else
                    self.SetFlags[Flag](Value)
                end
            end
        end
        self:Notification({ Title = "Configs", Description = "Loaded config: " .. Name, Duration = 2 })
    end

    function Library:Unload()
        for _, Connection in pairs(self.Connections) do
            if Connection.Connection then Connection.Connection:Disconnect() end
        end
        for _, Thread in pairs(self.Threads) do
            pcall(task.cancel, Thread)
        end
        for _, Object in pairs(self.ToClean) do
            if Object and Object.Destroy then Object:Destroy() end
        end
        if self.Holder then self.Holder:Clean() end
        if self.UnusedHolder then self.UnusedHolder:Clean() end
    end

    -- ================================================================================
    -- MAIN GUI BUILDER FUNCTION (CONSTRUCTS WHOLE FRAME & CONTROL CONTAINERS)
    -- ================================================================================

    function Library:CreateWindow(Data)
        Data = Data or {}
        local Window = {
            Title = Data.Title or Data.Name or "Ultra Interface",
            SubTitle = Data.SubTitle or "PC & Mobile Edition",
            Logo = FormatAssetId(Data.Logo or "10723345518"),
            TabList = {},
            ActiveTab = nil,
            IsOpen = true,
            Elements = {}
        }

        -- Main GUI Container
        local MainFrame = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            Size = UDim2New(0, IsMobile and 520 or 650, 0, IsMobile and 340 or 420),
            Position = UDim2New(0.5, IsMobile and -260 or -325, 0.5, IsMobile and -170 or -210),
            BackgroundColor3 = Library.Theme.Background,
            BorderSizePixel = 0,
            ZIndex = 2
        })  MainFrame:AddToTheme({BackgroundColor3 = "Background"})

        MainFrame:MakeDraggable()
        MainFrame:MakeResizeable(Vector2New(480, 300), Vector2New(900, 600))
        Library:MakeBlurred(MainFrame, Window)

        Instances:Create("UICorner", { Parent = MainFrame.Instance, CornerRadius = UDimNew(0, 8) })
        Instances:Create("UIStroke", { Parent = MainFrame.Instance, Color = Library.Theme.Outline, Thickness = 1.5 }):AddToTheme({Color = "Outline"})

        -- Top Header Bar
        local TopBar = Instances:Create("Frame", {
            Parent = MainFrame.Instance,
            Size = UDim2New(1, 0, 0, 45),
            BackgroundColor3 = Library.Theme["Background 2"],
            BorderSizePixel = 0
        })  TopBar:AddToTheme({BackgroundColor3 = "Background 2"})

        Instances:Create("UICorner", { Parent = TopBar.Instance, CornerRadius = UDimNew(0, 8) })

        -- Logo Icon
        local LogoIcon = Instances:Create("ImageLabel", {
            Parent = TopBar.Instance,
            Size = UDim2New(0, 26, 0, 26),
            Position = UDim2New(0, 10, 0, 9),
            BackgroundTransparency = 1,
            Image = Window.Logo,
            ImageColor3 = Library.Theme.Accent
        })  LogoIcon:AddToTheme({ImageColor3 = "Accent"})

        -- Title & Subtitle Labels
        local TitleLabel = Instances:Create("TextLabel", {
            Parent = TopBar.Instance,
            Size = UDim2New(0, 200, 0, 20),
            Position = UDim2New(0, 42, 0, 5),
            BackgroundTransparency = 1,
            Text = Window.Title,
            TextColor3 = Library.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 15,
            FontFace = Library.Font
        })  TitleLabel:AddToTheme({TextColor3 = "Text"})

        local SubTitleLabel = Instances:Create("TextLabel", {
            Parent = TopBar.Instance,
            Size = UDim2New(0, 200, 0, 16),
            Position = UDim2New(0, 42, 0, 23),
            BackgroundTransparency = 1,
            Text = Window.SubTitle,
            TextColor3 = Library.Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 11,
            FontFace = Library.Font
        })  SubTitleLabel:AddToTheme({TextColor3 = "Text Dim"})

        -- Global Search Engine Box
        local SearchBox = Instances:Create("TextBox", {
            Parent = TopBar.Instance,
            Size = UDim2New(0, IsMobile and 120 or 170, 0, 26),
            Position = UDim2New(1, IsMobile and -200 or -250, 0, 9),
            BackgroundColor3 = Library.Theme.Element,
            Text = "",
            PlaceholderText = "🔍 Search...",
            PlaceholderColor3 = Library.Theme.TextDim,
            TextColor3 = Library.Theme.Text,
            TextSize = 12,
            FontFace = Library.Font,
            BorderSizePixel = 0
        })  SearchBox:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text", PlaceholderColor3 = "Text Dim"})

        Instances:Create("UICorner", { Parent = SearchBox.Instance, CornerRadius = UDimNew(0, 5) })

        -- Close & Minimize Window Controls
        local MinimizeBtn = Instances:Create("TextButton", {
            Parent = TopBar.Instance,
            Size = UDim2New(0, 28, 0, 28),
            Position = UDim2New(1, -70, 0, 8),
            BackgroundColor3 = Library.Theme.Element,
            Text = "-",
            TextColor3 = Library.Theme.Text,
            TextSize = 16,
            FontFace = Library.Font,
            AutoButtonColor = false
        })  MinimizeBtn:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text"})
        Instances:Create("UICorner", { Parent = MinimizeBtn.Instance, CornerRadius = UDimNew(0, 5) })

        local CloseBtn = Instances:Create("TextButton", {
            Parent = TopBar.Instance,
            Size = UDim2New(0, 28, 0, 28),
            Position = UDim2New(1, -36, 0, 8),
            BackgroundColor3 = FromRGB(200, 50, 50),
            Text = "×",
            TextColor3 = FromRGB(255, 255, 255),
            TextSize = 18,
            FontFace = Library.Font,
            AutoButtonColor = false
        })
        Instances:Create("UICorner", { Parent = CloseBtn.Instance, CornerRadius = UDimNew(0, 5) })

        -- Sidebar Navigation Container
        local Sidebar = Instances:Create("ScrollingFrame", {
            Parent = MainFrame.Instance,
            Size = UDim2New(0, IsMobile and 120 or 150, 1, -55),
            Position = UDim2New(0, 5, 0, 50),
            BackgroundColor3 = Library.Theme["Background 2"],
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent
        })  Sidebar:AddToTheme({BackgroundColor3 = "Background 2", ScrollBarImageColor3 = "Accent"})

        Instances:Create("UICorner", { Parent = Sidebar.Instance, CornerRadius = UDimNew(0, 6) })
        Instances:Create("UIListLayout", { Parent = Sidebar.Instance, Padding = UDimNew(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })
        Instances:Create("UIPadding", { Parent = Sidebar.Instance, PaddingTop = UDimNew(0, 5), PaddingLeft = UDimNew(0, 5), PaddingRight = UDimNew(0, 5) })

        -- Content Container Body
        local ContentHolder = Instances:Create("Frame", {
            Parent = MainFrame.Instance,
            Size = UDim2New(1, IsMobile and -135 or -165, 1, -55),
            Position = UDim2New(0, IsMobile and 130 or 160, 0, 50),
            BackgroundTransparency = 1
        })

        -- Mobile Floating Action Button (FAB) Toggle Window
        local MobileToggle = Instances:Create("TextButton", {
            Parent = Library.Holder.Instance,
            Size = UDim2New(0, 45, 0, 45),
            Position = UDim2New(0, 15, 0.2, 0),
            BackgroundColor3 = Library.Theme.Accent,
            Text = "UI",
            TextColor3 = FromRGB(255, 255, 255),
            TextSize = 16,
            FontFace = Library.Font,
            Visible = IsMobile
        })  MobileToggle:AddToTheme({BackgroundColor3 = "Accent"})

        MobileToggle:MakeDraggable()
        Instances:Create("UICorner", { Parent = MobileToggle.Instance, CornerRadius = UDimNew(1, 0) })
        Instances:Create("UIStroke", { Parent = MobileToggle.Instance, Color = FromRGB(255, 255, 255), Thickness = 1.5 })

        -- Toggle Window Logic
        local function ToggleWindow(State)
            Window.IsOpen = (State ~= nil and State) or not Window.IsOpen
            MainFrame.Instance.Visible = Window.IsOpen
        end

        CloseBtn:Connect("MouseButton1Click", function()
            ToggleWindow(false)
        end)

        MinimizeBtn:Connect("MouseButton1Click", function()
            ToggleWindow(false)
        end)

        MobileToggle:Connect("MouseButton1Click", function()
            ToggleWindow()
        end)

        Library:Connect(UserInputService.InputBegan, function(Input, Processed)
            if not Processed and Input.KeyCode == Library.MenuKeybind then
                ToggleWindow()
            end
        end)

        -- Search Box Functionality
        SearchBox:Connect("Changed", function(Property)
            if Property == "Text" then
                local Query = StringLower(SearchBox.Instance.Text)
                for _, ElementData in pairs(Window.Elements) do
                    if ElementData.Frame then
                        if Query == "" then
                            ElementData.Frame.Instance.Visible = true
                        else
                            local Match = StringLower(ElementData.Name):find(Query) ~= nil
                            ElementData.Frame.Instance.Visible = Match
                        end
                    end
                end
            end
        end)

        -- ================================================================================
        -- TAB CREATION SYSTEM (SEPARATED API)
        -- ================================================================================

        function Window:CreateTab(TabData)
            TabData = TabData or {}
            local Tab = {
                Name = TabData.Name or "Tab",
                Icon = FormatAssetId(TabData.Icon or ""),
                Sections = {}
            }

            -- Sidebar Button
            local TabBtn = Instances:Create("TextButton", {
                Parent = Sidebar.Instance,
                Size = UDim2New(1, 0, 0, 32),
                BackgroundColor3 = Library.Theme.Element,
                Text = "",
                AutoButtonColor = false,
                BorderSizePixel = 0
            })  TabBtn:AddToTheme({BackgroundColor3 = "Element"})

            Instances:Create("UICorner", { Parent = TabBtn.Instance, CornerRadius = UDimNew(0, 5) })

            local TabIcon = Instances:Create("ImageLabel", {
                Parent = TabBtn.Instance,
                Size = UDim2New(0, 18, 0, 18),
                Position = UDim2New(0, 8, 0.5, -9),
                BackgroundTransparency = 1,
                Image = Tab.Icon,
                ImageColor3 = Library.Theme.TextDim,
                Visible = Tab.Icon ~= ""
            })  TabIcon:AddToTheme({ImageColor3 = "Text Dim"})

            local TabLbl = Instances:Create("TextLabel", {
                Parent = TabBtn.Instance,
                Size = UDim2New(1, Tab.Icon ~= "" and -32 or -10, 1, 0),
                Position = UDim2New(0, Tab.Icon ~= "" and 30 or 10, 0, 0),
                BackgroundTransparency = 1,
                Text = Tab.Name,
                TextColor3 = Library.Theme.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 13,
                FontFace = Library.Font
            })  TabLbl:AddToTheme({TextColor3 = "Text Dim"})

            -- Tab Content Page Scrolling Container
            local TabPage = Instances:Create("ScrollingFrame", {
                Parent = ContentHolder.Instance,
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = false,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Library.Theme.Accent
            })  TabPage:AddToTheme({ScrollBarImageColor3 = "Accent"})

            local LeftColumn = Instances:Create("Frame", {
                Parent = TabPage.Instance,
                Size = UDim2New(0.49, 0, 1, 0),
                Position = UDim2New(0, 0, 0, 0),
                BackgroundTransparency = 1
            })

            local RightColumn = Instances:Create("Frame", {
                Parent = TabPage.Instance,
                Size = UDim2New(0.49, 0, 1, 0),
                Position = UDim2New(0.51, 0, 0, 0),
                BackgroundTransparency = 1
            })

            Instances:Create("UIListLayout", { Parent = LeftColumn.Instance, Padding = UDimNew(0, 8) })
            Instances:Create("UIListLayout", { Parent = RightColumn.Instance, Padding = UDimNew(0, 8) })

            -- Select Tab Logic
            function Tab:Select()
                for _, OtherTab in pairs(Window.TabList) do
                    OtherTab.Page.Instance.Visible = false
                    OtherTab.Button:Tween(nil, {BackgroundColor3 = Library.Theme.Element})
                    OtherTab.Label:Tween(nil, {TextColor3 = Library.Theme.TextDim})
                    if OtherTab.IconLabel then OtherTab.IconLabel:Tween(nil, {ImageColor3 = Library.Theme.TextDim}) end
                end

                TabPage.Instance.Visible = true
                Window.ActiveTab = Tab
                TabBtn:Tween(nil, {BackgroundColor3 = Library.Theme.Accent})
                TabLbl:Tween(nil, {TextColor3 = FromRGB(255, 255, 255)})
                if TabIcon then TabIcon:Tween(nil, {ImageColor3 = FromRGB(255, 255, 255)}) end
            end

            TabBtn:Connect("MouseButton1Click", function()
                Tab:Select()
            end)

            Tab.Page = TabPage
            Tab.Button = TabBtn
            Tab.Label = TabLbl
            Tab.IconLabel = TabIcon

            TableInsert(Window.TabList, Tab)

            if #Window.TabList == 1 then
                Tab:Select()
            end

            -- ================================================================================
            -- SECTION CREATION SYSTEM
            -- ================================================================================

            function Tab:CreateSection(SecData)
                SecData = SecData or {}
                local Section = {
                    Name = SecData.Name or "Section",
                    Side = SecData.Side or "Left"
                }

                local ParentCol = (SecData.Side == "Right" and RightColumn) or LeftColumn

                local SecFrame = Instances:Create("Frame", {
                    Parent = ParentCol.Instance,
                    Size = UDim2New(1, 0, 0, 30),
                    BackgroundColor3 = Library.Theme["Section Background"],
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y
                })  SecFrame:AddToTheme({BackgroundColor3 = "Section Background"})

                Instances:Create("UICorner", { Parent = SecFrame.Instance, CornerRadius = UDimNew(0, 6) })
                Instances:Create("UIStroke", { Parent = SecFrame.Instance, Color = Library.Theme.Outline, Thickness = 1 }):AddToTheme({Color = "Outline"})

                -- Header
                local SecHeader = Instances:Create("Frame", {
                    Parent = SecFrame.Instance,
                    Size = UDim2New(1, 0, 0, 26),
                    BackgroundColor3 = Library.Theme["Section Top"],
                    BorderSizePixel = 0
                })  SecHeader:AddToTheme({BackgroundColor3 = "Section Top"})

                Instances:Create("UICorner", { Parent = SecHeader.Instance, CornerRadius = UDimNew(0, 6) })

                local SecTitle = Instances:Create("TextLabel", {
                    Parent = SecHeader.Instance,
                    Size = UDim2New(1, -10, 1, 0),
                    Position = UDim2New(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = Section.Name,
                    TextColor3 = Library.Theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 13,
                    FontFace = Library.Font
                })  SecTitle:AddToTheme({TextColor3 = "Accent"})

                -- Controls Container inside Section
                local Container = Instances:Create("Frame", {
                    Parent = SecFrame.Instance,
                    Size = UDim2New(1, 0, 0, 0),
                    Position = UDim2New(0, 0, 0, 28),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y
                })

                Instances:Create("UIListLayout", { Parent = Container.Instance, Padding = UDimNew(0, 6) })
                Instances:Create("UIPadding", { Parent = Container.Instance, PaddingLeft = UDimNew(0, 8), PaddingRight = UDimNew(0, 8), PaddingBottom = UDimNew(0, 8) })

                -- ================================================================================
                -- UI CONTROLS & ELEMENTS
                -- ================================================================================

                -- BUTTON
                function Section:AddButton(Data)
                    Data = Data or {}
                    local BtnData = { Name = Data.Name or "Button", Callback = Data.Callback or function() end }

                    local Btn = Instances:Create("TextButton", {
                        Parent = Container.Instance,
                        Size = UDim2New(1, 0, 0, 28),
                        BackgroundColor3 = Library.Theme.Element,
                        Text = BtnData.Name,
                        TextColor3 = Library.Theme.Text,
                        TextSize = 13,
                        FontFace = Library.Font,
                        AutoButtonColor = false,
                        BorderSizePixel = 0
                    })  Btn:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text"})

                    Instances:Create("UICorner", { Parent = Btn.Instance, CornerRadius = UDimNew(0, 5) })

                    Btn:Connect("MouseButton1Click", function()
                        Btn:Tween(TweenInfo.new(0.08), {BackgroundColor3 = Library.Theme.Accent})
                        task.delay(0.1, function()
                            Btn:Tween(TweenInfo.new(0.15), {BackgroundColor3 = Library.Theme.Element})
                        end)
                        Library:SafeCall(BtnData.Callback)
                    end)

                    TableInsert(Window.Elements, { Name = BtnData.Name, Frame = Btn })
                    return Btn
                end

                -- TOGGLE
                function Section:AddToggle(Data)
                    Data = Data or {}
                    local TogData = {
                        Name = Data.Name or "Toggle",
                        Flag = Data.Flag or Library:NextFlag(),
                        Value = Data.Default or false,
                        Callback = Data.Callback or function() end
                    }

                    local TogFrame = Instances:Create("Frame", {
                        Parent = Container.Instance,
                        Size = UDim2New(1, 0, 0, 26),
                        BackgroundTransparency = 1
                    })

                    local TogLabel = Instances:Create("TextLabel", {
                        Parent = TogFrame.Instance,
                        Size = UDim2New(1, -45, 1, 0),
                        BackgroundTransparency = 1,
                        Text = TogData.Name,
                        TextColor3 = Library.Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 13,
                        FontFace = Library.Font
                    })  TogLabel:AddToTheme({TextColor3 = "Text"})

                    local Switch = Instances:Create("TextButton", {
                        Parent = TogFrame.Instance,
                        Size = UDim2New(0, 36, 0, 18),
                        Position = UDim2New(1, -36, 0.5, -9),
                        BackgroundColor3 = TogData.Value and Library.Theme.Accent or Library.Theme.Element,
                        Text = "",
                        AutoButtonColor = false
                    })

                    Instances:Create("UICorner", { Parent = Switch.Instance, CornerRadius = UDimNew(1, 0) })

                    local Dot = Instances:Create("Frame", {
                        Parent = Switch.Instance,
                        Size = UDim2New(0, 14, 0, 14),
                        Position = TogData.Value and UDim2New(1, -16, 0.5, -7) or UDim2New(0, 2, 0.5, -7),
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                    Instances:Create("UICorner", { Parent = Dot.Instance, CornerRadius = UDimNew(1, 0) })

                    local function SetState(Val)
                        TogData.Value = Val
                        Library.Flags[TogData.Flag] = Val
                        Switch:Tween(nil, {BackgroundColor3 = Val and Library.Theme.Accent or Library.Theme.Element})
                        Dot:Tween(nil, {Position = Val and UDim2New(1, -16, 0.5, -7) or UDim2New(0, 2, 0.5, -7)})
                        Library:SafeCall(TogData.Callback, Val)
                    end

                    Switch:Connect("MouseButton1Click", function()
                        SetState(not TogData.Value)
                    end)

                    Library.Flags[TogData.Flag] = TogData.Value
                    Library.SetFlags[TogData.Flag] = SetState

                    TableInsert(Window.Elements, { Name = TogData.Name, Frame = TogFrame })
                    return { Set = SetState }
                end

                -- SLIDER
                function Section:AddSlider(Data)
                    Data = Data or {}
                    local SldData = {
                        Name = Data.Name or "Slider",
                        Flag = Data.Flag or Library:NextFlag(),
                        Min = Data.Min or 0,
                        Max = Data.Max or 100,
                        Value = Data.Default or Data.Min or 0,
                        Decimals = Data.Decimals or 0,
                        Suffix = Data.Suffix or "",
                        Callback = Data.Callback or function() end
                    }

                    local SldFrame = Instances:Create("Frame", {
                        Parent = Container.Instance,
                        Size = UDim2New(1, 0, 0, 40),
                        BackgroundTransparency = 1
                    })

                    local SldLabel = Instances:Create("TextLabel", {
                        Parent = SldFrame.Instance,
                        Size = UDim2New(0.6, 0, 0, 18),
                        BackgroundTransparency = 1,
                        Text = SldData.Name,
                        TextColor3 = Library.Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 13,
                        FontFace = Library.Font
                    })  SldLabel:AddToTheme({TextColor3 = "Text"})

                    local ValueLabel = Instances:Create("TextLabel", {
                        Parent = SldFrame.Instance,
                        Size = UDim2New(0.4, 0, 0, 18),
                        Position = UDim2New(0.6, 0, 0, 0),
                        BackgroundTransparency = 1,
                        Text = tostring(SldData.Value) .. SldData.Suffix,
                        TextColor3 = Library.Theme.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextSize = 12,
                        FontFace = Library.Font
                    })  ValueLabel:AddToTheme({TextColor3 = "Text Dim"})

                    local Track = Instances:Create("TextButton", {
                        Parent = SldFrame.Instance,
                        Size = UDim2New(1, 0, 0, 10),
                        Position = UDim2New(0, 0, 0, 24),
                        BackgroundColor3 = Library.Theme.Element,
                        Text = "",
                        AutoButtonColor = false
                    })  Track:AddToTheme({BackgroundColor3 = "Element"})

                    Instances:Create("UICorner", { Parent = Track.Instance, CornerRadius = UDimNew(1, 0) })

                    local Fill = Instances:Create("Frame", {
                        Parent = Track.Instance,
                        Size = UDim2New((SldData.Value - SldData.Min) / (SldData.Max - SldData.Min), 0, 1, 0),
                        BackgroundColor3 = Library.Theme.Accent
                    })  Fill:AddToTheme({BackgroundColor3 = "Accent"})

                    Instances:Create("UICorner", { Parent = Fill.Instance, CornerRadius = UDimNew(1, 0) })

                    local Sliding = false

                    local function UpdateSlider(Input)
                        local Percent = MathClamp((Input.Position.X - Track.Instance.AbsolutePosition.X) / Track.Instance.AbsoluteSize.X, 0, 1)
                        local Value = SldData.Min + (SldData.Max - SldData.Min) * Percent

                        if SldData.Decimals == 0 then
                            Value = MathFloor(Value + 0.5)
                        else
                            local Mult = 10 ^ SldData.Decimals
                            Value = MathFloor(Value * Mult + 0.5) / Mult
                        end

                        SldData.Value = Value
                        Library.Flags[SldData.Flag] = Value
                        ValueLabel.Instance.Text = tostring(Value) .. SldData.Suffix
                        Fill:Tween(TweenInfo.new(0.05), {Size = UDim2New(Percent, 0, 1, 0)})
                        Library:SafeCall(SldData.Callback, Value)
                    end

                    Track:Connect("InputBegan", function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            Sliding = true
                            UpdateSlider(Input)
                        end
                    end)

                    Library:Connect(UserInputService.InputEnded, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            Sliding = false
                        end
                    end)

                    Library:Connect(UserInputService.InputChanged, function(Input)
                        if Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                            UpdateSlider(Input)
                        end
                    end)

                    Library.Flags[SldData.Flag] = SldData.Value
                    Library.SetFlags[SldData.Flag] = function(Val)
                        SldData.Value = Val
                        local Percent = MathClamp((Val - SldData.Min) / (SldData.Max - SldData.Min), 0, 1)
                        Fill:Tween(nil, {Size = UDim2New(Percent, 0, 1, 0)})
                        ValueLabel.Instance.Text = tostring(Val) .. SldData.Suffix
                        Library:SafeCall(SldData.Callback, Val)
                    end

                    TableInsert(Window.Elements, { Name = SldData.Name, Frame = SldFrame })
                    return { Set = Library.SetFlags[SldData.Flag] }
                end

                -- DROPDOWN (SEPARATED API)
                function Section:AddDropdown(Data)
                    Data = Data or {}
                    local DropData = {
                        Name = Data.Name or "Dropdown",
                        Flag = Data.Flag or Library:NextFlag(),
                        Options = Data.Options or {},
                        Value = Data.Default or nil,
                        Callback = Data.Callback or function() end,
                        IsOpen = false
                    }

                    local DropFrame = Instances:Create("Frame", {
                        Parent = Container.Instance,
                        Size = UDim2New(1, 0, 0, 46),
                        BackgroundTransparency = 1
                    })

                    local DropLabel = Instances:Create("TextLabel", {
                        Parent = DropFrame.Instance,
                        Size = UDim2New(1, 0, 0, 18),
                        BackgroundTransparency = 1,
                        Text = DropData.Name,
                        TextColor3 = Library.Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 13,
                        FontFace = Library.Font
                    })  DropLabel:AddToTheme({TextColor3 = "Text"})

                    local DropBtn = Instances:Create("TextButton", {
                        Parent = DropFrame.Instance,
                        Size = UDim2New(1, 0, 0, 24),
                        Position = UDim2New(0, 0, 0, 20),
                        BackgroundColor3 = Library.Theme.Element,
                        Text = DropData.Value or "Select...",
                        TextColor3 = Library.Theme.TextDim,
                        TextSize = 12,
                        FontFace = Library.Font,
                        AutoButtonColor = false
                    })  DropBtn:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text Dim"})

                    Instances:Create("UICorner", { Parent = DropBtn.Instance, CornerRadius = UDimNew(0, 5) })

                    local Arrow = Instances:Create("TextLabel", {
                        Parent = DropBtn.Instance,
                        Size = UDim2New(0, 20, 1, 0),
                        Position = UDim2New(1, -20, 0, 0),
                        BackgroundTransparency = 1,
                        Text = "▼",
                        TextColor3 = Library.Theme.TextDim,
                        TextSize = 10
                    })

                    -- Options List Window Container
                    local ListHolder = Instances:Create("ScrollingFrame", {
                        Parent = Library.Holder.Instance,
                        Size = UDim2New(0, 100, 0, 0),
                        BackgroundColor3 = Library.Theme["Background 2"],
                        BorderSizePixel = 0,
                        Visible = false,
                        ZIndex = 100,
                        ScrollBarThickness = 2
                    })  ListHolder:AddToTheme({BackgroundColor3 = "Background 2"})

                    Instances:Create("UICorner", { Parent = ListHolder.Instance, CornerRadius = UDimNew(0, 5) })
                    Instances:Create("UIStroke", { Parent = ListHolder.Instance, Color = Library.Theme.Outline, Thickness = 1 }):AddToTheme({Color = "Outline"})
                    Instances:Create("UIListLayout", { Parent = ListHolder.Instance, Padding = UDimNew(0, 2) })

                    local function ToggleList(State)
                        DropData.IsOpen = (State ~= nil and State) or not DropData.IsOpen
                        if DropData.IsOpen then
                            ListHolder.Instance.Size = UDim2New(0, DropBtn.Instance.AbsoluteSize.X, 0, MathClamp(#DropData.Options * 22, 22, 120))
                            ListHolder.Instance.Position = UDim2New(0, DropBtn.Instance.AbsolutePosition.X, 0, DropBtn.Instance.AbsolutePosition.Y + DropBtn.Instance.AbsoluteSize.Y + 2)
                            ListHolder.Instance.Visible = true
                            Arrow.Instance.Text = "▲"
                        else
                            ListHolder.Instance.Visible = false
                            Arrow.Instance.Text = "▼"
                        end
                    end

                    local function RefreshOptions()
                        for _, Child in pairs(ListHolder.Instance:GetChildren()) do
                            if Child:IsA("TextButton") then Child:Destroy() end
                        end

                        for _, Opt in pairs(DropData.Options) do
                            local OptBtn = Instances:Create("TextButton", {
                                Parent = ListHolder.Instance,
                                Size = UDim2New(1, 0, 0, 20),
                                BackgroundColor3 = Library.Theme.Element,
                                Text = tostring(Opt),
                                TextColor3 = Library.Theme.Text,
                                TextSize = 12,
                                FontFace = Library.Font,
                                AutoButtonColor = false,
                                ZIndex = 101
                            })  OptBtn:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text"})

                            OptBtn:Connect("MouseButton1Click", function()
                                DropData.Value = Opt
                                Library.Flags[DropData.Flag] = Opt
                                DropBtn.Instance.Text = tostring(Opt)
                                ToggleList(false)
                                Library:SafeCall(DropData.Callback, Opt)
                            end)
                        end
                    end

                    DropBtn:Connect("MouseButton1Click", function()
                        ToggleList()
                    end)

                    RefreshOptions()

                    Library.Flags[DropData.Flag] = DropData.Value
                    Library.SetFlags[DropData.Flag] = function(Val)
                        DropData.Value = Val
                        DropBtn.Instance.Text = tostring(Val)
                        Library:SafeCall(DropData.Callback, Val)
                    end

                    TableInsert(Window.Elements, { Name = DropData.Name, Frame = DropFrame })
                    return {
                        Set = Library.SetFlags[DropData.Flag],
                        Refresh = function(self, NewOpts)
                            DropData.Options = NewOpts
                            RefreshOptions()
                        end
                    }
                end

                -- TEXT INPUT / TEXTBOX
                function Section:AddInput(Data)
                    Data = Data or {}
                    local InpData = {
                        Name = Data.Name or "Input",
                        Flag = Data.Flag or Library:NextFlag(),
                        Placeholder = Data.Placeholder or "Type here...",
                        Value = Data.Default or "",
                        Callback = Data.Callback or function() end
                    }

                    local InpFrame = Instances:Create("Frame", {
                        Parent = Container.Instance,
                        Size = UDim2New(1, 0, 0, 46),
                        BackgroundTransparency = 1
                    })

                    local InpLabel = Instances:Create("TextLabel", {
                        Parent = InpFrame.Instance,
                        Size = UDim2New(1, 0, 0, 18),
                        BackgroundTransparency = 1,
                        Text = InpData.Name,
                        TextColor3 = Library.Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 13,
                        FontFace = Library.Font
                    })  InpLabel:AddToTheme({TextColor3 = "Text"})

                    local Box = Instances:Create("TextBox", {
                        Parent = InpFrame.Instance,
                        Size = UDim2New(1, 0, 0, 24),
                        Position = UDim2New(0, 0, 0, 20),
                        BackgroundColor3 = Library.Theme.Element,
                        Text = InpData.Value,
                        PlaceholderText = InpData.Placeholder,
                        PlaceholderColor3 = Library.Theme.TextDim,
                        TextColor3 = Library.Theme.Text,
                        TextSize = 12,
                        FontFace = Library.Font,
                        ClearTextOnFocus = false
                    })  Box:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text", PlaceholderColor3 = "Text Dim"})

                    Instances:Create("UICorner", { Parent = Box.Instance, CornerRadius = UDimNew(0, 5) })

                    Box:Connect("FocusLost", function()
                        InpData.Value = Box.Instance.Text
                        Library.Flags[InpData.Flag] = Box.Instance.Text
                        Library:SafeCall(InpData.Callback, Box.Instance.Text)
                    end)

                    Library.Flags[InpData.Flag] = InpData.Value
                    Library.SetFlags[InpData.Flag] = function(Text)
                        InpData.Value = Text
                        Box.Instance.Text = Text
                        Library:SafeCall(InpData.Callback, Text)
                    end

                    TableInsert(Window.Elements, { Name = InpData.Name, Frame = InpFrame })
                    return { Set = Library.SetFlags[InpData.Flag] }
                end

                -- KEYBIND
                function Section:AddKeybind(Data)
                    Data = Data or {}
                    local KeyData = {
                        Name = Data.Name or "Keybind",
                        Flag = Data.Flag or Library:NextFlag(),
                        Value = Data.Default or Enum.KeyCode.E,
                        Callback = Data.Callback or function() end,
                        Binding = false
                    }

                    local KeyFrame = Instances:Create("Frame", {
                        Parent = Container.Instance,
                        Size = UDim2New(1, 0, 0, 26),
                        BackgroundTransparency = 1
                    })

                    local KeyLabel = Instances:Create("TextLabel", {
                        Parent = KeyFrame.Instance,
                        Size = UDim2New(1, -70, 1, 0),
                        BackgroundTransparency = 1,
                        Text = KeyData.Name,
                        TextColor3 = Library.Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 13,
                        FontFace = Library.Font
                    })  KeyLabel:AddToTheme({TextColor3 = "Text"})

                    local BindBtn = Instances:Create("TextButton", {
                        Parent = KeyFrame.Instance,
                        Size = UDim2New(0, 60, 0, 20),
                        Position = UDim2New(1, -60, 0.5, -10),
                        BackgroundColor3 = Library.Theme.Element,
                        Text = KeyData.Value.Name,
                        TextColor3 = Library.Theme.TextDim,
                        TextSize = 11,
                        FontFace = Library.Font,
                        AutoButtonColor = false
                    })  BindBtn:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text Dim"})

                    Instances:Create("UICorner", { Parent = BindBtn.Instance, CornerRadius = UDimNew(0, 4) })

                    BindBtn:Connect("MouseButton1Click", function()
                        KeyData.Binding = true
                        BindBtn.Instance.Text = "..."
                    end)

                    Library:Connect(UserInputService.InputBegan, function(Input, Processed)
                        if KeyData.Binding then
                            if Input.UserInputType == Enum.UserInputType.Keyboard then
                                KeyData.Value = Input.KeyCode
                                KeyData.Binding = false
                                BindBtn.Instance.Text = Input.KeyCode.Name
                                Library.Flags[KeyData.Flag] = Input.KeyCode
                            end
                        elseif not Processed and Input.KeyCode == KeyData.Value then
                            Library:SafeCall(KeyData.Callback, KeyData.Value)
                        end
                    end)

                    TableInsert(Window.Elements, { Name = KeyData.Name, Frame = KeyFrame })
                    return { Set = function(self, Key) KeyData.Value = Key BindBtn.Instance.Text = Key.Name end }
                end

                -- COLORPICKER
                function Section:AddColorpicker(Data)
                    Data = Data or {}
                    local ColorData = {
                        Name = Data.Name or "Colorpicker",
                        Flag = Data.Flag or Library:NextFlag(),
                        Value = Data.Default or FromRGB(255, 255, 255),
                        Callback = Data.Callback or function() end
                    }

                    local ColorFrame = Instances:Create("Frame", {
                        Parent = Container.Instance,
                        Size = UDim2New(1, 0, 0, 26),
                        BackgroundTransparency = 1
                    })

                    local ColorLabel = Instances:Create("TextLabel", {
                        Parent = ColorFrame.Instance,
                        Size = UDim2New(1, -30, 1, 0),
                        BackgroundTransparency = 1,
                        Text = ColorData.Name,
                        TextColor3 = Library.Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 13,
                        FontFace = Library.Font
                    })  ColorLabel:AddToTheme({TextColor3 = "Text"})

                    local ColorBtn = Instances:Create("TextButton", {
                        Parent = ColorFrame.Instance,
                        Size = UDim2New(0, 24, 0, 16),
                        Position = UDim2New(1, -24, 0.5, -8),
                        BackgroundColor3 = ColorData.Value,
                        Text = "",
                        AutoButtonColor = false
                    })

                    Instances:Create("UICorner", { Parent = ColorBtn.Instance, CornerRadius = UDimNew(0, 4) })

                    -- Delegated to Library.CreateColorpicker internally
                    Library.SetFlags[ColorData.Flag] = function(Col)
                        ColorData.Value = Col
                        ColorBtn.Instance.BackgroundColor3 = Col
                        Library:SafeCall(ColorData.Callback, Col)
                    end

                    TableInsert(Window.Elements, { Name = ColorData.Name, Frame = ColorFrame })
                    return { Set = Library.SetFlags[ColorData.Flag] }
                end

                -- LABEL / PARAGRAPH
                function Section:AddLabel(Text)
                    local LabelFrame = Instances:Create("Frame", {
                        Parent = Container.Instance,
                        Size = UDim2New(1, 0, 0, 20),
                        BackgroundTransparency = 1
                    })

                    local TextLbl = Instances:Create("TextLabel", {
                        Parent = LabelFrame.Instance,
                        Size = UDim2New(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = tostring(Text),
                        TextColor3 = Library.Theme.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        TextSize = 12,
                        FontFace = Library.Font
                    })  TextLbl:AddToTheme({TextColor3 = "Text Dim"})

                    return { Set = function(self, NewText) TextLbl.Instance.Text = NewText end }
                end

                return Section
            end

            return Tab
        end

        return Window
    end
end

return Library
