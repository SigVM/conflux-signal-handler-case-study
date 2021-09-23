pragma solidity >=0.6.9;
import "./Sig_MultiSigWalletWithTimeLock_parsed.sol";
contract UserExecuteTransaction {
    address payable Sig_MultiSigWalletWithTimeLock_addr;
    address[2] arg_roles;
    bytes32[3] arg_methods;
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
// Original code: multiSigWalletExecuation.bind(Sig_MultiSigWalletWithTimeLock_addr_,Sig_MultiSigWalletWithTimeLock.TimeLock,0.1,false,arg_roles,arg_methods);
set_multiSigWalletExecuation_key();
bytes32 multiSigWalletExecuation_method_hash = keccak256("multiSigWalletExecuation(uint256)");
bytes32 multiSigWalletExecuation_signal_prototype_hash = keccak256("TimeLock(uint256)");
bytes memory abi_encoded_multiSigWalletExecuation_sigRoles = abi.encode(arg_roles);
uint abi_encoded_multiSigWalletExecuation_sigRoles_length = abi_encoded_multiSigWalletExecuation_sigRoles.length;
bytes memory abi_encoded_multiSigWalletExecuation_sigMethods = abi.encode(arg_methods);
uint abi_encoded_multiSigWalletExecuation_sigMethods_length = abi_encoded_multiSigWalletExecuation_sigMethods.length;

assembly {
    mstore(
        0x00,
        sigbind(
            sload(multiSigWalletExecuation_key.slot),
            multiSigWalletExecuation_method_hash, 
            100000000, 
            110,
            Sig_MultiSigWalletWithTimeLock_addr_,
            multiSigWalletExecuation_signal_prototype_hash,
            0,
            abi_encoded_multiSigWalletExecuation_sigRoles,
            abi_encoded_multiSigWalletExecuation_sigRoles_length,
            abi_encoded_multiSigWalletExecuation_sigMethods,
            abi_encoded_multiSigWalletExecuation_sigMethods_length
        )
    )
}
////////////////////
    }
}