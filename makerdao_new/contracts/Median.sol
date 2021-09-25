pragma solidity >=0.6.9;
contract Median {
    //the price
  uint256 public val; 
  //Peek to get current price of a digital asset
  function peek() public view returns (uint256,bool) {return (val, val > 0);}
  //Signal event for price updates
  signal PriceFeed(uint256, bool);
  //Feed to set current price of a digital asset
  function feed(uint256 val_) public {
    val = val_;
    bool confirm = val > 0;
    //Emit PriceFeed to OSM
   PriceFeed.emit(val, confirm).delay(0);
  } 
  constructor(uint256 val_) public {
      val = val_;
  }
}