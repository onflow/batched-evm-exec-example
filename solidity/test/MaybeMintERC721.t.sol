pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MaybeMintERC721} from "../src/MaybeMintERC721.sol";
import {ExampleERC20} from "../src/test/ExampleERC20.sol";

contract MaybeMintERC721Test is Test {
    // Contracts
    MaybeMintERC721 private erc721;
    ExampleERC20 private erc20;

    // MaybeMintERC721 parameters
    address payable beneficiary = payable(address(100));
    uint256 internal mintCost = 1 ether;
    string internal name = "Maybe Mint ERC721 Test";
    string internal symbol = "MAYBE";

    // Test values
    address payable internal user = payable(address(101));

    function setUp() public virtual {
        vm.deal(user, 10 ether);

        erc20 = new ExampleERC20();
        erc721 = new MaybeMintERC721(name, symbol, address(erc20), mintCost, beneficiary);
    }

    function test_mint() public {
        erc20.mint(user, mintCost); // mint ERC20 to user

        vm.prank(user);
        erc20.approve(address(erc721), mintCost); // approve the ERC20 to be spent by MaybeMintERC721

        vm.prank(user);
        erc721.mint(); // mint ERC721 to user

        assertEq(erc721.ownerOf(1), user); // user should own the ERC721 token
    }
}
