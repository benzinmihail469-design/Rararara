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
    local TableRemove = table.remove
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
            Item = Item or self.Item 

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

    Library.MakeBlurred = function(self, Item, Window)
        Item = Item.Instance
        local DepthOfField = Instances:Create("DepthOfFieldEffect", {
            Parent = Lighting, Enabled = true, FarIntensity = 0, FocusDistance = 0, InFocusRadius = 1000, NearIntensity = 1
        })
        TableInsert(self.ToClean, DepthOfField.Instance)
    end

    -- Window Structure & Section Engine
    Library.Window = function(self, Data)
        Data = Data or { }

        local Window = {
            Name = Data.Name or "Window",
            SubName = Data.SubName or "Fine-tuning for sure wins",
            Logo = Data.Logo or "1l20959262762131",
            Pages = { },
            IsOpen = true,
            SelectedPage = nil
        }

        local Items = { }
        Items["MainFrame"] = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            Name = "\0",
            BorderColor3 = FromRGB(0, 0, 0),
            AnchorPoint = Vector2New(0.5, 0.5),
            BackgroundTransparency = 0.12,
            Position = UDim2New(0.5, 0, 0.5, 0),
            Size = UDim2New(0, 677, 0, 644),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(27, 25, 29)
        })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})

        Instances:Create("UICorner", { Parent = Items["MainFrame"].Instance, CornerRadius = UDimNew(0, 6) })

        -- Header Setup
        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["MainFrame"].Instance,
            FontFace = Library.Font,
            TextColor3 = FromRGB(240, 240, 240),
            Text = Window.Name,
            Size = UDim2New(0, 200, 0, 20),
            Position = UDim2New(0, 15, 0, 12),
            BackgroundTransparency = 1,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

        -- Navigation Container (Tabs)
        Items["TabHolder"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            Name = "TabHolder",
            Size = UDim2New(0, 180, 1, -50),
            Position = UDim2New(0, 10, 0, 40),
            BackgroundTransparency = 1
        })

        Instances:Create("UIListLayout", {
            Parent = Items["TabHolder"].Instance,
            Padding = UDimNew(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        -- Content Container (Pages & Sections)
        Items["PageContainer"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            Name = "PageContainer",
            Size = UDim2New(1, -210, 1, -50),
            Position = UDim2New(0, 200, 0, 40),
            BackgroundTransparency = 1
        })

        -- Window:Page Builder
        function Window:Page(PageData)
            PageData = PageData or {}
            local Page = {
                Name = PageData.Name or "Tab",
                Sections = {},
                Window = Window
            }

            -- Tab Button
            Page.Button = Instances:Create("TextButton", {
                Parent = Items["TabHolder"].Instance,
                Size = UDim2New(1, 0, 0, 32),
                Text = Page.Name,
                FontFace = Library.Font,
                TextSize = 14,
                TextColor3 = FromRGB(180, 180, 180),
                BackgroundColor3 = FromRGB(20, 20, 24),
                BorderSizePixel = 0,
                AutoButtonColor = false
            }) Page.Button:AddToTheme({BackgroundColor3 = "Section Background 2"})

            Instances:Create("UICorner", { Parent = Page.Button.Instance, CornerRadius = UDimNew(0, 4) })

            -- Page Main View Frame
            Page.Frame = Instances:Create("ScrollingFrame", {
                Parent = Items["PageContainer"].Instance,
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = false,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })

            -- Column Grids for Sections
            Page.LeftColumn = Instances:Create("Frame", {
                Parent = Page.Frame.Instance,
                Size = UDim2New(0.49, 0, 1, 0),
                Position = UDim2New(0, 0, 0, 0),
                BackgroundTransparency = 1
            })

            Page.RightColumn = Instances:Create("Frame", {
                Parent = Page.Frame.Instance,
                Size = UDim2New(0.49, 0, 1, 0),
                Position = UDim2New(0.51, 0, 0, 0),
                BackgroundTransparency = 1
            })

            local LeftList = Instances:Create("UIListLayout", { Parent = Page.LeftColumn.Instance, Padding = UDimNew(0, 10) })
            local RightList = Instances:Create("UIListLayout", { Parent = Page.RightColumn.Instance, Padding = UDimNew(0, 10) })

            -- Select Page Mechanics
            function Page:Select()
                for _, P in pairs(Window.Pages) do
                    P.Frame.Instance.Visible = false
                    P.Button:Tween(nil, {TextColor3 = FromRGB(180, 180, 180)})
                end
                Page.Frame.Instance.Visible = true
                Page.Button:Tween(nil, {TextColor3 = Library.Theme.Accent})
                Window.SelectedPage = Page
            end

            Page.Button:Connect("MouseButton1Down", function()
                Page:Select()
            end)

            -- Built-in Section Builder (Cекции около вкладок)
            function Page:Section(SecData)
                SecData = SecData or {}
                local Section = {
                    Name = SecData.Name or "Section",
                    Side = SecData.Side or "Left" -- "Left" or "Right"
                }

                local ParentColumn = (Section.Side == "Right" and Page.RightColumn.Instance) or Page.LeftColumn.Instance

                -- Main Section Card
                Section.Frame = Instances:Create("Frame", {
                    Parent = ParentColumn,
                    Size = UDim2New(1, 0, 0, 40),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(16, 16, 20),
                    BorderSizePixel = 0
                }) Section.Frame:AddToTheme({BackgroundColor3 = "Section Background"})

                Instances:Create("UICorner", { Parent = Section.Frame.Instance, CornerRadius = UDimNew(0, 5) })

                -- Section Title Bar
                Section.Header = Instances:Create("Frame", {
                    Parent = Section.Frame.Instance,
                    Size = UDim2New(1, 0, 0, 26),
                    BackgroundColor3 = FromRGB(24, 24, 28),
                    BorderSizePixel = 0
                }) Section.Header:AddToTheme({BackgroundColor3 = "Section Top"})

                Instances:Create("UICorner", { Parent = Section.Header.Instance, CornerRadius = UDimNew(0, 5) })

                Section.Title = Instances:Create("TextLabel", {
                    Parent = Section.Header.Instance,
                    Text = Section.Name,
                    FontFace = Library.Font,
                    TextSize = 13,
                    TextColor3 = FromRGB(220, 220, 220),
                    Size = UDim2New(1, -10, 1, 0),
                    Position = UDim2New(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                }) Section.Title:AddToTheme({TextColor3 = "Text"})

                -- Section Content Container
                Section.Container = Instances:Create("Frame", {
                    Parent = Section.Frame.Instance,
                    Size = UDim2New(1, 0, 0, 0),
                    Position = UDim2New(0, 0, 0, 30),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1
                })

                Instances:Create("UIListLayout", {
                    Parent = Section.Container.Instance,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UIPadding", {
                    Parent = Section.Container.Instance,
                    PaddingLeft = UDimNew(0, 8),
                    PaddingRight = UDimNew(0, 8),
                    PaddingBottom = UDimNew(0, 8)
                })

                TableInsert(Page.Sections, Section)
                return Section
            end

            TableInsert(Window.Pages, Page)
            if #Window.Pages == 1 then
                Page:Select()
            end

            return Page
        end

        return Window
    end
end

return Library
