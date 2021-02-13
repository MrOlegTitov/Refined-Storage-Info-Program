-- Import libraries
local GUI = require("GUI")
local image = require("Image")
local system = require("System")
local component = require("component")
local fs = require("Filesystem")
local event = require("Event")
local number = require("Number")
local internet = require("Internet")
local text = require("Text")
local screen = require("Screen")
---------------------------------------------------------------------------------
local disk_dirve

local l = system.getCurrentScriptLocalization()
local SD = fs.path(system.getCurrentScript())
local workspace, window = system.addWindow(GUI.filledWindow(1, 1, 120, 35, 0xE1E1E1))

local menu = workspace:addChild(GUI.menu(1, 1, workspace.width, 0xEEEEEE, 0x666666, 0x3366CC, 0xFFFFFF))
if component.isAvailable("block_refinedstorage_disk_drive") then
  disk_dirve = component.get("block_refinedstorage_disk_drive")
else
  GUI.alert(l.noRefinedStorage)
  window:remove()
  menu:remove()
end
local FileM = menu:addContextMenuItem(l.menuPTT)
FileM:addItem(l.menuCLS).onTouch = function()
  window:remove()
  menu:remove()
end

window.showDesktopOnMaximize = true

window.actionButtons.close.onTouch = function()
  window:remove()
  menu:remove()
end
  
local list = window:addChild(GUI.list(1, 4, 22, 1, 3, 0, 0x4B4B4B, 0xE1E1E1, 0x4B4B4B, 0xE1E1E1, 0xE1E1E1, 0x3C3C3C))
local listCover = window:addChild(GUI.panel(1, 1, list.width, 3, 0x4B4B4B))
local layout = window:addChild(GUI.layout(list.width + 1, 1, 1, 1, 1, 1))
  
local lx = layout.localX
  
window.backgroundPanel.localX = lx
  
function n2s(num)
  return number.roundToDecimalPlaces(num, 3)
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function splitString (inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

local function addTab(text, func)
  list:addItem(text).onTouch = function()
    layout:removeChildren()
    func()
    workspace:draw()
  end
end
  
local function addText(text)
  newText = layout:addChild(GUI.text(workspace.width, 0, 0x3C3C3C, text))
  return newText
end
  
local function addButton(text, func)
  newButton = layout:addChild(GUI.roundedButton(1, 1, 35, 3, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, text))
  newButton.onTouch = function()
    func()
  end
  return newButton
end

local function addSwitch(func)
  newSwitch = layout:addChild(GUI.switch(3, 2, 8, 0x66DB80, 0x1D1D1D, 0xEEEEEE, false))
  newSwitch.onStateChanged = function(state)
    func()
  end
  return newSwitch
end

local function addInput(xSize, ySize, placeholder, finishFunc)
  newInput = layout:addChild(GUI.input(1, 1, xSize, ySize, 0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, "", placeholder))
  if finishFunc ~= nil then
    newInput.onInputFinished = finishFunc()
  end
end

local function addComboBox()
  newCombobox = layout:addChild(GUI.comboBox(3, 2, 30, 3, 0xEEEEEE, 0x2D2D2D, 0xCCCCCC, 0x888888))
  return newCombobox
end

local function addList(posX, posY, sizeX, sizeY)
  newList = layout:addChild(GUI.list(posX, posY, sizeX, sizeY, 3, 0, 0xEEEEEE, 0x2D2D2D, 0xCCCCCC, 0x888888, 0x3366CC, 0xFFFFFF, false))
  return newList
end

local function drawIcon(pic)
  return layout:addChild(GUI.image(2, 2, image.load(pic)))
end

-- Main Program:
addTab(l.helloTT, function() --Hello TAB
  drawIcon(SD .. "Icon.pic")
  addText(l.greeting .. system.getUser() .. "!")
end)

addTab(l.disksTT, function() --InfoTAB
  addText(l.disksTLT)
  storagesList = addList(2, 2, layout.width-10, layout.height*0.5)
  storageDevices = disk_dirve.getStorages()["devices"]
  disksCount = tablelength(storageDevices)
  for i = 1, disksCount-1 do
    if storageDevices[i]["type"] == "item" then
      storagesList:addItem(l.disksTSD.. ", ".. l.disksTDS.. tostring(storageDevices[i]["usage"]).. l.bytes.. " / ".. tostring(storageDevices[i]["capacity"]).. l.bytes)
    else
      storagesList:addItem(l.disksTFD.. ", ".. l.disksTDF.. tostring(storageDevices[i]["usage"]).. l.bytes.. " / ".. tostring(storageDevices[i]["capacity"]).. l.bytes)
    end
  end
  energyUsage = addText(l.disksTEU.. tostring(disk_dirve.getEnergyUsage()).. " / 32000 FE")
  storagesList.eventHandler = function(workspace, list, e1, e2, e3, e4, e5)
    if e1 == "scroll" then
      local horizontalMargin, verticalMargin = storagesList:getMargin()
      storagesList:setMargin(horizontalMargin, math.max(-storagesList.itemSize * (#storagesList.children - 1), math.min(0, verticalMargin + e5)))
      workspace:draw()
    end
  end
end)

addTab(l.craftTT, function() -- Auto Crafts TAB
  addText(l.craftTPL)
  patternsList = addList(1,1,layout.width-10, layout.height*0.25)
  itemPatterns = disk_dirve.getPatterns()
  canProceed = false
  for i = 1, itemPatterns["n"] do
    patternsList:addItem(l.craftTIN.. itemPatterns[i]["label"].. ",".. itemPatterns[i]["name"])
  end
  craftCount = addComboBox()
  for i = 1,64 do
    craftCount:addItem(tostring(i))
  end
  addButton(l.craftTCB, function()
    selItemID = splitString(patternsList:getItem(patternsList.selectedItem)["text"], ",")
    disk_dirve.scheduleTask({["name"]=selItemID[2]}, tonumber(craftCount:getItem(craftCount.selectedItem)["text"]))
  end)
  patternsList.eventHandler = function(workspace, list, e1, e2, e3, e4, e5)
    if e1 == "scroll" then
      local horizontalMargin, verticalMargin = patternsList:getMargin()
      patternsList:setMargin(horizontalMargin, math.max(-patternsList.itemSize * (#patternsList.children - 1), math.min(0, verticalMargin + e5)))
      workspace:draw()
    end
  end
  
end)

addTab(l.aboutTT, function()
  addText(l.aboutTC.. "MrOlegTitovOffc")
  addText(l.aboutTV.. "1.0 Release")
  addText(l.aboutTB.. "https://github.com/MrOlegTitov/Refined-Storage-Info-Program")
  addText(l.aboutTTY)
  addText(l.aboutTR)
end)

 -- GUI Actions:
list.eventHandler = function(workspace, list, e1, e2, e3, e4, e5)
  if e1 == "scroll" then
    local horizontalMargin, verticalMargin = list:getMargin()
    list:setMargin(horizontalMargin, math.max(-list.itemSize * (#list.children - 1), math.min(0, verticalMargin + e5)))

    workspace:draw()
  end
end

local function calculateSizes()
  list.height = window.height

  window.backgroundPanel.width = window.width - list.width
  window.backgroundPanel.height = window.height

  layout.width = window.backgroundPanel.width
  layout.height = window.height
  
  list:getItem(list.selectedItem).onTouch()
end

window.onResize = function()
  calculateSizes()
end

calculateSizes()
window.actionButtons:moveToFront()
list:getItem(1).onTouch()
