package Text::Beautify;

use 5.008;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	beautify enable_feature disable_feature features enabled_features
	enable_all disable_all
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

our $VERSION = '0.05';

=head1 NAME

Text::Beautify - Beautifies text

=head1 SYNOPSIS

  use Text::Beautify;

  $text = "badly written text ,,you know ?"

  $new_text = beautify($text);
  # $new_text now holds "Badly written text, you know?"

  # or

  $text = Text::Beautify->new("badly written text ,,you know ?");
  $new_text = $text->beautify;

  # and also

  enable_feature('repeated_punctuation'); # enables the feature
  disable_feature('trailing_space');      # disables the feature

  @features_enables = enabled_features();

  @all_features = features();

  enable_all();
  disable_all();

=cut

my $debug = 0;
my (%features,@features,%status);

BEGIN {
  my $empt = '\'\'';
  %features = (
    heading_space                 => [[qr/^ +/                    , $empt    ]],
    trailing_space                => [[qr/ +$/                    , $empt    ]],
    space_in_front_of_punctuation => [[qr/ +(?=[;:,!?])/          , $empt    ]],
    double_spaces                 => [[qr/  +/                    , '\' \''  ]],
    repeated_punctuation          => [[qr/([;:,!?])(?=\1)/        , $empt    ],
                                      [qr/\.{3,}/                 , '\'...\''],
                                      [qr/(?<!\.)\.\.(?!\.)/      , '\'.\''  ]],

    space_after_punctuation       =>[[qr/([;:,!?])(?=[[:alnum:]])/, '"$1 "'  ]],
    uppercase_first               => [[qr/([.!?]+\s*[a-z])/i      , 'uc($1)' ],
                                      [qr/^(\s*[[:alnum:]])/      , 'uc($1)' ],
                                      [qr/(?<=[!?] )([a-z])/      , 'uc($1)' ],
                                      [qr/(?<=[^.]\. )([a-z])/    , 'uc($1)' ]],
  );

  @features = qw(
    heading_space
    trailing_space
    double_spaces
    repeated_punctuation
    space_in_front_of_punctuation
    space_after_punctuation
    uppercase_first
  );

  %status = map { ( $_ , 1 ) } @features; # all features enabled by default
}

#

sub beautify {

  my @text;
  if (ref($_[0]) eq 'Text::Beautify') {
    my $self = shift;
    @text = @$self;
  }
  else {
    @text = wantarray ? @_ : $_[0];
  }

  my @results;
  for (@text) {

    for my $feature (@features) {
      next unless $status{$feature};
      my ($str,$end) = ('','');
      ($str,$end) = ("<$feature>","</$feature>") if $debug;

      for my $f (@{$features{$feature}}) {
	s/$$f[0]/$str . (eval $$f[1]) . $end/ge;
      }
    }

    push @results, $_;
  }
  return wantarray ? @results : $results[0];

}

sub auto_feature {
  my $newstatus = shift;
  for (@_) { defined $features{$_} || return undef; }
  for (@_) { $status{$_} = $newstatus; }
  1
}

sub enabled_features { grep $status{$_}, keys %features; }
sub features         { keys %features; }

sub enable_feature   { auto_feature(1,@_); }
sub disable_feature  { auto_feature(0,@_); }

sub enable_all       { auto_feature(1,features()) }
sub disable_all      { auto_feature(0,features()) }

# OO interface

sub new {
  my ($self,@text) = @_;
  bless \@text, 'Text::Beautify';
}

# debug

sub debug {
  $debug = shift || return undef;
}

1;
__END__

=head1 DESCRIPTION

Beautifies text. This involves operations like squeezing double spaces,
removing spaces from the beginning and end of lines, upper casing the
first character in a string, etc.

You can enable / disable features with I<enable_feature> /
I<disable_feature>. These commands return a true value if they
are successful.

To know which features are beautified, see FEATURES

=head1 FEATURES

All features are enabled by default

=over 4

=item * heading_space

	Removes heading spaces

=item * trailing_space

	Removes trailing spaces

=item * double_spaces

	Squeezes double spaces

=item * repeated_punctuation

	Squeezes repeated punctuation

=item * space_in_front_of_punctuation

	Removes spaces in front of punctuation

=item * space_after_punctuation

	Puts a spaces after punctuation

=item * uppercase_first

	Uppercases the first character in the string

=back

=head1 BUGS

Each line is treated independently. This means a sentence comprising two lines
will get it's second line's first character uppercased... must solve that ASAP.

Smiles such as "this :-(" are turned into "this:-("

=head1 AUTHOR

Jose Alves de Castro, E<lt>cog [at] cpan [dot] org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Jose Alves de Castro

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
