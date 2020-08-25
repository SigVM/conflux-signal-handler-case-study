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
    abi: require('./contracts/Timelock-abi.json'),
    address: '0x848d59ea0f44d4825e98fb16fa18e371363295f4',
  });
  console.log(await contracttl.delay());
  console.log(await contracttl.admin());
  let target = contracttl.address;
  let value = 0;
  let signature = 'setDelay(uint256)';
  let data = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255];
  let eta=  1597881527;
  const receipttl = await contracttl.queueTransaction(
    target, value, signature, data, eta)
    .sendTransaction({ from: accounttl })
    .confirmed();
  console.log(receipttl);
  console.log(await contracttl.delay());
}

main().catch(e => console.error(e));

