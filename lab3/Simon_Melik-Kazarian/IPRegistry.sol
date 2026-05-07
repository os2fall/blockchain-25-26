// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IPRegistry {
    struct Record {
        address owner;
        uint256 timestamp;
        bool exists;
    }

    mapping(string => Record) private registry;

    function registerContent(string memory _fileHash) public {
        require(!registry[_fileHash].exists, "Security Alert: Content already registered!");
        
        registry[_fileHash] = Record({
            owner: msg.sender,
            timestamp: block.timestamp,
            exists: true
        });
    }

    function verifyContent(string memory _fileHash) public view returns (address, uint256) {
        require(registry[_fileHash].exists, "Content not found in registry!");
        return (registry[_fileHash].owner, registry[_fileHash].timestamp);
    }
}