import "FungibleToken"
import "FlowToken"
import "EVM"

/// Creates a CadenceOwnedAccount & funds with the specified amount. If the COA already exists, the transaction reverts.
///
transaction(amount: UFix64) {
    
    let coa: auth(EVM.Call) &EVM.CadenceOwnedAccount
    let fundingVault: @FlowToken.Vault

    prepare(signer: auth(SaveValue, BorrowValue, IssueStorageCapabilityController, PublishCapability, UnpublishCapability) &Account) {
        pre {
            amount > 0.0: "The funding amount must be greater than zero"
        }
        /* COA configuration & assigment */
        //
        let storagePath = /storage/evm
        let publicPath = /public/evm
        // Configure a COA if one is not found in storage at the default path
        if signer.storage.type(at: storagePath) != nil {
            panic("CadenceOwnedAccount already exists at path ".concat(storagePath.toString()))
        }
        // Create & save the CadenceOwnedAccount (COA) Resource
        let newCOA <- EVM.createCadenceOwnedAccount()
        signer.storage.save(<-newCOA, to: storagePath)

        // Unpublish any existing Capability at the public path if it exists
        signer.capabilities.unpublish(publicPath)
        // Issue & publish the public, unentitled COA Capability
        let coaCapability = signer.capabilities.storage.issue<&EVM.CadenceOwnedAccount>(storagePath)
        signer.capabilities.publish(coaCapability, at: publicPath)

        // Assign the COA reference to the transaction's coa field
        self.coa = signer.storage.borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: storagePath)
            ?? panic("A CadenceOwnedAccount (COA) Resource could not be found at path ".concat(storagePath.toString())
                .concat(" - ensure the COA Resource is created and saved at this path to enable EVM interactions"))

        // Borrow authorized reference to signer's FlowToken Vault
        let sourceVault = signer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(
                from: /storage/flowTokenVault
            ) ?? panic("The signer does not store a FlowToken Vault object at the path "
                    .concat("/storage/flowTokenVault. ")
                    .concat("The signer must initialize their account with this vault first!"))
        // Withdraw from the signer's FlowToken Vault
        self.fundingVault <- sourceVault.withdraw(amount: amount) as! @FlowToken.Vault
    }

    pre {
        self.fundingVault.balance == amount:
            "Expected amount =".concat(amount.toString())
            .concat(" but fundingVault.balance=").concat(self.fundingVault.balance.toString())
    }

    execute {
        /* Fund COA */
        //
        // Deposit the FLOW into the COA
        self.coa.deposit(from: <-self.fundingVault)
    }
}
        