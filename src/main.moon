export ChatEdit_CustomTabPressed

activeEditbox = ChatFrame1EditBox

GetNameList = ->
  nameList = {}
  
  for index = 1, GetNumFriends!
    name, _, _, _, online = GetFriendInfo(index)
    nameList[name] = true if online

  if IsInGuild()
    for index = 1, GetNumGuildMembers!
      name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(index)
      nameList[name] = true if online

  if GetNumRaidMembers! > 0
    for imdex = 1, GetNumRaidMembers!
      nameList[GetRaidRosterInfo(index)] = true

  if GetNumPartyMembers! > 0
    for i = 1, GetNumPartyMembers!
      nameList[UnitName("party" .. index)] = true

  nameList

GetPosition = ->
  return nil if activeEditbox\GetText! == ""

  activeEditbox\Insert("\255")
  pos = activeEditbox\GetText!\find("\255", 1) - 1

  activeEditbox\HighlightText(pos, pos + 1)
  activeEditbox\Insert("\0")

  pos

CompleteTab = ->
  pos = GetPosition!
  return nil if not pos

  full = activeEditbox\GetText!
  text = full\sub(1, pos)
  left = text\sub(1, pos)\find("%w+$")
  left = if left then left - 1 else pos

  return nil if not left or left == 1 and text\sub(1, 1) == "/"

  word = text\sub(left, pos)\match("(%w+)")
  return nil if not full\find("%a") or not word

  nameList = GetNameList!
  matches = {}

  lowered = word\lower!
  for name in pairs nameList
    tinsert(matches, name) if name\lower!\sub(0, #word) == lowered

  if #matches > 1
    ChatFrame1\AddMessage("|cff99cc33Potential matches:|r " .. table.concat(matches, ", "))
  elseif #matches == 1
    activeEditbox\HighlightText(pos - word\len(), pos)
    activeEditbox\Insert(matches[1])
    true
  false

OldHandler = ChatEdit_CustomTabPressed
ChatEdit_CustomTabPressed = (...) ->
  activeEditbox = nil

  for index, frame in pairs CHAT_FRAMES
    editbox = _G[frame .. "EditBox"]
    if editbox\GetText() != "" then
      activeEditbox = editbox
      break

  CompleteTab! if activeEditbox
  OldHandler(...) if OldHandler
