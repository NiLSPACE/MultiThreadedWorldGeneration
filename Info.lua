g_PluginInfo =
{
	Name = "Multithreaded World Generation",
	Date = "2022-09-23",
	Description = "Takes the chunk generation from one world and spreads it out over multiple worlds. Since every world in Cuberite runs on it's own thread it causes the load to be spread out as well.",

	-- The following members will be documented in greater detail later:
	AdditionalInfo = 
	{
		{
			Title = "Proof of concept",
			Contents = [[
This is just a proof of concept. Don't use it on a server you're actually playing in. 
If any of the chunk generation worlds generate a chunk they will override the chunk in your actual world. This also means that if the world generation threads start to generate their spawn they will override the spawn on your actual world.
			]]
		},
		{
			Title = "Configuring",
			Contents = [[
This plugin by itself doesn't contain any configuration. Instead it looks at all the worlds you've configured already in your settings.ini. 
If a world starts with 'wgt<any number>-' it considers it a world generation thread. Anything after that is the target world. 
So if you want 4 generator threads for a world called 'world' you create the following worlds:
	- wgt1-world
	- wgt2-world
	- wgt3-world
	- wgt4-world
	
Please note that in the settings.ini you can configure the path that those world should point at to look for their configuration.
You can make them all point at the same path so you only have to configure the generator once. Those settings in the settings.ini would look like this:

```ini
[Worlds]
DefaultWorld=world
World=wgt1-world
World=wgt2-world
World=wgt3-world
World=wgt4-world

[WorldPaths]
world=world
wgt1-world=wgt-world
wgt2-world=wgt-world
wgt3-world=wgt-world
wgt4-world=wgt-world
``` 

In the world.ini of the generator worlds it's important to set the PregenerateDistance to 2 and set the storage to forgetful. Those settings would look like this:

```ini
[SpawnPosition]
PregenerateDistance=2

[Storage]
Schema=Forgetful
```
			]]
		}
	},
	Commands = {},
	ConsoleCommands = {},
	Permissions = {},
	Categories = {},
}