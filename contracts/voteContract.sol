// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2; // This will generate a cautionary warning.


//import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v3.4.0/contracts/access/Ownable.sol";


contract VoteApp  {
    address payable public owner; // owner of the contract
    address payable public winner; // winner
    uint256 public contributionAmount; // contribution required to vote
    uint256 public numberOfDays; // duration of the voting
    uint256 public numberOfSeconds; // duration in seconds
    uint256 public raisedAmount; // the sum of all contributions
    uint256 public deadline; //the end of the voting

    // Contributors and Candidates
    struct Contributor {
        uint256 hasVoted; // one user can vote only once, true=1, false=0
    }

    struct Candidate {
        address payable candidate; // candidate
        uint256 isRegistered; // candidate is registered true=1, false=0
        uint256 amountCollected; // the amount of funds collected
    }

    mapping(address => Contributor) public contributors;
    mapping(address => Candidate) public candidates;

    constructor() {
        owner = msg.sender;
        numberOfSeconds = numberOfDays * 1 days;
        deadline = block.timestamp + numberOfSeconds;
        contributionAmount = 10000000000000000 wei;
    }

    // Array with candidates
    Candidate[] public allCandidates;

    // Workflow
    enum WorkflowStatus {
        CandidateRegistration,
        VotingSessionStarted,
        VotingSessionEnded,
        RewardWiring
    }

    // Events
    WorkflowStatus currentStatus = WorkflowStatus.CandidateRegistration;

    event VotingSessionStarted();
    event Contributed (address contibutor, address candidate);
    event FundsWired(address winner, address owner);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);


    // Modifiers
    modifier onlyOwner() {
        require(
            msg.sender == owner, "Only owner can use this function"
        );
        _;
    }

    modifier notVoted(address _address) {
        require(contributors[_address].hasVoted == 0,
            "One user can only vote once!"
        );
        _;
    }

    modifier isNotExpired() {
        require(
            block.timestamp < deadline,
            "Voting has ended."
        );
        _;
    }

    modifier isExpired() {
        require(
            block.timestamp >= deadline,
            "Voting is still online"
        );
        _;
    }

    modifier candidateExists(address _address) {
        require(
            candidates[_address].isRegistered == 1,
            "This candidate does not exist"
        );
        _;
    }

    modifier hasStatus(WorkflowStatus status) {
        require(keccak256(abi.encodePacked(currentStatus)) == keccak256(abi.encodePacked(status)), "You cannot do this, invalid workflow status");
        _;
    }


    // create vote
    function startVoting(address[] memory _candidates) public onlyOwner hasStatus(WorkflowStatus.CandidateRegistration) {
        emit VotingSessionStarted();
        emit WorkflowStatusChange(WorkflowStatus.CandidateRegistration, WorkflowStatus.VotingSessionStarted);

        currentStatus = WorkflowStatus.VotingSessionStarted;
        for (uint i=0; i < _candidates.length; i++) {
            allCandidates.push(Candidate(payable(_candidates[i]), 1, 0));
        }
    }

    //Contibute
    function contribute(address _candidate) public payable isNotExpired notVoted(msg.sender) hasStatus(WorkflowStatus.VotingSessionStarted) {

        require(
            msg.value >= contributionAmount,
            "0.01 eth is required to contribute."
        );

        contributors[msg.sender].hasVoted = 1; // voted
        raisedAmount += contributionAmount; // increase the entire amount raised
        candidates[_candidate].amountCollected += contributionAmount; //increase the candidate's amount
        emit Contributed(msg.sender, _candidate);
    }

    // stop vote
    function endVoting() public payable isExpired hasStatus(WorkflowStatus.VotingSessionStarted) {
        currentStatus = WorkflowStatus.VotingSessionEnded;

        //find winner
        uint winningAmount = 0;
        for (uint i = 0; i < allCandidates.length; i++) {
            if (allCandidates[i].amountCollected > winningAmount) {
                winningAmount = allCandidates[i].amountCollected;
                winner = allCandidates[i].candidate;
            }
        }

        //send 90% of the amount raised to the winner wallet
        uint256 winnerPrize = raisedAmount * 9 / 10 ;
        winner.transfer(winnerPrize);

        //send 10% of the amount raised to the admin wallet
        uint256 adminPrize = raisedAmount / 10;
        owner.transfer(adminPrize);

        emit FundsWired(winner, owner);
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.RewardWiring);
    }
}