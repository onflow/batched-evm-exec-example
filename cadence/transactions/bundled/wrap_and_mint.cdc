import "FungibleToken"
import "FlowToken"
import "EVM"

/// This transaction demonstrates how multiple EVM calls can be batched in a single Cadence transaction via
/// CadenceOwnedAccount (COA), performing the following actions:
///
///     1. Configures a COA in the signer's account if needed
///     2. Funds the signer's COA with enough FLOW to cover the WFLOW cost of minting an ERC721 token
///     3. Wraps FLOW as WFLOW - EVM call 1
///     4. Approves the example MaybeMintERC721 contract which accepts WFLOW to move the mint amount - EVM call 2
///     5. Attempts to mint an ERC721 token - EVM call 3
///
/// Importantly, the transaction is reverted if any of the EVM interactions fail returning the account to the original
/// state before the transaction was executed across Cadence & EVM.
///
/// For more context, see https://github.com/onflow/batched-evm-exec-example
///
/// @param wflowAddressHex: The EVM address hex of the WFLOW contract as a String
/// @param maybeMintERC721AddressHex: The EVM address hex of the ERC721 contract as a String
///
transaction(wflowAddressHex: String, maybeMintERC721AddressHex: String) {
    
    let coa: auth(EVM.Call) &EVM.CadenceOwnedAccount
    let mintCost: UFix64
    let wflowAddress: EVM.EVMAddress
    let erc721Address: EVM.EVMAddress

    prepare(signer: auth(SaveValue, BorrowValue, IssueStorageCapabilityController, PublishCapability, UnpublishCapability) &Account) {
        /* COA configuration & assigment */
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

        /* Assign the ERC721 EVM Address */
        //
        // Deserialize the provided ERC721 hex string to an EVM address
        self.erc721Address = EVM.addressFromString(maybeMintERC721AddressHex)
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

        /* Approve the ERC721 address for the mint amount */
        //
        // Encode calldata approve(address,uint) calldata, providing the ERC721 address & mint amount
        let approveCalldata = EVM.encodeABIWithSignature(
                "approve(address,uint256)",
                [self.erc721Address, UInt256(1_000_000_000_000_000_000)]
            )
        // Call the WFLOW contract, approving the ERC721 address to move the mint amount
        let approveResult = self.coa.call(
            to: self.wflowAddress,
            data: approveCalldata,
            gasLimit: 15_000_000,
            value: EVM.Balance(attoflow: 0)
        )
        assert(
            approveResult.status == EVM.Status.successful,
            message: "Approving ERC721 address on WFLOW contract failed: ".concat(approveResult.errorMessage)
        )

        /* Attempt to mint ERC721 */
        //
        // Convert the mintAmount from UFix64 to UInt256 (given 18 decimal precision on WFLOW contract)
        let ufixAllowance = EVM.Balance(attoflow: 0)
        ufixAllowance.setFLOW(flow: self.mintCost)
        let convertedAllowance = ufixAllowance.inAttoFLOW() as! UInt256
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
        