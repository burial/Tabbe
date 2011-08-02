local e = ChatFrame1EditBox -- active chat frame
local me = UnitName("player")

local matches = {}
local tablist = setmetatable({}, {
  __newindex = function(t, i, v)
    if i == me then
      rawset(t, i, nil)
    else
      rawset(t, strsplit("-", i), v)
    end
  end,
})

local function UpdateTab()
  wipe(tablist)

  for i = 1, GetNumFriends() do
    local name, _, _, _, online = GetFriendInfo(i)
    if online then 
      tablist[name] = true 
    end
  end

  if IsInGuild() then 
    for i = 1, GetNumGuildMembers() do
      local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
      if online then
        tablist[name] = true
      end
    end
  end

  if GetNumRaidMembers() > 0 then
    for i = 1, GetNumRaidMembers() do
      tablist[GetRaidRosterInfo(i)] = true
    end
  end

  if GetNumPartyMembers() > 0 then
    for i = 1, GetNumPartyMembers() do
      tablist[UnitName("party" .. i)] = true
    end
  end
end

local function GetPosition()
  if e:GetText() == "" then return end
  e:Insert("\255")
  local pos = e:GetText():find("\255", 1) - 1
  e:HighlightText(pos, pos + 1)
  e:Insert("\0")
  return pos
end

local function CompleteTab()
  local pos = GetPosition()
  if not pos then return end

  local full = e:GetText()
  local text = full:sub(1, pos)
  local left = text:sub(1, pos):find("%w+$")
  left = left and left - 1 or pos

  if not left or left == 1 and text:sub(1, 1) == "/" then  return end

  local word = text:sub(left, pos):match("(%w+)")
  if not full:find("%a") or not word then return  end

  UpdateTab()

  wipe(matches)

  for s in pairs(tablist) do
    if s:lower():sub(0, #word) == word:lower() then
      table.insert(matches, s)
    end
  end
  
  if #matches > 1 then
    ChatFrame1:AddMessage("|cff99cc33Potential matches:|r " .. table.concat(matches, ", "))
  elseif #matches == 1 then 
    e:HighlightText(pos - word:len(), pos)
    e:Insert(matches[1])
  end
end

do
  local OldHandler = ChatEdit_CustomTabPressed
  function ChatEdit_CustomTabPressed(...)
    for i = 1, 10 do
      local frame = _G["ChatFrame" .. i .. "EditBox"]
      if frame:GetText() ~= "" then
        e = frame
        break
      end
    end

    CompleteTab()

    if OldHandler then
      OldHandler(...)
    end
  end
end
