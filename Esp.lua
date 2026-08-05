-- ================================================================= --
--                     FULL ROBLOX UI LIBRARY                        --
-- ================================================================= --

local Library do 
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")

    gethui = gethui or function()
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
    local MathAbs = math.abs
    local MathSin = math.sin

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub
    local StringLower = string.lower
    local StringLen = string.len

    local InstanceNew = Instance.new
    local RectNew = Rect.new

    local IsMobile = UserInputService.TouchEnabled or false

    Library = {
        Theme =  { },
        ToClean = { },

        MenuKeybind = "Insert", 

        Flags = { },

        Tween = {
            Time = 0.3,
            Style = Enum.EasingStyle.Quad,
            Direction = Enum.EasingDirection.Out
        },

        FadeSpeed = 0.2,

        Folders = {
            Directory = "lyapossss",
            Configs = "lyapossss/Configs",
            Assets = "lyapossss/Assets",
        },

        Pages = { },
        Sections = { },

        Connections = { },
        Threads = { },

        ThemeMap = { },
        ThemeItems = { },

        OpenFrames = { },

        SetFlags = { },

        UnnamedConnections = 0,
        UnnamedFlags = 0,

        Holder = nil,
        NotifHolder = nil,
        UnusedHolder = nil,

        Font = nil
    }

    Library.__index = Library
    Library.Sections.__index = Library.Sections
    Library.Pages.__index = Library.Pages

    local Themes = {
        ["Preset"] = {
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
        }
    }

    Library.Theme = TableClone(Themes["Preset"])

    -- Folders
    for Index, Value in Library.Folders do 
        if not isfolder(Value) then
            makefolder(Value)
        end
    end

    -- Tweening
    local Tween = { } do
        Tween.__index = Tween

        Tween.Create = function(self, Item, Info, Goal, IsRawItem)
            Item = IsRawItem and Item or Item.Instance
            Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)

            local NewTween = {
                Tween = TweenService:Create(Item, Info, Goal),
                Info = Info,
                Goal = Goal,
                Item = Item
            }

            NewTween.Tween:Play()
            setmetatable(NewTween, Tween)
            return NewTween
        end

        Tween.GetProperty = function(self, Item)
            Item = Item or self.Item 

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

        Tween.FadeItem = function(self, Item, Property, Visibility, Speed)
            local Item = Item or self.Item 

            local OldTransparency = Item[Property]
            Item[Property] = Visibility and 1 or OldTransparency

            local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = Visibility and OldTransparency or 1
            }, true)

            Library:Connect(NewTween.Tween.Completed, function()
                if not Visibility then 
                    task.wait()
                    Item[Property] = OldTransparency
                end
            end)

            return NewTween
        end
    end

    -- Instances
    local Instances = { } do
        Instances.__index = Instances

        Instances.Create = function(self, Class, Properties)
            local NewItem = {
                Instance = InstanceNew(Class),
                Properties = Properties,
                Class = Class
            }

            setmetatable(NewItem, Instances)

            for Property, Value in NewItem.Properties do
                NewItem.Instance[Property] = Value
            end

            return NewItem
        end

        Instances.AddToTheme = function(self, Properties)
            if not self.Instance then return end
            Library:AddToTheme(self, Properties)
        end

        Instances.Connect = function(self, Event, Callback, Name)
            if not self.Instance or not self.Instance[Event] then return end

            if IsMobile then
                if Event == "MouseButton1Down" or Event == "MouseButton1Click" then 
                    Event = "TouchTap"
                elseif Event == "MouseButton2Down" or Event == "MouseButton2Click" then 
                    Event = "TouchLongPress"
                end
            end

            return Library:Connect(self.Instance[Event], Callback, Name)
        end

        Instances.Tween = function(self, Info, Goal)
            if not self.Instance then return end
            return Tween:Create(self, Info, Goal)
        end

        Instances.Clean = function(self)
            if not self.Instance then return end
            self.Instance:Destroy()
            self = nil
        end

        Instances.MakeDraggable = function(self)
            if not self.Instance then return end
        
            local Gui = self.Instance
            local Dragging = false 
            local DragStart, StartPosition 
        
            local Set = function(Input)
                local DragDelta = Input.Position - DragStart
                local NewX = StartPosition.X.Offset + DragDelta.X
                local NewY = StartPosition.Y.Offset + DragDelta.Y
                self:Tween(TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2New(StartPosition.X.Scale, NewX, StartPosition.Y.Scale, NewY)
                })
            end
        
            local InputChanged
        
            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position
        
                    if InputChanged then return end
        
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            if InputChanged then
                                InputChanged:Disconnect()
                                InputChanged = nil
                            end
                        end
                    end)
                end
            end)
        
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dragging then
                        Set(Input)
                    end
                end
            end)
        end

        Instances.OnHover = function(self, Function)
            if not self.Instance then return end
            return Library:Connect(self.Instance.MouseEnter, Function)
        end

        Instances.OnHoverLeave = function(self, Function)
            if not self.Instance then return end
            return Library:Connect(self.Instance.MouseLeave, Function)
        end
    end

    -- Font Setup
    Library.Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "LyaposLibraryHolder",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 2,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "LyaposUnusedHolder",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        ResetOnSpawn = false
    })

    Library.NotifHolder = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Name = "NotifHolder",
        BackgroundTransparency = 1,
        Size = UDim2New(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = FromRGB(255, 255, 255)
    })
    
    Instances:Create("UIListLayout", {
        Parent = Library.NotifHolder.Instance,
        Padding = UDimNew(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Instances:Create("UIPadding", {
        Parent = Library.NotifHolder.Instance,
        PaddingTop = UDimNew(0, 12),
        PaddingBottom = UDimNew(0, 12),
        PaddingRight = UDimNew(0, 12),
        PaddingLeft = UDimNew(0, 12)
    })

    Library.Unload = function(self)
        for _, Value in pairs(self.Connections) do 
            if Value.Connection then Value.Connection:Disconnect() end
        end

        for _, Value in pairs(self.Threads) do 
            coroutine.close(Value)
        end

        if self.Holder then self.Holder:Clean() end
        if self.UnusedHolder then self.UnusedHolder:Clean() end

        for _, Object in pairs(self.ToClean) do
            if Object and Object.Parent then Object:Destroy() end
        end

        Library = nil 
    end

    Library.Round = function(self, Number, Float)
        local Multiplier = 1 / (Float or 1)
        return MathFloor(Number * Multiplier) / Multiplier
    end

    Library.Thread = function(self, Function)
        local NewThread = coroutine.create(Function)
        coroutine.wrap(function() coroutine.resume(NewThread) end)()
        TableInsert(self.Threads, NewThread)
        return NewThread
    end
    
    Library.SafeCall = function(self, Function, ...)
        local Arguments = { ... }
        local Success, Result = pcall(Function, TableUnpack(Arguments))
        if not Success then warn(Result) end
        return Success
    end

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("conn_%s", HttpService:GenerateGUID(false))
        local NewConnection = {
            Event = Event,
            Callback = Callback,
            Name = Name,
            Connection = nil
        }
        Library:Thread(function()
            NewConnection.Connection = Event:Connect(Callback)
        end)
        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.NextFlag = function(self)
        self.UnnamedFlags = self.UnnamedFlags + 1
        return StringFormat("flag_%s", self.UnnamedFlags)
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item 
        local ThemeData = { Item = Item, Properties = Properties }

        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then
                Item[Property] = self.Theme[Value]
            elseif type(Value) == "function" then
                Item[Property] = Value()
            end
        end

        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    Library.ChangeTheme = function(self, Theme, Color)
        self.Theme[Theme] = Color
        for _, Item in pairs(self.ThemeItems) do
            for Property, Value in pairs(Item.Properties) do
                if type(Value) == "string" and Value == Theme then
                    Item.Item[Property] = Color
                elseif type(Value) == "function" then
                    Item.Item[Property] = Value()
                end
            end
        end
    end

    Library.IsMouseOverFrame = function(self, Frame)
        Frame = Frame.Instance
        local MousePos = Vector2New(Mouse.X, Mouse.Y)
        return MousePos.X >= Frame.AbsolutePosition.X and MousePos.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X 
        and MousePos.Y >= Frame.AbsolutePosition.Y and MousePos.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end

    Library.MakeBlurred = function(self, Item, Window)
        Item = Item.Instance
        local DepthOfField = Instances:Create("DepthOfFieldEffect", {
            Parent = Lighting,
            Enabled = true,
            FarIntensity = 0,
            FocusDistance = 0,
            InFocusRadius = 1000,
            NearIntensity = 1,
            Name = "UI_Blur"
        })
        TableInsert(self.ToClean, DepthOfField.Instance)
    end

    -- Colorpicker Method
    Library.CreateColorpicker = function(self, Data)
        local Colorpicker = {
            Flag = Data.Flag or Library:NextFlag(),
            Hue = 0, Saturation = 0, Value = 0, Alpha = 0,
            Color = FromRGB(255, 255, 255), HexValue = "#FFFFFF",
            IsOpen = false 
        }

        local Items = {}
        Items["ColorpickerButton"] = Instances:Create("TextButton", {
            Parent = Data.Parent.Instance,
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2New(1, 0, 0, 24)
        })

        Items["ColorLabel"] = Instances:Create("TextLabel", {
            Parent = Items["ColorpickerButton"].Instance,
            FontFace = Library.Font,
            Text = Data.Name or "Color Picker",
            TextColor3 = Library.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2New(1, -30, 1, 0)
        }) Items["ColorLabel"]:AddToTheme({TextColor3 = "Text"})

        Items["Color"] = Instances:Create("Frame", {
            Parent = Items["ColorpickerButton"].Instance,
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(1, 0, 0.5, 0),
            Size = UDim2New(0, 20, 0, 14),
            BackgroundColor3 = Data.Default or FromRGB(255, 255, 255),
            BorderSizePixel = 0
        })

        Instances:Create("UICorner", {
            Parent = Items["Color"].Instance,
            CornerRadius = UDimNew(0, 4)
        })

        function Colorpicker:Set(Color)
            Colorpicker.Color = Color
            Items["Color"].Instance.BackgroundColor3 = Color
            Library.Flags[Colorpicker.Flag] = Color
            if Data.Callback then Library:SafeCall(Data.Callback, Color) end
        end

        Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
            -- Простая ротация пресетов при клике для удобства
            local Presets = { FromRGB(0, 116, 224), FromRGB(255, 85, 85), FromRGB(85, 255, 127), FromRGB(255, 170, 0) }
            local NextColor = Presets[math.random(1, #Presets)]
            Colorpicker:Set(NextColor)
        end)

        if Data.Default then Colorpicker:Set(Data.Default) end
        return Colorpicker
    end

    -- Notifications
    Library.Notification = function(self, Data)
        local Items = {}
        Items["Notification"] = Instances:Create("Frame", {
            Parent = Library.NotifHolder.Instance,
            BackgroundTransparency = 0.2,
            Size = UDim2New(0, 220, 0, 50),
            BackgroundColor3 = Library.Theme["Section Background"]
        }) Items["Notification"]:AddToTheme({BackgroundColor3 = "Section Background"})

        Instances:Create("UICorner", { Parent = Items["Notification"].Instance, CornerRadius = UDimNew(0, 6) })

        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["Notification"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = Data.Title or "Notification",
            TextSize = 14,
            Position = UDim2New(0, 10, 0, 6),
            Size = UDim2New(1, -20, 0, 16),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        }) Items["Title"]:AddToTheme({TextColor3 = "Text"})

        Items["Description"] = Instances:Create("TextLabel", {
            Parent = Items["Notification"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            TextTransparency = 0.4,
            Text = Data.Description or "",
            TextSize = 12,
            Position = UDim2New(0, 10, 0, 24),
            Size = UDim2New(1, -20, 0, 18),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        }) Items["Description"]:AddToTheme({TextColor3 = "Text"})

        task.delay(Data.Duration or 3, function()
            if Items["Notification"] then Items["Notification"]:Clean() end
        end)
    end

    -- Window Constructor
    Library.Window = function(self, Data)
        Data = Data or {}

        local Window = {
            Name = Data.Name or "Window",
            SubName = Data.SubName or "Fine-tuning UI",
            Logo = Data.Logo or "10734950309",
            Pages = {},
            IsOpen = true
        }

        local Items = {}
        Items["MainFrame"] = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            AnchorPoint = Vector2New(0.5, 0.5),
            BackgroundTransparency = 0.12,
            Position = UDim2New(0.5, 0, 0.5, 0),
            Size = UDim2New(0, 620, 0, 420),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Background
        }) Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})

        if IsMobile then 
            Instances:Create("UIScale", {
                Parent = Items["MainFrame"].Instance,
                Scale = 0.75
            })                    
        end

        Items["MainFrame"]:MakeDraggable()

        Items["LeftTabs"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            BackgroundTransparency = 0.15,
            Size = UDim2New(0, 170, 1, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme["Background 2"]
        }) Items["LeftTabs"]:AddToTheme({BackgroundColor3 = "Background 2"})

        Instances:Create("UICorner", { Parent = Items["MainFrame"].Instance, CornerRadius = UDimNew(0, 6) })
        Instances:Create("UICorner", { Parent = Items["LeftTabs"].Instance, CornerRadius = UDimNew(0, 6) })

        Instances:Create("UIListLayout", {
            Parent = Items["LeftTabs"].Instance,
            Padding = UDimNew(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        Instances:Create("UIPadding", {
            Parent = Items["LeftTabs"].Instance,
            PaddingTop = UDimNew(0, 50),
            PaddingLeft = UDimNew(0, 8),
            PaddingRight = UDimNew(0, 8)
        })

        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["MainFrame"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = Window.Name,
            TextSize = 16,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 180, 0, 12),
            Size = UDim2New(0, 200, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left
        }) Items["Title"]:AddToTheme({TextColor3 = "Text"})

        Items["Content"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 180, 0, 40),
            Size = UDim2New(1, -190, 1, -50),
            ZIndex = 2
        })

        -- Floating Button for Mobile Devices
        if IsMobile then
            Items["FloatingButton"] = Instances:Create("TextButton", {
                Parent = Library.Holder.Instance,
                Text = "",
                AutoButtonColor = false,
                Position = UDim2New(0.5, -25, 0, 15),
                Size = UDim2New(0, 50, 0, 50),
                BorderSizePixel = 0,
                BackgroundTransparency = 0.2,
                ZIndex = 100,
                BackgroundColor3 = Library.Theme.Background
            }) Items["FloatingButton"]:AddToTheme({BackgroundColor3 = "Background"})

            Items["FloatingButton"]:MakeDraggable()
            Instances:Create("UICorner", { Parent = Items["FloatingButton"].Instance, CornerRadius = UDimNew(1, 0) })

            Items["FloatingIcon"] = Instances:Create("ImageLabel", {
                Parent = Items["FloatingButton"].Instance,
                Image = "rbxassetid://" .. Window.Logo,
                BackgroundTransparency = 1,
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 28, 0, 28)
            })

            Items["FloatingButton"]:Connect("MouseButton1Down", function()
                Window:SetOpen(not Window.IsOpen)
            end)
        end

        function Window:SetOpen(Value)
            Window.IsOpen = Value
            Items["MainFrame"].Instance.Visible = Value
        end

        Library:Connect(UserInputService.InputBegan, function(Input, Processed)
            if not Processed and Input.KeyCode == Enum.KeyCode[Library.MenuKeybind] then
                Window:SetOpen(not Window.IsOpen)
            end
        end)

        function Window:CreatePage(PageData)
            PageData = PageData or {}
            local Page = setmetatable({
                Name = PageData.Name or "Page",
                Icon = PageData.Icon or "10734950309",
                Window = Window,
                Sections = {}
            }, Library.Pages)

            local TabButton = Instances:Create("TextButton", {
                Parent = Items["LeftTabs"].Instance,
                FontFace = Library.Font,
                Text = "",
                AutoButtonColor = false,
                Size = UDim2New(1, 0, 0, 32),
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })

            Instances:Create("UICorner", { Parent = TabButton.Instance, CornerRadius = UDimNew(0, 4) })

            local IconId = Page.Icon:find("rbxassetid://") and Page.Icon or ("rbxassetid://" .. Page.Icon)
            local TabIcon = Instances:Create("ImageLabel", {
                Parent = TabButton.Instance,
                Image = IconId,
                ImageColor3 = FromRGB(140, 140, 150),
                BackgroundTransparency = 1,
                Size = UDim2New(0, 18, 0, 18),
                Position = UDim2New(0, 8, 0.5, -9)
            })

            local TabTitle = Instances:Create("TextLabel", {
                Parent = TabButton.Instance,
                FontFace = Library.Font,
                Text = Page.Name,
                TextColor3 = FromRGB(180, 180, 190),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Position = UDim2New(0, 32, 0, 0),
                Size = UDim2New(1, -36, 1, 0)
            })

            local PageFrame = Instances:Create("ScrollingFrame", {
                Parent = Items["Content"].Instance,
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Library.Theme.Accent,
                Visible = false,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2New(0, 0, 0, 0)
            })

            Instances:Create("UIListLayout", {
                Parent = PageFrame.Instance,
                Padding = UDimNew(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Page.Frame = PageFrame
            Page.TabButton = TabButton

            function Page:Select()
                for _, p in pairs(Window.Pages) do
                    p.Frame.Instance.Visible = false
                    p.TabButton.Instance.BackgroundTransparency = 1
                    p.TabButton.Instance:FindFirstChildOfClass("TextLabel").TextColor3 = FromRGB(180, 180, 190)
                    p.TabButton.Instance:FindFirstChildOfClass("ImageLabel").ImageColor3 = FromRGB(140, 140, 150)
                end
                PageFrame.Instance.Visible = true
                TabButton.Instance.BackgroundTransparency = 0.8
                TabButton.Instance.BackgroundColor3 = Library.Theme.Accent
                TabTitle.Instance.TextColor3 = FromRGB(255, 255, 255)
                TabIcon.Instance.ImageColor3 = Library.Theme.Accent
            end

            TabButton:Connect("MouseButton1Down", function() Page:Select() end)

            table.insert(Window.Pages, Page)
            if #Window.Pages == 1 then Page:Select() end

            return Page
        end

        return Window
    end

    -- Section Constructor & Elements
    function Library.Pages:CreateSection(Data)
        Data = Data or {}
        local Section = setmetatable({
            Name = Data.Name or "Section",
            Page = self
        }, Library.Sections)

        local SectionFrame = Instances:Create("Frame", {
            Parent = self.Frame.Instance,
            Size = UDim2New(1, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Library.Theme["Section Background"],
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0
        }) SectionFrame:AddToTheme({BackgroundColor3 = "Section Background"})

        Instances:Create("UICorner", { Parent = SectionFrame.Instance, CornerRadius = UDimNew(0, 6) })

        local HeaderText = Instances:Create("TextLabel", {
            Parent = SectionFrame.Instance,
            FontFace = Library.Font,
            Text = Section.Name,
            TextColor3 = Library.Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2New(0, 10, 0, 6),
            Size = UDim2New(1, -20, 0, 18)
        }) HeaderText:AddToTheme({TextColor3 = "Text"})

        local Container = Instances:Create("Frame", {
            Parent = SectionFrame.Instance,
            Position = UDim2New(0, 0, 0, 26),
            Size = UDim2New(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1
        })

        Instances:Create("UIListLayout", {
            Parent = Container.Instance,
            Padding = UDimNew(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Instances:Create("UIPadding", {
            Parent = Container.Instance,
            PaddingTop = UDimNew(0, 4),
            PaddingBottom = UDimNew(0, 8),
            PaddingLeft = UDimNew(0, 10),
            PaddingRight = UDimNew(0, 10)
        })

        Section.Container = Container
        return Section
    end

    function Library.Sections:CreateToggle(Data)
        Data = Data or {}
        local Toggle = {
            Name = Data.Name or "Toggle",
            Flag = Data.Flag or Library:NextFlag(),
            Value = Data.Default or false,
            Callback = Data.Callback or function() end
        }

        local ItemFrame = Instances:Create("Frame", {
            Parent = self.Container.Instance,
            Size = UDim2New(1, 0, 0, 24),
            BackgroundTransparency = 1
        })

        local Title = Instances:Create("TextLabel", {
            Parent = ItemFrame.Instance,
            FontFace = Library.Font,
            Text = Toggle.Name,
            TextColor3 = Library.Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2New(1, -45, 1, 0)
        }) Title:AddToTheme({TextColor3 = "Text"})

        local Box = Instances:Create("TextButton", {
            Parent = ItemFrame.Instance,
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(1, 0, 0.5, 0),
            Size = UDim2New(0, 34, 0, 16),
            BackgroundColor3 = Toggle.Value and Library.Theme.Accent or FromRGB(40, 40, 45),
            BorderSizePixel = 0
        })

        Instances:Create("UICorner", { Parent = Box.Instance, CornerRadius = UDimNew(1, 0) })

        local Indicator = Instances:Create("Frame", {
            Parent = Box.Instance,
            AnchorPoint = Vector2New(0, 0.5),
            Position = Toggle.Value and UDim2New(1, -14, 0.5, 0) or UDim2New(0, 2, 0.5, 0),
            Size = UDim2New(0, 12, 0, 12),
            BackgroundColor3 = FromRGB(255, 255, 255),
            BorderSizePixel = 0
        })

        Instances:Create("UICorner", { Parent = Indicator.Instance, CornerRadius = UDimNew(1, 0) })

        function Toggle:Set(Val)
            Toggle.Value = Val
            Library.Flags[Toggle.Flag] = Val
            Box:Tween(nil, {BackgroundColor3 = Val and Library.Theme.Accent or FromRGB(40, 40, 45)})
            Indicator:Tween(nil, {Position = Val and UDim2New(1, -14, 0.5, 0) or UDim2New(0, 2, 0.5, 0)})
            Library:SafeCall(Toggle.Callback, Val)
        end

        Box:Connect("MouseButton1Down", function() Toggle:Set(not Toggle.Value) end)
        return Toggle
    end

    function Library.Sections:CreateButton(Data)
        Data = Data or {}
        local BtnFrame = Instances:Create("TextButton", {
            Parent = self.Container.Instance,
            Text = Data.Name or "Button",
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            TextSize = 13,
            AutoButtonColor = false,
            Size = UDim2New(1, 0, 0, 26),
            BackgroundColor3 = Library.Theme.Element,
            BorderSizePixel = 0
        }) BtnFrame:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text"})

        Instances:Create("UICorner", { Parent = BtnFrame.Instance, CornerRadius = UDimNew(0, 4) })

        BtnFrame:Connect("MouseButton1Down", function()
            if Data.Callback then Library:SafeCall(Data.Callback) end
        end)
    end

    function Library.Sections:CreateKeybind(Data)
        Data = Data or {}
        local Keybind = {
            Name = Data.Name or "Keybind",
            Flag = Data.Flag or Library:NextFlag(),
            Key = Data.Default or Enum.KeyCode.Insert,
            Callback = Data.Callback or function() end
        }

        local Frame = Instances:Create("Frame", {
            Parent = self.Container.Instance,
            Size = UDim2New(1, 0, 0, 24),
            BackgroundTransparency = 1
        })

        local Title = Instances:Create("TextLabel", {
            Parent = Frame.Instance,
            FontFace = Library.Font,
            Text = Keybind.Name,
            TextColor3 = Library.Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2New(1, -70, 1, 0)
        }) Title:AddToTheme({TextColor3 = "Text"})

        local Btn = Instances:Create("TextButton", {
            Parent = Frame.Instance,
            Text = typeof(Keybind.Key) == "EnumItem" and Keybind.Key.Name or tostring(Keybind.Key),
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            TextSize = 12,
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(1, 0, 0.5, 0),
            Size = UDim2New(0, 60, 0, 20),
            BackgroundColor3 = Library.Theme.Element,
            BorderSizePixel = 0
        }) Btn:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text"})

        Instances:Create("UICorner", { Parent = Btn.Instance, CornerRadius = UDimNew(0, 4) })

        local Listening = false
        Btn:Connect("MouseButton1Down", function()
            Listening = true
            Btn.Instance.Text = "..."
        end)

        Library:Connect(UserInputService.InputBegan, function(Input, Processed)
            if Listening and Input.UserInputType == Enum.UserInputType.Keyboard then
                Keybind.Key = Input.KeyCode
                Btn.Instance.Text = Input.KeyCode.Name
                Listening = false
                Library.Flags[Keybind.Flag] = Input.KeyCode
                Library:SafeCall(Keybind.Callback, Input.KeyCode)
            end
        end)

        return Keybind
    end

    function Library.Sections:CreateColorpicker(Data)
        Data = Data or {}
        Data.Parent = self.Container
        return Library:CreateColorpicker(Data)
    end
end


-- ================================================================= --
--                         GUI CREATION CODE                         --
-- ================================================================= --

-- Создаём главное окно
local Window = Library:Window({
    Name = "Universal Hub",
    SubName = "PC & Mobile Support",
    Logo = "10734950309"
})

-- 1. Основная вкладка Main
local MainPage = Window:CreatePage({
    Name = "Main",
    Icon = "rbxassetid://10723415693"
})

local MainSection = MainPage:CreateSection({
    Name = "Main Controls"
})

MainSection:CreateToggle({
    Name = "Enable Feature",
    Default = false,
    Callback = function(Value)
        print("Feature Toggled:", Value)
    end
})

MainSection:CreateButton({
    Name = "Execute Action",
    Callback = function()
        Library:Notification({
            Title = "Action Executed",
            Description = "The button was clicked successfully!",
            Duration = 2
        })
    end
})


-- 2. Вкладка SETTINGS с подходящей иконкой (шестеренки/настройки)
local SettingsPage = Window:CreatePage({
    Name = "Settings",
    Icon = "rbxassetid://10734950309" -- Иконка шестерёнки / настроек
})

local MenuSection = SettingsPage:CreateSection({
    Name = "Menu Configuration"
})

-- Бинд клавиши открытия/закрытия
MenuSection:CreateKeybind({
    Name = "Toggle Menu Key",
    Default = Enum.KeyCode.Insert,
    Callback = function(Key)
        Library.MenuKeybind = Key.Name
        Library:Notification({
            Title = "Keybind Changed",
            Description = "New menu key: " .. Key.Name,
            Duration = 3
        })
    end
})

local AppearanceSection = SettingsPage:CreateSection({
    Name = "Theme & Colors"
})

-- Выбор Accent цвета
AppearanceSection:CreateColorpicker({
    Name = "Accent Color",
    Default = Library.Theme.Accent,
    Callback = function(Color)
        Library:ChangeTheme("Accent", Color)
    end
})

-- Выбор Background цвета
AppearanceSection:CreateColorpicker({
    Name = "Background Color",
    Default = Library.Theme.Background,
    Callback = function(Color)
        Library:ChangeTheme("Background", Color)
    end
})

local SystemSection = SettingsPage:CreateSection({
    Name = "UI Management"
})

-- Кнопка полного удаления GUI
SystemSection:CreateButton({
    Name = "Unload UI",
    Callback = function()
        Library:Unload()
    end
})

-- Уведомление о загрузке скрипта
Library:Notification({
    Title = "Script Loaded",
    Description = "UI with Settings tab is ready!",
    Duration = 3
})
