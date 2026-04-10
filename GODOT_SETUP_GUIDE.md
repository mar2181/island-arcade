# Island Arcade - Godot Setup Guide (For First-Timers)

## STEP 1: Download Godot

1. Open your browser and go to: https://godotengine.org/download/windows/
2. Click the big blue button that says **"Godot Engine 4.6.2"** (the standard one, NOT the ".NET" one)
3. It downloads a ZIP file. It's about 50-60MB.
4. Right-click the ZIP → **Extract All** → Extract to somewhere like `C:\Godot\`
5. Inside the extracted folder you'll see one file: **`Godot_v4.6.2-stable_win64.exe`**
   - That's the ENTIRE program. No installer needed. No setup wizard.
   - Just double-click that .exe to run Godot.

## STEP 2: Open the Project

1. Double-click `Godot_v4.6.2-stable_win64.exe`
2. A window called **"Project Manager"** appears. This is NOT your game yet — it's a launcher.
3. You'll see an empty list in the center. On the RIGHT side, click the button that says **"Scan"** (it has a magnifying glass icon)
   - OR click **"Import"** (also on the right side)
4. An "Import Project" dialog appears. Click the **"Browse"** button on the right.
5. Navigate to: `C:\Users\Mario\Desktop\island-arcade\`
6. Inside that folder, click on the file **`project.godot`** and click Open
7. The "Import Project" dialog will now show the project name "Island Arcade" and the path
8. Click **"Import & Edit"** at the bottom

**IMPORTANT:** The FIRST time you open the project, Godot will scan all files and import the 3D models and textures. This takes 30-60 seconds. You'll see a progress bar. Let it finish.

## STEP 3: What You'll See (The Godot Editor)

Once the project opens, you'll see the full editor. Here's what each section is:

```
┌─────────────────────────────────────────────────────────────────┐
│  MENU BAR: File  Edit  Project  Debug  (etc.)                  │
├──────────┬──────────────────────────────────┬───────────────────┤
│          │                                  │                   │
│  SCENE   │        2D / 3D VIEWPORT          │    INSPECTOR      │
│  TREE    │                                  │    (Properties)   │
│          │    (This is where you SEE        │                   │
│  (Left   │     your game world — the        │    (Right side    │
│  panel)  │     arcade room, enemies,        │     panel)        │
│          │     player, etc.)               │                   │
│          │                                  │                   │
│          │                                  │                   │
├──────────┴──────────────────────────────────┴───────────────────┤
│                                                                 │
│              BOTTOM PANEL: Output / FileSystem / etc.           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### The panels explained:

**LEFT PANEL - Scene Tree (FileSystem dock)**
- Shows a tree of everything in the current scene
- Like a file explorer but for game objects
- You'll see "GameScene" at top, then indented children like Player, WaveManager, etc.
- Click the **"FileSystem"** tab at the bottom of this panel to see ALL project files

**CENTER - Viewport**
- Shows the 3D (or 2D) view of your scene
- You can orbit with middle mouse button, zoom with scroll wheel
- Click objects to select them

**RIGHT PANEL - Inspector**
- Shows properties of whatever you clicked in the viewport or scene tree
- Numbers, colors, positions, scripts, etc.

**BOTTOM PANEL**
- **Output** tab: Shows print messages and errors when running
- **FileSystem** tab: Browse all your project files

## STEP 4: RUN THE GAME

There are TWO ways to run the game:

### Method A: The Play Button (Easiest)
1. Look at the **TOP RIGHT** of the Godot window
2. You'll see a row of buttons that look like this:
   ```
   ▶️  ⏸️  ⏹️  🔄
   ```
3. Click the **▶️ (Play)** button — it's the right-pointing triangle
4. The game starts! You'll see the main menu:
   - "ISLAND ARCADE" in large cyan pixel text
   - "South Padre Island, TX" in purple below it
   - A **"PLAY"** button centered below the title
   - Other buttons: "HIGH SCORES", "SETTINGS", "QUIT"

### Method B: Press F5
- Just press **F5** on your keyboard. Same thing as the Play button.

### Method C: Play Current Scene (F6)
- If you want to test JUST the game scene (skipping the menu), press **F6**
- This loads whatever scene you have open

## STEP 5: Playing the Game

When you click PLAY:
1. The screen fades to black, then the game loads
2. You're standing in the middle of a dark arcade room
3. The camera is first-person (your mouse controls looking around)
4. **Controls:**
   - **W/A/S/D** — Move forward/left/back/right
   - **Mouse** — Look around
   - **Left Click** — Shoot
   - **Right Click** — Aim down sights (zooms in)
   - **R** — Reload
   - **Space** — Jump
   - **Shift** — Sprint
   - **Ctrl** — Crouch
   - **Esc** — Pause

5. Enemies will spawn from the arcade cabinets around the room:
   - **Glitch** (pink/magenta) — Slow walker, 30 HP
   - **Byte** (green cube) — Floats and orbits, then darts at you, 15 HP
   - **Boss** (dark red, big) — Spawns minions, 300 HP (600 on wave 10)

6. The HUD shows:
   - Top-left: Wave number
   - Top-right: Score
   - Bottom-left: Health bar (green/yellow/red)
   - Bottom-right: Ammo (current / reserve)
   - Center: Crosshair (cyan dots)
   - Center: Combo multiplier when chaining kills

## STEP 6: Stopping the Game

To stop the game:
- Press **F8** or click the **⏹️ (Stop)** button at the top right
- OR press **Esc** → "QUIT TO MENU" → then close the window

## TROUBLESHOOTING

### "The screen is just purple/dark"
- You're probably in the main menu. Click PLAY or press F5.
- If F5 shows a dark empty room, the game scene loaded but WaveManager may not have started. Press F8, then F5 again.

### "I see errors in the Output panel"
- Look at the BOTTOM panel → "Output" tab
- Yellow warnings are usually fine
- Red errors mean something is wrong — read the error message

### "My .glb models are showing as wireframe/checkerboard"
- This is normal on first import. The models are there, materials load after.

### "I can't find my project in Project Manager"
- Click "Import" → Browse to `C:\Users\Mario\Desktop\island-arcade\project.godot`

## KEYBOARD SHORTCUTS IN GODOT EDITOR

| Key | Action |
|-----|--------|
| F5 | Run the game |
| F6 | Run current scene |
| F8 | Stop the game |
| Ctrl+S | Save current scene |
| Ctrl+Shift+S | Save all scenes |
| Space | Toggle between 2D/3D view |
| F | Focus on selected object |
| Ctrl+Z | Undo |
| Ctrl+Shift+Z | Redo |

## WHERE YOUR FILES ARE

- **Project folder:** `C:\Users\Mario\Desktop\island-arcade\`
- **Game scenes:** `scenes/game/` (game_scene.tscn is the main game)
- **Enemy scenes:** `scenes/enemies/`
- **Scripts:** `scripts/` (all .gd files)
- **3D models:** `assets/models/`
- **Materials:** `assets/materials/`
- **Sounds:** `assets/audio/`