# Player B (MeeleGuy) Implementation Guide

## Overview
This document describes the implementation of Player B (MeeleGuy) character selection in the 3d-character-testing project.

## What Was Implemented

### 1. Player Selection System
The game now features a main menu where players can choose between:
- **Player A**: The original mannequin character
- **Player B**: The new MeeleGuy character

**How it works:**
1. Game starts at `MainMenu.tscn` (configured in project.godot)
2. User clicks either "Player A – Mannequin" or "Player B – Meele Guy" button
3. `MainMenu.gd` stores the selection in `Global.player_scene`
4. Scene changes to `Game.tscn`
5. `Game.gd` spawns the selected player (or default Player.tscn if no selection)

### 2. Player B Scene Structure
`src/Player/PlayerMeele.tscn` contains:
- Root: `Player` (KinematicBody) with `Player.gd` script
- `CameraRig`: Camera system with mouse-look control
- `MannequinyMeele`: Visual model with AnimationTree
- `StateMachine`: Movement state machine (Idle, Move/Run, Air states)
- `CollisionShape`: Player collision capsule

This structure **exactly mirrors** Player A, ensuring consistent behavior.

### 3. Animation System
`src/Player/MannequinyMeele.gd` controls MeeleGuy animations:
- **API**: Identical to `Mannequiny.gd` (maintains compatibility)
- **States**: IDLE, RUN, AIR, LAND
- **Parameters**:
  - `move_direction`: Controls walk/run blend
  - `is_moving`: Triggers idle ↔ move transitions
- **AnimationTree structure** (must be configured in Godot Editor):
  ```
  Root: AnimationNodeStateMachine
  ├── idle (Animation: MeeleGuy/idle)
  ├── move_ground (BlendSpace1D)
  │   ├── Point 0.0: MeeleGuy/walk
  │   └── Point 1.0: MeeleGuy/run
  ├── jump (Animation: MeeleGuy/jumping)
  └── land (Animation: MeeleGuy/idle - reused)
  ```

### 4. Mouse-Look Camera Control
`src/Player/Camera/CameraRig.gd` now includes:
- **Mouse sensitivity**: Adjustable via export variable (default: 0.1)
- **Pitch clamping**: Min -80°, Max +80° (prevents camera flip)
- **Yaw rotation**: Applied to CameraRig (horizontal look)
- **Pitch rotation**: Applied to SpringArm (vertical look)
- **Input handling**: Only active when mouse is captured

**Controls:**
- Move mouse: Rotate camera
- ESC: Toggle mouse capture (via `toggle_mouse_captured` action)
- WASD: Move character (camera-relative)
- Space: Jump

## Files Modified

### Core Implementation Files
1. **src/Main/Game.gd**
   - Added `default_player_scene` export variable
   - Added `_spawn_selected_player()` function
   - Dynamically spawns selected player on game start

2. **src/Player/Camera/CameraRig.gd**
   - Added mouse sensitivity and pitch limit exports
   - Added `_unhandled_input()` for mouse-look
   - Added `_pitch` variable to track vertical rotation

### Pre-existing Files (Verified)
3. **Global.gd** - Singleton with `player_scene` variable
4. **MainMenu.gd/tscn** - Menu with player selection buttons
5. **src/Player/MannequinyMeele.gd** - Animation controller for MeeleGuy
6. **src/Player/PlayerMeele.tscn** - Complete Player B scene
7. **src/Player/MannequinyMeele.tscn** - MeeleGuy model with AnimationTree
8. **assets/characters/meele-guy/meele-guy.glb** - MeeleGuy 3D model

## Testing Instructions

### Prerequisites
- Godot Engine 3.2 or later
- This repository cloned locally

### Test Procedure

#### 1. Open in Godot Editor
```bash
# Open project
godot project.godot
```

#### 2. Verify AnimationTree Setup
⚠️ **IMPORTANT**: The AnimationTree in `MannequinyMeele.tscn` must be configured:

1. Open `src/Player/MannequinyMeele.tscn`
2. Select the `AnimationTree` node
3. In the Inspector, verify:
   - `Active`: Should be checked
   - `Anim Player`: Should reference the AnimationPlayer node
   - `Tree Root`: Should be an AnimationNodeStateMachine

4. Click "Edit" button next to Tree Root
5. Verify state machine structure:
   - States: `idle`, `move_ground`, `jump`, `land`
   - `move_ground` should be a BlendSpace1D with walk and run animations
   - Transitions should use `conditions/is_moving` parameter

6. If not configured, set it up:
   - Add state machine nodes
   - Connect animations from MeeleGuy AnimationPlayer
   - Add blend space for walk/run
   - Configure parameters: `move_ground/blend_position`, `conditions/is_moving`

#### 3. Test Player A (Mannequin)
1. Run the project (F5)
2. Main menu should appear
3. Click "Player A – Mannequin"
4. Verify:
   - ✓ Mannequin character appears
   - ✓ WASD moves character relative to camera
   - ✓ Mouse rotates camera
   - ✓ Space bar jumps
   - ✓ Character walks when moving slowly
   - ✓ Character runs when moving quickly
   - ✓ Camera pitch clamps at ±80 degrees

#### 4. Test Player B (MeeleGuy)
1. Restart the project
2. Click "Player B – Meele Guy"
3. Verify:
   - ✓ MeeleGuy character appears
   - ✓ WASD moves character relative to camera
   - ✓ Mouse rotates camera
   - ✓ Space bar jumps
   - ✓ Character uses MeeleGuy walk animation
   - ✓ Character uses MeeleGuy run animation
   - ✓ Walk/run blend smoothly
   - ✓ Idle animation plays when stopped
   - ✓ Jump animation plays when in air
   - ✓ Camera pitch clamps at ±80 degrees

#### 5. Test Mouse Capture Toggle
1. During gameplay, press ESC
2. Mouse should release (visible cursor)
3. Click anywhere to recapture mouse
4. Camera should resume responding to mouse movement

### Common Issues and Solutions

#### Issue: MeeleGuy animations don't play
**Solution**: AnimationTree not configured properly
1. Open `MannequinyMeele.tscn`
2. Follow "Verify AnimationTree Setup" instructions above
3. Make sure animations are assigned from the MeeleGuy AnimationPlayer

#### Issue: Camera doesn't rotate with mouse
**Solution**: Mouse might not be captured
1. Click in the game window to capture mouse
2. Check that `toggle_mouse_captured` input action exists in project settings
3. Verify `CameraRig.gd` has the `_unhandled_input` function

#### Issue: Game crashes when selecting Player B
**Solution**: PlayerMeele.tscn might be missing or misconfigured
1. Verify `src/Player/PlayerMeele.tscn` exists
2. Check that it has a MannequinyMeele child node
3. Ensure MannequinyMeele.tscn is properly saved

#### Issue: Character moves but animations are frozen
**Solution**: AnimationTree might not be active
1. Open `MannequinyMeele.tscn`
2. Select AnimationTree node
3. Check "Active" in Inspector
4. Verify Tree Root is configured

## Architecture Notes

### Why This Design?
The implementation maintains strict compatibility with the original Player system:
- **Same input system**: Both players use identical controls
- **Same state machine**: Both players use Move/Idle/Air/Land states
- **Same camera system**: Both players use the same CameraRig
- **Only difference**: Visual model and animations

This ensures:
- Easy maintenance (no duplicate logic)
- Consistent gameplay feel
- Simple to add more characters (just create new Mannequiny variants)

### Where Attack Animations Should Go (Future Work)
The MeeleGuy model includes attack animations (`kick`, `punch`, etc.) that are **not** integrated in this PR. To add them later:

**Option A: Shared Attack System** (Recommended)
1. Add new states to base StateMachine: `Attack`, `Combo`
2. Create attack state scripts in `src/Player/States/Attack.gd`
3. Add attack inputs to project settings (e.g., "attack_punch", "attack_kick")
4. Both mannequin and MeeleGuy get attack capabilities
5. Each character's Mannequiny script maps to their specific attack animations

**Option B: MeeleGuy-Specific Attacks**
1. Create `PlayerStateMeele.gd` extending `PlayerState`
2. Add meele-specific states: `AttackMeele`, `ComboMeele`
3. Only MeeleGuy gets attack system
4. More code duplication but allows character-specific mechanics

### State Machine Flow
```
Start
  ↓
Idle ←→ Move/Run (based on is_moving)
  ↓
Air (jump pressed)
  ↓
Land → Idle
```

Each state calls `transition_to()` on the Mannequiny script, which drives the AnimationTree.

## Future Enhancements

### Strafing
MeeleGuy has strafe animations. To add:
1. Detect movement direction relative to camera
2. Add strafe left/right blend nodes to AnimationTree
3. Use 2D BlendSpace instead of 1D for move_ground

### Attack Combo System
1. Add attack states to StateMachine
2. Implement combo timer and chain logic
3. Map attack animations to combo stages
4. Add hit detection and damage system

### Dash/Speed Variations
MeeleGuy model supports dash speeds:
1. Add sprint input (Shift key)
2. Modify movement speed in Run state
3. Add dash animation to blend space

## Troubleshooting Checklist

Before reporting issues, verify:
- [ ] Godot version 3.2 or later
- [ ] All files present (check git status)
- [ ] project.godot has Global autoload
- [ ] MainMenu.tscn is set as main scene
- [ ] AnimationTree in MannequinyMeele.tscn is configured
- [ ] MeeleGuy animations imported correctly from GLB
- [ ] No GDScript errors in Output panel

## References
- Original project: https://github.com/GDQuest/godot-3d-mannequin
- State Machine pattern: http://gameprogrammingpatterns.com/state.html
- Godot AnimationTree docs: https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html
