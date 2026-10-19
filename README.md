# 🌀 Portal Device 

<p align="center">
  <strong>🌀 WUBBA LUBBA DUB-DUB!</strong>
  <br>
  <sub>Built by Louis · Portal Device v1.0.1</sub>
</p>

---

<p align="center">
  <strong>A Rick and Morty-inspired portal device for Roblox.</strong>
  <br>
  Teleportation, live coordinate tracking, saved locations, and click-to-teleport controls.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Version-1.0.1-5aff6e?style=for-the-badge" alt="Version 1.0.1">
  <img src="https://img.shields.io/badge/Platform-Roblox-111111?style=for-the-badge&logo=roblox" alt="Platform Roblox">
  <img src="https://img.shields.io/badge/Language-Luau-00A2FF?style=for-the-badge" alt="Language Luau">
</p>

---

## ⚡ Overview

**Portal Device** is a lightweight teleportation tool built with Luau, featuring a custom interface inspired by the interdimensional technology of *Rick and Morty*.

Track your position, save favorite locations, teleport using custom coordinates, and move around the map with the click-to-teleport system.

## ✨ Features

- 🟢 **Custom GUI** — Draggable interface with a green sci-fi aesthetic.
- 📍 **Live Coordinates** — Track your character's current X, Y, and Z position in real time.
- 💾 **Saved Locations** — Save, name, and revisit up to 5 locations.
- 🌀 **Quick Teleport** — Teleport to any saved location with a single click.
- 🎯 **Manual Teleport** — Enter custom X, Y, and Z coordinates directly.
- 🖱️ **Click Teleport** — Teleport to a point on the map by clicking it.
- ⌨️ **Custom Activation Key** — Configure the keyboard shortcut for toggling click teleport. Default: `G`.
- 🛡️ **Input Validation** — Rejects invalid coordinates, including non-numeric values and infinities.
- 🔄 **Character Support** — Initializes the interface and updates coordinates when the character spawns.
- 🟩 **Status Feedback** — Displays system status, teleport results, and input errors.

## 🛠️ Installation

1. Download `PortalDevice-By-Louis.lua` from this repository.
2. Open your supported Luau execution environment.
3. Load and execute the script.
4. Use the interface to save locations, enter coordinates, or activate click teleport.

> **Note:** The script was tested on Xeno. Compatibility with other executors and Roblox experiences is not guaranteed. It is designed for client-side execution, and teleportation may be restricted by the server.

## 🎮 Controls

| Control | Action |
|---|---|
| `Right Ctrl` | Show / hide the interface |
| `SAVE` | Save your current coordinates |
| `GO` | Teleport to a saved location |
| `TELEPORT TO COORDINATES` | Teleport to manually entered coordinates |
| `CLICK TP: ON/OFF` | Enable or disable click teleport |
| `SET KEY` | Configure the click teleport activation key |
| `G` (default) | Toggle click teleport on or off |
| `Left Mouse Button` | Teleport to the clicked map position while click TP is active |
| `Esc` | Cancel key configuration |

## 🛠️ Configuration

Customize the interface, colors, saved location slots, and click teleport activation key directly in the script.

```lua
local VERSION = "1.0.1"

local GREEN = Color3.fromRGB(90, 255, 110)
local DARK = Color3.fromRGB(8, 20, 12)

local SLOT_COUNT = 5

local clickTeleportEnabled = false
local clickTeleportKey = Enum.KeyCode.G
```

## ⚠️ Limitations

- Saved locations are not persisted between script executions.
- Teleportation is performed on the client.
- The script does not verify whether a destination is safe or reachable.
- Click teleport depends on the mouse hit position and the geometry of the map.
- Client-side teleportation is not guaranteed to be accepted or replicated by the server.
- Compatibility depends on the execution environment and the Roblox experience.
- Some experiences may implement server-side validation or movement restrictions that prevent teleportation.

## 🧪 Technical Details

- **Language:** Luau
- **Platform:** Roblox
- **Interface:** Roblox `ScreenGui`
- **Input Handling:** `UserInputService`
- **Position Tracking:** `HumanoidRootPart`
- **Teleportation:** `CFrame`
- **Saved Locations:** 5 configurable slots

---

<p align="center">
  <strong>Built with Luau by Louis.</strong>
  <br>
  <sub>Inspired by the interdimensional chaos of Rick and Morty.</sub>
</p>
