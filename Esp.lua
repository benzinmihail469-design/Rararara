local CustomIconID = "76579925188009" 
local TweenService = game:GetService("TweenService") 
local UserInputService = game:GetService("UserInputService") 
local RunService = game:GetService("RunService") 
local GuiService = game:GetService("GuiService") 

local SafeParent = nil 
if gethui then 
    SafeParent = gethui() 
elseif game:GetService("CoreGui") then 
    local success, _ = pcall(function() return game:GetService("CoreGui").Name end) 
    if success then 
        SafeParent = game:GetService("CoreGui") 
    end 
end 

if not SafeParent then 
    SafeParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") 
end 

local DarkHub = Instance.new("ScreenGui") 
if SafeParent:FindFirstChild("DarkHub") then 
    SafeParent.DarkHub:Destroy() 
end 

DarkHub.Name = "DarkHub" 
DarkHub.Parent = SafeParent 
DarkHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 

local function tween(obj, props, dur) 
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props) 
    t:Play() 
    return t 
end 

-- === УЛЬТРА-ПОИСК V2 ===
local function NormalizeText(str)
    local success, res = pcall(function()
        local normalized = ""
        for _, c in utf8.codes(str) do
            if c >= 1040 and c <= 1071 then normalized = normalized .. utf8.char(c + 32)
            elseif c == 1025 then normalized = normalized .. utf8.char(1105)
            elseif c >= 65 and c <= 90 then normalized = normalized .. string.char(c + 32)
            else normalized = normalized .. utf8.char(c) end
        end
        return normalized
    end)

    local finalStr = success and res or string.lower(str)

    local synonyms = {
        ["авто"] = "auto", ["фарм"] = "farm", ["есп"] = "esp", ["монет"] = "coins", 
        ["монеты"] = "coins", ["игроков"] = "players", ["игрок"] = "player", 
        ["визуал"] = "visual", ["телепорт"] = "teleport", ["настройки"] = "settings"
    }
    for ru, en in pairs(synonyms) do finalStr = string.gsub(finalStr, ru, en) end

    local homoglyphs = {["а"] = "a", ["о"] = "o", ["с"] = "c", ["е"] = "e", ["р"] = "p", ["х"] = "x", ["у"] = "y"}
    for ru, en in pairs(homoglyphs) do finalStr = string.gsub(finalStr, ru, en) end

    return string.gsub(finalStr, "[%p%s%c]", "")
end
-- =========================

local MainFrame = Instance.new("Frame", DarkHub) 
MainFrame.Name = "MainFrame" 
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14) 
MainFrame.BackgroundTransparency = 0.15 
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175) 
MainFrame.Size = UDim2.new(0, 550, 0, 350) 

local MainCorner = Instance.new("UICorner", MainFrame) 
MainCorner.CornerRadius = UDim.new(0, 14) 

local MainStroke = Instance.new("UIStroke", MainFrame) 
MainStroke.Color = Color3.fromRGB(40, 40, 40) 
MainStroke.Thickness = 1.5 

local PagesContainer = Instance.new("Frame", MainFrame) 
PagesContainer.Name = "PagesContainer" 
PagesContainer.Size = UDim2.new(1, -185, 1, -70) 
PagesContainer.Position = UDim2.new(0, 175, 0, 60) 
PagesContainer.BackgroundTransparency = 1 
PagesContainer.ZIndex = 5 

local TabTitle = Instance.new("TextLabel", MainFrame) 
TabTitle.Text = "Main" 
TabTitle.Font = Enum.Font.GothamBold 
TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255) 
TabTitle.TextSize = 16 
TabTitle.Position = UDim2.new(0, 185, 0, 18) 
TabTitle.Size = UDim2.new(0, 100, 0, 20) 
TabTitle.TextXAlignment = Enum.TextXAlignment.Left 
TabTitle.BackgroundTransparency = 1 

local ControlsContainer = Instance.new("Frame", MainFrame) 
ControlsContainer.Name = "ControlsContainer" 
ControlsContainer.Size = UDim2.new(0, 60, 0, 30) 
ControlsContainer.Position = UDim2.new(1, -70, 0, 15) 
ControlsContainer.BackgroundTransparency = 1 
ControlsContainer.ZIndex = 10 

local MinBtn = Instance.new("TextButton", ControlsContainer) 
MinBtn.Size = UDim2.new(0, 24, 0, 24) 
MinBtn.Position = UDim2.new(0, 0, 0, 3) 
MinBtn.Text = "—" 
MinBtn.Font = Enum.Font.GothamBold 
MinBtn.TextSize = 12 
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 180) 
MinBtn.BackgroundTransparency = 1 
MinBtn.ZIndex = 11 

local CloseBtn = Instance.new("TextButton", ControlsContainer) 
CloseBtn.Size = UDim2.new(0, 24, 0, 24) 
CloseBtn.Position = UDim2.new(0, 30, 0, 0) 
CloseBtn.Text = "×" 
CloseBtn.Font = Enum.Font.Arial 
CloseBtn.TextSize = 22 
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180) 
CloseBtn.BackgroundTransparency = 1 
CloseBtn.ZIndex = 11 

-- === Интерфейс поиска === 
local SearchContainer = Instance.new("Frame", MainFrame) 
SearchContainer.Size = UDim2.new(0, 160, 0, 30) 
SearchContainer.Position = UDim2.new(1, -240, 0, 12) 
SearchContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 22) 
SearchContainer.ZIndex = 6 
Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 8) 

local SearchStroke = Instance.new("UIStroke", SearchContainer) 
SearchStroke.Color = Color3.fromRGB(45, 45, 45) 
SearchStroke.Thickness = 1.2 

local SearchIcon = Instance.new("ImageLabel", SearchContainer) 
SearchIcon.Size = UDim2.new(0, 14, 0, 14) 
SearchIcon.Position = UDim2.new(0, 10, 0.5, -7) 
SearchIcon.BackgroundTransparency = 1 
SearchIcon.Image = "rbxassetid://6031154871" 
SearchIcon.ImageColor3 = Color3.fromRGB(150, 150, 150) 
SearchIcon.ZIndex = 7 

local ClearSearchBtn = Instance.new("TextButton", SearchContainer) 
ClearSearchBtn.Size = UDim2.new(0, 16, 0, 16) 
ClearSearchBtn.Position = UDim2.new(1, -22, 0.5, -8) 
ClearSearchBtn.BackgroundTransparency = 1 
ClearSearchBtn.Text = "×" 
ClearSearchBtn.Font = Enum.Font.Gotham 
ClearSearchBtn.TextSize = 16 
ClearSearchBtn.TextColor3 = Color3.fromRGB(150, 150, 150) 
ClearSearchBtn.Visible = false 
ClearSearchBtn.ZIndex = 8 

local SearchBox = Instance.new("TextBox", SearchContainer) 
SearchBox.Size = UDim2.new(1, -55, 1, 0) 
SearchBox.Position = UDim2.new(0, 30, 0, 0) 
SearchBox.BackgroundTransparency = 1 
SearchBox.Text = "" 
SearchBox.PlaceholderText = "Search..." 
SearchBox.Font = Enum.Font.Gotham 
SearchBox.TextSize = 12 
SearchBox.TextColor3 = Color3.fromRGB(230, 230, 230) 
SearchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130) 
SearchBox.TextXAlignment = Enum.TextXAlignment.Left 
SearchBox.ZIndex = 7 
-- ======================== 

local SidebarContainer = Instance.new("Frame", MainFrame) 
SidebarContainer.Size = UDim2.new(0, 170, 1, 0) 
SidebarContainer.BackgroundTransparency = 1 
SidebarContainer.ZIndex = 3 

local HeaderBg = Instance.new("Frame", SidebarContainer) 
HeaderBg.Size = UDim2.new(0, 150, 0, 46) 
HeaderBg.Position = UDim2.new(0, 10, 0, 10) 
HeaderBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22) 
HeaderBg.ZIndex = 4 
Instance.new("UICorner", HeaderBg).CornerRadius = UDim.new(0, 10) 
Instance.new("UIStroke", HeaderBg).Color = Color3.fromRGB(45, 45, 45) 

local HubIcon = Instance.new("ImageLabel", HeaderBg) 
HubIcon.Size = UDim2.new(0, 28, 0, 28) 
HubIcon.Position = UDim2.new(0, 8, 0, 9) 
HubIcon.BackgroundTransparency = 1 
HubIcon.ScaleType = Enum.ScaleType.Fit 
HubIcon.ZIndex = 5 
Instance.new("UICorner", HubIcon).CornerRadius = UDim.new(0, 6) 
HubIcon.Image = "rbxthumb://type=Asset&id=" .. CustomIconID .. "&w=150&h=150" 

local HubTitle = Instance.new("TextLabel", HeaderBg) 
HubTitle.Text = "Dark Hub" 
HubTitle.Font = Enum.Font.GothamBold 
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255) 
HubTitle.TextSize = 13 
HubTitle.Position = UDim2.new(0, 44, 0, 7) 
HubTitle.Size = UDim2.new(0, 95, 0, 15) 
HubTitle.TextXAlignment = Enum.TextXAlignment.Left 
HubTitle.BackgroundTransparency = 1 
HubTitle.ZIndex = 5 

local SubTitle = Instance.new("TextLabel", HeaderBg) 
SubTitle.Text = "Grow A Garden 2" 
SubTitle.Font = Enum.Font.Gotham 
SubTitle.TextColor3 = Color3.fromRGB(130, 130, 130) 
SubTitle.TextSize = 9 
SubTitle.Position = UDim2.new(0, 44, 0, 23) 
SubTitle.Size = UDim2.new(0, 95, 0, 13) 
SubTitle.TextXAlignment = Enum.TextXAlignment.Left 
SubTitle.BackgroundTransparency = 1 
SubTitle.ZIndex = 5 

local EmbeddedControls = Instance.new("Frame", HeaderBg) 
EmbeddedControls.Size = UDim2.new(0, 50, 0, 30) 
EmbeddedControls.Position = UDim2.new(1, -55, 0, 8) 
EmbeddedControls.BackgroundTransparency = 1 
EmbeddedControls.ZIndex = 6 
EmbeddedControls.Visible = false 

local EmbMinBtn = Instance.new("TextButton", EmbeddedControls) 
EmbMinBtn.Size = UDim2.new(0, 20, 0, 20) 
EmbMinBtn.Position = UDim2.new(0, 0, 0, 5) 
EmbMinBtn.Text = "—" 
EmbMinBtn.Font = Enum.Font.GothamBold 
EmbMinBtn.TextSize = 11 
EmbMinBtn.TextColor3 = Color3.fromRGB(180, 180, 180) 
EmbMinBtn.BackgroundTransparency = 1 
EmbMinBtn.ZIndex = 7 

local EmbCloseBtn = Instance.new("TextButton", EmbeddedControls) 
EmbCloseBtn.Size = UDim2.new(0, 20, 0, 20) 
EmbCloseBtn.Position = UDim2.new(0, 25, 0, 2) 
EmbCloseBtn.Text = "×" 
EmbCloseBtn.Font = Enum.Font.Arial 
EmbCloseBtn.TextSize = 20 
EmbCloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180) 
EmbCloseBtn.BackgroundTransparency = 1 
EmbCloseBtn.ZIndex = 7 

local Navigation = Instance.new("ScrollingFrame", SidebarContainer) 
Navigation.Size = UDim2.new(1, -20, 1, -135) 
Navigation.Position = UDim2.new(0, 10, 0, 65) 
Navigation.BackgroundTransparency = 1 
Navigation.ScrollBarThickness = 0 
Navigation.AutomaticCanvasSize = Enum.AutomaticSize.Y 
local NavLayout = Instance.new("UIListLayout", Navigation) 
NavLayout.Padding = UDim.new(0, 5) 
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder 

local FooterBg = Instance.new("Frame", SidebarContainer) 
FooterBg.Size = UDim2.new(0, 150, 0, 46) 
FooterBg.Position = UDim2.new(0, 10, 1, -56) 
FooterBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22) 
FooterBg.ZIndex = 4 
Instance.new("UICorner", FooterBg).CornerRadius = UDim.new(0, 10) 
Instance.new("UIStroke", FooterBg).Color = Color3.fromRGB(45, 45, 45) 

local DiscordLabel = Instance.new("TextLabel", FooterBg) 
DiscordLabel.Position = UDim2.new(0, 10, 0, 7) 
DiscordLabel.Size = UDim2.new(1, -20, 0, 15) 
DiscordLabel.Font = Enum.Font.GothamMedium 
DiscordLabel.Text = "discord.gg/pulsezone" 
DiscordLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
DiscordLabel.TextSize = 10 
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Left 
DiscordLabel.BackgroundTransparency = 1 

local StatsLabel = Instance.new("TextLabel", FooterBg) 
StatsLabel.Position = UDim2.new(0, 10, 0, 23) 
StatsLabel.Size = UDim2.new(1, -20, 0, 15) 
StatsLabel.Font = Enum.Font.Gotham 
StatsLabel.Text = "FPS: ..." 
StatsLabel.TextColor3 = Color3.fromRGB(130, 130, 130) 
StatsLabel.TextSize = 10 
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left 
StatsLabel.BackgroundTransparency = 1 

local FrameUpdateTable = {} 
RunService.RenderStepped:Connect(function() 
    local CurrentTime = os.clock() 
    table.insert(FrameUpdateTable, CurrentTime) 
    while FrameUpdateTable[1] < CurrentTime - 1 do table.remove(FrameUpdateTable, 1) end 
    StatsLabel.Text = "FPS: " .. #FrameUpdateTable 
end) 

local function CreateRipple(button, clickX, clickY) 
    local Ripple = Instance.new("ImageLabel") 
    Ripple.Parent = button 
    Ripple.BackgroundTransparency = 1 
    Ripple.Image = "rbxassetid://4012975932" 
    Ripple.ImageColor3 = Color3.fromRGB(255, 255, 255) 
    Ripple.ImageTransparency = 0.5 
    Ripple.ZIndex = 25 
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5) 
    Ripple.Position = UDim2.new(0, clickX, 0, clickY) 
    Ripple.Size = UDim2.new(0, 0, 0, 0) 
    
    local maxLength = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 3 
    local t = TweenService:Create(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, maxLength, 0, maxLength), ImageTransparency = 1}) 
    t:Play() 
    t.Completed:Connect(function() Ripple:Destroy() end) 
end 

local isMinimized = false 
local function ToggleMinimize() 
    isMinimized = not isMinimized 
    if isMinimized then 
        PagesContainer.Visible, TabTitle.Visible, SearchContainer.Visible, Navigation.Visible, FooterBg.Visible, ControlsContainer.Visible = false, false, false, false, false, false 
        MainStroke.Enabled = false 
        MainFrame.BackgroundTransparency = 1 
        HeaderBg.Position = UDim2.new(0, 0, 0, 0) 
        HeaderBg.Size = UDim2.new(0, 175, 0, 46) 
        EmbeddedControls.Visible = true 
        tween(MainFrame, {Size = UDim2.new(0, 175, 0, 46)}) 
    else 
        EmbeddedControls.Visible = false 
        HeaderBg.Position = UDim2.new(0, 10, 0, 10) 
        HeaderBg.Size = UDim2.new(0, 150, 0, 46) 
        MainStroke.Enabled = true 
        MainFrame.BackgroundTransparency = 0.15 
        tween(MainFrame, {Size = UDim2.new(0, 550, 0, 350)}).Completed:Connect(function() 
            if not isMinimized then PagesContainer.Visible, TabTitle.Visible, SearchContainer.Visible, Navigation.Visible, FooterBg.Visible, ControlsContainer.Visible = true, true, true, true, true, true end 
        end) 
    end 
end 

MinBtn.MouseButton1Click:Connect(ToggleMinimize) 
EmbMinBtn.MouseButton1Click:Connect(ToggleMinimize) 

local function CloseGui() DarkHub:Destroy() end 
CloseBtn.MouseButton1Click:Connect(CloseGui) 
EmbCloseBtn.MouseButton1Click:Connect(CloseGui) 

local function applyHover(btn, normalColor, hoverColor) 
    btn.MouseEnter:Connect(function() tween(btn, {TextColor3 = hoverColor}) end) 
    btn.MouseLeave:Connect(function() tween(btn, {TextColor3 = normalColor}) end) 
end 
applyHover(MinBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,255,255)) 
applyHover(EmbMinBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,255,255)) 
applyHover(CloseBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,70,70)) 
applyHover(EmbCloseBtn, Color3.fromRGB(180,180,180), Color3.fromRGB(255,70,70)) 
applyHover(ClearSearchBtn, Color3.fromRGB(150,150,150), Color3.fromRGB(255,255,255)) 

local dragToggle, dragInput, dragStart, startPos 
MainFrame.InputBegan:Connect(function(input) 
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
        dragToggle = true; dragStart = input.Position; startPos = MainFrame.Position 
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end) 
    end 
end) 
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end) 
UserInputService.InputChanged:Connect(function(input) 
    if input == dragInput and dragToggle then 
        local delta = input.Position - dragStart 
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) 
    end 
end) 

-- === ГЛОБАЛЬНЫЙ ПОИСК ПО ВСЕМ ВКЛАДКАМ ===
local Library = {} 
local SearchableElements = {} 
local allTabs = {} 
local allTabButtons = {} 
local allTabIcons = {} 
local allPages = {} 

-- Создаем скрытую страницу для вывода результатов поиска
local SearchResultsPage = Instance.new("ScrollingFrame", PagesContainer) 
SearchResultsPage.Size = UDim2.new(1, 0, 1, 0) 
SearchResultsPage.BackgroundTransparency = 1 
SearchResultsPage.Visible = false 
SearchResultsPage.ScrollBarThickness = 2 
SearchResultsPage.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50) 
SearchResultsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y 
SearchResultsPage.ZIndex = 5 
local searchLayout = Instance.new("UIListLayout", SearchResultsPage) 
searchLayout.Padding = UDim.new(0, 8) 
searchLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center 
Instance.new("UIPadding", SearchResultsPage).PaddingTop = UDim.new(0, 2)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function() 
    local rawText = SearchBox.Text
    local query = NormalizeText(rawText) 
    ClearSearchBtn.Visible = (rawText ~= "") 

    if rawText == "" then
        -- Возвращаем всё по своим вкладкам, если поиск пуст
        SearchResultsPage.Visible = false
        for _, item in ipairs(SearchableElements) do
            item.Instance.Parent = item.OriginalParent
            item.Instance.Visible = true
        end
        -- Показываем активную вкладку
        if allPages[TabTitle.Text] then allPages[TabTitle.Text].Visible = true end
    else
        -- Скрываем обычные вкладки и показываем страницу поиска
        for _, page in pairs(allPages) do page.Visible = false end
        SearchResultsPage.Visible = true

        -- Фильтруем элементы и переносим найденные на страницу результатов
        for _, item in ipairs(SearchableElements) do 
            if string.find(item.SearchText, query, 1, true) then 
                item.Instance.Parent = SearchResultsPage
                item.Instance.Visible = true 
            else 
                item.Instance.Visible = false 
            end 
        end 
    end
end) 

ClearSearchBtn.MouseButton1Click:Connect(function() SearchBox.Text = "" end) 
-- =========================================

function Library:CreateButton(parentPage, text, callback) 
    local Btn = Instance.new("TextButton", parentPage) 
    Btn.Size = UDim2.new(1, -20, 0, 36) 
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22) 
    Btn.Text = text 
    Btn.Font = Enum.Font.GothamMedium 
    Btn.TextColor3 = Color3.fromRGB(230, 230, 230) 
    Btn.TextSize = 13 
    Btn.ClipsDescendants = true 
    Btn.ZIndex = 6 
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6) 
    Instance.new("UIStroke", Btn).Color = Color3.fromRGB(40, 40, 40) 
    
    Btn.MouseButton1Down:Connect(function() 
        local mousePos = UserInputService:GetMouseLocation() 
        local inset = GuiService:GetGuiInset() 
        CreateRipple(Btn, mousePos.X - Btn.AbsolutePosition.X, (mousePos.Y - inset.Y) - Btn.AbsolutePosition.Y) 
    end) 
    Btn.MouseButton1Click:Connect(callback) 
    
    -- Сохраняем не только элемент, но и его "родную" вкладку
    table.insert(SearchableElements, {Instance = Btn, SearchText = NormalizeText(text), OriginalParent = parentPage}) 
end 

function Library:CreateToggle(parentPage, text, default, callback) 
    local TglFrame = Instance.new("Frame", parentPage) 
    TglFrame.Size = UDim2.new(1, -20, 0, 36) 
    TglFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22) 
    TglFrame.ZIndex = 6 
    Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 6) 
    Instance.new("UIStroke", TglFrame).Color = Color3.fromRGB(40, 40, 40) 
    
    local TglLabel = Instance.new("TextLabel", TglFrame) 
    TglLabel.Size = UDim2.new(1, -60, 1, 0) 
    TglLabel.Position = UDim2.new(0, 12, 0, 0) 
    TglLabel.Text = text 
    TglLabel.Font = Enum.Font.GothamMedium 
    TglLabel.TextColor3 = Color3.fromRGB(230, 230, 230) 
    TglLabel.TextSize = 13 
    TglLabel.TextXAlignment = Enum.TextXAlignment.Left 
    TglLabel.BackgroundTransparency = 1 
    TglLabel.ZIndex = 7 
    
    local Checkbox = Instance.new("TextButton", TglFrame) 
    Checkbox.Size = UDim2.new(0, 34, 0, 18) 
    Checkbox.Position = UDim2.new(1, -44, 0.5, -9) 
    Checkbox.BackgroundColor3 = default and Color3.fromRGB(240, 110, 20) or Color3.fromRGB(40, 40, 40) 
    Checkbox.Text = "" 
    Checkbox.ZIndex = 7 
    Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 9) 
    
    local Indicator = Instance.new("Frame", Checkbox) 
    Indicator.Size = UDim2.new(0, 14, 0, 14) 
    Indicator.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) 
    Indicator.BackgroundColor3 = Color3.new(1, 1, 1) 
    Indicator.ZIndex = 8 
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0) 
    
    local enabled = default 
    Checkbox.MouseButton1Click:Connect(function() 
        enabled = not enabled 
        if enabled then 
            tween(Checkbox, {BackgroundColor3 = Color3.fromRGB(240, 110, 20)}, 0.2); tween(Indicator, {Position = UDim2.new(1, -16, 0.5, -7)}, 0.2) 
        else 
            tween(Checkbox, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2); tween(Indicator, {Position = UDim2.new(0, 2, 0.5, -7)}, 0.2) 
        end 
        callback(enabled) 
    end) 
    
    -- Сохраняем не только элемент, но и его "родную" вкладку
    table.insert(SearchableElements, {Instance = TglFrame, SearchText = NormalizeText(text), OriginalParent = parentPage}) 
end 

local function CreatePage(name, iconId, layoutOrder) 
    local PageFrame = Instance.new("ScrollingFrame", PagesContainer) 
    PageFrame.Size = UDim2.new(1, 0, 1, 0) 
    PageFrame.BackgroundTransparency = 1 
    PageFrame.Visible = false 
    PageFrame.ScrollBarThickness = 2 
    PageFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50) 
    PageFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y 
    PageFrame.ZIndex = 5 
    
    local layout = Instance.new("UIListLayout", PageFrame) 
    layout.Padding = UDim.new(0, 8) 
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center 
    Instance.new("UIPadding", PageFrame).PaddingTop = UDim.new(0, 2) 
    
    local TabContainer = Instance.new("Frame", Navigation) 
    TabContainer.Size = UDim2.new(1, 0, 0, 34) 
    TabContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 28) 
    TabContainer.BackgroundTransparency = 1 
    TabContainer.ClipsDescendants = true 
    TabContainer.ZIndex = 6 
    TabContainer.LayoutOrder = layoutOrder or 0 
    Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8) 
    
    local TabBtn = Instance.new("TextButton", TabContainer) 
    TabBtn.Size = UDim2.new(1, 0, 1, 0) 
    TabBtn.Text = name 
    TabBtn.Font = Enum.Font.GothamBold 
    TabBtn.TextSize = 13 
    TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140) 
    TabBtn.BackgroundTransparency = 1 
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left 
    TabBtn.ZIndex = 7 
    
    local Padding = Instance.new("UIPadding", TabBtn) 
    Padding.PaddingLeft = UDim.new(0, iconId and 42 or 12) 
    
    if iconId then 
        local TabIcon = Instance.new("ImageLabel", TabContainer) 
        TabIcon.Size = UDim2.new(0, 24, 0, 24) 
        TabIcon.Position = UDim2.new(0, 10, 0.5, -12) 
        TabIcon.BackgroundTransparency = 1 
        TabIcon.Image = "rbxthumb://type=Asset&id=" .. iconId .. "&w=150&h=150" 
        TabIcon.ImageTransparency = 0.25 
        TabIcon.ZIndex = 7 
        allTabIcons[name] = TabIcon 
    end 
    
    allTabs[name] = TabContainer 
    allTabButtons[name] = TabBtn 
    allPages[name] = PageFrame 
    
    TabBtn.MouseButton1Down:Connect(function() 
        local mousePos = UserInputService:GetMouseLocation() 
        local inset = GuiService:GetGuiInset() 
        CreateRipple(TabContainer, mousePos.X - TabContainer.AbsolutePosition.X, (mousePos.Y - inset.Y) - TabContainer.AbsolutePosition.Y) 
    end) 
    
    TabBtn.MouseButton1Click:Connect(function() 
        -- Очищаем поиск при клике на любую вкладку, чтобы вернуть интерфейс в обычный вид
        if SearchBox.Text ~= "" then SearchBox.Text = "" end 

        for tName, tContainer in pairs(allTabs) do 
            tween(tContainer, {BackgroundTransparency = 1}, 0.2) 
            tween(allTabButtons[tName], {TextColor3 = Color3.fromRGB(140, 140, 140)}, 0.2) 
            if allTabIcons[tName] then tween(allTabIcons[tName], {ImageTransparency = 0.25}, 0.2) end 
            allPages[tName].Visible = false 
        end 
        
        TabTitle.Text = name 
        PageFrame.Visible = true 
        tween(TabContainer, {BackgroundTransparency = 0}, 0.2) 
        tween(TabBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2) 
        if allTabIcons[name] then tween(allTabIcons[name], {ImageTransparency = 0}, 0.2) end 
    end) 
    
    return PageFrame 
end 

-- Создание страниц 
local MainPage = CreatePage("Main", "103980564128710", 1) 
local TeleportPage = CreatePage("Teleport", "94373592263020", 2) 
local MurderPage = CreatePage("Murder", "85278865249050", 3) 
local SheriffPage = CreatePage("Sheriff", "77487634679354", 4) 
local PlayersPage = CreatePage("Players", "99904215381150", 5) 
local VisualPage = CreatePage("Visual", "78910169210318", 6) 
local SettingsPage = CreatePage("Settings", "117996761927034", 99) 

-- Пример наполнения: 
Library:CreateToggle(MainPage, "Авто-Фарм Монет", false, function(state) print("Статус автофарма:", state) end)
Library:CreateToggle(VisualPage, "ESP Игроков", false, function(state) print("ESP статус:", state) end)
Library:CreateButton(SettingsPage, "Сохранить конфиг", function() print("Конфиг сохранен") end)
Library:CreateButton(TeleportPage, "Телепорт на спавн", function() print("Телепорт...") end)

-- Инициализация первой вкладки (Main) 
if allTabs["Main"] and allTabButtons["Main"] then 
    allTabs["Main"].BackgroundTransparency = 0 
    allTabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255) 
    if allTabIcons["Main"] then allTabIcons["Main"].ImageTransparency = 0 end 
    allPages["Main"].Visible = true 
    TabTitle.Text = "Main" 
end
