// SPDX-License-Identifier: MIT

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {IDCDFundsDistributor} from "./interfaces/IDCDFundsDistributor.sol";

pragma solidity ^0.8.17;

contract DCDFundsDistributor is Ownable, IDCDFundsDistributor {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public treasury;
    address public gnosisWallet;

    uint256 public gnosisWalletShare = 250; //basis points

    constructor(address treasury_, address gnosisWallet_) {
        treasury = treasury_;
        gnosisWallet = gnosisWallet_;
    }

    function distributeETH() external override {
        uint256 gnosisWalletShareETH = address(this)
            .balance
            .mul(gnosisWalletShare)
            .div(10000);
        uint256 treasuryShareETH = address(this).balance.sub(
            gnosisWalletShareETH
        );

        (bool hs, ) = payable(gnosisWallet).call{value: gnosisWalletShareETH}(
            ""
        );
        require(hs);

        (bool os, ) = payable(treasury).call{value: treasuryShareETH}("");
        require(os);

        emit ETHDistributed(gnosisWallet, gnosisWalletShareETH);
        emit ETHDistributed(treasury, treasuryShareETH);
    }

    function distributeERC20(address _tokenAddress) external override {
        IERC20 token = IERC20(_tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));

        uint256 gnosisWalletERC20Share = tokenBalance
            .mul(gnosisWalletShare)
            .div(10000);

        uint256 tresuryERC20Share = tokenBalance - gnosisWalletERC20Share;

        token.safeTransfer(gnosisWallet, gnosisWalletERC20Share);
        token.safeTransfer(treasury, tresuryERC20Share);

        emit ERC20Distributed(
            gnosisWallet,
            _tokenAddress,
            gnosisWalletERC20Share
        );
        emit ERC20Distributed(treasury, _tokenAddress, tresuryERC20Share);
    }

    function updateTreasury(address _newTreasury) external override onlyOwner {
        address oldTreasury = treasury;
        treasury = _newTreasury;

        emit TreasuryUpdated(_newTreasury, oldTreasury);
    }

    function updateGnosisWallet(
        address _newGnosisWallet
    ) external override onlyOwner {
        address oldGnosisWallet = gnosisWallet;
        gnosisWallet = _newGnosisWallet;

        emit GnosisWalletUpdated(_newGnosisWallet, oldGnosisWallet);
    }

    receive() external payable {}

    function deposite() external payable {} //TODO: remove at production
}
