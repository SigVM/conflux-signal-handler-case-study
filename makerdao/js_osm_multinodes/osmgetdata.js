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
    abi: require('./contract/OSM-abi.json'),
    address: '0x8c9d72e6efba0ee73f4fa38cb80ef88fd0271d0d',
  });

  await contractosm.getCurrentPrice();

}

main().catch(e => console.error(e));