local bt={}

input=io.lines()
for line in input do
   _,_,len=string.find(line, '^backtrace returned: (%d%d)$')
   if len then
      len=(tonumber(len)-2) 
      local s=""
      for i=1,len do
	 s=s .. input() .. '\n'
      end
      if bt[s] then
	 bt[s]=bt[s]+1
      else
	 bt[s]=1
      end
   end
end

i=1
for k,v in bt do
   print("leak #".. i .. " (" .. v .. " veces)\n" .. k)
   i=i+1
end

