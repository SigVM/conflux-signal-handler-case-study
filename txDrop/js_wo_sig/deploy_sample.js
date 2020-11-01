const { Conflux } = require('js-conflux-sdk');
const PRIVATE_KEY_OSM = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
async function main() {
  const cfx = new Conflux({
    url: 'http://localhost:12539',
    defaultGasPrice: 1,
    defaultGas: 1000000,
    logger: console,
  });
  const accountosm = cfx.Account(PRIVATE_KEY_OSM);
  const contractosm = cfx.Contract({
    abi: require('./contract/OSM_ORI-abi.json'),
    bytecode: require('./contract/OSM_ORI-bytecode.json'),
  });
  const contractdaval = cfx.Contract({
    abi: require('./contract/DSValue-abi.json'),
    bytecode: require('./contract/DSValue-bytecode.json'),
  });
  const receiptds = await contractdaval.constructor()
    .sendTransaction({ from: accountosm })
    .confirmed();
  const receiptosm = await contractosm.constructor(receiptds.contractCreated)
    .sendTransaction({from: accountosm, gas: 10000000 })
    .confirmed();
  console.log(receiptosm);
}

main().catch(e => console.error(e));

// ../../solidity/signalslot/parse.pl src/osm_sig.sol src/osm_sig_parsed.sol
// make build
// cp out/OSM.abi ../conflux-singal-handler-case-study/makerdao/js_osm/contract/OSM-abi.json
// cp out/OSM.bin ../conflux-singal-handler-case-study/makerdao/js_osm/contract/OSM-bytecode.json
// cp src/osm_sig_parsed.sol ../conflux-singal-handler-case-study/makerdao/js_osm/contract/osm_sig_parsed.sol