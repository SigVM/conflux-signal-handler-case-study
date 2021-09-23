pragma solidity >=0.6.9;
import "./Sig_MultiSigWalletWithTimeLock_parsed.sol";
contract UserExecuteTransaction {
    address payable Sig_MultiSigWalletWithTimeLock_addr;
    address[2] arg_roles;
    bytes32[3] arg_methods;
    // Handler to do function call
    function multiSigWalletExecuation (uint256 TransactionId) handler {
        Sig_MultiSigWalletWithTimeLock(Sig_MultiSigWalletWithTimeLock_addr).executeTransaction(TransactionId);
    }

    constructor(address Sig_MultiSigWalletWithTimeLock_addr_) public {
        Sig_MultiSigWalletWithTimeLock_addr = payable(Sig_MultiSigWalletWithTimeLock_addr_);
        multiSigWalletExecuation.bind(Sig_MultiSigWalletWithTimeLock_addr_, Sig_MultiSigWalletWithTimeLock.TimeLock, 0.1, false, arg_roles, arg_methods);
    }
}