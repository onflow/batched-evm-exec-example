import "EVM"

/// Configures a CadenceOwnedAccount in the signer's account if one is not already stored.
///
transaction {

    prepare(signer: auth(BorrowValue, SaveValue, StorageCapabilities, PublishCapability, UnpublishCapability) &Account) {
        /* COA configuration & assignment */
        //
        let storagePath = /storage/evm
        let publicPath = /public/evm
        // Configure a COA if one is not found in storage at the default path
        if signer.storage.type(at: storagePath) == nil {
            // Create & save the CadenceOwnedAccount (COA) Resource
            let newCOA <- EVM.createCadenceOwnedAccount()
            signer.storage.save(<-newCOA, to: storagePath)

            // Unpublish any existing Capability at the public path if it exists
            signer.capabilities.unpublish(publicPath)
            // Issue & publish the public, unentitled COA Capability
            let coaCapability = signer.capabilities.storage.issue<&EVM.CadenceOwnedAccount>(storagePath)
            signer.capabilities.publish(coaCapability, at: publicPath)
        }

        // Ensure a borrowable COA reference is available
        let coa = signer.storage.borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: storagePath)
            ?? panic("A CadenceOwnedAccount (COA) Resource could not be found at path ".concat(storagePath.toString())
                .concat(" - ensure the COA Resource is created and saved at this path to enable EVM interactions"))    
    }
}
