# SigVM Case Studies
SigVM project is a study on enabling event-driven in smart contract programming. It includes a proof of concept implementation (named SigChain) based on the Conflux client (branched off from the OpenEthereum client implemented in Rust) and a custom Solidity compiler named SigSolid. We refer the interested readers to [SigChain](https://github.com/SigVM/sigvm-conflux) and [SigSolid](https://github.com/SigVM/SigSolid) respectively.

This repository currently contains three case studies demonstrating how a event-driven paradigm can benefit decentralized application programming. First, MakerDAO is a stablecoin derivative application that can mint Dai tokens by collateralizing
crypto assets. Dai is designed to have a stable value
of one USD. Second, Compound is a decentralized lending service
platform where users could deposit one type of digital asset
as collateral to borrow another type of digital asset from
its shared pool. Third, Augur is a decentralized prediction market
where users bet on future result of real-world events. In total,
these applications manage more than $3B of digital assets
on the Ethereum network, making up an essential part of
the Ethereum economic ecosystem. On a side note that the Augur contract was token from the project repository in May 2020. There was later a restructure of the project hence the function referred is no longer in the Augur repository.

By surveying these existing projects, we realized a lot of them rely on off-chain "poking" transaction (i.e., periodic prompting transaction from relay servers to call a function on a smart contract). However, this solution creates a central point
of failure. On the other hand, this means, despite the lack of effort in native blockchain support, autonomous function calls when a certain constraint (e.g., time elapsed, satisfaction of a condition, etc.) is met is indeed desired.

For each case study, we includes the contracts that rely on off-chain poking from the original projects. Then we reimplemented them with the SigVM design with the goal of eliminating
off-chain relay servers. The benchmark contracts and the corresponding changes are summarized in the following table. We find that the new code is typically simpler than the original
contract code while the reimplementation effort is moderate.

| App        | Contract        | #Lines in Solidity     | #Lines in SigSolid  | #Lines Changed  |
| ---------- |:-------------:|:-------------:| :-----:| :-----:|
| MakerDAO   | Median        | 175 | 177 | 2 |
| MakerDAO   | OSM        | 178 | 174 | 6 |
| MakerDAO   | Spotter        | 116 | 116 | 5 |
| Compound   | Timelock        | 113 |   115 | 12 |
| Augur      | Universe        | 711  |  727 | 15 |

To validate the implementation, we deploy those benchmark contracts
together with the remaining components of the applications
in our SigChain platform. We manually validate that
all three benchmark applications function correctly with the
new contract code.

To run the benchmark contracts, please first clone [SigChain](https://github.com/SigVM/sigvm-conflux) and [SigSolid](https://github.com/SigVM/SigSolid).
