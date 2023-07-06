// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.17;

contract DigitalCitizenDAOEvents {
    /// @notice An event emitted when a new proposal is created
    event ProposalCreated(
        uint256 id,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );

    /// @notice An event emitted when a new proposal is created, which includes additional information
    event ProposalCreatedWithRequirements(
        uint256 id,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        uint256 proposalThreshold,
        uint256 quorumVotes,
        string description
    );

    /// @notice An event emitted when a vote has been cast on a proposal
    /// @param voter The address which casted a vote
    /// @param proposalId The proposal id which was voted on
    /// @param support Support value for the vote. 0=against, 1=for, 2=abstain
    /// @param votes Number of votes which were cast by the voter
    /// @param reason The reason given for the vote by the voter
    event VoteCast(
        address indexed voter,
        uint256 proposalId,
        uint8 support,
        uint256 votes,
        string reason
    );

    /// @notice An event emitted when a proposal has been canceled
    event ProposalCanceled(uint256 id);

    /// @notice An event emitted when a proposal has been queued in the DigitalCitizenDAOExecutor
    event ProposalQueued(uint256 id, uint256 eta);

    /// @notice An event emitted when a proposal has been executed in the DigitalCitizenDAOExecutor
    event ProposalExecuted(uint256 id);

    /// @notice An event emitted when a proposal has been vetoed by vetoAddress
    event ProposalVetoed(uint256 id);

    /// @notice An event emitted when the voting delay is set
    event VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay);

    /// @notice An event emitted when the voting period is set
    event VotingPeriodSet(uint256 oldVotingPeriod, uint256 newVotingPeriod);

    /// @notice Emitted when implementation is changed
    event NewImplementation(
        address oldImplementation,
        address newImplementation
    );

    /// @notice Emitted when proposal threshold basis points is set
    event ProposalThresholdBPSSet(
        uint256 oldProposalThresholdBPS,
        uint256 newProposalThresholdBPS
    );

    /// @notice Emitted when quorum votes basis points is set
    event QuorumVotesBPSSet(
        uint256 oldQuorumVotesBPS,
        uint256 newQuorumVotesBPS
    );

    /// @notice Emitted when pendingAdmin is changed
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /// @notice Emitted when pendingAdmin is accepted, which means admin is updated
    event NewAdmin(address oldAdmin, address newAdmin);

    /// @notice Emitted when vetoer is changed
    event NewVetoer(address oldVetoer, address newVetoer);
}

contract DigitalCitizenDAOEventsV2 is DigitalCitizenDAOEvents {
    /// @notice Emitted when minQuorumVotesBPS is set
    event MinQuorumVotesBPSSet(
        uint16 oldMinQuorumVotesBPS,
        uint16 newMinQuorumVotesBPS
    );

    /// @notice Emitted when maxQuorumVotesBPS is set
    event MaxQuorumVotesBPSSet(
        uint16 oldMaxQuorumVotesBPS,
        uint16 newMaxQuorumVotesBPS
    );

    /// @notice Emitted when quorumCoefficient is set
    event QuorumCoefficientSet(
        uint32 oldQuorumCoefficient,
        uint32 newQuorumCoefficient
    );

    /// @notice Emitted when a voter cast a vote requesting a gas refund.
    event RefundableVote(
        address indexed voter,
        uint256 refundAmount,
        bool refundSent
    );

    /// @notice Emitted when admin withdraws the DAO's balance.
    event Withdraw(uint256 amount, bool sent);

    /// @notice Emitted when pendingVetoer is changed
    event NewPendingVetoer(address oldPendingVetoer, address newPendingVetoer);
}

contract DigitalCitizenDAOProxyStorage {
    /// @notice Administrator for this contract
    address public admin;

    /// @notice Pending administrator for this contract
    address public pendingAdmin;

    /// @notice Active brains of Governor
    address public implementation;
}

/**
 * @title Storage for Governor Bravo Delegate
 * @notice For future upgrades, do not change DigitalCitizenDAOStorageV1. Create a new
 * contract which implements DigitalCitizenDAOStorageV1 and following the naming convention
 * DigitalCitizenDAOStorageVX.
 */
contract DigitalCitizenDAOStorageV1 is DigitalCitizenDAOProxyStorage {
    /// @notice Vetoer who has the ability to veto any proposal
    address public vetoer;

    /// @notice The delay before voting on a proposal may take place, once proposed, in blocks
    uint256 public votingDelay;

    /// @notice The duration of voting on a proposal, in blocks
    uint256 public votingPeriod;

    /// @notice The basis point number of votes required in order for a voter to become a proposer. *DIFFERS from GovernerBravo
    uint256 public proposalThresholdBPS;

    /// @notice The basis point number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed. *DIFFERS from GovernerBravo
    uint256 public quorumVotesBPS;

    /// @notice The total number of proposals
    uint256 public proposalCount;

    /// @notice The address of the DigitalCitizen DAO Executor DigitalCitizenDAOExecutor
    IDigitalCitizenDAOExecutor public timelock;

    /// @notice The address of the DigitalCitizen tokens
    DigitalCitizenTokenLike public DigitalCitizen;

    /// @notice The official record of all proposals ever proposed
    mapping(uint256 => Proposal) public proposals;

    /// @notice The latest proposal for each proposer
    mapping(address => uint256) public latestProposalIds;

    struct Proposal {
        /// @notice Unique id for looking up a proposal
        uint256 id;
        /// @notice Creator of the proposal
        address proposer;
        /// @notice The number of votes needed to create a proposal at the time of proposal creation. *DIFFERS from GovernerBravo
        uint256 proposalThreshold;
        /// @notice The number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed at the time of proposal creation. *DIFFERS from GovernerBravo
        uint256 quorumVotes;
        /// @notice The timestamp that the proposal will be available for execution, set once the vote succeeds
        uint256 eta;
        /// @notice the ordered list of target addresses for calls to be made
        address[] targets;
        /// @notice The ordered list of values (i.e. msg.value) to be passed to the calls to be made
        uint256[] values;
        /// @notice The ordered list of function signatures to be called
        string[] signatures;
        /// @notice The ordered list of calldata to be passed to each call
        bytes[] calldatas;
        /// @notice The block at which voting begins: holders must delegate their votes prior to this block
        uint256 startBlock;
        /// @notice The block at which voting ends: votes must be cast prior to this block
        uint256 endBlock;
        /// @notice Current number of votes in favor of this proposal
        uint256 forVotes;
        /// @notice Current number of votes in opposition to this proposal
        uint256 againstVotes;
        /// @notice Current number of votes for abstaining for this proposal
        uint256 abstainVotes;
        /// @notice Flag marking whether the proposal has been canceled
        bool canceled;
        /// @notice Flag marking whether the proposal has been vetoed
        bool vetoed;
        /// @notice Flag marking whether the proposal has been executed
        bool executed;
        /// @notice Receipts of ballots for the entire set of voters
        mapping(address => Receipt) receipts;
    }

    /// @notice Ballot receipt record for a voter
    struct Receipt {
        /// @notice Whether or not a vote has been cast
        bool hasVoted;
        /// @notice Whether or not the voter supports the proposal or abstains
        uint8 support;
        /// @notice The number of votes the voter had, which were cast
        uint96 votes;
    }

    /// @notice Possible states that a proposal may be in
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed,
        Vetoed
    }
}

/**
 * @title Extra fields added to the `Proposal` struct from DigitalCitizenDAOStorageV1
 * @notice The following fields were added to the `Proposal` struct:
 * - `Proposal.totalSupply`
 * - `Proposal.creationBlock`
 */
contract DigitalCitizenDAOStorageV1Adjusted is DigitalCitizenDAOProxyStorage {
    /// @notice Vetoer who has the ability to veto any proposal
    address public vetoer;

    /// @notice The delay before voting on a proposal may take place, once proposed, in blocks
    uint256 public votingDelay;

    /// @notice The duration of voting on a proposal, in blocks
    uint256 public votingPeriod;

    /// @notice The basis point number of votes required in order for a voter to become a proposer. *DIFFERS from GovernerBravo
    uint256 public proposalThresholdBPS;

    /// @notice The basis point number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed. *DIFFERS from GovernerBravo
    uint256 public quorumVotesBPS;

    /// @notice The total number of proposals
    uint256 public proposalCount;

    /// @notice The address of the DigitalCitizen DAO Executor DigitalCitizenDAOExecutor
    IDigitalCitizenDAOExecutor public timelock;

    /// @notice The address of the DigitalCitizen tokens
    DigitalCitizenTokenLike public DigitalCitizen;

    /// @notice The official record of all proposals ever proposed
    mapping(uint256 => Proposal) internal _proposals;

    /// @notice The latest proposal for each proposer
    mapping(address => uint256) public latestProposalIds;

    struct Proposal {
        /// @notice Unique id for looking up a proposal
        uint256 id;
        /// @notice Creator of the proposal
        address proposer;
        /// @notice The number of votes needed to create a proposal at the time of proposal creation. *DIFFERS from GovernerBravo
        uint256 proposalThreshold;
        /// @notice The number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed at the time of proposal creation. *DIFFERS from GovernerBravo
        uint256 quorumVotes;
        /// @notice The timestamp that the proposal will be available for execution, set once the vote succeeds
        uint256 eta;
        /// @notice the ordered list of target addresses for calls to be made
        address[] targets;
        /// @notice The ordered list of values (i.e. msg.value) to be passed to the calls to be made
        uint256[] values;
        /// @notice The ordered list of function signatures to be called
        string[] signatures;
        /// @notice The ordered list of calldata to be passed to each call
        bytes[] calldatas;
        /// @notice The block at which voting begins: holders must delegate their votes prior to this block
        uint256 startBlock;
        /// @notice The block at which voting ends: votes must be cast prior to this block
        uint256 endBlock;
        /// @notice Current number of votes in favor of this proposal
        uint256 forVotes;
        /// @notice Current number of votes in opposition to this proposal
        uint256 againstVotes;
        /// @notice Current number of votes for abstaining for this proposal
        uint256 abstainVotes;
        /// @notice Flag marking whether the proposal has been canceled
        bool canceled;
        /// @notice Flag marking whether the proposal has been vetoed
        bool vetoed;
        /// @notice Flag marking whether the proposal has been executed
        bool executed;
        /// @notice Receipts of ballots for the entire set of voters
        mapping(address => Receipt) receipts;
        /// @notice The total supply at the time of proposal creation
        uint256 totalSupply;
        /// @notice The block at which this proposal was created
        uint256 creationBlock;
    }

    /// @notice Ballot receipt record for a voter
    struct Receipt {
        /// @notice Whether or not a vote has been cast
        bool hasVoted;
        /// @notice Whether or not the voter supports the proposal or abstains
        uint8 support;
        /// @notice The number of votes the voter had, which were cast
        uint96 votes;
    }

    /// @notice Possible states that a proposal may be in
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed,
        Vetoed
    }
}

/**
 * @title Storage for Governor Bravo Delegate
 * @notice For future upgrades, do not change DigitalCitizenDAOStorageV2. Create a new
 * contract which implements DigitalCitizenDAOStorageV2 and following the naming convention
 * DigitalCitizenDAOStorageVX.
 */
contract DigitalCitizenDAOStorageV2 is DigitalCitizenDAOStorageV1Adjusted {
    DynamicQuorumParamsCheckpoint[] public quorumParamsCheckpoints;

    /// @notice Pending new vetoer
    address public pendingVetoer;

    struct DynamicQuorumParams {
        /// @notice The minimum basis point number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed.
        uint16 minQuorumVotesBPS;
        /// @notice The maximum basis point number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed.
        uint16 maxQuorumVotesBPS;
        /// @notice The dynamic quorum coefficient
        /// @dev Assumed to be fixed point integer with 6 decimals, i.e 0.2 is represented as 0.2 * 1e6 = 200000
        uint32 quorumCoefficient;
    }

    /// @notice A checkpoint for storing dynamic quorum params from a given block
    struct DynamicQuorumParamsCheckpoint {
        /// @notice The block at which the new values were set
        uint32 fromBlock;
        /// @notice The parameter values of this checkpoint
        DynamicQuorumParams params;
    }

    struct ProposalCondensed {
        /// @notice Unique id for looking up a proposal
        uint256 id;
        /// @notice Creator of the proposal
        address proposer;
        /// @notice The number of votes needed to create a proposal at the time of proposal creation. *DIFFERS from GovernerBravo
        uint256 proposalThreshold;
        /// @notice The minimum number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed at the time of proposal creation. *DIFFERS from GovernerBravo
        uint256 quorumVotes;
        /// @notice The timestamp that the proposal will be available for execution, set once the vote succeeds
        uint256 eta;
        /// @notice The block at which voting begins: holders must delegate their votes prior to this block
        uint256 startBlock;
        /// @notice The block at which voting ends: votes must be cast prior to this block
        uint256 endBlock;
        /// @notice Current number of votes in favor of this proposal
        uint256 forVotes;
        /// @notice Current number of votes in opposition to this proposal
        uint256 againstVotes;
        /// @notice Current number of votes for abstaining for this proposal
        uint256 abstainVotes;
        /// @notice Flag marking whether the proposal has been canceled
        bool canceled;
        /// @notice Flag marking whether the proposal has been vetoed
        bool vetoed;
        /// @notice Flag marking whether the proposal has been executed
        bool executed;
        /// @notice The total supply at the time of proposal creation
        uint256 totalSupply;
        /// @notice The block at which this proposal was created
        uint256 creationBlock;
    }
}

interface IDigitalCitizenDAOExecutor {
    function delay() external view returns (uint256);

    function GRACE_PERIOD() external view returns (uint256);

    function acceptAdmin() external;

    function queuedTransactions(bytes32 hash) external view returns (bool);

    function queueTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external returns (bytes32);

    function cancelTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external;

    function executeTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external payable returns (bytes memory);
}

interface DigitalCitizenTokenLike {
    function getPriorVotes(
        address account,
        uint256 blockNumber
    ) external view returns (uint96);

    function totalSupply() external view returns (uint256);
}
