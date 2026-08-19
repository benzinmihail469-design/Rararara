
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
                end
            end
            return Library:Connect(self.Instance[Event], Callback, Name)
        end

        Instances.Tween = function(self, Info, Goal)
            if not self.Instance then return end
            return Tween:Create(self, Info, Goal)
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

    Library.Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

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

    Library.Window = function(self, Data)
        Data = Data or { }

        local Window = {
            Name = Data.Name or Data.name or "Window",
            SubName = Data.SubName or Data.subname or "Fine-tuning for sure wins",
            Logo = Data.Logo or Data.logo or "1l20959262762131",
            Pages = { },
            IsOpen = true
        }

        local Items = { } do
            Items["MainFrame"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(0.5, 0.5),
                BackgroundTransparency = 0.12,
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 677, 0, 500),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 25, 29)
            }) Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})

            Items["LeftTabs"] = Instances:Create("ScrollingFrame", {
                Parent = Items["MainFrame"].Instance,
                Name = "LeftTabs",
                BorderColor3 = FromRGB(0, 0, 0),
                BackgroundTransparency = 0.15,
                Position = UDim2New(0, 0, 0, 55),
                Size = UDim2New(0, 200, 1, -55),
                ZIndex = 2,
                BorderSizePixel = 0,
                ScrollBarThickness = 0,
                BackgroundColor3 = FromRGB(27, 25, 29)
            }) Items["LeftTabs"]:AddToTheme({BackgroundColor3 = "Background"})

            Instances:Create("UIListLayout", {
                Parent = Items["LeftTabs"].Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Instances:Create("UIPadding", {
                Parent = Items["LeftTabs"].Instance,
                PaddingTop = UDimNew(0, 12),
                PaddingBottom = UDimNew(0, 12),
                PaddingRight = UDimNew(0, 10),
                PaddingLeft = UDimNew(0, 10)
            })

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["MainFrame"].Instance,
                Name = "Content",
                BorderColor3 = FromRGB(0, 0, 0),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 200, 0, 55),
                Size = UDim2New(1, -200, 1, -55),
                ZIndex = 2,
                BorderSizePixel = 0
            })

            Items["SettingsButton"] = Instances:Create("TextButton", {
                Parent = Items["MainFrame"].Instance,
                Name = "\0",
                FontFace = Library.Font,
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 0.2,
                Position = UDim2New(1, -14, 0, 11),
                Size = UDim2New(0, 32, 0, 32),
                ZIndex = 2,
                BackgroundColor3 = FromRGB(27, 25, 29)
            }) Items["SettingsButton"]:AddToTheme({BackgroundColor3 = "Element"})

            Items["SettingsIcon"] = Instances:Create("ImageLabel", {
                Parent = Items["SettingsButton"].Instance,
                Name = "\0",
                ImageColor3 = FromRGB(240, 240, 240),
                ImageTransparency = 0.3,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 16, 0, 16),
                AnchorPoint = Vector2New(0.5, 0.5),
                Image = "rbxassetid://130510492706892",
                BackgroundTransparency = 1,
                Position = UDim2New(0.5, 0, 0.5, 0),
                ZIndex = 3,
                BorderSizePixel = 0
            }) Items["SettingsIcon"]:AddToTheme({ImageColor3 = "Text"})
        end

        -- Секция/Заголовок категорий в меню вкладок (слева)
        function Window:TabSection(Name)
            local SectionHeader = Instances:Create("TextLabel", {
                Parent = Items["LeftTabs"].Instance,
                Name = "TabSectionHeader",
                FontFace = Library.Font,
                TextColor3 = FromRGB(140, 140, 145),
                Text = Name:upper(),
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2New(1, 0, 0, 22),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 2,
                TextSize = 11
            }) SectionHeader:AddToTheme({TextColor3 = "Text"})

            return SectionHeader
        end

        -- Добавление новой вкладки
        function Window:Page(Data)
            local Page = {
                Name = Data.Name or Data.name or "Page",
                Icon = Data.Icon or Data.icon or "",
                Selected = false
            }

            local TabButton = Instances:Create("TextButton", {
                Parent = Items["LeftTabs"].Instance,
                Name = "TabButton",
                FontFace = Library.Font,
                Text = "",
                AutoButtonColor = false,
                Size = UDim2New(1, 0, 0, 30),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                ZIndex = 2,
                BackgroundColor3 = FromRGB(35, 33, 38)
            }) TabButton:AddToTheme({BackgroundColor3 = "Element"})

            Instances:Create("UICorner", {
                Parent = TabButton.Instance,
                CornerRadius = UDimNew(0, 5)
            })

            local TabTitle = Instances:Create("TextLabel", {
                Parent = TabButton.Instance,
                Name = "Title",
                FontFace = Library.Font,
                TextColor3 = FromRGB(200, 200, 205),
                Text = Page.Name,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, 10, 0, 0),
                Size = UDim2New(1, -10, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 3,
                TextSize = 13
            }) TabTitle:AddToTheme({TextColor3 = "Text"})

            local PageContainer = Instances:Create("ScrollingFrame", {
                Parent = Items["Content"].Instance,
                Name = Page.Name .. "_Container",
                Size = UDim2New(1, -20, 1, -20),
                Position = UDim2New(0, 10, 0, 10),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Visible = false,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Library.Theme.Accent,
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            }) PageContainer:AddToTheme({ScrollBarImageColor3 = "Accent"})

            local LeftCol = Instances:Create("Frame", {
                Parent = PageContainer.Instance,
                Name = "LeftColumn",
                Size = UDim2New(0.49, 0, 1, 0),
                Position = UDim2New(0, 0, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })

            local RightCol = Instances:Create("Frame", {
                Parent = PageContainer.Instance,
                Name = "RightColumn",
                Size = UDim2New(0.49, 0, 1, 0),
                Position = UDim2New(0.51, 0, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })

            Instances:Create("UIListLayout", {
                Parent = LeftCol.Instance,
                Padding = UDimNew(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Instances:Create("UIListLayout", {
                Parent = RightCol.Instance,
                Padding = UDimNew(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            function Page:Select()
                for _, P in pairs(Window.Pages) do
                    P:Deselect()
                end
                Page.Selected = true
                PageContainer.Instance.Visible = true
                TabButton:Tween(nil, {BackgroundTransparency = 0.2})
            end

            function Page:Deselect()
                Page.Selected = false
                PageContainer.Instance.Visible = false
                TabButton:Tween(nil, {BackgroundTransparency = 1})
            end

            TabButton:Connect("MouseButton1Down", function()
                Page:Select()
            end)

            -- Создание карточки-секции внутри страницы
            function Page:Section(Data)
                local Section = {
                    Name = Data.Name or Data.name or "Section",
                    Side = Data.Side or Data.side or "Left"
                }

                local Target = (Section.Side == "Right" and RightCol) or LeftCol

                local SectionBox = Instances:Create("Frame", {
                    Parent = Target.Instance,
                    Name = Section.Name .. "_Section",
                    Size = UDim2New(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(12, 12, 14),
                    BackgroundTransparency = 0.2,
                    BorderSizePixel = 0
                }) SectionBox:AddToTheme({BackgroundColor3 = "Section Background"})

                Instances:Create("UICorner", {
                    Parent = SectionBox.Instance,
                    CornerRadius = UDimNew(0, 6)
                })

                local TopBar = Instances:Create("Frame", {
                    Parent = SectionBox.Instance,
                    Name = "TopBar",
                    Size = UDim2New(1, 0, 0, 26),
                    BackgroundColor3 = FromRGB(28, 27, 31),
                    BorderSizePixel = 0
                }) TopBar:AddToTheme({BackgroundColor3 = "Section Top"})

                Instances:Create("UICorner", {
                    Parent = TopBar.Instance,
                    CornerRadius = UDimNew(0, 6)
                })

                local TitleLabel = Instances:Create("TextLabel", {
                    Parent = TopBar.Instance,
                    Name = "Title",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(235, 235, 235),
                    Text = Section.Name,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Position = UDim2New(0, 10, 0, 0),
                    Size = UDim2New(1, -10, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    TextSize = 13
                }) TitleLabel:AddToTheme({TextColor3 = "Text"})

                local ElementsHolder = Instances:Create("Frame", {
                    Parent = SectionBox.Instance,
                    Name = "Elements",
                    Position = UDim2New(0, 0, 0, 26),
                    Size = UDim2New(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0
                })

                Instances:Create("UIListLayout", {
                    Parent = ElementsHolder.Instance,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UIPadding", {
                    Parent = ElementsHolder.Instance,
                    PaddingTop = UDimNew(0, 8),
                    PaddingBottom = UDimNew(0, 8),
                    PaddingLeft = UDimNew(0, 10),
                    PaddingRight = UDimNew(0, 10)
                })

                return ElementsHolder
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
