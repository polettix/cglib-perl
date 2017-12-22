# CGLib - Coding Game Library

This is a small library of functions/objects that have already proven
useful for me in solving some of the problems in [CodingGame][CG].

The code is not particularly robust nor readable. Actually, the design
follows the following guidelines:

- aim for easy cut-and-paste, as I often just include functions in the
  solutions (which boil down to a single file anyway)
- privilege compactness where possible
- do only minimal parameters checking, assume that the usage will be
  "correct". This is a valid assumption while solving problems in [CG][]
  where you retain full control
- avoid `Carp`/`croak` even if useful. This is again in the spirit of
  easier cut-and-paste, even though `croak` is actually the best option
  inside a library instead of `die`
- use `Exporter` - its presence does not get in the way of easy
  copy-pasting anyway

[CG]: https://www.codingame.com/
