# ISLAND ARCADE

A first-person arcade shooter set in a neon-soaked arcade on **South Padre Island, Texas**.

## Overview

You walk into Island Arcade -- rows of glowing cabinets, the hum of CRT screens, tickets spilling from machines. But something's wrong. The games are glitching out, and digital creatures are crawling out of the screens. You find a Pixel Blaster on the counter. Time to clear the floor.

## Gameplay

- **10 waves** of escalating enemies
- **3 enemy types:** Glitch (walks at you), Byte (circles and darts), Boss Glitch (spawns minions)
- **1 weapon:** The Pixel Blaster -- semi-auto, hitscan, 12-round mag
- **Scoring system:** Points for kills, headshots (2x), quick kills, combo multipliers (up to 3x)
- **Health pickups** and **ammo pickups** spawn throughout the arena

## Controls

| Action | Key |
|---|---|
| Move | WASD |
| Look | Mouse |
| Shoot | Left Click |
| Aim Down Sights | Right Click |
| Jump | Space |
| Sprint | Left Shift |
| Crouch | Left Ctrl |
| Reload | R |
| Interact | E |
| Pause | Escape |

## Project Structure

```
island-arcade/
├── project.godot          # Engine config, input maps, render settings
├── export_presets.cfg      # Windows + Web export configs
├── assets/
│   ├── materials/          # All .tres material files
│   ├── models/             # 3D models (.glb)
│   ├── textures/           # Texture maps
│   ├── audio/              # Music + SFX (.ogg/.wav)
│   └── fonts/              # Press Start 2P + Inter
├── scenes/
│   ├── main.tscn           # Entry point (menu)
│   ├── menu/               # Menu scenes
│   ├── game/
│   │   ├── game_scene.tscn # Main gameplay scene
│   │   ├── ammo_pickup.tscn
│   │   ├── health_pickup.tscn
│   │   └── impact_effect.tscn
│   └── enemies/
│       ├── glitch.tscn
│       ├── byte.tscn
│       └── boss_glitch.tscn
├── scripts/
│   ├── autoload/            # GameManager, AudioManager, SaveManager
│   ├── player/              # PlayerController, Weapon, PlayerHealth
│   ├── enemies/             # BaseEnemy, GlitchAI, ByteAI, BossAI
│   ├── systems/             # WaveManager, Scoring, Pickups, Cabinet
│   └── ui/                  # HUD, MenuController
├── data/
│   └── high_scores.json    # Persistent leaderboard
└── export/
    ├── windows/
    └── web/
```

## How to Build

1. Install [Godot 4.4+](https://godotengine.org/download)
2. Open this project folder in Godot
3. Press F5 to run in editor, or:
4. Project → Export → Windows Desktop → Export

## Required Assets (to be added)

- 3D models: arcade cabinet, Pixel Blaster, enemy meshes, props
- Audio: music tracks (menu, 3 gameplay intensities, boss, game over), all SFX
- Fonts: Press Start 2P (Google Fonts), Inter (Google Fonts)
- Textures: floor grid, cabinet screens, neon signs

## Tech Stack

- **Engine:** Godot 4.4 (Forward+ renderer, Vulkan)
- **Language:** GDScript
- **Physics:** GodotPhysics
- **Platform:** Windows Desktop + Web (HTML5)

## South Padre Island, TX

This game is set in and inspired by Island Arcade, a real arcade business located on South Padre Island, Texas. The neon aesthetic reflects the coastal nightlife vibe of SPI -- warm gulf breezes, boardwalk lights, and that special kind of chaos only an island arcade after dark can deliver.

---

*Built with Godot 4. Made on South Padre Island, TX.*
