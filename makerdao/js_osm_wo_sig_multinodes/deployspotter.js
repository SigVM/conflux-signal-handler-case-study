/* eslint-disable */

const { Conflux } = require('js-conflux-sdk');
const fs = require('fs');

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
    abi: require('./contract/Spotter_ORI-abi.json'),
    bytecode: require('./contract/Spotter_ORI-bytecode.json'),
  });

  // deploy the contract, and get `contractCreated`
  const receiptspot = await contractspot.constructor(0x1000000000100000000010000000001000000000)
    .sendTransaction({from: accountosm})
    .confirmed();
  console.log(receiptspot);

  fs.appendFileSync('deployreceipt.txt', receiptspot.contractCreated.toString()+"\r\n");
}

main().catch(e => console.error(e));

// ../../solidity/signalslot/parse.pl src/spot_sig.sol src/spot_sig_parsed.sol
// make build
// cp out/Spotter.abi ../conflux-singal-handler-case-study/makerdao/js_osm/contract/Spotter-abi.json
// cp out/Spotter.bin ../conflux-singal-handler-case-study/makerdao/js_osm/contract/Spotter-bytecode.json
// cp src/spot_sig_parsed.sol ../conflux-singal-handler-case-study/makerdao/js_osm/contract/spot_sig_parsed.sol
//0x877a692777b5f395490ea3f8bdc58125b1322be7
//0x8df43fc1e1c03a4068b62503dc1aaaac23c488a9
//0x852ca5312870833c7b110fe73b84c525e9d6c365