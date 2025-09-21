-- custom_library.lua
-- UI (aparência baseada na sua primeira UI) + API compatível com a library original do Alora
-- Retorna: library, menu, tabholder

-- Services
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

-- Root player references (para algumas features que o script Alora pode usar)
local localPlayer = Players.LocalPlayer

-- Library table
local library = {
    flags = {},
    options = {},   -- cada flag terá .type e .changeState, e possivelmente .refresh (para lists)
    libColor = Color3.fromRGB(100,60,80),
    Open = true,
    notifyQueue = {},
    notifyPlaying = false
}

-- Theme (mantendo aparência da primeira UI)
local MAIN_BG_COLOR = Color3.fromRGB(25, 25, 30)
local SIDEBAR_BG_COLOR = Color3.fromRGB(35, 35, 40)
local BORDER_COLOR = Color3.fromRGB(0, 140, 255)
local BORDER_TRANSPARENCY = 0.2
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local INACTIVE_TEXT_COLOR = Color3.fromRGB(150, 150, 150)
local BUTTON_HOVER_COLOR = Color3.fromRGB(45, 45, 50)
local BUTTON_ACTIVE_COLOR = Color3.fromRGB(0, 140, 255)
local CORNER_RADIUS = UDim.new(0, 8)

-- Blur effect (como seu UI original)
if Lighting:FindFirstChild("AloraBlur") then
    Lighting.AloraBlur:Destroy()
end
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "AloraBlur"
blurEffect.Size = 10
blurEffect.Parent = Lighting

-- Criar ScreenGui principal (nome "sjorlib" para compatibilidade com checks do script)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "sjorlib"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

-- Sombrinha (shadow)
local shadowFrame = Instance.new("Frame")
shadowFrame.Name = "ShadowFrame"
shadowFrame.Parent = screenGui
shadowFrame.BackgroundColor3 = Color3.new(0,0,0)
shadowFrame.BackgroundTransparency = 0.7
shadowFrame.Position = UDim2.new(0.5, -260 + 5, 0.5, -210 + 5)
shadowFrame.Size = UDim2.new(0, 520, 0, 420)
local shadowCorner = Instance.new("UICorner", shadowFrame)
shadowCorner.CornerRadius = CORNER_RADIUS

-- Janela principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = MAIN_BG_COLOR
mainFrame.Size = UDim2.new(0, 520, 0, 420)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = CORNER_RADIUS

local glow = Instance.new("UIStroke")
glow.Name = "Glow"
glow.Parent = mainFrame
glow.Color = BORDER_COLOR
glow.Thickness = 2
glow.Transparency = BORDER_TRANSPARENCY

-- TitleBar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(20,20,25)
titleBar.Size = UDim2.new(1,0,0,35)
local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = CORNER_RADIUS

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = titleBar
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Alora v1.2"
titleLabel.TextColor3 = TEXT_COLOR
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Parent = titleBar
closeButton.Size = UDim2.new(0,35,1,0)
closeButton.Position = UDim2.new(1,-35,0,0)
closeButton.BackgroundTransparency = 1
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = TEXT_COLOR
closeButton.TextSize = 16

closeButton.MouseButton1Click:Connect(function()
    library.Open = false
    screenGui.Enabled = false
    blurEffect.Enabled = false
end)

-- Sidebar
local sideBar = Instance.new("Frame")
sideBar.Name = "SideBar"
sideBar.Parent = mainFrame
sideBar.BackgroundColor3 = SIDEBAR_BG_COLOR
sideBar.Position = UDim2.new(0, 0, 0, 35)
sideBar.Size = UDim2.new(0, 150, 1, -35)
local sideBarCorner = Instance.new("UICorner", sideBar)
sideBarCorner.CornerRadius = CORNER_RADIUS

local sideList = Instance.new("UIListLayout", sideBar)
sideList.SortOrder = Enum.SortOrder.LayoutOrder
sideList.Padding = UDim.new(0,5)
local sidePadding = Instance.new("UIPadding", sideBar)
sidePadding.PaddingTop = UDim.new(0,5)

-- Content area (tab pages)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Parent = mainFrame
contentFrame.BackgroundTransparency = 1
contentFrame.Position = UDim2.new(0, 150, 0, 35)
contentFrame.Size = UDim2.new(1, -150, 1, -35)

-- Dragging behavior for main window (move shadow too)
do
    local dragging, dragStart, startPos, shadowStart = false, nil, nil, nil
    local dragInput = nil
    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        mainFrame.Position = newPos
        shadowFrame.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset + 5, newPos.Y.Scale, newPos.Y.Offset + 5)
    end
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inp.Position
            startPos = mainFrame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp == dragInput and dragging then update(inp) end
    end)
end

-- Toggle UI with Insert
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.Insert and not processed then
        library.Open = not library.Open
        screenGui.Enabled = library.Open
        blurEffect.Enabled = library.Open
        if library.Open then
            UserInputService.MouseIconEnabled = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        else
            UserInputService.MouseIconEnabled = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    end
end)

-- store tabs container for Alora script compatibility
local tabholder = contentFrame

-- Keep internal tabs table
local tabs = {}

-- Utility helpers
local function makeUICorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or CORNER_RADIUS
    c.Parent = parent
    return c
end

local function makeLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = TEXT_COLOR
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Size = UDim2.new(1, -10, 0, 20)
    return label
end

-- Notification (simple)
local notifyLabel = Instance.new("TextLabel")
notifyLabel.Parent = mainFrame
notifyLabel.BackgroundTransparency = 0.6
notifyLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
notifyLabel.Size = UDim2.new(0, 250, 0, 22)
notifyLabel.Position = UDim2.new(0, 10, 0, 10)
notifyLabel.Font = Enum.Font.Gotham
notifyLabel.TextColor3 = Color3.fromRGB(255,255,255)
notifyLabel.TextSize = 14
notifyLabel.Visible = false
makeUICorner(notifyLabel, UDim.new(0,6))

function library:notify(text)
    if not text then return end
    if library.notifyPlaying then
        table.insert(library.notifyQueue, text)
        return
    end
    library.notifyPlaying = true
    notifyLabel.Text = text
    notifyLabel.Visible = true
    notifyLabel.TextTransparency = 1
    -- simple tween in/out
    spawn(function()
        for i=1,10 do
            notifyLabel.TextTransparency = 1 - i/10
            wait(0.02)
        end
        wait(2)
        for i=1,10 do
            notifyLabel.TextTransparency = i/10
            wait(0.02)
        end
        notifyLabel.Visible = false
        library.notifyPlaying = false
        if #library.notifyQueue > 0 then
            local nextText = table.remove(library.notifyQueue, 1)
            library:notify(nextText)
        end
    end)
end

-- Add Tab function (API compatível)
function library:addTab(name)
    -- create button
    local tabButton = Instance.new("TextButton")
    tabButton.Parent = sideBar
    tabButton.BackgroundColor3 = SIDEBAR_BG_COLOR
    tabButton.Size = UDim2.new(0.9, 0, 0, 32)
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.Text = name
    tabButton.TextColor3 = INACTIVE_TEXT_COLOR
    tabButton.TextSize = 14
    makeUICorner(tabButton, UDim.new(0,4))

    -- create page (scrolling frame)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Parent = contentFrame
    page.BackgroundColor3 = SIDEBAR_BG_COLOR
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BorderSizePixel = 0
    page.Visible = false
    page.ScrollBarThickness = 6

    local pageLayout = Instance.new("UIListLayout", page)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 8)
    local pagePadding = Instance.new("UIPadding", page)
    pagePadding.PaddingTop = UDim.new(0,8)
    pagePadding.PaddingLeft = UDim.new(0,8)
    pagePadding.PaddingRight = UDim.new(0,8)

    local tabObj = {button = tabButton, page = page}

    -- activation logic
    tabButton.MouseButton1Click:Connect(function()
        for k,v in pairs(tabs) do
            v.button.TextColor3 = INACTIVE_TEXT_COLOR
            v.button.BackgroundColor3 = SIDEBAR_BG_COLOR
            v.page.Visible = false
        end
        tabButton.TextColor3 = TEXT_COLOR
        tabButton.BackgroundColor3 = BUTTON_ACTIVE_COLOR
        page.Visible = true
    end)

    -- hover effects
    tabButton.MouseEnter:Connect(function()
        if tabButton.TextColor3 ~= TEXT_COLOR then
            tabButton.BackgroundColor3 = BUTTON_HOVER_COLOR
        end
    end)
    tabButton.MouseLeave:Connect(function()
        if tabButton.TextColor3 ~= TEXT_COLOR then
            tabButton.BackgroundColor3 = SIDEBAR_BG_COLOR
        end
    end)

    -- createGroup method
    function tabObj:createGroup(layoutOrder)
        local groupFrame = Instance.new("Frame")
        groupFrame.Parent = page
        groupFrame.BackgroundColor3 = SIDEBAR_BG_COLOR
        groupFrame.BorderSizePixel = 0
        groupFrame.AutomaticSize = Enum.AutomaticSize.Y
        groupFrame.LayoutOrder = layoutOrder or 0
        makeUICorner(groupFrame, UDim.new(0,6))

        local groupPadding = Instance.new("UIPadding", groupFrame)
        groupPadding.PaddingTop = UDim.new(0,6)
        groupPadding.PaddingLeft = UDim.new(0,6)
        groupPadding.PaddingRight = UDim.new(0,6)
        groupPadding.PaddingBottom = UDim.new(0,6)

        local groupList = Instance.new("UIListLayout", groupFrame)
        groupList.SortOrder = Enum.SortOrder.LayoutOrder
        groupList.Padding = UDim.new(0,6)

        local group = {}

        -- addToggle
        function group:addToggle(config)
            config = config or {}
            local flag = config.flag or config.text
            if not flag then return warn("addToggle requires flag/text") end
            library.flags[flag] = config.value or false

            local container = Instance.new("Frame")
            container.Parent = groupFrame
            container.BackgroundTransparency = 1
            container.Size = UDim2.new(1, 0, 0, 26)
            container.LayoutOrder = config.LayoutOrder or 0

            local btn = Instance.new("TextButton")
            btn.Parent = container
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1,0,1,0)
            btn.Text = ""
            btn.AutoButtonColor = false

            local checkbox = Instance.new("Frame")
            checkbox.Parent = btn
            checkbox.Size = UDim2.new(0, 18, 0, 18)
            checkbox.Position = UDim2.new(0, 6, 0.5, -9)
            checkbox.BackgroundColor3 = library.flags[flag] and library.libColor or Color3.fromRGB(40,40,45)
            makeUICorner(checkbox, UDim.new(0,4))

            local label = makeLabel(btn, config.text or flag)
            label.Position = UDim2.new(0, 32, 0.5, -10)

            local function update(v)
                library.flags[flag] = v
                checkbox.BackgroundColor3 = v and library.libColor or Color3.fromRGB(40,40,45)
                if config.callback then
                    pcall(config.callback, v)
                end
            end

            btn.MouseButton1Click:Connect(function()
                update(not library.flags[flag])
            end)

            library.options[flag] = { type = "toggle", changeState = update, skipflag = config.skipflag, oldargs = config }
            return btn
        end

        -- addButton
        function group:addButton(config)
            config = config or {}
            if not config.text or not config.callback then return warn("addButton requires text and callback") end
            local btn = Instance.new("TextButton")
            btn.Parent = groupFrame
            btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
            btn.Size = UDim2.new(1, -10, 0, 26)
            btn.LayoutOrder = config.LayoutOrder or 0
            btn.Text = config.text
            btn.Font = Enum.Font.GothamBold
            btn.TextColor3 = TEXT_COLOR
            makeUICorner(btn, UDim.new(0,4))
            btn.MouseButton1Click:Connect(function()
                pcall(config.callback)
            end)
            return btn
        end

        -- addSlider
        function group:addSlider(config)
            config = config or {}
            local flag = config.flag
            if not flag or config.min == nil or config.max == nil then return warn("addSlider requires flag,min,max") end
            library.flags[flag] = config.value or config.min

            local frame = Instance.new("Frame")
            frame.Parent = groupFrame
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.new(1, -10, 0, 44)
            frame.LayoutOrder = config.LayoutOrder or 0

            local label = makeLabel(frame, (config.text or flag) .. ": " .. tostring(library.flags[flag]))
            label.Position = UDim2.new(0,0,0,0)

            local barBG = Instance.new("Frame")
            barBG.Parent = frame
            barBG.BackgroundColor3 = Color3.fromRGB(40,40,45)
            barBG.Position = UDim2.new(0,0,0,20)
            barBG.Size = UDim2.new(1, 0, 0, 10)
            makeUICorner(barBG, UDim.new(1,0))

            local barFill = Instance.new("Frame")
            barFill.Parent = barBG
            barFill.BackgroundColor3 = library.libColor
            barFill.Size = UDim2.new( (library.flags[flag]-config.min) / (config.max-config.min) , 0, 1, 0)
            makeUICorner(barFill, UDim.new(1,0))

            local dragging = false
            barBG.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            RunService.RenderStepped:Connect(function()
                if dragging then
                    local x = math.clamp((UserInputService:GetMouseLocation().X - barBG.AbsolutePosition.X) / barBG.AbsoluteSize.X, 0, 1)
                    local value = config.min + x * (config.max - config.min)
                    if not config.precise then value = math.floor(value) end
                    library.flags[flag] = value
                    barFill.Size = UDim2.new(x, 0, 1, 0)
                    label.Text = (config.text or flag) .. ": " .. tostring(library.flags[flag])
                    if config.callback then pcall(config.callback, library.flags[flag]) end
                end
            end)

            library.options[flag] = { type = "slider", changeState = function(v)
                library.flags[flag] = v
                local x = (v - config.min) / (config.max - config.min)
                barFill.Size = UDim2.new(x,0,1,0)
                label.Text = (config.text or flag) .. ": " .. tostring(library.flags[flag])
            end, skipflag = config.skipflag, oldargs = config }
            -- initialize
            if config.value then
                library.options[flag].changeState(config.value)
            end
            return frame
        end

        -- addTextbox
        function group:addTextbox(config)
            config = config or {}
            local flag = config.flag
            if not flag then return warn("addTextbox requires flag") end
            local box = Instance.new("TextBox")
            box.Parent = groupFrame
            box.BackgroundColor3 = Color3.fromRGB(40,40,45)
            box.Size = UDim2.new(1,-10,0,26)
            box.LayoutOrder = config.LayoutOrder or 0
            box.ClearTextOnFocus = false
            box.Text = config.text or ""
            box.Font = Enum.Font.Gotham
            box.TextColor3 = TEXT_COLOR
            makeUICorner(box, UDim.new(0,4))

            box.FocusLost:Connect(function(enter)
                if enter then
                    library.flags[flag] = box.Text
                    if config.callback then pcall(config.callback, box.Text) end
                end
            end)
            library.flags[flag] = box.Text
            library.options[flag] = { type = "textbox", changeState = function(v) box.Text = v end, skipflag = config.skipflag, oldargs = config }
            return box
        end

        -- addKeybind (simple)
        function group:addKeybind(config)
            config = config or {}
            local flag = config.flag
            if not flag then return warn("addKeybind requires flag") end

            local btn = Instance.new("TextButton")
            btn.Parent = groupFrame
            btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
            btn.Size = UDim2.new(1,-10,0,26)
            btn.LayoutOrder = config.LayoutOrder or 0
            btn.Font = Enum.Font.Gotham
            btn.TextColor3 = TEXT_COLOR
            btn.Text = (config.text or flag) .. " [" .. (tostring(config.key and config.key.Name or "Unknown")) .. "]"
            makeUICorner(btn, UDim.new(0,4))

            library.flags[flag] = config.key or Enum.KeyCode.Unknown

            local listening = false
            local conn
            btn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                btn.Text = (config.text or flag) .. " [Press Key]"
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        library.flags[flag] = input.KeyCode
                        btn.Text = (config.text or flag) .. " [" .. tostring(input.KeyCode.Name) .. "]"
                        listening = false
                        if conn then conn:Disconnect() end
                        if config.callback then pcall(config.callback, library.flags[flag]) end
                    end
                end)
            end)

            library.options[flag] = { type = "keybind", changeState = function(v)
                library.flags[flag] = v
                btn.Text = (config.text or flag) .. " [" .. (tostring(v.Name or tostring(v))) .. "]"
            end, skipflag = config.skipflag, oldargs = config }
            return btn
        end

        -- addList (supports multiselect)
        function group:addList(config)
            config = config or {}
            local flag = config.flag
            if not flag or not config.values then return warn("addList requires flag and values") end

            library.flags[flag] = config.multiselect and (config.value or {}) or (config.value or config.values[1])

            local container = Instance.new("Frame")
            container.Parent = groupFrame
            container.BackgroundTransparency = 1
            container.Size = UDim2.new(1,-10,0,26)
            container.LayoutOrder = config.LayoutOrder or 0

            local button = Instance.new("TextButton")
            button.Parent = container
            button.BackgroundColor3 = Color3.fromRGB(40,40,45)
            button.Size = UDim2.new(1,0,1,0)
            button.AutoButtonColor = false
            button.Text = config.text or flag
            button.Font = Enum.Font.Gotham
            button.TextColor3 = TEXT_COLOR
            makeUICorner(button, UDim.new(0,4))

            local dropdown = Instance.new("ScrollingFrame")
            dropdown.Parent = button
            dropdown.BackgroundColor3 = SIDEBAR_BG_COLOR
            dropdown.Size = UDim2.new(1,0,0,#config.values * 22)
            dropdown.Position = UDim2.new(0,0,1,6)
            dropdown.Visible = false
            dropdown.AutomaticSize = Enum.AutomaticSize.Y
            dropdown.ZIndex = 1000
            local dl = Instance.new("UIListLayout", dropdown)
            dl.SortOrder = Enum.SortOrder.LayoutOrder

            local function buildList(values)
                for i,v in pairs(dropdown:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end
                for _, val in ipairs(values) do
                    local item = Instance.new("TextButton")
                    item.Parent = dropdown
                    item.BackgroundColor3 = SIDEBAR_BG_COLOR
                    item.Size = UDim2.new(1,0,0,22)
                    item.Text = val
                    item.Font = Enum.Font.Gotham
                    item.TextColor3 = Color3.fromRGB(165,165,165)
                    item.AutoButtonColor = false
                    item.MouseButton1Click:Connect(function()
                        if config.multiselect then
                            local found = false
                            for i,v in pairs(library.flags[flag]) do
                                if v == val then
                                    table.remove(library.flags[flag], i)
                                    found = true
                                    break
                                end
                            end
                            if not found then table.insert(library.flags[flag], val) end
                        else
                            library.flags[flag] = val
                        end
                        if config.callback then pcall(config.callback, library.flags[flag]) end
                    end)
                end
            end

            button.MouseButton1Click:Connect(function()
                dropdown.Visible = not dropdown.Visible
                if dropdown.Visible then buildList(config.values) end
            end)

            library.options[flag] = {
                type = "list",
                changeState = function(v) library.flags[flag] = v end,
                values = config.values,
                refresh = function(tbl)
                    config.values = tbl
                    if dropdown.Visible then buildList(tbl) end
                end,
                skipflag = config.skipflag,
                oldargs = config
            }
            -- initialize
            if config.values then buildList(config.values) end
            return button, dropdown
        end

        -- addColorpicker (simplified: R/G/B sliders)
        function group:addColorpicker(config)
            config = config or {}
            local flag = config.flag
            if not flag then return warn("addColorpicker requires flag") end

            local container = Instance.new("Frame")
            container.Parent = groupFrame
            container.BackgroundTransparency = 1
            container.Size = UDim2.new(1, -10, 0, 26)
            container.LayoutOrder = config.LayoutOrder or 0

            local btn = Instance.new("TextButton")
            btn.Parent = container
            btn.BackgroundColor3 = config.color or Color3.new(1,1,1)
            btn.Size = UDim2.new(0, 34, 0, 24)
            btn.Position = UDim2.new(0, 0, 0, 0)
            btn.AutoButtonColor = false
            makeUICorner(btn, UDim.new(0,4))

            local label = makeLabel(container, config.text or flag)
            label.Position = UDim2.new(0, 40, 0, 0)

            local popup = Instance.new("Frame")
            popup.Parent = container
            popup.BackgroundColor3 = SIDEBAR_BG_COLOR
            popup.Size = UDim2.new(0, 220, 0, 90)
            popup.Position = UDim2.new(0, 120, 0, 0)
            popup.Visible = false
            makeUICorner(popup, UDim.new(0,6))

            -- three sliders for R G B (0..255)
            local function createColorSlider(textStr, index, default)
                local f = Instance.new("Frame", popup)
                f.Size = UDim2.new(1, -10, 0, 24)
                f.Position = UDim2.new(0, 6, 0, (index-1)*28 + 6)
                f.BackgroundTransparency = 1

                local t = Instance.new("TextLabel", f)
                t.BackgroundTransparency = 1
                t.Size = UDim2.new(0.35,0,1,0)
                t.Text = textStr
                t.Font = Enum.Font.Gotham
                t.TextColor3 = TEXT_COLOR
                t.TextSize = 12
                t.TextXAlignment = Enum.TextXAlignment.Left

                local barBG = Instance.new("Frame", f)
                barBG.Size = UDim2.new(0.6, 0, 0.5, 0)
                barBG.Position = UDim2.new(0.38,0,0.25,0)
                barBG.BackgroundColor3 = Color3.fromRGB(40,40,45)
                makeUICorner(barBG, UDim.new(1,0))

                local fill = Instance.new("Frame", barBG)
                fill.Size = UDim2.new(default/255, 0, 1, 0)
                fill.BackgroundColor3 = library.libColor
                makeUICorner(fill, UDim.new(1,0))

                local dragging = false
                barBG.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                RunService.RenderStepped:Connect(function()
                    if dragging then
                        local pct = math.clamp((UserInputService:GetMouseLocation().X - barBG.AbsolutePosition.X) / barBG.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.new(pct,0,1,0)
                        return true, pct * 255
                    end
                end)

                return {
                    frame = f,
                    getValue = function()
                        return fill.Size.X.Scale * 255
                    end,
                    setValue = function(v)
                        fill.Size = UDim2.new((v/255),0,1,0)
                    end
                }
            end

            local rSlider = createColorSlider("R",1, (config.color and config.color.R*255) or 255)
            local gSlider = createColorSlider("G",2, (config.color and config.color.G*255) or 255)
            local bSlider = createColorSlider("B",3, (config.color and config.color.B*255) or 255)

            btn.MouseButton1Click:Connect(function()
                popup.Visible = not popup.Visible
            end)

            local function updateColor()
                local r = rSlider.getValue()
                local g = gSlider.getValue()
                local b = bSlider.getValue()
                local color = Color3.fromRGB(math.clamp(math.floor(r),0,255), math.clamp(math.floor(g),0,255), math.clamp(math.floor(b),0,255))
                btn.BackgroundColor3 = color
                library.flags[flag] = color
                if config.callback then pcall(config.callback, color) end
            end

            -- update periodically while popup visible
            spawn(function()
                while true do
                    wait(0.05)
                    if popup.Visible then updateColor() end
                end
            end)

            library.flags[flag] = config.color or Color3.fromRGB(255,255,255)
            library.options[flag] = { type = "colorpicker", changeState = function(v)
                if typeof(v) == "Color3" then
                    btn.BackgroundColor3 = v
                    library.flags[flag] = v
                    rSlider.setValue(v.R*255); gSlider.setValue(v.G*255); bSlider.setValue(v.B*255)
                end
            end, skipflag = config.skipflag, oldargs = config }

            -- initialize
            library.options[flag].changeState(library.flags[flag])
            return btn
        end

        -- addDivider
        function group:addDivider()
            local div = Instance.new("Frame")
            div.Parent = groupFrame
            div.BackgroundColor3 = Color3.fromRGB(30,30,30)
            div.Size = UDim2.new(1,-10,0,1)
            div.LayoutOrder = 9999
            return div
        end

        return group, groupFrame
    end

    tabs[name] = tabObj
    return tabObj
end

-- Config management (save/load/delete/refresh)
function library:refreshConfigs()
    local cfgs = {}
    local success, files = pcall(function()
        if isfolder and isfolder("alora/"..tostring(game.GameId)) then
            return listfiles and listfiles("alora/"..tostring(game.GameId)) or {}
        else
            return {}
        end
    end)
    if success and files then
        for _, path in ipairs(files) do
            local parts = string.split(path, "/")
            local fname = parts[#parts]
            fname = fname:gsub("%.cfg$", "")
            table.insert(cfgs, fname)
        end
    end
    -- if there's an option registered for "selected_config", call its refresh
    local opt = library.options["selected_config"]
    if opt and opt.refresh then
        pcall(opt.refresh, cfgs)
    end
    return cfgs
end

function library:saveConfig(name)
    local cfgName = name or library.flags["config_name"] or library.flags["selected_config"]
    if not cfgName or cfgName == "" then library:notify("No config name set") return end

    if not isfolder then
        pcall(function() writefile("alora/"..tostring(game.GameId).."/"..cfgName..".cfg", HttpService:JSONEncode({})) end)
        library:notify("Save API not available in this executor")
        return
    end

    if not isfolder("alora") then pcall(makefolder, "alora") end
    if not isfolder("alora/"..tostring(game.GameId)) then pcall(makefolder, "alora/"..tostring(game.GameId)) end

    local out = {}
    for k,v in pairs(library.flags) do
        local opt = library.options[k]
        if opt and opt.skipflag then continue end
        if typeof(v) == "Color3" then
            out[k] = { "Color3", v.R, v.G, v.B }
        elseif typeof(v) == "EnumItem" then
            local enumType = tostring(v):match("Enum%.(.+)")
            local enumName = tostring(v):match("%.(.+)")
            out[k] = { "EnumItem", enumType, enumName }
        else
            out[k] = v
        end
    end
    pcall(function() writefile("alora/"..tostring(game.GameId).."/"..cfgName..".cfg", HttpService:JSONEncode(out)) end)
    library:notify("Saved config: "..cfgName)
    library:refreshConfigs()
end

function library:loadConfig(name)
    local cfgName = name or library.flags["selected_config"]
    if not cfgName or cfgName == "" then library:notify("No config selected") return end
    if not isfile then
        library:notify("Load API not available in this executor")
        return
    end
    local path = "alora/"..tostring(game.GameId).."/"..cfgName..".cfg"
    if not isfile(path) then library:notify("Config not found: "..cfgName) return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok or not data then library:notify("Failed to read config") return end

    for k, v in pairs(data) do
        local opt = library.options[k]
        if opt and opt.changeState then
            if type(v) == "table" and v[1] == "Color3" then
                local c = Color3.new(v[2], v[3], v[4])
                pcall(opt.changeState, c)
            elseif type(v) == "table" and v[1] == "EnumItem" then
                local enumType, enumName = v[2], v[3]
                local enumItem = Enum[enumType] and Enum[enumType][enumName] or nil
                pcall(opt.changeState, enumItem)
            else
                pcall(opt.changeState, v)
            end
        else
            -- store anyway
            library.flags[k] = v
        end
    end
    library:notify("Loaded config: "..cfgName)
end

function library:deleteConfig(name)
    local cfgName = name or library.flags["selected_config"]
    if not cfgName or cfgName == "" then library:notify("No config selected") return end
    if not isfile then
        library:notify("Delete API not available in this executor")
        return
    end
    local path = "alora/"..tostring(game.GameId).."/"..cfgName..".cfg"
    if isfile(path) then
        pcall(function() delfile(path) end)
        library:notify("Deleted config: "..cfgName)
        library:refreshConfigs()
    else
        library:notify("Config not found: "..cfgName)
    end
end

-- Final returned values:
-- library (table), menu (the ScreenGui), tabholder (contentFrame)
return library, screenGui, contentFrame
