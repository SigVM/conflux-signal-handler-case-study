# Compound
[Compound](https://compound.finance/documents/Compound.Whitepaper.pdf) is a decentralized market to lend or borrow assets. Users communicate with the Compound contracts to supply, withdraw, borrow and repay assets. In the protocol, the key parameters of the market, such as interest rate, risk model and underlying price, are managed by a decentralized government body. Any proposals of updating the parameters must be voted for approval and queued in `Timelock` contract. To give market participants time to react for any parameter changes, the queued proposals will be executed in the required delay specified in the proposals.


| Function        | Description    | maintenance party|
| ---------- |:------------|:------------:|
| `queueTransaction()`      | hash the provided transaction param + a time in the future (`eta`), and store it in `queuedTransactions` |  Admin |
| `executeTransaction()`        | execute the transaction if it is in the correct time period (within 14 days after `eta`) | Admin |

`executeTransaction()` is supposed to be called by the admin within the designated time period. Otherwise, the queued transaction will be invalid and dropped.

We included the original function to demonstrate their reliance on poking in `js_wo_sig/contract` as well as the accompanying JavaScript scripts to invoke the corresponding functions. The reimplemented smart contract is in `js_sig/contract`.

... write detailed instructions on how to run them
