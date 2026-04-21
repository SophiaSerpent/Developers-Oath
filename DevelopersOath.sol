// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title The Developers Oath (Autonomous)
 * @author _beautifulDATA
 * @notice Perpetual, ownerless terminal sustained by USDC on Base.
 */
contract DevelopersOath is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // --- State Variables ---
    IERC20 public immutable usdc;
    uint256 public constant CYCLE_DURATION = 90 days;
    uint256 public constant MINIMUM_VOW = 1e6; // $1.00 USDC (6 decimals)

    uint256 public totalPool;
    uint256 public lastReset;
    uint256 public currentCycleId;

    struct Dev {
        uint256 balance;
        uint256 cycleId;
    }

    mapping(address => Dev) public registry;
    mapping(uint256 => uint256) public historicalTotalPools;

    // --- Events ---
    event VowSustained(address indexed dev, string name, uint256 amount, uint256 cycle);
    event RolloverTriggered(uint256 indexed completedCycle, uint256 totalAmount);

    constructor(address _usdc) {
        usdc = IERC20(_usdc);
        lastReset = block.timestamp;
        currentCycleId = 1;
    }

    /**
     * @notice Sustain the terminal. Triggers rollover if 90 days have passed.
     * @param _name The handle for the Mural.
     * @param _amount Amount of USDC to contribute.
     */
    function sustain(string calldata _name, uint256 _amount) external nonReentrant {
        if (block.timestamp >= lastReset + CYCLE_DURATION) {
            _executeRollover();
        }

        require(_amount >= MINIMUM_VOW, "Integrity has a $1 minimum.");
        usdc.safeTransferFrom(msg.sender, address(this), _amount);

        // Reset balance if developer is joining a new cycle
        if (registry[msg.sender].cycleId < currentCycleId) {
            registry[msg.sender].balance = 0;
            registry[msg.sender].cycleId = currentCycleId;
        }

        registry[msg.sender].balance += _amount;
        totalPool += _amount;

        emit VowSustained(msg.sender, _name, _amount, currentCycleId);
    }

    /**
     * @dev Internal function to finalize a cycle.
     */
    function _executeRollover() private {
        historicalTotalPools[currentCycleId] = totalPool;
        emit RolloverTriggered(currentCycleId, totalPool);

        totalPool = 0;
        lastReset = block.timestamp;
        currentCycleId++;
    }

    /**
     * @notice Pull-based withdrawal. Users claim their share of the cycle pool.
     * @dev Logic assumes interest/redistribution is 1:1 for this MVP.
     */
    function claim(uint256 _cycleId) external nonReentrant {
        require(_cycleId < currentCycleId, "Cycle still in progress.");
        require(registry[msg.sender].cycleId == _cycleId, "No record in cycle.");
        
        uint256 share = registry[msg.sender].balance;
        require(share > 0, "Already claimed or zero balance.");

        registry[msg.sender].balance = 0;
        usdc.safeTransfer(msg.sender, share);
    }
}
