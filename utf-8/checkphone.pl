#!/usr/bin/perl
use strict;
use encoding 'utf8', STDIN => 'utf8' , STDOUT => 'utf8';

=head1 NAME

checkphone.pl - A tool to check the consistency between libchewing's tsi.src and phone.cin

=head1 USAGE

# at the directory of tsi.src and phone.cin

./checkphone.pl

=head1 AUTHOR

Kuang-che Wu

=cut

my(%tsisrc,%phone,%phonechar);
my(%keyname);

open F,"tsi.src" or die $!;
while(<F>) {
    chomp;
    s/\s*#.*//;
    if(my($phrase,$freq,$data)=m/^(\S+)\s+(\d+)(?:\s+(.+?))?\s*$/) {
	my $len=length$phrase;
	$tsisrc{"$phrase,$data"}=() if $len == 1;
    }
}
close F;

open F,"phone.cin" or die $!;

my $lineno = 0;
$lineno++ until <F> =~ /^\%keyname\s+begin/;
$lineno++;
while(<F>) {
    $lineno++;
    last if /^\%keyname\s+end/;
    chomp;
    my($key,$name)= split /\s+/;
    $keyname{$key}=$name; 
}

$lineno++ until <F> =~ /^\%chardef\s+begin/;
$lineno++;
while(<F>) {
    $lineno++;
    last if /^\%chardef\s+end/;
    my($key,$char)=split /\s+/;
    $key =~ s/./$keyname{$&} or die "unknown key '$&'"/ge;
    $phonechar{"$char,$key"}=$lineno;
    $phone{$key}++;
}

close F;

for(sort { $phonechar{$a} <=> $phonechar{$b} } keys %phonechar) {
    my($zhi,$yin)=split /,/;
    next if $phone{$yin}>1;
    next if exists $tsisrc{"$zhi,$yin"};
    print "$phonechar{$_}: $_\n";
}
