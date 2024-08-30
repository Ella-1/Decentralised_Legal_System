// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Arbitration is Ownable {
    enum DisputeStatus { Pending, Resolved, Appealed }
    
    struct Dispute {
        uint256 id;
        address plaintiff;
        address defendant;
        string evidenceHash;    // Hash of the evidence provided for the dispute
        DisputeStatus status;   // Current status of the dispute
        address[] jurors;       // List of jurors assigned to this dispute
        mapping(address => bool) hasVoted; // Tracks juror votes
        uint256 votesForPlaintiff; // Count of votes in favor of the plaintiff
        uint256 votesForDefendant; // Count of votes in favor of the defendant
        address winner;         // Address of the winner of the dispute
    }

    uint256 public disputeCount;
    mapping(uint256 => Dispute) public disputes;
    mapping(address => uint256[]) public userDisputes;

    event DisputeSubmitted(uint256 indexed disputeId, address plaintiff, address defendant, string evidenceHash);
    event JurorSelected(uint256 indexed disputeId, address juror);
    event VoteCast(uint256 indexed disputeId, address juror, bool voteForPlaintiff);
    event DisputeResolved(uint256 indexed disputeId, address winner);

    // Function to submit a new dispute
    function submitDispute(address _defendant, string memory _evidenceHash) external {
        disputeCount++;
        Dispute storage newDispute = disputes[disputeCount];
        newDispute.id = disputeCount;
        newDispute.plaintiff = msg.sender;
        newDispute.defendant = _defendant;
        newDispute.evidenceHash = _evidenceHash;
        newDispute.status = DisputeStatus.Pending;

        userDisputes[msg.sender].push(disputeCount);
        userDisputes[_defendant].push(disputeCount);

        emit DisputeSubmitted(disputeCount, msg.sender, _defendant, _evidenceHash);
    }

    // Function to select jurors for a dispute
    function selectJurors(uint256 _disputeId, address[] memory _jurors) external onlyOwner {
        require(disputes[_disputeId].status == DisputeStatus.Pending, "Dispute not in pending state");

        disputes[_disputeId].jurors = _jurors;

        for (uint256 i = 0; i < _jurors.length; i++) {
            emit JurorSelected(_disputeId, _jurors[i]);
        }
    }

    // Function for jurors to cast a vote
    function castVote(uint256 _disputeId, bool _voteForPlaintiff) external {
        Dispute storage dispute = disputes[_disputeId];
        require(dispute.status == DisputeStatus.Pending, "Dispute not in pending state");
        require(!dispute.hasVoted[msg.sender], "Juror has already voted");

        dispute.hasVoted[msg.sender] = true;
        if (_voteForPlaintiff) {
            dispute.votesForPlaintiff++;
        } else {
            dispute.votesForDefendant++;
        }

        emit VoteCast(_disputeId, msg.sender, _voteForPlaintiff);
    }

    // Function to resolve a dispute and declare a winner
    function resolveDispute(uint256 _disputeId) external onlyOwner {
        Dispute storage dispute = disputes[_disputeId];
        require(dispute.status == DisputeStatus.Pending, "Dispute not in pending state");

        dispute.status = DisputeStatus.Resolved;
        if (dispute.votesForPlaintiff > dispute.votesForDefendant) {
            dispute.winner = dispute.plaintiff;
        } else {
            dispute.winner = dispute.defendant;
        }

        emit DisputeResolved(_disputeId, dispute.winner);
    }
}
