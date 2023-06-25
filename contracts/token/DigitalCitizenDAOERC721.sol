// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721Checkpointable} from "../base/ERC721Checkpointable.sol";
import {ERC721} from "../base/ERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IProxyRegistry} from "../external/opensea/IProxyRegistry.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IDigitalCitizenDAOERC721} from "../interfaces/IDigitalCitizenDAOERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DigitalCitizenDAOERC721 is
    Ownable,
    ERC721Checkpointable,
    IDigitalCitizenDAOERC721
{
    using Counters for Counters.Counter;
    using Strings for uint256;
    IProxyRegistry public immutable proxyRegistry;

    uint256 public maxSupply = 100;
    uint256 public foundingFatherSupply = 5;
    uint256 public price = 0.08 ether; //TODO: change it to 3 eth
    uint256 public mintLimit = 1;

    string public foundingFatherImage =
        "https://pink-uncertain-junglefowl-438.mypinata.cloud/ipfs/QmZ2qMB7EkvxzX1EKsaf1DA4JcaQnZDpqwAjKkfAfdTU1k/Founding.png";
    string public normalImage =
        "https://pink-uncertain-junglefowl-438.mypinata.cloud/ipfs/QmZ2qMB7EkvxzX1EKsaf1DA4JcaQnZDpqwAjKkfAfdTU1k/Normal.jpg";

    string public revealuri =
        "https://pink-uncertain-junglefowl-438.mypinata.cloud/ipfs/QmXB4KijnGFR4HzBEoFbVHhkZ2fF9K7USF1sYVYurA9dM4";

    mapping(uint256 => Token) public tokens;
    mapping(address => uint256) public mintBalanceOf;

    bool public transferPaused = true;
    bool public revealed = false;

    Counters.Counter public totalMinted;

    string public contractUri =
        "https://pink-uncertain-junglefowl-438.mypinata.cloud/ipfs/QmTRWrErRT7ueVWVwAFfxwvLFFpv3epqavN2AJvmnhpzV1";

    constructor(address _proxyRegistry) ERC721("Digital Citizen DAO", "DCD") {
        proxyRegistry = IProxyRegistry(_proxyRegistry);
    }

    /*
    Public functions
    */
    function contractURI() public view returns (string memory) {
        return contractUri;
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view override(IERC721, ERC721) returns (bool) {
        if (proxyRegistry.proxies(owner) == operator) {
            return true;
        }
        return super.isApprovedForAll(owner, operator);
    }

    function mintToken(uint256 amount) external payable override {
        uint256 totalPrice = amount * price;

        require(
            msg.value >= totalPrice,
            "DigitalCitizenDAOERC721::Incorrect Price"
        );

        _mintToken(msg.sender);
    }

    function buildMetadata(
        uint256 _tokenId
    ) public view returns (string memory) {
        Token memory currentToken = tokens[_tokenId];

        string memory imageURI = currentToken.isFoundingFather
            ? foundingFatherImage
            : normalImage;

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                string(
                                    abi.encodePacked(
                                        "DCD # ",
                                        _tokenId.toString()
                                    )
                                ),
                                '", "description":"',
                                "This token conveys citizenship and voting rights to the Digital Citizen DAO",
                                '", "image": "',
                                imageURI,
                                '", "attributes":[{"display_type": "date", "trait_type":"Citizen Since","value":"',
                                currentToken.date.toString(),
                                '"},{"trait_type":"Type","value":"',
                                currentToken.isFoundingFather
                                    ? "Founding Father"
                                    : "Citizen",
                                '"}]}'
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return revealed ? buildMetadata(_tokenId) : revealuri;
    }

    /*
    Only owner function
    */
    function updateContractURI(
        string memory _newContractUri
    ) external onlyOwner {
        string memory oldContractUri = contractUri;
        contractUri = _newContractUri;

        emit ContractURIUpdated(oldContractUri, _newContractUri);
    }

    function updateMaxSupply(
        uint256 _newTotalMaxSupply
    ) external override onlyOwner {
        uint256 oldMaxSupply = _newTotalMaxSupply;
        maxSupply = _newTotalMaxSupply;

        emit MaxSupplyUpdated(oldMaxSupply, _newTotalMaxSupply);
    }

    function updatePrice(uint256 _newPrice) external override onlyOwner {
        uint256 oldPrice = price;
        price = _newPrice;

        emit PriceUpdated(oldPrice, _newPrice);
    }

    function updateMintLimit(
        uint256 _newMintLimit
    ) external override onlyOwner {
        uint256 oldMintLimit = _newMintLimit;
        mintLimit = _newMintLimit;

        emit MintLimitUpdated(oldMintLimit, _newMintLimit);
    }

    function updateTransferPause(bool _isPause) external override onlyOwner {
        transferPaused = _isPause;

        emit TransferPauseUpdated(_isPause);
    }

    function updateFoundingFatherImage(
        string memory _newFoundingFatherImage
    ) external override onlyOwner {
        string memory oldFoundingFatherImage = foundingFatherImage;
        foundingFatherImage = _newFoundingFatherImage;

        emit FoundingFatherImageUpdated(
            oldFoundingFatherImage,
            _newFoundingFatherImage
        );
    }

    function updateNormalImage(
        string memory _newNormalImage
    ) external override onlyOwner {
        string memory oldNormalImage = normalImage;
        normalImage = _newNormalImage;

        emit NormalImageUpdated(oldNormalImage, _newNormalImage);
    }

    function reveal() external override onlyOwner {
        revealed = true;

        emit Revealed();
    }

    /*
    Internal Functions
    */
    function _currentTime() internal view returns (uint256 currentTime) {
        currentTime = block.timestamp;
    }

    function _mintToken(address reciever) internal {
        uint256 supply = totalSupply();
        totalMinted.increment();

        require(supply <= maxSupply, "DigitalCitizenTokenERC721::Sold Out");
        require(supply + 1 <= maxSupply, "DigitalCitizenTokenERC721::Sold Out");
        require(
            mintBalanceOf[reciever] <= mintLimit,
            "DigitalCitizenTokenERC721::Cannot Mint More Tokens"
        );

        bool isFoundingFather = supply <= foundingFatherSupply ? true : false;

        Token memory newToken = Token(
            totalMinted.current(),
            _currentTime(),
            isFoundingFather
        );

        tokens[totalMinted.current()] = newToken;
        mintBalanceOf[reciever] = mintBalanceOf[reciever] + 1;
        _safeMint(owner(), reciever, totalMinted.current());

        emit TokenMinted(totalMinted.current(), _currentTime());
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(transferPaused == false, "You cannot transfer right now");
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
}
