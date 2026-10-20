
--[[
    By Louis
    Version: 1.1.4
    Runtime: Xeno - Luau
    Last updated: 2026-10-20
    Intended for personal projects, testing, and environments where use is authorized.
]]

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

--==================================================
-- CONFIGURATION
--==================================================

local VERSION = "1.1.4"

local SLOT_COUNT = 5
local MAX_TARGET_DISTANCE = 500

local GREEN = Color3.fromRGB(70, 255, 100)
local GREEN_LIGHT = Color3.fromRGB(160, 255, 175)
local GREEN_DARK = Color3.fromRGB(20, 110, 45)

local DARK = Color3.fromRGB(5, 13, 8)
local PANEL = Color3.fromRGB(10, 26, 15)
local PANEL_LIGHT = Color3.fromRGB(17, 42, 24)

local WHITE = Color3.fromRGB(220, 255, 225)
local MUTED = Color3.fromRGB(105, 155, 115)
local RED = Color3.fromRGB(255, 90, 90)
local YELLOW = Color3.fromRGB(220, 255, 100)

--==================================================
-- SYSTEM STATE
--==================================================

local clickTeleportEnabled = false
local clickTeleportKey = Enum.KeyCode.G -- default key for click teleport
local waitingForTeleportKey = false

local targetObject = nil
local targetPart = nil

local dragging = false
local dragStart = nil
local startPosition = nil

local connections = {}

--==================================================
-- CLEANUP
--==================================================

local previous = playerGui:FindFirstChild("PortalDevice")

if previous then
    previous:Destroy()
end

--==================================================
-- CONNECTION MANAGER
--==================================================

-- Centralizes event connections so they can all be disconnected during cleanup.
local function connect(signal, callback)
    local connection = signal:Connect(callback)

    table.insert(connections, connection)

    return connection
end

--==================================================
-- INSTANCE HELPER
--==================================================

-- Creates an Instance, applies its properties, and attaches it to the requested parent.
local function create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties) do
        object[property] = value
    end

    object.Parent = parent

    return object
end

--==================================================
-- UI HELPERS
--==================================================

local function corner(object, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 7)
    }, object)
end

local function stroke(object, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or GREEN,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, object)
end

--==================================================
-- VALIDATION
--==================================================

local function isValidPart(part)
    return part ~= nil
        and part:IsA("BasePart")
        and part:IsDescendantOf(Workspace)
end

local function isFiniteNumber(number)
    return number ~= nil
        and number == number
        and number ~= math.huge
        and number ~= -math.huge
end

--==================================================
-- COORDINATES
--==================================================

local function formatCoordinates(position)
    return string.format(
        "%.2f, %.2f, %.2f",
        position.X,
        position.Y,
        position.Z
    )
end

-- Accepts three finite numeric values separated by commas, semicolons, or whitespace.
local function parseCoordinates(text)
    text = text:gsub("[,;]", " ")

    local values = {}

    for token in text:gmatch("%S+") do
        local number = tonumber(token)

        if not isFiniteNumber(number) then
            return nil
        end

        table.insert(values, number)
    end

    if #values ~= 3 then
        return nil
    end

    return Vector3.new(
        values[1],
        values[2],
        values[3]
    )
end

--==================================================
-- MAIN GUI
--==================================================

local gui = create("ScreenGui", {
    Name = "PortalDevice",
    ResetOnSpawn = false,
    DisplayOrder = 100,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = false
}, playerGui)

--==================================================
-- MAIN WINDOW
--==================================================

local main = create("Frame", {
    Name = "Main",

    Size = UDim2.fromOffset(390, 535),
    Position = UDim2.new(0, 24, 0.5, -267),

    BackgroundColor3 = DARK,
    BorderSizePixel = 0,

    ClipsDescendants = true,
    Visible = true,
    Active = true,

    ZIndex = 1
}, gui)

corner(main, 12)

local mainStroke = stroke(
    main,
    GREEN,
    1.5,
    0.15
)

--==================================================
-- BACKGROUND ACCENT
--==================================================

create("Frame", {
    Name = "BackgroundAccent",

    Position = UDim2.fromOffset(0, 46),
    Size = UDim2.new(1, 0, 0, 1),

    BackgroundColor3 = GREEN,
    BackgroundTransparency = 0.55,

    BorderSizePixel = 0,
    ZIndex = 2
}, main)

--==================================================
-- STATUS BAR
--==================================================

local status = create("TextLabel", {
    Name = "Status",

    Position = UDim2.new(0, 12, 1, -25),
    Size = UDim2.new(1, -24, 0, 16),

    BackgroundTransparency = 1,

    Text = "GREEN VORTEX // INITIALIZING",
    TextColor3 = GREEN,

    TextSize = 10,
    Font = Enum.Font.Code,

    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,

    ZIndex = 5
}, main)

-- Keeps status feedback consistent across all tool actions.
local function setStatus(message, color)
    status.Text = message
    status.TextColor3 = color or GREEN
end

--==================================================
-- LABEL HELPER
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
        TextTruncate = Enum.TextTruncate.AtEnd,

        ZIndex = 3
    }, main)
end

--==================================================
-- BUTTON HELPER
--==================================================

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

        AutoButtonColor = false,
        Active = true,

        ZIndex = 3
    }, main)

    corner(button, 6)

    stroke(button, GREEN_LIGHT, 1, 0.65)

    connect(button.MouseEnter, function()
        button.BackgroundColor3 = GREEN_LIGHT
    end)

    connect(button.MouseLeave, function()
        if button.Name == "ClickTpButton"
            and clickTeleportEnabled then

            button.BackgroundColor3 = GREEN
        elseif button.Name == "ClickTpButton" then
            button.BackgroundColor3 = PANEL_LIGHT
        elseif button.Name == "ClickTpKeyButton" then
            button.BackgroundColor3 = PANEL_LIGHT
        else
            button.BackgroundColor3 = GREEN
        end
    end)

    return button
end

--==================================================
-- TEXTBOX HELPER
--==================================================

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

        ZIndex = 3
    }, main)

    corner(input, 6)
    stroke(input, GREEN, 1, 0.72)

    connect(input.Focused, function()
        TweenService:Create(
            input,
            TweenInfo.new(0.15),
            {
                BackgroundColor3 = PANEL_LIGHT
            }
        ):Play()
    end)

    connect(input.FocusLost, function()
        TweenService:Create(
            input,
            TweenInfo.new(0.15),
            {
                BackgroundColor3 = PANEL
            }
        ):Play()
    end)

    return input
end

--==================================================
-- part 1/7
--==================================================

print("[Portal Device] Part 1/7")

--==================================================
-- HEADER
--==================================================

local header = create("Frame", {
    Name = "Header",

    Size = UDim2.new(1, 0, 0, 46),

    BackgroundColor3 = PANEL_LIGHT,
    BorderSizePixel = 0,

    Active = true,
    ZIndex = 4
}, main)

local headerLine = create("Frame", {
    Name = "HeaderNeonLine",

    Position = UDim2.new(0, 0, 1, -1),
    Size = UDim2.new(1, 0, 0, 1),

    BackgroundColor3 = GREEN,
    BackgroundTransparency = 0.15,

    BorderSizePixel = 0,
    ZIndex = 5
}, header)

--==================================================
-- PORTAL ICON
--==================================================

local portalIcon = create("Frame", {
    Name = "PortalIcon",

    Position = UDim2.fromOffset(10, 7),
    Size = UDim2.fromOffset(32, 32),

    BackgroundColor3 = DARK,
    BorderSizePixel = 0,

    ZIndex = 5
}, header)

corner(portalIcon, 16)

local portalIconStroke = stroke(
    portalIcon,
    GREEN,
    1.5,
    0
)

-- Inner ring adds depth to the portal emblem.
local innerRing = create("Frame", {
    Name = "InnerRing",

    Position = UDim2.fromOffset(5, 5),
    Size = UDim2.fromOffset(22, 22),

    BackgroundTransparency = 1,
    BorderSizePixel = 0,

    ZIndex = 6
}, portalIcon)

corner(innerRing, 11)

local innerRingStroke = stroke(
    innerRing,
    GREEN_LIGHT,
    1.2,
    0.1
)

local portalCore = create("Frame", {
    Name = "PortalCore",

    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),

    Size = UDim2.fromOffset(7, 7),

    BackgroundColor3 = GREEN_LIGHT,
    BorderSizePixel = 0,

    ZIndex = 7
}, portalIcon)

corner(portalCore, 8)

local coreStroke = stroke(
    portalCore,
    GREEN,
    1,
    0
)

--==================================================
-- HEADER TEXT
--==================================================

create("TextLabel", {
    Name = "Title",

    Position = UDim2.fromOffset(50, 5),
    Size = UDim2.new(1, -125, 0, 22),

    BackgroundTransparency = 1,

    Text = "PORTAL DEVICE",
    TextColor3 = GREEN,

    TextSize = 16,
    Font = Enum.Font.GothamBold,

    TextXAlignment = Enum.TextXAlignment.Left,

    ZIndex = 6
}, header)

create("TextLabel", {
    Name = "Subtitle",

    Position = UDim2.fromOffset(51, 26),
    Size = UDim2.new(1, -125, 0, 12),

    BackgroundTransparency = 1,

    Text = "// DIMENSIONAL TOOL",
    TextColor3 = MUTED,

    TextSize = 8,
    Font = Enum.Font.Code,

    TextXAlignment = Enum.TextXAlignment.Left,

    ZIndex = 6
}, header)

create("TextLabel", {
    Name = "Version",

    Position = UDim2.new(1, -67, 0, 13),
    Size = UDim2.fromOffset(56, 20),

    BackgroundTransparency = 1,

    Text = "v" .. VERSION,
    TextColor3 = GREEN_LIGHT,

    TextSize = 10,
    Font = Enum.Font.GothamBold,

    ZIndex = 6
}, header)

--==================================================
-- WINDOW DRAG
-- Mouse + touch
--==================================================

connect(header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

connect(UserInputService.InputChanged, function(input)
    if not dragging or not dragStart or not startPosition then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,

            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
        dragStart = nil
        startPosition = nil
    end
end)

--==================================================
-- GREEN NEON ANIMATION
--==================================================

local animationTime = 0

connect(RunService.RenderStepped, function(deltaTime)
    animationTime += deltaTime

    local pulse = (math.sin(animationTime * 2.5) + 1) / 2

    mainStroke.Transparency = 0.10 + pulse * 0.22

    portalIconStroke.Transparency = 0.05 + pulse * 0.25

    innerRingStroke.Transparency = 0.10 + pulse * 0.35

    headerLine.BackgroundTransparency = 0.10 + pulse * 0.35

    -- The core scales with the neon pulse animation.
    local coreSize = 6 + pulse * 2

    portalCore.Size = UDim2.fromOffset(
        coreSize,
        coreSize
    )

    coreStroke.Transparency = 0.05 + pulse * 0.25
end)

--==================================================
-- END OF PART 2/7
--==================================================

print("[Portal Device] Part 2/7 loaded.")

--==================================================
-- CHARACTER ROOT DETECTION
--==================================================

-- Finds a usable root part, preferring the standard HumanoidRootPart.
local function findCharacterRoot(character)
    if not character or not character:IsA("Model") then
        return nil
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if isValidPart(root) then
        return root
    end

    if isValidPart(character.PrimaryPart) then
        return character.PrimaryPart
    end

    local rootNames = {
        "RootPart",
        "Root",
        "UpperTorso",
        "Torso",
        "LowerTorso"
    }

    for _, name in ipairs(rootNames) do
        local part = character:FindFirstChild(name, true)

        if isValidPart(part) then
            return part
        end
    end

    return nil
end

--==================================================
-- LOCAL CHARACTER TARGET
--==================================================

local function getCharacterTarget()
    local character = player.Character

    if not character then
        return nil, nil
    end

    return character, findCharacterRoot(character)
end

-- The current target is the local player's character.
local function getTargetPart()
    local character, root = getCharacterTarget()

    if character and root then
        targetObject = character
        targetPart = root

        return root
    end

    targetObject = nil
    targetPart = nil

    return nil
end

local function getPosition()
    local part = getTargetPart()

    return part and part.Position or nil
end

--==================================================
-- TARGET DISTANCE
--==================================================

local function getTargetDistance(part)
    local character = player.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not root or not isValidPart(part) then
        return nil
    end

    return (root.Position - part.Position).Magnitude
end

--==================================================
-- GREEN HIGHLIGHT
--==================================================

local selectedHighlight = create("Highlight", {
    Name = "PortalSelectedTarget",

    FillColor = GREEN,
    OutlineColor = GREEN_LIGHT,

    FillTransparency = 0.88,
    OutlineTransparency = 0.05,

    DepthMode = Enum.HighlightDepthMode.Occluded,
    Enabled = false
}, gui)

-- Updates the highlight whenever the local character becomes available or changes.
local function updateSelectedHighlight()
    local character = player.Character

    if character and character:IsDescendantOf(Workspace) then
        selectedHighlight.Adornee = character
        selectedHighlight.Enabled = true
    else
        selectedHighlight.Adornee = nil
        selectedHighlight.Enabled = false
    end
end

--==================================================
-- CHARACTER INITIALIZATION
--==================================================

local function initializeCharacter(character)
    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if not root then
        root = character:WaitForChild("HumanoidRootPart", 5)
    end

    if character ~= player.Character then
        return
    end

    if not isValidPart(root) then
        root = findCharacterRoot(character)
    end

    if root then
        targetObject = character
        targetPart = root

        updateSelectedHighlight()

        setStatus("CHARACTER DETECTED", GREEN)
    else
        targetObject = nil
        targetPart = nil

        updateSelectedHighlight()

        setStatus("CHARACTER ROOT NOT FOUND", RED)
    end
end

--==================================================
-- RESPAWN HANDLING
--==================================================

connect(player.CharacterAdded, function(character)
    task.spawn(initializeCharacter, character)
end)

connect(player.CharacterRemoving, function(character)
    if targetObject == character then
        targetObject = nil
        targetPart = nil
    end

    selectedHighlight.Adornee = nil
    selectedHighlight.Enabled = false

    setStatus("CHARACTER RESPAWNING", MUTED)
end)

--==================================================
-- INITIAL TARGET
--==================================================

if player.Character then
    task.spawn(initializeCharacter, player.Character)
else
    setStatus("WAITING FOR CHARACTER", MUTED)
end

--==================================================
-- END OF PART 3/7
--==================================================

print("[Portal Device] Part 3/7 loaded.")

--==================================================
-- CURRENT POSITION
--==================================================

makeLabel(
    "CURRENT POSITION // X, Y, Z",
    UDim2.fromOffset(12, 54),
    UDim2.new(1, -24, 0, 17)
)

local currentBox = makeInput(
    "0, 0, 0",
    UDim2.fromOffset(12, 75),
    UDim2.new(1, -24, 0, 30),
    "X, Y, Z"
)

currentBox.TextXAlignment = Enum.TextXAlignment.Center
currentBox.TextEditable = false

--==================================================
-- SAVED LOCATIONS HEADER
--==================================================

makeLabel(
    "SAVED LOCATIONS // 5 SLOTS",
    UDim2.fromOffset(12, 117),
    UDim2.new(1, -24, 0, 18)
)

makeLabel(
    "NAME",
    UDim2.fromOffset(12, 139),
    UDim2.fromOffset(77, 15),
    10
)

makeLabel(
    "COORDINATES",
    UDim2.fromOffset(95, 139),
    UDim2.fromOffset(155, 15),
    10
)

--==================================================
-- SLOT STORAGE
--==================================================

local slots = {}

--==================================================
-- CREATE FIVE SLOTS
--==================================================

for i = 1, SLOT_COUNT do
    local y = 158 + (i - 1) * 40

    local nameBox = makeInput(
        "Slot " .. i,
        UDim2.fromOffset(12, y),
        UDim2.fromOffset(77, 30),
        "Name"
    )

    local coordinateBox = makeInput(
        "",
        UDim2.fromOffset(95, y),
        UDim2.fromOffset(155, 30),
        "Empty"
    )

    local saveButton = makeButton(
        "SAVE",
        UDim2.fromOffset(256, y),
        UDim2.fromOffset(52, 30)
    )

    local goButton = makeButton(
        "GO",
        UDim2.fromOffset(314, y),
        UDim2.fromOffset(54, 30)
    )

    slots[i] = {
        nameBox = nameBox,
        coordinateBox = coordinateBox,
        saveButton = saveButton,
        goButton = goButton
    }

    --==================================================
    -- SAVE CURRENT POSITION
    --==================================================

    connect(saveButton.MouseButton1Click, function()
        local position = getPosition()

        if not position then
            setStatus("NO VALID CHARACTER POSITION", RED)
            return
        end

        coordinateBox.Text = formatCoordinates(position)

        if nameBox.Text:gsub("%s+", "") == "" then
            nameBox.Text = "Slot " .. i
        end

        setStatus("POSITION SAVED // " .. nameBox.Text, GREEN)
    end)

    --==================================================
    -- GO TO SAVED POSITION
    --==================================================

    connect(goButton.MouseButton1Click, function()
        local destination = parseCoordinates(
            coordinateBox.Text
        )

        if not destination then
            setStatus("INVALID SLOT COORDINATES", RED)
            return
        end

        local part = getTargetPart()

        if not part then
            setStatus("NO VALID CHARACTER ROOT", RED)
            return
        end

        local success, err = pcall(function()
            part.CFrame = CFrame.new(destination)
        end)

        if success then
            setStatus("MOVE REQUEST SENT // " .. nameBox.Text, GREEN)
        else
            setStatus("MOVE FAILED // " .. tostring(err), RED)
        end
    end)
end

--==================================================
-- LIVE POSITION UPDATE
--==================================================

local positionAccumulator = 0
local POSITION_UPDATE_INTERVAL = 0.15

connect(RunService.Heartbeat, function(deltaTime)
    positionAccumulator += deltaTime

    if positionAccumulator < POSITION_UPDATE_INTERVAL then
        return
    end

    positionAccumulator = 0

    if not gui.Parent then
        return
    end

    local part = getTargetPart()

    if part then
        if not currentBox:IsFocused() then
            currentBox.Text = formatCoordinates(part.Position)
        end
    else
        if not currentBox:IsFocused() then
            currentBox.Text = "Unavailable"
        end
    end
end)

--==================================================
-- END OF PART 4/7
--==================================================

print("[Portal Device] Part 4/7 loaded.")

--==================================================
-- MANUAL TELEPORT
--==================================================

makeLabel(
    "MANUAL TELEPORT // X, Y, Z",
    UDim2.fromOffset(12, 370),
    UDim2.new(1, -24, 0, 17)
)

local manualBox = makeInput(
    "0, 0, 0",
    UDim2.fromOffset(12, 391),
    UDim2.new(1, -24, 0, 30),
    "Example: 0, 10, 0"
)

manualBox.TextXAlignment = Enum.TextXAlignment.Center

local teleportButton = makeButton(
    "MOVE TO COORDINATES",
    UDim2.fromOffset(12, 428),
    UDim2.new(1, -24, 0, 30)
)

--==================================================
-- TELEPORT EXECUTION
--==================================================

-- Validates the destination and attempts to move the local character root.
local function teleportToPosition(destination)
    if typeof(destination) ~= "Vector3"
        or not isFiniteNumber(destination.X)
        or not isFiniteNumber(destination.Y)
        or not isFiniteNumber(destination.Z) then

        setStatus("INVALID DESTINATION", RED)
        return
    end

    local part = getTargetPart()

    if not part then
        setStatus("NO VALID CHARACTER ROOT", RED)
        return
    end

    local success, err = pcall(function()
        part.CFrame = CFrame.new(destination)
    end)

    if success then
        setStatus("MOVE REQUEST SENT", GREEN)
    else
        setStatus("MOVE FAILED // " .. tostring(err), RED)
    end
end

connect(teleportButton.MouseButton1Click, function()
    local destination = parseCoordinates(manualBox.Text)

    if not destination then
        setStatus("INVALID COORDINATES", RED)
        return
    end

    teleportToPosition(destination)
end)

--==================================================
-- CLICK TELEPORT UI
--==================================================

makeLabel(
    "CLICK TELEPORT",
    UDim2.fromOffset(12, 472),
    UDim2.new(1, -24, 0, 17)
)

local clickTpButton = makeButton(
    "CLICK TP: OFF",
    UDim2.fromOffset(12, 495),
    UDim2.fromOffset(170, 30)
)

local clickTpKeyButton = makeButton(
    "SET KEY: " .. clickTeleportKey.Name,
    UDim2.fromOffset(190, 495),
    UDim2.fromOffset(178, 30)
)

--==================================================
-- CLICK TP STATE
--==================================================

local function updateClickTpButton()
    if clickTeleportEnabled then
        clickTpButton.Text = "CLICK TP: ON"
        clickTpButton.BackgroundColor3 = GREEN
    else
        clickTpButton.Text = "CLICK TP: OFF"
        clickTpButton.BackgroundColor3 = PANEL_LIGHT
    end
end

local function setClickTeleport(enabled)
    clickTeleportEnabled = enabled

    updateClickTpButton()

    if enabled then
        setStatus("CLICK TP ACTIVE // CLICK WORLD", GREEN)
    else
        setStatus("CLICK TP OFF", MUTED)
    end
end

connect(clickTpButton.MouseButton1Click, function()
    setClickTeleport(not clickTeleportEnabled)
end)

--==================================================
-- CONFIGURE CLICK TP KEY
--==================================================

connect(clickTpKeyButton.MouseButton1Click, function()
    waitingForTeleportKey = true

    clickTpKeyButton.Text = "PRESS A KEY..."

    setStatus("PRESS A KEY // ESC TO CANCEL", GREEN)
end)

--==================================================
-- GUI CLICK DETECTION
--==================================================

-- Prevents interface interactions from being interpreted as world clicks.
local function clickIsOverGui(input)
    local objects = playerGui:GetGuiObjectsAtPosition(
        input.Position.X,
        input.Position.Y
    )

    for _, object in ipairs(objects) do
        if object:IsDescendantOf(gui) then
            return true
        end
    end

    return false
end

--==================================================
-- CLICK TELEPORT EXECUTION
--==================================================

local function teleportToClick()
    local part = getTargetPart()

    if not part then
        setStatus("NO VALID CHARACTER ROOT", RED)
        setClickTeleport(false)
        return
    end

    local hit = mouse.Hit
    local destination = hit.Position + Vector3.new(0, 3, 0)

    teleportToPosition(destination)
end

--==================================================
-- END OF PART 5/7
--==================================================

updateClickTpButton()

print("[Portal Device] Part 5/7 loaded.")

--==================================================
-- INPUT HANDLER
--==================================================

connect(UserInputService.InputBegan, function(input, processed)

    ------------------------------------------------
    -- KEY BINDING MODE
    ------------------------------------------------

    if waitingForTeleportKey then
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end

        if input.KeyCode == Enum.KeyCode.Escape then
            waitingForTeleportKey = false

            clickTpKeyButton.Text =
                "SET KEY: " .. clickTeleportKey.Name

            setStatus("KEY CHANGE CANCELLED", MUTED)
            return
        end

        if input.KeyCode == Enum.KeyCode.Unknown
            or input.KeyCode == Enum.KeyCode.RightControl then
            return
        end

        clickTeleportKey = input.KeyCode
        waitingForTeleportKey = false

        clickTpKeyButton.Text =
            "SET KEY: " .. clickTeleportKey.Name

        setStatus("CLICK TP KEY UPDATED", GREEN)
        return
    end

    ------------------------------------------------
    -- RIGHT CTRL: SHOW / HIDE GUI
    ------------------------------------------------

    if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == Enum.KeyCode.RightControl
        and not processed
        and not UserInputService:GetFocusedTextBox() then

        main.Visible = not main.Visible
        return
    end

    ------------------------------------------------
    -- IGNORE PROCESSED INPUT
    ------------------------------------------------

    if processed then
        return
    end

    if UserInputService:GetFocusedTextBox() then
        return
    end

    ------------------------------------------------
    -- TOGGLE CLICK TP KEY
    ------------------------------------------------

    if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == clickTeleportKey then

        setClickTeleport(not clickTeleportEnabled)
        return
    end

    ------------------------------------------------
    -- WORLD CLICK
    ------------------------------------------------

    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    -- Ignore clicks that land on the tool's interface.
    if main.Visible and clickIsOverGui(input) then
        return
    end

    -- Only process world clicks while Click Teleport is enabled.
    if clickTeleportEnabled then
        teleportToClick()
    end
end)

--==================================================
-- CLEANUP
--==================================================

connect(gui.Destroying, function()
    for _, connection in ipairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end

    table.clear(connections)
end)

--==================================================
-- END OF PART 6/7
--==================================================

print("[Portal Device] Part 6/7 loaded.")

--==================================================
-- LIVE POSITION UPDATE
--==================================================

local finalUpdateAccumulator = 0
local FINAL_UPDATE_INTERVAL = 0.15

connect(RunService.Heartbeat, function(deltaTime)
    finalUpdateAccumulator += deltaTime

    if finalUpdateAccumulator < FINAL_UPDATE_INTERVAL then
        return
    end

    finalUpdateAccumulator = 0

    if not gui.Parent then
        return
    end

    local part = getTargetPart()

    if part then
        if not currentBox:IsFocused() then
            currentBox.Text = formatCoordinates(part.Position)
        end

        if not manualBox:IsFocused() then
            manualBox.Text = formatCoordinates(part.Position)
        end

        updateSelectedHighlight()
    else
        if not currentBox:IsFocused() then
            currentBox.Text = "Unavailable"
        end

        if not manualBox:IsFocused() then
            manualBox.Text = "Unavailable"
        end

        selectedHighlight.Adornee = nil
        selectedHighlight.Enabled = false
    end
end)

--==================================================
-- WINDOW POSITION
--==================================================

-- Keeps the window within the current camera viewport after resizing or camera changes.
local function clampWindowPosition()
    local camera = Workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local absoluteSize = main.AbsoluteSize

    local maxX = math.max(0, viewport.X - absoluteSize.X)
    local maxY = math.max(0, viewport.Y - absoluteSize.Y)

    local x = math.clamp(
        main.Position.X.Offset,
        0,
        maxX
    )

    local y = math.clamp(
        main.Position.Y.Offset,
        0,
        maxY
    )

    main.Position = UDim2.new(0, x, 0, y)
end

connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
    task.defer(function()
        clampWindowPosition()

        local camera = Workspace.CurrentCamera

        if camera then
            connect(
                camera:GetPropertyChangedSignal("ViewportSize"),
                clampWindowPosition
            )
        end
    end)
end)

if Workspace.CurrentCamera then
    connect(
        Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),
        clampWindowPosition
    )
end

--==================================================
-- INITIALIZATION
--==================================================

gui.Enabled = true
main.Visible = true

updateClickTpButton()

if player.Character then
    task.spawn(initializeCharacter, player.Character)
else
    setStatus("WAITING FOR CHARACTER", MUTED)
end

task.defer(clampWindowPosition)

--==================================================
-- STARTUP
--==================================================

print("======================================")
print("[Portal Device] GREEN VORTEX")
print("[Portal Device] Version: " .. VERSION)
print("[Portal Device] Initialization complete")
print("[Portal Device] Right Ctrl: Toggle GUI")
print("[Portal Device] Click TP: " .. clickTeleportKey.Name)
print("======================================")
