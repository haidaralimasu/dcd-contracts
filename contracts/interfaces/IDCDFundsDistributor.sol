// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IDCDFundsDistributor {
    event TreasuryUpdated(address newTreasury, address oldTreausry);

    event GnosisWalletUpdated(address newGnosisWallet, address oldGnosisWallet);

    event ERC20Distributed(
        address receiver,
        address tokenAddress,
        uint256 amount
    );

    event ETHDistributed(address receiver, uint256 amount);

    function updateTreasury(address _newTreasury) external;

    function updateGnosisWallet(address _newGnosisWallet) external;

    function distributeETH() external;

    function distributeERC20(address _tokenAddress) external;
}
