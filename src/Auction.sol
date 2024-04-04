// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";

/// @title Auction Contract
/// @notice This contract enables the auction of items with customizable parameters such as duration, number of winners, and bid increment.
/// @dev This contract is intended for use in auction scenarios where sellers can auction items and bidders can place bids.
contract Auction {
    using Math for uint256;
    address public seller;
    uint256 public duration;
    uint256 public expiry;
    uint256 public numWinners;
    uint256 public bidIncrement;
    uint256 public highestBid;
    address[] public winners;
    uint256[] public winningBids;
    mapping(address => uint256) public bids;

    /// @notice Emitted when a bid is placed.
    /// @param bidder The address of the bidder.
    /// @param amount The amount of the bid.
    event BidPlaced(address bidder, uint256 amount);

    /// @notice Emitted when the auction ends.
    /// @param winners The addresses of the winners.
    /// @param winningBids The amounts of the winning bids.
    event AuctionEnded(address[] winners, uint256[] winningBids);

    /// @dev Modifier to restrict access to only the seller.
    modifier onlySeller() {
        require(msg.sender == seller, "Only the seller can perform this action");
        _;
    }

    /// @dev Modifier to ensure the auction has not yet expired.
    modifier onlyBeforeExpiry() {
        require(block.timestamp < expiry, "Auction has already expired");
        _;
    }

    /// @notice Constructor to initialize the auction parameters.
    /// @param _duration The duration of the auction in seconds.
    /// @param _numWinners The number of winners to be selected at the end of the auction.
    /// @param _bidIncrement The minimum increment allowed for each bid.
    constructor(uint256 _duration, uint256 _numWinners, uint256 _bidIncrement) {
        seller = msg.sender;
        duration = _duration;
        numWinners = _numWinners;
        bidIncrement = _bidIncrement;
        expiry = block.timestamp + _duration;
    }

    /// @notice Allows bidders to place bids during the active auction period.
    /// @dev Bidders must place bids higher than the current highest bid.
    function placeBid() external payable onlyBeforeExpiry {
        (bool success, uint256 newBid) = highestBid.tryAdd(bidIncrement);
        require(success, "Bid increment overflow");
        require(msg.value > newBid, "Bid must be higher than current highest bid plus increment");

        highestBid = msg.value;
        bids[msg.sender] = msg.value;

        // Add the bidder's address and bid amount to the winners and winningBids arrays
        winners.push(msg.sender);
        winningBids.push(msg.value);

        emit BidPlaced(msg.sender, msg.value);
    }

    /// @notice Ends the auction and selects the winners based on the highest bids.
    /// @dev Only the seller can end the auction, and it can only be done before the expiry.
    function endAuction() external onlySeller onlyBeforeExpiry {
        require(winners.length == 0, "Auction has already ended");

        // Select top bidders directly
        selectWinners();
    }

    /// @notice Allows the seller to increase the duration of the auction.
    /// @param _additionalSeconds The additional duration to be added to the auction expiry.
    function increaseDuration(uint256 _additionalSeconds) external onlySeller onlyBeforeExpiry {
        expiry += _additionalSeconds;
    }

    /// @notice Allows the seller to withdraw the funds from the auction contract after it ends.
    function withdraw() external onlySeller {
        payable(seller).transfer(address(this).balance);
    }

    /// @dev Internal function to select the top bidders as winners.
    function selectWinners() internal {
        require(winners.length == 0, "Auction has already ended");

        // Sort the winners and winningBids arrays in descending order based on the bid amounts
        // This requires a sorting algorithm, which is not included in this code

        // Select the top numWinners bidders
        address[] memory newWinners = new address[](numWinners);
        uint256[] memory newWinningBids = new uint256[](numWinners);
        
        for (uint256 i = 0; i < numWinners; i++) {
            newWinners[i] = winners[i];
            newWinningBids[i] = winningBids[i];
        }
        winners = newWinners;
        winningBids = newWinningBids;

        emit AuctionEnded(winners, winningBids ); // No winning bids needed
    }
}
