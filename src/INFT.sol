// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../lib/contracts/contracts/token/ERC721/IERC721.sol";

interface INFT is IERC721 {
    function create(
        address to,
        string memory punchline,
        string memory hook,
        uint256 tokenId
    ) external;
}
