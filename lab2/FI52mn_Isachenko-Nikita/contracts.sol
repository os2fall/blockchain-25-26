// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdfundingErc20 {
    struct Campaign {
        address creator;
        IERC20 token;
        uint256 goal;
        uint256 pledged;
        uint256 deadline;
        bool claimed;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount;

    mapping(uint256 => mapping(address => uint256)) public pledges;

    // Під час створення кампанії вказуємо адресу токена
    function createCampaign(IERC20 _token, uint256 _goal, uint256 _durationInDays) external {
        campaignCount++;
        campaigns[campaignCount] = Campaign({
            creator: msg.sender, // payable вже не потрібен
            token: _token,
            goal: _goal,
            pledged: 0,
            deadline: block.timestamp + (_durationInDays * 1 days),
            claimed: false
        });
    }

    function pledge(uint256 _campaignId, uint256 _amount) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(_amount > 0, "Pledge must be greater than 0");

        campaign.pledged += _amount;
        pledges[_campaignId][msg.sender] += _amount;

        // Переказуємо ERC20 токени від інвестора на цей контракт
        // Користувач має спершу викликати функцію approve() у смарт-контракті самого токена!
        require(
            campaign.token.transferFrom(msg.sender, address(this), _amount),
            "Transfer from failed"
        );
    }

    function claimFunds(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.sender == campaign.creator, "Not the creator");
        require(block.timestamp >= campaign.deadline, "Campaign not ended yet");
        require(campaign.pledged >= campaign.goal, "Goal not reached");
        require(!campaign.claimed, "Funds already claimed");

        campaign.claimed = true;

        // Відправляємо зібрані токени творцю кампанії
        require(
            campaign.token.transfer(campaign.creator, campaign.pledged),
            "Transfer failed"
        );
    }

    function refund(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign not ended yet");
        require(campaign.pledged < campaign.goal, "Goal was reached");

        uint256 amount = pledges[_campaignId][msg.sender];
        require(amount > 0, "No funds to refund");

        // Спочатку обнуляємо баланс (захист від Reentrancy)
        pledges[_campaignId][msg.sender] = 0;

        require(
            campaign.token.transfer(msg.sender, amount),
            "Refund failed"
        );
    }
}


contract CrowdfundingNative {
    struct Campaign {
        address payable creator;
        uint256 goal;
        uint256 pledged;
        uint256 deadline;
        bool claimed;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount;

    mapping(uint256 => mapping(address => uint256)) public pledges;

    function createCampaign(uint256 _goal, uint256 _durationInDays) external {
        campaignCount++;
        campaigns[campaignCount] = Campaign({
            creator: payable(msg.sender),
            goal: _goal,
            pledged: 0,
            deadline: block.timestamp + (_durationInDays * 1 days),
            claimed: false
        });
    }

    function pledge(uint256 _campaignId) external payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(msg.value > 0, "Pledge must be greater than 0");

        campaign.pledged += msg.value;
        pledges[_campaignId][msg.sender] += msg.value;
    }

    function claimFunds(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.sender == campaign.creator, "Not the creator");
        require(block.timestamp >= campaign.deadline, "Campaign not ended yet");
        require(campaign.pledged >= campaign.goal, "Goal not reached");
        require(!campaign.claimed, "Funds already claimed");

        campaign.claimed = true;
        campaign.creator.transfer(campaign.pledged);
    }

    function refund(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign not ended yet");
        require(campaign.pledged < campaign.goal, "Goal was reached");

        uint256 amount = pledges[_campaignId][msg.sender];
        require(amount > 0, "No funds to refund");

        pledges[_campaignId][msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
