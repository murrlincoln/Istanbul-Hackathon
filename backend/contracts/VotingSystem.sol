pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    function setFeeTo(address _feeTo) external;
}

contract VotingSystem {
    struct Proposal {
        uint256 startTime;
        uint256 endTime;
        uint256 voteThreshold;
        uint256 category;
        uint256 associatedNumber;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        bool executed;
        address targetAddress; // Target address for specific proposals
        mapping(address => bool) voted;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public nextProposalId;

    mapping(address => bool) public worldIdVerified;
    mapping(address => uint256) public firstDepositTime;
    mapping(address => address) public delegate;

    IUniswapV2Factory public uniswapFactory;

    event ProposalCreated(uint256 indexed proposalId, uint256 startTime, uint256 endTime, uint256 voteThreshold, uint256 category, uint256 associatedNumber, address targetAddress);
    event Voted(uint256 indexed proposalId, address indexed voter, bool vote, uint256 votingPower, string voteType);
    event Delegated(address indexed delegatee, address indexed representative);

    constructor(address _uniswapFactory) {
        uniswapFactory = IUniswapV2Factory(_uniswapFactory);
    }

    function createProposal(uint256 _startTime, uint256 _endTime, uint256 _voteThreshold, uint256 _category, uint256 _associatedNumber, address _targetAddress) external {
        require(_endTime > _startTime, "End time must be greater than start time");

        Proposal storage proposal = proposals[nextProposalId];
        proposal.startTime = _startTime;
        proposal.endTime = _endTime;
        proposal.voteThreshold = _voteThreshold;
        proposal.category = _category;
        proposal.associatedNumber = _associatedNumber;
        proposal.executed = false;
        proposal.targetAddress = _targetAddress;

        emit ProposalCreated(nextProposalId, _startTime, _endTime, _voteThreshold, _category, _associatedNumber, _targetAddress);
        nextProposalId++;
    }

    function vote(uint256 _proposalId, bool _vote, bool _abstain) external {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime, "Voting is not active");
        require(worldIdVerified[msg.sender], "User not authenticated");

        address voter = msg.sender;
        if (delegate[msg.sender] != address(0)) {
            voter = delegate[msg.sender];
        }

        require(!proposal.voted[voter], "Already voted");

        uint256 votingPower = calculateVotingPower(voter);

        if (_abstain) {
            proposal.votesAbstain += votingPower;
            emit Voted(_proposalId, voter, false, votingPower, "Abstain");
        } else if (_vote) {
            proposal.votesFor += votingPower;
            emit Voted(_proposalId, voter, true, votingPower, "For");
        } else {
            proposal.votesAgainst += votingPower;
            emit Voted(_proposalId, voter, false, votingPower, "Against");
        }

        proposal.voted[voter] = true;
    }

    function delegateVote(address _delegatee) external {
        require(worldIdVerified[msg.sender], "User not authenticated");
        require(_delegatee != msg.sender, "Cannot delegate to self");

        delegate[msg.sender] = _delegatee;
        emit Delegated(msg.sender, _delegatee);
    }

    function undelegateVote() external {
        require(delegate[msg.sender] != address(0), "No delegation set");

        emit Delegated(msg.sender, address(0));
        delegate[msg.sender] = address(0);
    }

    function calculateVotingPower(address _voter) public view returns (uint256) {
        uint256 depositTime = firstDepositTime[_voter];
        require(depositTime != 0, "No deposit history");

        uint256 daysSinceFirstDeposit = (block.timestamp - depositTime) / 60 / 60 / 24;
        return daysSinceFirstDeposit;
    }

    function executeProposal(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.endTime, "Voting is not ended");
        require(!proposal.executed, "Proposal already executed");
        require(proposal.votesFor > proposal.voteThreshold, "Threshold not met");

        if (proposal.category == 1) {
           
            uniswapFactory.setFeeTo(proposal.targetAddress);
        }

        proposal.executed = true;
    }
}