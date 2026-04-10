# Contributing to Island Arcade

Thanks for your interest in contributing! This is an open-source game project built with Godot 4.4.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/island-arcade.git`
3. Open the project in [Godot 4.4+](https://godotengine.org/download)
4. Create a feature branch: `git checkout -b feature/your-feature-name`

## Project Structure

- `scripts/autoload/` - Global singletons (GameManager, AudioManager, SaveManager)
- `scripts/player/` - Player controller, weapon, health
- `scripts/enemies/` - Enemy AI (Glitch, Byte, Boss)
- `scripts/systems/` - Wave manager, pickups, arcade cabinet, scoring
- `scripts/ui/` - HUD, menu controller
- `scenes/` - Godot scene files (.tscn)
- `assets/materials/` - Material definitions (.tres)
- `assets/models/` - 3D models (.glb) - to be added
- `assets/audio/` - Music and SFX - to be added
- `assets/fonts/` - Press Start 2P + Inter

## Code Style

- Use tabs for indentation (Godot convention)
- GDScript 4 typed declarations where possible
- Comment non-obvious logic
- Keep scripts under 200 lines; split into components if needed

## Submitting Changes

1. Test your changes in the Godot editor
2. Commit with clear messages
3. Push to your fork
4. Open a Pull Request against `main`

## Asset Contributions

We need:
- 3D models (arcade cabinets, enemies, weapon, props)
- Music tracks (synthwave/retrowave)
- Sound effects (weapons, enemies, UI, ambient)
- Pixel art textures

All contributed assets must be your own work or clearly licensed for use.

## Setting

This game is set on **South Padre Island, Texas**. Keep the coastal-island-arcade vibe in mind for all visual and audio contributions.

---

Built with love on South Padre Island, TX.