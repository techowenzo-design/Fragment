--[[
    FRAGMENT | Executor-compatible UI replacement
    UI ONLY: appearance, layout, menu visibility and keybind settings.
    This does not add or connect gameplay/cheat controls.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then
    warn("[Fragment] LocalPlayer unavailable.")
    return
end

local ENV = (getgenv and getgenv()) or _G

local function getGuiHost()
    if type(ENV.UE_GUI_HOST) == "function" then
        local ok, host = pcall(ENV.UE_GUI_HOST)
        if ok and host then return host end
    end
    if type(gethui) == "function" then
        local ok, host = pcall(gethui)
        if ok and host then return host end
    end
    return player:WaitForChild("PlayerGui")
end

local host = getGuiHost()

-- Remove previous Fragment menu hosts, including the old DisplayOrder 20 menu.
for _, child in ipairs(host:GetChildren()) do
    if child:IsA("ScreenGui") then
        local n = child.Name:lower()
        if child.Name == "FragmentNewUI"
            or child.Name == "FragmentCleanUI"
            or child.DisplayOrder == 20
            or n:find("fragment", 1, true) then
            pcall(function() child:Destroy() end)
        end
    end
end

if ENV.__FRAGMENT_UI_REPLACEMENT_CLEANUP then
    pcall(ENV.__FRAGMENT_UI_REPLACEMENT_CLEANUP)
end

local Theme = {
    Background = Color3.fromRGB(10, 14, 23),
    Sidebar = Color3.fromRGB(13, 19, 31),
    Panel = Color3.fromRGB(18, 26, 41),
    Panel2 = Color3.fromRGB(25, 36, 56),
    Stroke = Color3.fromRGB(43, 58, 82),
    Text = Color3.fromRGB(238, 244, 255),
    Muted = Color3.fromRGB(139, 155, 180),
    Accent = Color3.fromRGB(74, 145, 255),
    Accent2 = Color3.fromRGB(111, 181, 255),
}

local themes = {
    Blue = {Color3.fromRGB(74,145,255), Color3.fromRGB(111,181,255)},
    Purple = {Color3.fromRGB(153,105,255), Color3.fromRGB(194,157,255)},
    Red = {Color3.fromRGB(239,82,105), Color3.fromRGB(255,139,153)},
    Green = {Color3.fromRGB(54,190,143), Color3.fromRGB(113,229,183)},
}

local settings = {
    theme = "Blue",
    compact = false,
    reduceMotion = false,
    menuKey = Enum.KeyCode.RightShift,
    scale = 1,
}

local connections = {}
local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(connections, c)
    return c
end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, obj)
end

local function outline(obj, color, transparency)
    make("UIStroke", {
        Color = color or Theme.Stroke,
        Transparency = transparency or 0,
        Thickness = 1,
    }, obj)
end

local function tween(obj, duration, props)
    if settings.reduceMotion then
        for k, v in pairs(props) do obj[k] = v end
    else
        TweenService:Create(obj, TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end
end

local gui = make("ScreenGui", {
    Name = "FragmentReplacementUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
}, host)

local scale = make("UIScale", {Scale = 1}, gui)

local main = make("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(820, 540),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
round(main, 16)
outline(main, Theme.Stroke)

local sidebar = make("Frame", {
    Size = UDim2.new(0, 190, 1, 0),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0,
}, main)

local logo = make("Frame", {
    Position = UDim2.fromOffset(18, 18),
    Size = UDim2.fromOffset(42, 42),
    BackgroundColor3 = Theme.Panel2,
    BorderSizePixel = 0,
}, sidebar)
round(logo, 12)
outline(logo, Theme.Accent, 0.15)

local logoText = make("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Text = "F",
    Font = Enum.Font.GothamBlack,
    TextSize = 25,
    TextColor3 = Theme.Accent,
}, logo)

local brand = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(70, 19),
    Size = UDim2.new(1, -78, 0, 22),
    Text = "FRAGMENT",
    Font = Enum.Font.GothamBlack,
    TextSize = 16,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)

local subBrand = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(70, 41),
    Size = UDim2.new(1, -78, 0, 17),
    Text = "CONTROL CENTER",
    Font = Enum.Font.GothamMedium,
    TextSize = 9,
    TextColor3 = Theme.Muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)

local nav = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 88),
    Size = UDim2.new(1, -24, 0, 180),
}, sidebar)
make("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, nav)

local sideFooter = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 1, -48),
    Size = UDim2.new(1, -36, 0, 28),
    Text = "FRAGMENT  •  UI",
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextColor3 = Theme.Muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)

local contentArea = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(190, 0),
    Size = UDim2.new(1, -190, 1, 0),
}, main)

local header = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(26, 18),
    Size = UDim2.new(1, -52, 0, 58),
}, contentArea)

local pageTitle = make("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -100, 0, 30),
    Text = "Overview",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local pageSubtitle = make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 31),
    Size = UDim2.new(1, -100, 0, 20),
    Text = "Your interface, your style.",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = Theme.Muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local close = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 4),
    Size = UDim2.fromOffset(34, 30),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 19,
    TextColor3 = Theme.Muted,
    AutoButtonColor = false,
}, header)
round(close, 8)

local pageHolder = make("ScrollingFrame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(26, 88),
    Size = UDim2.new(1, -52, 1, -112),
    CanvasSize = UDim2.new(),
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Accent,
}, contentArea)
local pageLayout = make("UIListLayout", {
    Padding = UDim.new(0, 12),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, pageHolder)
connect(pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
    pageHolder.CanvasSize = UDim2.fromOffset(0, pageLayout.AbsoluteContentSize.Y + 10)
end)

local function clearPage()
    for _, child in ipairs(pageHolder:GetChildren()) do
        if child ~= pageLayout then child:Destroy() end
    end
end

local function section(title, description)
    local card = make("Frame", {
        BackgroundColor3 = Theme.Panel,
        Size = UDim2.new(1, -4, 0, 78),
        BorderSizePixel = 0,
    }, pageHolder)
    round(card, 11)
    outline(card, Theme.Stroke, 0.35)
    local t = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 12),
        Size = UDim2.new(1, -30, 0, 21),
        Text = title,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    local d = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 36),
        Size = UDim2.new(1, -30, 0, 28),
        Text = description or "",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.Muted,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, card)
    return card
end

local function settingRow(title, description, buttonText, callback)
    local card = make("Frame", {
        BackgroundColor3 = Theme.Panel,
        Size = UDim2.new(1, -4, 0, 68),
        BorderSizePixel = 0,
    }, pageHolder)
    round(card, 10)
    outline(card, Theme.Stroke, 0.4)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 10),
        Size = UDim2.new(1, -150, 0, 20),
        Text = title,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 32),
        Size = UDim2.new(1, -150, 0, 22),
        Text = description,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    local button = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -13, 0.5, 0),
        Size = UDim2.fromOffset(112, 34),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        Text = buttonText,
        Font = Enum.Font.GothamSemibold,
        TextSize = 10,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
    }, card)
    round(button, 8)
    button.Activated:Connect(function() callback(button) end)
    return button
end

local currentPage = "Overview"
local navButtons = {}

local function applyTheme(name)
    local chosen = themes[name]
    if not chosen then return end
    settings.theme = name
    Theme.Accent, Theme.Accent2 = chosen[1], chosen[2]
    logoText.TextColor3 = Theme.Accent
    outline(logo, Theme.Accent, 0.15)
    pageHolder.ScrollBarImageColor3 = Theme.Accent
    for pageName, button in pairs(navButtons) do
        button.BackgroundColor3 = pageName == currentPage and Theme.Panel2 or Theme.Sidebar
        button.TextColor3 = pageName == currentPage and Theme.Accent or Theme.Muted
    end
end

local function render(name)
    currentPage = name
    clearPage()
    pageTitle.Text = name
    pageSubtitle.Text = ({
        Overview = "A clean home for your Fragment interface.",
        Appearance = "Choose the look and feel of your menu.",
        Settings = "Adjust how the interface behaves.",
        About = "Information about this UI replacement.",
    })[name] or ""

    for pageName, button in pairs(navButtons) do
        local active = pageName == name
        button.BackgroundColor3 = active and Theme.Panel2 or Theme.Sidebar
        button.TextColor3 = active and Theme.Accent or Theme.Muted
    end

    if name == "Overview" then
        section("WELCOME TO FRAGMENT", "A refreshed, lightweight interface with a cleaner layout and simple navigation.")
        section("INTERFACE STATUS", "The replacement menu is active. Press RightShift to show or hide it.")
        section("WHAT'S INCLUDED", "Appearance themes, compact layout, motion preference, menu scale and keybind options.")
    elseif name == "Appearance" then
        section("COLOR THEMES", "Choose an accent color for the interface.")
        for themeName in pairs(themes) do
            settingRow(themeName .. " theme", "Apply the " .. themeName:lower() .. " accent palette.", settings.theme == themeName and "Selected" or "Apply", function(btn)
                applyTheme(themeName)
                render("Appearance")
            end)
        end
        settingRow("Compact layout", "Use a tighter window layout.", settings.compact and "ON" or "OFF", function(btn)
            settings.compact = not settings.compact
            main.Size = settings.compact and UDim2.fromOffset(760, 500) or UDim2.fromOffset(820, 540)
            btn.Text = settings.compact and "ON" or "OFF"
        end)
    elseif name == "Settings" then
        section("MENU CONTROLS", "These options change the interface only.")
        settingRow("Reduce motion", "Disable menu tween animations.", settings.reduceMotion and "ON" or "OFF", function(btn)
            settings.reduceMotion = not settings.reduceMotion
            btn.Text = settings.reduceMotion and "ON" or "OFF"
        end)
        settingRow("Menu scale", "Cycle through 80%, 90%, 100% and 110%.", tostring(math.floor(settings.scale * 100)) .. "%", function(btn)
            settings.scale = settings.scale + 0.1
            if settings.scale > 1.1 then settings.scale = 0.8 end
            scale.Scale = settings.scale
            btn.Text = tostring(math.floor(settings.scale * 100)) .. "%"
        end)
        settingRow("Toggle key", "Click, then press a key to change the menu keybind.", settings.menuKey.Name, function(btn)
            btn.Text = "Press key..."
            local c
            c = UserInputService.InputBegan:Connect(function(input, processed)
                if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                settings.menuKey = input.KeyCode
                btn.Text = input.KeyCode.Name
                c:Disconnect()
            end)
        end)
    elseif name == "About" then
        section("FRAGMENT UI", "A standalone visual interface replacement.")
        section("SCOPE", "This menu contains interface and appearance settings only. It does not add or connect gameplay controls.")
        section("CONTROLS", "Drag the top area to move the window. Press your selected toggle key to hide or show it.")
    end
end

for i, name in ipairs({"Overview", "Appearance", "Settings", "About"}) do
    local button = make("TextButton", {
        BackgroundColor3 = name == "Overview" and Theme.Panel2 or Theme.Sidebar,
        Size = UDim2.new(1, 0, 0, 38),
        BorderSizePixel = 0,
        Text = "   " .. name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextColor3 = name == "Overview" and Theme.Accent or Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        LayoutOrder = i,
    }, nav)
    round(button, 8)
    navButtons[name] = button
    button.Activated:Connect(function() render(name) end)
end

-- Drag window
local dragging, dragStart, startPosition = false, nil, nil
connect(header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)
connect(UserInputService.InputChanged, function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)
connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local visible = true
local function setVisible(value)
    visible = value
    tween(main, 0.16, {Position = value and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0.5, 0.56)})
    main.Visible = value
end

connect(close.Activated, function() setVisible(false) end)
connect(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == settings.menuKey then
        setVisible(not visible)
    end
end)

local function cleanup()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    pcall(function() gui:Destroy() end)
end
ENV.__FRAGMENT_UI_REPLACEMENT_CLEANUP = cleanup

render("Overview")
print("[Fragment] Replacement UI loaded. Toggle: " .. settings.menuKey.Name)
