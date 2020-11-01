#!/usr/bin/perl
use strict;
use warnings;
use POSIX;
use Time::HiRes qw( time );

my $num_normal_tx = int($ARGV[0]);
my $num_tx = int($ARGV[1]);
my $osm_init = int($ARGV[2]);
my @set = ('0' ..'9', 'A' .. 'F');
my @accounts;
for(my $i = 0; $i < $num_normal_tx+$num_tx-1; $i++){
	$accounts[$i] = join '' => map $set[rand @set], 1 .. 64;
  my $tmp = $accounts[$i];
  $accounts[$i] = "0x$tmp";
  #print "$accounts[$i]\n";
}
system("rm -rf init.js");
open( my $tx_fh,    ">", "init.js" ) or die $!;
my $message = <<"END_MESSAGE";
const { Conflux } = require('js-conflux-sdk');
const fs = require('fs');
const PRIVATE_KEYS = ['0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
END_MESSAGE
print {$tx_fh} $message;
for(my $i = 0; $i < $num_normal_tx+$num_tx-1; $i++){
  my $tmp = $accounts[$i];
	print {$tx_fh} ",'$tmp'\n";
}
$message = <<"END_MESSAGE";
];
async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12539',
    defaultGasPrice: 1,
    defaultGas: 1000000,
    logger: console,
  });
  var accounts = new Array($num_tx);
  for (i = 0; i < accounts.length; i++) {
    accounts[i] = cfx.Account(PRIVATE_KEYS[i]);
  }
  var val = (48017578125012962550)*$num_tx;
  for (i = 1; i < accounts.length; i++) {
    await cfx.sendTransaction({ from: accounts[0], to: accounts[i], value: 48017578125012962550, gasPrice: 1}).confirmed();
    fs.appendFileSync('spotteraccount.txt', PRIVATE_KEYS[i].toString()+"\\r\\n");
  }
  var normal_accounts = new Array($num_normal_tx);
  for (i = accounts.length; i < accounts.length + normal_accounts.length; i++) {
    normal_accounts[i-accounts.length] = cfx.Account(PRIVATE_KEYS[i]);
    await cfx.sendTransaction({ from: accounts[0], to: normal_accounts[i-accounts.length], value: 300000000, gasPrice: 1}).confirmed();
    fs.appendFileSync('normalaccount.txt', PRIVATE_KEYS[i].toString()+"\\r\\n");
  }

  if($osm_init){
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
  fs.appendFileSync('osmaddr.txt', receiptosm.contractCreated.toString()+"\\r\\n");
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
  receipt_tmp = await contractosm_func.step(1)
    .sendTransaction({from: accountosm, gas: 10000000 })
    .confirmed();
  receipt_tmp = await contractosm_func.poke()
    .sendTransaction({from: accountosm, gas: 10000000 })
    .confirmed();
  }
  console.log("======================Deploy Spotter==============================");
  for (i = 0; i < accounts.length; i++) {
    console.log(accounts[i].address);
  }
  var contractspots = new Array($num_tx);
  var receipt_spots = new Array($num_tx);
  for (i = 1; i < contractspots.length; i++) {
    console.log("=====================Spotter Deploy==============================");
    console.log(i);
    contractspots[i] = cfx.Contract({
      abi: require('./contract/Spotter_ORI-abi.json'),
      bytecode: require('./contract/Spotter_ORI-bytecode.json'),
    });
    receipt_spots[i] = await contractspots[i].constructor(0x1000000000100000000010000000001000000000)
      .sendTransaction({from: accounts[i]})
      .confirmed();
      fs.appendFileSync('spotteraddr.txt', receipt_spots[i].contractCreated.toString()+"\\r\\n");
  }
  //Below is example to poke and normal transfer
  //var contractspots_func = new Array($num_tx);
  //for (i = 1; i < contractspots_func.length; i++) {
  //  console.log("=====================Spotter Poking==============================");
  //  console.log(i);
  //  contractspots_func[i] = cfx.Contract({
  //  abi: require('./contract/Spotter_ORI-abi.json'),
  //  address: receipt_spots[i].contractCreated,
  //  });
  //  receipt_tmp = await contractspots_func[i].simple_poke(contractosm_func.address).sendTransaction({from: accounts[i], gasPrice: 1});
  //}
  //for (i = 0; i < normal_accounts.length; i++) {
  //  console.log("=====================Normal Transfer==============================");
  //  console.log(i);
  //  await cfx.sendTransaction({from: normal_accounts[i], to: accounts[0], value: 1, gasPrice: 1});
  //}
  console.log("=====================Normal Account==============================");
  for (i = 0; i < normal_accounts.length; i++) {
    console.log(normal_accounts[i].address);
  }
  console.log("=====================Poking Account==============================");
  for (i = 0; i < accounts.length; i++) {
    console.log(accounts[i].address);
  }
}
main().catch(e => console.error(e));
END_MESSAGE
print {$tx_fh} $message;
close $tx_fh;
my @commands = ("node init.js");
my @pids;
foreach my $cmd( @commands ) {
    my $pid = fork;
    if ( $pid ) {
        # parent process
        push @pids, $pid;
        next;
    }
    # now we're in the child
    system( $cmd );
    exit; # terminate the child
}
wait for @pids;
open( $tx_fh,    ">", "tx.js" ) or die $!;
$message = <<"END_MESSAGE";
const { Conflux } = require('js-conflux-sdk');
const fs = require('fs');
const PRIVATE_KEYS = ['0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
END_MESSAGE
print {$tx_fh} $message;
open( my $default_fh, "<", "spotteraccount.txt" ) or die $!;
my $num_poking_in_tx = 1;
while ( my $line = <$default_fh> ) {
  $line =~ s/\R//g;
  print {$tx_fh} ",'$line'\n";
  $num_poking_in_tx = $num_poking_in_tx + 1;
}
close $default_fh;
my $num_normal_in_tx = 0;
open( $default_fh, "<", "normalaccount.txt" ) or die $!;
while ( my $line = <$default_fh> ) {
  $line =~ s/\R//g;
  print {$tx_fh} ",'$line'\n";
  $num_normal_in_tx = $num_normal_in_tx + 1;
}
print {$tx_fh} "];\n";
close $default_fh;

$message = <<"END_MESSAGE";
const SPOT_ADDR = ['0x1cad0b19bb29d4674531d6f115237e16afce377c'
END_MESSAGE
print {$tx_fh} $message;
open( $default_fh, "<", "spotteraddr.txt" ) or die $!;
while ( my $line = <$default_fh> ) {
  $line =~ s/\R//g;
  print {$tx_fh} ",'$line'\n";
}
print {$tx_fh} "];\n";
close $default_fh;
open( $default_fh, "<", "osmaddr.txt" ) or die $!;
my $osm_addr;
while ( my $line = <$default_fh> ) {
  $line =~ s/\R//g;
  $osm_addr = $line;
}
close $default_fh;
$message = <<"END_MESSAGE";
const OSM_ADDR = '${osm_addr}';
async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12539',
    defaultGasPrice: 1,
    defaultGas: 1000000,
    logger: console,
  });
  var accounts = new Array($num_poking_in_tx);
  for (i = 0; i < accounts.length; i++) {
    accounts[i] = cfx.Account(PRIVATE_KEYS[i]);
  }
  var normal_accounts = new Array($num_normal_in_tx);
  for (i = accounts.length; i < accounts.length + normal_accounts.length; i++) {
    normal_accounts[i-accounts.length] = cfx.Account(PRIVATE_KEYS[i]);
  }
  var contractspots_func = new Array($num_poking_in_tx);
  for (i = 1; i < contractspots_func.length; i++) {
    console.log("=====================Spotter Poking==============================");
    console.log(i);
    contractspots_func[i] = cfx.Contract({
    abi: require('./contract/Spotter_ORI-abi.json'),
    address: SPOT_ADDR[i],
    });
    receipt_tmp = await contractspots_func[i].simple_poke(OSM_ADDR).sendTransaction({from: accounts[i], gasPrice: 1});
  }
  for (i = 0; i < normal_accounts.length; i++) {
    console.log("=====================Normal Transfer==============================");
    console.log(i);
    await cfx.sendTransaction({from: normal_accounts[i], to: accounts[0], value: 1, gasPrice: 1});
  }
  console.log("=====================Normal Account==============================");
  for (i = 0; i < normal_accounts.length; i++) {
    console.log(normal_accounts[i].address);
  }
  console.log("=====================Poking Account==============================");
  for (i = 0; i < accounts.length; i++) {
    console.log(accounts[i].address);
  }
}
main().catch(e => console.error(e));
END_MESSAGE
print {$tx_fh} $message;
close $tx_fh;
=for comment
running order:
node deploydsval.js
node deployosm.js //deploy with dsvalue contract address
node dsvalpoke.js
node osmsethop.js
node osmpokeandread.js
=cut


