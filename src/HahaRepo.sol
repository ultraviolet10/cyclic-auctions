// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./IHahaRepo.sol";

contract HahaRepo is IHahaRepo {
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    Haha[] public hahas;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function storeHaha(string memory q, string memory a) public onlyOwner {
        hahas.push(Haha(q, a));
    }

    function batchStoreHahas(
        string[] memory questions,
        string[] memory answers
    ) public onlyOwner {
        require(
            questions.length == answers.length,
            "No matches, we need full jokes."
        );
        for (uint256 i = 0; i < questions.length; i++) {
            hahas.push(Haha(questions[i], answers[i]));
        }
    }

    function getHaha(uint256 _index) external view returns (Haha memory haha) {
        return hahas[_index];
    }
}
