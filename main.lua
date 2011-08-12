local activeEditbox = ChatFrame1EditBox
local GetNameList
GetNameList = function()
  local nameList = { }
  for index = 1, GetNumFriends() do
    local name, _, _, _, online = GetFriendInfo(index)
    if online then
      nameList[name] = true
    end
  end
  if IsInGuild() then
    for index = 1, GetNumGuildMembers() do
      local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(index)
      if online then
        nameList[name] = true
      end
    end
  end
  if GetNumRaidMembers() > 0 then
    for imdex = 1, GetNumRaidMembers() do
      nameList[GetRaidRosterInfo(index)] = true
    end
  end
  if GetNumPartyMembers() > 0 then
    for i = 1, GetNumPartyMembers() do
      nameList[UnitName("party" .. index)] = true
    end
  end
  return nameList
end
local GetPosition
GetPosition = function()
  if activeEditbox:GetText() == "" then
    return nil
  end
  activeEditbox:Insert("\255")
  local pos = activeEditbox:GetText():find("\255", 1) - 1
  activeEditbox:HighlightText(pos, pos + 1)
  activeEditbox:Insert("\0")
  return pos
end
local CompleteTab
CompleteTab = function()
  local pos = GetPosition()
  if not pos then
    return nil
  end
  local full = activeEditbox:GetText()
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
  local nameList = GetNameList()
  local matches = { }
  local lowered = word:lower()
  for name in pairs(nameList) do
    if name:lower():sub(0, #word) == lowered then
      tinsert(matches, name)
    end
  end
  if #matches > 1 then
    ChatFrame1:AddMessage("|cff99cc33Potential matches:|r " .. table.concat(matches, ", "))
  elseif #matches == 1 then
    activeEditbox:HighlightText(pos - word:len(), pos)
    activeEditbox:Insert(matches[1])
    local _ = true
  end
  return false
end
local OldHandler = ChatEdit_CustomTabPressed
ChatEdit_CustomTabPressed = function(...)
  activeEditbox = nil
  for index, frame in pairs(CHAT_FRAMES) do
    local editbox = _G[frame .. "EditBox"]
    if editbox:GetText() ~= "" then
      activeEditbox = editbox
      break
    end
  end
  if not activeEditbox then
    return nil
  end
  CompleteTab()
  if OldHandler then
    return OldHandler(...)
  end
end
