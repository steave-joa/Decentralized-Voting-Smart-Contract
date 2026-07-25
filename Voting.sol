// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Voting {

    // ------------------------------------------------------------
    // Structs
    // ------------------------------------------------------------

    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    // ------------------------------------------------------------
    // Enums
    // ------------------------------------------------------------

    enum VotingStatus {
        NotStarted,
        Ongoing,
        Ended
    }

    // ------------------------------------------------------------
    // State Variables
    // ------------------------------------------------------------

    address public immutable admin;

    VotingStatus public votingStatus;

    uint256 public candidatesCount;

    // Candidate ID => Candidate details
    mapping(uint256 => Candidate) public candidates;

    // Voter address => Whether the voter has already voted
    mapping(address => bool) public hasVoted;

    // Voter address => Whether the voter is registered
    mapping(address => bool) public registeredVoters;

    // ------------------------------------------------------------
    // Events
    // ------------------------------------------------------------

    event VoterRegistered(address indexed voter);

    event CandidateAdded(
        uint256 indexed candidateId,
        string name
    );

    event VotingStarted();

    event VotingEnded();

    event Voted(
        address indexed voter,
        uint256 indexed candidateId
    );

    // ------------------------------------------------------------
    // Modifiers
    // ------------------------------------------------------------

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "Only admin can perform this action"
        );
        _;
    }

    modifier onlyWhenVotingOngoing() {
        require(
            votingStatus == VotingStatus.Ongoing,
            "Voting is not ongoing"
        );
        _;
    }

    // ------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------

    constructor() {
        admin = msg.sender;
        votingStatus = VotingStatus.NotStarted;
    }

    // ------------------------------------------------------------
    // Admin Functions
    // ------------------------------------------------------------

    /**
     * @dev Registers an eligible voter.
     * Only the admin can register voters.
     */
    function registerVoter(address _voter) external onlyAdmin {
        require(
            _voter != address(0),
            "Invalid voter address"
        );

        require(
            !registeredVoters[_voter],
            "Voter already registered"
        );

        registeredVoters[_voter] = true;

        emit VoterRegistered(_voter);
    }

    /**
     * @dev Adds a new candidate.
     * Candidates can only be added before voting starts.
     */
    function addCandidate(
        string calldata _name
    ) external onlyAdmin {

        require(
            votingStatus == VotingStatus.NotStarted,
            "Cannot add candidate after voting starts"
        );

        require(
            bytes(_name).length > 0,
            "Candidate name cannot be empty"
        );

        candidatesCount++;

        candidates[candidatesCount] = Candidate({
            id: candidatesCount,
            name: _name,
            voteCount: 0
        });

        emit CandidateAdded(
            candidatesCount,
            _name
        );
    }

    /**
     * @dev Starts the voting process.
     */
    function startVoting() external onlyAdmin {

        require(
            votingStatus == VotingStatus.NotStarted,
            "Voting has already started or ended"
        );

        require(
            candidatesCount > 0,
            "Add at least one candidate"
        );

        votingStatus = VotingStatus.Ongoing;

        emit VotingStarted();
    }

    /**
     * @dev Ends the voting process.
     */
    function endVoting() external onlyAdmin {

        require(
            votingStatus == VotingStatus.Ongoing,
            "Voting is not ongoing"
        );

        votingStatus = VotingStatus.Ended;

        emit VotingEnded();
    }

    // ------------------------------------------------------------
    // Voting Functions
    // ------------------------------------------------------------

    /**
     * @dev Allows a registered voter to cast one vote.
     */
    function vote(
        uint256 _candidateId
    ) external onlyWhenVotingOngoing {

        require(
            registeredVoters[msg.sender],
            "Voter is not registered"
        );

        require(
            !hasVoted[msg.sender],
            "Voter has already voted"
        );

        require(
            _candidateId > 0 &&
            _candidateId <= candidatesCount,
            "Invalid candidate ID"
        );

        hasVoted[msg.sender] = true;

        candidates[_candidateId].voteCount++;

        emit Voted(
            msg.sender,
            _candidateId
        );
    }

    // ------------------------------------------------------------
    // View Functions
    // ------------------------------------------------------------

    /**
     * @dev Returns details of a specific candidate.
     */
    function getCandidate(
        uint256 _candidateId
    )
        external
        view
        returns (
            uint256 id,
            string memory name,
            uint256 voteCount
        )
    {
        require(
            _candidateId > 0 &&
            _candidateId <= candidatesCount,
            "Invalid candidate ID"
        );

        Candidate memory candidate = candidates[_candidateId];

        return (
            candidate.id,
            candidate.name,
            candidate.voteCount
        );
    }

    /**
     * @dev Returns all candidates.
     * Useful for frontend applications.
     */
    function getAllCandidates()
        external
        view
        returns (Candidate[] memory)
    {
        Candidate[] memory allCandidates =
            new Candidate[](candidatesCount);

        for (
            uint256 i = 1;
            i <= candidatesCount;
            i++
        ) {
            allCandidates[i - 1] = candidates[i];
        }

        return allCandidates;
    }

    /**
     * @dev Returns whether an address is registered as a voter.
     */
    function getRegisteredVoterStatus(
        address _voter
    )
        external
        view
        returns (bool)
    {
        return registeredVoters[_voter];
    }

    /**
     * @dev Returns the current voting status.
     */
    function getVotingStatus()
        external
        view
        returns (VotingStatus)
    {
        return votingStatus;
    }

    /**
     * @dev Returns the winner after voting has ended.
     *
     * If multiple candidates have the same highest vote count,
     * the function returns a tie.
     */
    function getWinner()
        external
        view
        returns (
            bool isTie,
            string memory winnerName,
            uint256 winnerVotes
        )
    {
        require(
            votingStatus == VotingStatus.Ended,
            "Voting has not ended"
        );

        uint256 highestVotes = 0;
        uint256 winnerCount = 0;
        string memory currentWinner;

        for (
            uint256 i = 1;
            i <= candidatesCount;
            i++
        ) {
            if (
                candidates[i].voteCount > highestVotes
            ) {
                highestVotes = candidates[i].voteCount;
                currentWinner = candidates[i].name;
                winnerCount = 1;
            }
            else if (
                candidates[i].voteCount == highestVotes &&
                highestVotes > 0
            ) {
                winnerCount++;
            }
        }

        if (winnerCount > 1) {
            return (
                true,
                "",
                highestVotes
            );
        }

        return (
            false,
            currentWinner,
            highestVotes
        );
    }
}
