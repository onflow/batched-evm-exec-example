pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {CadenceArchUtils} from "flow-sol-utils/cadence-arch/CadenceArchUtils.sol";

/**
 * @title MaybeMintERC721
 * @dev Mint ERC721 tokens for a fee in ERC20 tokens. As this simple token is intended for
 *      demonstration of batched EVM calls on Flow EVM using a single Cadence transaction, the
 *      minting process is random and has some chance of failure.
 */
contract MaybeMintERC721 is ERC721, Ownable {
    IERC20 public denomination;
    uint256 public mintCost;
    address public beneficiary;
    uint256 public totalSupply;
    string private uri;

    error RandomRevert();
    error InsufficientAllowance(address denomination, address sender, uint256 needed);

    constructor(
        string memory _name,
        string memory _symbol,
        address _erc20,
        uint256 _mintCost,
        address _beneficiary,
        string memory _uri
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        denomination = IERC20(_erc20);
        mintCost = _mintCost;
        beneficiary = _beneficiary;
        uri = _uri;
        totalSupply = 0;
    }

    /**
     * @dev Mint a new ERC721 token to the caller with some chance of failure. This is for
     *      demonstration purposes, intended to showcase how a single Cadence transaction can batch
     *      multiple EVM calls and condition final execution based on the result of any individual
     *      EVM call.
     *
     *      NOTE: This contract address must be approved to transfer mintCost amount from the caller
     *      to the beneficiary before minting the ERC721 to pay for mint
     */
    function mint() external {
        // Randomly fail mint with 50% chance of reverting
        _maybeMint();
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (_ownerOf(tokenId) == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return uri;
    }

    /**
     * @dev Mint a new ERC721 token to the caller with some chance of failure.
     *      NOTE: Production systems using random minting should leverage a commit-reveal scheme
     *      to ensure that the random minting transaction cannot be reverted on random result.
     */
    function _maybeMint() internal {
        _splitChanceRevert(); // randomly revert with 50% chance

        // take payment for mint
        try denomination.transferFrom(msg.sender, beneficiary, mintCost) {
            totalSupply++; // increment the total supply
            _mint(msg.sender, totalSupply); // mint the token, assigning the next tokenId
                // TODO: Set token URI
        } catch {
            revert InsufficientAllowance(address(denomination), msg.sender, mintCost);
        }
    }

    /**
     * @dev Randomly revert with 50% chance
     */
    function _splitChanceRevert() internal view {
        uint64 random = CadenceArchUtils._revertibleRandom();
        if (random % 2 == 1) {
            revert RandomRevert();
        }
    }
}
