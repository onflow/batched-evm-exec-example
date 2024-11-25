import "FungibleToken"
import "FlowToken"
import "EVM"

/// This transaction approves the provided ERC721 address to move the mint amount on the WFLOW contract. In this example
/// the mint amount is 1.0 WFLOW. While not included in the code below, this transaction is part of a larger example
/// showcasing how Cadence can be used to atomically orchestrate multiple EVM interactions in a single transaction.
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

    prepare(signer: auth(BorrowValue) &Account) {
        // Ensure a borrowable COA reference is available
        let storagePath = /storage/evm
        self.coa = signer.storage.borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: storagePath)
            ?? panic("A CadenceOwnedAccount (COA) Resource could not be found at path ".concat(storagePath.toString())
                .concat(" - ensure the COA Resource is created and saved at this path to enable EVM interactions"))
        // Assign the amount we'll deposit to WFLOW to cover the eventual ERC721 mint
        self.mintCost = 1.0
        // Deserialize the WFLOW & ERC721 addresses
        self.wflowAddress = EVM.addressFromString(wflowAddressHex)
        self.erc721Address = EVM.addressFromString(maybeMintERC721AddressHex)
    }

    execute {
        /* Approve the ERC721 address for the mint amount */
        //
        // Convert the mintAmount from UFix64 to UInt256 (given 18 decimal precision on WFLOW contract)
        let ufixAllowance = EVM.Balance(attoflow: 0)
        ufixAllowance.setFLOW(flow: self.mintCost)
        let uintAllowance = UInt256(ufixAllowance.inAttoFLOW())
        // Encode calldata approve(address,uint) calldata, providing the ERC721 address & mint amount
        let approveCalldata = EVM.encodeABIWithSignature(
                "approve(address,uint256)",
                [self.erc721Address, uintAllowance]
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
    }
}
