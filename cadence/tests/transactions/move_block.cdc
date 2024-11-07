import "EVM"

transaction {
    let coa: auth(EVM.Call) &EVM.CadenceOwnedAccount
    prepare(signer: auth(BorrowValue) &Account) {
        self.coa = signer.storage.borrow<auth(EVM.Call) &EVM.CadenceOwnedAccount>(from: /storage/evm)
            ?? panic("A CadenceOwnedAccount (COA) Resource could not be found at path /storage/evm")
    }

    execute {
        let res = self.coa.call(
            to: self.coa.address(),
            data: [],
            gasLimit: 15_000_000,
            value: EVM.Balance(attoflow: 0)
        )
        assert(res.status == EVM.Status.successful, message: "Empty EVM call failed")
    }
}
