import "EVM"

/// Returns the FLOW balance of of a given EVM address in FlowEVM
///
/// @param address: The hex-encoded EVM address for which to check the balance
///
access(all) fun main(address: String): UFix64 {
    return EVM.addressFromString(address).balance().inFLOW()
}
