## This is the documentation of my progress and thought process while creating my horror game


## Goals (before first version):
  - ![#c5f015](https://placehold.co/15x15/c5f015/c5f015.png) `Build base map generation algorithm `
  - ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) `Add pathfinding for hallways in the map generation algo`
  - ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) `Build AI decoration algorithm to create convincing rooms w/ textures as well.`
  - ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) `Add AI gameplay dynamics like backstories, text on walls, etc to make gameplay trippy/liminal. `
  - ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) `Figure out what the actual goal of the game will be & implement it`
  - ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) `Build the Lobby & pre-game scene.`
  - ![#f03c15](https://placehold.co/15x15/f03c15/f03c15.png) `Put everything together`

  
## Goals (after first version):
  -   `Make sure every aspect of the game is unique to its own session`
  -   `Make sure it takes inspiration from FNAF games/The Backrooms.`
  -   `Introduce unique collectibles and achievements to encourage exploration.`
  -   `Make the game replayable, fun with friends, and rewarding`


## Gameplay loop:
  -   Lobby place will be prebuilt, the user can either random queue into a party or host their own party and load into a game.
  -   Send the party to a new instance of the actual game server.
  -   Everyone loads into a room, they're each asked a set of questions by an LLM, then the LLM takes the responses and generates elements/text to use later in game.
  -   Maybe: An AI generated kind of cutscene will play, with backstory of the player. This could help build the replayability.
  -   The player will enter an elevator/door to enter the real game.
  -   During surveys/loading in, the server has been generating the player's respective maps. It'll be random, with decorations decided by AI, and triggers for scares, etc.
  -   The player will find themself in an office, a bedroom, a bathroom, who knows. The goal of the player will be to explore and try to figure out where they are. Each game will have a unique map, so every corner will be unpredictable. 
  -   The use of AI in the map generation will create a unique sense of liminality/weirdness. In the same way AI sometimes lies to you, I believe its map generation will be inconsistent and trippy sometimes, which I can take advantage of.

# Day 1 (Nov 17 2024)

First, I wanted to find a fast and reliable LLM to use for prompt engineering later, because I knew it'd come up eventually. After some research, I came across groq, which worked perfectly from Roblox Studio, because I just had to send a HTTP Get request. It responded almost instantly, and I knew it'd work well for the job. 

After ensuring it worked well, I wrote a small script that gave the AI a prompt, basically saying: You're building a map for my game, it needs to be this big with this many rooms, each room should be in this size range, blah blah blah. After it spat out data for a map, I parsed it and had the script automatically create the map. What came out wasn't exactly breathtaking. I changed up the prompt a few times, but the map it gave was always inconsistent and honestly just ugly. 

First big decision: This game will not fully rely on an LLM to generate its map. I'll do more research tomorrow.

# Day 2 (Nov 18 2024)

After looking at Roblox devforums I found this GitHub repo: https://github.com/Nyapaw/Roblox/tree/master/Dungeon

It includes code to generate a dungeon/maze in 2D, and it looks promising with a good amount of configuration. Later I'll see if I can port it into a 3D version.

# Day 3 (Nov 19 2024)

Started writing my own lua code to automatically generate a simple room of a random size. Got the code to work on roblox and actually create a building. Works but the map doesnt look very good.

# Day 4 (Nov 20 2024)

Scripted in room branching, randomization, & quadrant normalization. The code will now generate a good-looking map of any size, and will either print in the console or actually build itself if ran in roblox. It's very efficient (only takes about 5ms to generate a 200x200 map)

Uploaded the source (map_generation.lua) to this repo 

# Day 5 (Nov 21 2024)

Optimized and cleaned code (ALOT). Added functionality to build a list of walls for each room that are exposed on the outside. I'll use that later for pathfinding to make hallways.
