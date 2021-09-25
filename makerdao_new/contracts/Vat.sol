pragma solidity >=0.6.9;
contract Vat {
uint256 data;
address osm;
address[] sigroles;
bytes32[] sigmethods;
  //Handler function to receive price from OSM
 function price_update(uint256 data_, address osm_) handler {
    data = data_;
    osm = osm_;
  }
  // move function used for Dai join or exit.
  function move() external returns (uint256) {
      return data;
  }
  constructor(address osm0) public {
    // Bind handlers to the signal PriceFeed from OSMs.
   price_update.bind(osm0,OSM.DelayedPrice,0.1, true, sigroles, sigmethods);

  }
  }