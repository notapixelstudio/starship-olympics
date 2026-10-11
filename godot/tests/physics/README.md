# Physics stress tests

Headless checks for the physics engine (Box2D addon). Run them after updating
the `godot-box2d` addon or Godot itself, to catch regressions like ships or
missiles tunneling through walls.

They are standalone scripts: nothing in the game references them.

## How to run

From the `godot/` folder:

```sh
Godot --headless --path . --fixed-fps 60 -s res://tests/physics/<script>.gd
```

## Tests

| Script | What it does | Pass |
|---|---|---|
| `dash_wall_probe.gd` | Full-charge dash into every wall of `TestCollisions`, from several angles and distances (280 dashes) | `tunneled=0` |
| `corner_shot_probe.gd` | Ship in each corner of `deathmatch/pvp/2p`, rear to the wall, fires a full-charge missile (224 shots). Set `HOMING=0` to disable missile homing | `escaped=0` |
| `box2d_oneway_probe.gd` | Balls hit one-way walls from both sides | `blocked=true` and `passed=true` on every line |
| `box2d_probe.gd` | Bodies, joints, areas, raycasts, CCD. Prints positions to diff between two addon versions | output identical between versions |

`box2d_oneway_probe.gd` fails with the old addon build on Godot 4.7 (one-way
walls block both sides). It passes once the addon is built for Godot 4.7.

For reference, Godot's built-in physics fails the dash and corner tests
(49 tunnels, 76 escapes), while Box2D passes both.
