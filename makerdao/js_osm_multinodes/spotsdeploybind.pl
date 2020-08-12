#!/usr/bin/perl
use strict;
use warnings;
use POSIX;

my $num_nodes = int($ARGV[0]);
my $osm_addr = $ARGV[1];
system("rm -rf deployreceipt.txt");
my @a = (1..${num_nodes});
for(@a){
	print("SPOT $_ is being deployed\n");
    system("node deployspotter.js");
}
open( my $default_fh, "<", "deployreceipt.txt" ) or die $!;
my $node = 1;
while ( my $line = <$default_fh> ) {
    $line =~ s/\R//g;
    open( my $main_fh,    ">", "spotter_${node}_bind.js" ) or die $!;
    my $message = <<"END_MESSAGE";
const { Conflux } = require('js-conflux-sdk');

const PRIVATE_KEY_OSM = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12540',
    defaultGasPrice: 1,
    defaultGas: 1000000,
    logger: console,
  });

  console.log(cfx.defaultGasPrice); // 100
  console.log(cfx.defaultGas); // 1000000

  // ================================ Account =================================
  const accountosm = cfx.Account(PRIVATE_KEY_OSM); // create account instance
  console.log(accountosm.address);

  // ================================ Contract ================================
  // create contract instance
  const contractspot = cfx.Contract({
    abi: require('./contract/Spotter-abi.json'),
    address: '${line}',
  });

  const contractosm = cfx.Contract({
    abi: require('./contract/OSM-abi.json'),
    address: '${osm_addr}',
  });

  // deploy the contract, and get `contractCreated`
  const receiptspot = await contractspot.poke_to_bind(contractosm.address)
    .sendTransaction({from: accountosm})
    .confirmed();
  console.log(receiptspot);
}

main().catch(e => console.error(e));
END_MESSAGE
    print {$main_fh} $message;
    close $main_fh;
    system("node spotter_${node}_bind.js");
    system("rm -rf spotter_${node}_bind.js");
    if($node == ceil($num_nodes/2)){
        print "reach here";
        open($main_fh,    ">", "spotter_${node}_getdata.js" ) or die $!;
        $message = <<"END_MESSAGE";
const { Conflux } = require('js-conflux-sdk');

const PRIVATE_KEY_OSM = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12540',
    defaultGasPrice: 1,
    defaultGas: 1000000,
    logger: console,
  });

  console.log(cfx.defaultGasPrice); // 100
  console.log(cfx.defaultGas); // 1000000

  // ================================ Account =================================
  const accountosm = cfx.Account(PRIVATE_KEY_OSM); // create account instance
  console.log(accountosm.address);

  // ================================ Contract ================================
  // create contract instance
  const contractspot = cfx.Contract({
    abi: require('./contract/Spotter-abi.json'),
    address: '${line}',
  });

  // deploy the contract, and get `contractCreated`
  await contractspot.getPrice();
}

main().catch(e => console.error(e));
END_MESSAGE
        print {$main_fh} $message;
        close $main_fh;
    }
    $node = $node + 1;
}

system("rm -rf deployreceipt.txt");
close $default_fh;

=for comment
running order:
node deploydsval.js
node deployosm.js //deploy with dsvalue contract address
node dsvalpoke.js
node start_emit.js
//Then better to turn off all info! print in rust
./spotsdeploybind.pl <num of nodes> <osm address>
//Then check slottx time in rust print
=cut
