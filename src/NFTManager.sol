// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma abicoder v2;

import "../lib/contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

import "./NFT.sol";
import "./NFTDescriptor.sol";
import "./INFTManager.sol";

contract NFTManager is NFT, INFTManager, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    string setup;
    string punchline;

    constructor(
        string memory _setup,
        string memory _punchline,
        IERC20 _uToken
    ) NFT("HeheToken", "HEHE") {
        setup = _setup;
        punchline = _punchline;
    }

    function mint() public virtual override(INFTManager, NFT) nonReentrant {
        _safeMint(msg.sender, tokenCounter);
        // uToken.safeTransferFrom(msg.sender, address(this), STAKE_AMOUNT);
    }

    function formatTokenURI(
        uint256 tokenId
    ) internal view virtual override returns (string memory) {
        return
            NFTDescriptor.constructTokenURI(
                NFTDescriptor.URIParams({
                    tokenId: tokenId,
                    blockNumber: block.number,
                    stakeAmount: STAKE_AMOUNT,
                    uTokenSymbol: tokenSymbol(address(uToken))
                    // uTokenAddress: address(uToken)
                })
            );
    }
}
