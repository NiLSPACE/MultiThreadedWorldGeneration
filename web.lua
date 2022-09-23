
-- web.lua

-- Contains handlers for the webadmin to monitor the chunk queue of every world.




function HandleWeb_GeneratorQueue(a_Request)
	if (a_Request.Params['stats']) then
		local res = {}
		cRoot:Get():ForEachWorld(function(world)
			table.insert(res, {name = world:GetName(), numInGenQueue = world:GetGeneratorQueueLength(), numLoadedChunks = world:GetNumChunks()});
		end);
		return cJson:Serialize(res);
	end
	return [[
	<table id="worlds">
		<tr>
			<th>World</th>
			<th>Queue Size</th>
			<th>Loaded Chunks</th>
		</tr>
	</table>
	<script>
		(() => {
			let worldsDom = document.getElementById("worlds");
			setInterval(async () => {
				let req = await fetch("/~webadmin/MultiThreadedWorldGeneration/generator-queue?stats=true")
				let info = await req.json();
				for (let obj of info) {
					let dom = document.getElementById("world-" + obj.name);
					if (!dom) {
						dom = document.createElement("tr");
						dom.id = "world-" + obj.name
						let headerDom = document.createElement("td");
						headerDom.innerText = obj.name;
						dom.appendChild(headerDom);
						dom.appendChild(document.createElement("td"));
						dom.appendChild(document.createElement("td"));
						worldsDom.appendChild(dom);
					}
					dom.children[1].innerText = obj.numInGenQueue
					dom.children[2].innerText = obj.numLoadedChunks
				}
			}, 300)
		})();
	</script>
	]]
end





function RegisterWebPages()
	cWebAdmin:AddWebTab("Generator Queue", "generator-queue", HandleWeb_GeneratorQueue);
end




