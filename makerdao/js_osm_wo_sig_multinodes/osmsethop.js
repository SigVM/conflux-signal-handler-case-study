/* eslint-disable */

const { Conflux } = require('js-conflux-sdk');

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

  // ================================ Account =================================
  const accountosm = cfx.Account(PRIVATE_KEY_OSM); // create account instance
  console.log(accountosm.address);

  // ================================ Contract ================================
  // create contract instance
  const contractosm = cfx.Contract({
    abi: require('./contract/OSM_ORI-abi.json'),
    address: '0x8e661963c993cb441c3668b2ca7a7f1ef6897401',
  });

  const receiptosm = await contractosm.step(1)
  .sendTransaction({from: accountosm,
                    gas: 10000000 })
  .confirmed();
  console.log(receiptosm);

}

main().catch(e => console.error(e));