-- libraryteste.lua (CORRIGIDA: abas, dropdown flutuante, layout full-width)
-- Retorna: library, menu (ScreenGui), tabholder (Frame)

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer

local library = {
    flags = {},
    options = {},
    libColor = Color3.fromRGB(0,140,255),
    Open = true,
    _dropdowns = {} -- track overlays to close when switching tabs
}

-- Theme
local MAIN_BG_COLOR    = Color3.fromRGB(25,25,30)
local SIDEBAR_BG_COLOR = Color3.fromRGB(35,35,40)
local ELEM_BG_COLOR    = Color3.fromRGB(40,40,46)
local BORDER_COLOR     = Color3.fromRGB(0,140,255)
local BORDER_TRANSP    = 0.2
local TEXT_COLOR       = Color3.fromRGB(255,255,255)
local TEXT_MUTED       = Color3.fromRGB(170,170,170)
local HOVER_COLOR      = Color3.fromRGB(50,50,56)
local CORNER_RADIUS    = UDim.new(0,8)

-- Cleanup old gui & blur
pcall(function() if CoreGui:FindFirstChild("sjorlib") then CoreGui.sjorlib:Destroy() end end)
pcall(function() if Lighting:FindFirstChild("AloraBlur") then Lighting.AloraBlur:Destroy() end end)

-- Blur
local blur = Instance.new("BlurEffect")
blur.Name = "AloraBlur"
blur.Size = 10
blur.Parent = Lighting

-- ScreenGui (must be sjorlib for Alora script check)
local menu = Instance.new("ScreenGui")
menu.Name = "sjorlib"
menu.Parent = CoreGui
menu.ResetOnSpawn = false
menu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
menu.Enabled = true

-- Shadow
local shadow = Instance.new("Frame", menu)
shadow.Name = "ShadowFrame"
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = 0.7
shadow.Size = UDim2.new(0, 720, 0, 460)
shadow.Position = UDim2.new(0.5, -360 + 6, 0.5, -230 + 6)
local shc = Instance.new("UICorner", shadow); shc.CornerRadius = CORNER_RADIUS

-- Main window
local main = Instance.new("Frame", menu)
main.Name = "MainFrame"
main.BackgroundColor3 = MAIN_BG_COLOR
main.Size = UDim2.new(0, 720, 0, 460)
main.Position = UDim2.new(0.5, -360, 0.5, -230)
local mc = Instance.new("UICorner", main); mc.CornerRadius = CORNER_RADIUS

local glow = Instance.new("UIStroke", main)
glow.Color = BORDER_COLOR
glow.Transparency = BORDER_TRANSP
glow.Thickness = 2

-- Titlebar
local titleBar = Instance.new("Frame", main)
titleBar.Name = "TitleBar"
titleBar.BackgroundColor3 = Color3.fromRGB(20,20,25)
titleBar.Size = UDim2.new(1,0,0,38)
local tc = Instance.new("UICorner", titleBar); tc.CornerRadius = CORNER_RADIUS

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 16, 0, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Alora v1.2"
titleLabel.TextColor3 = TEXT_COLOR
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,44,1,0)
closeBtn.Position = UDim2.new(1,-44,0,0)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.TextColor3 = TEXT_COLOR
closeBtn.TextSize = 16
closeBtn.AutoButtonColor = false
closeBtn.MouseButton1Click:Connect(function()
    library.Open = false
    menu.Enabled = false
    blur.Enabled = false
end)

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Name = "SideBar"
sidebar.BackgroundColor3 = SIDEBAR_BG_COLOR
sidebar.Size = UDim2.new(0, 180, 1, -38)
sidebar.Position = UDim2.new(0, 0, 0, 38)
local sc2 = Instance.new("UICorner", sidebar); sc2.CornerRadius = CORNER_RADIUS
local sideList = Instance.new("UIListLayout", sidebar)
sideList.Padding = UDim.new(0,8)
sideList.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0,8)

-- Tabholder (content pages)
local tabholder = Instance.new("Frame", main)
tabholder.Name = "ContentFrame"
tabholder.BackgroundTransparency = 1
tabholder.Size = UDim2.new(1, -180, 1, -38)
tabholder.Position = UDim2.new(0, 180, 0, 38)

-- dragging
do
    local dragging = false; local dragStart; local startPos; local dragInput
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then dragInput = i end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i == dragInput then
            local delta = i.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            main.Position = newPos
            shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset + 6, newPos.Y.Scale, newPos.Y.Offset + 6)
        end
    end)
end

-- toggle with Insert
UserInputService.InputBegan:Connect(function(inp, g)
    if not g and inp.KeyCode == Enum.KeyCode.Insert then
        library.Open = not library.Open
        menu.Enabled = library.Open
        blur.Enabled = library.Open
        if library.Open then
            UserInputService.MouseIconEnabled = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        else
            UserInputService.MouseIconEnabled = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    end
end)

-- helpers
local function mkCorner(p, r) local c = Instance.new("UICorner", p); c.CornerRadius = r or CORNER_RADIUS; return c end
local function mkLabel(p, txt, size)
    local l = Instance.new("TextLabel", p)
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, -10, 0, 20)
    l.Font = Enum.Font.Gotham
    l.TextSize = size or 15
    l.TextColor3 = TEXT_COLOR
    l.Text = txt or ""
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

-- toast
local toast = Instance.new("TextLabel", main)
toast.BackgroundColor3 = Color3.fromRGB(0,0,0)
toast.BackgroundTransparency = 0.35
toast.Position = UDim2.new(0, 12, 0, 8)
toast.Size = UDim2.new(0, 320, 0, 26)
toast.Font = Enum.Font.Gotham
toast.TextColor3 = TEXT_COLOR
toast.TextSize = 14
toast.TextXAlignment = Enum.TextXAlignment.Left
toast.Visible = false
mkCorner(toast, UDim.new(0,6))

function library:notify(txt)
    if not txt then return end
    toast.Text = "  "..tostring(txt)
    toast.Visible = true
    toast.TextTransparency = 1
    for i=0,1,0.1 do toast.TextTransparency = 1-i; task.wait(0.02) end
    task.wait(2)
    for i=0,1,0.1 do toast.TextTransparency = i; task.wait(0.02) end
    toast.Visible = false
end

-- tabs storage
local tabList = {}

-- close all dropdowns helper
local function closeAllDropdowns()
    for _,d in ipairs(library._dropdowns) do
        if d and d.gui then d.gui.Visible = false end
        if d and d.runner then pcall(function() d.runner:Disconnect() end) end
    end
    library._dropdowns = {}
end

-- Add Tab
function library:addTab(name)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -12, 0, 40)
    btn.BackgroundColor3 = SIDEBAR_BG_COLOR
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.TextColor3 = TEXT_MUTED
    btn.AutoButtonColor = false
    mkCorner(btn, UDim.new(0,6))

    local page = Instance.new("ScrollingFrame", tabholder)
    page.Name = name.."Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 8
    page.Visible = false
    page.BorderSizePixel = 0
    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0,10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    local pPad = Instance.new("UIPadding", page)
    pPad.PaddingTop = UDim.new(0,10)
    pPad.PaddingLeft = UDim.new(0,10)
    pPad.PaddingRight = UDim.new(0,10)
    local function refreshCanvas()
        page.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y + 12)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas)
    page.ChildAdded:Connect(refreshCanvas)
    page.ChildRemoved:Connect(refreshCanvas)

    local tabObj = { button = btn, page = page }

    local function activate()
        closeAllDropdowns()
        for _,t in ipairs(tabList) do
            t.button.BackgroundColor3 = SIDEBAR_BG_COLOR
            t.button.TextColor3 = TEXT_MUTED
            t.page.Visible = false
        end
        btn.BackgroundColor3 = library.libColor
        btn.TextColor3 = TEXT_COLOR
        page.Visible = true
    end
    btn.MouseButton1Click:Connect(activate)
    btn.MouseEnter:Connect(function() if btn.TextColor3 ~= TEXT_COLOR then btn.BackgroundColor3 = HOVER_COLOR end end)
    btn.MouseLeave:Connect(function() if btn.TextColor3 ~= TEXT_COLOR then btn.BackgroundColor3 = SIDEBAR_BG_COLOR end end)

    table.insert(tabList, tabObj)
    if #tabList == 1 then activate() end

    -- createGroup
    function tabObj:createGroup(order)
        local groupFrame = Instance.new("Frame", page)
        groupFrame.BackgroundColor3 = SIDEBAR_BG_COLOR
        groupFrame.BorderSizePixel = 0
        groupFrame.AutomaticSize = Enum.AutomaticSize.Y
        groupFrame.Size = UDim2.new(1, 0, 0, 0)
        groupFrame.LayoutOrder = order or 0
        mkCorner(groupFrame, UDim.new(0,6))

        local gpPad = Instance.new("UIPadding", groupFrame)
        gpPad.PaddingTop = UDim.new(0,8); gpPad.PaddingBottom = UDim.new(0,8)
        gpPad.PaddingLeft = UDim.new(0,8); gpPad.PaddingRight = UDim.new(0,8)

        local gList = Instance.new("UIListLayout", groupFrame)
        gList.Padding = UDim.new(0,8)
        gList.SortOrder = Enum.SortOrder.LayoutOrder

        local group = {}

        -- Toggle
        function group:addToggle(cfg)
            cfg = cfg or {}
            local flag = cfg.flag or cfg.text
            assert(flag, "addToggle requires flag/text")
            library.flags[flag] = cfg.value or false

            local row = Instance.new("Frame", groupFrame)
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1,0,0,40)
            row.LayoutOrder = cfg.LayoutOrder or 0

            local btn = Instance.new("TextButton", row)
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1,0,1,0)
            btn.Text = ""
            btn.AutoButtonColor = false

            local box = Instance.new("Frame", btn)
            box.Size = UDim2.new(0,20,0,20)
            box.Position = UDim2.new(0,6,0.5,-10)
            box.BackgroundColor3 = library.flags[flag] and library.libColor or ELEM_BG_COLOR
            mkCorner(box, UDim.new(0,4))

            local lbl = mkLabel(btn, cfg.text or flag, 15)
            lbl.Position = UDim2.new(0, 32, 0.5, -10)

            local function set(v)
                library.flags[flag] = v
                box.BackgroundColor3 = v and library.libColor or ELEM_BG_COLOR
                if cfg.callback then pcall(cfg.callback, v) end
            end

            btn.MouseButton1Click:Connect(function() set(not library.flags[flag]) end)
            library.options[flag] = { type="toggle", changeState=set, skipflag=cfg.skipflag, oldargs=cfg }
            return btn
        end

        -- Button
        function group:addButton(cfg)
            cfg = cfg or {}
            local b = Instance.new("TextButton", groupFrame)
            b.BackgroundColor3 = ELEM_BG_COLOR
            b.Size = UDim2.new(1,0,0,36)
            b.LayoutOrder = cfg.LayoutOrder or 0
            b.Text = cfg.text or "Button"
            b.Font = Enum.Font.GothamBold
            b.TextSize = 15
            b.TextColor3 = TEXT_COLOR
            b.AutoButtonColor = false
            mkCorner(b, UDim.new(0,6))
            b.MouseButton1Click:Connect(function() if cfg.callback then pcall(cfg.callback) end end)
            return b
        end

        -- Slider
        function group:addSlider(cfg)
            cfg = cfg or {}
            assert(cfg.flag and cfg.min and cfg.max, "addSlider requires flag/min/max")
            library.flags[cfg.flag] = cfg.value or cfg.min

            local frame = Instance.new("Frame", groupFrame)
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.new(1,0,0,52)
            frame.LayoutOrder = cfg.LayoutOrder or 0

            local lbl = mkLabel(frame, (cfg.text or cfg.flag)..": "..tostring(library.flags[cfg.flag]), 14)
            lbl.Position = UDim2.new(0,0,0,0)

            local barBG = Instance.new("Frame", frame)
            barBG.BackgroundColor3 = ELEM_BG_COLOR
            barBG.Size = UDim2.new(1,0,0,12)
            barBG.Position = UDim2.new(0,0,0,34)
            mkCorner(barBG, UDim.new(1,0))

            local fill = Instance.new("Frame", barBG)
            fill.BackgroundColor3 = library.libColor
            fill.Size = UDim2.new((library.flags[cfg.flag]-cfg.min)/(cfg.max-cfg.min),0,1,0)
            mkCorner(fill, UDim.new(1,0))

            local dragging = false
            barBG.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
            RunService.RenderStepped:Connect(function()
                if dragging then
                    local pct = math.clamp((UserInputService:GetMouseLocation().X - barBG.AbsolutePosition.X)/barBG.AbsoluteSize.X, 0, 1)
                    local value = cfg.min + pct*(cfg.max - cfg.min)
                    if not cfg.precise then value = math.floor(value) end
                    library.flags[cfg.flag] = value
                    fill.Size = UDim2.new(pct,0,1,0)
                    lbl.Text = (cfg.text or cfg.flag)..": "..tostring(library.flags[cfg.flag])
                    if cfg.callback then pcall(cfg.callback, library.flags[cfg.flag]) end
                end
            end)

            library.options[cfg.flag] = { type="slider", changeState=function(v) library.flags[cfg.flag]=v; fill.Size = UDim2.new((v-cfg.min)/(cfg.max-cfg.min),0,1,0); lbl.Text = (cfg.text or cfg.flag)..": "..tostring(v) end, skipflag=cfg.skipflag, oldargs=cfg}
            if cfg.value then library.options[cfg.flag].changeState(cfg.value) end
            return frame
        end

        -- Textbox
        function group:addTextbox(cfg)
            cfg = cfg or {}
            assert(cfg.flag, "addTextbox requires flag")
            local tb = Instance.new("TextBox", groupFrame)
            tb.BackgroundColor3 = ELEM_BG_COLOR
            tb.Size = UDim2.new(1,0,0,36)
            tb.LayoutOrder = cfg.LayoutOrder or 0
            tb.Text = cfg.text or ""
            tb.Font = Enum.Font.Gotham
            tb.TextSize = 15
            tb.TextColor3 = TEXT_COLOR
            tb.ClearTextOnFocus = false
            mkCorner(tb, UDim.new(0,6))
            tb.FocusLost:Connect(function(enter)
                if enter then
                    library.flags[cfg.flag] = tb.Text
                    if cfg.callback then pcall(cfg.callback, tb.Text) end
                end
            end)
            library.flags[cfg.flag] = tb.Text
            library.options[cfg.flag] = { type="textbox", changeState=function(v) tb.Text = v end, skipflag=cfg.skipflag, oldargs=cfg}
            return tb
        end

        -- Keybind
        function group:addKeybind(cfg)
            cfg = cfg or {}
            assert(cfg.flag, "addKeybind requires flag")
            library.flags[cfg.flag] = cfg.key or Enum.KeyCode.Unknown

            local b = Instance.new("TextButton", groupFrame)
            b.BackgroundColor3 = ELEM_BG_COLOR
            b.Size = UDim2.new(1,0,0,36)
            b.LayoutOrder = cfg.LayoutOrder or 0
            b.Font = Enum.Font.Gotham
            b.TextSize = 15
            b.TextColor3 = TEXT_COLOR
            mkCorner(b, UDim.new(0,6))

            local function updateText()
                local k = library.flags[cfg.flag]
                local name = (k and k.Name) or tostring(k)
                b.Text = (cfg.text or cfg.flag).." ["..name.."]"
            end
            updateText()

            local listening=false; local con
            b.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                b.Text = (cfg.text or cfg.flag).." [press key]"
                con = UserInputService.InputBegan:Connect(function(i, g)
                    if not g and i.UserInputType == Enum.UserInputType.Keyboard then
                        library.flags[cfg.flag] = i.KeyCode
                        updateText()
                        listening = false
                        if con then con:Disconnect() end
                        if cfg.callback then pcall(cfg.callback, library.flags[cfg.flag]) end
                    end
                end)
            end)

            library.options[cfg.flag] = { type="keybind", changeState=function(v) library.flags[cfg.flag]=v; updateText() end, skipflag=cfg.skipflag, oldargs=cfg}
            return b
        end

        -- LIST (floating dropdown overlay)
        function group:addList(cfg)
            cfg = cfg or {}
            assert(cfg.flag and cfg.values, "addList requires flag and values")
            local multi = cfg.multiselect
            library.flags[cfg.flag] = multi and (cfg.value or {}) or (cfg.value or cfg.values[1])

            local holder = Instance.new("Frame", groupFrame)
            holder.BackgroundTransparency = 1
            holder.Size = UDim2.new(1,0,0,36)
            holder.LayoutOrder = cfg.LayoutOrder or 0

            local btn = Instance.new("TextButton", holder)
            btn.BackgroundColor3 = ELEM_BG_COLOR
            btn.Size = UDim2.new(1,0,1,0)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 15
            btn.TextColor3 = TEXT_COLOR
            btn.Text = cfg.text or cfg.flag
            btn.AutoButtonColor = false
            mkCorner(btn, UDim.new(0,6))

            -- Create floating overlay (parent menu)
            local overlay = Instance.new("Frame", menu)
            overlay.BackgroundColor3 = SIDEBAR_BG_COLOR
            overlay.Size = UDim2.new(0, 300, 0, 0)
            overlay.Visible = false
            overlay.ClipsDescendants = true
            overlay.ZIndex = 10000
            mkCorner(overlay, UDim.new(0,6))
            local overlayList = Instance.new("UIListLayout", overlay)
            overlayList.Padding = UDim.new(0,0)
            overlayList.SortOrder = Enum.SortOrder.LayoutOrder
            overlay.AutomaticSize = Enum.AutomaticSize.Y

            local runnerConn
            local function updateOverlayPos()
                local absPos = btn.AbsolutePosition
                local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800,600)
                local x = absPos.X
                local y = absPos.Y + btn.AbsoluteSize.Y + 6
                -- adjust if overflow right
                local width = overlay.AbsoluteSize.X
                if (x + 320) > viewport.X then x = math.max(6, viewport.X - 320 - 6) end
                overlay.Position = UDim2.new(0, x, 0, y)
            end

            local function build(vals)
                for _,c in pairs(overlay:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for _,v in ipairs(vals) do
                    local it = Instance.new("TextButton", overlay)
                    it.Size = UDim2.new(1,0,0,28)
                    it.BackgroundColor3 = SIDEBAR_BG_COLOR
                    it.Text = v
                    it.Font = Enum.Font.Gotham
                    it.TextSize = 14
                    it.TextColor3 = TEXT_MUTED
                    it.AutoButtonColor = false
                    it.LayoutOrder = 0
                    it.MouseButton1Click:Connect(function()
                        if multi then
                            local list = library.flags[cfg.flag]
                            local idx = table.find(list, v)
                            if idx then table.remove(list, idx) else table.insert(list, v) end
                            if cfg.callback then pcall(cfg.callback, list) end
                        else
                            library.flags[cfg.flag] = v
                            if cfg.callback then pcall(cfg.callback, v) end
                            overlay.Visible = false
                        end
                    end)
                end
            end

            btn.MouseButton1Click:Connect(function()
                -- close others
                for _,d in ipairs(library._dropdowns) do if d and d.gui then d.gui.Visible = false; if d.runner then d.runner:Disconnect() end end end
                library._dropdowns = {}

                build(cfg.values)
                updateOverlayPos()
                overlay.Visible = not overlay.Visible

                if overlay.Visible then
                    -- attach runner to update position while visible
                    runnerConn = RunService.RenderStepped:Connect(updateOverlayPos)
                    table.insert(library._dropdowns, {gui = overlay, runner = runnerConn})
                else
                    if runnerConn then runnerConn:Disconnect() end
                end
            end)

            -- close overlay when clicking outside
            local inputConn
            inputConn = UserInputService.InputBegan:Connect(function(input, processed)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local target = input.Target
                    if overlay.Visible then
                        local isDesc = false
                        if target then
                            local ins = target
                            while ins do
                                if ins == overlay or ins == btn then isDesc = true; break end
                                ins = ins.Parent
                            end
                        end
                        if not isDesc then
                            overlay.Visible = false
                            if runnerConn then pcall(function() runnerConn:Disconnect() end) end
                        end
                    end
                end
            end)

            library.options[cfg.flag] = { type="list", changeState=function(v) library.flags[cfg.flag]=v end, refresh=function(tbl) cfg.values = tbl; build(tbl) end, values=cfg.values, skipflag=cfg.skipflag, oldargs=cfg }

            return btn, overlay
        end

        -- addColorpicker (simple)
        function group:addColorpicker(cfg)
            cfg = cfg or {}
            assert(cfg.flag, "addColorpicker requires flag")
            library.flags[cfg.flag] = cfg.color or Color3.new(1,1,1)

            local row = Instance.new("Frame", groupFrame)
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1,0,0,36)
            row.LayoutOrder = cfg.LayoutOrder or 0

            local preview = Instance.new("TextButton", row)
            preview.Size = UDim2.new(0, 40, 0, 28)
            preview.Position = UDim2.new(0, 4, 0, 4)
            preview.BackgroundColor3 = library.flags[cfg.flag]
            preview.Text = ""
            preview.AutoButtonColor = false
            mkCorner(preview, UDim.new(0,6))

            local lbl = mkLabel(row, cfg.text or cfg.flag, 15)
            lbl.Position = UDim2.new(0, 52, 0, 6)

            -- We'll implement 3 small sliders inside a floating popup similar to list (for simplicity)
            local popup = Instance.new("Frame", menu)
            popup.BackgroundColor3 = SIDEBAR_BG_COLOR
            popup.Size = UDim2.new(0, 300, 0, 110)
            popup.Visible = false
            popup.ClipsDescendants = true
            popup.ZIndex = 10000
            mkCorner(popup, UDim.new(0,6))

            local function mkSlider(name, y, start)
                local fr = Instance.new("Frame", popup)
                fr.BackgroundTransparency = 1
                fr.Size = UDim2.new(1,-12,0,28)
                fr.Position = UDim2.new(0,6,0,y)
                local t = mkLabel(fr, name, 13); t.Size = UDim2.new(0,28,1,0)
                local bar = Instance.new("Frame", fr)
                bar.Size = UDim2.new(1,-44,0,10)
                bar.Position = UDim2.new(0, 34, 0, 8)
                bar.BackgroundColor3 = ELEM_BG_COLOR; mkCorner(bar, UDim.new(1,0))
                local fill = Instance.new("Frame", bar)
                fill.BackgroundColor3 = library.libColor; mkCorner(fill, UDim.new(1,0))
                fill.Size = UDim2.new(start/255, 0, 1, 0)
                local dragging=false
                bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
                RunService.RenderStepped:Connect(function()
                    if dragging and popup.Visible then
                        local pct = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.new(pct,0,1,0)
                    end
                end)
                return function() return math.floor(fill.Size.X.Scale*255) end, function(v) fill.Size = UDim2.new(v/255,0,1,0) end
            end

            local col = library.flags[cfg.flag]
            local getR,setR = mkSlider("R", 6, col.R*255)
            local getG,setG = mkSlider("G", 40, col.G*255)
            local getB,setB = mkSlider("B", 74, col.B*255)

            preview.MouseButton1Click:Connect(function()
                popup.Visible = not popup.Visible
                if popup.Visible then
                    -- position popup near preview
                    local abs = preview.AbsolutePosition
                    popup.Position = UDim2.new(0, abs.X + 50, 0, abs.Y)
                end
            end)

            RunService.RenderStepped:Connect(function()
                if popup.Visible then
                    local color = Color3.fromRGB(getR(), getG(), getB())
                    library.flags[cfg.flag] = color
                    preview.BackgroundColor3 = color
                    if cfg.callback then pcall(cfg.callback, color) end
                end
            end)

            library.options[cfg.flag] = { type="colorpicker", changeState=function(v) if typeof(v)=="Color3" then library.flags[cfg.flag]=v; preview.BackgroundColor3=v; setR(v.R*255); setG(v.G*255); setB(v.B*255) end end, skipflag=cfg.skipflag, oldargs=cfg }

            return preview
        end

        -- divider
        function group:addDivider()
            local d = Instance.new("Frame", groupFrame)
            d.BackgroundColor3 = Color3.fromRGB(30,30,34)
            d.Size = UDim2.new(1,-10,0,1)
            d.LayoutOrder = 9999
            return d
        end

        return group, groupFrame
    end

    return tabObj
end

-- config helpers
local function ensureFolders()
    if not isfolder then return false end
    if not isfolder("alora") then pcall(makefolder,"alora") end
    if not isfolder("alora/"..tostring(game.GameId)) then pcall(makefolder,"alora/"..tostring(game.GameId)) end
    return true
end

function library:refreshConfigs()
    local opt = library.options["selected_config"]
    if not opt or not opt.refresh then return {} end
    if not listfiles then opt.refresh({}); return {} end
    ensureFolders()
    local files = listfiles("alora/"..tostring(game.GameId))
    local out = {}
    for _,p in ipairs(files) do
        local name = p:match("([^/\```+)%.cfg$")
        if name then table.insert(out, name) end
    end
    pcall(function() opt.refresh(out) end)
    return out
end

function library:saveConfig()
    if not writefile then library:notify("Executor sem writefile"); return end
    ensureFolders()
    local name = library.flags["config_name"] or library.flags["selected_config"]
    if not name or name=="" then library:notify("Sem nome de config"); return end
    local dump = {}
    for k,v in pairs(library.flags) do
        local o = library.options[k]
        if o and o.skipflag then
        else
            if typeof(v)=="Color3" then dump[k]={"Color3", v.R, v.G, v.B}
            elseif typeof(v)=="EnumItem" then dump[k]={"EnumItem", tostring(v.EnumType):match("Enum%.(.+)"), v.Name}
            else dump[k] = v end
        end
    end
    local path = "alora/"..tostring(game.GameId).."/"..name..".cfg"
    pcall(writefile, path, HttpService:JSONEncode(dump))
    library:notify("Salvo: "..name)
    library:refreshConfigs()
end

function library:loadConfig()
    if not readfile then library:notify("Executor sem readfile"); return end
    local name = library.flags["selected_config"]
    if not name or name=="" then library:notify("Selecione config"); return end
    local path = "alora/"..tostring(game.GameId).."/"..name..".cfg"
    if not isfile or not isfile(path) then library:notify("Config não encontrada"); return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok or not data then library:notify("Erro ao ler cfg"); return end
    for k,v in pairs(data) do
        local o = library.options[k]
        if o and o.changeState then
            if type(v)=="table" and v[1]=="Color3" then o.changeState(Color3.new(v[2],v[3],v[4]))
            elseif type(v)=="table" and v[1]=="EnumItem" then pcall(function() o.changeState(Enum[v[2]][v[3]]) end)
            else pcall(function() o.changeState(v) end) end
        else
            library.flags[k] = v
        end
    end
    library:notify("Carregado: "..name)
end

function library:deleteConfig()
    if not delfile then library:notify("Executor sem delfile"); return end
    local name = library.flags["selected_config"]
    if not name or name=="" then library:notify("Selecione config"); return end
    local path = "alora/"..tostring(game.GameId).."/"..name..".cfg"
    if isfile and isfile(path) then pcall(delfile, path); library:notify("Deletado: "..name); library:refreshConfigs()
    else library:notify("Config não encontrada") end
end

-- return
return library, menu, tabholder
