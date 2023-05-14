--LCD Counter (requires digilines)
--Counts the number of pulses sent to pin A and displays the number on an LCD.
--Connect the LCD over digilines and set the channel to "lcd"

if event.type == "program" then
	mem.count = 0
elseif event.type == "on" and event.pin.name == "A" then
	mem.count = mem.count + 1
end

digiline_send("lcd",tostring(mem.count))
