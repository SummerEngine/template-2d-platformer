# 2D Metroidvania Template

A Hollow Knight-inspired 2D Metroidvania starter for Summer Engine (a Godot 4.6+ fork): a tuned platformer controller with melee combat, seven interconnected rooms, ability pickups, NPCs with dialogue, quests, a boss fight and a save system. The game boots straight into gameplay in `scenes/rooms/room_01.tscn`. Everything is drawn with `Polygon2D` and `CPUParticles2D` except two background PNGs, so it is easy to reskin.

Create a project from it with the Summer toolkit:

```
summer create 2d-platformer my-game
cd my-game
bash tests/autopilot/run.sh   # boots the game offscreen; must exit 0 with no engine errors
```

## Controls

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Move | A / D or Left / Right | Left stick |
| Jump (hold for height; press again in the air to double jump) | Space, W or Up | A |
| Aim down (down attack in the air) | S or Down | Left stick down |
| Dash | Shift | RB |
| Attack (3-hit combo, up / down / forward) | X or J | X |
| Interact (NPCs, benches, pickups, doors) | E | Y |
| Pause | Escape | Start |

## What's Included

**Player** (`scripts/player/player_controller.gd`, `scripts/combat/player_combat.gd`)
- Run, jump with coyote time, jump buffer and variable height, asymmetric gravity, double jump, wall slide and wall jump, 8-direction dash with cooldown, stomp-to-kill
- Sword combo with directional attacks; the down attack bounces you off enemies
- Hearts-based HP with invincibility frames and knockback, death and bench respawn
- Squash/stretch, landing and jump particles, screen shake and hitstop on impacts

**Abilities** (`scripts/autoloads/ability_manager.gd`)
- dash, wall_climb, double_jump, down_attack, charged_attack tracked and saved
- Pickups placed for dash (room_02) and wall climb (room_04); dash is also granted at boot so the first room is fully traversable
- `AbilityGate` and `Door.requires_ability` are ready for gating; the shipped world is fully open

**World** -- 7 rooms in `scenes/rooms/`, connected by doors and managed by `RoomManager` + `SceneTransition`
- room_01 hub (Elder NPC, bench, patrol enemy) -- room_02 Mossy Grotto (dash pickup, enemies) -- room_04 Fungal Depths (wall-climb pickup, crumbling platforms) -- room_05 (moving platforms, flying enemies) -- room_06 (Crystal Queen boss arena)
- room_01 -- room_03 (patrol and flying enemies) -- room_07 (Garden Spirit NPC)

**Enemies and boss**
- Patrol enemy (turns at edges and walls, player detector), flying enemy (sine-wave flight)
- Crystal Queen boss with a state machine, telegraphed attacks and a health bar

**NPCs, quests, shop, saves**
- NPCs with JSON dialogue (`data/dialogue/`) and a typewriter dialogue box; Elder and Garden Spirit are placed
- Quests from `data/quests/` (Explore the Grotto, Fungal Harvest, Defeat the Crystal Queen) with a quest journal
- Shop UI (`scenes/ui/shop.tscn`) opened by an NPC flagged `is_shopkeeper`; the shopkeeper dialogue ships, the NPC itself is not placed yet
- Benches heal, save and set your respawn point; `SaveManager` persists abilities, rooms, quests, HP and coins to `user://save_data.json`

**UI**
- HUD (hearts, coins, controls hint), pause menu (Resume / Quest Journal / Map / Restart / Main Menu), room map, quest journal, shop, main menu, game over, dialogue box

## Project Structure

```
scripts/
  autoloads/   EventBus, AbilityManager, RoomManager, GameManager, QuestManager,
               SaveManager, SceneTransition, AudioManager
  player/      PlayerController, CameraController
  combat/      PlayerCombat, HitArea2D, HurtArea2D
  enemies/     BaseEnemy, PatrolEnemy, FlyingEnemy
  bosses/      CrystalQueen
  npcs/        NPCController, DialogueRunner
  systems/     Door, Bench, AbilityPickup, AbilityGate, Coin, Killzone, CrumblingPlatform,
               MovingPlatform, RoomLoader, ParallaxBg, JuiceManager, FloatingText
               (+ legacy BouncePad, OneWayPlatform, Checkpoint, Gem, LevelEnd)
  ui/          HUD, PauseMenu, QuestJournal, Map, Shop, MainMenu, GameOver
               (+ legacy LevelSelect, Victory, LevelComplete)
scenes/
  rooms/       room_01 .. room_07
  player/ enemies/ bosses/ npcs/ doors/ systems/ ui/
  levels/      legacy linear levels; nothing in the game loads them
data/
  dialogue/    elder, garden_spirit, shopkeeper
  quests/      explore_grotto, fungal_harvest, defeat_queen
assets/sprites/  background.png, menu_bg.png
```

## Collision Layers

| Layer | Name | Value | Used By |
|-------|------|-------|---------|
| 1 | World | 1 | Platforms, walls, NPC bodies |
| 2 | Player | 2 | Player |
| 3 | Enemies | 4 | Enemies and the boss |
| 4 | PlayerAttack | 8 | Player sword hitbox |

Interactables (doors, benches, pickups, NPC zones) are Area2Ds on layer 0 that detect layer 2.

## How to Extend

**Add a room:** duplicate a room scene, keep `room_loader.gd` on the root and set `room_id`, add door pairs (`door_id` / `target_room_id` / `target_door_id` on both sides), and register the path in `scripts/autoloads/room_manager.gd` `room_paths`. Never place the player in a room scene; RoomManager spawns it at the door.

**Gate progress:** set `requires_ability` on a door or put `scenes/systems/ability_gate.tscn` in the way, then add a pickup with the matching `ability_name`.

**Add an enemy:** extend `scripts/enemies/base_enemy.gd`, override `_setup()` and `_ai_process(delta)`; collision layer 4, mask 1.

**Tune the feel:** everything is `@export` on PlayerController: `max_speed` (280), `acceleration` (1800), `friction` (2400), `jump_velocity` (-440), `gravity_up` (1100), `gravity_down` (1400), `coyote_time` (0.08), `jump_buffer_time` (0.1), `dash_speed` (480), `wall_jump_velocity` (320, -400), `landing_squash`, `jump_stretch`, `turn_boost` (1.6).

**Add audio:** `AudioManager` has the crossfade and SFX plumbing; assign streams and hook EventBus signals such as `player_jumped`, `player_landed`, `coin_collected`, `enemy_killed`, `player_attacked`.

## Verifying a Change

`bash tests/autopilot/run.sh` in a created project drives the player through room_01 offscreen and fails on any engine error or warning. Keep it green. Agent-facing detail lives in `CLAUDE.md`.

## License

MIT
