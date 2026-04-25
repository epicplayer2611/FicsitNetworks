--Github Files
FactoryOS = "https://github.com/epicplayer2611/FicsitNetworks/tree/main/FactoryOS/OperatingSystem/"
FactoryOSProgram = "Boot.lua"

--Simplify filesystem
fs = filesystem

--Required Devices table
local requiredDevices = {
    {"GPU T2", classes.FINComputerGPUT2},
    {"Network Card", classes.NetworkCard},
    {"Screen Driver", classes.FINComputerScreen},
    {"Internet Card", classes.FINInternetCard}
}

function successfulBeep(message)
	computer.beep(1)
	event.pull(0.1)
	computer.beep(1.5)
	print(message.." Successful Beep!")
end

function errorBeep(message)
	computer.beep(0.9)
	event.pull(0.1)
	computer.beep(0.8)
	computer.panic(message.." Error Beep!")
end

-- Iterate through the table and check for each device
function detectComponents()
	for _, device in ipairs(requiredDevices) do
    	local name, class = device[1], device[2]
    	local devices = computer.getPCIDevices(class)
    	if #devices > 0 then
        	print(name .. ": Installed (" .. #devices .. ")")
        	event.pull(0.1)
    	else
        	errorBeep(name .. ": MISSING!")
        	event.pull(0.1)
    	end
	end
	successfulBeep("All necessary components detected!")
end

--AutoInstall Operating System
function installOS(URL, program)
	local card = computer.getPCIDevices(classes.FINInternetCard)[1]
	local req = card:request(URL..program,"GET","")
	local _, libdata = req:await()
	fs.initFileSystem("/dev")
	fs.makeFileSystem("tmpfs","tmp")
	fs.mount("/dev/tmp","/")
	local file = filesystem.open(program,"w")
	file:write(libdata)
	file:close()
	
end

--Locate OS
function locateProgram(program)
	if not fs.initFileSystem("/dev") then errorBeep("No /dev!") end
	local drives = fs.children("/dev")
	if #drives == 0 then 
		errorBeep("No Drive found!") 
	else
		local drive = drives[1]
		fs.mount("/dev/"..drive,"/")
		successfulBeep("Harddrive found!")
	end
	event.pull(1)
	if fs.exists("/"..program) then
		successfulBeep("Running "..program)
		fs.doFile("/"..program)
	else
		installOS(FactoryOS,FactoryOSProgram)
	end
end

--BIOS Start
print("BIOS Start")
computer.beep(1)
event.pull(1)
detectComponents()
event.pull(1)
locateProgram("osBoot.lua")
