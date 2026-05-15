// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DocumentRegistryUnoptimized {
    struct Document {
        uint256 timestamp;
        string author;
        string documentHash;
        bool isVerified;
    }

    mapping(uint256 => Document) public documents;
    uint256 public docCount;

    function addDocument(string memory _hash, string memory _author) public {
        docCount++;
        documents[docCount] = Document(block.timestamp, _author, _hash, false);
    }
}