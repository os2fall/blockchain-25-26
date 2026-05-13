// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// GameItemMarket.sol
// Prototype NFT marketplace for in-game item trading.
// NOTE: Integration with actual game backends is OUT OF SCOPE for this lab.
// Item ownership here is on-chain only; game-side sync requires a separate
// oracle/bridge layer not covered by this prototype.

contract GameItemMarket {

    struct Item {
        uint256 id;
        string  name;
        string  itemType;   // e.g. "Sword", "Armor", "Mount"
        string  rarity;     // e.g. "Common", "Rare", "Legendary"
        address owner;
        uint256 price;      // in wei; 0 = not for sale
        bool    forSale;
    }

    uint256 private _nextId = 1;

    mapping(uint256 => Item) public items;
    uint256[] public allItemIds;

    event ItemMinted(uint256 indexed id, string name, address indexed owner);
    event ItemListed(uint256 indexed id, uint256 price);
    event ItemSold(uint256 indexed id, address indexed from, address indexed to, uint256 price);
    event ItemDelisted(uint256 indexed id);

    // ---------------------------------------------------------
    // Mint (create) a new item.
    // In a real system this would be restricted to a game server key.
    // ---------------------------------------------------------
    function mintItem(
        string calldata name,
        string calldata itemType,
        string calldata rarity
    ) external returns (uint256) {
        uint256 id = _nextId++;
        items[id] = Item(id, name, itemType, rarity, msg.sender, 0, false);
        allItemIds.push(id);
        emit ItemMinted(id, name, msg.sender);
        return id;
    }

    // ---------------------------------------------------------
    // List an owned item for sale.
    // ---------------------------------------------------------
    function listItem(uint256 id, uint256 price) external {
        require(items[id].owner == msg.sender, "Not owner");
        require(price > 0, "Price must be > 0");
        items[id].price   = price;
        items[id].forSale = true;
        emit ItemListed(id, price);
    }

    // ---------------------------------------------------------
    // Buy a listed item.
    // ---------------------------------------------------------
    function buyItem(uint256 id) external payable {
        Item storage item = items[id];
        require(item.forSale, "Not for sale");
        require(msg.value >= item.price, "Insufficient payment");
        require(item.owner != msg.sender, "Cannot buy own item");

        address seller = item.owner;
        item.owner   = msg.sender;
        item.forSale = false;
        item.price   = 0;

        // Transfer funds to seller
        (bool sent, ) = payable(seller).call{value: msg.value}("");
        require(sent, "Transfer failed");

        emit ItemSold(id, seller, msg.sender, msg.value);
    }

    // ---------------------------------------------------------
    // Delist an item (cancel sale).
    // ---------------------------------------------------------
    function delistItem(uint256 id) external {
        require(items[id].owner == msg.sender, "Not owner");
        items[id].forSale = false;
        items[id].price   = 0;
        emit ItemDelisted(id);
    }

    // ---------------------------------------------------------
    // Read helpers
    // ---------------------------------------------------------
    function getItem(uint256 id) external view returns (Item memory) {
        return items[id];
    }

    function totalItems() external view returns (uint256) {
        return allItemIds.length;
    }
}
