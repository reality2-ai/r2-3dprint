# Taller-wall, slide-through bar concept

`slide-through.scad` is the historical plain-bar concept requested for review.
It has been superseded by the locking-bar implementation in
`../src/battery_holder.scad`, whose bars rest on the cells and have far-end
squeeze-release catches. Use the current STLs and main README for printing.

Two rigid orange bars pass sideways through slots above the cells. The taller
blue outer walls support them; local towers on the internal dividers support
the two- and three-cell bars between cells. The flat base stays on the board.
Continuous copper-tape contact walls remain at the ends.

The illustrative tray is 66.8 mm long and 22.8 mm high. Its width is 19.9, 39 or
58.1 mm for one, two or three cells. Pull heads add 2 mm on one side and bar tips
0.5 mm on the other. The bars are 6 mm wide and 2 mm thick, with 0.2 mm nominal
clearance on each slot face. Cells are shown using the existing 65 mm fit envelope
(reported 64 mm plus 1 mm empirical allowance), not a new measurement.

`view="assembled"` shows the closed holder. `view="withdrawn"` shows the bars
fully removed sideways and the cells lifted above the walls; the board and base
do not move. `cells=1`, `2` or `3` selects capacity. `view="empty"` exposes the
slots. The withdrawn view illustrates the significant side access needed.

This concept still needs an anti-withdrawal catch or another locking detail,
confirmation of side access and height in the actual box, printability review
and physical strength/fit checks. If side access is insufficient, a short-slide,
then-lift-out mechanism is the alternative under discussion. No new printable
STLs are supplied from this concept.
