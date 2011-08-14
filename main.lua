-- Compiled from MoonScript at 1313284448
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
    for index = 1, GetNumRaidMembers() do
      nameList[GetRaidRosterInfo(index)] = true
    end
  end
  if GetNumPartyMembers() > 0 then
    for index = 1, GetNumPartyMembers() do
      nameList[UnitName("party" .. index)] = true
    end
  end
  return nameList
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
  local nameList = GetNameList()
  local matches = { }
  local lowered = word:lower()
  for name in pairs(nameList) do
    if name:lower():sub(0, #word) == lowered then
      tinsert(matches, name)
    end
  end
  if #matches == 1 then
    editbox:HighlightText(pos - word:len(), pos)
    editbox:Insert(matches[1])
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
