# DIM wishlist generator

A bunch of scripts for generating [DIM wishlists](https://github.com/DestinyItemManager/DIM/blob/master/docs/COMMUNITY_CURATIONS.md) from a human-readable source file.

If you're not comfortable with *nix command-line tools, this is probably not for you.

## Installation

```sh
git submodule add git@github.com:gelraen/destiny2-dim-wishlist-generator.git gen
ln -s gen/Makefile
make install-hooks  # optional, but highly recommended
make
git add data/
```

This will add this repository as a submodule, install pre-commit hook to keep
generated files up to date, and generate macros for perk and weapon hashes.

## Usage

Create a file with `.m4` extension and write your wishlist there. Example:

```
title:My personal wishlist

//notes:Super stable kinetic sniper rifle
Dreaded_Venture(Arrowhead_Brake, Tactical_Mag, Triple_Tap, Rapid_Hit)

Austringer(Hammer_Forged_Rifling, 3142289711, any_of(1168162263, 3124871000), any_of(3425386926, Rangefinder))

Jack_Queen_King_3(any_of(Subsistence, Demolitionist), 2848615171)
```

Check files in `data/` for the list of names you can use. Weapon names are used
as kind of "functions", with any arguments added as perks. Perks can be listed
either by name (if there is one in `data/perks.m4`) or by numerical ID. If there
are multiple perks specified in a single argument (either using `any_of` macro or
by simply separating them with `|`), single line will generate all combinations
of listed perks.

After you created your wishlist, run `make`, which will generate corresponding
text file. Commit that text file and push it to GitHub. Then open your text file
on GitHub in your browser, press "Raw" button and copy URL into wishlist URL
field in DIM settings.

## Macro reference

### `wishlist_entry`

Syntax: `wishlist_entry(itemID, perks...)`

Generates entries for a given item with given perks, automatically computing
all combinations for perks listed with multiple options (in a single argument, 
separated by `|`).

While you can use this directly, it's advised to define a wrapper macro for each
item ID (like in `data/weapons.m4`):

```
define(`Sidearm', `wishlist_entry(14, $@)')

Sidearm(Demolitionist)
```

### `any_of`

Syntax: `any_of(perks...)`

Helper macro to make specifying perk options slightly more readable. Retuns all
arguments joined with `|` as a single string.

## Caveats

### Not all perks/items are present in generated files

The code currently skips any names that match more than one ID, because I haven't
figured yet a good way to disambiguate them. This is mostly happens with overly
generic names, like "Aggressive Frame", where actual perks are specific to
weapon types, despite identical display names.

### Macro names can't start with a digit

`m4` doesn't recognize macro invocations of macros with "invalid" names.
Definition of "invalid" includes, among other things, names that start with a
digit. To work this around you can use `indir` builtin:
`indir(`123foobar', args...)`
