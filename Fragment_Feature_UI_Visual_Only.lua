--[[
    FRAGMENT | Compact Pink/Black UI
    Visual interface template inspired by the supplied reference.
    This file only controls its own appearance and harmless interface settings.
    It does not connect to aimbot, targeting, player-tracking, or combat automation.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then
    warn("[Fragment] LocalPlayer unavailable.")
    return
end

local playerGui = player:WaitForChild("PlayerGui")
local previous = playerGui:FindFirstChild("FragmentCompactUI")
if previous then previous:Destroy() end

local C = {
    bg = Color3.fromRGB(12, 12, 12),
    panel = Color3.fromRGB(17, 17, 17),
    panel2 = Color3.fromRGB(25, 25, 25),
    row = Color3.fromRGB(31, 31, 31),
    border = Color3.fromRGB(65, 65, 65),
    white = Color3.fromRGB(225, 225, 225),
    muted = Color3.fromRGB(145, 145, 145),
    pink = Color3.fromRGB(205, 40, 105),
    pink2 = Color3.fromRGB(245, 65, 135),
}

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 2)}, obj)
end

local function line(parent, color, thickness)
    return make("UIStroke", {
        Color = color or C.border,
        Thickness = thickness or 1,
        Transparency = 0.15
    }, parent)
end

local function text(parent, value, size, color, font)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Text = value,
        Font = font or Enum.Font.Code,
        TextSize = size or 11,
        TextColor3 = color or C.white,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 0, (size or 11) + 5),
    }, parent)
end

local gui = make("ScreenGui", {
    Name = "FragmentCompactUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
}, playerGui)

local main = make("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(520, 580),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
}, gui)
line(main, C.pink, 2)

local inner = make("Frame", {
    Position = UDim2.fromOffset(8, 8),
    Size = UDim2.new(1, -16, 1, -16),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
}, main)
line(inner, Color3.fromRGB(45, 45, 45), 1)

local top = make("Frame", {
    Position = UDim2.fromOffset(8, 5),
    Size = UDim2.new(1, -16, 0, 22),
    BackgroundTransparency = 1,
}, inner)
local stamp = os.date("%b. %d. %Y | %I:%M %p")
text(top, "fragment.local - " .. stamp, 10, C.pink2, Enum.Font.Code)

local tabs = make("Frame", {
    Position = UDim2.fromOffset(8, 31),
    Size = UDim2.new(1, -16, 0, 29),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, inner)
make("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 2),
}, tabs)

local content = make("Frame", {
    Position = UDim2.fromOffset(8, 66),
    Size = UDim2.new(1, -16, 1, -76),
    BackgroundTransparency = 1,
}, inner)

local left = make("ScrollingFrame", {
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = C.pink,
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(0.5, -4, 1, 0),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, content)
local right = make("ScrollingFrame", {
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = C.pink,
    Position = UDim2.new(0.5, 4, 0, 0),
    Size = UDim2.new(0.5, -4, 1, 0),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, content)

local function makeSection(parent, title, y, height)
    local box = make("Frame", {
        Position = UDim2.fromOffset(0, y),
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
    }, parent)
    local accent = make("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = C.pink,
        BorderSizePixel = 0,
    }, box)
    text(box, title, 11, C.white, Enum.Font.Code).Position = UDim2.fromOffset(8, 4)
    return box
end

local function addToggle(parent, labelText, y, default)
    local row = make("Frame", {
        Position = UDim2.fromOffset(7, y),
        Size = UDim2.new(1, -14, 0, 18),
        BackgroundTransparency = 1,
    }, parent)
    local check = make("TextButton", {
        Position = UDim2.fromOffset(0, 2),
        Size = UDim2.fromOffset(13, 13),
        Text = "",
        BackgroundColor3 = C.panel2,
        BorderSizePixel = 1,
        BorderColor3 = C.border,
        AutoButtonColor = false,
    }, row)
    local state = default == true
    local function render()
        check.BackgroundColor3 = state and C.pink or C.panel2
    end
    check.Activated:Connect(function()
        state = not state
        render()
    end)
    render()
    local label = text(row, labelText, 11, C.white, Enum.Font.Code)
    label.Position = UDim2.fromOffset(20, -1)
    return row
end

local function addSlider(parent, labelText, y, initial, minValue, maxValue)
    text(parent, labelText, 10, C.white, Enum.Font.Code).Position = UDim2.fromOffset(8, y)
    local track = make("Frame", {
        Position = UDim2.fromOffset(8, y + 18),
        Size = UDim2.new(1, -16, 0, 12),
        BackgroundColor3 = C.row,
        BorderSizePixel = 0,
    }, parent)
    local fill = make("Frame", {
        Size = UDim2.new((initial - minValue) / (maxValue - minValue), 0, 1, 0),
        BackgroundColor3 = C.pink,
        BorderSizePixel = 0,
    }, track)
    local value = text(track, tostring(initial), 9, C.white, Enum.Font.Code)
    value.TextXAlignment = Enum.TextXAlignment.Center
    value.Size = UDim2.fromScale(1, 1)
    local dragging = false
    local function update(input)
        local x = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local n = math.floor(minValue + (maxValue - minValue) * x + 0.5)
        fill.Size = UDim2.new(x, 0, 1, 0)
        value.Text = tostring(n)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function addChoice(parent, labelText, y, choice)
    text(parent, labelText, 10, C.white, Enum.Font.Code).Position = UDim2.fromOffset(8, y)
    local button = make("TextButton", {
        Position = UDim2.fromOffset(8, y + 17),
        Size = UDim2.new(1, -16, 0, 21),
        BackgroundColor3 = C.row,
        BorderSizePixel = 0,
        Text = choice .. "                         +",
        TextColor3 = C.white,
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    }, parent)
    local options = {"Default", "Compact", "Expanded"}
    local index = 1
    button.Activated:Connect(function()
        index = index % #options + 1
        button.Text = options[index] .. "                         +"
    end)
end

local pages = {}
local currentPage = "Main"

local function clearPage()
    for _, child in ipairs(left:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
    for _, child in ipairs(right:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
end

-- These are presentation-only controls. They intentionally do not call or modify
-- any gameplay, targeting, player-tracking, or combat functions from the source.
local featurePages = {
    Main = {
        left = {
            {"Silent Aim", {"Enabled", "Keybind", "Manipulation", "Closest part", "Visualize", "Show FOV", "FOV outline", "FOV fill", "FOV lerp", "Moving rotation", "Rotation", "Rotation speed", "FOV settings", "Radius", "Hit chance"}},
            {"Aimbot", {"Enabled", "Keybind", "Closest part", "Closest position", "Delay position", "X smooth", "Y smooth", "Jump smoothing", "Show FOV", "FOV outline", "FOV fill", "FOV lerp", "Moving rotation", "Rotation", "Rotation speed", "FOV settings", "Radius", "Smoothing"}},
        },
        right = {
            {"Triggerbot", {"Enabled", "Keybind", "Reaction time", "Reaction time offset", "Forget time", "Shoot delay", "Max distance", "Part blacklist", "Settings", "No delay between targets", "Anti katana", "Check scoped if"}},
            {"Targeting", {"Visible only", "Ignore protected", "Ignore conditions", "Disable on flash", "Limit distance", "Max distance", "Reaction time", "Forget time", "Target part", "Closest part blacklist"}},
        }
    },
    World = {
        left = {
            {"Color correction", {"Enabled", "Tint", "Saturation", "Contrast", "Brightness"}},
            {"Atmosphere", {"Enabled", "Tint color", "Decay color", "Glare", "Haze", "Offset", "Density"}},
            {"Skybox", {"Enabled", "Selected", "Disable", "Sun", "Stars"}},
        },
        right = {
            {"Weather", {"Enabled", "Selected", "Rate", "Lifetime", "Timescale"}},
            {"Ambience", {"Enabled", "Selected", "Volume"}},
            {"Lighting effects", {"Bloom", "Bloom intensity", "Bloom size", "Bloom threshold", "Sun rays", "Intensity", "Spread"}},
        }
    },
    ESP = {
        left = {
            {"ESP", {"Enabled", "Boxes", "Names", "Health", "Distance", "Tracers", "Skeleton", "Team check", "Visible check", "Max distance"}},
            {"ESP appearance", {"Box color", "Name color", "Health color", "Tracer color", "Text size", "Thickness", "Transparency"}},
        },
        right = {
            {"World visuals", {"Dropped items", "Weapon indicators", "Objective markers", "World labels", "Distance labels"}},
            {"Visual filters", {"Team colors", "Highlight style", "Only visible", "Fade distance"}},
        }
    },
    Visuals = {
        left = {
            {"Camera", {"Anti flashbang", "FOV changer", "FOV", "Aspect ratio", "Ratio X", "Ratio Y", "Blur"}},
            {"Screen effects", {"Color correction", "Atmosphere", "Bloom", "Sun rays", "Weather", "Ambience"}},
        },
        right = {
            {"Environment", {"Skybox", "Disable sun", "Disable stars", "Clock time", "Brightness", "Global shadows"}},
            {"Display", {"Watermark", "Show status", "Show indicators", "Visual notifications"}},
        }
    },
    Character = {
        left = {
            {"Character", {"Movement settings", "Camera settings", "Character visuals", "Animation settings"}},
        },
        right = {
            {"Appearance", {"Color", "Transparency", "Highlight", "Outline"}},
        }
    },
    Misc = {
        left = {
            {"Weapons", {"No spread", "Faster reload", "Full auto", "Always backstab", "Grenade options", "Remove fuse", "Firerate", "Melee cooldown", "Dash cooldown"}},
        },
        right = {
            {"Ragebot", {"Enabled", "Keybind", "Void spam", "Hide", "Attack", "Medkit hide", "Health", "Shoot attempts", "Attack mode", "Preferred weapon", "Settings", "Swap weapons when empty"}},
            {"Priority", {"Auto prioritize", "Send notification", "Auto priority settings", "Attackers"}},
        }
    },
    Settings = {
        left = {
            {"Interface", {"Show status text", "Reduce animations", "Remember window position", "Tooltips", "Notifications"}},
            {"Window", {"UI scale", "Panel opacity", "Accent intensity", "Window width", "Window height"}},
        },
        right = {
            {"Appearance", {"Pink accent", "Dark background", "Thin borders", "Font style", "Corner roundness"}},
            {"Configuration", {"Theme manager", "Save configuration", "Load configuration", "Reset interface"}},
        }
    }
}

local function addDisplayRow(parent, labelText, y, index)
    local row = make("Frame", {
        Position = UDim2.fromOffset(7, y),
        Size = UDim2.new(1, -14, 0, 20),
        BackgroundColor3 = index % 2 == 0 and C.panel2 or C.row,
        BorderSizePixel = 0,
    }, parent)
    text(row, labelText, 10, C.white, Enum.Font.Code).Position = UDim2.fromOffset(7, 0)
    local marker = make("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = C.border,
        BorderSizePixel = 0,
    }, row)
    round(marker, 2)
    return row
end

local function renderPage(pageName)
    currentPage = pageName
    clearPage()
    local data = featurePages[pageName] or featurePages.Settings
    local function renderColumn(parent, sections)
        local y = 0
        for _, section in ipairs(sections) do
            local rows = section[2]
            local height = 28 + (#rows * 23)
            local box = makeSection(parent, section[1], y, height)
            local rowY = 27
            for i, labelText in ipairs(rows) do
                addDisplayRow(box, labelText, rowY, i)
                rowY = rowY + 23
            end
            y = y + height + 10
        end
        parent.CanvasPosition = Vector2.new(0, 0)
    end
    renderColumn(left, data.left or {})
    renderColumn(right, data.right or {})
end

local tabNames = {"Main", "World", "ESP", "Visuals", "Character", "Misc", "Settings"}
for i, name in ipairs(tabNames) do
    local tab = make("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1 / #tabNames, -1, 1, 0),
        BackgroundColor3 = C.panel2,
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = name == currentPage and C.white or C.muted,
        TextSize = 9,
        Font = Enum.Font.Code,
        AutoButtonColor = false,
        LayoutOrder = i,
    }, tabs)
    tab.Activated:Connect(function()
        for _, other in ipairs(tabs:GetChildren()) do
            if other:IsA("TextButton") then
                other.TextColor3 = C.muted
                other.BackgroundColor3 = C.panel2
            end
        end
        tab.TextColor3 = C.white
        tab.BackgroundColor3 = C.panel
        renderPage(name)
    end)
end

-- Drag the compact window from its top strip.
local dragging, dragStart, startPos = false, nil, nil
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

renderPage("Main")
print("[Fragment] Feature layout loaded (visual-only controls; no gameplay functions connected).")
