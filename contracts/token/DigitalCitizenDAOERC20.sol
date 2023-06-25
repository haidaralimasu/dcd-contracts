// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IDigitalCitizenDAOERC20} from "../interfaces/IDigitalCitizenDAOERC20.sol";

contract DigitalCitizenDAOERC20 is ERC20, Ownable, IDigitalCitizenDAOERC20 {
    uint256 public initialSupply = 400000000 ether;
    address public treasury;

    mapping(address => bool) public isGetFees;
    mapping(address => bool) public isExcludedFromFees;

    uint256 public feeOnBuy = 5;
    uint256 public feeOnSell = 5;

    constructor(address _treasury) ERC20("Digital Citizen DAO", "DCD") {
        treasury = _treasury;

        isExcludedFromFees[address(this)] = true;
        isExcludedFromFees[address(0xdead)] = true;
        isExcludedFromFees[owner()] = true;

        _mint(owner(), initialSupply);
    }

    /*
    PUBLIC FUNCTIONS
    */

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 _totalFees;

        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
            _totalFees = 0;
        } else if (isGetFees[from]) {
            _totalFees = feeOnBuy;
        } else if (isGetFees[to]) {
            _totalFees = feeOnBuy;
        }

        if (_totalFees > 0) {
            uint256 fees = (amount * _totalFees) / 100;
            amount = amount - fees;
            super._transfer(from, treasury, fees);
        }

        super._transfer(from, to, amount);
    }

    /*
    ONLY OWNER FUNCTIONS
    */

    function updateTreasury(address _newTreasury) external override onlyOwner {
        address oldTreasury = treasury;
        treasury = _newTreasury;

        emit TreasuryUpdated(oldTreasury, _newTreasury);
    }

    function updateInitialSupply(
        uint256 _newInitialSupply
    ) external override onlyOwner {
        uint256 oldInitialSupply = initialSupply;
        initialSupply = initialSupply + _newInitialSupply;
        _mint(treasury, _newInitialSupply);

        emit InitialSupplyUpdated(oldInitialSupply, _newInitialSupply);
    }

    function setGetFee(
        address _getFeeAddress,
        bool _isGetFee
    ) external override onlyOwner {
        _setGetFees(_getFeeAddress, _isGetFee);
    }

    function setMultipleGetFees(
        address[] memory _getFeeAddresses,
        bool _isGetFee
    ) external override onlyOwner {
        for (uint256 i = 0; i < _getFeeAddresses.length; i++) {
            _setGetFees(_getFeeAddresses[i], _isGetFee);
        }
    }

    function setExcludeFromFee(
        address _account,
        bool _isExcluded
    ) external override onlyOwner {
        _setExcludedFromFees(_account, _isExcluded);
    }

    function setMultipleExcludeFromFees(
        address[] memory _accounts,
        bool _isExcluded
    ) external onlyOwner {
        for (uint256 i = 0; i < _accounts.length; i++) {
            _setExcludedFromFees(_accounts[i], _isExcluded);
        }
    }

    function updateFee(
        uint256 _onBuy,
        uint256 _onSell
    ) external override onlyOwner {
        uint256 oldFeeOnBuy = feeOnBuy;
        uint256 oldFeeOnSell = feeOnSell;

        feeOnBuy = _onBuy;
        feeOnSell = _onSell;

        emit FeeOnBuyUpdated(oldFeeOnBuy, _onBuy);
        emit FeeOnSellUpdated(oldFeeOnSell, _onSell);
    }

    /*
    INTERNAL FUNCTIONS
    */

    function _currentTime() internal view returns (uint256 currentTime) {
        currentTime = block.timestamp;
    }

    function _setGetFees(address _getFeeAddress, bool _isGetFee) internal {
        isGetFees[_getFeeAddress] = _isGetFee;
        emit GetFeeSetted(_getFeeAddress, _isGetFee);
    }

    function _setExcludedFromFees(address _account, bool _isExcluded) internal {
        isExcludedFromFees[_account] = _isExcluded;
        emit ExcldedFromFeesSetted(_account, _isExcluded);
    }
}
