
pragma solidity >=0.6.9;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor ()  {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at


    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/


/**
 * @title IMedian
 * @author Set Protocol
 *
 * Interface for operating with a price feed Medianizer contract
 */
interface IMedian {

    /**
     * Returns the current price set on the medianizer. Throws if the price is set to 0 (initialization)
     *
     * @return  Current price of asset represented in hex as bytes32
     */
    function read()
        external
        view
        returns (bytes32);

    /**
     * Returns the current price set on the medianizer and whether the value has been initialized
     *
     * @return  Current price of asset represented in hex as bytes32, and whether value is non-zero
     */
    function peek()
        external
        view
        returns (bytes32, bool);
}


/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at


    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma experimental "ABIEncoderV2";



/**
 * @title LinkedListLibrary
 * @author Set Protocol
 *
 * Library for creating and altering uni-directional circularly linked lists, optimized for sequential updating
 */
contract LinkedListLibrary {

    using SafeMath for uint256;

    /* ============ Structs ============ */

    struct LinkedList{
        uint256 dataSizeLimit;
        uint256 lastUpdatedIndex;
        uint256[] dataArray;
    }

    /*
     * Initialize LinkedList by setting limit on amount of nodes and inital value of node 0
     *
     * @param  _self                        LinkedList to operate on
     * @param  _dataSizeLimit               Max amount of nodes allowed in LinkedList
     * @param  _initialValue                Initial value of node 0 in LinkedList
     */
    function initialize(
        LinkedList storage _self,
        uint256 _dataSizeLimit,
        uint256 _initialValue
    )
        internal
    {
        require(
            _self.dataArray.length == 0,
            "LinkedListLibrary: Initialized LinkedList must be empty"
        );

        _self.dataSizeLimit = _dataSizeLimit;
        _self.dataArray.push(_initialValue);
        _self.lastUpdatedIndex = 0;
    }

    /*
     * Add new value to list by either creating new node if node limit not reached or updating
     * existing node value
     *
     * @param  _self                        LinkedList to operate on
     * @param  _addedValue                  Value to add to list
     */
    function editList(
        LinkedList storage _self,
        uint256 _addedValue
    )
        internal
    {
        _self.dataArray.length < _self.dataSizeLimit ? addNode(_self, _addedValue)
            : updateNode(_self, _addedValue);

    }

    /*
     * Add new value to list by either creating new node. Node limit must not be reached.
     *
     * @param  _self                        LinkedList to operate on
     * @param  _addedValue                  Value to add to list
     */
    function addNode(
        LinkedList storage _self,
        uint256 _addedValue
    )
        internal
    {
        uint256 newNodeIndex = _self.lastUpdatedIndex.add(1);

        require(
            newNodeIndex == _self.dataArray.length,
            "LinkedListLibrary: Node must be added at next expected index in list"
        );

        require(
            newNodeIndex < _self.dataSizeLimit,
            "LinkedListLibrary: Attempting to add node that exceeds data size limit"
        );

        _self.dataArray.push(_addedValue);

        _self.lastUpdatedIndex = newNodeIndex;
    }

    /*
     * Add new value to list by updating existing node. Updates only happen if node limit has been
     * reached.
     *
     * @param  _self                        LinkedList to operate on
     * @param  _addedValue                  Value to add to list
     */
    function updateNode(
        LinkedList storage _self,
        uint256 _addedValue
    )
        internal
    {
        uint256 updateNodeIndex = _self.lastUpdatedIndex.add(1) % _self.dataSizeLimit;

        require(
            updateNodeIndex < _self.dataArray.length,
            "LinkedListLibrary: Attempting to update non-existent node"
        );

        _self.dataArray[updateNodeIndex] = _addedValue;
        _self.lastUpdatedIndex = updateNodeIndex;
    }

    /*
     * Read list from the lastUpdatedIndex back the passed amount of data points.
     *
     * @param  _self                        LinkedList to operate on
     * @param  _dataPoints                  Number of data points to return
     */
    function readList(
        LinkedList storage _self,
        uint256 _dataPoints
    )
        internal
        view
        returns (uint256[] memory)
    {
        require(
            _dataPoints <= _self.dataArray.length,
            "LinkedListLibrary: Querying more data than available"
        );

        uint256[] memory outputArray = new uint256[](_dataPoints);

        uint256 linkedListIndex = _self.lastUpdatedIndex;
        for (uint256 i = 0; i < _dataPoints; i++) {
            outputArray[i] = _self.dataArray[linkedListIndex];

            linkedListIndex = linkedListIndex == 0 ? _self.dataSizeLimit.sub(1) : linkedListIndex.sub(1);
        }

        return outputArray;
    }
}


/*
    Copyright 2019 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at


    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/





/**
 * @title HistoricalPriceFeed
 * @author Set Protocol
 *
 * Contract used to store Historical price data from an off-chain oracle
 */
contract HistoricalPriceFeed is
    Ownable,
    LinkedListLibrary
{
    using SafeMath for uint256;

    /* ============ Constants ============ */
    uint256 constant DAYS_IN_DATASET = 200;

    /* ============ State Variables ============ */
    uint256 public updateFrequency;
    uint256 public lastUpdatedAt;
    string public dataDescription;
    IMedian public medianizerInstance;

    LinkedList public historicalPriceData;
// Original code: signal empty_sig();
bytes32 private empty_sig_key;
function set_empty_sig_key() private {
    empty_sig_key = keccak256("empty_sig()");
}
////////////////////
    address[2] arg_roles;
    bytes32[3] arg_methods;
    /* ============ External ============ */

    /*
     * Updates linked list with newest data point by querying medianizer. Is eligible to be
     * called every 24 hours.
     */
// Original code: function poke() handler {
bytes32 private poke_key;
function set_poke_key() private {
    poke_key = keccak256("poke()");
}
function poke() public {
////////////////////
        uint256 local_updateFrequency = updateFrequency;
// Original code: empty_sig.emit().delay(local_updateFrequency);
assembly {
    mstore(
        0x00,
        sigemit(
            sload(empty_sig_key.slot), 
            0,
            0,
            local_updateFrequency
        )
    )
}
////////////////////

        uint256 newValue = uint256(medianizerInstance.read());

        editList(
            historicalPriceData,
            newValue
        );
    }

    /*
     * Query linked list for specified days of data. Will revert if number of days
     * passed exceeds amount of days collected. Will revert if not enough days of
     * data logged.
     *
     * @param  _dataDays       Number of days of data being queried
     * @returns                Array of historical price data of length _dataDays
     */
    function read(
        uint256 _dataDays
    )
        external
        view
        returns (uint256[] memory)
    {
        return readList(
            historicalPriceData,
            _dataDays
        );
    }

    /*
     * Change medianizer in case current one fails or is deprecated. Only contract
     * owner is allowed to change.
     *
     * @param  _newMedianizerAddress       Address of new medianizer to pull data from
     */
    function changeMedianizer(
        address _newMedianizerAddress
    )
        external
        onlyOwner
    {
        medianizerInstance = IMedian(_newMedianizerAddress);
    }


    /* ============ Private ============ */

    /*
     * Create initialValues array from _seededValues and the current medianizer price.
     * Added to historicalPriceData in constructor.
// Auto create signal
set_empty_sig_key();
assembly {
    mstore(0x00, createsignal(sload(empty_sig_key.slot)))
}
////////////////////
     *
     * @param  _seededValues        Array of previous days' historical price values to seed
     * @returns                     Array of initial values to add to historicalPriceData
     */
    function createInitialValues(
        uint256[] memory _seededValues
    )
        private
        returns (uint256[] memory)
    {
        uint256 currentValue = uint256(medianizerInstance.read());

        uint256 seededValuesLength = _seededValues.length;
        uint256[] memory outputArray = new uint256[](seededValuesLength.add(1));

        for (uint256 i = 0; i < _seededValues.length; i++) {
            outputArray[i] = _seededValues[i];
        }

        outputArray[seededValuesLength] = currentValue;

        return outputArray;
    }

   /* ============ Constructor ============ */

    /*
     * Historical Price Feed Constructor.
     * Stores Historical prices according to passed in oracle address. Updates must be
     * triggered off chain to be stored in this smart contract.
     *
     * @param  _updateFrequency           How often new data can be logged, passe=d in seconds
     * @param  _medianizerAddress         The oracle address to read historical data from
     * @param  _dataDescription           Description of data in Data Bank
     * @param  _seededValues              Array of previous days' Historical price values to seed
     *                                    initial values in list. Should NOT contain the current
     *                                    days price.
     */
    constructor(uint256 _updateFrequency,address _medianizerAddress,string memory _dataDescription, uint256[] memory _seededValues)public {
// Auto create signal
set_empty_sig_key();
assembly {
    mstore(0x00, createsignal(sload(empty_sig_key.slot)))
}
////////////////////
        updateFrequency = _updateFrequency;
        dataDescription = _dataDescription;
        medianizerInstance = IMedian(_medianizerAddress);

        uint256[] memory initialValues = createInitialValues(_seededValues);

        initialize(
            historicalPriceData,
            DAYS_IN_DATASET,
            initialValues[0]
        );

        for (uint256 i = 1; i < initialValues.length; i++) {
            editList(
                historicalPriceData,
                initialValues[i]
            );
        }

        lastUpdatedAt = block.timestamp;
        address addr = address(this);
// Original code: poke.bind(addr,HistoricalPriceFeed.empty_sig,0.1,false,arg_roles,arg_methods);
set_poke_key();
bytes32 poke_method_hash = keccak256("poke()");
bytes32 poke_signal_prototype_hash = keccak256("empty_sig()");
bytes memory abi_encoded_poke_sigRoles = abi.encode(arg_roles);
uint abi_encoded_poke_sigRoles_length = abi_encoded_poke_sigRoles.length;
bytes memory abi_encoded_poke_sigMethods = abi.encode(arg_methods);
uint abi_encoded_poke_sigMethods_length = abi_encoded_poke_sigMethods.length;

assembly {
    mstore(
        0x00,
        sigbind(
            sload(poke_key.slot),
            poke_method_hash, 
            100000000, 
            110,
            addr,
            poke_signal_prototype_hash,
            0,
            abi_encoded_poke_sigRoles,
            abi_encoded_poke_sigRoles_length,
            abi_encoded_poke_sigMethods,
            abi_encoded_poke_sigMethods_length
        )
    )
}
////////////////////
    }

}