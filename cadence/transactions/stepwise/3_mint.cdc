import "FungibleToken"
import "FlowToken"
import "EVM"

/// This transaction attempts to mint the ERC721 token, reverting if the mint fails
///
transaction(wflowAddressHex: String, maybeMintERC721AddressHex: String) {

    let coa: auth(EVM.Call) &EVM.CadenceOwnedAccount
    let erc721Address: EVM.EVMAddress

    prepare(signer: auth(SaveValue, BorrowValue, IssueStorageCapabilityController, PublishCapability, UnpublishCapability) &Account) {
        /* COA assigment */
        //
        let storagePath = /storage/evm

        // Assign the COA reference to the transaction's coa field
        self.coa = signer.storage.borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: storagePath)
            ?? panic("A CadenceOwnedAccount (COA) Resource could not be found at path ".concat(storagePath.toString())
                .concat(" - ensure the COA Resource is created and saved at this path to enable EVM interactions"))

        /* Assign the ERC721 EVM Address */
        //
        // Deserialize the provided ERC721 hex string to an EVM address
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
