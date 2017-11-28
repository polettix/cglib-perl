package TSTrie;

sub contains { return defined $_[0]->get($_[1]) }
sub get { return (($_[0]->get_node($_[1]) // {})->{value}) }
sub get_node;    # see below
sub new { return bless {n => 0, root => undef}, $_[0] }

sub get_node { return __get_node($_[0]->{root}, __valid($_[1]), 0) }

sub __get_node {
   my ($root, $key, $d) = @_;

}

sub __valid { defined($_[0]) && length($_[0]) ? $_[0] : die 'invalid' }

1;
