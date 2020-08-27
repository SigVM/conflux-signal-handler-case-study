#!/usr/bin/perl
use strict;
use warnings;
use POSIX;

for(@ARGV){
  if($_ =~ /\.abi/){
  print("File $_ is parsed\n");
      my ($tmp) = $_ =~ /(.+)\.abi/;
      system("mv $_ $tmp\-abi.json");
  }elsif($_ =~ /\.bin/){
  print("File $_ is parsed\n");
    my ($tmp) = $_ =~ /(.+)\.bin/;
    open( my $main_fh, "<", "$_" ) or die $!;
    open( my $df_fh, ">", "$tmp\-bytecode.json" ) or die $!;
    while (my $row = <$main_fh>) {
        $row = "\"0x${row}\"";
        print {$df_fh} $row;
    }
    close $main_fh;
    close $df_fh;
    system("rm -rf $_");
  }
}

#perl parse_contract_output.pl $(find augur/js_wo_sig/contracts/ -type f -name '*')
