import "FungibleToken"
import "FlowToken"
import "EVM"

/// This transaction attempts to mint the ERC721 token, reverting if the mint fails. The intended example is part of a 
/// larger example showcasing how Cadence can be used to atomically orchestrate multiple EVM interactions in a single
/// transaction. In this case, the MaybeMintERC721 contract mints an ERC721 token in exchange for WFLOW with a 50% 
/// probability of success. If the mint fails, the transaction can be reverted, ensuring the account is returned to the
/// original state before the transaction was executed across Cadence & EVM.
///
/// For more context, see https://github.com/onflow/batched-evm-exec-example
///
/// @param wflowAddressHex: The EVM address hex of the WFLOW contract as a String
/// @param maybeMintERC721AddressHex: The EVM address hex of the ERC721 contract as a String
///
transaction(maybeMintERC721AddressHex: String) {

    let coa: auth(EVM.Call) &EVM.CadenceOwnedAccount
    let erc721Address: EVM.EVMAddress

    prepare(signer: auth(BorrowValue) &Account) {
        // Ensure a borrowable COA reference is available
        let storagePath = /storage/evm
        self.coa = signer.storage.borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: storagePath)
            ?? panic("A CadenceOwnedAccount (COA) Resource could not be found at path ".concat(storagePath.toString())
                .concat(" - ensure the COA Resource is created and saved at this path to enable EVM interactions"))
        // Deserialize the ERC721 address
        self.erc721Address = EVM.addressFromString(maybeMintERC721AddressHex)
    }

    execute {
        /* Attempt to mint ERC721 */
        //
        // Encode the mint() calldata
        let mintCalldata = EVM.encodeABIWithSignature("mint()", [])
        // Call the ERC721 contract, attempting to mint
        let mintResult = self.coa.call(
            to: self.erc721Address,
            data: mintCalldata,
            gasLimit: 15_000_000,
            value: EVM.Balance(attoflow: 0)
        )
        // If mint fails, all other actions in this transaction are reverted
        assert(
            mintResult.status == EVM.Status.successful,
            message: "Minting ERC721 token failed: ".concat(mintResult.errorMessage)
        )
    }
}
