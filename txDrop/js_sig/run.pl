#!/usr/bin/perl
use strict;
use warnings;
use POSIX;
use Time::HiRes qw( time );

my $num_normal_tx = int($ARGV[0]);
my $num_tx = int($ARGV[1]);
my $osm_init = int($ARGV[2]);
my $num_gasprice_random_size = int($ARGV[3]);
my $gasprice_maximum = int($ARGV[4]);
my $gasprice_normal_mean = int($ARGV[5]);
my $gasprice_normal_sd = int($ARGV[6]);
my $tx_rate = int($ARGV[7]);
my @set = ('0' ..'9', 'A' .. 'F');
my @accounts;
for(my $i = 0; $i < $num_normal_tx+$num_tx-1; $i++){
	$accounts[$i] = join '' => map $set[rand @set], 1 .. 64;
  my $tmp = $accounts[$i];
  $accounts[$i] = "0x$tmp";
  #print "$accounts[$i]\n";
}
if($osm_init){
  system("./clearaccounts.sh");
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
my $osm_addr_in_init = 0x0;
if ($osm_init==0){
  open( my $osm_addr_fh, "<", "osmaddr.txt" ) or die $!;
  while ( my $line = <$osm_addr_fh> ) {
    $line =~ s/\R//g;
    $osm_addr_in_init = $line;
  }
  close $osm_addr_fh;
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
  var i;
  var accounts = new Array($num_tx);
  for (i = 0; i < accounts.length; i++) {
    accounts[i] = cfx.Account(PRIVATE_KEYS[i]);
  }
  for (i = 1; i < accounts.length; i++) {
    await cfx.sendTransaction({ from: accounts[0], to: accounts[i], value: 48017578125012962550, gasPrice: 1}).confirmed();
    fs.appendFileSync('spotteraccount.txt', PRIVATE_KEYS[i].toString()+"\\r\\n");
  }
  var normal_accounts = new Array($num_normal_tx);
  for (i = accounts.length; i < accounts.length + normal_accounts.length; i++) {
    normal_accounts[i-accounts.length] = cfx.Account(PRIVATE_KEYS[i]);
    await cfx.sendTransaction({ from: accounts[0], to: normal_accounts[i-accounts.length], value: 48017578125012962550, gasPrice: 1}).confirmed();
    fs.appendFileSync('normalaccount.txt', PRIVATE_KEYS[i].toString()+"\\r\\n");
  }
  var contractosm_func;
  var receipt_tmp;
  if($osm_init){
  const accountosm = cfx.Account(PRIVATE_KEYS[0]);
  const contractosm = cfx.Contract({
    abi: require('./contract/OSM-abi.json'),
    bytecode: require('./contract/OSM-bytecode.json'),
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
  receipt_tmp = await contractdsval_func.poke([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,127,126,125])
    .sendTransaction({from: accountosm})
    .confirmed();

  contractosm_func = cfx.Contract({
    abi: require('./contract/OSM-abi.json'),
    address: receiptosm.contractCreated,
  });
  receipt_tmp =  await contractosm_func.startPriceUpdate()
      .sendTransaction({from: accountosm,gas: 10000000})
      .confirmed();
  }else{
  contractosm_func = cfx.Contract({
    abi: require('./contract/OSM-abi.json'),
    address: '$osm_addr_in_init',
  });    
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
      abi: require('./contract/Spotter-abi.json'),
      bytecode: require('./contract/Spotter-bytecode.json'),
    });
    receipt_spots[i] = await contractspots[i].constructor()
      .sendTransaction({from: accounts[i]})
      .confirmed();
    fs.appendFileSync('spotteraddr.txt', receipt_spots[i].contractCreated.toString()+"\\r\\n");
  }
  var contractspots_func = new Array($num_tx);
  for (i = 1; i < contractspots_func.length; i++) {
    console.log("=====================Spotter Binding==============================");
    console.log(i);
    contractspots_func[i] = cfx.Contract({
    abi: require('./contract/Spotter-abi.json'),
    address: receipt_spots[i].contractCreated,
    });
    receipt_tmp = await contractspots_func[i].poke_to_bind(contractosm_func.address).sendTransaction({from: accounts[i], gasPrice: 1}).confirmed();
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
const JSBI = require('jsbi');
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
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12539',
    defaultGasPrice: 1,
    defaultGas: 1000000,
    logger: undefined,
  });
  var j;
  var i;
  var k;
  var accounts = new Array($num_poking_in_tx);
  for (i = 0; i < accounts.length; i++) {
    accounts[i] = cfx.Account(PRIVATE_KEYS[i]);
  }
  var normal_accounts = new Array($num_normal_in_tx);
  for (i = accounts.length; i < accounts.length + normal_accounts.length; i++) {
    normal_accounts[i-accounts.length] = cfx.Account(PRIVATE_KEYS[i]);
  }
  var contractspots_func = new Array($num_poking_in_tx);

  // create a list of n numbers between 1 and max
  var list = [];
  for (i = 0; i < $num_gasprice_random_size; i++) {
    list[i] = Math.random() * ($gasprice_maximum - 1) + 1;
  }
  // compute mean, sd and the interval range: [min, max]
  var mean;
  var sd;
  var len = list.length;
  var sum;
  var a = Infinity;
  var b = -a;
  for (sum = i = 0; i < len; i++) {
    sum += list[i];
    a = Math.min(a, list[i]);
    b = Math.max(b, list[i]);
  }
  mean = sum / len;
  for (sum = i = 0; i < len; i++) {
    sum += (list[i] - mean) * (list[i] - mean);
  }
  sd = Math.sqrt(sum / (len - 1));
  // transform the list to have an exact mean of 5 and sd of 2
  var oldMean = mean;
  var oldSD = sd;
  var newList = [];
  var len = list.length;
  for (i = 0; i < len; i++) {
    newList[i] = $gasprice_normal_sd * (list[i] - oldMean) / oldSD + $gasprice_normal_mean;
  }

  var normal_accounts_gasprice = [];
  var normal_accounts_nonce = [];
  for (i = 1; i < contractspots_func.length; i++) {
    console.log("=====================Spotter INT contract==============================");
    console.log(i);
    contractspots_func[i] = cfx.Contract({
    abi: require('./contract/Spotter-abi.json'),
    address: SPOT_ADDR[i],
    });
  }
  for (i = 0; i < normal_accounts.length; i++) {
    console.log("=====================Normal Transfer Init Nonce==============================");
    console.log(i);
    normal_accounts_nonce[i] = await cfx.getNextNonce(normal_accounts[i].address);
  }
  var accounts_nonce = [];
  for (i = 0; i < accounts.length; i++) {
    console.log("=====================Contract Tx Init Nonce==============================");
    console.log(i);
    accounts_nonce[i] = await cfx.getNextNonce(accounts[i].address);
  }
  console.log("Iter ", Math.round(${tx_rate}/(normal_accounts.length + contractspots_func.length)));
  
  var index = 1;
  var num_nor_tx = 0;
  var num_int_tx = 0;
  while(true){
    num_nor_tx = 0;
    num_int_tx = 0; 
    await sleep(1000);
    for(j=0;j<Math.round(${tx_rate}/(normal_accounts.length + contractspots_func.length));j++){
      for (i = 0; i < normal_accounts.length; i++) {
        normal_accounts_gasprice[i] = Math.round(newList[Math.floor(Math.random() * newList.length)]);       
        await cfx.sendTransaction({from: normal_accounts[i], to: accounts[0], value: 1, nonce: normal_accounts_nonce[i], gasPrice: normal_accounts_gasprice[i]});
        normal_accounts_nonce[i] = JSBI.add(normal_accounts_nonce[i],JSBI.BigInt(1));    
        num_nor_tx++;  
      }
      for(k = 0; k < index*100; k++){
        for(i = 1; i < contractspots_func.length; i++){
          receipt_tmp = await contractspots_func[i].getPrice().sendTransaction({from: accounts[i], nonce: accounts_nonce[i], gasPrice: Math.round(newList[Math.floor(Math.random() * newList.length)])});
          accounts_nonce[i] = JSBI.add(accounts_nonce[i],JSBI.BigInt(1));
          num_int_tx++;
        }
      }
    }
    console.log(index);
    console.log("=====================Normal Account Last Nonce==============================");
    for (i = 0; i < normal_accounts.length; i++) {
      console.log(normal_accounts_nonce[i]);
    }
    console.log("=====================Poking Account Last Nonce==============================");
    for (i = 0; i < accounts.length; i++) {
      console.log(accounts_nonce[i]);
    }
    console.log("NORMAL_TX", num_nor_tx, "INT_TX", num_int_tx);
    index++;
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


