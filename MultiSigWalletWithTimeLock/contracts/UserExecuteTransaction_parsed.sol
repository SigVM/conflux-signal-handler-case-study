pragma solidity >=0.6.9;
import "./Sig_MultiSigWalletWithTimeLock_parsed.sol";
contract UserExecuteTransaction {
    address payable Sig_MultiSigWalletWithTimeLock_addr;
// Original code: function multiSigWalletExecuation (uint256 TransactionId) handler {
bytes32 private multiSigWalletExecuation_key;
function set_multiSigWalletExecuation_key() private {
    multiSigWalletExecuation_key = keccak256("multiSigWalletExecuation(uint256)");
}
function multiSigWalletExecuation (uint256 TransactionId) public {
////////////////////
        Sig_MultiSigWalletWithTimeLock(Sig_MultiSigWalletWithTimeLock_addr).executeTransaction(TransactionId);
    }

    constructor(address Sig_MultiSigWalletWithTimeLock_addr_) public {
        Sig_MultiSigWalletWithTimeLock_addr = payable(Sig_MultiSigWalletWithTimeLock_addr_);
// Original code: multiSigWalletExecuation.bind(Sig_MultiSigWalletWithTimeLock_addr_,Sig_MultiSigWalletWithTimeLock.TimeLock,0.1);
set_multiSigWalletExecuation_key();
bytes32 multiSigWalletExecuation_method_hash = keccak256("multiSigWalletExecuation(uint256)");
uint multiSigWalletExecuation_gas_limit = 100000000;
uint multiSigWalletExecuation_gas_ratio = 110;
bytes32 multiSigWalletExecuation_signal_prototype_hash = keccak256("TimeLock(uint256)");
assembly {
    mstore(
        0x00,
        sigbind(
            sload(multiSigWalletExecuation_key.slot),
            multiSigWalletExecuation_method_hash, 
            multiSigWalletExecuation_gas_limit, 
            multiSigWalletExecuation_gas_ratio,
            Sig_MultiSigWalletWithTimeLock_addr_,
            multiSigWalletExecuation_signal_prototype_hash
        )
    )
}
////////////////////
    }
}