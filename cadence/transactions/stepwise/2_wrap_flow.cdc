import "FungibleToken"
import "FlowToken"
import "EVM"

/// This transaction wraps FLOW as WFLOW, sourcing the wrapped FLOW from the signer's FlowToken Vault in the amount of
/// 1.0 FLOW to cover the mint cost of 1 MaybeMintERC721 token. If a CadenceOwnedAccount (COA) is not configured in the
/// signer's account, one is configured, allowing the Flow account to interact with Flow's EVM runtime.
///
/// While not interesting on its own, this transaction demonstrates a single step in the bundled EVM execution example,
/// showcasing how Cadence can be used to atomically orchestrate multiple EVM interactions in a single transaction.
///
/// For more context, see https://github.com/onflow/batched-evm-exec-example
/// 
/// @param wflowAddressHex: The EVM address hex of the WFLOW contract as a String
///
transaction(wflowAddressHex: String) {

    let coa: auth(EVM.Call) &EVM.CadenceOwnedAccount
    let mintCost: UFix64
    let wflowAddress: EVM.EVMAddress

    prepare(signer: auth(BorrowValue, StorageCapabilities, PublishCapability, UnpublishCapability) &Account) {
        // Ensure a borrowable COA reference is available
        let storagePath = /storage/evm
        self.coa = signer.storage.borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: storagePath)
            ?? panic("A CadenceOwnedAccount (COA) Resource could not be found at path ".concat(storagePath.toString())
                .concat(" - ensure the COA Resource is created and saved at this path to enable EVM interactions"))
        // Assign the amount we'll deposit to WFLOW to cover the eventual ERC721 mint
        self.mintCost = 1.0
        // Deserialize the WFLOW address
        self.wflowAddress = EVM.addressFromString(wflowAddressHex)
    }

    pre {
        self.coa.balance().inFLOW() >= self.mintCost:
            "CadenceOwnedAccount holds insufficient FLOW balance to mint - "
            .concat("Ensure COA has at least ".concat(self.mintCost.toString()).concat(" FLOW"))
    }

    execute {
        /* Wrap FLOW in EVM as WFLOW */
        //
        // Encode calldata & set value
        let depositCalldata = EVM.encodeABIWithSignature("deposit()", [])
        let value = EVM.Balance(attoflow: 0)
        value.setFLOW(flow: self.mintCost)
        // Call the WFLOW contract, wrapping the sent FLOW
        let wrapResult = self.coa.call(
            to: self.wflowAddress,
            data: depositCalldata,
            gasLimit: 15_000_000,
            value: value
        )
        assert(
            wrapResult.status == EVM.Status.successful,
            message: "Wrapping FLOW as WFLOW failed: ".concat(wrapResult.errorMessage)
        )
    }
}
