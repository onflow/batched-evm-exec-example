import Test

// Bytecode constants
access(all) let wflowBytecode = "60c0604052600c60808190526b5772617070656420466c6f7760a01b60a090815261002d916000919061007a565b506040805180820190915260058082526457464c4f5760d81b602090920191825261005a9160019161007a565b506002805460ff1916601217905534801561007457600080fd5b50610115565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106100bb57805160ff19168380011785556100e8565b828001600101855582156100e8579182015b828111156100e85782518255916020019190600101906100cd565b506100f49291506100f8565b5090565b61011291905b808211156100f457600081556001016100fe565b90565b6106e3806101246000396000f3fe60806040526004361061009c5760003560e01c8063313ce56711610064578063313ce5671461021157806370a082311461023c57806395d89b411461026f578063a9059cbb14610284578063d0e30db01461009c578063dd62ed3e146102bd5761009c565b806306fdde03146100a6578063095ea7b31461013057806318160ddd1461017d57806323b872dd146101a45780632e1a7d4d146101e7575b6100a46102f8565b005b3480156100b257600080fd5b506100bb610347565b6040805160208082528351818301528351919283929083019185019080838360005b838110156100f55781810151838201526020016100dd565b50505050905090810190601f1680156101225780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34801561013c57600080fd5b506101696004803603604081101561015357600080fd5b506001600160a01b0381351690602001356103d5565b604080519115158252519081900360200190f35b34801561018957600080fd5b5061019261043b565b60408051918252519081900360200190f35b3480156101b057600080fd5b50610169600480360360608110156101c757600080fd5b506001600160a01b0381358116916020810135909116906040013561043f565b3480156101f357600080fd5b506100a46004803603602081101561020a57600080fd5b5035610573565b34801561021d57600080fd5b50610226610608565b6040805160ff9092168252519081900360200190f35b34801561024857600080fd5b506101926004803603602081101561025f57600080fd5b50356001600160a01b0316610611565b34801561027b57600080fd5b506100bb610623565b34801561029057600080fd5b50610169600480360360408110156102a757600080fd5b506001600160a01b03813516906020013561067d565b3480156102c957600080fd5b50610192600480360360408110156102e057600080fd5b506001600160a01b0381358116916020013516610691565b33600081815260036020908152604091829020805434908101909155825190815291517fe1fffcc4923d04b559f4d29a8bfc6cda04eb5b0d3c460751c2402c5c5cc9109c9281900390910190a2565b6000805460408051602060026001851615610100026000190190941693909304601f810184900484028201840190925281815292918301828280156103cd5780601f106103a2576101008083540402835291602001916103cd565b820191906000526020600020905b8154815290600101906020018083116103b057829003601f168201915b505050505081565b3360008181526004602090815260408083206001600160a01b038716808552908352818420869055815186815291519394909390927f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925928290030190a350600192915050565b4790565b6001600160a01b03831660009081526003602052604081205482111561046457600080fd5b6001600160a01b03841633148015906104a257506001600160a01b038416600090815260046020908152604080832033845290915290205460001914155b15610502576001600160a01b03841660009081526004602090815260408083203384529091529020548211156104d757600080fd5b6001600160a01b03841660009081526004602090815260408083203384529091529020805483900390555b6001600160a01b03808516600081815260036020908152604080832080548890039055938716808352918490208054870190558351868152935191937fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef929081900390910190a35060019392505050565b3360009081526003602052604090205481111561058f57600080fd5b33600081815260036020526040808220805485900390555183156108fc0291849190818181858888f193505050501580156105ce573d6000803e3d6000fd5b5060408051828152905133917f7fcf532c15f0a6db0bd6d0e038bea71d30d808c7d98cb3bf7268a95bf5081b65919081900360200190a250565b60025460ff1681565b60036020526000908152604090205481565b60018054604080516020600284861615610100026000190190941693909304601f810184900484028201840190925281815292918301828280156103cd5780601f106103a2576101008083540402835291602001916103cd565b600061068a33848461043f565b9392505050565b60046020908152600092835260408084209091529082529020548156fea265627a7a7231582092a6eff3c9232bde55997efc6d8d256f5875b16304694b39e740dcabf78f802964736f6c63430005110032"
access(all) let erc721Bytecode = "60806040523480156200001157600080fd5b506040516200181b3803806200181b833981016040819052620000349162000208565b338585600062000045838262000332565b50600162000054828262000332565b5050506001600160a01b0381166200008657604051631e4fbdf760e01b81526000600482015260240160405180910390fd5b6200009181620000d1565b50600780546001600160a01b039485166001600160a01b0319918216179091556008929092556009805491909316911617905550506000600a55620003fe565b600680546001600160a01b038381166001600160a01b0319831681179093556040519116919082907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a35050565b634e487b7160e01b600052604160045260246000fd5b600082601f8301126200014b57600080fd5b81516001600160401b038082111562000168576200016862000123565b604051601f8301601f19908116603f0116810190828211818310171562000193576200019362000123565b8160405283815260209250866020858801011115620001b157600080fd5b600091505b83821015620001d55785820183015181830184015290820190620001b6565b6000602085830101528094505050505092915050565b80516001600160a01b03811681146200020357600080fd5b919050565b600080600080600060a086880312156200022157600080fd5b85516001600160401b03808211156200023957600080fd5b6200024789838a0162000139565b965060208801519150808211156200025e57600080fd5b506200026d8882890162000139565b9450506200027e60408701620001eb565b9250606086015191506200029560808701620001eb565b90509295509295909350565b600181811c90821680620002b657607f821691505b602082108103620002d757634e487b7160e01b600052602260045260246000fd5b50919050565b601f8211156200032d576000816000526020600020601f850160051c81016020861015620003085750805b601f850160051c820191505b81811015620003295782815560010162000314565b5050505b505050565b81516001600160401b038111156200034e576200034e62000123565b62000366816200035f8454620002a1565b84620002dd565b602080601f8311600181146200039e5760008415620003855750858301515b600019600386901b1c1916600185901b17855562000329565b600085815260208120601f198616915b82811015620003cf57888601518255948401946001909101908401620003ae565b5085821015620003ee5787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b61140d806200040e6000396000f3fe608060405234801561001057600080fd5b50600436106101375760003560e01c806370a08231116100b8578063a22cb4651161007c578063a22cb4651461026b578063b88d4fde1461027e578063bdb4b84814610291578063c87b56dd1461029a578063e985e9c5146102ad578063f2fde38b146102c057600080fd5b806370a0823114610224578063715018a6146102375780638bca6d161461023f5780638da5cb5b1461025257806395d89b411461026357600080fd5b806318160ddd116100ff57806318160ddd146101c157806323b872dd146101d857806338af3eed146101eb57806342842e0e146101fe5780636352211e1461021157600080fd5b806301ffc9a71461013c57806306fdde0314610164578063081812fc14610179578063095ea7b3146101a45780631249c58b146101b9575b600080fd5b61014f61014a366004610fb5565b6102d3565b60405190151581526020015b60405180910390f35b61016c610325565b60405161015b9190611022565b61018c610187366004611035565b6103b7565b6040516001600160a01b03909116815260200161015b565b6101b76101b236600461106a565b6103e0565b005b6101b76103ef565b6101ca600a5481565b60405190815260200161015b565b6101b76101e6366004611094565b6103f9565b60095461018c906001600160a01b031681565b6101b761020c366004611094565b610489565b61018c61021f366004611035565b6104a9565b6101ca6102323660046110d0565b6104b4565b6101b76104fc565b60075461018c906001600160a01b031681565b6006546001600160a01b031661018c565b61016c61050e565b6101b76102793660046110f9565b61051d565b6101b761028c366004611146565b610528565b6101ca60085481565b61016c6102a8366004611035565b610540565b61014f6102bb366004611222565b6105b5565b6101b76102ce3660046110d0565b6105e3565b60006001600160e01b031982166380ac58cd60e01b148061030457506001600160e01b03198216635b5e139f60e01b145b8061031f57506301ffc9a760e01b6001600160e01b03198316145b92915050565b60606000805461033490611255565b80601f016020809104026020016040519081016040528092919081815260200182805461036090611255565b80156103ad5780601f10610382576101008083540402835291602001916103ad565b820191906000526020600020905b81548152906001019060200180831161039057829003601f168201915b5050505050905090565b60006103c282610621565b506000828152600460205260409020546001600160a01b031661031f565b6103eb82823361065a565b5050565b6103f7610667565b565b6001600160a01b03821661042857604051633250574960e11b8152600060048201526024015b60405180910390fd5b6000610435838333610746565b9050836001600160a01b0316816001600160a01b031614610483576040516364283d7b60e01b81526001600160a01b038086166004830152602482018490528216604482015260640161041f565b50505050565b6104a483838360405180602001604052806000815250610528565b505050565b600061031f82610621565b60006001600160a01b0382166104e0576040516322718ad960e21b81526000600482015260240161041f565b506001600160a01b031660009081526003602052604090205490565b61050461083f565b6103f7600061086c565b60606001805461033490611255565b6103eb3383836108be565b6105338484846103f9565b610483338585858561095d565b606061054b82610621565b50600061056360408051602081019091526000815290565b9050600081511161058357604051806020016040528060008152506105ae565b8061058d84610a88565b60405160200161059e92919061128f565b6040516020818303038152906040525b9392505050565b6001600160a01b03918216600090815260056020908152604080832093909416825291909152205460ff1690565b6105eb61083f565b6001600160a01b03811661061557604051631e4fbdf760e01b81526000600482015260240161041f565b61061e8161086c565b50565b6000818152600260205260408120546001600160a01b03168061031f57604051637e27328960e01b81526004810184905260240161041f565b6104a48383836001610b1b565b61066f610c21565b6007546009546008546040516323b872dd60e01b81523360048201526001600160a01b03928316602482015260448101919091529116906323b872dd906064016020604051808303816000875af19250505080156106ea575060408051601f3d908101601f191682019092526106e7918101906112be565b60015b6107245760075460085460405163760a9bc360e11b81526001600160a01b039092166004830152336024830152604482015260640161041f565b50600a8054906000610735836112db565b91905055506103f733600a54610c62565b6000828152600260205260408120546001600160a01b039081169083161561077357610773818486610cc7565b6001600160a01b038116156107b157610790600085600080610b1b565b6001600160a01b038116600090815260036020526040902080546000190190555b6001600160a01b038516156107e0576001600160a01b0385166000908152600360205260409020805460010190555b60008481526002602052604080822080546001600160a01b0319166001600160a01b0389811691821790925591518793918516917fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef91a4949350505050565b6006546001600160a01b031633146103f75760405163118cdaa760e01b815233600482015260240161041f565b600680546001600160a01b038381166001600160a01b0319831681179093556040519116919082907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a35050565b6001600160a01b0382166108f057604051630b61174360e31b81526001600160a01b038316600482015260240161041f565b6001600160a01b03838116600081815260056020908152604080832094871680845294825291829020805460ff191686151590811790915591519182527f17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31910160405180910390a3505050565b6001600160a01b0383163b15610a8157604051630a85bd0160e11b81526001600160a01b0384169063150b7a029061099f908890889087908790600401611302565b6020604051808303816000875af19250505080156109da575060408051601f3d908101601f191682019092526109d79181019061133f565b60015b610a43573d808015610a08576040519150601f19603f3d011682016040523d82523d6000602084013e610a0d565b606091505b508051600003610a3b57604051633250574960e11b81526001600160a01b038516600482015260240161041f565b805181602001fd5b6001600160e01b03198116630a85bd0160e11b14610a7f57604051633250574960e11b81526001600160a01b038516600482015260240161041f565b505b5050505050565b60606000610a9583610d2b565b600101905060008167ffffffffffffffff811115610ab557610ab5611130565b6040519080825280601f01601f191660200182016040528015610adf576020820181803683370190505b5090508181016020015b600019016f181899199a1a9b1b9c1cb0b131b232b360811b600a86061a8153600a8504945084610ae957509392505050565b8080610b2f57506001600160a01b03821615155b15610bf1576000610b3f84610621565b90506001600160a01b03831615801590610b6b5750826001600160a01b0316816001600160a01b031614155b8015610b7e5750610b7c81846105b5565b155b15610ba75760405163a9fbf51f60e01b81526001600160a01b038416600482015260240161041f565b8115610bef5783856001600160a01b0316826001600160a01b03167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92560405160405180910390a45b505b5050600090815260046020526040902080546001600160a01b0319166001600160a01b0392909216919091179055565b6000610c2b610e03565b9050610c3860028261135c565b67ffffffffffffffff1660010361061e576040516351d099d960e11b815260040160405180910390fd5b6001600160a01b038216610c8c57604051633250574960e11b81526000600482015260240161041f565b6000610c9a83836000610746565b90506001600160a01b038116156104a4576040516339e3563760e11b81526000600482015260240161041f565b610cd2838383610f3c565b6104a4576001600160a01b038316610d0057604051637e27328960e01b81526004810182905260240161041f565b60405163177e802f60e01b81526001600160a01b03831660048201526024810182905260440161041f565b60008072184f03e93ff9f4daa797ed6e38ed64bf6a1f0160401b8310610d6a5772184f03e93ff9f4daa797ed6e38ed64bf6a1f0160401b830492506040015b6d04ee2d6d415b85acef81000000008310610d96576d04ee2d6d415b85acef8100000000830492506020015b662386f26fc100008310610db457662386f26fc10000830492506010015b6305f5e1008310610dcc576305f5e100830492506008015b6127108310610de057612710830492506004015b60648310610df2576064830492506002015b600a831061031f5760010192915050565b60408051600481526024810182526020810180516001600160e01b0316630382fd5960e51b1790529051600091829182916801000000000000000191610e499190611391565b600060405180830381855afa9150503d8060008114610e84576040519150601f19603f3d011682016040523d82523d6000602084013e610e89565b606091505b509150915081610f1e5760405162461bcd60e51b815260206004820152605460248201527f556e7375636365737366756c2063616c6c20746f20436164656e63652041726360448201527f68207072652d636f6d70696c65207768656e206665746368696e672072657665606482015273393a34b13632903930b73237b690373ab6b132b960611b608482015260a40161041f565b600081806020019051810190610f3491906113ad565b949350505050565b60006001600160a01b03831615801590610f345750826001600160a01b0316846001600160a01b03161480610f765750610f7684846105b5565b80610f345750506000908152600460205260409020546001600160a01b03908116911614919050565b6001600160e01b03198116811461061e57600080fd5b600060208284031215610fc757600080fd5b81356105ae81610f9f565b60005b83811015610fed578181015183820152602001610fd5565b50506000910152565b6000815180845261100e816020860160208601610fd2565b601f01601f19169290920160200192915050565b6020815260006105ae6020830184610ff6565b60006020828403121561104757600080fd5b5035919050565b80356001600160a01b038116811461106557600080fd5b919050565b6000806040838503121561107d57600080fd5b6110868361104e565b946020939093013593505050565b6000806000606084860312156110a957600080fd5b6110b28461104e565b92506110c06020850161104e565b9150604084013590509250925092565b6000602082840312156110e257600080fd5b6105ae8261104e565b801515811461061e57600080fd5b6000806040838503121561110c57600080fd5b6111158361104e565b91506020830135611125816110eb565b809150509250929050565b634e487b7160e01b600052604160045260246000fd5b6000806000806080858703121561115c57600080fd5b6111658561104e565b93506111736020860161104e565b925060408501359150606085013567ffffffffffffffff8082111561119757600080fd5b818701915087601f8301126111ab57600080fd5b8135818111156111bd576111bd611130565b604051601f8201601f19908116603f011681019083821181831017156111e5576111e5611130565b816040528281528a60208487010111156111fe57600080fd5b82602086016020830137600060208483010152809550505050505092959194509250565b6000806040838503121561123557600080fd5b61123e8361104e565b915061124c6020840161104e565b90509250929050565b600181811c9082168061126957607f821691505b60208210810361128957634e487b7160e01b600052602260045260246000fd5b50919050565b600083516112a1818460208801610fd2565b8351908301906112b5818360208801610fd2565b01949350505050565b6000602082840312156112d057600080fd5b81516105ae816110eb565b6000600182016112fb57634e487b7160e01b600052601160045260246000fd5b5060010190565b6001600160a01b038581168252841660208201526040810183905260806060820181905260009061133590830184610ff6565b9695505050505050565b60006020828403121561135157600080fd5b81516105ae81610f9f565b600067ffffffffffffffff8084168061138557634e487b7160e01b600052601260045260246000fd5b92169190910692915050565b600082516113a3818460208701610fd2565b9190910192915050565b6000602082840312156113bf57600080fd5b815167ffffffffffffffff811681146105ae57600080fdfea2646970667358221220859d8cb88597efba0ae5690919e0bd43747ee03f464470c2b6f1c0b3f9bb454f64736f6c63430008180033"

/* --- Getters --- */

access(all)
fun getWFLOWBytecode(): String {
    return wflowBytecode
}

access(all)
fun getERC721Bytecode(): String {
    return erc721Bytecode
}

access(all)
fun moveBlock() {
    let res = _executeTransaction(
        "./transactions/move_block.cdc",
        [],
        Test.serviceAccount()
    )
    Test.expect(res, Test.beSucceeded())
}

access(all)
fun _executeTransaction(_ path: String, _ args: [AnyStruct], _ signer: Test.TestAccount): Test.TransactionResult {
    let txn = Test.Transaction(
        code: Test.readFile(path),
        authorizers: [signer.address],
        signers: [signer],
        arguments: args
    )    
    return Test.executeTransaction(txn)
}