/* eslint-disable */

const { Conflux } = require('js-conflux-sdk');
const fs = require('fs');

const PRIVATE_KEY_OSM = '0x2381984F1F65B55489ECB4D3B521E485CA364F29CAA4D03DFE123CE8D4AE13D0';
const PRIVATE_KEY_TMP = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12539',
    defaultGasPrice: 1,
    defaultGas: 1000000,
    logger: console,
  });
  const accountosm = cfx.Account(PRIVATE_KEY_OSM);
  const accounttmp = cfx.Account(PRIVATE_KEY_TMP);
  console.log(accountosm.address);
  const contractspot = cfx.Contract({
    abi: require('./contract/Spotter_ORI-abi.json'),
    bytecode: require('./contract/Spotter_ORI-bytecode.json'),
  });
  await cfx.sendTransaction({ from: accounttmp, to: accountosm, value: 4801757812501296255, gasPrice: 1}).confirmed();
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