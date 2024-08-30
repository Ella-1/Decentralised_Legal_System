// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
// import Integration with Skate: The above smart contracts should be integrated with Skate’s infrastructure, especially the Legal Identity Manager (Kernel Contract), to utilize Skate's message box and economic security features.
contract LegalIdentityManager is Ownable {
    using Counters for Counters.Counter;

    struct UserIdentity {
        uint256 id;
        address userAddress;
        string legalIdentityHash; // A hash representing the user's legal identity
        uint256 reputationScore;  // Reputation score based on interactions and dispute outcomes
        bool isVerified;          // Verification status of the user's identity
    }

    Counters.Counter private _userIdCounter;
    mapping(address => UserIdentity) public userIdentities;
    mapping(uint256 => address) public userIds;

    event IdentityRegistered(address indexed user, uint256 id, string legalIdentityHash);
    event IdentityVerified(address indexed user);
    event ReputationUpdated(address indexed user, uint256 reputationScore);

    // Function to register a new user identity
    function registerIdentity(string memory _legalIdentityHash) external {
        require(bytes(_legalIdentityHash).length > 0, "Identity hash cannot be empty");
        require(userIdentities[msg.sender].userAddress == address(0), "User already registered");

        _userIdCounter.increment();
        uint256 newUserId = _userIdCounter.current();

        userIdentities[msg.sender] = UserIdentity({
            id: newUserId,
            userAddress: msg.sender,
            legalIdentityHash: _legalIdentityHash,
            reputationScore: 1000,  // Initial reputation score
            isVerified: false
        });

        userIds[newUserId] = msg.sender;

        emit IdentityRegistered(msg.sender, newUserId, _legalIdentityHash);
    }

    // Function to verify a user's identity (only owner can call this function)
    function verifyIdentity(address _userAddress) external onlyOwner {
        require(userIdentities[_userAddress].userAddress != address(0), "User not registered");
        userIdentities[_userAddress].isVerified = true;

        emit IdentityVerified(_userAddress);
    }

    // Function to update a user's reputation score (can be called by arbitration contract)
    function updateReputation(address _userAddress, uint256 _newReputationScore) external onlyOwner {
        require(userIdentities[_userAddress].userAddress != address(0), "User not registered");
        userIdentities[_userAddress].reputationScore = _newReputationScore;

        emit ReputationUpdated(_userAddress, _newReputationScore);
    }

    // Function to get user identity information
    function getUserIdentity(address _userAddress) external view returns (UserIdentity memory) {
        return userIdentities[_userAddress];
    }
}
