/* eslint-disable */

const { Conflux} = require('js-conflux-sdk');
const PRIVATE_KEY = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
const PRIVATE_KEY_MARKET = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcde0';
async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12539',
    defaultGasPrice: 1,
    defaultGas: 1000000,
    logger: console,
  });

  console.log(cfx.defaultGasPrice); // 100
  console.log(cfx.defaultGas); // 1000000

  // ================================ Account =================================
  const accountminer = cfx.Account(PRIVATE_KEY); // create account instance
  console.log(accountminer.address);
  // ================================ Account =================================
  const accountmarket = cfx.Account(PRIVATE_KEY_MARKET); // create account instance
  console.log(accountmarket.address);

  // ================================ Contract ================================
  // create contract instance
  const contract1 = cfx.Contract({
    abi: require('./contracts/TestNetDaiVat-abi.json'),
    bytecode: require('./contracts/TestNetDaiVat-bytecode.json'),
  });

  // deploy the contract, and get `contractCreated`
  const receipt1 = await contract1.constructor()
    .sendTransaction({ from: accountminer })
    .confirmed();
  console.log(receipt1);

  // ================================ Contract ================================
  // create contract instance
  const contract2 = cfx.Contract({
    abi: require('./contracts/Cash-abi.json'),
    bytecode: require('./contracts/Cash-bytecode.json'),
  });

  // deploy the contract, and get `contractCreated`
  const receipt2 = await contract2.constructor()
  .sendTransaction({ from: accountminer })
  .confirmed();
  console.log(receipt2);

  // ================================ Contract ================================
  // create contract instance
  const contract3 = cfx.Contract({
    abi: require('./contracts/TestNetDaiJoin-abi.json'),
    bytecode: require('./contracts/TestNetDaiJoin-bytecode.json'),
  });

  // deploy the contract, and get `contractCreated`
  const receipt3 = await contract3.constructor(receipt1.contractCreated, receipt2.contractCreated)
  .sendTransaction({ from: accountminer })
  .confirmed();
  console.log(receipt3);

  // ================================ Contract ================================
  // create contract instance
  const contract4 = cfx.Contract({
    abi: require('./contracts/TestNetDaiPot-abi.json'),
    bytecode: require('./contracts/TestNetDaiPot-bytecode.json'),
  });

  // deploy the contract, and get `contractCreated`
  const receipt4 = await contract4.constructor(receipt1.contractCreated)
  .sendTransaction({ from: accountminer })
  .confirmed();
  console.log(receipt4);

  // ================================ Contract ================================
  // create contract instance
  const contract5 = cfx.Contract({
    abi: require('./contracts/Augur-abi.json'),
    bytecode: require('./contracts/Augur-bytecode.json'),
  });

  // deploy the contract, and get `contractCreated`
  const receipt5 = await contract5.constructor()
  .sendTransaction({ from: accountminer})
  .confirmed();
  console.log(receipt5);

  const contractAugur = cfx.Contract({
    abi: require('./contracts/Augur-abi.json'),
    address: receipt5.contractCreated,
  });
  var myBuffer = [];
  var str = 'DaiVat';
  var buffer = new Buffer(str, 'utf16le');
  for (var i = 0; i < 32; i++) {
    if (i*2<buffer.length){
      myBuffer.push(buffer[i*2]);
    }else{
      myBuffer.push(0);
    }
  }
  console.log(myBuffer);
  await contractAugur.registerContract(myBuffer, receipt1.contractCreated)
  .sendTransaction({ from: accountminer})
  .confirmed();

  str = 'Cash';
  buffer = new Buffer(str, 'utf16le');
  myBuffer = [];
  for (var i = 0; i < 32; i++) {
    if (i*2<buffer.length){
      myBuffer.push(buffer[i*2]);
    }else{
      myBuffer.push(0);
    }
  }
  console.log(myBuffer);
  await contractAugur.registerContract(myBuffer, receipt2.contractCreated)
  .sendTransaction({ from: accountminer})
  .confirmed();
  str = 'DaiJoin';
  buffer = new Buffer(str, 'utf16le');
  myBuffer = [];
  for (var i = 0; i < 32; i++) {
    if (i*2<buffer.length){
      myBuffer.push(buffer[i*2]);
    }else{
      myBuffer.push(0);
    }
  }
  console.log(myBuffer);
  await contractAugur.registerContract(myBuffer, receipt3.contractCreated)
  .sendTransaction({ from: accountminer})
  .confirmed();
  str = 'DaiPot';
  buffer = new Buffer(str, 'utf16le');
  myBuffer = [];
  for (var i = 0; i < 32; i++) {
    if (i*2<buffer.length){
      myBuffer.push(buffer[i*2]);
    }else{
      myBuffer.push(0);
    }
  }
  console.log(myBuffer);
  await contractAugur.registerContract(myBuffer, receipt4.contractCreated)
  .sendTransaction({ from: accountminer})
  .confirmed();

  // ================================ Contract ================================
  // create contract instance
  const contract6 = cfx.Contract({
    abi: require('./contracts/SimpleUniverse-abi.json'),
    bytecode: require('./contracts/SimpleUniverse-bytecode.json'),
  });
  // deploy the contract, and get `contractCreated`
  const receipt6 = await contract6.constructor(receipt5.contractCreated)
  .sendTransaction({ from: accountminer})
  .confirmed();
  
  // In Augur:
  // set miner into trustedsender
  await contractAugur.setTrustedSender(accountminer.address)
  .sendTransaction({ from: accountminer})
  .confirmed();
  console.log("-----------------MINER IS TrustedSender---------------------");
  await contractAugur.isTrustedSender(accountminer.address);

  // In Pot:
  // set miner's pie
  const contractPot = cfx.Contract({
    abi: require('./contracts/TestNetDaiPot-abi.json'),
    address: receipt4.contractCreated,
  });
  await contractPot.setpie(receipt6.contractCreated, 0xDEADBEEF)
  .sendTransaction({ from: accountminer})
  .confirmed();
  console.log("-----------------MINER PIE IS---------------------");
  await contractPot.getpie(receipt6.contractCreated);

  // In Cash:
  // init with augur
  // approve miner with some allowance
  // faucet miner with some balance
  const contractCash = cfx.Contract({
    abi: require('./contracts/Cash-abi.json'),
    address: receipt2.contractCreated,
  });
  await contractCash.initialize(contractAugur.address)
  .sendTransaction({ from: accountminer})
  .confirmed();

  await contractCash.approve(accountminer.address, 0x0000FEEB)
  .sendTransaction({ from: accountminer})
  .confirmed();
  console.log("-----------------MINER ALLOWANCE IS---------------------");
  await contractCash.allowance(accountminer.address, accountminer.address);
  await contractCash.faucet(0x0000BEEF)
  .sendTransaction({ from: accountminer})
  .confirmed();
  console.log("-----------------MINER BALANCE IS---------------------");
  await contractCash.balanceOf(accountminer.address);

  console.log("Vat CONTRACT ADDRESS IS");
  console.log(receipt1.contractCreated);
  console.log("Cash CONTRACT ADDRESS IS");
  console.log(receipt2.contractCreated);
  console.log("Join CONTRACT ADDRESS IS");
  console.log(receipt3.contractCreated);
  console.log("Pot CONTRACT ADDRESS IS");
  console.log(receipt4.contractCreated);
  console.log("Augur CONTRACT ADDRESS IS");
  console.log(receipt5.contractCreated);
  console.log("Universe CONTRACT ADDRESS IS");
  console.log(receipt6.contractCreated);
}

main().catch(e => console.error(e));
/*
rm -rf *
cp ~/Documents/augur/packages/augur-core/source/contracts/out/TestNetDai* .
cp ~/Documents/augur/packages/augur-core/source/contracts/out/SimpleUniverse.* .
cp ~/Documents/augur/packages/augur-core/source/contracts/out/Augur* .
cp ~/Documents/augur/packages/augur-core/source/contracts/out/Cash* .
perl ../../../parse_contract_output.pl $(find . -type f -name "*")

cp ~/Documents/augur/packages/augur-core/source/contracts/out/TestNetDai* .
cp ~/Documents/augur/packages/augur-core/source/contracts/out/SimpleUniverse.* .
cp ~/Documents/augur/packages/augur-core/source/contracts/out/Augur_sol* .
cp ~/Documents/augur/packages/augur-core/source/contracts/out/Cash_sol* .
perl ../../../parse_contract_output.pl $(find . -type f -name "*")


deploy TestNetDaiVat
deploy Cash
deploy TestNetDaiJoin using TestNetDaiVat, Cash
deploy TestNetDaiPot using TestNetDaiVat
deploy Augur
register cash, daivat, daipot, daijoin into augur
deploy universe using augur

In Augur:
  set miner into trustedsender

In Pot:
  set miner's pie

In Cash:
  init with augur
  approve miner with some allowance
  faucet miner with some balance

In universe:
  deposit from miner to current universe

  sweepInterest()

In Cash:
  check miner balance
*/

