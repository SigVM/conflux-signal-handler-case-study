#!/usr/bin/perl
use strict;
use warnings;
use POSIX;
use Time::HiRes qw( time );

my $num_tx = int($ARGV[0]);
my @set = ('0' ..'9', 'A' .. 'F');
my @accounts;
for(my $i = 0; $i < $num_tx-1; $i++){
	$accounts[$i] = join '' => map $set[rand @set], 1 .. 64;
  my $tmp = $accounts[$i];
  $accounts[$i] = "0x$tmp";
  #print "$accounts[$i]\n";
}
system("rm -rf deployreceipt.txt");
system("rm -rf init.js");
open( my $tx_fh,    ">", "init.js" ) or die $!;
my $message = <<"END_MESSAGE";
const { Conflux } = require('js-conflux-sdk');
const fs = require('fs');
const PRIVATE_KEYS = ['0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
END_MESSAGE
print {$tx_fh} $message;
for(my $i = 0; $i < $num_tx-2; $i++){
  my $tmp = $accounts[$i];
	print {$tx_fh} "'$tmp',";
}
my $tmp = $accounts[$num_tx-2];
$message = <<"END_MESSAGE";
'$tmp'];
async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12539',
    defaultGasPrice: 1,
    defaultGas: 1000000,
    logger: console,
  });
  var accounts = new Array(PRIVATE_KEYS.length);
  for (i = 0; i < accounts.length; i++) {
    accounts[i] = cfx.Account(PRIVATE_KEYS[i]);
  }
  var val = (5801757812501296255)*$num_tx;
  for (i = 1; i < accounts.length; i++) {
    await cfx.sendTransaction({ from: accounts[0], to: accounts[i], value: 5801757812501296255, gasPrice: 1}).confirmed();
  }
  const accountosm = cfx.Account(PRIVATE_KEYS[0]);
  const contractosm = cfx.Contract({
    abi: require('./contract/OSM_ORI-abi.json'),
    bytecode: require('./contract/OSM_ORI-bytecode.json'),
  });
  const contractdaval = cfx.Contract({
    abi: require('./contract/DSValue-abi.json'),
    bytecode: require('./contract/DSValue-bytecode.json'),
  });
  const receiptds = await contractdaval.constructor()
    .sendTransaction({ from: accountosm })
    .confirmed();
  const receiptosm = await contractosm.constructor(receiptds.contractCreated)
    .sendTransaction({from: accountosm, gas: 10000000 })
    .confirmed();
  const contractdsval_func = cfx.Contract({
    abi: require('./contract/DSValue-abi.json'),
    address: receiptds.contractCreated,
  });
  var receipt_tmp = await contractdsval_func.poke([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,127,126,125])
    .sendTransaction({from: accountosm})
    .confirmed();

  const contractosm_func = cfx.Contract({
    abi: require('./contract/OSM_ORI-abi.json'),
    address: receiptosm.contractCreated,
  });
  receipt_tmp = await contractosm_func.step(50)
    .sendTransaction({from: accountosm, gas: 10000000 })
    .confirmed();
  receipt_tmp = await contractosm_func.poke()
    .sendTransaction({from: accountosm, gas: 10000000 })
    .confirmed();
  console.log("======================Deploy Spotter==============================");
  for (i = 0; i < accounts.length; i++) {
    console.log(accounts[i].address);
  }
  var contractspots = new Array(PRIVATE_KEYS.length);
  for (i = 0; i < contractspots.length; i++) {
    contractspots[i] = cfx.Contract({
      abi: require('./contract/Spotter_ORI-abi.json'),
      bytecode: require('./contract/Spotter_ORI-bytecode.json'),
    });
    receipt_tmp = await contractspots[i].constructor(0x1000000000100000000010000000001000000000)
      .sendTransaction({from: accounts[i]})
      .confirmed();
    fs.appendFileSync('deployreceipt.txt', receipt_tmp.contractCreated.toString()+"\\r\\n");
  }
  console.log(receipt_tmp);
  for (i = 0; i < accounts.length; i++) {
    console.log(accounts[i].address);
  }
}
main().catch(e => console.error(e));
END_MESSAGE
print {$tx_fh} $message;
close $tx_fh;
system("node init.js");

=for comment
running order:
node deploydsval.js
node deployosm.js //deploy with dsvalue contract address
node dsvalpoke.js
node osmsethop.js
node osmpokeandread.js
./spotsdeploypoke.pl <num of nodes> <osm address> //to get time comsumption
=cut


