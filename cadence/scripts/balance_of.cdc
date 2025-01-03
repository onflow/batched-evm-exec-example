import "EVM"

/// Returns the balance of the owner (hex-encoded EVM address) of a given ERC20 fungible token defined
/// at the hex-encoded EVM contract address
///
/// @param coaHost: The Flow address storing the COA to use for the EVM call
/// @param contractAddressHex: The hex-encoded EVM contract address of the ERC20 contract
/// @param ownerAddressHex: The hex-encoded EVM address to check the balance of
///
/// @return The balance of the address, reverting if the given contract address does not implement the ERC20 method
///     "balanceOf(address)(uint256)"
///
access(all) fun main(coaHost: Address, contractAddressHex: String, ownerAddressHex: String): UInt256 {
    // Get the COA from the Flow account we'll use to make the EVM call
    let flowAccount = getAuthAccount<auth(BorrowValue) &Account>(coaHost)
    let coa = flowAccount.storage.borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: /storage/evm)
        ?? panic("Could not find a COA in account ".concat(coaHost.toString()))
    // Deserialize the contract address & owner address
    let contractAddress = EVM.addressFromString(contractAddressHex)
    let ownerAddress = EVM.addressFromString(ownerAddressHex)

    // Encode the calldata for the EVM call
    let calldata = EVM.encodeABIWithSignature(
        "balanceOf(address)",
        [ownerAddress]
    )
    // Make the EVM call, targetting the contract and passing the encoded calldata
    let res = coa.call(
        to: contractAddress,
        data: calldata,
        gasLimit: 15_000_000,
        value: EVM.Balance(attoflow: 0)
    )
    assert(res.status == EVM.Status.successful, message: "Error making balanceOf(address) call to ".concat(contractAddressHex))

    // Decode the calldata, ensure success & return
    let decoded = EVM.decodeABI(types: [Type<UInt256>()], data: res.data)
    assert(decoded.length == 1, message: "Expected 1 decoded value, got ".concat(decoded.length.toString()))

    // Cast the return value since .decodeABI returns [`AnyStruct`]
    return decoded[0] as! UInt256
}
