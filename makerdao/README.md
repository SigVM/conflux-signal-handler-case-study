# MakerDAO
[MakerDAO](https://makerdao.com/en/whitepaper/) is a decentralized platform that provides collateral-backed stablecoin called Dai. It follows the Maker Protocol to keep Dai softly pegged to USD by a fixed ratio. This is accomplished by backing Dai with crypto assets based on the market prices. In order to generate Dai, users send collateral to the Collateralized Debt Position smart contract to create a vault. To meet the long-term solvency of the system, the ratio between the deposit to the vault and the Dai the vault owner obtains must be greater than a ratio decided by a MakerDAO governance committee at all time. Once the ratio drops below the set ratio, the Maker Protocol forces the collateral to be liquidated.

Evidently, a reliable price feed is critical to the MakerDAO system. Otherwise, it won't be able to determine the value of deposits locked in a vault, hence posing the solvency of the system in danger. The oracle module in MakerDAO (containing three smart contracts) aims to provide a stable price feed to the system.

| Contract        | Description    | maintenance party  |
| ---------- |:------------|:-------------:| :-----:| :-----:|
| Median        | `feed()`: report a new price of the interested asset, the median of which is considered the oracle spot price; <br /> `peek()`: read the latest oracle price |  Authorized maintainers |
| OSM        | `poke()`: prompt the contract to read from a Median/DSValue contract, and make the previous value valid. Can only be called an hour after the previous call <br /> `peek()`: read the latest value and whether it is valid | Anyone |
| Spotter        | `poke()`: update price for an asset type, read from an OSM contract | Anyone |

We included the minimal-functional version of the three contracts to demonstrate their reliance on poking in `js_osm_wo_sig/contract` and `js_osm_wo_sig_multinodes/contract`.

<object data="MakerDAO_woSig.pdf" type="application/pdf" width="700px" height="700px">
    <embed src="MakerDAO_woSig.pdf">
        <p>This browser does not support PDFs. Please see: <a href="MakerDAO_woSig.pdf">Download PDF</a>.</p>
    </embed>
</object>

... write detailed instructions on how to run them, double check if the description above are accurate and modify the contract names in the code
