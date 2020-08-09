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

  // create contract instance
  const contractds_val = cfx.Contract({
    abi: require('./contract/DSValue-abi.json'),
    // code is unnecessary
    address: '0x8df4fade46019b611baed0c03875055942255aee',
  });
  // deploy the contract, and get `contractCreated`
  const receiptosm = await contractds_val.poke([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,22,33])
    .sendTransaction({from: accountosm})
    .confirmed();
  console.log(receiptosm);  
    await contractds_val.peek();

}

main().catch(e => console.error(e));
