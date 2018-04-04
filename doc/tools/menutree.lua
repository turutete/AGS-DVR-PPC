#! /usr/bin/lua

-- menutree.lua

-- "fake" curses
curses={}
curses.mvaddstr=function(x,y,s)   return end
curses.mvaddch =function(x,y,s,r) return end
curses.refresh=function() return end
curs={}
curs.KEY_UP=" "
curs.KEY_DOWN=" "
curs.KEY_RET=" "
curs.KEY_ESC=" "

-- "fake" gobject
gobject={}
gobject.connect=function(obj, sig, func, udata) return end
gobject.timeout_add=function(timeout, func, udata) return end
gobject.set_property=function(obj, name, value) return end
-- "fake" access
access={}
access.get=function(sds, k) return 0 end
access.set=function(sds, k, v) return end
-- "fake" xaccess
accessx={}
accessx.getnextkey=function(sds, k) return 0 end

r=require
-- function require(s) return end
r"functions"
function loadlualib(s) return end
function package.loadlib(s) return function() end end
a=r(arg[1])

if type(a)~="table" then os.exit() end
local deck=a

-----------------
local keys={  "KEY_RET", "KEY_DOWN", "KEY_UP",  }
local cached={}
local function nodo(deck, current, cluster)
   local s=""

   if cached[current] then
      return -- ya visitado
   else
      s=s .. current 
      s=s .. ' [ color=blue,shape=box ] '
      s=s .. ';\n'
      cached[current]=true
   end

   for i,key in pairs(keys) do
      local dest=""
      local dest_cluster=cluster
      deck.current=current
      deck[current].edit=false
      deck[current].dokey(deck[current], curses[key])
      dest=deck.current

      if(dest~=current) then
	 local edge_opts='color="blue"'

	 if key=="KEY_RET" then
	    edge_opts='color="red"'
	 end

	 s=s .. current .. ' -> ' .. dest 
	 s=s .. ' [ fontsize=8,' .. edge_opts
	 s=s .. ',label="' .. curs[key] .. '" ] '
	 s=s .. ' ;\n'

	 if key=="KEY_DOWN" then
	    s=s .. ' subgraph cluster'..cluster..' { color="darkgreen"; rankdir="LR"; clusterrank="local"; rank=same; '
	    s=s .. current .. " " .. dest .. '} '
	    s=s .. ' ;\n'
	 elseif key=="KEY_RET" then
	    dest_cluster=dest
	 end

	 s=s.. (nodo(deck, dest, dest_cluster) or "")
      end
   end

   return s
end

s=nodo(deck, deck.current, "Principal")

print('digraph "' .. arg[1] .. '" { rankdir="TB"; clusterrank="local"; ')

print(s)

print('};')

return s
