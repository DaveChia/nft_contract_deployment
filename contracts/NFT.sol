// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT_Minting_With_Date_Range is ERC721, ERC721URIStorage, AccessControl, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint public nft_minting_start_date;
    uint public nft_minting_end_date;
    uint8 public nft_minting_maximum_count = 5;
    uint8 public nft_minting_current_count = 0;
    string public nft_metadata_ipfs_url = "";

    struct address_minting_data {
        string nft_ipfs_url;
        string receipt;
        uint minted_timestamp;
    }

    mapping (address => bool) public addresses_minted_nft;
    mapping (string => bool) public receipts_minted_nft;
    
    mapping(address => address_minting_data) public addresses_minting_data;
    

    constructor(uint nft_minting_start_date_chosen, uint nft_minting_end_date_chosen, string memory nft_metadata_ipfs_url_chosen) ERC721("Mercedes Benz NFT", "MERC-NFT") {

        require(nft_minting_start_date_chosen > block.timestamp, "The chosen start date to mint NFT is not in the future.");
        require(nft_minting_end_date_chosen > block.timestamp, "The chosen end date to mint NFT is not in the future,");
        require(nft_minting_end_date_chosen > nft_minting_start_date_chosen, "The chosen end date to mint NFT is not later than the start date.");
        
        nft_minting_start_date = nft_minting_start_date_chosen;
        nft_minting_end_date = nft_minting_end_date_chosen;

        nft_metadata_ipfs_url = nft_metadata_ipfs_url_chosen;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function grantDefaultAdminRole(address addressToGrantRole) public onlyRole(DEFAULT_ADMIN_ROLE) {

        _grantRole(DEFAULT_ADMIN_ROLE, addressToGrantRole);
    }

    function mint(address to, string memory receipt) public {

        require(nft_minting_maximum_count > nft_minting_current_count, "All NFTs have been minted.");
        require(addresses_minted_nft[to] == false, "The address has already minted a NFT.");
        require(receipts_minted_nft[receipt] == false, "The receipt has already minted a NFT.");
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
        _setTokenURI(tokenId, nft_metadata_ipfs_url);

        addresses_minted_nft[to] = true;
        receipts_minted_nft[receipt] = true;

        addresses_minting_data[to].nft_ipfs_url = nft_metadata_ipfs_url;
        addresses_minting_data[to].receipt = receipt;
        addresses_minting_data[to].minted_timestamp = block.timestamp;

        nft_minting_current_count++;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) onlyRole(DEFAULT_ADMIN_ROLE) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}