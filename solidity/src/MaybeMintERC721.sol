pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MaybeMintERC721
 * @dev Mint ERC721 tokens for a fee in ERC20 tokens
 */
contract MaybeMintERC721 is ERC721, Ownable {
    IERC20 public denomination;
    uint256 public mintCost;
    address beneficiary;
    uint256 public totalSupply;

    event MintCostUpdated(uint256 newCost);
    event BeneficiaryUpdated(address indexed newBeneficiary);
    event DenominationUpdated(address indexed newDenomination);

    constructor(string memory _name, string memory _symbol, address _erc20, uint256 _mintCost, address _beneficiary)
        ERC721(_name, _symbol)
        Ownable(msg.sender)
    {
        denomination = IERC20(_erc20);
        mintCost = _mintCost;
        beneficiary = _beneficiary;
        totalSupply = 0;

        emit MintCostUpdated(_mintCost);
        emit BeneficiaryUpdated(_beneficiary);
        emit DenominationUpdated(_erc20);
    }

    /**
     * @dev Mint a new ERC721 token to the caller. This contract must be approved to transfer mintCost amount from the caller
     *      before minting the ERC721 to pay for mint
     */
    function mint() external {
        // TODO: Get a random number to determine if the mint is successful
        totalSupply++; // increment the total supply
        denomination.transferFrom(msg.sender, beneficiary, mintCost); // take payment for mint
        _mint(msg.sender, totalSupply); // mint the token, assigning the next tokenId
    }

    /**
     * @dev Set the cost to mint a new ERC721 token
     * @param _mintCost The new cost to mint a token in the denomination ERC20 token
     */
    function setMintCost(uint256 _mintCost) external onlyOwner {
        mintCost = _mintCost;
        emit MintCostUpdated(_mintCost);
    }

    /**
     * @dev Set the ERC20 token to use as the denomination
     * @param _denomination The address of the ERC20 token to use as the denomination
     */
    function setDenomination(address _denomination) external onlyOwner {
        require(_denomination != address(0), "Denomination cannot be the zero address");

        denomination = IERC20(_denomination);
        emit DenominationUpdated(_denomination);
    }

    /**
     * @dev Set the address to receive the minting fees
     * @param _beneficiary The address to receive the minting fees
     */
    function setBeneficiary(address _beneficiary) external onlyOwner {
        beneficiary = _beneficiary;
        emit BeneficiaryUpdated(_beneficiary);
    }
}
