import "EVM"

/// Returns the ERC20 token allowance of the allowed address as approved by the owner
///
/// @param coaHost: The Flow address storing the COA to use for the EVM call
/// @param tokenAddressHex: The hex-encoded EVM address to token to check the allowance for
/// @param ownerAddressHex: The hex-encoded EVM address of the entity who approved the allowed address
/// @param allowedAddressHex: The hex-encoded EVM address of the entity who has been approved
///
/// @return The allowance allotted to the address, reverting if the given contract address does not implement the ERC20 method
///     "allowance(address,address)(uint256)"
///
access(all) fun main(coaHost: Address, tokenAddressHex: String, ownerAddressHex: String, allowedAddressHex: String): UInt256 {
    // Get the COA from the Flow account we'll use to make the EVM call
    let flowAccount = getAuthAccount<auth(BorrowValue) &Account>(coaHost)
    let coa = flowAccount.storage.borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: /storage/evm)
        ?? panic("Could not find a COA in account ".concat(coaHost.toString()))
    // Deserialize the contract address & owner address
    let tokenAddress = EVM.addressFromString(tokenAddressHex)
    let ownerAddress = EVM.addressFromString(ownerAddressHex)
    let allowedAddress = EVM.addressFromString(allowedAddressHex)

    // Encode the calldata for the EVM call
    let calldata = EVM.encodeABIWithSignature(
        "allowance(address,address)",
        [ownerAddress, allowedAddress]
    )
    // Make the EVM call, targetting the contract and passing the encoded calldata
    let res = coa.call(
        to: tokenAddress,
        data: calldata,
        gasLimit: 15_000_000,
        value: EVM.Balance(attoflow: 0)
    )
    assert(res.status == EVM.Status.successful, message: "Error making allowance(address,address) call to ".concat(allowedAddressHex))

    // Decode the calldata, ensure success & return
    let decoded = EVM.decodeABI(types: [Type<UInt256>()], data: res.data)
    assert(decoded.length == 1, message: "Expected 1 decoded value, got ".concat(decoded.length.toString()))

    // Cast the return value since .decodeABI returns [`AnyStruct`]
    return decoded[0] as! UInt256
}
