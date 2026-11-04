# V23 — Bracket II and live repair

V23 adds the ten Impossible Realms, each with its 200 supplied cards, story, five bosses, deck box and background. The complete application contains 23 factions and 4,600 card definitions; the original thirteen factions and their Progressive Battles route are preserved.

Gameplay includes morph/materialization, bounded lane and shared resources, Collection, Great Bloom, gravity, Edicts and Appeal Seals, Lucidity, notes and Chords, real future-library reservations, cancellable omens, nonrecursive Echo, and Axiom phases with destructible Pillars. Defender combat supports legal blocking previews, overrides, damage assignments, lifelink and explicit confirmation of external-board casualties.

Bracket II progression is saved by the host service. Practice supports custom settings; ranked starts use the full original preset and standard settings. Importing an editable standalone Bracket II save opens it as practice.

## Repair fix

The prior installer attempted to rename the current program folder while the old Node service was still running from it. Windows held that directory in use and rejected the move.

The installer now validates the complete candidate before stopping the identified service, waits for that process to exit, and replaces the program folder with bounded retries. Failed promotion restores the previous program. Unrelated processes are never terminated to release a folder lock; the error instead identifies the folder to close. A per-installation mutex prevents simultaneous setup. Service records use UTF-8, and Windows PowerShell module paths are normalized for launch from PowerShell 7.

## Defined rule interpretations

The handoff named several laws and Edicts without specifying exact effects. These bounded interpretations were explicitly authorized:

| Rule | Effect |
|---|---|
| Limited mill | Prevent the first two combat mill damage total each defender cycle. |
| Guardian ward | Monster Defenders have ward {2}. |
| Redirection tax | The first human combat that mills each cycle deals one Core damage. |
| Mass | Monster Defenders get +0/+1. |
| Distance | Prevent the first one combat mill damage in each lane each cycle. |
| Recurrence / Sequence | At monster start, create one Axiom Guardian in the least occupied lane, at most once per two monster turns. |
| Silence | Monster Defenders have ward {2}. |

Pillars and sorcery Omen Anchors have three durability. Destroying an anchor cancels its event. Removing a Pillar suppresses its law through the next monster turn. The Ninth Note occurs once after three Chords and telegraphs three Core damage for the next monster turn. The original supplied card catalog is preserved.

## Verification

- Supplied validators: 2,000 unique card IDs and all twenty supplied images passed.
- New card execution: 4,000 empty/populated fixtures, 12,011 assertions and 147,311 commands.
- Runtime: 138 contract, 49 authority/network, 38 operator, 12 omen/anchor, 95 asset and 76 archive-provenance checks passed.
- Browser: 102 checks, no page errors or failed asset requests.
- Simulation: 900 monster rounds across ten factions and three seeds, with deterministic replay and bounded objects.
- Packaged installer: 60 integration checks, 142 installed-file/gameplay checks and four menu-return checks passed.
- Live repair: nine checks covering V20-to-V23 upgrade, campaign/Core preservation, unresponsive services, unrelated process identities, simultaneous setup and external folder locks.

Synthetic simulations verify structure and replay. Multiplayer balance and authored difficulties still require human playtesting with actual defender decks.
