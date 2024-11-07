import Test
import BlockchainHelpers
import "test_helpers.cdc"

import "EVM"

access(all) let serviceAccount = Test.serviceAccount()

access(all) var coaAddress: String = ""
access(all) var wflowAddress: String = ""
access(all) var erc721Address: String = ""

access(all)
fun setup() {
    // Create & fund a CadenceOwnedAccount
    let coaRes = executeTransaction(
        "./transactions/create_coa.cdc",
        [100.0],
        serviceAccount
    )
    Test.expect(coaRes, Test.beSucceeded())

    // Extract COA address from event
    let coaEvts = Test.eventsOfType(Type<EVM.CadenceOwnedAccountCreated>())
    let coaEvt = coaEvts[0] as! EVM.CadenceOwnedAccountCreated
    coaAddress = coaEvt.address
    log("COA address: ".concat(coaAddress))

    // Deploy WFLOW
    let wflowDeployRes = executeTransaction(
        "./transactions/deploy.cdc",
        [getWFLOWBytecode(), UInt64(15_000_000), 0.0],
        serviceAccount
    )
    Test.expect(wflowDeployRes, Test.beSucceeded())

    // Extract WFLOW address from event
    var txnExecEvts = Test.eventsOfType(Type<EVM.TransactionExecuted>())
    let wflowEvt = txnExecEvts[2] as! EVM.TransactionExecuted
    wflowAddress = wflowEvt.contractAddress

    // Deploy ERC721
    let constructorArgs = [
        "Maybe Mint ERC721",
        "MAYBE",
        EVM.addressFromString(wflowAddress),
        UInt256(1_000_000_000_000_000_000),
        EVM.addressFromString(coaAddress)
    ]
    // Encode constructor args as ABI and then as hex
    let argsBytecode = String.encodeHex(EVM.encodeABI(
        constructorArgs
    ))
    // Append the encoded constructor args to the compiled bytecode
    let finalBytecode = getERC721Bytecode().concat(argsBytecode)
    let erc721DeployRes = executeTransaction(
        "./transactions/deploy.cdc",
        [finalBytecode, UInt64(15_000_000), 0.0],
        serviceAccount
    )
    Test.expect(erc721DeployRes, Test.beSucceeded())

    // Extract ERC721 address from event
    txnExecEvts = Test.eventsOfType(Type<EVM.TransactionExecuted>())
    let erc721Evt = txnExecEvts[3] as! EVM.TransactionExecuted
    erc721Address = erc721Evt.contractAddress

    log("WFLOW address: ".concat(wflowAddress))
    log("ERC721 address: ".concat(erc721Address))
}

access(all)
fun testWrapAndMintSucceeds() {
    let user = Test.createAccount()
    mintFlow(to: user, amount: 10.0)

    wrapAndMintUntilSuccess(signer: user, wflow: wflowAddress, erc721: erc721Address)
}

access(all)
fun wrapAndMintUntilSuccess(signer: Test.TestAccount, wflow: String, erc721: String) {
    var i = 0
    var success = false
    while i < 50 {
        let res: Test.TransactionResult = executeTransaction(
            "../transactions/bundled/wrap_and_mint.cdc",
            [wflow, erc721],
            signer
        )
        if res.error == nil {
            success = true
            break
        } else {
            i = i + 1
            moveBlock()
        }
    }
    Test.assertEqual(true, success)
}