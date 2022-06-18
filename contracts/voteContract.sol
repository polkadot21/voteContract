pragma solidity >=0.7.0 <0.9.0;


contract VoteContract {
    address public owner; // owner of the contract
    uint8 public minimumContribution; // minimun contribution required to vote
    uint8 public numberOfDays; // duration of the voting
    uint8 public raisedAmount; // the sum of all contribtuions
    uint8 public contributorsNumber; // the total number of contributors


    mapping(address => uint256) public contributors;
    mapping(address => uint256) public candidates;

    constructor(uint256 _target) {
        owner = msg.sender;
        duration = numberOfDays * days;
        deadline = block.timestamp + duration;
        minimumContribution = 10000000000000000 wei;
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can use this function");
        _;
    }

    modifier isNotExpired() {
        require(
            block.timestamp < deadline,
            "Voting has ended."
        );
        _;
    }

    // get balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //Contibute
    function contribute() public payable isNotExpired {
        require(
            msg.value >= minimumContribution,
            "Minimum 0.01 eth is required to contribute."
        );

        if (contributors[msg.sender] == 0) {
            contributorsNumber++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

}