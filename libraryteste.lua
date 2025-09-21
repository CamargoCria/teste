-- libraryteste.lua (VERSÃO CORRIGIDA)
-- UI com blur/sombra/glow e layout corrigido (controles maiores, full-width)
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
    Open = true
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

-- cleanup old
pcall(function() if CoreGui:FindFirstChild("sjorlib") then CoreGui.sjorlib:Destroy() end end)
pcall(function() if Lighting:FindFirstChild("AloraBlur") then Lighting.AloraBlur:Destroy() end end)

-- blur
local blur = Instance.new("BlurEffect")
blur.Name = "AloraBlur"
blur.Size = 10
blur.Parent = Lighting

-- screen gui (must be 'sjorlib' for your script check)
local menu = Instance.new("ScreenGui")
menu.Name = "sjorlib"
menu.Parent = CoreGui
menu.ResetOnSpawn = false
menu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
menu.Enabled = true

-- shadow
local shadow = Instance.new("Frame", menu)
shadow.Name = "ShadowFrame"
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = 0.7
shadow.Size = UDim2.new(0, 720, 0, 460)
shadow.Position = UDim2.new(0.5, -360 + 6, 0.5, -230 + 6)
local sc = Instance.new("UICorner", shadow); sc.CornerRadius = CORNER_RADIUS

-- main window
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

-- titlebar
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
closeBtn.Size = UDim2.new(0, 44, 1, 0)
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

-- sidebar
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

-- content holder (tab pages)
local tabholder = Instance.new("Frame", main)
tabholder.Name = "ContentFrame"
tabholder.BackgroundTransparency = 1
tabholder.Size = UDim2.new(1, -180, 1, -38)
tabholder.Position = UDim2.new(0, 180, 0, 38)

-- dragging logic
do
    local dragging = false; local dragStart; local startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    local dragInput
    titleBar.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragInput and dragging and i == dragInput then
            local delta = i.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            main.Position = newPos
            shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset + 6, newPos.Y.Scale, newPos.Y.Offset + 6)
        end
    end)
end

-- toggle menu with Insert
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.Insert and not processed then
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

-- helper constructors
local function makeCorner(parent, rad) local c = Instance.new("UICorner", parent); c.CornerRadius = rad or CORNER_RADIUS; return c end
local function makeLabel(parent, text, size)
    local l = Instance.new("TextLabel", parent)
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, -10, 0, 20)
    l.Font = Enum.Font.Gotham
    l.TextSize = size or 15
    l.TextColor3 = TEXT_COLOR
    l.Text = text or ""
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

-- notifier
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
makeCorner(toast, UDim.new(0,6))

function library:notify(text)
    if not text then return end
    toast.Text = "  "..tostring(text)
    toast.Visible = true
    toast.TextTransparency = 1
    for i=0,1,0.1 do toast.TextTransparency = 1 - i; task.wait(0.02) end
    task.wait(2)
    for i=0,1,0.1 do toast.TextTransparency = i; task.wait(0.02) end
    toast.Visible = false
end

-- Tabs container
local tabs = {}

-- Add tab
function library:addTab(name)
    local btn = Instance.new("TextButton")
    btn.Parent = sidebar
    btn.Size = UDim2.new(1, -12, 0, 40)
    btn.BackgroundColor3 = SIDEBAR_BG_COLOR
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.TextColor3 = TEXT_MUTED
    btn.AutoButtonColor = false
    makeCorner(btn, UDim.new(0,6))

    local page = Instance.new("ScrollingFrame")
    page.Name = name.."Page"
    page.Parent = tabholder
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.ScrollBarThickness = 8
    page.Visible = false
    page.BorderSizePixel = 0

    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0,10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0,10)
    pad.PaddingLeft = UDim.new(0,10)
    pad.PaddingRight = UDim.new(0,10)

    -- auto canvas size
    local function refreshCanvas()
        page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 12)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas)
    page.ChildAdded:Connect(refreshCanvas)
    page.ChildRemoved:Connect(refreshCanvas)

    local function activate()
        for k,v in pairs(tabs) do
            v.button.BackgroundColor3 = SIDEBAR_BG_COLOR
            v.button.TextColor3 = TEXT_MUTED
            v.page.Visible = false
        end
        btn.BackgroundColor3 = library.libColor
        btn.TextColor3 = TEXT_COLOR
        page.Visible = true
    end

    btn.MouseButton1Click:Connect(activate)
    btn.MouseEnter:Connect(function() if btn.TextColor3 ~= TEXT_COLOR then btn.BackgroundColor3 = HOVER_COLOR end end)
    btn.MouseLeave:Connect(function() if btn.TextColor3 ~= TEXT_COLOR then btn.BackgroundColor3 = SIDEBAR_BG_COLOR end end)

    local tabObj = {button = btn, page = page}

    function tabObj:createGroup(layoutOrder)
        local groupFrame = Instance.new("Frame")
        groupFrame.Parent = page
        groupFrame.BackgroundColor3 = SIDEBAR_BG_COLOR
        groupFrame.BorderSizePixel = 0
        groupFrame.AutomaticSize = Enum.AutomaticSize.Y
        groupFrame.Size = UDim2.new(1, 0, 0, 0)
        groupFrame.LayoutOrder = layoutOrder or 0
        makeCorner(groupFrame, UDim.new(0,6))

        local gpPad = Instance.new("UIPadding", groupFrame)
        gpPad.PaddingTop = UDim.new(0,8)
        gpPad.PaddingBottom = UDim.new(0,8)
        gpPad.PaddingLeft = UDim.new(0,8)
        gpPad.PaddingRight = UDim.new(0,8)

        local gList = Instance.new("UIListLayout", groupFrame)
        gList.Padding = UDim.new(0,8)
        gList.SortOrder = Enum.SortOrder.LayoutOrder

        local group = {}

        -- addToggle
        function group:addToggle(cfg)
            cfg = cfg or {}
            local flag = cfg.flag or cfg.text
            if not flag then return warn("addToggle requires flag/text") end
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
            makeCorner(box, UDim.new(0,4))

            local lbl = makeLabel(btn, cfg.text or flag, 15)
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

        -- addButton
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
            makeCorner(b, UDim.new(0,6))
            b.MouseButton1Click:Connect(function() if cfg.callback then pcall(cfg.callback) end end)
            return b
        end

        -- addSlider
        function group:addSlider(cfg)
            cfg = cfg or {}
            assert(cfg.flag and cfg.min and cfg.max, "addSlider requires flag/min/max")
            library.flags[cfg.flag] = cfg.value or cfg.min

            local frame = Instance.new("Frame", groupFrame)
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.new(1,0,0,52)
            frame.LayoutOrder = cfg.LayoutOrder or 0

            local lbl = makeLabel(frame, (cfg.text or cfg.flag)..": "..tostring(library.flags[cfg.flag]), 14)
            lbl.Position = UDim2.new(0,0,0,0)

            local barBG = Instance.new("Frame", frame)
            barBG.BackgroundColor3 = ELEM_BG_COLOR
            barBG.Size = UDim2.new(1,0,0,12)
            barBG.Position = UDim2.new(0,0,0,34)
            makeCorner(barBG, UDim.new(1,0))

            local fill = Instance.new("Frame", barBG)
            fill.BackgroundColor3 = library.libColor
            fill.Size = UDim2.new( (library.flags[cfg.flag]-cfg.min)/(cfg.max-cfg.min), 0, 1, 0)
            makeCorner(fill, UDim.new(1,0))

            local dragging = false
            barBG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
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

        -- addTextbox
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
            makeCorner(tb, UDim.new(0,6))
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

        -- addKeybind
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
            makeCorner(b, UDim.new(0,6))

            local function updateText()
                local k = library.flags[cfg.flag]
                local name = (k and k.Name) or tostring(k)
                b.Text = (cfg.text or cfg.flag).." ["..name.."]"
            end
            updateText()

            local listening = false; local con
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

        -- addList
        function group:addList(cfg)
            cfg = cfg or {}
            assert(cfg.flag and cfg.values, "addList requires flag and values")
            local multi = cfg.multiselect
            library.flags[cfg.flag] = multi and (cfg.value or {}) or (cfg.value or cfg.values[1])

            local container = Instance.new("Frame", groupFrame)
            container.BackgroundTransparency = 1
            container.Size = UDim2.new(1,0,0,36)
            container.LayoutOrder = cfg.LayoutOrder or 0

            local btn = Instance.new("TextButton", container)
            btn.BackgroundColor3 = ELEM_BG_COLOR
            btn.Size = UDim2.new(1,0,1,0)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 15
            btn.TextColor3 = TEXT_COLOR
            btn.Text = cfg.text or cfg.flag
            makeCorner(btn, UDim.new(0,6))

            local dd = Instance.new("Frame", btn)
            dd.Size = UDim2.new(1,0,0,0)
            dd.Position = UDim2.new(0,0,1,6)
            dd.BackgroundColor3 = SIDEBAR_BG_COLOR
            dd.Visible = false
            dd.ZIndex = 1000
            local ddList = Instance.new("UIListLayout", dd)
            ddList.SortOrder = Enum.SortOrder.LayoutOrder

            local function build(vals)
                for _,c in pairs(dd:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for _,v in ipairs(vals) do
                    local it = Instance.new("TextButton", dd)
                    it.Size = UDim2.new(1,0,0,28)
                    it.BackgroundColor3 = SIDEBAR_BG_COLOR
                    it.Text = v
                    it.Font = Enum.Font.Gotham
                    it.TextSize = 14
                    it.TextColor3 = TEXT_MUTED
                    it.AutoButtonColor = false
                    it.MouseButton1Click:Connect(function()
                        if multi then
                            local t = library.flags[cfg.flag]
                            local idx = table.find(t, v)
                            if idx then table.remove(t, idx) else table.insert(t, v) end
                            if cfg.callback then pcall(cfg.callback, t) end
                        else
                            library.flags[cfg.flag] = v
                            if cfg.callback then pcall(cfg.callback, v) end
                            dd.Visible = false
                        end
                    end)
                end
                dd.Size = UDim2.new(1,0,0,#vals * 28)
            end
            build(cfg.values)

            btn.MouseButton1Click:Connect(function() dd.Visible = not dd.Visible end)

            library.options[cfg.flag] = { type="list", changeState=function(v) library.flags[cfg.flag]=v end, refresh=function(tbl) cfg.values = tbl; build(tbl) end, values=cfg.values, skipflag=cfg.skipflag, oldargs=cfg }
            return btn, dd
        end

        -- addColorpicker (simple)
        function group:addColorpicker(cfg)
            cfg = cfg or {}
            assert(cfg.flag, "addColorpicker requires flag")
            library.flags[cfg.flag] = cfg.color or Color3.new(1,1,1)

            local container = Instance.new("Frame", groupFrame)
            container.BackgroundTransparency = 1
            container.Size = UDim2.new(1,0,0,36)
            container.LayoutOrder = cfg.LayoutOrder or 0

            local preview = Instance.new("TextButton", container)
            preview.Size = UDim2.new(0, 40, 0, 28)
            preview.Position = UDim2.new(0, 4, 0, 4)
            preview.BackgroundColor3 = library.flags[cfg.flag]
            preview.Text = ""
            preview.AutoButtonColor = false
            makeCorner(preview, UDim.new(0,6))

            local lbl = makeLabel(container, cfg.text or cfg.flag, 15)
            lbl.Position = UDim2.new(0, 52, 0, 6)

            local popup = Instance.new("Frame", container)
            popup.BackgroundColor3 = SIDEBAR_BG_COLOR
            popup.Size = UDim2.new(0, 260, 0, 110)
            popup.Position = UDim2.new(0, 120, 0, 0)
            popup.Visible = false
            makeCorner(popup, UDim.new(0,6))

            local function mkSlider(name, y, start)
                local f = Instance.new("Frame", popup)
                f.BackgroundTransparency = 1
                f.Size = UDim2.new(1,-12,0,28)
                f.Position = UDim2.new(0,6,0,(y))
                local t = makeLabel(f, name, 13); t.Size = UDim2.new(0,28,1,0)
                local bar = Instance.new("Frame", f)
                bar.Size = UDim2.new(1,-44,0,10)
                bar.Position = UDim2.new(0, 34, 0, 8)
                bar.BackgroundColor3 = ELEM_BG_COLOR; makeCorner(bar,UDim.new(1,0))
                local fill = Instance.new("Frame", bar); fill.BackgroundColor3 = library.libColor; makeCorner(fill,UDim.new(1,0))
                fill.Size = UDim2.new(start/255,0,1,0)
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

            local c = library.flags[cfg.flag]
            local getR,setR = mkSlider("R", 6, c.R*255)
            local getG,setG = mkSlider("G", 40, c.G*255)
            local getB,setB = mkSlider("B", 74, c.B*255)

            preview.MouseButton1Click:Connect(function() popup.Visible = not popup.Visible end)

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

        -- addDivider
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

-- Config helpers (files)
local function ensureFolders()
    if not isfolder then return end
    if not isfolder("alora") then pcall(makefolder,"alora") end
    if not isfolder("alora/"..tostring(game.GameId)) then pcall(makefolder, "alora/"..tostring(game.GameId)) end
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
        if o and o.skipflag then -- skip
        else
            if typeof(v)=="Color3" then dump[k] = {"Color3", v.R, v.G, v.B}
            elseif typeof(v)=="EnumItem" then dump[k] = {"EnumItem", tostring(v.EnumType):match("Enum%.(.+)"), v.Name}
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
    if isfile and isfile(path) then pcall(delfile, path); library:notify("Deletado: "..name); library:refreshConfigs() else library:notify("Config não encontrada") end
end

-- Return library for Alora script
return library, menu, tabholder
