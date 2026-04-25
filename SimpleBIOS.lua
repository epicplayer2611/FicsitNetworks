--Allows running HDD programs just edit the program name!
--Allows editing programs from VSCode!
program = ""

--Simplify FileSystem
fs = filesystem

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
		errorBeep(program.." not detected.")
	end
end

--BIOS Start
print("BIOS Start")
computer.beep(1)
event.pull(1)
locateProgram(program)
