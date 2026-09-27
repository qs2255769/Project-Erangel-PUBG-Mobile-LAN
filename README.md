# Project Erangel — PUBG Mobile LAN

An independent, community-led preservation and interoperability project focused on bringing **local-area-network (LAN) multiplayer** to the legacy **PUBG Mobile 0.13.4** client.

> [!IMPORTANT]
> This project is unofficial and is not affiliated with, endorsed by, or sponsored by KRAFTON, Tencent Games, LIGHTSPEED STUDIOS, or PUBG Corporation. PUBG and related names, trademarks, game files, and assets belong to their respective owners.

## Why this project exists

PUBG Mobile 0.13.4 represents an older era of the game that many players remember for its gameplay, maps, interface, and community. As official services evolve, old client versions can become impossible to use—even between devices on the same local network.

The aim of Project Erangel is to preserve the technical knowledge needed to make this legacy version playable again in a controlled, private environment. The long-term goal is for players and researchers to host a match on one device or computer and allow nearby devices to join over Wi-Fi or Ethernet without depending on the official online infrastructure.

This work is also intended to document how an older mobile multiplayer title handled its lobby flow, session discovery, match startup, replication, player spawning, world streaming, and other networked systems. That knowledge can be useful for software preservation, protocol research, education, and legitimate interoperability work.

## Project goals

- Enable host-and-client multiplayer over a trusted LAN.
- Add automatic discovery of a local host where practical.
- Restore the basic lobby-to-match flow for version 0.13.4.
- Investigate player spawning, movement, replication, combat, vehicles, loot, bots, and match state.
- Make offline or locally hosted matches independent of discontinued official services.
- Document discoveries so other researchers can reproduce and improve the work.
- Keep all original project code open source and community-reviewable.

## Current research areas

The project may include work on:

- Local session hosting and discovery
- Login and lobby flow replacement for local testing
- Map loading and match-state transitions
- Host and client player visibility
- Movement and combat replication
- World streaming and ground-loading issues
- Plane, parachute, spawn, and match-start behavior
- Native loot, bots, monsters, audio, UI, and game-mode systems
- Packet captures, protocol notes, and Termux/Linux server experiments

## Non-goals

This project is **not** intended to:

- Connect modified clients to official PUBG Mobile services.
- Bypass payments, authentication, anti-cheat, bans, or access controls on live services.
- Provide cheats or an unfair advantage in public or competitive matches.
- Distribute APKs, OBBs, PAKs, extracted assets, proprietary source code, encryption keys, credentials, or other copyrighted game material.
- Impersonate an official PUBG Mobile server or service.

## Repository policy

Only code, documentation, configuration examples, patches, and research notes that contributors are legally allowed to share should be committed. Users must supply their own lawfully obtained game client and must follow the laws and license terms that apply in their jurisdiction.

Do not open an issue or pull request containing secrets, account tokens, copyrighted game archives, decryption keys, or personal information. Use sanitized logs and small original test fixtures whenever possible. The root `.gitignore` excludes common extracted game dumps and package files.

## Current contents

- `client/MapPath.lua`: project-authored map-selection configuration.
- `docs/native-match-startup.md`: notes on the local listen-server startup investigation and the limits of the supplied SDK dump.

The original game Lua files, Blueprint JSON, SDK dumps, and game packages are deliberately not included.

## Development status

**Early research and prototyping.** Expect incomplete features, crashes, breaking changes, and version-specific behavior. The initial target is PUBG Mobile 0.13.4; support for other versions is outside the first milestone.

## Initial roadmap

1. Document the 0.13.4 client environment and reproducible test setup.
2. Establish reliable host discovery and joining on the same LAN.
3. Complete the lobby, map-entry, and match-start lifecycle.
4. Stabilize player spawning, visibility, movement, and world streaming.
5. Restore combat, damage, loot, bots, audio, and UI incrementally.
6. Package clean setup instructions and repeatable tests.

## Contributing

Contributions involving networking, Lua, Unreal Engine research, Android, Termux, protocol analysis, testing, or technical documentation are welcome. Please keep changes focused, explain how they were tested, and avoid including proprietary material.

Before contributing, describe:

- The exact client version and platform tested
- Whether the device acted as host or client
- Network topology and relevant addresses with private details removed
- Expected and observed behavior
- Reproduction steps and sanitized logs

## Responsible research

Please test only on devices, software copies, and networks you own or are authorized to use. Report security findings responsibly, and do not use this work to disrupt services or other players.

## License

Original code in this repository is intended to be released under the **GNU General Public License v3.0 (GPL-3.0)**. Third-party trademarks and proprietary game materials are not covered by that license and must not be added to the repository.

## Project name

“Project Erangel” is a community project name used for identification. It does not indicate ownership of the Erangel or PUBG trademarks.
