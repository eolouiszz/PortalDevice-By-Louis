# 🌀 Portal Device

<p align="center">
  <strong>🌀 WUBBA LUBBA DUB-DUB!</strong>
  <br>
  <sub>Built by Louis · Portal Device v1.0.0</sub>
</p>

---

<p align="center">
  <strong>A Rick and Morty-inspired portal device for Roblox.</strong>
  <br>
  Teleportation, coordinate tracking, and saved locations.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Version-1.0.0-5aff6e?style=for-the-badge" alt="Version 1.0.0">
  <img src="https://img.shields.io/badge/Platform-Roblox-111111?style=for-the-badge&logo=roblox" alt="Platform Roblox">
  <img src="https://img.shields.io/badge/Language-Luau-00A2FF?style=for-the-badge" alt="Language Luau">
</p>

---

## ⚡ Overview

**Portal Device** is a lightweight teleportation tool built with Luau, featuring a custom interface inspired by the interdimensional technology of *Rick and Morty*.

Navigate coordinates, save locations, and manage teleportation through a compact, draggable interface.

## ✨ Features

- 🟢 **Custom GUI** — Compact, draggable interface with a green sci-fi aesthetic.
- 📍 **Live Coordinates** — Track your character's current X, Y, and Z position.
- 💾 **Saved Locations** — Save and name up to 5 locations.
- 🌀 **Quick Teleport** — Teleport to saved coordinates.
- 🎯 **Manual Teleport** — Enter custom coordinates directly.
- ⌨️ **Toggle Interface** — Press `Right Ctrl` to show or hide the window.
- 🛡️ **Input Validation** — Rejects invalid coordinate values.
- 🔄 **Character Support** — Initializes the interface when the character spawns.

## 🛠️ Installation

1. Download `PortalDevice-By-Louis.lua` from this repository.
2. Open your preferred executor.
3. Load the script and execute it in your environment.

> **Note:** This script is designed to run on client-side executors. It has only been tested on Xeno, so compatibility with other executors and Roblox experiences is not guaranteed.

## 🎮 Controls

| Control | Action |
|---|---|
| `Right Ctrl` | Show / hide the interface |
| `SAVE` | Save your current coordinates |
| `GO` | Teleport to the selected saved coordinates |
| `TELEPORT TO COORDINATES` | Teleport to manually entered coordinates |

## 🧪 Configuration

The interface colors, window dimensions, and number of location slots can be customized directly in the script.

```lua
local VERSION = "1.0.0"

local GREEN = Color3.fromRGB(90, 255, 110)
local DARK = Color3.fromRGB(8, 20, 12)

local SLOT_COUNT = 5
```

## ⚠️ Limitations

- Saved locations are not persisted between script executions.
- Teleportation is performed on the client.
- The script does not verify whether a destination is safe or reachable.
- Client-side teleportation is not guaranteed to be accepted by the server.
- Compatibility depends on the executor and the Roblox experience.

---

<p align="center">
  <sub>Built with Luau by Louis.</sub>
</p>
