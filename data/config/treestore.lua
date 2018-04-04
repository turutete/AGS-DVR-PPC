loadlualib("treestore")
-- Modificamos treestore.set/get() para que acepten columna tanto por índice como por nombre
do
   local old_get=treestore.get
   local old_set=treestore.set
   treestore.get = 
      function(m, r, c)
	 if type(c)=="string" then c=treestore.get_col_number(m, c) end
	 if c>=0 then -- XXX and c<n_columns
	    return old_get(m, r, c)
	 else
	    return nil
	 end
      end
   treestore.set =
      function(m, r, c, v)
	 if type(c)=="string" then c=treestore.get_col_number(m, c) end
	 if c>=0 then -- XXX and c<n_columns
	    return old_set(m, r, c, v)
	 else
	    return nil
	 end
      end
end
