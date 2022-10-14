# EXAMPLE: perl concordance.pl regex radius
#          perlbrew exec perl concordance.pl mujeres 5

use strict;
use warnings;
use utf8;


open(FILE, "salida-del-parser-json.txt") or die ("Fi1e not found!!!");

$/ = ""; # Paragraph mode for first while loop

my $target = "($ARGV[0])";
my $radius = $ARGV[1];
my $width = 2*$radius;
my $ordinal = $ARGV[2];
my $match = "";
my $pos = 0;
my $start = 0; 
my $count = 0;
my $extract = "";
my $deficit = 0;
my @lines=();

while ($_ = <FILE>) {
    chomp;
    s/\n/ /g;           # Replace newlines by spaces
    s/\b--\b/ -- /g;    # Add spaces around dashes adjacent to words
    s/\P{Ascii}|\r//g;  # quita caracteres raros

    while ($_ =~ /$target/gi) {
        $match = $1;
        $pos = pos($_);
        $start = $pos - $radius - length($match);        

        # Extracts are padded with spaces if needed
        if ($start < 0) {
            $extract = substr($_,0,$width+$start+length($match));
            $extract = (" " x -$start) . $extract;
        }
        else {
            $extract = substr($_,$start,$width+length($match));
            $deficit = $width+length($match)-length($extract);
            if ( $deficit > 0) {
                $extract .= (" " x $deficit);
            }
        }
        
        $lines[$count] = $extract;
        ++$count;
    }
}

close(FILE);    # This fix <FILE> chunk error 

# Code to print out the concordance lines found

# my $line_number = 0;
# foreach $x (@lines) {
#     ++$line_number;
#     printf "%5d", $line_number;
#     print " $x\n";
# }

# @lines = sort byMatch @lines;
# foreach my $line_number (1 .. $#lines) {
#     my $x = $lines[$line_number];
#     printf "%5d", $line_number;
#     print " $x\n";
# }

# A function to sort concordance lines by the strings that match the regex
# sub byMatch {
#     my $middle_a = substr($a, $radius, length($a) - 2*$radius);
#     my $middle_b = substr($b, $radius, length($b) - 2*$radius);
#     $middle_a = removePunctuation($middle_a);
#     $middle_b = removePunctuation($middle_b);
#     $middle_a cmp $middle_b;
# }

# Code Sample 6.10 Commands to print out the sorted concordance lines.
my $line_number = 0;
my $x=0;
foreach $x (sort byLeftWords @lines) {
    ++$line_number;
    printf "%5d", $line_number;
    print " $x\n";
}

$line_number = 0;
$x=0;
foreach $x (sort byRightWords @lines) {
    ++$line_number;
    printf "%5d", $line_number;
    print " $x\n";
}

# A function to remove punctuation
sub removePunctuation {
    # USAGE: $unpunctuated = removePunctuation($string);
    my $string = $_[0];
    $string = lc($string);      # Convert to lowercase
    $string =~ s/[^-a-z ]//g;   # Remove non-alphabetic characters
    $string =~ s/--+/ /g;       # Replace 2+ hyphens with a space
    $string =~ s/-//g;          # Remove hyphens
    $string =~ s/\s+/ /g;       # Replace whitespaces with a space
    return($string);
}

# Code Sample 6.7 A function that returns a word to the left of the regex match in a concordance line.
sub onLeft {
    # USAGE: $word = onLeft($string,$radius,$ordinal);
    my $left = substr($_[0],0,$_[1]);
    $left = removePunctuation($left);
    my @word = split(/\s+/,$left);
    return($word[-$_[2]]); 
}

# Code Sample 6.8 An ordering for sort. It uses the function onLeft defined in code sample 6.7.
sub byLeftWords {
    my $ordinal=@_; # This fix Use of uninitialized value $_[2] in negation (-) 
    my $left_a = onLeft($a,$radius,$ordinal);
    my $left_b = onLeft($b,$radius,$ordinal);
    lc($left_a) cmp lc($left_b);
}

# Code Sample 6.9 Subroutines to sort concordance lines by a word to the right of the match.
sub onRight {
    # USAGE: $word = onRight($string, $radius, $ordinal);
    my $right = substr($_[0],-$_[1]);
    $right = removePunctuation($right);
    $right =~ s/^\s+//;             # Remove initial space
    my @word = split(/\s+/,$right);
    return($word[$_[2]-1]); 
}

sub byRightWords {
    my $ordinal=@_; #Use of uninitialized value $_[2] in subtraction (-)
    my $right_a = onRight($a,$radius,$ordinal);
    my $right_b = onRight($b,$radius,$ordinal);
    lc($right_a) cmp lc($right_b);
}