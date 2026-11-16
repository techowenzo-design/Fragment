--[[
    FRAGMENT | New UI
    Run the original Fragment script first, then run this UI script.
    This UI connects to the existing getgenv().Toggles / getgenv().Options
    objects; it does not recreate or replace the underlying feature modules.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[Fragment UI] LocalPlayer not available.")
    return
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ENV = (getgenv and getgenv()) or _G
local Toggles = ENV.Toggles or Toggles
local Options = ENV.Options or Options

if type(Toggles) ~= "table" then
    warn("[Fragment UI] Toggles were not found. Run the main Fragment script first.")
    return
end

if ENV.__FRAGMENT_NEW_UI_CLEANUP then
    pcall(ENV.__FRAGMENT_NEW_UI_CLEANUP)
end

local old = PlayerGui:FindFirstChild("FragmentNewUI")
if old then old:Destroy() end

local Connections = {}
local Alive = true

local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(Connections, c)
    return c
end

local function cleanup()
    if not Alive then return end
    Alive = false
    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(Connections)
    local existing = PlayerGui:FindFirstChild("FragmentNewUI")
    if existing then existing:Destroy() end
    if ENV.__FRAGMENT_NEW_UI_CLEANUP == cleanup then
        ENV.__FRAGMENT_NEW_UI_CLEANUP = nil
    end
end
ENV.__FRAGMENT_NEW_UI_CLEANUP = cleanup

local Theme = {
    Background = Color3.fromRGB(9, 13, 22),
    Sidebar = Color3.fromRGB(12, 18, 30),
    Panel = Color3.fromRGB(16, 24, 39),
    Panel2 = Color3.fromRGB(20, 31, 49),
    Stroke = Color3.fromRGB(39, 57, 78),
    Text = Color3.fromRGB(236, 244, 255),
    Muted = Color3.fromRGB(133, 153, 178),
    Accent = Color3.fromRGB(77, 176, 255),
    Accent2 = Color3.fromRGB(93, 111, 255),
    Off = Color3.fromRGB(48, 61, 79),
    Good = Color3.fromRGB(103, 220, 168),
}

local function create(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end

local function outline(parent, color, transparency)
    return create("UIStroke", {
        Color = color or Theme.Stroke,
        Transparency = transparency or 0,
        Thickness = 1,
    }, parent)
end

local function label(parent, value, size, color, font)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Text = value,
        Font = font or Enum.Font.Gotham,
        TextSize = size or 12,
        TextColor3 = color or Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 0, (size or 12) + 8),
    }, parent)
end

local function tween(object, properties, duration)
    local t = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    t:Play()
    return t
end

local Screen = create("ScreenGui", {
    Name = "FragmentNewUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 950,
}, PlayerGui)

local Scale = create("UIScale", {Scale = 1}, nil)
Scale.Parent = nil

local Main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(920, 590),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, Screen)
corner(Main, 16)
outline(Main, Theme.Stroke)

local MainGradient = create("UIGradient", {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 29, 47)),
        ColorSequenceKeypoint.new(1, Theme.Background),
    }),
}, Main)

local Sidebar = create("Frame", {
    BackgroundColor3 = Theme.Sidebar,
    Size = UDim2.new(0, 190, 1, 0),
    BorderSizePixel = 0,
}, Main)
local SideLine = create("Frame", {
    BackgroundColor3 = Theme.Stroke,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -1, 0, 0),
    Size = UDim2.new(0, 1, 1, 0),
}, Sidebar)

local Logo = create("Frame", {
    Position = UDim2.fromOffset(18, 18),
    Size = UDim2.fromOffset(42, 42),
    BackgroundColor3 = Theme.Panel2,
    BorderSizePixel = 0,
}, Sidebar)
corner(Logo, 12)
outline(Logo, Theme.Accent, 0.2)
local LogoText = label(Logo, "F", 24, Theme.Accent, Enum.Font.GothamBlack)
LogoText.TextXAlignment = Enum.TextXAlignment.Center
LogoText.Size = UDim2.fromScale(1, 1)

local Brand = label(Sidebar, "FRAGMENT", 17, Theme.Text, Enum.Font.GothamBlack)
Brand.Position = UDim2.fromOffset(70, 17)
Brand.Size = UDim2.new(1, -78, 0, 24)
local BrandSub = label(Sidebar, "CONTROL CENTER  /  2.0", 8, Theme.Muted, Enum.Font.GothamMedium)
BrandSub.Position = UDim2.fromOffset(71, 40)
BrandSub.Size = UDim2.new(1, -78, 0, 15)

local ModuleTitle = label(Sidebar, "WORKSPACE", 9, Theme.Muted, Enum.Font.GothamBold)
ModuleTitle.Position = UDim2.fromOffset(20, 88)
ModuleTitle.Size = UDim2.new(1, -40, 0, 18)

local Nav = create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 116),
    Size = UDim2.new(1, -24, 1, -190),
}, Sidebar)
create("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, Nav)

local Profile = create("Frame", {
    BackgroundColor3 = Theme.Panel,
    Position = UDim2.new(0, 12, 1, -62),
    Size = UDim2.new(1, -24, 0, 48),
    BorderSizePixel = 0,
}, Sidebar)
corner(Profile, 10)
outline(Profile, Theme.Stroke, 0.25)
local ProfileName = label(Profile, LocalPlayer.DisplayName, 11, Theme.Text, Enum.Font.GothamBold)
ProfileName.Position = UDim2.fromOffset(12, 5)
ProfileName.Size = UDim2.new(1, -20, 0, 17)
local ProfileSub = label(Profile, "FRAGMENT USER", 8, Theme.Muted, Enum.Font.Gotham)
ProfileSub.Position = UDim2.fromOffset(12, 23)
ProfileSub.Size = UDim2.new(1, -20, 0, 14)

local Header = create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(190, 0),
    Size = UDim2.new(1, -190, 0, 74),
}, Main)

local PageTitle = label(Header, "Overview", 20, Theme.Text, Enum.Font.GothamBold)
PageTitle.Position = UDim2.fromOffset(26, 12)
PageTitle.Size = UDim2.new(0, 350, 0, 28)
local PageSub = label(Header, "Manage your Fragment modules from one place.", 10, Theme.Muted)
PageSub.Position = UDim2.fromOffset(27, 41)
PageSub.Size = UDim2.new(0, 430, 0, 18)

local Search = create("TextBox", {
    PlaceholderText = "Search modules...",
    Text = "",
    ClearTextOnFocus = false,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = Theme.Text,
    PlaceholderColor3 = Theme.Muted,
    BackgroundColor3 = Theme.Panel,
    Position = UDim2.new(1, -226, 0, 22),
    Size = UDim2.fromOffset(194, 32),
    BorderSizePixel = 0,
}, Header)
corner(Search, 9)
outline(Search, Theme.Stroke, 0.2)
create("UIPadding", {
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 10),
}, Search)

local Close = create("TextButton", {
    Text = "×",
    Font = Enum.Font.GothamMedium,
    TextSize = 22,
    TextColor3 = Theme.Muted,
    BackgroundColor3 = Theme.Panel,
    Position = UDim2.new(1, -36, 0, 22),
    Size = UDim2.fromOffset(26, 32),
    BorderSizePixel = 0,
    AutoButtonColor = false,
}, Header)
corner(Close, 8)
Close.Activated:Connect(cleanup)

local Content = create("ScrollingFrame", {
    Name = "Content",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(214, 82),
    Size = UDim2.new(1, -238, 1, -104),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Accent,
}, Main)
local ContentLayout = create("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, Content)
create("UIPadding", {
    PaddingBottom = UDim.new(0, 14),
    PaddingRight = UDim.new(0, 4),
}, Content)

local pages = {
    Overview = {
        description = "Your Fragment modules at a glance.",
        groups = {
            {title = "ESP", items = {"esp_box", "esp_name", "esp_distance", "esp_fill", "esp_healthbar", "esp_skeleton", "esp_weapon", "esp_show_team"}},
            {title = "Visuals", items = {"camera_fov_changer", "camera_aspect_ratio", "atmosphere_enabled", "bloom_enabled", "color_correction_enabled", "skybox_enabled", "sunrays_enabled", "weather_enabled"}},
            {title = "Effects", items = {"hit_effects_enabled", "hit_sounds_enabled", "target_hit_notify"}},
        },
    },
    Combat = {
        description = "Combat-related module switches.",
        groups = {
            {title = "Combat modules", items = {"ragebot_enabled", "ragebot_priority", "ragebot_priority_notification", "ragebot_void_spam", "indicator_ragebot", "target_hit_notify"}},
            {title = "Hit feedback", items = {"hit_effects_enabled", "hit_effects_weld", "hit_sounds_enabled"}},
        },
    },
    ESP = {
        description = "Player information and on-screen indicators.",
        groups = {
            {title = "Player ESP", items = {"esp_box", "esp_name", "esp_distance", "esp_fill", "esp_healthbar", "esp_skeleton", "esp_weapon", "esp_show_team"}},
            {title = "ESP details", items = {"esp_flag_health_text", "esp_flag_staring_text"}},
        },
    },
    Movement = {
        description = "Character movement and animation options.",
        groups = {
            {title = "Movement", items = {"movement_fly", "animation_player_enabled"}},
            {title = "Character options", items = {"anti_aim_floor_hide", "protection_fake_position"}},
        },
    },
    Visuals = {
        description = "Camera, lighting and world appearance.",
        groups = {
            {title = "Camera", items = {"camera_fov_changer", "camera_aspect_ratio"}},
            {title = "Lighting", items = {"atmosphere_enabled", "bloom_enabled", "color_correction_enabled", "sunrays_enabled"}},
            {title = "World", items = {"skybox_enabled", "weather_enabled"}},
        },
    },
    Misc = {
        description = "Extra indicators and quality-of-life switches.",
        groups = {
            {title = "Miscellaneous", items = {"status", "target_hit_notify", "hit_effects_weld"}},
        },
    },
}

local navButtons = {}
local currentPage = "Overview"
local activeCards = {}

local function prettyName(name)
    local value = name:gsub("_", " ")
    value = value:gsub("(%a)([%w']*)", function(first, rest)
        return string.upper(first) .. rest
    end)
    return value
end

local function readValue(object)
    local ok, value = pcall(function() return object.Value end)
    if ok then return value end
    return nil
end

local function writeValue(object, value)
    if not object then return false end
    local ok = pcall(function()
        if type(object.SetValue) == "function" then
            object:SetValue(value)
        else
            object.Value = value
        end
    end)
    return ok
end

local function clearContent()
    for _, child in ipairs(Content:GetChildren()) do
        if child ~= ContentLayout then
            child:Destroy()
        end
    end
    table.clear(activeCards)
end

local function makeGroup(title)
    local Group = create("Frame", {
        BackgroundColor3 = Theme.Panel,
        Size = UDim2.new(1, -4, 0, 40),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
    }, Content)
    corner(Group, 12)
    outline(Group, Theme.Stroke, 0.3)
    local Heading = label(Group, title, 12, Theme.Text, Enum.Font.GothamBold)
    Heading.Position = UDim2.fromOffset(15, 10)
    Heading.Size = UDim2.new(1, -30, 0, 22)
    local List = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 40),
        Size = UDim2.new(1, -24, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, Group)
    create("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, List)
    create("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
    }, List)
    return Group, List
end

local function makeToggle(parent, key, query)
    local object = Toggles[key]
    if not object then return end

    local Row = create("Frame", {
        BackgroundColor3 = Theme.Panel2,
        Size = UDim2.new(1, 0, 0, 48),
        BorderSizePixel = 0,
    }, parent)
    corner(Row, 9)

    local Name = label(Row, prettyName(key), 11, Theme.Text, Enum.Font.GothamMedium)
    Name.Position = UDim2.fromOffset(12, 4)
    Name.Size = UDim2.new(1, -82, 0, 18)

    local Key = label(Row, key, 8, Theme.Muted, Enum.Font.Code)
    Key.Position = UDim2.fromOffset(12, 23)
    Key.Size = UDim2.new(1, -82, 0, 14)

    local Button = create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Off,
        Position = UDim2.new(1, -58, 0.5, -11),
        Size = UDim2.fromOffset(42, 22),
        BorderSizePixel = 0,
    }, Row)
    corner(Button, 11)

    local Knob = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(235, 242, 250),
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(16, 16),
        BorderSizePixel = 0,
    }, Button)
    corner(Knob, 9)

    local state = readValue(object) == true
    local updating = false

    local function render()
        if not Button.Parent then return end
        tween(Button, {BackgroundColor3 = state and Theme.Accent or Theme.Off}, 0.14)
        tween(Knob, {Position = state and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)}, 0.14)
    end

    local function setState(value)
        if updating then return end
        updating = true
        state = value == true
        writeValue(object, state)
        render()
        updating = false
    end

    Button.Activated:Connect(function()
        setState(not state)
    end)

    if type(object.OnChanged) == "function" then
        local ok, changedConnection = pcall(function()
            return object:OnChanged(function(value)
                if updating then return end
                state = value == true
                render()
            end)
        end)
        if ok and type(changedConnection) == "table" and type(changedConnection.Disconnect) == "function" then
            table.insert(Connections, changedConnection)
        end
    end

    render()
    table.insert(activeCards, {
        frame = Row,
        search = (prettyName(key) .. " " .. key .. " " .. (query or "")):lower(),
    })
end

local function renderPage(pageName, filter)
    currentPage = pageName
    local page = pages[pageName]
    if not page then return end

    PageTitle.Text = pageName
    PageSub.Text = page.description
    clearContent()

    for _, groupData in ipairs(page.groups) do
        local Group, List = makeGroup(groupData.title)
        local shown = 0

        for _, key in ipairs(groupData.items) do
            local object = Toggles[key]
            if object then
                local match = filter == "" or prettyName(key):lower():find(filter, 1, true) or key:lower():find(filter, 1, true)
                if match then
                    makeToggle(List, key)
                    shown += 1
                end
            end
        end

        if shown == 0 then
            Group:Destroy()
        end
    end

    if #Content:GetChildren() <= 1 then
        local Empty = create("Frame", {
            BackgroundColor3 = Theme.Panel,
            Size = UDim2.new(1, -4, 0, 88),
            BorderSizePixel = 0,
        }, Content)
        corner(Empty, 12)
        local EmptyText = label(Empty, "No matching controls found.", 12, Theme.Muted)
        EmptyText.Position = UDim2.fromOffset(16, 24)
        EmptyText.Size = UDim2.new(1, -32, 0, 30)
    end
end

local function setPage(name)
    Search.Text = ""
    for pageName, button in pairs(navButtons) do
        local selected = pageName == name
        button.BackgroundColor3 = selected and Theme.Panel2 or Theme.Sidebar
        button.TextColor3 = selected and Theme.Accent or Theme.Muted
    end
    renderPage(name, "")
end

local navOrder = {"Overview", "Combat", "ESP", "Movement", "Visuals", "Misc"}
for index, name in ipairs(navOrder) do
    local Button = create("TextButton", {
        Text = "   " .. name,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextColor3 = name == "Overview" and Theme.Accent or Theme.Muted,
        BackgroundColor3 = name == "Overview" and Theme.Panel2 or Theme.Sidebar,
        Size = UDim2.new(1, 0, 0, 38),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = index,
    }, Nav)
    corner(Button, 9)
    Button.Activated:Connect(function()
        setPage(name)
    end)
    navButtons[name] = Button
end

connect(Search:GetPropertyChangedSignal("Text"), function()
    local query = Search.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
    renderPage(currentPage, query)
end)

-- Dragging
local dragging = false
local dragStart, startPosition
connect(Header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)
connect(UserInputService.InputChanged, function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)
connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Responsive scaling
local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local factor = math.min(1, (viewport.X - 24) / 920, (viewport.Y - 24) / 590)
    Scale.Scale = math.max(0.55, factor)
end
Scale.Parent = Main
connect(RunService.RenderStepped, function()
    if not Alive then return end
    updateScale()
end)
updateScale()

setPage("Overview")
print("[Fragment UI] New control center loaded.")
