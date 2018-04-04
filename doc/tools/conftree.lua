#! /usr/bin/lua

-- conftree.lua <muestra_tipo> <excluidos>
-- si muestra_so == 1 entonces se muestran los tipo de objeto
-- excluidos es una subcadena de los módulos a excluir del grafo
-- NOTA: _no_ se excluirán del grafo los módulos que estén referenciados 
-- por modulos no excluidos.

r=require
-- function require(s) return end
r"functions"
function loadlualib(s) return end
function package.loadlib(s) return function() end end
gtk={}
a=r(arg[1])

if type(a)~="table" then a=ags end

print('digraph "' .. arg[1] .. '" { clusterrank="local"; ')
--print('subgraph cluster0 {')
c=''
r='{ '
u=''
n=1
for k,v in pairs(a) do
   -- Saltamos lineas
   if not arg[3] or not string.find(k, arg[3]) then 
      l=''
      l=l .. '"' .. k .. '" [label="'.. tostring(n) .. ": " .. k..'"];\n'
      n=n+1
      
      if arg[2]=="1" then
	 mod="mod_new"
	 if(not v[mod]) then
	    mod="mod_filename"
	 end
	 
	 c=c .. '"<<'..v[mod] ..'>>" [shape=box] ;\n'
	 --   r=r .. ' "<<'..v.mod_filename ..'>>" '
	 
	 l=l .. '"' .. k .. '" -> "<<'..v[mod]..'>>" [style=dotted,color=black];\n'
      end
      if v.depends then 
	 for k2,v2 in pairs(v.depends) do
	    if string.sub(k2,1,1)=='_' then
	       l=l .. ' edge [style=dashed,color=red];\n'
	    else
	       l=l .. ' edge [style=solid,color=blue];\n'
	    end
	    l=l .. '"' .. k .. '" -> { '
	    l=l .. v2 .. ' '
	    l=l .. '} '
	    l=l .. ' [fontsize=8,fontname="courier",label="'.. k2  ..'" ] '
	    l=l .. ';\n'
	 end
      end
      --   print(l)
      u=u .. l
   end
end
--print('} ')
print('subgraph clusterOTRO { ')
print(c .. '};')

print('subgraph cluster_UNO { ')
print(u)
print('};')

--print(r .. '}')
print('}')
