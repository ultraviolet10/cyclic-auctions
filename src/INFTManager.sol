// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../lib/contracts/contracts/token/ERC721/IERC721.sol";

interface INFTManager is IERC721 {
    function burn(uint256 tokenId) external;

    function mint() external;
}
