# Augur
[Augur](https://www.augur.net/whitepaper.pdf)  is a decentralized prediction market where users can bet on future real-world outcomes. Augur markets follow four stages: creation of the market, trading, reporting outcomes and prediction settlement. During reporting stage, one of the reporters report results of a real-world event by staking REP tokens on one of the outcomes of the market. If a Dispute Bond is reached on an alternative outcome, the Tentative Winning Outcome changes to the new alternative outcome. This process happens every 24 hours.

In the `Universe` contract, the `sweepInterest()` function has to be executed so that the contract can finalize the last round results and can start a new round if required. The reimplementation is rather straightforward, we declare a `signal DailySignal()` that is handled by a handler `Update()`. Within the handler, another instance of  `DailySignal()` is emitted with a delay of 24 hours during the handling of the previous instance. As a result, `Update()` is executed every 24 hours until the contract runs out of funds.

We included the original function to demonstrate their reliance on poking in `js_wo_sig/contract` as well as the accompanying JavaScript scripts to invoke the corresponding functions. The reimplemented smart contract is in `js_sig/contract`.

... write detailed instructions on how to run them
