divert(-1)

include(`data/perks.m4')
include(`data/weapons.m4')
include(gen_root`/src/manual_perks.m4')
include(gen_root`/src/manual_weapons.m4')

define(`single_entry', ``dimwishlist:item='$1`'ifelse($#, 1, , $2, ,, ``&perks='shift($@)')')

dnl replace_arg(index, value, nargs, args...)
define(`replace_arg', `ifelse(
	$3, 0, `',
	$3, 1, `ifelse($1, 1, $2, $4)',
	`ifelse($1, 1, $2, $4)`, '$0(decr($1), $2, decr($3), shift(shift(shift(shift($@)))))')')

define(`unwrap', `$1')

define(`argn', `ifelse(`$1', 1, ``$2'', `argn(decr(`$1'), shift(shift($@)))')')

dnl _wishlist_entry(expanded_count, item, perks...)
define(`_wishlist_entry', `ifelse(
eval($# - 2 - $1 == 0), 1, `single_entry(shift($@))',
`pushdef(`__cur', argn(incr($1), shift(shift($@))))pushdef(`__index', index(__cur, `|'))dnl
ifelse(
		__index, -1, `$0(incr($1), shift($@))',
		`$0(incr($1), $2, unwrap(replace_arg(incr($1), substr(__cur, 0, __index), decr(decr($#)), shift(shift($@)))))
$0($1, $2, unwrap(replace_arg(incr($1), substr(__cur, incr(__index)), decr(decr($#)), shift(shift($@)))))')dnl
popdef(`__cur')popdef(`__index')dnl
')')

ifelse(`Roughly equivalent python code for the above macro:

def _wishlist_entry(expanded_count, item, *perks):
    if len(perks) == expanded_count:
        # All arguments have been expanded, just emit the entry.
        single_entry(item, *perks)
        return

    perk = perks[expanded_count]
    if "|" in perk:
        # We have some alternatives to go through. Split the string into first
        # one, and the rest.
        a, _, b = perk.partition("|")

        # Substitute first alternative in place of the currently processed argument
        # and continue with the rest of args.
        _wishlist_entry(expanded_count+1, item,
            *(perks[:expanded_count] + [a] + perks[expanded_count+1:]))

        # Do the same with the rest of alternatives. expanded_count is not
        # incremented because there might still be "|" in them.
        _wishlist_entry(expanded_count, item,
            *(perks[:expanded_count] + [b] + perks[expanded_count+1:]))
    else:
        # Next perk spec does not include alternatives, move on to the next one.
        _wishlist_entry(expanded_count+1, item, *perks)
')

define(`_join', `ifelse($3, 0, $1, $3, 1, $1`'$4, `_join($1`'$4`'$2`', `$2', decr(`$3'), shift(shift(shift(shift($@)))))')')
define(`any_of', `_join(`', `|', $#, $@)')

define(`wishlist_entry', `_wishlist_entry(0, $@)')

changecom(`//')

divert`'dnl
