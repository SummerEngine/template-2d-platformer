# 2D Metroidvania Template -- Agent Handoff

You are building a Hollow Knight-inspired 2D Metroidvania template for Summer Engine (Godot 4.5 fork). This is an open-source game template that developers download and build on top of.

## What Exists (DO NOT REWRITE)

The following systems are built and working. Study them before adding anything:

### Core Architecture
- **EventBus** (`scripts/autoloads/event_bus.gd`) -- Global signal bus. ALL cross-system communication goes through here. When adding new features, add signals here first.
- **GameManager** (`scripts/autoloads/game_manager.gd`) -- HP system (hearts, not lives), coins, score, bench respawn, room transitions.
- **RoomManager** (`scripts/autoloads/room_manager.gd`) -- Manages room transitions, player spawning at doors, visited room tracking. Room paths are registered in this file's `room_paths` dictionary.
- **AbilityManager** (`scripts/autoloads/ability_manager.gd`) -- Tracks unlocked abilities (dash, wall_climb, double_jump). Player controller checks `AbilityManager.has_ability()` before allowing moves.
- **QuestManager** (`scripts/autoloads/quest_manager.gd`) -- Loads quest JSON from `data/quests/`, tracks states (not_started/active/completed).
- **SaveManager** (`scripts/autoloads/save_manager.gd`) -- JSON persistence to `user://save_data.json`. Saves abilities, rooms, quests, HP, coins, bench position.
- **SceneTransition** (`scripts/autoloads/scene_transition.gd`) -- Fade-to-black between scenes. Use `SceneTransition.change_scene(path)` instead of `get_tree().change_scene_to_file()`.
- **AudioManager** (`scripts/autoloads/audio_manager.gd`) -- Music crossfade + SFX pool with pitch variance. Stub only, no audio files yet.

### Player
- **PlayerController** (`scripts/player/player_controller.gd`) -- Full movement: walk, jump (coyote time, buffer, variable height, double jump), wall slide, wall jump, dash (8-directional, cooldown, iframes). All values are @export. Abilities gated by AbilityManager. Has `take_damage()`, `take_hit()`, `die()`, `respawn()`.
- **PlayerCombat** (`scripts/combat/player_combat.gd`) -- Child node on Player. Sword swing with 3-hit combo, directional attacks (up/down/horizontal). Down-attack bounces player. Uses `body_entered` on SwordHitArea to detect enemies.
- **CameraController** (`scripts/player/camera_controller.gd`) -- Screen shake (decay-based) + hitstop (Engine.time_scale). Listens to EventBus signals.
- **Player Scene** (`scenes/player/player.tscn`) -- CharacterBody2D with Visuals (Polygon2D body+eyes), StompDetector, Particles, PlayerCombat, Camera2D. Player is NOT placed in room scenes. RoomManager spawns it.

### Enemies
- **BaseEnemy** (`scripts/enemies/base_enemy.gd`) -- Base class. HP, contact_damage, gravity, knockback, coin drops, death particles, white flash on hit. Override `_ai_process(delta)` for custom behavior. Override `_setup()` for init.
- **PatrolEnemy** (`scripts/enemies/patrol_enemy.gd`) -- Extends base_enemy via preload path. Walks back/forth, turns at edges/walls. Has PlayerDetector Area2D.
- **FlyingEnemy** (`scripts/enemies/flying_enemy.gd`) -- Extends base_enemy. Sine-wave flight, wing flap animation.
- Enemy scenes at `scenes/enemies/`. Collision layer 4 (Enemies), mask 1 (World).

### Systems
- **Door** (`scripts/systems/door.gd`, `scenes/doors/door.tscn`) -- Connects rooms. @export: door_id, target_room_id, target_door_id, requires_ability, auto_enter. Added to "doors" group.
- **Bench** (`scripts/systems/bench.gd`, `scenes/systems/bench.tscn`) -- Save/heal point. Interact to heal full, save game, set respawn.
- **AbilityPickup** (`scripts/systems/ability_pickup.gd`, `scenes/systems/ability_pickup.tscn`) -- Glowing orb. Interact to unlock ability permanently.
- **AbilityGate** (`scripts/systems/ability_gate.gd`, `scenes/systems/ability_gate.tscn`) -- Wall that crumbles when you have the required ability.
- **Coin** (`scripts/systems/coin.gd`), **Killzone**, **BouncePad**, **MovingPlatform**, **OneWayPlatform**, **CrumblingPlatform** -- All at `scripts/systems/`.
- **RoomLoader** (`scripts/systems/room_loader.gd`) -- Attach to root of every room scene. Sets room_id and spawns the player.
- **JuiceManager** (`scripts/systems/juice_manager.gd`) -- Floating text, stomp particles, dash afterimage, gem sparkles. Listens to EventBus.
- **ParallaxBg** (`scripts/systems/parallax_bg.gd`) -- Procedural starfield + mountain silhouettes + themed decorations (trees/crystals/pillars via `decoration_type` export).

### NPCs
- **NPC** (`scripts/npcs/npc_controller.gd`, `scenes/npcs/npc.tscn`) -- Interaction zone, loads dialogue from JSON, shows "E" prompt. @export: npc_id, dialogue_file, body_color.
- **DialogueRunner** (`scripts/npcs/dialogue_runner.gd`) -- Typewriter text box at bottom of screen. Instantiated by NPCs, not an autoload. Emits `dialogue_finished`.
- Dialogue data at `data/dialogue/*.json`. Format: conversations array with conditions (flag_not_set, has_ability, quest_active, quest_completed).

### UI
- **MainMenu** (`scenes/ui/main_menu.tscn`) -- New Game / Continue / Quit. Shows controls.
- **HUD** (`scenes/ui/hud.tscn`) -- Heart containers (Polygon2D), coin counter, controls hint at bottom.
- **PauseMenu** (`scenes/ui/pause_menu.tscn`) -- Resume / Restart / Main Menu.

### Collision Layers
| Layer | Name | Value | Used By |
|-------|------|-------|---------|
| 1 | World | 1 | Platforms, walls |
| 2 | Player | 2 | Player CharacterBody2D |
| 3 | Enemies | 4 | Enemy CharacterBody2Ds |
| 4 | PlayerAttack | 8 | Player sword hitbox |
| 5 | EnemyAttack | 16 | Enemy projectiles/attacks |
| 6 | Interactable | 32 | NPCs, doors, pickups |

### Current Room Layout
```
Room 01 (hub) -- Room 02 (Mossy Grotto, has Dash pickup)
     |
Room 03 (Crystal Caves)
```
Only 3 rooms exist. 4 more are planned.

## What Needs To Be Built

### Priority 1: More Rooms (4 new rooms)

Each room is a .tscn scene file following this structure:
```
RoomXX (Node2D, script=room_loader.gd, room_id="room_XX")
  ParallaxBg (ParallaxBackground, script=parallax_bg.gd)
  CamBoundTL (Marker2D) -- top-left camera limit
  CamBoundBR (Marker2D) -- bottom-right camera limit
  Geometry (Node2D)
    Ground (StaticBody2D, collision_layer=1, collision_mask=0)
      Col (CollisionShape2D, position offset by half height)
      V (Polygon2D, visual)
      T (Polygon2D, top highlight line)
    ...more platforms...
  Doors (Node2D)
    DoorXX (instance of door.tscn, with door_id, target_room_id, target_door_id)
  Enemies (Node2D)
  Coins (Node2D)
  Collectibles (Node2D)
  DeathPlane (Area2D, killzone script, at y=700)
  HUD (instance of hud.tscn)
  PauseMenu (instance of pause_menu.tscn)
```

**CRITICAL RULES for rooms:**
- Player is NOT in the room scene. RoomManager spawns it.
- Register room path in `room_manager.gd` `room_paths` dictionary.
- All Color() values in .tscn must have 4 components: `Color(r, g, b, a)` not `Color(r, g, b)`.
- Sub-resources ([sub_resource]) must come BEFORE nodes in .tscn files.
- Ext-resources ([ext_resource]) must come before sub-resources.
- Platform top surface = StaticBody2D position. CollisionShape2D offset by (0, half_height). Polygon2D draws downward from 0.
- Platforms should be reachable: single jump height is ~88px, double jump adds ~65px. Keep platform gaps under 150px vertical.

**Planned rooms:**
| Room | Theme | Content |
|------|-------|---------|
| room_04 | Fungal Depths | Dash-gated entry, wall_climb ability pickup, crumbling platforms, quest item |
| room_05 | Ancient Aqueduct | wall_climb-gated entry, vertical section, moving platforms, shopkeeper NPC |
| room_06 | Queen's Chamber | Boss fight arena |
| room_07 | Hidden Garden | Secret room, double_jump-gated, ending NPC, reward coins |

### Priority 2: Boss Fight

Create at `scripts/bosses/crystal_queen.gd` + `scenes/bosses/crystal_queen.tscn`.

Requirements:
- Extend CharacterBody2D (not base_enemy, bosses are special)
- State machine: IDLE, TELEGRAPH, ATTACK, RECOVER, DYING
- 20 HP, contact_damage = 2
- Phase 1 (100-50% HP): charge attack, crystal rain (falling projectiles), slam
- Phase 2 (<50% HP): faster attacks, crystal wall (spawns temporary obstacles)
- Recovery windows between attacks (1-2s) where player can hit
- Telegraph attacks with visual indicator (flash, shake) before executing
- Death: doors unlock, ability pickup spawns, quest completes
- Health bar UI at top of screen (CanvasLayer, ColorRect fill bar)

Room_06 should:
- Lock doors on boss room entry
- Flat arena floor with 2 platforms for dodging
- Boss spawns from center with name title card
- On death: unlock doors, spawn reward

### Priority 3: Quest Journal UI

Create `scripts/ui/quest_journal.gd` + `scenes/ui/quest_journal.tscn`.

- Opened from pause menu (add "Journal" button to pause_menu.tscn)
- Lists active quests with current objective
- Lists completed quests (greyed)
- QuestManager already has `get_active_quests()`, `get_completed_quests()`, and `quest_data` dictionary with title/description/objectives

### Priority 4: Room Map

Create `scripts/ui/map.gd` + `scenes/ui/map.tscn`.

- Grid of colored rectangles representing rooms
- Visited rooms colored, unvisited hidden/dark
- Current room highlighted with a border
- Room connections shown as lines between rectangles
- Room positions from a const Dictionary in the script
- Opened with a "Map" button in pause menu or a key

### Priority 5: Wall Climb Ability Pickup

The wall_climb ability exists in AbilityManager but there's no pickup for it yet. Place it in room_04. Same pattern as the Dash pickup in room_02.

### Priority 6: Additional Quest Data

Create more quest JSON files at `data/quests/`:
- `defeat_queen.json`: Kill boss in room_06. Reward: game completion flag.
- `fungal_harvest.json`: Fetch item from room_04, return to Elder. Reward: coins + door unlock.

### Priority 7: Shopkeeper

The shopkeeper NPC dialogue exists at `data/dialogue/shopkeeper.json`. Place a shopkeeper NPC in room_05. For the actual shop UI:
- Create `scripts/ui/shop.gd` + `scenes/ui/shop.tscn`
- Items: health upgrade (+1 max HP, 50 coins), attack charm (+1 sword damage, 30 coins)
- GameManager already has `increase_max_hp()` and coins tracking

## Code Conventions

- GDScript, fully typed: `var speed: float = 5.0`, `func move(delta: float) -> void:`
- `@export` for all tunable values, grouped with `@export_group()`
- `@onready` for node references
- Groups for detection: `"player"`, `"enemies"`, `"doors"`, `"npcs"`
- `has_method()` for duck typing instead of `is ClassName` (class_name resolution is unreliable in Godot 4.5)
- No external assets. All visuals via Polygon2D, CPUParticles2D, code-drawn shapes
- Event-driven: emit EventBus signals, listen in other systems. Never directly reference nodes across systems.
- process_mode = PROCESS_MODE_ALWAYS on any node that must work during pause (UI, transitions)

## How To Test

Launch: `/Applications/Godot.app/Contents/MacOS/Godot --path /Users/MathiasWork/development/templates/template-2d-platformer 2>&1`
Headless validation: add `--headless --quit` flags.
Check for zero errors in console output.

## Input Actions (defined in project.godot)

| Action | Keys | Gamepad |
|--------|------|---------|
| move_left | A, Left Arrow | Left Stick |
| move_right | D, Right Arrow | Left Stick |
| jump | Space, W, Up Arrow | A button |
| move_down | S, Down Arrow | Left Stick |
| dash | Shift | RB |
| attack | X, J | X button |
| interact | E | Y button |
| pause | Escape | Start |
