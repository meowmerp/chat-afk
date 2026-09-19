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
dragBar.Text = "ChatClicker"
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

-- Small circle button next to status
local circleBtn = Instance.new("Frame")
circleBtn.Size = UDim2.new(0, 16, 0, 16)
circleBtn.Position = UDim2.new(1, -20, 0, 4)
circleBtn.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
circleBtn.BackgroundTransparency = 1
circleBtn.BorderSizePixel = 0
circleBtn.Active = true
circleBtn.ZIndex = 10
circleBtn.Parent = frame

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circleBtn

local circleText = Instance.new("TextLabel")
circleText.Size = UDim2.new(1, 0, 1, 0)
circleText.BackgroundTransparency = 1
circleText.Text = "○"
circleText.TextColor3 = Color3.fromRGB(255, 255, 255)
circleText.Font = Enum.Font.GothamBold
circleText.TextSize = 12
circleText.Parent = circleBtn

-- Update function now also sets circle button color
local function updateGui()
    if destroyed then return end
    if not state.gui or not state.gui.Parent then return end
    if state.running then
        status.Text = "ON"
        status.TextColor3 = Color3.fromRGB(120, 230, 120)
        circleBtn.BackgroundColor3 = Color3.fromRGB(120, 230, 120)
    else
        status.Text = "OFF"
        status.TextColor3 = Color3.fromRGB(255, 90, 90)
        circleBtn.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
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
