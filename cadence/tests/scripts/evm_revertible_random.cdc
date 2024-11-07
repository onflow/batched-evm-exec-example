import "EVM"

access(all)
fun main(coaHost: Address, testAddress: EVM.EVMAddress): UInt64 {
    let coa = getAuthAccount<auth(BorrowValue) &Account>(coaHost).storage
        .borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: /storage/evm)!
    let res = coa.call(
        to: testAddress,
        data: EVM.encodeABIWithSignature("getRevertibleRandomInRange(uint64,uint64)", [UInt64(0), UInt64(1000)]),
        gasLimit: 15_000_000,
        value: EVM.Balance(attoflow: 0)
    )
    assert(res.status == EVM.Status.successful, message: "getRevertibleRandomInRange failed")
    let decoded = EVM.decodeABI(types: [Type<UInt64>()], data: res.data)
    return decoded[0] as! UInt64
}
