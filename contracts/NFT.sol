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
    uint public nft_minting_maximum_count;
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

    constructor(uint max_mint_count, uint nft_minting_start_date_chosen, uint nft_minting_end_date_chosen, string memory nft_metadata_ipfs_url_chosen) ERC721("Mercedes Benz NFT", "MERC-NFT") {

        //  Initiate the smart contract
        //  Validate the input parameters to deploy the contract
        require(nft_minting_start_date_chosen > block.timestamp, "The chosen start date to mint NFT is not in the future.");
        require(nft_minting_end_date_chosen > block.timestamp, "The chosen end date to mint NFT is not in the future,");
        require(nft_minting_end_date_chosen > nft_minting_start_date_chosen, "The chosen end date to mint NFT is not later than the start date.");
        
        //  Set up the start and end date range when the smart contract allows minting
        nft_minting_start_date = nft_minting_start_date_chosen;
        nft_minting_end_date = nft_minting_end_date_chosen;

        //  Set up the IPFS URL of the metadata of which all minted NFTs will share
        nft_metadata_ipfs_url = nft_metadata_ipfs_url_chosen;

        //  Set the maximum number of NFTs allowed to be minted in this smart contract
        nft_minting_maximum_count= max_mint_count;

        //  Grant the DEFAULT_ADMIN_ROLE to the wallet that deployed this contract
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    //  This function grants the DEFAULT_ADMIN_ROLE to the selected wallet address (addressToGrantRole), the sender will need to have the DEFAULT_ADMIN_ROLE to use this function
    function grantDefaultAdminRole(address addressToGrantRole) public onlyRole(DEFAULT_ADMIN_ROLE) {

        _grantRole(DEFAULT_ADMIN_ROLE, addressToGrantRole);
    }

    //  This function mints an NFT to a selected wallet address (to), it will also accept a receipt encrypted string which will be stored on the blockchain as a state.
    //  The receipt is a unique identifier to identify each NFT minted
    //  Each wallet address can only mint a NFT once
    //  Receipt must be unique on the chain
    function mint(address to, string memory receipt) public {

        //  Allow minting only if the maximum allowed minting count is not reached yet
        require(nft_minting_maximum_count > nft_minting_current_count, "All NFTs have been minted.");

        //  Ensure that each address and receipt can only mint a NFT once in this smart contract
        require(addresses_minted_nft[to] == false, "The address has already minted a NFT.");
        require(receipts_minted_nft[receipt] == false, "The receipt has already minted a NFT.");
        
        //  Generate the NFT's unique token id on the chain
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        //  Perform the minting
        _mint(to, tokenId);

        //  Bind the NFT's metadata URL to the generated token id
        _setTokenURI(tokenId, nft_metadata_ipfs_url);

        //  Record the address and receipt on the blockchain
        addresses_minted_nft[to] = true;
        receipts_minted_nft[receipt] = true;

        //  Pair the wallet address that did the minting with the respective data
        addresses_minting_data[to].nft_ipfs_url = nft_metadata_ipfs_url;
        addresses_minting_data[to].receipt = receipt;
        addresses_minting_data[to].minted_timestamp = block.timestamp;

        //  Increment the current number of NFTs minted
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