// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IDigitalCitizenDAOERC721 {
    struct Token {
        uint256 id;
        uint256 date;
        bool isFoundingFather;
        address recruitedBy;
    }

    event MaxSupplyUpdated(uint256 oldMaxSupply, uint256 newMaxSupply);

    event PriceUpdated(uint256 oldPrice, uint256 newPrice);

    event MintLimitUpdated(uint256 oldMintLimit, uint256 newMintLimit);

    event TransferPauseUpdated(bool isPause);

    event TokenMinted(uint256 tokenId, uint256 time);

    event GnosisWalletUpdated(address newGnosisWallet, address oldGnosisWallet);

    event Revealed();

    event FoundingFatherImageUpdated(
        string oldFoundingFatherImage,
        string newFoundingFatherImage
    );

    event RecruitmentBonusPercentageUpdated(
        uint256 newBonusPercentage,
        uint256 oldBonusPercentage
    );

    event ContractURIUpdated(string oldContractUri, string _newContractUri);

    event NormalImageUpdated(string oldNormalImage, string newNormalImage);

    function updateMaxSupply(uint256 _newTotalMaxSupply) external;

    function updatePrice(uint256 _newPrice) external;

    function updateMintLimit(uint256 _newMintLimit) external;

    function updateTransferPause(bool _isPause) external;

    function mintToken(uint256 amount, address recuriter) external payable;

    function updateNormalImage(string memory _newNormalImage) external;

    function updateFoundingFatherImage(
        string memory _newFoundingFatherImage
    ) external;

    function reveal() external;

    function updateContractURI(string memory _newContractUri) external;

    function updateGnosisWallet(address _newGnosisWallet) external;

    function updateRecruitmentBonusPercentage(
        uint256 _newBonusPercentage
    ) external;
}
