// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IHahaRepo {
    struct Haha {
        string question;
        string answer;
    }

    function storeHaha(string memory q, string memory a) external;

    function batchStoreHahas(
        string[] memory questions,
        string[] memory answers
    ) external;

    function getHaha(uint256 index) external returns (Haha memory haha);
}
