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
        MenuKeybind = tostring(Enum.KeyCode.Insert), 
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

    for Index, Value in Library.Folders do 
        if not isfolder(Value) then
            makefolder(Value)
        end
    end

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
            local Dragging, DragStart, StartPosition = false, nil, nil
            
            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position
                    local InputChanged
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            if InputChanged then InputChanged:Disconnect() end
                        end
                    end)
                end
            end)
        
            Library:Connect(UserInputService.InputChanged, function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Dragging then
                    local DragDelta = Input.Position - DragStart
                    self:Tween(TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)
                    })
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

    local SemiBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    local Regular = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    local Light = Font.new("rbxassetid://12187365364", Enum.FontWeight.Light, Enum.FontStyle.Normal)

    Library.Fonts = { ["SemiBold"] = SemiBold, ["Regular"] = Regular, ["Light"] = Light }
    Library.Font = SemiBold

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 2,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        ResetOnSpawn = false
    })

    Library.NotifHolder = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Name = "\0",
        BackgroundTransparency = 1,
        Size = UDim2New(0, 0, 1, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = FromRGB(255, 255, 255)
    })
    
    Instances:Create("UIListLayout", { Parent = Library.NotifHolder.Instance, Padding = UDimNew(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })
    Instances:Create("UIPadding", { Parent = Library.NotifHolder.Instance, PaddingTop = UDimNew(0, 12), PaddingBottom = UDimNew(0, 12), PaddingRight = UDimNew(0, 12), PaddingLeft = UDimNew(0, 12) })    

    Library.Unload = function(self)
        for _, Value in self.Connections do Value.Connection:Disconnect() end
        for _, Value in self.Threads do coroutine.close(Value) end
        if self.Holder then self.Holder:Clean() end
        if self.UnusedHolder then self.UnusedHolder:Clean() end
        for _, Object in pairs(self.ToClean) do
            if Object and Object.Parent then Object:Destroy() end
        end
        Library = nil 
        getgenv().Library = nil
    end

    Library.Thread = function(self, Function)
        local NewThread = coroutine.create(Function)
        coroutine.wrap(function() coroutine.resume(NewThread) end)()
        TableInsert(self.Threads, NewThread)
        return NewThread
    end
    
    Library.SafeCall = function(self, Function, ...)
        local Success, Result = pcall(Function, ...)
        if not Success then warn(Result) return false end
        return Success
    end

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("connection_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))
        local NewConnection = { Event = Event, Callback = Callback, Name = Name, Connection = nil }
        Library:Thread(function() NewConnection.Connection = Event:Connect(Callback) end)
        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item 
        local ThemeData = { Item = Item, Properties = Properties }
        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then Item[Property] = self.Theme[Value] else Item[Property] = Value() end
        end
        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    Library.IsMouseOverFrame = function(self, Frame)
        Frame = Frame.Instance or Frame
        local MousePosition = Vector2New(Mouse.X, Mouse.Y)
        return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X 
        and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end

    -- Window implementation with full GUI collection, icon support, tabs, and search
    Library.Window = function(self, Data)
        Data = Data or { }
        local Window = {
            Name = Data.Name or "Window",
            SubName = Data.SubName or "UI Library",
            Logo = Data.Logo or "1l20959262762131",
            Pages = { },
            IsOpen = true
        }

        local Items = { } do
            Items["MainFrame"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                Name = "MainFrame",
                AnchorPoint = Vector2New(0.5, 0.5),
                BackgroundTransparency = 0.12,
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 680, 0, 600),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 25, 29)
            })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})

            Items["MainFrame"]:MakeDraggable()

            if IsMobile then 
                Instances:Create("UIScale", { Parent = Items["MainFrame"].Instance, Scale = 0.75 })                    
            end

            Items["LeftTabs"] = Instances:Create("ScrollingFrame", {
                Parent = Items["MainFrame"].Instance,
                Name = "LeftTabsContainer",
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                BorderSizePixel = 0,
                BackgroundTransparency = 0.15,
                Position = UDim2New(0, 0, 0, 55),
                Size = UDim2New(0, 200, 1, -55),
                BackgroundColor3 = FromRGB(27, 25, 29)
            })  Items["LeftTabs"]:AddToTheme({BackgroundColor3 = "Background"})

            Instances:Create("UIListLayout", { Parent = Items["LeftTabs"].Instance, Padding = UDimNew(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
            Instances:Create("UIPadding", { Parent = Items["LeftTabs"].Instance, PaddingTop = UDimNew(0, 10), PaddingBottom = UDimNew(0, 10), PaddingRight = UDimNew(0, 10), PaddingLeft = UDimNew(0, 10 })

            Items["Container"] = Instances:Create("Frame", {
                Parent = Items["MainFrame"].Instance,
                Name = "ElementsContainer",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 210, 0, 55),
                Size = UDim2New(1, -210, 1, -55),
                BorderSizePixel = 0
            })

            -- Search Bar Integration
            Items["SearchBox"] = Instances:Create("TextBox", {
                Parent = Items["MainFrame"].Instance,
                Name = "SearchBox",
                FontFace = Library.Font,
                PlaceholderText = "Search features...",
                Text = "",
                TextColor3 = FromRGB(240, 240, 240),
                PlaceholderColor3 = FromRGB(150, 150, 150),
                Size = UDim2New(0, 180, 0, 32),
                Position = UDim2New(1, -210, 0, 11),
                AnchorPoint = Vector2New(0, 0),
                BackgroundTransparency = 0.2,
                BackgroundColor3 = FromRGB(16, 16, 18),
                BorderSizePixel = 0,
                TextSize = 13
            })  Items["SearchBox"]:AddToTheme({BackgroundColor3 = "Element"})
            Instances:Create("UICorner", { Parent = Items["SearchBox"].Instance, CornerRadius = UDimNew(0, 6) })
            Instances:Create("UIPadding", { Parent = Items["SearchBox"].Instance, PaddingLeft = UDimNew(0, 8) })

            Items["CloseButton"] = Instances:Create("TextButton", {
                Parent = Items["MainFrame"].Instance,
                Name = "CloseButton",
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0),
                BackgroundTransparency = 0.2,
                Position = UDim2New(1, -14, 0, 11),
                Size = UDim2New(0, 32, 0, 32),
                BackgroundColor3 = FromRGB(27, 25, 29)
            })  Items["CloseButton"]:AddToTheme({BackgroundColor3 = "Element"})
            Instances:Create("UICorner", { Parent = Items["CloseButton"].Instance, CornerRadius = UDimNew(0, 7) })

            Items["CloseButton"]:Connect("MouseButton1Down", function()
                Library:Unload()
            end)

            Items["CloseIcon"] = Instances:Create("ImageLabel", {
                Parent = Items["CloseButton"].Instance,
                Image = "rbxassetid://130510492706892",
                Size = UDim2New(0, 12, 0, 12),
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2New(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
                ImageColor3 = FromRGB(240, 240, 240)
            })  Items["CloseIcon"]:AddToTheme({ImageColor3 = "Text"})

            -- Minimize / Collapse Button
            Items["MinimizeButton"] = Instances:Create("TextButton", {
                Parent = Items["MainFrame"].Instance,
                Name = "MinimizeButton",
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0),
                BackgroundTransparency = 0.2,
                Position = UDim2New(1, -52, 0, 11),
                Size = UDim2New(0, 32, 0, 32),
                BackgroundColor3 = FromRGB(27, 25, 29)
            })  Items["MinimizeButton"]:AddToTheme({BackgroundColor3 = "Element"})
            Instances:Create("UICorner", { Parent = Items["MinimizeButton"].Instance, CornerRadius = UDimNew(0, 7) })

            Items["MinimizeButton"]:Connect("MouseButton1Down", function()
                Window.IsOpen = not Window.IsOpen
                Items["Container"].Instance.Visible = Window.IsOpen
                Items["LeftTabs"].Instance.Visible = Window.IsOpen
                Items["MainFrame"]:Tween(nil, {Size = Window.IsOpen and UDim2New(0, 680, 0, 600) or UDim2New(0, 680, 0, 50)})
            end)

            -- Window Title & Logo with icon support
            Items["Logo"] = Instances:Create("ImageLabel", {
                Parent = Items["MainFrame"].Instance,
                Image = "rbxassetid://" .. Window.Logo,
                Size = UDim2New(0, 32, 0, 32),
                Position = UDim2New(0, 12, 0, 11),
                BackgroundTransparency = 1
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["MainFrame"].Instance,
                FontFace = Library.Font,
                Text = Window.Name,
                TextColor3 = FromRGB(240, 240, 240),
                Position = UDim2New(0, 52, 0, 11),
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                TextSize = 15,
                AutomaticSize = Enum.AutomaticSize.X
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Items["SubTitle"] = Instances:Create("TextLabel", {
                Parent = Items["MainFrame"].Instance,
                FontFace = Library.Font,
                Text = Window.SubName,
                TextColor3 = FromRGB(180, 180, 180),
                Position = UDim2New(0, 52, 0, 28),
                Size = UDim2New(0, 0, 0, 12),
                BackgroundTransparency = 1,
                TextSize = 12,
                AutomaticSize = Enum.AutomaticSize.X
            })  Items["SubTitle"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UICorner", { Parent = Items["MainFrame"].Instance, CornerRadius = UDimNew(0, 8) })
        end

        -- Tab creation supporting separate dropdowns/tabs and icons
        function Window:Tab(TabData)
            TabData = TabData or {}
            local TabName = TabData.Name or "Tab"
            local TabIcon = TabData.Icon or ""

            local Tab = {
                Name = TabName,
                Sections = {}
            }

            local TabButton = Instances:Create("TextButton", {
                Parent = Items["LeftTabs"].Instance,
                Text = "",
                AutoButtonColor = false,
                Size = UDim2New(1, 0, 0, 36),
                BackgroundColor3 = FromRGB(20, 20, 22),
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0
            })  TabButton:AddToTheme({BackgroundColor3 = "Element"})
            Instances:Create("UICorner", { Parent = TabButton.Instance, CornerRadius = UDimNew(0, 6) })

            if TabIcon ~= "" then
                Instances:Create("ImageLabel", {
                    Parent = TabButton.Instance,
                    Image = "rbxassetid://" .. TabIcon,
                    Size = UDim2New(0, 18, 0, 18),
                    Position = UDim2New(0, 10, 0.5, -9),
                    BackgroundTransparency = 1,
                    ImageColor3 = FromRGB(200, 200, 200)
                })
            end

            local TabLabel = Instances:Create("TextLabel", {
                Parent = TabButton.Instance,
                FontFace = Library.Font,
                Text = TabName,
                TextColor3 = FromRGB(220, 220, 220),
                Size = UDim2New(1, -40, 1, 0),
                Position = UDim2New(0, TabIcon ~= "" and 36 or 12, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 13
            })  TabLabel:AddToTheme({TextColor3 = "Text"})

            local TabContent = Instances:Create("ScrollingFrame", {
                Parent = Items["Container"].Instance,
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 3,
                Visible = false,
                BorderSizePixel = 0
            })
            Instances:Create("UIListLayout", { Parent = TabContent.Instance, Padding = UDimNew(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })
            Instances:Create("UIPadding", { Parent = TabContent.Instance, PaddingTop = UDimNew(0, 5), PaddingBottom = UDimNew(0, 5), PaddingRight = UDimNew(0, 10), PaddingLeft = UDimNew(0, 5) })

            if #Window.Pages == 0 then
                TabContent.Instance.Visible = true
                TabButton.Instance.BackgroundTransparency = 0.1
            end

            TabButton:Connect("MouseButton1Down", function()
                for _, Page in pairs(Window.Pages) do
                    Page.Content.Visible = false
                    Page.Button.Instance.BackgroundTransparency = 0.5
                end
                TabContent.Instance.Visible = true
                TabButton.Instance.BackgroundTransparency = 0.1
            end)

            Tab.Content = TabContent.Instance
            Tab.Button = TabButton
            TableInsert(Window.Pages, Tab)

            function Tab:Section(SectionData)
                SectionData = SectionData or {}
                local SectionName = SectionData.Name or "Section"

                local SectionHolder = Instances:Create("Frame", {
                    Parent = TabContent.Instance,
                    Size = UDim2New(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(15, 15, 17),
                    BorderSizePixel = 0
                })  SectionHolder:AddToTheme({BackgroundColor3 = "Section Background"})
                Instances:Create("UICorner", { Parent = SectionHolder.Instance, CornerRadius = UDimNew(0, 6) })
                Instances:Create("UIPadding", { Parent = SectionHolder.Instance, PaddingTop = UDimNew(0, 8), PaddingBottom = UDimNew(0, 8), PaddingLeft = UDimNew(0, 10), PaddingRight = UDimNew(0, 10) })
                Instances:Create("UIListLayout", { Parent = SectionHolder.Instance, Padding = UDimNew(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })

                if SectionName ~= "" then
                    Instances:Create("TextLabel", {
                        Parent = SectionHolder.Instance,
                        FontFace = Library.Font,
                        Text = SectionName,
                        TextColor3 = FromRGB(160, 160, 160),
                        Size = UDim2New(1, 0, 0, 20),
                        BackgroundTransparency = 1,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }):AddToTheme({TextColor3 = "Text"})
                end

                local Section = {}
                return Section
            end

            return Tab
        end

        return Window
    end

    Library.Notification = function(self, Data)
        Data = Data or {}
        local Title = Data.Title or "Notification"
        local Desc = Data.Description or "Action executed successfully."
        local Duration = Data.Duration or 3

        local Notif = Instances:Create("Frame", {
            Parent = Library.NotifHolder.Instance,
            Size = UDim2New(0, 250, 0, 60),
            BackgroundColor3 = FromRGB(20, 20, 22),
            BorderSizePixel = 0
        })  Notif:AddToTheme({BackgroundColor3 = "Background"})
        Instances:Create("UICorner", { Parent = Notif.Instance, CornerRadius = UDimNew(0, 6) })

        Instances:Create("TextLabel", {
            Parent = Notif.Instance,
            FontFace = Library.Font,
            Text = Title,
            TextColor3 = FromRGB(255, 255, 255),
            Position = UDim2New(0, 10, 0, 8),
            Size = UDim2New(1, -20, 0, 16),
            BackgroundTransparency = 1,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        }):AddToTheme({TextColor3 = "Text"})

        Instances:Create("TextLabel", {
            Parent = Notif.Instance,
            FontFace = Library.Font,
            Text = Desc,
            TextColor3 = FromRGB(180, 180, 180),
            Position = UDim2New(0, 10, 0, 26),
            Size = UDim2New(1, -20, 0, 24),
            BackgroundTransparency = 1,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        }):AddToTheme({TextColor3 = "Text"})

        task.delay(Duration, function()
            Notif:Clean()
        end)
    end
end

getgenv().Library = Library
return Library
