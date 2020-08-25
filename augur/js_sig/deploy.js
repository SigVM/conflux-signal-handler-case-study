/* eslint-disable */

const { Conflux, util } = require('js-conflux-sdk');

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
  const accounttl = cfx.Account(PRIVATE_KEY_OSM); // create account instance
  console.log(accounttl.address);

  // ================================ Contract ================================
  // create contract instance
  const contracttl = cfx.Contract({
    abi: require('./contracts/Sig_Timelock-abi.json'),
    bytecode: require('./contracts/Sig_Timelock-bytecode.json'),
  });

  // deploy the contract, and get `contractCreated`
  const receipttl = await contracttl.constructor(accounttl.address, 100)
    .sendTransaction({ from: accounttl })
    .confirmed();
  console.log(receipttl);
}

main().catch(e => console.error(e));

