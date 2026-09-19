-- Chat Clicker — two clicks per cycle
-- =  = toggle on/off
-- ]  = destroy the GUI and stop everything
-- Slider controls the delay between full cycles (1s - 20s)
-- Run in your executor.

local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ============ CONFIG ============
local CLICK_X       = 139      -- screen X of the chat bubble
local CLICK_Y       = 32       -- screen Y of the chat bubble
local CLICK_DELAY   = 0.6      -- seconds between the two clicks (open -> close)
-- ================================

getgenv().ChatClicker = getgenv().ChatClicker or {}
local state = getgenv().ChatClicker
state.running   = false
state.loopDelay = 3

local loopThread = nil
local destroyed  = false

-- ---------- Click (two real mouse clicks) ----------
local function doClick()
    VIM:SendMouseButtonEvent(CLICK_X, CLICK_Y, 0, true,  game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(CLICK_X, CLICK_Y, 0, false, game, 1)
end

-- ---------- GUI ----------
if state.gui then
    pcall(function() state.gui:Destroy() end)
    state.gui = nil
end

local gui = Instance.new("ScreenGui")
gui.Name = "ChatClickerGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

do
    local parented = false
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then
            gui.Parent = hui
            parented = true
        end
    end
    if not parented then
        gui.Parent = player:WaitForChild("PlayerGui")
    end
end
state.gui = gui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = false
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Drag bar (only this strip moves the window)
local dragBar = Instance.new("TextLabel")
dragBar.Size = UDim2.new(1, 0, 0, 28)
dragBar.BackgroundTransparency = 1
dragBar.Text = "Chat Clicker"
dragBar.TextColor3 = Color3.fromRGB(220, 220, 220)
dragBar.Font = Enum.Font.GothamBold
dragBar.TextSize = 14
dragBar.Active = true
dragBar.Parent = frame

local dragStart, startPos
dragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        startPos  = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragStart = nil
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if not dragStart then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragStart = nil
    end
end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 22)
status.Position = UDim2.new(0, 0, 0, 28)
status.BackgroundTransparency = 1
status.Text = "OFF"
status.TextColor3 = Color3.fromRGB(255, 90, 90)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.Parent = frame

local coordLabel = Instance.new("TextLabel")
coordLabel.Size = UDim2.new(1, 0, 0, 20)
coordLabel.Position = UDim2.new(0, 0, 0, 52)
coordLabel.BackgroundTransparency = 1
coordLabel.Text = "click @ (" .. CLICK_X .. ", " .. CLICK_Y .. ")"
coordLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
coordLabel.Font = Enum.Font.Gotham
coordLabel.TextSize = 12
coordLabel.Parent = frame

local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(1, 0, 0, 20)
delayLabel.Position = UDim2.new(0, 0, 0, 72)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Loop delay: " .. state.loopDelay .. "s"
delayLabel.TextColor3 = Color3.fromRGB(120, 190, 255)
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextSize = 12
delayLabel.Parent = frame

-- Slider
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -24, 0, 12)
sliderBg.Position = UDim2.new(0, 12, 0, 100)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
sliderBg.BorderSizePixel = 0
sliderBg.Active = true
sliderBg.ZIndex = 2
sliderBg.Parent = frame

local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(1, 0)
sliderBgCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((state.loopDelay - 1) / 19, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(120, 190, 255)
sliderFill.BorderSizePixel = 0
sliderFill.ZIndex = 3
sliderFill.Parent = sliderBg

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(1, 0)
sliderFillCorner.Parent = sliderFill

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 18, 0, 18)
knob.AnchorPoint = Vector2.new(0.5, 0.5)
knob.Position = UDim2.new((state.loopDelay - 1) / 19, 0, 0.5, 0)
knob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
knob.BorderSizePixel = 0
knob.ZIndex = 4
knob.Active = true
knob.Parent = sliderBg

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = knob

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, 0, 0, 20)
hint.Position = UDim2.new(0, 0, 0, 122)
hint.BackgroundTransparency = 1
hint.Text = "= toggle  ·  ] destroy  ·  drag slider"
hint.TextColor3 = Color3.fromRGB(150, 150, 150)
hint.Font = Enum.Font.Gotham
hint.TextSize = 12
hint.Parent = frame

-- Slider drag logic
local draggingSlider = false

local function updateSliderFromInput(input)
    local mouseX = input.Position.X
    local barAbs  = sliderBg.AbsolutePosition.X
    local barSize = sliderBg.AbsoluteSize.X
    if barSize <= 0 then return end

    local relX = math.clamp(mouseX - barAbs, 0, barSize)
    local pct  = relX / barSize
    local val  = math.floor(1 + pct * 19 + 0.5)
    if val < 1 then val = 1 end
    if val > 20 then val = 20 end

    state.loopDelay = val
    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
    knob.Position   = UDim2.new(pct, 0, 0.5, 0)
    delayLabel.Text = "Loop delay: " .. val .. "s"
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        updateSliderFromInput(input)
    end
end)

knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
    end
end)

UIS.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        updateSliderFromInput(input)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

local function updateGui()
    if destroyed then return end
    if not state.gui or not state.gui.Parent then return end
    if state.running then
        status.Text = "ON"
        status.TextColor3 = Color3.fromRGB(120, 230, 120)
    else
        status.Text = "OFF"
        status.TextColor3 = Color3.fromRGB(255, 90, 90)
    end
end

-- ---------- Loop ----------
local function startLoop()
    if loopThread then return end
    loopThread = task.spawn(function()
        while state.running and not destroyed do
            local ok, err = pcall(function()
                doClick()                        -- click 1: open
                task.wait(CLICK_DELAY)
                doClick()                        -- click 2: close
                task.wait(state.loopDelay)       -- wait between cycles
            end)
            if not ok then
                warn("[ChatClicker] error, stopping: " .. tostring(err))
                state.running = false
                updateGui()
                break
            end
        end
        loopThread = nil
    end)
end

local function stopLoop()
    state.running = false
    loopThread = nil
end

-- ---------- Keybinds ----------
local function toggle()
    if destroyed then return end
    state.running = not state.running
    if state.running then startLoop() else stopLoop() end
    updateGui()
end
state.toggle = toggle

local function destroy()
    if destroyed then return end
    destroyed = true
    state.running = false
    loopThread = nil
    if state.gui then
        pcall(function() state.gui:Destroy() end)
        state.gui = nil
    end
    print("[ChatClicker] destroyed")
end
state.destroy = destroy

UIS.InputBegan:Connect(function(input, gp)
    if gp or destroyed then return end
    if input.KeyCode == Enum.KeyCode.Equals then
        toggle()
    elseif input.KeyCode == Enum.KeyCode.RightBracket then
        destroy()
    end
end)

updateGui()
print("[ChatClicker] loaded — = toggle · ] destroy")
