# Description #

Doolittle was created because it's very difficult to create a "do what I mean" macro which randomizes your mounts.  You can create a macro which summons a random mount, but you can't control whether that mount is of the appropriate type and speed.  You can create a macro which gives you an appropriate mount, but it'll be the same ones each time.

Enter Doolittle.  With single keypress, you can get a randomly-selected mount of the appropriate type, weighted so that your favorite ones come up more often.  It's even aware of situations you can't normally macro around, such as Dalaran and Wintergrasp.  Companions (a.k.a mini-pets) can also be given ratings and summoned randomly.

## Current features ##

  * Random mount and companion selection via keybinding or macro command
  * "Star ratings" so that your favorites come up more often… and your least favorites never do!
  * Use any "macro option" when summoning mounts, e.g. `/mount [mounted]dismount;[flyable,nomodifier]flying;ground` so that you can hold Shift to get a ground mount even in flyable areas
  * "Smart" mount selection, knows about Dalaran, Wintergrasp, and Cold-Weather Flying.

## Planned features ##

  * Auto-summoning of companions — "hands-free" minipet management!
  * Finer-grained control in mount macros (select speeds or even specific mounts)
  * Option to select specific companions via '/companion' command
  * "Preview" macros — see which pet/mount will be summoned before you press the button

# Usage #

Doolittle has three basic commands, each of which has a keybinding as well:

| `/doolittle` | Open the Doolittle options window. |
|:-------------|:-----------------------------------|
| `/companion` | Summon a companion.                |
| `/mount`     | Summon a mount.                    |

The keybindings can be found in the Doolittle options panel or via the Keybindings button in WoW's game menu.

## `/doolittle` ##

You can open a specific section of the Doolittle options by adding it to the command:

| `/doolittle main` | The default options; same as just `/doolittle`. |
|:------------------|:------------------------------------------------|
| `/doolittle advanced` | You can fiddle with the internals of the randomization system in the Advanced section. |
| `/doolittle profile` | By default, all of your characters use the same set of ratings and options.  You can switch to per-character in the Profiles section. |
| `/doolittle about` | Basic information about the addon, including the version number (for bug reports). |

## `/companion` ##

Just summons a random companion.

## `/mount` ##

On its own, summons a random mount according to the "default mount macro" (see the Configuration section below).  The macro which comes with Doolittle is `[mounted]dismount;[swimming]swimming;[flyable]flying;ground` — in other words, dismount if you're mounted, otherwise summon a swimming mount if you're swimming, otherwise summon a flying mount if you're in an area where you can fly, otherwise summon a plain old ground mount.  However, you can specify your own macro, too.  All macro options are supported (though not all make sense, like `[combat]` or `[target=]`) and you can choose from the following commands:

| `dismount` | Unsurprisingly, dismounts you. |
|:-----------|:-------------------------------|
| `flying`   | Summons a flying mount.  If you have no flying mounts, are in Northrend and don't know Cold Weather Flying, or are in Dalaran (and not in Krasus' Landing) or Wintergrasp, summons a ground mount instead. |
| `ground`   | Summons a ground mount.        |
| `swimming` | Summons a swimming mount.  If you have no swimming mounts, summons a ground mount instead. |

### Examples ###

_Coming Soon_

# Configuration #

_Coming Soon_