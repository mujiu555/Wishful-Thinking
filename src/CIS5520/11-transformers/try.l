x = 0
y = 1
try 
  if (x + y) then
     a = 100
     throw (x + y)
     b = 200
  else end 
handle e with
  z = e + a
