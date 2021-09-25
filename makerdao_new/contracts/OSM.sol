pragma solidity >=0.6.9;
contract OSM {
  struct Feed {
    uint256 val;
    bool has; }
  Feed cur;

address[] sigroles;
bytes32[] sigmethods;

  //Signal event for the delayed price update
 signal DelayedPrice(uint256, address);

  //Handler function to receive price from Median
 function price_update(uint256 wut, bool ok) handler {

    if (ok) {
        address i = address(this);
      DelayedPrice.emit(wut, i).delay(50);
      cur.val = wut;
      cur.has = ok;
    } 
  }
  function peekfromosm() public view returns (uint256,bool) {return (cur.val, cur.val > 0);}
  constructor(address median, address allower) public {
      sigroles= [allower];
      sigmethods = [keccak256("peekfromosm()")];
   //Handler SendUpdate binds to signal PriceFeed
  price_update.bind(median, Median.PriceFeed, 0.1, true, sigroles, sigmethods);
   //Other initialization statements
   } 
}