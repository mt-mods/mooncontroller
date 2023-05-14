--Interrupt-Driven Clock
--Continually pulses pin A, turning on/off once per second.

if event.type == "program" or event.iid == "clock" then
	port.a = not port.a
	interrupt(1,"clock",true)
end
