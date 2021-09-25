pragma solidity >=0.6.9;
contract Median {
  uint256 public val; 
  function peek() public view returns (uint256,bool) {return (val, val > 0);}
// Original code: signal PriceFeed(uint256,bool);
bytes32 private PriceFeed_key;
function set_PriceFeed_key() private {
    PriceFeed_key = keccak256("PriceFeed(uint256,bool)");
}
////////////////////
  function feed(uint256 val_) public {
    val = val_;
    bool confirm = val > 0;
// Original code: PriceFeed.emit(val,confirm).delay(0);
bytes memory abi_encoded_PriceFeed_data = abi.encode(val,confirm);
// This length is measured in bytes and is always a multiple of 32.
uint abi_encoded_PriceFeed_length = abi_encoded_PriceFeed_data.length;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(PriceFeed_key.slot), 
            abi_encoded_PriceFeed_data,
            abi_encoded_PriceFeed_length,
            0
        )
    )
}
////////////////////
  } 
  constructor(uint256 val_) public {
// Auto create signal
set_PriceFeed_key();
assembly {
    mstore(0x00, createsignal(sload(PriceFeed_key.slot)))
}
////////////////////
      val = val_;
  }
}