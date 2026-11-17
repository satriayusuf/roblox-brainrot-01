# roblox-brainrot-01
[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/satriayusuf/roblox-brainrot-01/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/satriayusuf/roblox-brainrot-01/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

**Tsunami Brainrot Cove** — a 3D Roblox brainrot game on a sunny seaside plaza that a tsunami
sweeps every few minutes. Brainrots roll down a conveyor belt across the plaza with price tags
on them: buy one off the belt, carry it home on your head, and stand it on a pad at your base,
where it prints cash every second. But a placed brainrot is only safe while your base is
locked — rivals can walk into an unlocked base and steal it right off its pad (you get a loud
alarm), or whack you with a bat to knock the one on your head loose for anyone to grab. Climb
the ladder — Common, Rare, Epic, Legendary, Mythic, plus Gold (x3) and Diamond (x6) mutations —
with up to 8 pads per base and rebirths that trade your crew for a permanent income multiplier
and longer base locks. When the 10-second tsunami warning sounds, run: a catch carried outside
your own base when the wall of water reaches you is washed away, stolen or not, and so is
anyone caught in the open.

The loop, all in Roblox's 3D world with a ScreenGui HUD over it:

- **Buy** — brainrots roll down the plaza belt wearing BillboardGui tags (name, rarity, $/s, price = income × 75). Buy one before it reaches the end and swims away.
- **Carry** — a bought, stolen or grabbed brainrot rides above your head; one at a time.
- **Place** — stand it on one of your base's pads; its nameplate shows its rarity and $/s, and your cash ticks up every second.
- **Steal** — any brainrot standing on an *unlocked* rival base can be stolen off its pad; the owner gets a ⚠ alarm toast, and the catch is yours once you place it on your own pad.
- **Defend** — whack a carrier with your bat and their catch drops at their feet, free for anyone to grab; lock your base (60s + 10s per rebirth, then a 60s cooldown) to raise barrier walls, disable steal prompts and push intruders out.
- **Climb** — more pads (4 free, 4 more to buy) and the Rebirth Shrine (+50% income per rebirth, forever).
- **Survive** — a tsunami warns, then sweeps the map; bases are safe, the plaza is not.

Everything is code: a server world generator builds the island, sea, belt, bases, shrine and
decorations from Parts at startup, characters are assembled from Parts by a factory module, and
there are no toolbox models, no external asset ids and no DataStore (progress is session-only).

## Layout

- `src/shared/GameData.luau` — the cast, rarities, belt prices, lock and bat tuning, wave timing (ReplicatedStorage).
- `src/server/` — `init.server.luau` bootstrap, `WorldGen` (the world), `CharacterFactory` (the
  characters), `GameServer` (belt, economy, stealing, bats, locks, rebirth, wave consequences), `Tsunami` (the wave).
- `src/client/Game.client.luau` — the HUD: cash, income, rebirth count, toasts, wave banner.
- `main.ts` (Node 22) hands the entry in: it copies `game.rbxl`, `src/`, `screenshots/` and
  `PLAY.json` to the output directory and writes `dossier.json` with `vendor/makefun-roblox.ts`.

## Build and play

Build the place with [Rojo](https://rojo.space/):

    rojo build default.project.json --output game.rbxl

Then open `game.rbxl` in Roblox Studio and press Play — or publish it to your experience and play
it on Roblox. Hand the entry in the way the grader does:

    mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

`PLAY.json` names the published place and its universe; one of the screenshots in `screenshots/`
is also the experience's first thumbnail on Roblox.
