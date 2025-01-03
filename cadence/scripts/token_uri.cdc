import "EVM"

/// Returns the token URI of the requested ERC721 ID
///
/// @param coaHost: The Flow address storing the COA to use for the EVM call
/// @param erc721AddressHex: The hex-encoded EVM contract address of the ERC721 contract
/// @param tokenID: The NFT ID for which to retrieve the token URI
///
/// @return The token URI for the requested NFT
///
access(all) fun main(coaHost: Address, erc721AddressHex: String, tokenID: UInt256): String {
    // Get the COA from the Flow account we'll use to make the EVM call
    let flowAccount = getAuthAccount<auth(BorrowValue) &Account>(coaHost)
    let coa = flowAccount.storage.borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: /storage/evm)
        ?? panic("Could not find a COA in account ".concat(coaHost.toString()))
    // Deserialize the contract address & owner address
    let erc721Address = EVM.addressFromString(erc721AddressHex)

    // Encode the calldata for the EVM call
    let calldata = EVM.encodeABIWithSignature(
        "tokenURI(uint256)",
        [tokenID]
    )
    // Make the EVM call, targetting the contract and passing the encoded calldata
    let res = coa.call(
        to: erc721Address,
        data: calldata,
        gasLimit: 15_000_000,
        value: EVM.Balance(attoflow: 0)
    )
    assert(res.status == EVM.Status.successful, message: "Error making tokenURI(uint256) call to ".concat(erc721AddressHex))

    // Decode the calldata, ensure success & return
    let decoded = EVM.decodeABI(types: [Type<String>()], data: res.data)
    assert(decoded.length == 1, message: "Expected 1 decoded value, got ".concat(decoded.length.toString()))

    // Cast the return value since .decodeABI returns [`AnyStruct`]
    return decoded[0] as! String
}
