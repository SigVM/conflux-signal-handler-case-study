/* eslint-disable */

const { Conflux} = require('js-conflux-sdk');

const PRIVATE_KEY = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
const PRIVATE_KEY_MARKET = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcde0';

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
  const accountmarket = cfx.Account(PRIVATE_KEY_MARKET); // create account instance
  console.log(accountmarket.address);
  // ================================ Account =================================
  const accountminer = cfx.Account(PRIVATE_KEY); // create account instance
  console.log(accountminer.address);

  // In universe:
  // deposit from miner to current universe
  const contractUni = cfx.Contract({
    abi: require('./contracts/SigSimpleUniverse-abi.json'),
    address: '0x8dff1cdde6d78bd12296d2bef0bdf6fd2dff003a',
  });
  const contractCash = cfx.Contract({
    abi: require('./contracts/Cash-abi.json'),
    address: '0x87348bafb19f35b653c35e88674a9beff2974ec4',
  });
  // await contractUni.start_emit()
  // .sendTransaction({ from: accountminer})
  // .confirmed();
  await contractUni.deposit(accountminer.address, 0x00EF, accountmarket.address)
  .sendTransaction({ from: accountminer})
  .confirmed();

  console.log("-----------------MINER BALANCE AFTER DEPOSIT IS---------------------");

  await contractCash.allowance(accountminer.address,accountminer.address);
  await contractCash.balanceOf(accountminer.address);
  await contractCash.balanceOf(contractUni.address);
}

main().catch(e => console.error(e));

