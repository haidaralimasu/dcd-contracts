// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IDigitalCitizenDAOERC20 {
    event TreasuryUpdated(address oldTreasury, address newTreasury);

    event InitialSupplyUpdated(
        uint256 oldInitialSupply,
        uint256 newInitialSupply
    );

    event FunDistributorUpdated(
        address oldFundDistributor,
        address newFundDistributor
    );

    event GetFeeSetted(address getFeeAddress, bool isGetFee);

    event ExcldedFromFeesSetted(address account, bool isExcluded);

    event FeeOnBuyUpdated(uint256 oldFeeOnBuy, uint256 newFeeBuy);

    event FeeOnSellUpdated(uint256 oldFeeOnSell, uint256 newFeeSell);

    function updateInitialSupply(uint256 _newInitialSupply) external;

    function setGetFee(address _getFeeAddress, bool _isGetFee) external;

    function setMultipleGetFees(
        address[] memory _getFeeAddresses,
        bool _isGetFee
    ) external;

    function setExcludeFromFee(address _account, bool _isExcluded) external;

    function setMultipleExcludeFromFees(
        address[] memory _accounts,
        bool _isExcluded
    ) external;

    function updateFee(uint256 _onBuy, uint256 _onSell) external;

    function updateFunDistributor(address _newFundDistributor) external;
}
