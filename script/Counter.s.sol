// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Auction Contract
/// @notice This contract enables the auction of items with customizable parameters such as duration, number of winners, and bid increment.
/// @dev This contract is intended for use in auction scenarios where sellers can auction items and bidders can place bids.
contract Auction {
    address public seller;
    uint256 public duration;
    uint256 public expiry;
    uint256 public numWinners;
    uint256 public highestBid;
    address[] public winners;
    mapping(address => uint256) public bids;
    mapping(uint256 => address[]) public tiedBidders;

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
    constructor(uint256 _duration, uint256 _numWinners) {
        seller = msg.sender;
        duration = _duration;
        numWinners = _numWinners;
        expiry = block.timestamp + _duration;
    }

    /// @notice Allows bidders to place bids during the active auction period.
    /// @dev Bidders must place bids higher than the current highest bid.
    function placeBid() external payable onlyBeforeExpiry {
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        highestBid = msg.value;
        bids[msg.sender] = msg.value;
        emit BidPlaced(msg.sender, msg.value);
    }

    /// @notice Ends the auction and selects the winners based on the highest bids.
    /// @dev Only the seller can end the auction, and it can only be done before the expiry.
    function endAuction() external onlySeller onlyBeforeExpiry {
        require(winners.length == 0, "Auction has already ended");

        // Select winners and handle ties
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

    /// @dev Internal function to select winners and handle ties.
    function selectWinners() internal {
        // Sort bidders by highest bids
        address[] memory sortedBidders = new address[](numWinners);
        uint256[] memory sortedBids = new uint256[](numWinners);

        uint256[] memory bidValues = new uint256[](numWinners);
        for (uint256 i = 0; i < numWinners; i++) {
            bidValues[i] = 0;
        }

        for (uint256 i = 0; i < winners.length; i++) {
            address bidder = winners[i];
            uint256 bidAmount = bids[bidder];

            // Insertion sort
            uint256 j = i;
            while (j > 0 && bidAmount > bidValues[j - 1]) {
                bidValues[j] = bidValues[j - 1];
                sortedBidders[j] = sortedBidders[j - 1];
                j--;
            }

            bidValues[j] = bidAmount;
            sortedBidders[j] = bidder;
        }

        winners = sortedBidders;
        emit AuctionEnded(winners, sortedBids);
    }
}
