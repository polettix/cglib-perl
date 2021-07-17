package ANSIColors;
use strict;
use Exporter qw< import >;
our @EXPORT_OK = qw< color >;

# Copied verbatim from Term::ANSIColor 5.01 (our -> my)
{
   my %ATTRIBUTES = (
      'clear'          => 0, 'reset'          => 0,
      'bold'           => 1, 'dark'           => 2, 'faint'          => 2,
      'italic'         => 3, 'underline'      => 4, 'underscore'     => 4,
      'blink'          => 5, 'reverse'        => 7, 'concealed'      => 8,

      'black'          => 30,   'on_black'          => 40,
      'red'            => 31,   'on_red'            => 41,
      'green'          => 32,   'on_green'          => 42,
      'yellow'         => 33,   'on_yellow'         => 43,
      'blue'           => 34,   'on_blue'           => 44,
      'magenta'        => 35,   'on_magenta'        => 45,
      'cyan'           => 36,   'on_cyan'           => 46,
      'white'          => 37,   'on_white'          => 47,

      'bright_black'   => 90,   'on_bright_black'   => 100,
      'bright_red'     => 91,   'on_bright_red'     => 101,
      'bright_green'   => 92,   'on_bright_green'   => 102,
      'bright_yellow'  => 93,   'on_bright_yellow'  => 103,
      'bright_blue'    => 94,   'on_bright_blue'    => 104,
      'bright_magenta' => 95,   'on_bright_magenta' => 105,
      'bright_cyan'    => 96,   'on_bright_cyan'    => 106,
      'bright_white'   => 97,   'on_bright_white'   => 107,
   );

   sub color {
      exists $ATTRIBUTES{$_} || die "unknown attribute '$_'" for @_;
      return "\e[" . join(';', map {$ATTRIBUTES{$_}} @_) . 'm';
   }
}
1;
