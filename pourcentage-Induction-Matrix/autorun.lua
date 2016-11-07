-- % induction matrix
-- programme réalisé par redsarow
-- nommer ce fichier autorun.lua pour un lancement automatique au démarage de l'ordi

-- modification utilisateur

local pasageVer = 90
local passageOrange = 20
local tempo = 0.5 -- (en second) temps de refresh
local hasSignRedstone = true -- activer / désactiver signale redstone
local onSignRedstone = 100 -- signale redstone à x%

-- fin modification utilisateur

---------------------

local computer = require("computer")
local component = require("component")
local term = require("term")
local event = require("event")
local keyboard = require("keyboard")
local math = require("math")

local gpu = component.gpu
local induction_matrix = component.induction_matrix
local rs = nil
if signRedstone then
	rs = component.redstone
end

---------------------

local maxEnergie = induction_matrix.getMaxEnergy()
local maxX = 25
local maxY = 54

gpu.setResolution(maxX, maxY)

local function loadBar()
	local energi = induction_matrix.getEnergy()
	local x = maxX-2
	local y = maxY-4

	local h = math.floor( energi*(y/maxEnergie))
	local p = math.floor( (energi/maxEnergie)*100)
	
	gpu.setBackground(0x000000)
	gpu.set(1,2," Induction Matrix à "..tostring( p ) .. "%   " )
	
	gpu.setBackground(0x222222)
	gpu.fill( 2, 4, x, y, " " )
	
	-- modification des palier de changement de couleur 
	-- (les couleurs sont sous forme hexadécimale)
	if p>=pasageVer then 
		gpu.setBackground(0x00FF00)
	elseif p>=passageOrange then
		gpu.setBackground(0xFFa500)
	else
		gpu.setBackground(0xFF0000)
	end
	
	---------------
	
	gpu.fill( 2, y-h+4, x, y-(y-h), " " )
	
	if signRedstone then
		if p >= onSignRedstone then
			for i=0, 5 do
				rs.setOutput(i,15)
			end
		else
			for i=0, 5 do
				rs.setOutput(i,0)
			end
		end
	end
end 

-- fonction pour stopper le programme
local function stop(_,_,c,d)
	if keyboard.keys[d]=="c" and keyboard.isControlDown() then
		os.sleep(1)
		computer.pushSignal("stop")
	end
end

-- clear
term.clear()
gpu.setBackground(0x000000)
gpu.fill( 0,0, maxX+1, maxY+1, " " )

-- event 

event.listen("key_down",stop)
local timer = event.timer(tempo, loadBar, math.huge)

event.pull("stop")

event.ignore("key_down",stop)
event.cancel(timer)

--fin event
-- clear

if signRedstone then
	for i=0, 5 do
		rs.setOutput(i,0)
	end
end

term.clear()
gpu.setBackground(0x000000)
gpu.fill( 0,0, maxX+1, maxY+1, " " )
gpu.setResolution(gpu.maxResolution())
