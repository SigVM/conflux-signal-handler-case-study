/* eslint-disable */

const { Conflux} = require('js-conflux-sdk');
const JSBI = require('jsbi');
const format = require('js-conflux-sdk/src/util/format');
const PRIVATE_KEY_OSM = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12539',
    defaultGasPrice: 1,
    defaultGas: 1000000,
    logger: console,
  });

  console.log(cfx.defaultGasPrice); // 100
  console.log(cfx.defaultGas); // 1000000

  // // ================================ Account =================================
  const accounttl = cfx.Account(PRIVATE_KEY_OSM); // create account instance
  console.log(accounttl.address);

  // ================================ Contract ================================
  // create contract instance
  const contracttl = cfx.Contract({
    abi: require('./contracts/Sig_Timelock-abi.json'),
    address: '0x83ee6601d16ca60135b9c0ee66987d4723fdde3a',
  });
  console.log(await contracttl.delay());
  console.log(await contracttl.admin());
  let target = contracttl.address;
  let value = 0;
  let signature = 'setDelay(uint256)';
  let data = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255];
  let delay=  200;
  const receipttl = await contracttl.queueTransaction(
    target, value, signature, data, delay)
    .sendTransaction({ from: accounttl, gas: 1000000})
    .confirmed();
  console.log(receipttl);
  console.log(await cfx.getEpochNumber());
}

main().catch(e => console.error(e));

