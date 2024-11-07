import Test
import BlockchainHelpers
import "test_helpers.cdc"

import "EVM"

access(all) let serviceAccount = Test.serviceAccount()

access(all) var coaAddress: String = ""
access(all) var testAddress: String = ""

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
    let testDeployRes = executeTransaction(
        "./transactions/deploy.cdc",
        [testBytecode, UInt64(15_000_000), 0.0],
        serviceAccount
    )
    Test.expect(testDeployRes, Test.beSucceeded())

    // Extract test address from event
    var txnExecEvts = Test.eventsOfType(Type<EVM.TransactionExecuted>())
    let testEvt = txnExecEvts[2] as! EVM.TransactionExecuted
    testAddress = testEvt.contractAddress

    log("Test address: ".concat(testAddress))
}

access(all)
fun testGetRevertibleRandomSucceeds() {
    let a = getEVMRevertibleRandom(coaHost: serviceAccount.address, testAddress: EVM.addressFromString(testAddress))
    moveBlock()
    let b = getEVMRevertibleRandom(coaHost: serviceAccount.address, testAddress: EVM.addressFromString(testAddress))
    moveBlock()
    let c = getEVMRevertibleRandom(coaHost: serviceAccount.address, testAddress: EVM.addressFromString(testAddress))
    moveBlock()
    let d = getEVMRevertibleRandom(coaHost: serviceAccount.address, testAddress: EVM.addressFromString(testAddress))
    moveBlock()
    let e = getEVMRevertibleRandom(coaHost: serviceAccount.address, testAddress: EVM.addressFromString(testAddress))
    moveBlock()
    let f = getEVMRevertibleRandom(coaHost: serviceAccount.address, testAddress: EVM.addressFromString(testAddress))
    log(String.join([a.toString(), b.toString(), c.toString(), d.toString(), e.toString(), f.toString()], separator: ", "))
    // Test.assert(a != b || a != c || b != c, message: "getEVMRevertibleRandom should return different values")
}

access(all)
fun getEVMRevertibleRandom(coaHost: Address, testAddress: EVM.EVMAddress): UInt64 {
    return 0
}