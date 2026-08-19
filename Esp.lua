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

    local TableInsert = table.insert
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringGSub = string.gsub

    local InstanceNew = Instance.new

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
    end

    -- Font Setup
    Library.Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "LibraryHolder",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 2,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "UnusedHolder",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        ResetOnSpawn = false
    })

    Library.Unload = function(self)
        for Index, Value in self.Connections do 
            Value.Connection:Disconnect()
        end

        if self.Holder then self.Holder:Clean() end
        if self.UnusedHolder then self.UnusedHolder:Clean() end

        for _, Object in pairs(self.ToClean) do
            if Object and Object.Parent then
                Object:Destroy()
            end
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

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("connection_%s", HttpService:GenerateGUID(false))
        local NewConnection = { Event = Event, Callback = Callback, Name = Name, Connection = nil }
        Library:Thread(function() NewConnection.Connection = Event:Connect(Callback) end)
        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.AddToTheme = function(self, Item, Properties)
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

    -- Window Creation
    Library.Window = function(self, Data)
        Data = Data or { }

        local Window = {
            Name = Data.Name or Data.name or "Window",
            SubName = Data.SubName or Data.subname or "Fine-tuning for sure wins",
            Logo = Data.Logo or Data.logo or "1l20959262762131",
            
            Pages = { },
            Items = { },
            IsOpen = true
        }

        local Items = { } do
            Items["MainFrame"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                Name = "MainFrame",
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(0.5, 0.5),
                BackgroundTransparency = 0.12,
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 677, 0, 500),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 25, 29)
            })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})

            Items["LeftTabs"] = Instances:Create("ScrollingFrame", {
                Parent = Items["MainFrame"].Instance,
                Name = "LeftTabs",
                Visible = true,
                BorderColor3 = FromRGB(0, 0, 0),
                BackgroundTransparency = 0.15,
                Size = UDim2New(0, 210, 1, -55),
                Position = UDim2New(0, 0, 0, 55),
                ZIndex = 2,
                BorderSizePixel = 0,
                ScrollBarThickness = 0,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(27, 25, 29)
            })  Items["LeftTabs"]:AddToTheme({BackgroundColor3 = "Background"})

            Instances:Create("UIListLayout", {
                Parent = Items["LeftTabs"].Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            Instances:Create("UIPadding", {
                Parent = Items["LeftTabs"].Instance,
                PaddingTop = UDimNew(0, 10),
                PaddingBottom = UDimNew(0, 10),
                PaddingRight = UDimNew(0, 10),
                PaddingLeft = UDimNew(0, 10)
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["MainFrame"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(240, 240, 240),
                Text = Window.Name,
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 15, 0, 13),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2,
                TextSize = 16
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["MainFrame"].Instance,
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 210, 0, 55),
                Size = UDim2New(1, -210, 1, -55),
                ZIndex = 2
            })

            Items["CloseButton"] = Instances:Create("TextButton", {
                Parent = Items["MainFrame"].Instance,
                Text = "X",
                FontFace = Library.Font,
                TextColor3 = FromRGB(240, 240, 240),
                AnchorPoint = Vector2New(1, 0),
                Position = UDim2New(1, -10, 0, 10),
                Size = UDim2New(0, 32, 0, 32),
                ZIndex = 3,
                BackgroundColor3 = FromRGB(27, 25, 29)
            })  Items["CloseButton"]:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text"})
            
            Items["CloseButton"]:Connect("MouseButton1Down", function()
                Library:Unload()
            end)

            Items["SettingsButton"] = Instances:Create("TextButton", {
                Parent = Items["MainFrame"].Instance,
                Text = "",
                AnchorPoint = Vector2New(1, 0),
                Position = UDim2New(1, -48, 0, 10),
                Size = UDim2New(0, 32, 0, 32),
                ZIndex = 2,
                BackgroundColor3 = FromRGB(27, 25, 29)
            })  Items["SettingsButton"]:AddToTheme({BackgroundColor3 = "Element"})

            Items["SettingsIcon"] = Instances:Create("ImageLabel", {
                Parent = Items["SettingsButton"].Instance,
                ImageColor3 = FromRGB(240, 240, 240),
                ImageTransparency = 0.3,
                Size = UDim2New(0, 16, 0, 16),
                AnchorPoint = Vector2New(0.5, 0.5),
                Image = "rbxassetid://130510492706892",
                BackgroundTransparency = 1,
                Position = UDim2New(0.5, 0, 0.5, 0),
                ZIndex = 3
            })  Items["SettingsIcon"]:AddToTheme({ImageColor3 = "Text"})
        end

        -- ========================================================
        -- СЕКЦИИ ДЛЯ ВКЛАДОК (Tab Section Header)
        -- ========================================================
        function Window:TabSection(Title)
            local SectionHeader = Instances:Create("Frame", {
                Parent = Items["LeftTabs"].Instance,
                Name = Title .. "_SectionHeader",
                Size = UDim2New(1, 0, 0, 22),
                BackgroundTransparency = 1,
                ZIndex = 3
            })

            local Label = Instances:Create("TextLabel", {
                Parent = SectionHeader.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(120, 120, 130),
                Text = Title:upper(),
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 3
            })  Label:AddToTheme({TextColor3 = "Accent"})

            return SectionHeader
        end

        -- Создание страницы (вкладки)
        function Window:Page(PageData)
            PageData = PageData or {}
            local PageName = PageData.Name or "Tab"

            local Page = {
                Name = PageName,
                Window = Window
            }

            local TabButton = Instances:Create("TextButton", {
                Parent = Items["LeftTabs"].Instance,
                Name = PageName .. "_Button",
                FontFace = Library.Font,
                Text = "",
                Size = UDim2New(1, 0, 0, 32),
                BackgroundColor3 = FromRGB(16, 16, 18),
                BackgroundTransparency = 0.5,
                AutoButtonColor = false,
                ZIndex = 3
            })  TabButton:AddToTheme({BackgroundColor3 = "Element"})

            Instances:Create("UICorner", {
                Parent = TabButton.Instance,
                CornerRadius = UDimNew(0, 6)
            })

            local TabTitle = Instances:Create("TextLabel", {
                Parent = TabButton.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(200, 200, 200),
                Text = PageName,
                Size = UDim2New(1, -10, 1, 0),
                Position = UDim2New(0, 10, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 13,
                ZIndex = 4
            })  TabTitle:AddToTheme({TextColor3 = "Text"})

            local PageFrame = Instances:Create("ScrollingFrame", {
                Parent = Items["Content"].Instance,
                Name = PageName .. "_Frame",
                Size = UDim2New(1, -20, 1, -20),
                Position = UDim2New(0, 10, 0, 10),
                BackgroundTransparency = 1,
                Visible = false,
                ScrollBarThickness = 2,
                BorderSizePixel = 0,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })

            Instances:Create("UIListLayout", {
                Parent = PageFrame.Instance,
                Padding = UDimNew(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            function Page:Select()
                for _, p in pairs(Window.Pages) do
                    p.Frame.Instance.Visible = false
                    p.Button:Tween(nil, {BackgroundTransparency = 0.5})
                end
                PageFrame.Instance.Visible = true
                TabButton:Tween(nil, {BackgroundTransparency = 0})
            end

            TabButton:Connect("MouseButton1Down", function()
                Page:Select()
            end)

            Page.Frame = PageFrame
            Page.Button = TabButton

            TableInsert(Window.Pages, Page)

            if #Window.Pages == 1 then
                Page:Select()
            end

            return Page
        end

        return Window
    end
end
