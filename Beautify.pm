package Text::Beautify;

use 5.008;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	beautify enable_feature disable_feature features enabled_features
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	beautify enable_feature disable_feature features enabled_features
);

our $VERSION = '0.01';

=head1 NAME

Text::Beautify - Beautifies text

=head1 SYNOPSIS

  use Text::Beautify;

  $text = "badly written text ,,you know ?"

  $new_text = beautify($text);
  # $new_text now holds "Badly written text, you know?"

  enable_feature('repeated_punctuation'); # enables the feature
  disable_feature('trailing_space');      # disables the feature

  @features_enables = enabled_features();

  @all_features = features();

=cut

my (%features,@features);
my  %status;

BEGIN {
  %features = (
    heading_space                 => [ qr/^ +/                 , ''        ],
    trailing_space                => [ qr/ +$/                 , ''        ],
    space_in_front_of_punctuation => [ qr/ +(?=[[:punct:]])/   , ''        ],
    double_spaces                 => [ qr/  +/                 , ' '       ],
    repeated_punctuation          => [ qr/([[:punct:]])(?=\1)/ , ''        ],

    _space_after_punctuation      => [ qr/[[:punct:]](?=[^ ])/  , '$&." "' ],
    _uppercase_first              => [ qr/^[[:^alnum:]]*[a-z]/  , 'uc($&)' ],
  );

  @features = qw(
    heading_space
    trailing_space
    double_spaces
    repeated_punctuation
    space_in_front_of_punctuation
    _space_after_punctuation
    _uppercase_first
  );

  %status = map { ( $_ , 1 ) } @features; # all features enabled by default
}

sub beautify {
  my @results;
  for (wantarray ? @_ : $_[0]) {

    for my $feature (@features) {
      next unless $status{$feature};

      if ($feature =~ /^_/) { # advanced feature
        s/$features{$feature}[0]/eval $features{$feature}[1]/ge;
      }
      else {                  # regular feature
        s/$features{$feature}[0]/$features{$feature}[1]/g;
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

=item * _space_after_punctuation

	Puts a spaces after punctuation

=item * _uppercase_first

	Uppercases the first character in the string

=back

=head1 MESSAGE FROM THE AUTHOR

If you're using this module, please drop me a line to my e-mail. Tell
me what you're doing with it. Also, feel free to suggest new
bugs^H^H^H^H^H features O:-)

=head1 AUTHOR

Jose Alves de Castro, E<lt>cog [at] cpan [dot] org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Jose Alves de Castro

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
