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
  const contractspot = cfx.Contract({
    abi: require('./contract/Spotter-abi.json'),
    address: '0x8bfd47551ad3faa4b1311af87dcb6e5b486fdb45',
  });

  // deploy the contract, and get `contractCreated`
  await contractspot.getPrice();
}

main().catch(e => console.error(e));
