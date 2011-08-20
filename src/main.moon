export ChatEdit_CustomTabPressed

mt = __newindex: (index, value) => rawset(self, strsplit("-", index), value)
onlines = setmetatable({}, mt)
offlines = setmetatable({}, mt)

GetNameList = ->
  wipe(onlines)
  wipe(offlines)
  
  for index = 1, GetNumFriends!
    name, _, _, _, online = GetFriendInfo(index)

    if online
      onlines[name] = true
    else
      offlines[name] = true

  if IsInGuild()
    for index = 1, GetNumGuildMembers!
      name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(index)

      if online
        onlines[name] = true
      -- else
      --  offlines[name] = true

  if GetNumRaidMembers! > 0
    for index = 1, GetNumRaidMembers!
      onlines[GetRaidRosterInfo(index)] = true

  if GetNumPartyMembers! > 0
    for index = 1, GetNumPartyMembers!
      onlines[UnitName("party" .. index)] = true

  target = UnitName("target")
  onlines[target] = true if target

  focus = UnitName("focus")
  onlines[focus] = true if focus

GetPosition = (editbox) ->
  return nil if editbox\GetText! == ""

  editbox\Insert("\255")
  pos = editbox\GetText!\find("\255", 1) - 1

  editbox\HighlightText(pos, pos + 1)
  editbox\Insert("\0")

  pos

CompleteTab = (editbox) ->
  pos = GetPosition(editbox)
  return nil if not pos

  full = editbox\GetText!
  text = full\sub(1, pos)
  left = text\sub(1, pos)\find("%w+$")
  left = if left then left - 1 else pos

  return nil if not left or left == 1 and text\sub(1, 1) == "/"

  word = text\sub(left, pos)\match("(%w+)")
  return nil if not full\find("%a") or not word

  GetNameList!

  matches = {}
  lowered = word\lower!

  for name in pairs(onlines)
    tinsert(matches, name) if name\lower!\sub(0, #word) == lowered

  if IsShiftKeyDown!
    for name in pairs(offlines)
      tinsert(matches, name) if name\lower!\sub(0, #word) == lowered

  if #matches == 1
    name = if word == lowered
      matches[1]\lower!
    else
      matches[1]

    editbox\HighlightText(pos - word\len(), pos)
    editbox\Insert(name)
    true
  elseif #matches > 1
    ChatFrame1\AddMessage("|cff99cc33Potential matches:|r " .. table.concat(matches, ", "))
    false
  else
    false

OldHandler = ChatEdit_CustomTabPressed
ChatEdit_CustomTabPressed = (...) ->
  activeEditbox = nil

  for index, frame in pairs CHAT_FRAMES
    editbox = _G[frame .. "EditBox"]
    if editbox\GetText! != "" then
      activeEditbox = editbox
      break

  CompleteTab(activeEditbox) if activeEditbox
  OldHandler(...) if OldHandler
