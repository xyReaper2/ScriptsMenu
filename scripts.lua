scriptbotPanelName = "scriptbot"

local ui = setupUI([[
Panel
  height: 19
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Scripts')
    font: verdana-11px-rounded

  Button
    id: settings
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
    font: verdana-11px-rounded
]])
ui:setId(scriptbotPanelName);

local windowUI = setupUI([[
UIWindow
  image-source: /bot/cavebot1/imagens/megumin
  size: 500 500

  Panel
    id: shadow
    opacity: 0.1
    background-color: black
    anchors.fill: parent

  Panel
    id: titlePanel
    anchors.top: parent.top
    anchors.left: parent.horizontalCenter
    text-align: center
    text-offset: 0 0
    margin-left: -20
    text: Scripts
    color: #99d6ff


  Label
    text: 
    margin-top: -3
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    text-wrap: true
    text-auto-resize: true
    text-align: left

  BotSwitch
    id: CheckPlayers
    anchors.top: prev.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 100
    margin-top: 8
    text-align: center
    text: Check Players
  
  BotSwitch
    id: escMsg
    anchors.top: prev.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 100
    margin-top: 8
    text-align: center
    text: Esconder Msg
  
  BotSwitch
    id: escSpr
    anchors.top: prev.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 100
    margin-top: 8
    text-align: center
    text: Esconder SPR
  
  BotSwitch
    id: autoPt
    anchors.top: prev.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 100
    margin-top: 8
    text-align: center
    text: Auto Party
  
  BotSwitch
    id: infoTarget
    anchors.top: prev.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 100
    margin-top: 8
    text-align: center
    text: Info Target
  
  BotSwitch
    id: CaveTar
    anchors.top: prev.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 100
    margin-top: 8
    text-align: center
    text: Cave/Target
  
  BotSwitch
    id: InfoJan
    anchors.top: prev.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 100
    margin-top: 8
    text-align: center
    text: Info Morte
  
  BotSwitch
    id: bugMapM
    anchors.top: prev.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 100
    margin-top: 8
    text-align: center
    text: Bug Map Mouse
  
  BotSwitch
    id: idleMode
    anchors.top: prev.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 100
    margin-top: 8
    text-align: center
    text: Idle Mode

  BotSwitch
    id: gotoTela
    anchors.top: prev.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 100
    margin-top: 8
    text-align: center
    text: Goto Na Tela

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-top: -1
    margin-right: -1

]], g_ui.getRootWidget());

windowUI:hide();

local configName = modules.game_bot.contentsPanel.config:getCurrentOption().text;
scriptbotConfig = {
    enabled = false,
};

scriptbot = {};

local MainPanel = windowUI

local lookDelay = 2000 -- intervalo entre look..
local checkDelay = 10*60*1000 -- só vai verificar o mesmo player de novo depois de 10min

local last = 0 -- ultima verificação

local toCheck = {} -- tabela de players a serem verificados (por causa do look delay)
local checked = {} -- tabela de quem ja foi verificado

--[[ Esconder Mensagens Laranjas ]]--
local TH = {
    enabled = true, -- Para desabilitar, mude para false
    isOff = function() return not TH.enabled end
}

onStaticText(function(thing, text)
    if not scriptbotConfig.enabled or not TH.enabled or not scriptbotConfig.escMsg then return end
    if not text:find('says:') then
        g_map.cleanTexts()
    end
end)

local sprh = {
    enabled = true, -- Para desabilitar, mude para false
    isOff = function() return not sprh.enabled end
}

onAddThing(function(tile, thing)
    if not scriptbotConfig.enabled or not sprh.enabled or not scriptbotConfig.escSpr then return end
    if thing:isEffect() then
        thing:hide()
    end
end)

local palavraChave = 'pt'
local autoPartyEnabled = true

onTalk(function(name, level, mode, text, channelId, pos)
    if not autoPartyEnabled or not scriptbotConfig.enabled or not scriptbotConfig.autoPt then return end
    if name == player:getName() then return end
    if mode ~= 1 then return end
    if string.find(text, palavraChave) then
        local friend = getPlayerByName(name)
        g_game.partyInvite(friend:getId())
    end
end)


local uitarget = setupUI([[
Panel
  height: 400
  width: 1500

  Label
    id: bossName
    text: None
    font: verdana-11px-rounded
    text-horizontal-auto-resize: true
    color: red
    text-align: center
  ProgressBar
    id: percent
    background-color: white
    text: 100%
    width: 150
    margin-right: 5

    ]], modules.game_interface.getMapPanel())

uitarget:hide()

macro(1, function()
  if (not ui.title:isOn()) then return; end
  if not scriptbotConfig.enabled or not scriptbotConfig.infoTarget then return end
if not g_game.isAttacking() then
 uitarget:hide()

elseif g_game.isAttacking() then
  uitarget:show()
  --- get attacking creature name
   local mob = g_game.getAttackingCreature()
   uitarget.bossName:setText("Name: ".. mob:getName())

  --- get attacking creature health percent
   local monsterHP = mob:getHealthPercent()
   uitarget.percent:setText(monsterHP.."%")
   uitarget.percent:setPercent(monsterHP)
   uitarget.percent:setFont("terminus-14px-bold")

  if monsterHP == 100 then 
    uitarget.percent:setBackgroundColor("white")
   elseif monsterHP > 75 then
    uitarget.percent:setBackgroundColor("green")
   elseif monsterHP > 50 then
    uitarget.percent:setBackgroundColor("yellow")
   elseif monsterHP > 25 then
    uitarget.percent:setBackgroundColor("orange")
   elseif monsterHP > 1 then
    uitarget.percent:setBackgroundColor("red")
  end
 end
end)  


g_ui.getRootWidget():recursiveGetChildById("bossName"):setPosition({x = 850, y = 105})
g_ui.getRootWidget():recursiveGetChildById("percent"):setPosition({x = 850, y = 120})


local cIcon = addIcon("cI",{text="Cave\nBot",switchable=false,moveable=true}, function()
  if not scriptbotConfig.enabled or not scriptbotConfig.CaveTar then return end
  if CaveBot.isOff() then 
    CaveBot.setOn()
  else 
    CaveBot.setOff()
  end
end)
cIcon:setSize({height=30,width=50})
cIcon.text:setFont('verdana-11px-rounded')

local tIcon = addIcon("tI",{text="Target\nBot",switchable=false,moveable=true}, function()
  if not scriptbotConfig.enabled or not scriptbotConfig.CaveTar then return end
  if TargetBot.isOff() then 
    TargetBot.setOn()
  else 
    TargetBot.setOff()
  end
end)
tIcon:setSize({height=30,width=50})
tIcon.text:setFont('verdana-11px-rounded')

macro(50,function()
  if not scriptbotConfig.enabled or not scriptbotConfig.CaveTar then return end
  if CaveBot.isOn() then
    cIcon.text:setColoredText({"CaveBot\n","white","ON","green"})
  else
    cIcon.text:setColoredText({"CaveBot\n","white","OFF","red"})
  end
  if TargetBot.isOn() then
    tIcon.text:setColoredText({"Target\n","white","ON","green"})
  else
    tIcon.text:setColoredText({"Target\n","white","OFF","red"})
  end
end)

macro(1, function()
	if not scriptbotConfig.enabled or not scriptbotConfig.InfoJan then return end
    if ui.title then
      if hppercent() > 0 then
          g_window.setTitle(name() .. " - ".. "Level: " .. lvl() .. " % " .. player:getLevelPercent())
      else
          g_window.setTitle(name() .. " - MORTO")
      end
    else
      g_window.setTitle(name() .. " - ".. "Level: " .. lvl() .. " % " .. player:getLevelPercent())
    end
  end)

macro(50, function(m)
	if not scriptbotConfig.enabled or not scriptbotConfig.bugMapM then return end
    --Made By VivoDibra#1182 
    local tile = getTileUnderCursor()
    if not tile then return end
    if tile:getTopThing() == g_game.getLocalPlayer() then  
        return m.setOff()
    end
    g_game.use(tile:getTopUseThing())
end)

------------------------------------------------------
local secondsToIdle = 5
local activeFPS =  60
---------------------------------------------------------

local afkFPS = 0
function botPrintMessage(message)
  modules.game_textmessage.displayGameMessage(message)
end

botPrintMessage("[Idle-Mode] made by: VivoDibra#1182")

local function isSameMousePos(p1,p2)
  return p1.x == p2.x and p1.y == p2.y
end

local function setAfk()
  modules.client_options.setOption("backgroundFrameRate", afkFPS)
  modules.game_interface.gameMapPanel:hide()
end

local function setActive()
  modules.client_options.setOption("backgroundFrameRate", activeFPS)
  modules.game_interface.gameMapPanel:show()
end

local lastMousePos = nil
local finalMousePos = nil
local idleCount = 0
local maxIdle = secondsToIdle * 4
macro(250, function()
	if not scriptbotConfig.enabled or not scriptbotConfig.idleMode then return end
  local currentMousePos = g_window.getMousePosition()

  if finalMousePos then
    if isSameMousePos(finalMousePos,currentMousePos) then return end
    botPrintMessage("(Idle Mode) Active!")
    setActive()
    finalMousePos = nil
  end

  if lastMousePos and isSameMousePos(lastMousePos,currentMousePos) then
    idleCount = idleCount + 1
  else
    lastMousePos = currentMousePos
    idleCount = 0
  end

  if idleCount == maxIdle then
    botPrintMessage("(Idle Mode) AFK!")
    setAfk()
    finalMousePos = currentMousePos
    idleCount = 0
  end

end)

macro(200, function()
  if not scriptbotConfig.enabled or not scriptbotConfig.gotoTela then return end
  local list = CaveBotList() 
  for index, child in ipairs(list:getChildren()) do
    if child.action == "goto" then
      local x = child.value:split(",")[1]
      local y = child.value:split(",")[2]
      local z = child.value:split(",")[3]
      local p = {x=x, y=y, z=z}
      local t = g_map.getTile(p)
      if t then
        local color = child:isFocused() and "yellow" or "white"
        t:setText(child.value, color)
      end
    end
  end
end)

local function checkPlayers()
  if not scriptbotConfig.enabled or not scriptbotConfig.CheckPlayers or os.time() - last < lookDelay then
    return
  end

  last = os.time()

  -- vendo quem ta na tela
  for s, spec in pairs(getSpectators()) do
    local pName = spec:getName()
    if spec ~= player and spec:isPlayer() then
      if not checked[pName] or checked[pName].last < os.time() then
        -- se nao foi verificado ainda, ou faz mt tempo, coloca na lista pra verificar (se já não estiver)
        if not table.find(toCheck,pName) then
          table.insert(toCheck,pName) 
        end
      else
        -- se ja foi, seta o texto nele
        spec:setText(checked[pName].text)
      end
    end
  end

  -- ver quem ta na lista toCheck
  for i, creature in pairs(toCheck) do
    table.remove(toCheck,i) -- remove da lista
    local find = getCreatureByName(creature) -- se encontrou, dá look
    if find then
      delay(lookDelay)
      return g_game.look(find)
    end
  end
end


onCreatureAppear(function(creature)
  if not scriptbotConfig.enabled or not scriptbotConfig.CheckPlayers then return end
  if creature == player or not creature:isPlayer() then return end
  local cName = creature:getName()
  if checked[name] and checked[name].last > os.time() then
    creature:setText(checked[name].text) -- ja foi verificada, seta o texto
    return
  end
  if os.time() - last >= lookDelay then
    local find = getCreatureByName(cName)
    if find then
      g_game.look(find) -- ja pode dar look
    end
  elseif not table.find(toCheck,cName) then
    table.insert(toCheck,cName) -- nao pode, colocar na lista
  end
end)

local pattern = 'You see (.+)%(Level (.+)%).'
onTextMessage(function(mode, text)
  if not scriptbotConfig.enabled or not scriptbotConfig.CheckPlayers then return end
  if not text:find("Level ") then return end

  local name, level = text:match(pattern) -- pegar nome e level pela msg de look
  name = name:trim()
  local text = 'Nome: ' .. name .. '\n Level: ' .. level -- texto q vai ficar no player

  checked[name] = checked[name] or {}
  checked[name].last = os.time() + checkDelay -- intervalo que vai ficar sem checar o mesmo player
  checked[name].text = text

  local find = getCreatureByName(name)
  if find then
    find:setText(text) -- seta o texto ja
  end
end)


scriptbot.save = function()
  -- Implemente a lógica para salvar as configurações do bot aqui
  -- Por exemplo, você pode salvar scriptbotConfig em um arquivo ou em algum banco de dados
end

-- Adicionando funcionalidades da interface do usuário
ui.title:setOn(scriptbotConfig.enabled);
ui.title.onClick = function(widget)
  scriptbotConfig.enabled = not scriptbotConfig.enabled;
  widget:setOn(scriptbotConfig.enabled);
  scriptbot.save();
end

ui.settings.onClick = function(widget)
  windowUI:show();
  windowUI:raise();
  windowUI:focus();
end

windowUI.closeButton.onClick = function(widget)
  windowUI:hide();
  scriptbot.save();
end

MainPanel.CheckPlayers:setOn(scriptbotConfig.CheckPlayers);
MainPanel.CheckPlayers.onClick = function(widget)
  scriptbotConfig.CheckPlayers = not scriptbotConfig.CheckPlayers;
  widget:setOn(scriptbotConfig.CheckPlayers);
end

MainPanel.escMsg:setOn(scriptbotConfig.escMsg);
MainPanel.escMsg.onClick = function(widget)
  scriptbotConfig.escMsg = not scriptbotConfig.escMsg;
  widget:setOn(scriptbotConfig.escMsg);
end

MainPanel.escSpr:setOn(scriptbotConfig.escSpr);
MainPanel.escSpr.onClick = function(widget)
  scriptbotConfig.escSpr = not scriptbotConfig.escSpr;
  widget:setOn(scriptbotConfig.escSpr);
end

MainPanel.autoPt:setOn(scriptbotConfig.autoPt);
MainPanel.autoPt.onClick = function(widget)
  scriptbotConfig.autoPt = not scriptbotConfig.autoPt;
  widget:setOn(scriptbotConfig.autoPt);
end

MainPanel.infoTarget:setOn(scriptbotConfig.infoTarget);
MainPanel.infoTarget.onClick = function(widget)
  scriptbotConfig.infoTarget = not scriptbotConfig.infoTarget;
  widget:setOn(scriptbotConfig.infoTarget);
end

MainPanel.CaveTar:setOn(scriptbotConfig.CaveTar);
MainPanel.CaveTar.onClick = function(widget)
  scriptbotConfig.CaveTar = not scriptbotConfig.CaveTar;
  widget:setOn(scriptbotConfig.CaveTar);
end

MainPanel.InfoJan:setOn(scriptbotConfig.InfoJan);
MainPanel.InfoJan.onClick = function(widget)
  scriptbotConfig.InfoJan = not scriptbotConfig.InfoJan;
  widget:setOn(scriptbotConfig.InfoJan);
end

MainPanel.bugMapM:setOn(scriptbotConfig.bugMapM);
MainPanel.bugMapM.onClick = function(widget)
  scriptbotConfig.bugMapM = not scriptbotConfig.bugMapM;
  widget:setOn(scriptbotConfig.bugMapM);
end

MainPanel.idleMode:setOn(scriptbotConfig.idleMode);
MainPanel.idleMode.onClick = function(widget)
  scriptbotConfig.idleMode = not scriptbotConfig.idleMode;
  widget:setOn(scriptbotConfig.idleMode);
end

MainPanel.gotoTela:setOn(scriptbotConfig.gotoTela);
MainPanel.gotoTela.onClick = function(widget)
  scriptbotConfig.gotoTela = not scriptbotConfig.gotoTela;
  widget:setOn(scriptbotConfig.gotoTela);
end