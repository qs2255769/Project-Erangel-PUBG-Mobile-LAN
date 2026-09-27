# Native match startup research

## Goal

This project aims to start the game's existing gameplay systems on a locally hosted UE listen server. It does not require a separate dedicated server to exist.

## What the supplied files show

- The client launch code travels with `GameplayStatics.OpenLevel` and the `?listen` URL option. This can create a local listen-server world, but it does not prove that the game's original match initialization has completed.
- The reflected SDK lists classes, properties, and function signatures. It does not include native function bodies or a verified call order.
- The Zombie Survival Blueprint data references a GameMode data asset, a level director class, and native match-state objects. Those are useful checks for whether the selected mode is configured.
- The supplied client archive does not include the dedicated-server Lua modules. A client-side `Server.*` API should not be assumed to exist.

## Investigation checklist

After the host finishes travel, record these values from the host's world:

1. Whether the world is authoritative and whether the active GameMode is the intended Zombie Survival Blueprint class.
2. Whether its GameMode data asset and level director are non-null.
3. Whether the map and mode URL values were received as intended (for the supplied Zombie Survival config: `mapid=20` and `ModeId=12012`).
4. Whether the Zombie mode reports `bMapLoaded`.
5. Whether the level manager has loaded level data and active levels.
6. The current native GameMode state before and after the game’s normal startup callbacks.

Use the first missing value to locate the failed initialization stage. Do not call state-transition or wave functions in isolation: the SDK does not show their prerequisites or call order, and the project’s previous direct-call attempts were unstable.

## Distribution boundary

This repository contains project-authored source and notes only. Do not add extracted game Lua, Blueprint JSON, SDK dumps, APK/OBB/PAK files, or other game assets. Each contributor must use their own legally obtained client files for local testing.
