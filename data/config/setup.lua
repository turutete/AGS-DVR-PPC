for p in string.gmatch(AGS_CONFIG_PATH, "([^:]+)") do 
   package.path  = package.path .. ';' .. p .. "/?.lua" 
end
for p in string.gmatch(AGS_MOD_PATH, "([^:]+)") do 
   package.cpath = package.cpath .. ';' .. p .. "/?.so" 
end

----
