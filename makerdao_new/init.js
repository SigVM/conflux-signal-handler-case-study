const { Conflux } = require('js-conflux-sdk');
const fs = require('fs');
const PRIVATE_KEYS = ['0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
,'0x268CA3C03E13787C07764127282139A4D4907BE8AEE8AD6D737B6D082968B175'
,'0x55E98E25E10FEB5B2B6CA346DCC1CF28AD12F84E2E997E4F496C10B295ACF1D2'
];
async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12539',
    defaultGasPrice: 1,
    defaultGas: 1000000,
    logger: console,
  });
  const accountosm = cfx.Account(PRIVATE_KEYS[0]);
  const accountvat = cfx.Account(PRIVATE_KEYS[1]);
  var i;
  var accounts = new Array(3);
  for (i = 0; i < accounts.length; i++) {
    accounts[i] = cfx.Account(PRIVATE_KEYS[i]);
  }
  var receipt;
  for (i = 1; i < accounts.length; i++) {
    receipt = await cfx.sendTransaction({ from: accounts[0], to: accounts[i], value: 48017578125012962550, gasPrice: 1}).confirmed();
    console.log(receipt);
  }

  const contractosm = cfx.Contract({
    abi: require('./contracts/out/OSM-abi.json'),
    bytecode: require('./contracts/out/OSM-bin.json'),
  });
  const contractmed = cfx.Contract({
    abi: require('./contracts/out/Median-abi.json'),
    bytecode: require('./contracts/out/Median-bin.json'),
  });
  const contractvat = cfx.Contract({
    abi: require('./contracts/out/Vat-abi.json'),
    bytecode: require('./contracts/out/Vat-bin.json'),
  });
  var value = 50;
  const receiptds = await contractmed.constructor(value)
    .sendTransaction({ from: accountosm })
    .confirmed();
  const receiptosm = await contractosm.constructor(receiptds.contractCreated, accountosm.address)
    .sendTransaction({from: accountosm, gas: 10000000 })
    .confirmed();
  const receiptvat = await contractvat.constructor(receiptosm.contractCreated)
    .sendTransaction({from: accountvat, gas: 10000000 })
    .confirmed();
    console.log(receiptds.contractCreated);
    console.log(receiptosm.contractCreated);
    console.log(receiptvat.contractCreated);
    console.log(accountosm.address);

console.log("Now do Function Call.........................................");
var contractmed_func = cfx.Contract({
    abi: require('./contracts/out/Median-abi.json'),
    address: "0x83e3405d1c40694cf63f51e949a0bb1b53b87821",
});
    var receipt_tmp =  await contractmed_func.feed(37)
    .sendTransaction({from: accountosm, gas: 10000000})
    .confirmed();
 receipt_tmp =  await contractmed_func.peek();
console.log(JSON.stringify(receipt_tmp, null, 2));
    var contractvat_func = cfx.Contract({
        abi: require('./contracts/out/Vat-abi.json'),
        address: "0x8c2fa1c9722c0199c30e0e41ee9db1b486f2985f",
    });
    receipt_tmp =  await contractvat_func.move();
    console.log(JSON.stringify(receipt_tmp, null, 2));
    var contractosm_func = cfx.Contract({
        abi: require('./contracts/out/OSM-abi.json'),
        address: "0x81da7076dafc248c31fef315435fbaf03a65a9d9",
    });
    receipt_tmp =  await contractosm_func.peekfromosm();
    console.log(JSON.stringify(receipt_tmp, null, 2));
}
main().catch(e => console.error(e));