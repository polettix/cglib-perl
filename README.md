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

A lot of the code would not be here were it not for the excellent courses
on Algorithms by Robert Sedgewick and Kevin Wayne as found on Coursera.
Their [mini-site][algs4] about the book is invaluable.

Copyright (C) 2018 by Flavio Poletti.

This code is free software. You can redistribute it and/or modify it
under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

As an extension, I will not take offense if you just copy-paste the
parts you need when solving puzzles in [CodingGame][CG]. I would be
happy to receive updates if you find bugs or do useful additions, just
use [the GitHub repository][cglib-perl].

[CG]: https://www.codingame.com/
[algs4]: https://algs4.cs.princeton.edu/code/
[cglib-perl]: https://github.com/polettix/cglib-perl
