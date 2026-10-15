--[[
    PORTAL DEVICE
    Version: 1.0.0
    Platform: Roblox Studio
    Type: LocalScript
    By: Louis
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CONFIGURATION
--==================================================

local VERSION = "1.0.0"

local GREEN = Color3.fromRGB(90, 255, 110)
local DARK = Color3.fromRGB(8, 20, 12)
local PANEL = Color3.fromRGB(15, 35, 21)
local WHITE = Color3.fromRGB(220, 255, 225)
local MUTED = Color3.fromRGB(130, 170, 140)
local RED = Color3.fromRGB(255, 100, 100)

local SLOT_COUNT = 5

--==================================================
-- CLEANUP PREVIOUS GUI
--==================================================

local previous = playerGui:FindFirstChild("PortalDevice")

if previous then
    previous:Destroy()
end

--==================================================
-- INSTANCE HELPERS
--==================================================

local function create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function corner(object, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 7)
    }, object)
end

local function stroke(object, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or GREEN,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, object)
end

--==================================================
-- GUI
--==================================================

local gui = create("ScreenGui", {
    Name = "PortalDevice",
    ResetOnSpawn = false,
    DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    IgnoreGuiInset = false,
}, playerGui)

local main = create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(380, 474),
    Position = UDim2.new(0, 24, 0.5, -237),
    BackgroundColor3 = DARK,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = true,
    ZIndex = 1,
}, gui)

corner(main, 12)
stroke(main, GREEN, 1.5, 0.2)

--==================================================
-- HEADER
--==================================================

local header = create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Active = true,
    ZIndex = 2,
}, main)

create("TextLabel", {
    Size = UDim2.new(1, -65, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Text = "◉  PORTAL DEVICE",
    TextColor3 = GREEN,
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, header)

create("TextLabel", {
    Size = UDim2.fromOffset(45, 20),
    Position = UDim2.new(1, -55, 0, 11),
    BackgroundTransparency = 1,
    Text = "v" .. VERSION,
    TextColor3 = MUTED,
    TextSize = 10,
    Font = Enum.Font.GothamMedium,
    ZIndex = 3,
}, header)

--==================================================
-- DRAG WINDOW
--==================================================

local dragging = false
local dragStart
local startPosition
local dragInput

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        dragInput = input
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging or not dragInput then
        return
    end

    if input == dragInput
        or input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
        dragInput = nil
    end
end)

--==================================================
-- UI HELPERS
--==================================================

local function makeLabel(text, position, size, textSize)
    return create("TextLabel", {
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = GREEN,
        TextSize = textSize or 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    }, main)
end

local function makeButton(text, position, size)
    local button = create("TextButton", {
        Position = position,
        Size = size,
        BackgroundColor3 = GREEN,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = DARK,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = true,
        ZIndex = 2,
    }, main)

    corner(button, 6)
    return button
end

local function makeInput(text, position, size, placeholder)
    local input = create("TextBox", {
        Position = position,
        Size = size,
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Text = text or "",
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = MUTED,
        TextColor3 = WHITE,
        TextSize = 12,
        Font = Enum.Font.Code,
        ClearTextOnFocus = false,
        TextEditable = true,
        ZIndex = 2,
    }, main)

    corner(input, 6)
    stroke(input, GREEN, 1, 0.72)

    return input
end

--==================================================
-- CHARACTER HELPERS
--==================================================

local function getRoot()
    local character = player.Character

    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

local function getPosition()
    local root = getRoot()
    return root and root.Position or nil
end

local function formatCoordinates(position)
    return string.format(
        "%.2f, %.2f, %.2f",
        position.X,
        position.Y,
        position.Z
    )
end

local function parseCoordinates(text)
    text = text:gsub("[,;]", " ")

    local values = {}

    for token in text:gmatch("%S+") do
        local number = tonumber(token)

        if not number
            or number ~= number
            or number == math.huge
            or number == -math.huge then
            return nil
        end

        table.insert(values, number)
    end

    if #values ~= 3 then
        return nil
    end

    return Vector3.new(values[1], values[2], values[3])
end

--==================================================
-- STATUS
--==================================================

local status = create("TextLabel", {
    Name = "Status",
    Position = UDim2.new(0, 12, 1, -29),
    Size = UDim2.new(1, -24, 0, 20),
    BackgroundTransparency = 1,
    Text = "● SYSTEM ONLINE",
    TextColor3 = GREEN,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 2,
}, main)

local function setStatus(message, color)
    status.Text = "● " .. message
    status.TextColor3 = color or GREEN
end

--==================================================
-- CURRENT POSITION
--==================================================

makeLabel(
    "CURRENT POSITION",
    UDim2.fromOffset(12, 49),
    UDim2.new(1, -24, 0, 18)
)

local currentBox = makeInput(
    "0, 0, 0",
    UDim2.fromOffset(12, 70),
    UDim2.new(1, -24, 0, 31),
    "X, Y, Z"
)

currentBox.TextXAlignment = Enum.TextXAlignment.Center

--==================================================
-- SAVED LOCATIONS
--==================================================

makeLabel(
    "SAVED LOCATIONS  /  5 SLOTS",
    UDim2.fromOffset(12, 112),
    UDim2.new(1, -24, 0, 18)
)

makeLabel(
    "NAME",
    UDim2.fromOffset(12, 133),
    UDim2.fromOffset(77, 15),
    10
)

makeLabel(
    "COORDINATES (X, Y, Z)",
    UDim2.fromOffset(95, 133),
    UDim2.fromOffset(155, 15),
    10
)

local slots = {}

for i = 1, SLOT_COUNT do
    local y = 151 + (i - 1) * 42

    local nameBox = makeInput(
        "Slot " .. i,
        UDim2.fromOffset(12, y),
        UDim2.fromOffset(77, 31),
        "Name"
    )

    local coordinateBox = makeInput(
        "",
        UDim2.fromOffset(95, y),
        UDim2.fromOffset(155, 31),
        "Empty"
    )

    local saveButton = makeButton(
        "SAVE",
        UDim2.fromOffset(256, y),
        UDim2.fromOffset(52, 31)
    )

    local goButton = makeButton(
        "GO",
        UDim2.fromOffset(314, y),
        UDim2.fromOffset(54, 31)
    )

    slots[i] = {
        nameBox = nameBox,
        coordinateBox = coordinateBox,
        saveButton = saveButton,
        goButton = goButton,
    }

    saveButton.MouseButton1Click:Connect(function()
        local position = getPosition()

        if not position then
            setStatus("CHARACTER NOT READY", RED)
            return
        end

        coordinateBox.Text = formatCoordinates(position)

        if nameBox.Text:gsub("%s+", "") == "" then
            nameBox.Text = "Slot " .. i
        end

        setStatus("SAVED: " .. nameBox.Text)
    end)

    goButton.MouseButton1Click:Connect(function()
        local destination = parseCoordinates(coordinateBox.Text)

        if not destination then
            setStatus("INVALID SLOT COORDINATES", RED)
            return
        end

        local root = getRoot()

        if not root then
            setStatus("CHARACTER NOT READY", RED)
            return
        end

        root.CFrame = CFrame.new(destination)
        setStatus("TELEPORTED: " .. nameBox.Text)
    end)
end

--==================================================
-- MANUAL TELEPORT
--==================================================

makeLabel(
    "MANUAL TELEPORT  /  X, Y, Z",
    UDim2.fromOffset(12, 366),
    UDim2.new(1, -24, 0, 18)
)

local manualBox = makeInput(
    "0, 0, 0",
    UDim2.fromOffset(12, 388),
    UDim2.new(1, -24, 0, 31),
    "X, Y, Z"
)

local teleportButton = makeButton(
    "TELEPORT TO COORDINATES",
    UDim2.fromOffset(12, 425),
    UDim2.new(1, -24, 0, 30)
)

teleportButton.MouseButton1Click:Connect(function()
    local destination = parseCoordinates(manualBox.Text)

    if not destination then
        setStatus("INVALID COORDINATES", RED)
        return
    end

    local root = getRoot()

    if not root then
        setStatus("CHARACTER NOT READY", RED)
        return
    end

    root.CFrame = CFrame.new(destination)
    setStatus("TELEPORT COMPLETE")
end)

--==================================================
-- RIGHT CTRL: SHOW / HIDE GUI
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if UserInputService:GetFocusedTextBox() then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)

--==================================================
-- CHARACTER INITIALIZATION
--==================================================

local function initializeCharacter()
    task.wait(0.5)

    local position = getPosition()

    if not position then
        return
    end

    currentBox.Text = formatCoordinates(position)
    manualBox.Text = formatCoordinates(position)

    setStatus("SYSTEM ONLINE")
end

player.CharacterAdded:Connect(initializeCharacter)
initializeCharacter()

--==================================================
-- LIVE POSITION UPDATE
--==================================================

task.spawn(function()
    while gui.Parent do
        local position = getPosition()

        if position and not currentBox:IsFocused() then
            currentBox.Text = formatCoordinates(position)
        end

        task.wait(0.15)
    end
end)

print("[Portal Device] v" .. VERSION .. " loaded successfully.")

--wabba lubba dub dub