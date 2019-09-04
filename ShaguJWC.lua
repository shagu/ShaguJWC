-- init variables
local fireworks, window
local filter = string.gsub(LOOT_ITEM_SELF,"%%s", "(.+)")
local filtermulti = string.gsub(LOOT_ITEM_SELF_MULTIPLE,"%%s", "(.+)")
filtermulti = string.gsub(filtermulti,"%%d", "(.+)")
local slots = {}

SLASH_SHAGUJWC1, SLASH_SHAGUJWC2 = "/jwc", "/sjwc"
SlashCmdList["SHAGUJWC"] = function()
  if not window:IsShown() then window:Show() else window:Hide() end
end

-- global function to use inside button macro
ShaguJWC_Random = function()
  window.running = GetTime()
end

do -- animation
  fireworks = CreateFrame("Frame", nil, WorldFrame)
  fireworks:SetFrameStrata("BACKGROUND")
  fireworks:SetAllPoints()
  fireworks:Hide()

  -- basic explosion animation
  local function animation()
    this:SetWidth(this:GetWidth()+2)
    this:SetHeight(this:GetHeight()+2)
    this:SetAlpha(this:GetAlpha() - .05)
    if this:GetAlpha() <= 0 then
      this.free = true
      this:Hide()
    end
  end

  -- cache explosions to reuse frames
  local explosions = {}
  local function GetExplosion()
    for id, frame in pairs(explosions) do
      if frame.free then
        frame.free = nil
        return frame
      end
    end

    local frame = CreateFrame("Frame", nil, fireworks)
    frame:SetScript("OnUpdate", animation)
    frame.tex = frame:CreateTexture("HIGH")
    frame.tex:SetAllPoints()

    table.insert(explosions, frame)

    return frame
  end

  -- create random amount of fireworks at random positions
  local width, height = GetScreenWidth(), GetScreenHeight()
  fireworks:SetScript("OnUpdate", function()
    if not window:IsShown() then this:Hide() end

    -- fade in the night
    if this:GetAlpha() < 1 then
      this:SetAlpha(this:GetAlpha() + .02)
      return
    end

    if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + math.random() - .6 end

    local x,y = math.random(1, width), -1*math.random(1,height)

    -- create the base explosion
    local f = GetExplosion()
    f:ClearAllPoints()
    f:SetPoint("CENTER", fireworks, "TOPLEFT", x, y)
    f:SetWidth(25)
    f:SetHeight(25)
    f.tex:SetTexture(1,1,1,.5)
    f:SetAlpha(1)
    f:Show()

    -- create random amount of colored explosions
    for i=1, math.random(20) do
      local f = GetExplosion()
      f:ClearAllPoints()
      f:SetPoint("CENTER", fireworks, "TOPLEFT", x+(math.random(0,100)-50), y+(math.random(0,100)-50))
      f:SetWidth(2)
      f:SetHeight(2)
      f.tex:SetTexture(math.random(),math.random(),math.random(),1)
      f:SetAlpha(1)
      f:Show()
    end
  end)
end

do -- window
  local function CreateSlot()
    local f = CreateFrame("Button", nil, window)
    -- icon
    f.icon = f:CreateTexture(nil, "BACKGROUND")
    f.icon:SetAllPoints()

    -- border
    f.border = f:CreateTexture(nil, "BORDER")
    f.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    f.border:SetBlendMode("ADD")
    f.border:SetPoint("CENTER", 0, 0)

    -- count
    f.count = f:CreateFontString(nil, "OVERLAY", "GameFontWhite")
    f.count:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    f.count:SetPoint("BOTTOMRIGHT", -3, 3)

    return f
  end

  window = CreateFrame("Frame", nil, UIParent)
  window:SetPoint("CENTER", 0, 0)
  window:SetWidth(300)
  window:SetHeight(200)
  window:SetBackdrop({
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 16,
    insets = {left = 5, right = 5, top = 5, bottom = 5},
  })

  window:SetMovable(true)
  window:EnableMouse(true)
  window:SetScript("OnMouseDown", function() this:StartMoving() end)
  window:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)
  window:Hide()

  window.bg = window:CreateTexture(nil, "BACKGROUND")
  window.bg:SetTexture(0,0,0,.4)
  window.bg:SetAllPoints()

  -- close
  window.close = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
  window.close:SetWidth(16)
  window.close:SetHeight(16)
  window.close:SetText("X")
  window.close:SetPoint("TOPRIGHT", -4, -4)
  window.close:SetScript("OnClick", function()
    window:Hide()
  end)

  -- gamble button
  window.button = CreateFrame("Button", nil, window, "UIPanelButtonTemplate,SecureActionButtonTemplate")
  window.button:SetPoint("BOTTOM", window, "BOTTOM", 0, 16)
  window.button:SetWidth(150)
  window.button:SetHeight(24)
  window.button:SetText("Gamble!")
  window.button:SetAttribute("type1", "macro")
  window.button:RegisterForClicks("AnyUp")

  -- item
  local function DropItem()
    local cursor, id, itemlink = GetCursorInfo()
    if cursor == "item" then
      local name, link, rarity, level, min, itype, isubtype, istackcount, itemEquipLoc, texture = GetItemInfo(itemlink)
      window.button:SetAttribute("macrotext1", string.format("/cast Prospecting\n/use %s\n/run ShaguJWC_Random()", name))
      this.icon:SetTexture(texture)
      this.border:SetVertexColor(GetItemQualityColor(rarity))
      this.item = name
      ClearCursor()
    end
  end
  window.drag = CreateSlot()
  window.drag:SetPoint("TOP", 0, -16)
  window.drag:SetWidth(32)
  window.drag:SetHeight(32)
  window.drag:RegisterForDrag("LeftButton")
  window.drag:SetScript("OnClick", DropItem)
  window.drag:SetScript("OnReceiveDrag", DropItem)

  -- slots
  window.slots = { }
  window.slots[1] = CreateSlot()
  window.slots[1]:SetPoint("CENTER", window, "CENTER", 0, 0)
  window.slots[1]:SetWidth(64)
  window.slots[1]:SetHeight(64)
  window.slots[1].border:SetWidth(128)
  window.slots[1].border:SetHeight(128)
  window.slots[1].border:SetVertexColor(.2,.2,.2,1)

  window.slots[2] = CreateSlot()
  window.slots[2]:SetPoint("LEFT", window, "LEFT", 32, 0)
  window.slots[2]:SetWidth(32)
  window.slots[2]:SetHeight(32)
  window.slots[2].border:SetWidth(64)
  window.slots[2].border:SetHeight(64)
  window.slots[2].border:SetVertexColor(.2,.2,.2,1)

  window.slots[3] = CreateSlot()
  window.slots[3]:SetPoint("RIGHT", window, "RIGHT", -32, 0)
  window.slots[3]:SetWidth(32)
  window.slots[3]:SetHeight(32)
  window.slots[3].border:SetWidth(64)
  window.slots[3].border:SetHeight(64)
  window.slots[3].border:SetVertexColor(.2,.2,.2,1)

  -- animation
  window:SetScript("OnUpdate", function()
    this.drag.count:SetText(GetItemCount(this.drag.item))

    if not this.running then return end

    -- disable fireworks while running
    fireworks:Hide()

    -- limmit updates to once per .1 seconds
    if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .1 end

    -- detect aborted/failed casts and reset all
    if this.running + .3 < GetTime() and not UnitCastingInfo("player") then
      for i=1,3 do this.slots[i].border:SetVertexColor(1,1,1) end
      this.running = nil
      return
    end

    for i=1,3 do
      -- clear texture and animate borders
      this.slots[i].icon:SetTexture(0,0,0)
      this.slots[i].border:SetVertexColor(math.random(), math.random(), math.random())
      this.slots[i].count:SetText("")
    end
  end)
end

do -- loot handler
  local function AddLootToSlot(itemlink, count)
    local name, link, rarity, level, min, itype, isubtype, istackcount, itemEquipLoc, texture = GetItemInfo(itemlink)
    table.insert(slots, { name, rarity, texture, count })
    table.sort(slots, function(a,b)
      if ( not b or not b[2]) then
        return false
      else
        return a[2] > b[2]
      end
    end)

    for i=1,3 do
      local index = i

      -- skip the big icon when less than 3 results are available
      if not slots[3] then
        index = i + 1
        window.slots[1].icon:SetTexture(0,0,0)
        window.slots[1].border:SetVertexColor(GetItemQualityColor(0))
        window.slots[1].count:SetText("")
        if index > 3 then break end
      end

      window.slots[index].icon:SetTexture(slots[i] and slots[i][3] or 0, 0, 0)
      window.slots[index].border:SetVertexColor(GetItemQualityColor(slots[i] and slots[i][2] or 0))
      window.slots[index].count:SetText(slots[i] and slots[i][4] ~= 0 and slots[i][4] or "")
    end

    if slots[1] and slots[1][2] and slots[1][2] > 2 then fireworks:Show() end
  end

  local lootscan = CreateFrame("Frame")
  lootscan:RegisterEvent("CHAT_MSG_LOOT")
  lootscan:SetScript("OnEvent", function()
    window.running = nil

    local _, _, item, count = string.find(arg1, filtermulti)
    if not item then _, _, item, count= string.find(arg1, filter) end

    count = count or 0

    if item then

      -- detect and initiate new loot events
      if (this.lasttime or 0) + .2 < GetTime() then
        slots = {}
        this.lasttime = GetTime()
      end

      -- add slot to the window
      AddLootToSlot(item, count)
    end
  end)
end
