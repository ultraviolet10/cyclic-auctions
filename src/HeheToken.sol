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

    uint8 public MINT_LIMIT = 50;

    using SafeMath for uint256;

    uint8 public currentHeheId; // make private
    IHahaRepo private hahaRepo; // make private

    event CreatedHeheToken(uint8 indexed tokenId);

    constructor(
        string memory _name,
        string memory _symbol,
        IHahaRepo _hahaRepo
    ) ERC721(_name, _symbol) {
        hahaRepo = _hahaRepo;
        currentHeheId = 0;
    }

    function createHehe(address to) external returns (uint8) {
        if (currentHeheId > MINT_LIMIT) revert MintLimitExceeded();

        // get Haha from repo
        IHahaRepo.Haha memory haha = hahaRepo.getHaha(currentHeheId);

        // store current token ID in new var
        uint8 currentId = currentHeheId;
        super._safeMint(to, currentId);
        string memory uri = NFTDescriptor.constructTokenURI(
            NFTDescriptor.URIParams({
                tokenId: currentHeheId,
                blockNumber: block.number,
                tokenOwner: msg.sender,
                punchline: haha.question,
                hook: haha.answer
            })
        );
        _setTokenURI(currentId, uri);
        emit CreatedHeheToken(currentHeheId);
        currentHeheId++;

        return (currentId);
    }
}
