// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Verifier.sol"; // TODO


contract ZKLocationProofToken is ERC721, Verifier {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct LocationProof {
        string ipfsCid; // IPFS CID storing the proof metadata
        uint256 timestamp;
    }

    // Mapping from token ID to LocationProof
    mapping(uint256 => LocationProof) private _locationProofs;

    // Mapping from owner address to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    event ProofTokenCreated(uint256 indexed tokenId, string ipfsCid);

    constructor() ERC721("ZKLocationProofToken", "ZKPT") {}

    function mintProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[] memory input,
        string memory ipfsCid
    ) public {
        require(verifyProof(a, b, c, input), "Invalid zk-proof provided.");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _locationProofs[tokenId] = LocationProof(ipfsCid, block.timestamp);
        _mint(msg.sender, tokenId);
        _ownedTokens[msg.sender].push(tokenId);

        emit ProofTokenCreated(tokenId, ipfsCid);
    }

    function getProof(uint256 tokenId) public view returns (LocationProof memory) {
        require(ownerOf(tokenId)!= address(0), "ZKLocationProofToken: Proof token does not exist.");
        return _locationProofs[tokenId];
    }

    function getOwnedProofs(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }

    function getAllProofDetails(address owner) public view returns (LocationProof[] memory) {
        uint256[] memory tokenIds = getOwnedProofs(owner);
        LocationProof[] memory proofs = new LocationProof[](tokenIds.length);
        
        for (uint i = 0; i < tokenIds.length; i++) {
            proofs[i] = getProof(tokenIds[i]);
        }

        return proofs;
    }
}
