// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./libs/NFTDescriptor.sol";
import "./interfaces/IHahaRepo.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract HeheToken is ERC721URIStorage, Ownable {
    struct Haha {
        string question;
        string answer;
    }

    using SafeMath for uint256;

    uint8 public tokenCounter; // make private?
    IHahaRepo private hahaRepo; // make private

    event CreatedHeheToken(uint8 indexed tokenId);

    constructor(
        string memory _name,
        string memory _symbol,
        IHahaRepo _hahaRepo
    ) ERC721(_name, _symbol) {
        hahaRepo = _hahaRepo;
        tokenCounter = 0;
    }

    function createHehe(address to) external returns (uint8) {
        IHahaRepo.Haha memory haha = hahaRepo.getHaha(tokenCounter);
        uint8 currentId = tokenCounter;
        super._safeMint(to, currentId);
        string memory uri = NFTDescriptor.constructTokenURI(
            NFTDescriptor.URIParams({
                tokenId: tokenCounter,
                blockNumber: block.number,
                tokenOwner: msg.sender,
                punchline: haha.question,
                hook: haha.answer
            })
        );
        _setTokenURI(currentId, uri);
        emit CreatedHeheToken(tokenCounter);
        tokenCounter = tokenCounter + 1;

        return (currentId);
    }
}
