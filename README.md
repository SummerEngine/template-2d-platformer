# 2D Platformer Template

A tight, responsive 2D platformer template for Summer Engine (Godot 4.6). Polished movement feel with coyote time, variable jump height, screen shake, hitstop, squash/stretch, and stomp-to-kill enemies.

## Controls

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Move | A/D or Arrow Keys | Left Stick |
| Jump | Space, W, or Up Arrow | A Button |
| Pause | Escape | Start |

**Jump mechanics:**
- Tap for short hop, hold for full jump (variable height)
- Jump works briefly after leaving a ledge (coyote time)
- Press jump slightly before landing and it still registers (jump buffering)
- Faster fall than rise (asymmetric gravity) for snappy, weighty arcs

## What's Included

**Player:**
- Full controller with coyote time, jump buffer, variable jump height, asymmetric gravity
- Turn boost (snappier direction changes), squash/stretch, landing/jump particles
- Stomp-to-kill enemies with bounce, invincibility on hit with knockback + flash
- Death/respawn with checkpoint support

**Enemies:**
- **Patrol Enemy** -- walks back and forth, turns at edges/walls, stompable (with flatten + death particles)
- **Flying Enemy** -- sine-wave flight pattern, wing flap animation, spin death on stomp

**Systems:**
- Collectible coins with bob animation and collect pop (+100 floating text)
- Moving platforms (smooth sinusoidal motion, player rides automatically)
- Bounce pads that launch the player with elastic visual feedback
- Checkpoints that update spawn position (flag turns green)
- Spike hazards and death plane (falling off map)
- Screen shake and hitstop on impacts
- Floating score text on coin collect and enemy kill
- Procedural parallax background (stars + mountain layers)
- Celebration particles on level complete

**UI:**
- Main menu (Start, Quit)
- HUD (lives, coins, score)
- Pause menu (Resume, Restart, Main Menu)
- Game over screen (Try Again, Main Menu)
- Level complete overlay with scale pop animation

**Two playable levels:**
- Level 1: Tutorial -- gentle ramp with platforms, spikes, coins, enemies, checkpoint, bounce pad
- Level 2: Challenge -- vertical platforming, moving platforms, flying enemies, multiple checkpoints, spikes

## Project Structure

```
scripts/
  autoloads/          # EventBus, GameManager
  player/             # PlayerController, CameraController (shake + hitstop)
  enemies/            # PatrolEnemy, FlyingEnemy
  systems/            # Coin, Killzone, LevelEnd, MovingPlatform, BouncePad,
                      # Checkpoint, ParallaxBg, FloatingText, JuiceManager
  ui/                 # MainMenu, HUD, PauseMenu, GameOver, LevelComplete
scenes/
  player/             # Player scene
  enemies/            # PatrolEnemy, FlyingEnemy scenes
  systems/            # Coin, Checkpoint, BouncePad scenes
  levels/             # Level 01, Level 02
  ui/                 # UI scenes
```

## Collision Layers

| Layer | Name | Value | Used By |
|-------|------|-------|---------|
| 1 | World | 1 | Platforms, ground |
| 2 | Player | 2 | Player character |
| 3 | Enemies | 4 | Patrol/Flying enemies |

## How to Extend

**Add a new level:**
1. Duplicate `scenes/levels/level_01.tscn`
2. Rearrange platforms, enemies, coins, checkpoints
3. Add the path to `GameManager.levels` array

**Add a new enemy type:**
1. Create script in `scripts/enemies/` extending `CharacterBody2D`
2. Implement `stomp()` method for player stomping
3. Add a `PlayerDetector` Area2D (collision_mask = 2) that calls `body.take_damage()`
4. Set collision_layer = 4, collision_mask = 1

**Tune the feel:**
All parameters are `@export` on PlayerController. Key ones:
- `max_speed` (280), `acceleration` (1800), `friction` (2400) -- ground movement
- `jump_velocity` (-440), `gravity_up` (1100), `gravity_down` (1400) -- jump arc
- `coyote_time` (0.08), `jump_buffer_time` (0.1) -- input forgiveness
- `landing_squash`, `jump_stretch` -- visual feedback intensity
- `turn_boost` (1.6) -- direction change snappiness

**Add audio:**
Hook into EventBus signals in a new AudioManager autoload:
- `player_jumped` -- jump sound
- `player_landed` -- landing thud
- `coin_collected` -- pickup chime
- `enemy_stomped` -- stomp impact
- `enemy_killed` -- defeat sound

## License

MIT
