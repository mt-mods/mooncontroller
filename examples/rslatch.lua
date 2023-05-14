--R/S Latch
--When S is active, Q turns on.
--When R is active, Q turns off.
--/Q is always the opposite of Q.

--Pin Assignments:
-- S: Pin A
-- R: Pin B
-- Q: Pin C
--/Q: Pin D

if pin.a then
	port.c = true
elseif pin.b then
	port.c = false
end

port.d = not port.c
