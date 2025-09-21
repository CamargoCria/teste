-- libraryteste.lua (FIX)
-- UI com blur/sombra/glow e layout corrigido (controles grandes e full-width)
-- Retorna: library, menu(ScreenGui), tabholder(ContentFrame)

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local library = {
    flags = {},
    options = {},
    libColor = Color3.fromRGB(0,140,255),
    Open = true
}

-- Tema (mantém sua aparência)
local MAIN_BG_COLOR       = Color3.fromRGB(25, 25, 30)
local SIDEBAR_BG_COLOR    = Color3.fromRGB(35, 35, 40)
local ELEM_BG_COLOR       = Color3.fromRGB(40, 40, 46)
local BORDER_COLOR        = Color3.fromRGB(0, 140, 255)
local BORDER_TRANSP       = 0.2
local TEXT_COLOR          = Color3.fromRGB(255, 255, 255)
local TEXT_MUTED          = Color3.fromRGB(150, 150, 150)
local HOVER_COLOR         = Color3.fromRGB(50, 50, 56)
local ACTIVE_COLOR        = Color3.fromRGB(0, 140, 255)
local CORNER              = UDim.new(0, 8)

-- Evita duplicar
pcall(function() if CoreGui:FindFirstChild("sjorlib") then CoreGui.sjorlib:Destroy() end end)
pcall(function() if Lighting:FindFirstChild("AloraBlur") then Lighting.AloraBlur:Destroy() end end)

-- Blur
local blur = Instance.new("BlurEffect")
blur.Name = "AloraBlur"
blur.Size = 10
blur.Parent = Lighting

-- ScreenGui (precisa se chamar sjorlib pro seu script detectar)
local menu = Instance.new("ScreenGui")
menu.Name = "sjorlib"
menu.Parent = CoreGui
menu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
menu.ResetOnSpawn = false
menu.Enabled = true

-- Sombra
local shadow = Instance.new("Frame")
shadow.Parent = menu
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = 0.7
shadow.Size = UDim2.new(0, 680, 0, 430)
shadow.Position = UDim2.new(0.5, -340 + 5, 0.5, -215 + 5)
local shCorner = Instance.new("UICorner", shadow); shCorner.CornerRadius = CORNER

-- Main
local main = Instance.new("Frame")
main.Parent = menu
main.BackgroundColor3 = MAIN_BG_COLOR
main.Size = UDim2.new(0, 680, 0, 430)      -- maior pra ficar confortável
main.Position = UDim2.new(0.5, -340, 0.5, -215)
local mainCorner = Instance.new("UICorner", main); mainCorner.CornerRadius = CORNER

local glow = Instance.new("UIStroke")
glow.Parent = main
glow.Color = BORDER_COLOR
glow.Transparency = BORDER_TRANSP
glow.Thickness = 2

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Parent = main
titleBar.BackgroundColor3 = Color3.fromRGB(20,20,25)
titleBar.Size = UDim2.new(1,0,0,36)
local titleCorner = Instance.new("UICorner", titleBar); titleCorner.CornerRadius = CORNER

local title = Instance.new("TextLabel")
title.Parent = titleBar
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 15, 0, 0)
title.Size = UDim2.new(1, -60, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "Alora v1.2"
title.TextColor3 = TEXT_COLOR
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0, 36, 1, 0)
closeBtn.Position = UDim2.new(1, -36, 0, 0)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = TEXT_COLOR

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Parent = main
sidebar.BackgroundColor3 = SIDEBAR_BG_COLOR
sidebar.Size = UDim2.new(0, 170, 1, -36)
sidebar.Position = UDim2.new(0, 0, 0, 36)
local sideCorner = Instance.new("UICorner", sidebar); sideCorner.CornerRadius = CORNER

local sideList = Instance.new("UIListLayout", sidebar)
sideList.Padding = UDim.new(0,6)
sideList.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0,6)

-- Content holder
local tabholder = Instance.new("Frame")
tabholder.Name = "ContentFrame"
tabholder.Parent = main
tabholder.BackgroundTransparency = 1
tabholder.Size = UDim2.new(1, -170, 1, -36)
tabholder.Position = UDim2.new(0, 170, 0, 36)

-- Drag
do
    local dragging, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        main.Position = newPos
        shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset + 5, newPos.Y.Scale, newPos.Y.Offset + 5)
    end
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
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement) then update(i) end
    end)
end

-- Toggle UI (Insert)
UserInputService.InputBegan:Connect(function(input, g)
    if not g and input.KeyCode == Enum.KeyCode.Insert then
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

closeBtn.MouseButton1Click:Connect(function()
    library.Open = false
    menu.Enabled = false
    blur.Enabled = false
end)

-- Helpers
local function corner(parent, rad) local c = Instance.new("UICorner"); c.CornerRadius = rad or CORNER; c.Parent = parent; return c end
local function label(parent, text, size)
    local l = Instance.new("TextLabel")
    l.Parent = parent
    l.BackgroundTransparency = 1
    l.Text = text or ""
    l.Font = Enum.Font.Gotham
    l.TextSize = size or 15
    l.TextColor3 = TEXT_COLOR
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Size = UDim2.new(1,-10,0,20)
    return l
end

-- Notifier simples
local toast = Instance.new("TextLabel")
toast.Parent = main
toast.BackgroundColor3 = Color3.fromRGB(0,0,0)
toast.BackgroundTransparency = 0.35
toast.Size = UDim2.new(0, 300, 0, 26)
toast.Position = UDim2.new(0, 12, 0, 8)
toast.Visible = false
toast.Font = Enum.Font.Gotham
toast.TextColor3 = TEXT_COLOR
toast.TextSize = 14
toast.TextXAlignment = Enum.TextXAlignment.Left
corner(toast, UDim.new(0,6))

function library:notify(txt)
    if not txt then return end
    toast.Text = "  " .. tostring(txt)
    toast.Visible = true
    toast.TextTransparency = 1
    for i=0,1,0.1 do toast.TextTransparency = 1-i; task.wait(0.02) end
    task.wait(2)
    for i=0,1,0.1 do toast.TextTransparency = i; task.wait(0.02) end
    toast.Visible = false
end

-- Tabs
local tabs = {}
function library:addTab(name)
    -- botão da aba
    local btn = Instance.new("TextButton")
    btn.Parent = sidebar
    btn.Size = UDim2.new(1, -12, 0, 36)
    btn.BackgroundColor3 = SIDEBAR_BG_COLOR
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.TextColor3 = TEXT_MUTED
    btn.AutoButtonColor = false
    corner(btn, UDim.new(0,6))

    -- página
    local page = Instance.new("ScrollingFrame")
    page.Name = name.."Page"
    page.Parent = tabholder
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.ScrollBarThickness = 6
    page.BorderSizePixel = 0
    page.Visible = false

    local pList = Instance.new("UIListLayout", page)
    pList.Padding = UDim.new(0,10)
    pList.SortOrder = Enum.SortOrder.LayoutOrder
    local pPad = Instance.new("UIPadding", page)
    pPad.PaddingTop = UDim.new(0,10)
    pPad.PaddingLeft = UDim.new(0,10)
    pPad.PaddingRight = UDim.new(0,10)

    local function refreshCanvas()
        page.CanvasSize = UDim2.new(0,0,0,pList.AbsoluteContentSize.Y + 10)
    end
    page.ChildAdded:Connect(refreshCanvas)
    pList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas)

    local function activate()
        for _,t in pairs(tabs) do
            t.button.BackgroundColor3 = SIDEBAR_BG_COLOR
            t.button.TextColor3 = TEXT_MUTED
            t.page.Visible = false
        end
        btn.BackgroundColor3 = ACTIVE_COLOR
        btn.TextColor3 = TEXT_COLOR
        page.Visible = true
    end
    btn.MouseButton1Click:Connect(activate)
    btn.MouseEnter:Connect(function()
        if btn.TextColor3 ~= TEXT_COLOR then btn.BackgroundColor3 = HOVER_COLOR end
    end)
    btn.MouseLeave:Connect(function()
        if btn.TextColor3 ~= TEXT_COLOR then btn.BackgroundColor3 = SIDEBAR_BG_COLOR end
    end)

    local tabObj = {button=btn, page=page}
    tabs[name] = tabObj
    if not tabs._first then tabs._first = true; activate() end

    -- Groups
    function tabObj:createGroup(order)
        local group = {}
        local g = Instance.new("Frame")
        g.Parent = page
        g.BackgroundColor3 = SIDEBAR_BG_COLOR
        g.BorderSizePixel = 0
        g.AutomaticSize = Enum.AutomaticSize.Y
        g.Size = UDim2.new(1, 0, 0, 0)
        g.LayoutOrder = order or 0
        corner(g, UDim.new(0,6))
        local gPad = Instance.new("UIPadding", g)
        gPad.PaddingTop    = UDim.new(0,8)
        gPad.PaddingBottom = UDim.new(0,8)
        gPad.PaddingLeft   = UDim.new(0,8)
        gPad.PaddingRight  = UDim.new(0,8)
        local gList = Instance.new("UIListLayout", g)
        gList.Padding = UDim.new(0,8)
        gList.SortOrder = Enum.SortOrder.LayoutOrder

        -- Toggle
        function group:addToggle(cfg)
            local flag = cfg.flag or cfg.text
            assert(flag, "addToggle requer flag/text")

            library.flags[flag] = cfg.value or false

            local row = Instance.new("Frame")
            row.Parent = g
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1,0,0,32)

            local btn = Instance.new("TextButton")
            btn.Parent = row
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1,0,1,0)
            btn.Text = ""
            btn.AutoButtonColor = false

            local box = Instance.new("Frame")
            box.Parent = btn
            box.Size = UDim2.new(0, 18, 0, 18)
            box.Position = UDim2.new(0, 4, 0.5, -9)
            box.BackgroundColor3 = library.flags[flag] and library.libColor or ELEM_BG_COLOR
            corner(box, UDim.new(0,4))

            local txt = label(btn, cfg.text or flag, 15)
            txt.Position = UDim2.new(0, 28, 0.5, -10)

            local function set(v)
                library.flags[flag] = v
                box.BackgroundColor3 = v and library.libColor or ELEM_BG_COLOR
                if cfg.callback then pcall(cfg.callback, v) end
            end

            btn.MouseButton1Click:Connect(function() set(not library.flags[flag]) end)

            library.options[flag] = {type="toggle", changeState=set, skipflag=cfg.skipflag, oldargs=cfg}
            return btn
        end

        -- Button
        function group:addButton(cfg)
            assert(cfg and cfg.text and cfg.callback, "addButton requer text/callback")
            local b = Instance.new("TextButton")
            b.Parent = g
            b.BackgroundColor3 = ELEM_BG_COLOR
            b.Size = UDim2.new(1,0,0,32)
            b.Text = cfg.text
            b.TextColor3 = TEXT_COLOR
            b.Font = Enum.Font.GothamBold
            b.TextSize = 15
            b.AutoButtonColor = false
            corner(b, UDim.new(0,6))
            b.MouseButton1Click:Connect(function() pcall(cfg.callback) end)
            return b
        end

        -- Slider
        function group:addSlider(cfg)
            assert(cfg and cfg.flag and cfg.min and cfg.max, "addSlider requer flag/min/max")
            library.flags[cfg.flag] = cfg.value or cfg.min

            local frame = Instance.new("Frame")
            frame.Parent = g
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.new(1,0,0,44)

            local txt = label(frame, (cfg.text or cfg.flag)..": "..tostring(library.flags[cfg.flag]), 14)
            txt.Position = UDim2.new(0,0,0,0)

            local barBG = Instance.new("Frame")
            barBG.Parent = frame
            barBG.BackgroundColor3 = ELEM_BG_COLOR
            barBG.Size = UDim2.new(1,0,0,10)
            barBG.Position = UDim2.new(0,0,0,26)
            corner(barBG, UDim.new(1,0))

            local fill = Instance.new("Frame")
            fill.Parent = barBG
            fill.BackgroundColor3 = library.libColor
            corner(fill, UDim.new(1,0))

            local function setVal(v)
                v = math.clamp(v, cfg.min, cfg.max)
                if not cfg.precise then v = math.floor(v) end
                library.flags[cfg.flag] = v
                local pct = (v - cfg.min) / (cfg.max - cfg.min)
                fill.Size = UDim2.new(pct,0,1,0)
                txt.Text = (cfg.text or cfg.flag)..": "..tostring(v)
                if cfg.callback then pcall(cfg.callback, v) end
            end

            -- drag
            local dragging=false
            barBG.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
            RunService.RenderStepped:Connect(function()
                if dragging then
                    local x = math.clamp((UserInputService:GetMouseLocation().X - barBG.AbsolutePosition.X)/barBG.AbsoluteSize.X, 0, 1)
                    setVal(cfg.min + x*(cfg.max-cfg.min))
                end
            end)

            library.options[cfg.flag] = {type="slider", changeState=setVal, skipflag=cfg.skipflag, oldargs=cfg}
            setVal(library.flags[cfg.flag])
            return frame
        end

        -- Textbox
        function group:addTextbox(cfg)
            assert(cfg and cfg.flag, "addTextbox requer flag")
            local tb = Instance.new("TextBox")
            tb.Parent = g
            tb.BackgroundColor3 = ELEM_BG_COLOR
            tb.Size = UDim2.new(1,0,0,32)
            tb.Text = cfg.text or ""
            tb.TextColor3 = TEXT_COLOR
            tb.Font = Enum.Font.Gotham
            tb.TextSize = 15
            tb.ClearTextOnFocus = false
            corner(tb, UDim.new(0,6))
            tb.FocusLost:Connect(function(enter)
                if enter then
                    library.flags[cfg.flag] = tb.Text
                    if cfg.callback then pcall(cfg.callback, tb.Text) end
                end
            end)
            library.flags[cfg.flag] = tb.Text
            library.options[cfg.flag] = {type="textbox", changeState=function(v) tb.Text = v end, skipflag=cfg.skipflag, oldargs=cfg}
            return tb
        end

        -- Keybind
        function group:addKeybind(cfg)
            assert(cfg and cfg.flag, "addKeybind requer flag")
            library.flags[cfg.flag] = cfg.key or Enum.KeyCode.Unknown

            local b = Instance.new("TextButton")
            b.Parent = g
            b.BackgroundColor3 = ELEM_BG_COLOR
            b.Size = UDim2.new(1,0,0,32)
            b.TextColor3 = TEXT_COLOR
            b.Font = Enum.Font.Gotham
            b.TextSize = 15
            corner(b, UDim.new(0,6))

            local function refreshText()
                local k = library.flags[cfg.flag]
                local n = (k and k.Name) or "Unknown"
                b.Text = (cfg.text or cfg.flag).." ["..n.."]"
            end
            refreshText()

            local listening=false; local conn
            b.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                b.Text = (cfg.text or cfg.flag).." [Press Key]"
                conn = UserInputService.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.Keyboard then
                        library.flags[cfg.flag] = i.KeyCode
                        refreshText()
                        if conn then conn:Disconnect() end
                        listening=false
                        if cfg.callback then pcall(cfg.callback, library.flags[cfg.flag]) end
                    end
                end)
            end)

            library.options[cfg.flag] = {type="keybind", changeState=function(v) library.flags[cfg.flag]=v; refreshText() end, skipflag=cfg.skipflag, oldargs=cfg}
            return b
        end

        -- List (dropdown) - com multiselect
        function group:addList(cfg)
            assert(cfg and cfg.flag and cfg.values, "addList requer flag/values")
            local multi = cfg.multiselect
            library.flags[cfg.flag] = multi and (cfg.value or {}) or (cfg.value or cfg.values[1])

            local holder = Instance.new("Frame")
            holder.Parent = g
            holder.BackgroundTransparency = 1
            holder.Size = UDim2.new(1,0,0,32)

            local btn = Instance.new("TextButton")
            btn.Parent = holder
            btn.BackgroundColor3 = ELEM_BG_COLOR
            btn.Size = UDim2.new(1,0,1,0)
            btn.TextColor3 = TEXT_COLOR
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 15
            btn.Text = cfg.text or cfg.flag
            btn.AutoButtonColor = false
            corner(btn, UDim.new(0,6))

            local dd = Instance.new("ScrollingFrame")
            dd.Parent = btn
            dd.Size = UDim2.new(1,0,0,0)     -- cresce automático
            dd.Position = UDim2.new(0,0,1,6)
            dd.BackgroundColor3 = SIDEBAR_BG_COLOR
            dd.Visible = false
            dd.ScrollBarThickness = 6
            dd.AutomaticSize = Enum.AutomaticSize.Y
            dd.ZIndex = 1000
            corner(dd, UDim.new(0,6))
            local ddList = Instance.new("UIListLayout", dd)
            ddList.SortOrder = Enum.SortOrder.LayoutOrder

            local function build(values)
                for _,c in ipairs(dd:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for _,val in ipairs(values) do
                    local it = Instance.new("TextButton")
                    it.Parent = dd
                    it.BackgroundColor3 = SIDEBAR_BG_COLOR
                    it.Size = UDim2.new(1,0,0,28)
                    it.Text = val
                    it.Font = Enum.Font.Gotham
                    it.TextSize = 15
                    it.TextColor3 = TEXT_MUTED
                    it.AutoButtonColor = false
                    it.ZIndex = 1001
                    it.MouseButton1Click:Connect(function()
                        if multi then
                            local list = library.flags[cfg.flag]
                            local found = table.find(list, val)
                            if found then table.remove(list, found) else table.insert(list, val) end
                            if cfg.callback then pcall(cfg.callback, list) end
                        else
                            library.flags[cfg.flag] = val
                            dd.Visible = false
                            if cfg.callback then pcall(cfg.callback, val) end
                        end
                    end)
                end
            end
            build(cfg.values)

            btn.MouseButton1Click:Connect(function()
                dd.Visible = not dd.Visible
            end)

            library.options[cfg.flag] = {
                type="list",
                changeState=function(v) library.flags[cfg.flag] = v end,
                refresh=function(vs) cfg.values = vs; if dd.Visible then build(vs) end end,
                values=cfg.values,
                skipflag=cfg.skipflag,
                oldargs=cfg
            }
            return btn, dd
        end

        -- Colorpicker simples (R/G/B sliders)
        function group:addColorpicker(cfg)
            assert(cfg and cfg.flag, "addColorpicker requer flag")
            library.flags[cfg.flag] = cfg.color or Color3.new(1,1,1)

            local row = Instance.new("Frame")
            row.Parent = g
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1,0,0,32)

            local preview = Instance.new("TextButton")
            preview.Parent = row
            preview.BackgroundColor3 = library.flags[cfg.flag]
            preview.Size = UDim2.new(0, 36, 0, 26)
            preview.Position = UDim2.new(0,0,0,3)
            preview.Text = ""
            preview.AutoButtonColor = false
            corner(preview, UDim.new(0,6))

            local txt = label(row, cfg.text or cfg.flag, 15)
            txt.Position = UDim2.new(0, 44, 0, 5)

            local popup = Instance.new("Frame")
            popup.Parent = row
            popup.BackgroundColor3 = SIDEBAR_BG_COLOR
            popup.Size = UDim2.new(0, 260, 0, 110)
            popup.Position = UDim2.new(0, 90, 0, 0)
            popup.Visible = false
            corner(popup, UDim.new(0,6))

            local function mkSlider(lbl, y, start)
                local fr = Instance.new("Frame", popup)
                fr.BackgroundTransparency = 1
                fr.Size = UDim2.new(1,-14,0,30)
                fr.Position = UDim2.new(0,7,0,y)
                local t = label(fr, lbl, 13); t.Size = UDim2.new(0,28,0,24)
                local bar = Instance.new("Frame", fr)
                bar.BackgroundColor3 = ELEM_BG_COLOR
                bar.Size = UDim2.new(1,-40,0,10)
                bar.Position = UDim2.new(0, 34, 0, 8)
                corner(bar, UDim.new(1,0))
                local fill = Instance.new("Frame", bar)
                fill.BackgroundColor3 = library.libColor
                corner(fill, UDim.new(1,0))
                fill.Size = UDim2.new(start/255,0,1,0)

                local dragging=false
                bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
                RunService.RenderStepped:Connect(function()
                    if dragging then
                        local pct = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.new(pct,0,1,0)
                    end
                end)
                return function() return math.floor(fill.Size.X.Scale*255) end,
                       function(v) fill.Size = UDim2.new(v/255,0,1,0) end
            end

            local col = library.flags[cfg.flag]
            local getR,setR = mkSlider("R", 6,  math.floor(col.R*255))
            local getG,setG = mkSlider("G", 40, math.floor(col.G*255))
            local getB,setB = mkSlider("B", 74, math.floor(col.B*255))

            preview.MouseButton1Click:Connect(function() popup.Visible = not popup.Visible end)

            local function apply()
                local c = Color3.fromRGB(getR(),getG(),getB())
                library.flags[cfg.flag] = c
                preview.BackgroundColor3 = c
                if cfg.callback then pcall(cfg.callback, c) end
            end
            RunService.RenderStepped:Connect(function()
                if popup.Visible then apply() end
            end)

            library.options[cfg.flag] = {type="colorpicker", changeState=function(v)
                if typeof(v)=="Color3" then
                    library.flags[cfg.flag] = v
                    preview.BackgroundColor3 = v
                    setR(v.R*255); setG(v.G*255); setB(v.B*255)
                end
            end, skipflag=cfg.skipflag, oldargs=cfg}
            return preview
        end

        -- Divider
        function group:addDivider()
            local d = Instance.new("Frame")
            d.Parent = g
            d.BackgroundColor3 = Color3.fromRGB(28,28,32)
            d.Size = UDim2.new(1,0,0,1)
            return d
        end

        return group, g
    end

    return tabObj
end

-- Configs (usa APIs de arquivo se existirem)
local function ensureFolders()
    if not isfolder then return end
    if not isfolder("alora") then pcall(makefolder,"alora") end
    local gid = tostring(game.GameId)
    if not isfolder("alora/"..gid) then pcall(makefolder,"alora/"..gid) end
end

function library:refreshConfigs()
    local opt = library.options["selected_config"]
    if not (opt and opt.refresh) then return end
    if not listfiles then opt.refresh({}); return end
    ensureFolders()
    local gid = tostring(game.GameId)
    local files = listfiles("alora/"..gid)
    local out = {}
    for _,p in ipairs(files) do
        local name = p:match("([^/\```+)%.cfg$")
        if name then table.insert(out, name) end
    end
    opt.refresh(out)
end

function library:saveConfig()
    if not writefile then library:notify("Executor sem writefile"); return end
    ensureFolders()
    local name = library.flags["config_name"]; if name=="" or not name then name = library.flags["selected_config"] end
    if not name or name=="" then library:notify("Sem nome de config"); return end
    local dump = {}
    for k,v in pairs(library.flags) do
        local o = library.options[k]
        if o and o.skipflag then -- pula
        else
            if typeof(v)=="Color3" then dump[k]={"Color3",v.R,v.G,v.B}
            elseif typeof(v)=="EnumItem" then dump[k]={"EnumItem", tostring(v.EnumType):match("Enum%.(.+)"), v.Name}
            else dump[k]=v end
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
    if not name or name=="" then library:notify("Selecione uma config"); return end
    local path = "alora/"..tostring(game.GameId).."/"..name..".cfg"
    if not isfile(path) then library:notify("Config não encontrada"); return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok or not data then library:notify("Erro ao ler config"); return end
    for k,v in pairs(data) do
        local o = library.options[k]
        if o and o.changeState then
            if type(v)=="table" and v[1]=="Color3" then o.changeState(Color3.new(v[2],v[3],v[4]))
            elseif type(v)=="table" and v[1]=="EnumItem" then local e=Enum[v[2]][v[3]]; o.changeState(e)
            else o.changeState(v) end
        else library.flags[k]=v end
    end
    library:notify("Carregado: "..name)
end

function library:deleteConfig()
    if not delfile then library:notify("Executor sem delfile"); return end
    local name = library.flags["selected_config"]
    if not name or name=="" then library:notify("Selecione uma config"); return end
    local path = "alora/"..tostring(game.GameId).."/"..name..".cfg"
    if isfile(path) then pcall(delfile, path); library:notify("Deletado: "..name); library:refreshConfigs()
    else library:notify("Config não encontrada") end
end

return library, menu, tabholder
