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
    bytecode: require('./contract/OSM-bytecode.json'),
  });
  // create contract instance
  const contractds_val = cfx.Contract({
    abi: require('./contract/DSValue-abi.json'),
    // code is unnecessary
    address: '0x8df4fade46019b611baed0c03875055942255aee',
  });
  // deploy the contract, and get `contractCreated`
  const receiptosm = await contractosm.constructor(contractds_val.address)
    .sendTransaction({from: accountosm,
                      gas: 10000000 })
    .confirmed();
  console.log(receiptosm);
}

main().catch(e => console.error(e));

// ../../solidity/signalslot/parse.pl src/osm_sig.sol src/osm_sig_parsed.sol
// make build
// cp out/OSM.abi ../conflux-singal-handler-case-study/makerdao/js_osm/contract/OSM-abi.json
// cp out/OSM.bin ../conflux-singal-handler-case-study/makerdao/js_osm/contract/OSM-bytecode.json
// cp src/osm_sig_parsed.sol ../conflux-singal-handler-case-study/makerdao/js_osm/contract/osm_sig_parsed.sol