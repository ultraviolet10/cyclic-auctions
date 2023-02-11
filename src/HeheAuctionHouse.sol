// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import {IHeheAuctionHouse} from "./interfaces/IHeheAuctionHouse.sol";
import {INFT} from "./interfaces/INFT.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";

contract HeheAuctionHouse is
    Pausable,
    Ownable,
    ReentrancyGuard,
    IERC721Receiver
{
    using SafeMath for uint256;

    address payable private contractOwner;
    INFT public hehe;
    uint256 currentTokenId;

    struct Auction {
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        uint256 bidAmount;
        address payable bidder;
        bool settled;
    }

    address payable artist =
        payable(0xF9AB0CC40324d0565111846beeb11BCC676D6eaC);

    mapping(uint256 => Auction) public _auctions;

    event AuctionCreated(
        uint256 indexed heheId,
        uint256 startTime,
        uint256 endTime
    );
    event AuctionBid(uint256 indexed heheId, address sender, uint256 value);
    event AuctionSettled(
        uint256 indexed heheId,
        address winner,
        uint256 amount
    );

    constructor(INFT _hehe) {
        contractOwner = payable(msg.sender);
        hehe = _hehe;

        _pause();
    }

    function unpause(uint256 _auctionId) external onlyOwner {
        require(
            msg.sender == contractOwner,
            "only owner can unpause the contract."
        );
        _unpause();

        if (
            _auctions[_auctionId].startTime == 0 ||
            _auctions[_auctionId].settled
        ) {
            startNewAuction(4 minutes);
        }
    }

    function pause() external onlyOwner {
        require(
            msg.sender == contractOwner,
            "only owner can unpause the contract."
        );
        _pause();
    }

    function startNewAuction(uint256 _duration) internal {
        // require((msg.sender == owner || ownerOf(_tokenId) == msg.sender), "Only owners.");
        // require(_auctions[_tokenId].startTime == 0, "Auction for given token ID already in progress.");

        // mint a new token and store it in the contract

        try hehe.createHehe(address(this)) returns (uint256 tokenCounter) {
            uint256 _startTime = block.timestamp;
            uint256 _endTime = block.timestamp + _duration;

            currentTokenId = tokenCounter;

            _auctions[tokenCounter] = Auction({
                tokenId: tokenCounter,
                startTime: _startTime,
                endTime: _endTime,
                bidAmount: 0,
                bidder: payable(0),
                settled: false
            });
            emit AuctionCreated(tokenCounter, _startTime, _endTime);
        } catch Error(string memory) {
            _pause();
        }
    }

    function bid(uint256 _tokenId) external payable nonReentrant {
        require(
            _auctions[_tokenId].endTime > _auctions[_tokenId].startTime,
            "Auction is not active any longer."
        );
        require(
            msg.value > _auctions[_tokenId].bidAmount,
            "Bid amount too higher than the existing bid."
        );

        if (_auctions[_tokenId].bidAmount > 0) {
            _auctions[_tokenId].bidder.transfer(_auctions[_tokenId].bidAmount);
        }
        _auctions[_tokenId].bidAmount = msg.value;
        _auctions[_tokenId].bidder = payable(msg.sender);

        emit AuctionBid(_tokenId, msg.sender, msg.value);
    }

    function settleAuction(uint256 _tokenId) internal {
        require(_auctions[_tokenId].startTime != 0, "Auction hasn't begun");
        require(
            _auctions[_tokenId].settled != true,
            "Auction already completed."
        );
        require(
            _auctions[_tokenId].endTime <= block.timestamp,
            "Auction hasn't completed."
        );

        hehe.approve(msg.sender, _tokenId);

        if (_auctions[_tokenId].bidder == address(0)) {
            _auctions[_tokenId].settled = true;
        } else {
            hehe.transferFrom(
                address(this),
                _auctions[_tokenId].bidder,
                _tokenId
            );
        }

        if (_auctions[_tokenId].bidAmount > 0) {
            contractOwner.transfer(_auctions[_tokenId].bidAmount);
        }

        _auctions[_tokenId].settled = true;

        uint256 amount = address(this).balance;
        if (amount > 0) {
            artist.transfer(amount);
        }

        emit AuctionSettled(
            _tokenId,
            _auctions[_tokenId].bidder,
            _auctions[_tokenId].bidAmount
        );
    }

    function settleCurrentAndCreateNewAuction() external nonReentrant {
        settleAuction(currentTokenId);
        startNewAuction(4 minutes);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
