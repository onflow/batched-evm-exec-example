import "FungibleToken"
import "FlowToken"
import "EVM"

/// This transaction wraps FLOW as WFLOW, funing the signer's CadenceOwnedAccount with the mint cost
///
transaction(wflowAddressHex: String) {
    
    let coa: auth(EVM.Call) &EVM.CadenceOwnedAccount
    let mintCost: UFix64
    let wflowAddress: EVM.EVMAddress

    prepare(signer: auth(SaveValue, BorrowValue) &Account) {
        /* COA configuration & assigment */
        //
        let storagePath = /storage/evm
        // Assign the COA reference to the transaction's coa field
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
        self.mintCost = 1.0
        let fundingVault <- sourceVault.withdraw(amount: self.mintCost) as! @FlowToken.Vault
        // Deposit the mint cost into the COA
        self.coa.deposit(from: <-fundingVault)

        /* Set the WFLOW contract address */
        //
        // View the cannonical WFLOW contract at:
        // https://evm-testnet.flowscan.io/address/0xd3bF53DAC106A0290B0483EcBC89d40FcC961f3e
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
