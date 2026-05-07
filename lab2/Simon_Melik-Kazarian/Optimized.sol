// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DocumentRegistryOptimized {
    struct Document {
        bytes32 documentHash;
        uint64 timestamp;
        bool isVerified;
    }

    mapping(uint256 => Document) public documents;
    uint256 public docCount;

    function addDocument(bytes32 _hash) public {
        docCount++;
        documents[docCount] = Document(_hash, uint64(block.timestamp), false);
    }
}