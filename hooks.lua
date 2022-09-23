
-- hooks.lua

-- Implements the handlers for the hooks to trigger world generation in the
-- generator thread worlds and then write them back into their target worlds.




-- Definitions:
local ChunkWidth = 16;





-- Used for generator thread worlds.
-- Once a chunk generates on such a world the chunk on the target world is replaced with this chunk.
function OnChunkGenerated(a_World, a_ChunkX, a_ChunkZ, a_ChunkDesc)
	local dummyThreadId, targetWorldName = a_World:GetName():match(g_generatorThreadPattern)
	if (not targetWorldName) then
		-- Not a generator thread world. 
		return;
	end

	-- cBlockArea doesn't contain biomes, so save them in an external array.
	local biomes = {};
	for x = 0, 15 do
		for z = 0, 15 do
			biomes[x * ChunkWidth + z] = a_ChunkDesc:GetBiome(x, z);
		end
	end
	
	-- cChunkDesc doesn't have functionality to write it back into another world, so read everything
	-- into a cBlockArea.
	local blockArea = cBlockArea();
	a_ChunkDesc:ReadBlockArea(blockArea, 0, 15, 0, 255, 0, 15);

	local targetWorld = cRoot:Get():GetWorld(targetWorldName);
	targetWorld:QueueTask(function()
		targetWorld:ChunkStay({{a_ChunkX, a_ChunkZ}}, nil, function() 
			-- Write the cBlockArea back into the target world.
			blockArea:Write(targetWorld, Vector3i(a_ChunkX * ChunkWidth, 0, a_ChunkZ * ChunkWidth));
			
			-- Write the biomes back into the target world.
			for x = 0, 15 do
				for z = 0, 15 do
					targetWorld:SetBiomeAt(a_ChunkX * ChunkWidth + x, a_ChunkZ * ChunkWidth + z, biomes[x * ChunkWidth + z]);
				end
			end
		end);
	end);
end





-- Used to intercept chunk generation on worlds that have generator thread worlds pointing at it.
-- If a world has generator thread worlds pointing at it it picks one of those worlds at tells it
-- to (re)generate a chunk at the same position.
function OnChunkGenerating(a_World, a_ChunkX, a_ChunkZ, a_ChunkDesc)
	local threadsInfo = g_targetWorlds[a_World:GetName()]
	if (not threadsInfo) then
		-- No generator thread worlds pointing to this world.
		return;
	end
	
	-- Since there are generator thread worlds pointing to this world we disable 
	-- all other generation for this chunk.
	a_ChunkDesc:SetUseDefaultComposition(false);
	a_ChunkDesc:SetUseDefaultBiomes(false);
	a_ChunkDesc:SetUseDefaultHeight(false);
	a_ChunkDesc:SetUseDefaultFinish(false);
	
	-- Pick a generator thread world from the list. That world is then used to 
	-- generate a new chunk.
	local generatorWorldName = threadsInfo.generatorWorlds[threadsInfo.currentIdx];
	local generatorWorld = cRoot:Get():GetWorld(generatorWorldName);
	generatorWorld:QueueTask(function()
		generatorWorld:RegenerateChunk(a_ChunkX, a_ChunkZ);
	end);
	
	-- Move to the next generator world.
	-- ToDo: It might be advantageous to let one world generate chunks that are 
	--       next to other chunks that it previously generated.
	--       This is because the world generator can cache certain composition/biome 
	--       generation to make sure finishers like villages or trees work properly.
	--       Because of the way the chunks are now spread out there is a chance the
	--       same chunks are generated on multiple threads to make those finishers work.
	threadsInfo.currentIdx = threadsInfo.currentIdx + 1;
	if (threadsInfo.currentIdx > #threadsInfo.generatorWorlds) then
		threadsInfo.currentIdx = 1;
	end
end





-- Adds all the hooks to cPluginManager.
function RegisterHooks()
	-- Used to intercept chunk generation on worlds with generator thread worlds pointing to it.
	cPluginManager:AddHook(cPluginManager.HOOK_CHUNK_GENERATING, OnChunkGenerating);
	
	-- Used to get chunks from generator thread worlds and write them back into their target world.
	cPluginManager:AddHook(cPluginManager.HOOK_CHUNK_GENERATED, OnChunkGenerated);
end




