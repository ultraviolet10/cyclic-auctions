// SPDX-License-Identifier: MIT
///@notice Inspired by Uniswap-v3-periphery NFTSVG.sol
pragma solidity ^0.8.4;
pragma abicoder v2;

import "../lib/contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/contracts/contracts/utils/Strings.sol";
import "../lib/contracts/contracts/utils/math/SafeMath.sol";
import "../lib/contracts/contracts/utils/math/SignedSafeMath.sol";
import "./HexStrings.sol";

library NFTSVG {
    using Strings for uint256;

    struct SVGParams {
        uint256 tokenId;
        uint256 blockNumber;
        string punchline;
        string hook;
        string color0;
        string color1;
    }

    function generateSVG(
        SVGParams memory params
    ) internal pure returns (string memory svg) {
        return
            string(
                abi.encodePacked(
                    generateSVGDefs(params),
                    generateSVGFigures(params),
                    "</svg>"
                )
            );
    }

    function generateSVGDefs(
        SVGParams memory params
    ) private pure returns (string memory svg) {
        svg = string(
            abi.encodePacked(
                '<svg width="1130.667" height="1306.667" viewBox="0 0 648 680" fill="none" xmlns="http://www.w3.org/2000/svg">',
                "<defs>",
                '<linearGradient id="g1" x1="0%" y1="50%" >',
                generateSVGColorPartOne(params),
                generateSVGColorPartTwo(params),
                "</linearGradient></defs>"
            )
        );
    }

    function generateSVGColorPartOne(
        SVGParams memory params
    ) private pure returns (string memory svg) {
        string memory values0 = string(
            abi.encodePacked("#", params.color0, "; #", params.color1)
        );
        string memory values1 = string(
            abi.encodePacked("#", params.color1, "; #", params.color0)
        );
        svg = string(
            abi.encodePacked(
                '<stop offset="0%" stop-color="#',
                params.color0,
                '" >',
                '<animate id="a1" attributeName="stop-color" values="',
                values0,
                '" begin="0; a2.end" dur="3s" />',
                '<animate id="a2" attributeName="stop-color" values="',
                values1,
                '" begin="a1.end" dur="3s" /></stop>'
            )
        );
    }

    function generateSVGColorPartTwo(
        SVGParams memory params
    ) private pure returns (string memory svg) {
        string memory values0 = string(
            abi.encodePacked("#", params.color0, "; #", params.color1)
        );
        string memory values1 = string(
            abi.encodePacked("#", params.color1, "; #", params.color0)
        );
        svg = string(
            abi.encodePacked(
                '<stop offset="100%" stop-color="#',
                params.color1,
                '" >',
                '<animate id="a3" attributeName="stop-color" values="',
                values1,
                '" begin="0; a4.end" dur="3s" />',
                '<animate id="a4" attributeName="stop-color" values="',
                values0,
                '" begin="a3.end" dur="3s" /></stop>'
            )
        );
    }

    function generateSVGText(
        SVGParams memory params
    ) private pure returns (string memory svg) {
        svg = string(
            abi.encodePacked(
                '<g fill="black" font-family="Verdana" font-size="17"><text x="15" y="60" >HeheToken #',
                Strings.toString(params.tokenId),
                '</text><text x="15" y="90">',
                params.punchline,
                '</text><text x="15" y="120">',
                params.hook,
                "</text></g>"
            )
        );
    }

    function generateSVGFigures(
        SVGParams memory params
    ) private pure returns (string memory svg) {
        svg = string(
            abi.encodePacked(
                '<rect id="r" x="0" y="0" rx="15" ry="15" width="100%" height="100%" fill="url(#g1)" />',
                generateSVGText(params),
                '<g fill="#000000" fill-opacity="0.4" stroke="none">',
                '<path d="M260.4 1.1c-4.7 1.3-11.1 8.3-14.8 16.3-9.2 19.3-11 45.2-8.1 112.1 1.7 39.2 1.6 61.2-.5 68.5-.9 3.2-2 4-13.2 9.7-17.8 9-27.8 14.9-49.8 29.3-10.7 7-27.6 17.1-37.5 22.5-40.7 22.1-50.3 32.3-63.8 68-6.7 17.7-7.7 19.8-16.7 35-52.8 89.9-68.9 199-44.5 301.2C46.3 809 163.3 926.4 312.3 965.5c55.7 14.6 113 18.1 170.9 10.4 77.6-10.3 149.7-41.1 211.9-90.6 16.5-13.1 50.2-46.6 63.1-62.8 68.9-86.1 99.4-191.3 86.8-300-8.9-77.5-37.6-155.3-77.6-210.2-8.6-11.8-11.3-18-14.8-33.7-3.3-14.8-3.4-16.7-.3-26.4 16.5-51.3 20.5-104.7 12.6-164.7-2.6-19.5-4.1-25.1-9.5-36-8.3-16.9-13.3-21.5-23.1-21.5-17.2.1-36.7 16.8-102.9 88-42.7 45.9-51.8 54.4-64.3 60.3-6.2 2.9-6.5 3-18 2.4-14.8-.8-24.5-2.6-51.1-9.2-42.3-10.6-59.2-13-84.6-11.9l-14.9.7-5.8-5.3c-7.6-7-11-12-14.6-22-7.2-19.6-33.4-61.9-57.1-92.2-8.3-10.6-26-28.5-32.5-32.9-10.1-6.8-18.6-9-26.1-6.8zM275.8 22c7.3 4.9 22 20.1 32.8 34.1 21.3 27.4 44.6 65.5 51.8 84.7 5.4 14.7 17.2 28.9 28.6 34.4 4.3 2.1 5.8 2.2 30 2.3 28.8.1 29.8.2 69 10 35.3 8.8 42.1 9.9 61 10 15.9 0 16.7-.1 22.2-2.7 3.2-1.5 8.4-4.4 11.5-6.5 8.1-5.3 31.3-28.2 59.7-58.8 51-55.2 74.8-77.5 86.7-81.7 3.6-1.2 4-.8 9.9 10.3 4.8 9.2 6.2 15.1 9.2 37.4 3 23.1 3.3 70.9.5 91-3.1 22-10.3 52.7-16.2 69.4-1.1 3.1-1 5.3.1 13.2 3.4 23.1 9.2 38.5 19.8 52.8 36.9 49.8 64.2 121.1 74 193.6 4.1 29.9 4.5 69.8 1.1 98.5-12.4 104.3-68.1 200.2-154.1 265.2-52.4 39.5-115.3 66.5-179.9 77.2-27.6 4.5-35.4 5.1-70.5 5.1-29.1-.1-35.7-.4-50.5-2.4-88.4-11.8-163.9-46.7-228.2-105.1-68.7-62.6-112.4-147.6-124-241-2.5-20.3-2.5-67.5 0-88 7.1-57.9 24.2-108.7 52.3-156.1 7.5-12.7 9.7-17.3 16.5-35.2 12.1-32 18.7-38.8 58.3-60.1 9.8-5.3 26.3-15.2 36.5-22 21.3-14.1 29.7-19.1 49.4-29 12.7-6.4 14.4-7.5 16.9-11.6 4.8-7.7 6-16.6 6-42-.1-12.4-.6-31.1-1.1-41.5-1.4-25-1.4-65.7 0-77 2.3-18.9 7.5-32.5 12.3-32.5 1.3 0 5.1 1.8 8.4 4zm-98.5 324c-2.4 1.2-6.7 4.8-9.7 8-10.2 11-15.8 24.1-15.9 37.1-.1 6.5.4 8.5 2.8 13.4 5.2 10.2 20.1 21.4 30.8 23.2 11.6 1.9 27.8-14.9 36.8-38.1 6.1-15.8 4.8-23.9-5.5-34.2-7.6-7.6-14.4-10.4-26.6-11.1-7.3-.4-9.1-.1-12.7 1.7zm4.7 11.8c0 3.7-1.7 5.2-5.6 5.2h-3.2l-.7 8.8c-1.2 14.9 2 29.7 8.5 40.4 1.7 2.8 2.8 5.3 2.5 5.6-1.1 1.1-7.5-3.1-11.6-7.6-2.3-2.4-5.3-6.9-6.7-10-2.3-4.9-2.7-7-2.7-15.2 0-8.4.3-10.1 2.8-14.8 3.4-6.6 11.2-14.6 13.3-13.8.9.3 1.2.1.9-.4-.3-.6.1-1 .9-1 1.1 0 1.6.9 1.6 2.8zm35.9 9.3c1.3 2.4 1.3 2.9-.2 5.3-3.3 4.9-9.7 2.8-9.7-3.3 0-5.3 7.2-6.7 9.9-2zm209.6 23.2c-11.4 4.3-23.6 13.9-34 27-12.1 15.2-19.9 33.9-17.5 42.6 1.3 5.1 3.1 6.4 12.2 9.5 4.2 1.4 11.6 4.8 16.4 7.5 11.1 6.4 18.5 8.8 30.6 10.1 15.3 1.6 26.5-1.6 40.1-11.4 8.1-5.7 24.9-23.2 31.5-32.5l5.2-7.3-3.3-4.6c-5-7.1-20.3-22.7-27.6-28.2-8.5-6.4-18.3-11.6-25.7-13.5-8.6-2.2-20.6-1.9-27.9.8zm20 18.1c2 1.3 2.5 2.4 2.5 6.1 0 2.6-.6 5-1.6 5.9-1.9 1.9-3.5 1.2-10.8-4.6-2.9-2.3-5.8-3.8-7-3.6-2.8.4-6.2 7.4-8.2 16.9-1.9 8.4-2.4 33.6-1 43.6.6 4.1.5 6.3-.1 6.3-1 0-11.4-7.1-17.7-12.1-4.3-3.4-5.7-7.9-5.7-17.7.1-18.6 8.4-36.1 19.6-41.4 3.4-1.6 5.7-1.8 15.7-1.5 8.7.3 12.4.8 14.3 2.1zm-302 96.7c-24.5 3.3-42 12.8-47.7 25.7-2.5 5.7-3.5 16.6-1.9 21.4 1.2 3.8 8.5 11.8 19 21.1l6.4 5.7h-3.7c-5.5 0-9.6 4.3-9.6 10.3 0 9.1 10.2 23.6 21.1 29.9 8.7 5 14.1 6.1 26.8 5.5 17.6-.9 32.6-4.2 36.2-7.8 1-1 1.9-3 1.9-4.4 0-3.3-3.3-9.8-7.6-15.1l-3.4-4.2 5.8 3.2c5.1 2.8 6.6 3.1 14.2 3.1 7.5 0 9.3-.4 15.2-3.2 16.9-8 27.9-25.7 26.6-42.8-1.7-20.6-21.9-38-53.6-46.1-11.1-2.9-33.5-4-45.7-2.3zM133.4 667c-11.4 1.7-20 6.1-25.7 13.2-2.3 2.9-3.1 5.1-3.5 9.1-1.2 14.4 12.4 24.1 45.5 32.7 8.8 2.3 15.8 3.3 32.5 4.5 11.7.8 26.4 2.2 32.6 3 27.8 3.7 80 3.7 109.2-.1 24.7-3.1 45.1-9.9 53.9-17.9 4.5-4.1 8.1-10.1 8.1-13.5 0-2-.4-2.1-5.7-1.5-28.2 3.1-57.9 7.7-90.7 14.1-17.6 3.4-18 3.4-24 1.9-3.4-.9-11.3-4.4-17.6-7.9-14.8-8.2-15.3-8.4-41.8-16.6-14.7-4.6-24.4-8.2-28.1-10.5-14.3-8.6-31.1-12.6-44.7-10.5z"/>',
                "</g>"
            )
        );
    }

    function generateSVGRareMark(
        uint256 tokenId,
        string memory tokenAddress
    ) private pure returns (string memory svg) {
        if (isRare(tokenId, tokenAddress)) {
            svg = string(
                abi.encodePacked(
                    '<rect x="16" y="16" width="258" height="468" rx="26" ry="26" fill="black" />'
                )
            );
        } else {
            svg = "";
        }
    }

    function isRare(
        uint256 tokenId,
        string memory tokenAddress
    ) internal pure returns (bool) {
        // return uint256(keccak256(abi.encodePacked(tokenId, tokenAddress))) < type(uint256).max / 10;
        return false;
    }
}
