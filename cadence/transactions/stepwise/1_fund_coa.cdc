import "FungibleToken"
import "FlowToken"
import "EVM"

/// This transaction deposits FLOW from the signer's Cadence vault to their COA's EVM balance
///
transaction {

    let coa: auth(EVM.Call) &EVM.CadenceOwnedAccount
    let fundingVault: @FlowToken.Vault

    prepare(signer: auth(BorrowValue, StorageCapabilities, PublishCapability, UnpublishCapability) &Account) {
        // Ensure a borrowable COA reference is available
        let storagePath = /storage/evm
        self.coa = signer.storage.borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: storagePath)
            ?? panic("A CadenceOwnedAccount (COA) Resource could not be found at path ".concat(storagePath.toString())
                .concat(" - ensure the COA Resource is created and saved at this path to enable EVM interactions"))

        /* Fund COA with cost of mint */
        //
        // Borrow authorized reference to signer's FlowToken Vault
        let sourceVault = signer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(
                from: /storage/flowTokenVault
            ) ?? panic("The signer does not store a FlowToken Vault object at the path "
                    .concat("/storage/flowTokenVault. ")
                    .concat("The signer must initialize their account with this vault first!"))
        // Withdraw from the signer's FlowToken Vault
        let mintCost = 1.0
        self.fundingVault <- sourceVault.withdraw(amount: mintCost) as! @FlowToken.Vault
    }

    execute {
        // Deposit the mint cost into the COA
        self.coa.deposit(from: <-self.fundingVault)    
    }
}
