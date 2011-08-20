local me = UnitName("player")
local mt = {
  __newindex = function(self, index, value)
    return rawset(self, strsplit("-", index), value)
  end
}
local onlines = setmetatable({ }, mt)
local offlines = setmetatable({ }, mt)
local GetNameList
GetNameList = function()
  wipe(onlines)
  wipe(offlines)
  for index = 1, GetNumFriends() do
    local name, _, _, _, online = GetFriendInfo(index)
    if online then
      onlines[name] = true
    else
      offlines[name] = true
    end
  end
  if IsInGuild() then
    for index = 1, GetNumGuildMembers() do
      local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(index)
      if online then
        onlines[name] = true
      else
        offlines[name] = true
      end
    end
  end
  if GetNumRaidMembers() > 0 then
    for index = 1, GetNumRaidMembers() do
      onlines[GetRaidRosterInfo(index)] = true
    end
  end
  if GetNumPartyMembers() > 0 then
    for index = 1, GetNumPartyMembers() do
      onlines[UnitName("party" .. index)] = true
    end
  end
  local target = UnitName("target")
  if target then
    onlines[target] = true
  end
  local focus = UnitName("focus")
  if focus then
    onlines[focus] = true
  end
end
local GetPosition
GetPosition = function(editbox)
  if editbox:GetText() == "" then
    return nil
  end
  editbox:Insert("\255")
  local pos = editbox:GetText():find("\255", 1) - 1
  editbox:HighlightText(pos, pos + 1)
  editbox:Insert("\0")
  return pos
end
local CompleteTab
CompleteTab = function(editbox)
  local pos = GetPosition(editbox)
  if not pos then
    return nil
  end
  local full = editbox:GetText()
  local text = full:sub(1, pos)
  local left = text:sub(1, pos):find("%w+$")
  if left then
    left = left - 1
  else
    left = pos
  end
  if not left or left == 1 and text:sub(1, 1) == "/" then
    return nil
  end
  local word = text:sub(left, pos):match("(%w+)")
  if not full:find("%a") or not word then
    return nil
  end
  GetNameList()
  local matches = { }
  local lowered = word:lower()
  for name in pairs(onlines) do
    if name:lower():sub(0, #word) == lowered then
      tinsert(matches, name)
    end
  end
  if IsShiftKeyDown() then
    for name in pairs(offlines) do
      if name:lower():sub(0, #word) == lowered then
        tinsert(matches, name)
      end
    end
  end
  if #matches == 1 then
    local name
    if word == lowered then
      name = matches[1]:lower()
    else
      name = matches[1]
    end
    editbox:HighlightText(pos - word:len(), pos)
    editbox:Insert(name)
    return true
  elseif #matches > 1 then
    ChatFrame1:AddMessage("|cff99cc33Potential matches:|r " .. table.concat(matches, ", "))
    return false
  else
    return false
  end
end
local OldHandler = ChatEdit_CustomTabPressed
ChatEdit_CustomTabPressed = function(...)
  local activeEditbox = nil
  for index, frame in pairs(CHAT_FRAMES) do
    local editbox = _G[frame .. "EditBox"]
    if editbox:GetText() ~= "" then
      activeEditbox = editbox
      break
    end
  end
  if activeEditbox then
    CompleteTab(activeEditbox)
  end
  if OldHandler then
    return OldHandler(...)
  end
end
