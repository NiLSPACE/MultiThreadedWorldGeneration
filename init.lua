
-- init.lua
-- 




-- A map/dictionary for target worlds which contains all the generator thread worlds they have pointing at them.
g_targetWorlds = {};

-- A lua pattern to identify target worlds in the name of a generator thread world.
g_generatorThreadPattern = "wgt(%d-)%-(.*)"





function Initialize(a_Plugin)
	a_Plugin:SetName("MultiThreadedWorldGeneration");
	a_Plugin:SetVersion(1);
	
	RegisterHooks();
	
	RegisterWebPages();
	
	-- Look to all worlds and see if they are generator thread worlds. If so save them in g_targetWorlds.
	cRoot:Get():ForEachWorld(function(world)
		local dummyThreadId, targetWorld = world:GetName():match(g_generatorThreadPattern)
		if (targetWorld == nil) then
			return;
		end
		g_targetWorlds[targetWorld] = g_targetWorlds[targetWorld] or {generatorWorlds = {}, currentIdx = 1};
		table.insert(g_targetWorlds[targetWorld].generatorWorlds, world:GetName());
	end);
	
	LOG("Initialized");
	return true;
end




