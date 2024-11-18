# Synthorium Dev Notes

## This is the documentation of my progress and thought processs while creating my horror game

## The rules I'm giving myself while making the game:
  -   Create a well polished and fun horror game
  -   Build map generation, character generation, and gameplay dynamics using AI prompt engineering or other techniques
  -   Make sure it has VR support, with smooth gameplay
  -   Most importantly, make it as SCARY as possible

## Goals for gameplay:
  -   Make the game replayable, fun with friends, and rewarding
  -   Every play should be unique, never keep something the exact same
  -   Take inspiration from FNAF games.
  -   Multiplayer
  -   Gameplay should feel like you're being hunted
    
## Gameplay loop:
  -   

# Day 1 (Nov 17 2024)

First, I wanted to find a fast and reliable LLM to use for prompt engineering later, because I knew it'd come up eventually. After some research, I came across groq, which worked perfectly from roblox studio, because I just had to send a HTTP Get request. It responded almost instantly, and I knew it'd work well for the job. 

After insuring it worked well, I wrote a small script that gave the AI a prompt, basically saying: You're building a map for my game, it needs to be this big with this many rooms, each room should be in this size range, blah blah blah. After it spat out data for a map, I parsed it and had the script automatically create the map. What came out wasn't exactly breathtaking. I changed up the prompt a few times, but the map it gave was always inconsistent and honestly just ugly. 

First big decision: This game will not fully rely on an LLM to generate its map. I'll do more research tomorrow.

# Day 2 (Nov 18 2024)

Today I'll research and try to find the best technique to generate maps for my game. 
