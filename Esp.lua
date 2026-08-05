local Library = do 
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

    local DarkHub = {
        Theme = { },
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
            Directory = "DarkHub",
            Configs = "DarkHub/Configs",
            Assets = "DarkHub/Assets",
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

    DarkHub.__index = DarkHub
    DarkHub.Sections.__index = DarkHub.Sections
    DarkHub.Pages.__index = DarkHub.Pages

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

    DarkHub.Theme = TableClone(Themes["Preset"])

    for Index, Value in DarkHub.Folders do 
        if not isfolder(Value) then
            makefolder(Value)
        end
    end

    local Tween = { } do
        Tween.__index = Tween
        Tween.Create = function(self, Item, Info, Goal, IsRawItem)
            Item = IsRawItem and Item or Item.Instance
            Info = Info or TweenInfo.new(DarkHub.Tween.Time, DarkHub.Tween.Style, DarkHub.Tween.Direction)
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

            local NewTween = Tween:Create(Item, TweenInfo.new(Speed or DarkHub.Tween.Time, DarkHub.Tween.Style, DarkHub.Tween.Direction), {
                [Property] = Visibility and OldTransparency or 1
            }, true)

            DarkHub:Connect(NewTween.Tween.Completed, function()
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
            DarkHub:AddToTheme(self, Properties)
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
            return DarkHub:Connect(self.Instance[Event], Callback, Name)
        end

        Instances.Tween = function(self, Info, Goal)
            if not self.Instance then return end
            return Tween:Create(self, Info, Goal)
        end

        Instances.MakeDraggable = function(self)
            if not self.Instance then return end
            local Gui = self.Instance
            local Dragging = false 
            local DragStart, StartPosition 
        
            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position
                end
            end)
        
            DarkHub:Connect(UserInputService.InputChanged, function(Input)
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
            return DarkHub:Connect(self.Instance.MouseEnter, Function)
        end

        Instances.OnHoverLeave = function(self, Function)
            if not self.Instance then return end
            return DarkHub:Connect(self.Instance.MouseLeave, Function)
        end
    end

    local SemiBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    DarkHub.Font = SemiBold

    DarkHub.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "DarkHub_Main",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 999,
        ResetOnSpawn = false
    })

    DarkHub.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "DarkHub_Unused",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        ResetOnSpawn = false
    })

    DarkHub.NotifHolder = Instances:Create("Frame", {
        Parent = DarkHub.Holder.Instance,
        Name = "Notifications",
        BackgroundTransparency = 1,
        Size = UDim2New(0, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = FromRGB(255, 255, 255)
    })
    
    Instances:Create("UIListLayout", {
        Parent = DarkHub.NotifHolder.Instance,
        Padding = UDimNew(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Instances:Create("UIPadding", {
        Parent = DarkHub.NotifHolder.Instance,
        PaddingTop = UDimNew(0, 12),
        PaddingBottom = UDimNew(0, 12),
        PaddingRight = UDimNew(0, 12),
        PaddingLeft = UDimNew(0, 12)
    })

    DarkHub.Unload = function(self)
        for _, Value in self.Connections do 
            if Value.Connection then Value.Connection:Disconnect() end
        end
        for _, Value in self.Threads do 
            task.cancel(Value)
        end
        if self.Holder then self.Holder.Instance:Destroy() end
        if self.UnusedHolder then self.UnusedHolder.Instance:Destroy() end
        getgenv().DarkHubLibrary = nil
    end

    DarkHub.Thread = function(self, Function)
        local NewThread = task.spawn(Function)
        TableInsert(self.Threads, NewThread)
        return NewThread
    end

    DarkHub.SafeCall = function(self, Function, ...)
        local Success, Result = pcall(Function, ...)
        if not Success then warn(Result) return false end
        return Success, Result
    end

    DarkHub.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("conn_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))
        local NewConnection = { Event = Event, Callback = Callback, Name = Name, Connection = nil }
        DarkHub:Thread(function()
            NewConnection.Connection = Event:Connect(Callback)
        end)
        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    DarkHub.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item 
        local ThemeData = { Item = Item, Properties = Properties }
        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then
                Item[Property] = self.Theme[Value]
            else
                Item[Property] = Value()
            end
        end
        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    DarkHub.Window = function(self, Data)
        Data = Data or {}
        local Window = {
            Name = Data.Name or "Dark Hub",
            SubName = Data.SubName or "Ultimate Script Solution",
            Logo = Data.Logo or "1l20959262762131",
            Pages = {},
            IsOpen = true
        }

        local Items = {} do
            Items["MainFrame"] = Instances:Create("Frame", {
                Parent = DarkHub.Holder.Instance,
                Name = "MainFrame",
                AnchorPoint = Vector2New(0.5, 0.5),
                BackgroundTransparency = 0.12,
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 677, 0, 644),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 25, 29)
            })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})

            if IsMobile then 
                Instances:Create("UIScale", {
                    Parent = Items["MainFrame"].Instance,
                    Scale = 0.7
                })                    
            end

            Items["MainFrame"]:MakeDraggable()

            Items["LeftTabs"] = Instances:Create("Frame", {
                Parent = Items["MainFrame"].Instance,
                Name = "LeftTabs",
                BorderColor3 = FromRGB(0, 0, 0),
                BackgroundTransparency = 0.15,
                Size = UDim2New(0, 225, 1, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 25, 29)
            })  Items["LeftTabs"]:AddToTheme({BackgroundColor3 = "Background"})

            Instances:Create("UIListLayout", {
                Parent = Items["LeftTabs"].Instance,
                Padding = UDimNew(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            Instances:Create("UIPadding", {
                Parent = Items["LeftTabs"].Instance,
                PaddingTop = UDimNew(0, 15),
                PaddingBottom = UDimNew(0, 15),
                PaddingRight = UDimNew(0, 12),
                PaddingLeft = UDimNew(0, 12)
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["MainFrame"].Instance,
                FontFace = DarkHub.Font,
                TextColor3 = FromRGB(240, 240, 240),
                Text = Window.Name,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 52, 0, 13),
                BorderSizePixel = 0,
                ZIndex = 2,
                TextSize = 16
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})
            
            Items["SubTitle"] = Instances:Create("TextLabel", {
                Parent = Items["MainFrame"].Instance,
                FontFace = DarkHub.Font,
                TextColor3 = FromRGB(240, 240, 240),
                TextTransparency = 0.4,
                Text = Window.SubName,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 52, 0, 30),
                ZIndex = 2,
                TextSize = 14
            })  Items["SubTitle"]:AddToTheme({TextColor3 = "Text"})

            Items["CloseButton"] = Instances:Create("TextButton", {
                Parent = Items["MainFrame"].Instance,
                FontFace = DarkHub.Font,
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 0.2,
                Position = UDim2New(1, -14, 0, 11),
                Size = UDim2New(0, 32, 0, 32),
                ZIndex = 2,
                BackgroundColor3 = FromRGB(27, 25, 29)
            })  Items["CloseButton"]:AddToTheme({BackgroundColor3 = "Element"})
            
            Instances:Create("UICorner", {
                Parent = Items["CloseButton"].Instance,
                CornerRadius = UDimNew(0, 7)
            })

            Items["CloseButton"]:Connect("MouseButton1Down", function()
                DarkHub:Unload()
            end)
        end

        function Window:Tab(TabName)
            local Tab = {}
            -- Функционал вкладок и элементов (кнопки, слайдеры, тогглы) интегрируется здесь
            return Tab
        end

        return Window
    end

    getgenv().DarkHubLibrary = DarkHub
    return DarkHub
end

return Library
