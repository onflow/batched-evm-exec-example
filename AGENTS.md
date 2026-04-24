# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, Codex, Cursor, Copilot, and others)
when working in this repository. It is loaded into agent context automatically — keep it concise.

## Overview

Cross-VM example demonstrating how a single Cadence transaction on Flow can batch multiple EVM
calls atomically via a `CadenceOwnedAccount` (COA), reverting every EVM side-effect if any call
fails. The repo pairs a Solidity `MaybeMintERC721` contract (Foundry) — which randomly reverts
~50% of the time via the Cadence Arch `revertibleRandom()` precompile — with Cadence transactions,
scripts, and tests that wrap FLOW into WFLOW, approve the ERC721, and attempt a mint in one
atomic flow. Testnet deployments are listed in `README.md`; mainnet deployments are not declared.

## Build and Test Commands

Solidity (Foundry — configured via `foundry.toml` with paths rooted at `solidity/`):

- `forge build --sizes` — compile Solidity contracts (CI step)
- `forge test -vvv` — run Foundry tests in `solidity/test/` (CI step)
- `forge fmt --check` — verify Solidity formatting (CI step, `FOUNDRY_PROFILE=ci`)
- `forge install` / `git submodule update --init --recursive` — hydrate submodules in
  `solidity/lib/` (`openzeppelin-contracts`, `forge-std`, `flow-sol-utils`)

Cadence (Flow CLI — configured via `flow.json`):

- `flow test cadence/tests/wrap_and_mint_tests.cdc` — run the Cadence test suite
- `flow emulator` — start the local emulator (network defined in `flow.json`)
- `flow project deploy --network emulator` — deploy `NonFungibleToken`, `MetadataViews`, and
  `FungibleTokenMetadataViews` to the emulator account (only deployment block in `flow.json`)

No Makefile, `package.json`, or custom scripts are present — invoke `forge` and `flow` directly.

## Architecture

```
cadence/
  transactions/
    bundled/wrap_and_mint.cdc         # single atomic tx: wrap FLOW -> approve -> mint
    stepwise/                         # same flow split into 5 txs: 0_create_coa, 1_fund_coa,
                                      #   2_wrap_flow, 3_approve, 4_mint
  scripts/                            # read-only queries: get_evm_address, get_evm_balance,
                                      #   balance_of, allowance, token_uri
  tests/
    wrap_and_mint_tests.cdc           # end-to-end test of the bundled transaction
    test_helpers.cdc                  # WFLOW + ERC721 compiled bytecode constants + helpers
    transactions/                     # test-only txs: create_coa, deploy, move_block

solidity/
  src/
    MaybeMintERC721.sol               # ERC721 paid in ERC20, ~50% random revert via Cadence Arch
    test/ExampleERC20.sol             # local ERC20 used only in Foundry tests
  test/MaybeMintERC721.t.sol          # Foundry tests; mock cadenceArch precompile via vm.mockCall
  script/                             # (declared in foundry.toml; no scripts currently committed)
  lib/                                # git submodules: openzeppelin-contracts, forge-std,
                                      #   flow-sol-utils
  metadata/                           # off-chain ERC721 image + metadata JSON

flow.json                             # Cadence dependencies + emulator deployment targets
foundry.toml                          # Foundry paths rooted at ./solidity
remappings.txt                        # Solidity import remappings (OZ, forge-std, flow-sol-utils)
```

On testnet the bundled transaction targets the `MaybeMintERC721` and `WFLOW` addresses listed
in `README.md`; locally the Cadence tests deploy both contracts from the bytecode constants
embedded in `cadence/tests/test_helpers.cdc`.

## Conventions and Gotchas

- Contract name is `MaybeMintERC721` — verify spelling when referencing it from Cadence
  transactions, tests, or docs.
- `MaybeMintERC721.mint()` reverts ~50% of the time via
  `CadenceArchUtils._revertibleRandom()` (see `solidity/src/MaybeMintERC721.sol:82`). Cadence
  tests loop with `wrapAndMintUntilSuccess` and `moveBlock` between retries because the
  Cadence Arch precompile cannot currently be mocked in Cadence tests. Foundry tests use
  `vm.mockCall` against `0x0000000000000000000000010000000000000001`.
- The bundled `wrap_and_mint.cdc` requires `auth(EVM.Call)` on the COA reference and expects
  a COA at `/storage/evm` (created lazily in `prepare` if missing); the stepwise path assumes
  `0_create_coa.cdc` ran first.
- Gas limit used for every `coa.call` / `coa.deploy` in this repo is `15_000_000`; mint cost
  is hardcoded to `1.0 FLOW` in both the bundled transaction and the tests.
- Solidity pragma is `0.8.24` in `MaybeMintERC721.sol`; `ExampleERC20.sol` uses `^0.8.17`.
- CI (`.github/workflows/foundry_tests.yml`) enforces `forge fmt --check` — run `forge fmt`
  before committing Solidity changes or CI will fail.
- `flow.json` declares emulator-only deployments (`NonFungibleToken`, `MetadataViews`,
  `FungibleTokenMetadataViews`); do not add testnet/mainnet deployment blocks without
  confirming with maintainers — testnet contract addresses are tracked in `README.md`, not
  `flow.json`.
- Git commit style (`CONTRIBUTING.md`): imperative mood, present tense, first line ≤ 72 chars.
- License is The Unlicense (`LICENSE`) — contributions are public domain.

## Files Not to Modify

- `solidity/lib/**` — git submodules (OpenZeppelin, forge-std, flow-sol-utils); update via
  `git submodule update` instead of editing in place.
- `cadence/tests/test_helpers.cdc` bytecode constants (`wflowBytecode`, `erc721Bytecode`) —
  regenerate from the Solidity sources via `forge build` and re-embed if contracts change;
  do not hand-edit.
- `solidity/out/`, `solidity/cache/`, `coverage.json`, `coverage.lcov`, `imports/` — generated
  artifacts (see `.gitignore`).
