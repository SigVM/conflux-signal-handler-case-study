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
    abi: require('./contracts/SimpleUniverse-abi.json'),
    address: '0x808f7d3ca25bb652b8aa0b1d340b5d7ffa0f7388',
  });
  const contractCash = cfx.Contract({
    abi: require('./contracts/Cash-abi.json'),
    address: '0x8f1aed66825ab789569a4ef36cb552564c39645b',
  });
  const contractAugur = cfx.Contract({
    abi: require('./contracts/Augur-abi.json'),
    address: '0x81f7c609e7279c70b1fa5b50b6c60509de2efb53',
  });
  
  await contractAugur.trustedTransfer(contractCash.address, accountminer.address, contractUni.address, 333)
  .sendTransaction({ from: accountminer})
  .confirmed();

  // await contractUni.deposit(accountminer.address, 333, accountmarket.address)
  // .sendTransaction({ from: accountminer})
  // .confirmed();
  await contractUni.cash();
  // await contractUni.sweepInterest()
  // .sendTransaction({ from: accountminer})
  // .confirmed();

  console.log("-----------------MINER BALANCE AFTER DEPOSIT IS---------------------");
  // await contractCash.transferFrom(accountminer.address,contractUni.address, 333)
  // .sendTransaction({ from: accountminer})
  // .confirmed();
  await contractCash.allowance(accountminer.address,accountminer.address);
  await contractCash.balanceOf(accountminer.address);
  await contractCash.balanceOf(contractUni.address);

  // await contract7.sweepInterest()
  // .sendTransaction({ from: accountminer})
  // .confirmed();
}

main().catch(e => console.error(e));

