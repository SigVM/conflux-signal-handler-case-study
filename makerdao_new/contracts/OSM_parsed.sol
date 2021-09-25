pragma solidity >=0.6.9;
contract OSM {
  struct Feed {
    uint256 val;
    bool has; }
  Feed cur;

address[] sigroles;
bytes32[] sigmethods;

// Original code: signal DelayedPrice(uint256,address);
bytes32 private DelayedPrice_key;
function set_DelayedPrice_key() private {
    DelayedPrice_key = keccak256("DelayedPrice(uint256,address)");
}
////////////////////

// Original code: function price_update(uint256 wut, bool ok) handler {
bytes32 private price_update_key;
function set_price_update_key() private {
    price_update_key = keccak256("price_update(uint256,bool)");
}
function price_update(uint256 wut, bool ok) public {
////////////////////

    if (ok) {
        address i = address(this);
// Original code: DelayedPrice.emit(wut,i).delay(50);
bytes memory abi_encoded_DelayedPrice_data = abi.encode(wut,i);
// This length is measured in bytes and is always a multiple of 32.
uint abi_encoded_DelayedPrice_length = abi_encoded_DelayedPrice_data.length;
assembly {
    mstore(
        0x00,
        sigemit(
            sload(DelayedPrice_key.slot), 
            abi_encoded_DelayedPrice_data,
            abi_encoded_DelayedPrice_length,
            50
        )
    )
}
////////////////////
      cur.val = wut;
      cur.has = ok;
    } 
  }
  function peekfromosm() public view returns (uint256,bool) {return (cur.val, cur.val > 0);}
  constructor(address median, address allower) public {
// Auto create signal
set_DelayedPrice_key();
assembly {
    mstore(0x00, createsignal(sload(DelayedPrice_key.slot)))
}
////////////////////
      sigroles= [allower];
      sigmethods = [keccak256("peekfromosm()")];
// Original code: price_update.bind(median,Median.PriceFeed,0.1,true,sigroles,sigmethods);
set_price_update_key();
bytes32 price_update_method_hash = keccak256("price_update(uint256,bool)");
bytes32 price_update_signal_prototype_hash = keccak256("PriceFeed(uint256,bool)");
bytes memory abi_encoded_price_update_sigRoles = abi.encode(sigroles);
uint abi_encoded_price_update_sigRoles_length = abi_encoded_price_update_sigRoles.length - 64;
bytes memory abi_encoded_price_update_sigMethods = abi.encode(sigmethods);
uint abi_encoded_price_update_sigMethods_length = abi_encoded_price_update_sigMethods.length - 64;

assembly {
    mstore(
        0x00,
        sigbind(
            sload(price_update_key.slot),
            price_update_method_hash, 
            10000000, 
            110,
            median,
            price_update_signal_prototype_hash,
            1,
            abi_encoded_price_update_sigRoles,
            abi_encoded_price_update_sigRoles_length,
            abi_encoded_price_update_sigMethods,
            abi_encoded_price_update_sigMethods_length
        )
    )
}
////////////////////
   } 
}