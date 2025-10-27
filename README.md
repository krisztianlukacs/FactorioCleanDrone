# CleanDrone (Factorio 2.0)

A tiny mod that adds a **Clean Drone**: a flying helper that picks up items from the ground and delivers them to the nearest **purple (Active provider)** chest.

## Features
- Searches for ground items (`item-entity`), picks them up, and caches them as cargo.
- Flies to the nearest **Active provider** chest on the same force and inserts its cargo.
- Simple scripted movement; no charging required.
- Research gated by **red + green** science.
- Recipe: **1× logistic-robot + 1× coal → 1× Clean Drone**.

## Installation
1. Download the zip from your assistant and put it into your `Factorio/mods/` folder.
2. Launch Factorio and enable **CleanDrone** in the Mods menu.

## Tech & Recipe
- Technology: **CleanDrone** (50 units; ingredients: 1× red + 1× green; time: 15).
- Recipe (unlocked by the tech): 1× `logistic-robot` + 1× `coal` → 1× `Clean Drone`.

## Usage
1. Place at least one **Active provider chest** (purple).
2. Craft/place the **Clean Drone**.
3. The drone will start collecting ground items and drop them into the nearest purple chest.

## Notes
- The drone is not part of the vanilla logistic network AI; it is fully script-driven.
- Update cadence is every other tick for low overhead.
- Cargo is capped heuristically at ~100 items before delivery.
- You can retarget to Storage chests by changing `logistic_container_type` in `control.lua`.

Enjoy!
