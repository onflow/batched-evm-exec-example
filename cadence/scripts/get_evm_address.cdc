import "EVM"

/// Returns the EVM address of a given Flow account as defined by the account's COA.
/// If a COA is not found, nil is returned.
///
/// @param address: The Flow address to look up
///
/// @return the serialized EVM address or nil if a COA is not found in the given account
///
access(all) fun main(address: Address): String? {
    let flowAccount = getAccount(address)
    if let coa = flowAccount.capabilities.borrow<&EVM.CadenceOwnedAccount>(/public/evm) {
        return coa.address().toString()
    }
    return nil
}
