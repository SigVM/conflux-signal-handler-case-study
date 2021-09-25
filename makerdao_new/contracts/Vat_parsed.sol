pragma solidity >=0.6.9;
contract Vat {
uint256 data;
address osm;
address[] sigroles;
bytes32[] sigmethods;
// Original code: function price_update(uint256 data_, address osm_) handler {
bytes32 private price_update_key;
function set_price_update_key() private {
    price_update_key = keccak256("price_update(uint256,address)");
}
function price_update(uint256 data_, address osm_) public {
////////////////////
    data = data_;
    osm = osm_;
  }
  function move() external returns (uint256) {
      return data;
  }
  constructor(address osm0) public {
// Original code: price_update.bind(osm0,OSM.DelayedPrice,0.1,true,sigroles,sigmethods);
set_price_update_key();
bytes32 price_update_method_hash = keccak256("price_update(uint256,address)");
bytes32 price_update_signal_prototype_hash = keccak256("DelayedPrice(uint256,address)");
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
            osm0,
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