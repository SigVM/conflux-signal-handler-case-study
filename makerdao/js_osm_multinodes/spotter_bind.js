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
  const contractspot = cfx.Contract({
    abi: require('./contract/Spotter-abi.json'),
    address: '0x8f32e4276c96cba1adb30645a7d9b6e38397e770',
  });

  const contractosm = cfx.Contract({
    abi: require('./contract/OSM-abi.json'),
    address: '0x8c9d72e6efba0ee73f4fa38cb80ef88fd0271d0d',
  });

  // deploy the contract, and get `contractCreated`
  const receiptspot = await contractspot.poke_to_bind(contractosm.address)
    .sendTransaction({from: accountosm})
    .confirmed();
  console.log(receiptspot);
}

main().catch(e => console.error(e));

// ../../solidity/signalslot/parse.pl src/osm_sig.sol src/osm_sig_parsed.sol
// make build
// cp out/Spotter.abi ../conflux-singal-handler-case-study/makerdao/js_osm/contract/Spotter-abi.json
// cp out/Spotter.bin ../conflux-singal-handler-case-study/makerdao/js_osm/contract/Spotter-bytecode.json
// cp src/spot_sig_parsed.sol ../conflux-singal-handler-case-study/makerdao/js_osm/contract/spot_sig_parsed.sol
