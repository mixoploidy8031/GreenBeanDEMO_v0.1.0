# Grubby Gobblin' - Known Game-Breaking Bug

## **Game-Breaking Bug: Pausing While on Moving Platforms**

### **Description**
If the player pauses the game while standing on any moving platform, it will cause the game to enter a broken state. Upon unpausing, the screen turns grey, and the player appears to be missing or invisible. Additionally, **all audio stops working**. This issue forces the player to restart the game entirely.

### **Cause**
The issue is directly related to how **`Engine.time_scale`** is used to pause the game. When **`Engine.time_scale` is set to 0**, animations and physics are completely halted. If the player is standing on a moving platform, the physics and collision states do not properly resume when unpausing. As a result, the game logic desynchronizes, causing:

- **Player Despawn/Invisible State**: The player’s position is not properly retained or updated when time resumes.
- **Grey Screen**: This could be related to the fade/transition logic, animation timing, or other post-processing effects not resuming properly.
- **Audio Loss**: Since `Engine.time_scale = 0` affects the **AudioServer**, all sounds are essentially "paused" but do not properly resume.

### **Steps to Reproduce**
1. Stand on any **moving platform**.
2. Press the pause button (mapped to the "pause" input action) while on the platform.
3. Unpause the game.
4. Observe that the screen is grey, the player is invisible, and the audio is silent.

### **Workarounds**
#### **Option 1: Disable Pausing on Moving Platforms**
Prevent pausing entirely if the player is standing on a moving platform. This can be done by detecting if the player’s collision shape is overlapping with a platform using `get_overlapping_areas()` and `get_overlapping_bodies()`.

#### **Option 2: Adjust Pause Speed (Recommended)**
Instead of using `Engine.time_scale = 0`, use a value like **0.01** to simulate a pause. This keeps physics and player animations "technically running" but at an imperceptibly slow speed. This avoids the issue of physics desync and preserves the player's position and collision state.
Animations play and audio will still play at regular speed in this case.


### **Proposed Fix**
- **Option 1**: Use `Engine.time_scale = 0.01` instead of `0` to prevent total animation freeze.
- **Option 2**: Implement a manual pause system using `set_physics_process(false)`, `set_process(false)`, and `AnimationPlayer.pause()`, as opposed to controlling everything globally via `Engine.time_scale`.

### **Status**
- **Bug Acknowledged**: ✅
- **Current Workaround**: Use `Engine.time_scale = 0.01` instead of `0` for pause logic.
- **Long-Term Solution**: Implement a custom pause system that pauses player, enemies, animations, and tweens directly instead of using `Engine.time_scale`.

### **Notes for Developers**
This bug only occurs **when the player is standing on a moving platform**. If the player pauses the game on normal ground, everything works fine. This issue is related to Godot’s internal handling of physics bodies, collisions, and position updates while `Engine.time_scale = 0`.

If you’d like to contribute to fixing this bug, please consider submitting a PR or providing feedback on potential solutions.
