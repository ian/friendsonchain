// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

// ██      ███████ ████████ ███████     ██████  ███████     ███████ ██████  ██ ███████ ███    ██ ██████  ███████
// ██      ██         ██    ██          ██   ██ ██          ██      ██   ██ ██ ██      ████   ██ ██   ██ ██
// ██      █████      ██    ███████     ██████  █████       █████   ██████  ██ █████   ██ ██  ██ ██   ██ ███████
// ██      ██         ██         ██     ██   ██ ██          ██      ██   ██ ██ ██      ██  ██ ██ ██   ██      ██
// ███████ ███████    ██    ███████     ██████  ███████     ██      ██   ██ ██ ███████ ██   ████ ██████  ███████

// Import OpenZeppelin Contracts
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

// @title Friends on Chain
// @author Ian Hunter (@ianh), Derek Brown (@derekbrown)
contract FriendsOnChain is ERC1155, Ownable {
  using Address for address payable;
  using Counters for Counters.Counter;
  using Strings for uint256;

  // Defaults to 0. 0 is unlimited supply.
  uint256 private maxSupply = 0;

  // Indicates the number of people in a FOC, including the minter. Defaults to 7.
  uint256 private maxOwners = 7;

  // Defaults to free mint. Denominated in wei.
  uint256 private pricePerToken = 0;

  // Use OpenZeppelin Counters for incrementing - do NOT access counter's underlying value.
  Counters.Counter private nextTokenId;

  event GroupCreated(uint256 tokenId, address[] indexed _to);

  constructor() ERC1155("https://bunches.xyz/foc/metadata/{id}") {
    // nextTokenId is initialized to 1, since starting at 0 leads to higher gas cost for the first minter
    nextTokenId.increment();
  }

  /// @notice Mint a token for up to maxOwners addresses.
  /// @dev Payable. Emits GroupCreated event. Checks maxOwners and maxSupply.
  /// @dev Loops through addresses to assign ownership.
  /// @param _to array of recipient addresses of the token
  function createGroup(address[] memory _to) external payable {
    uint256 currentTokenId = nextTokenId.current();

    require(
      maxOwners == 0 || _to.length <= maxOwners,
      "Maximum number of owners exceeded"
    );
    require(msg.value == pricePerToken, "Incorrect payment");
    require(
      maxSupply == 0 || currentTokenId < maxSupply,
      "Maximum number of tokens reached"
    );

    for (uint256 i = 0; i < _to.length; i++) {
      _mint(_to[i], currentTokenId, 1, "");
    }

    emit GroupCreated(currentTokenId, _to);

    nextTokenId.increment();
  }

  /// @notice Returns whether the given address is a member of a given tokenId.
  /// @param _addr address for potential member
  /// @param _tokenId queried FOC token ID
  /// @return True or false, indicating address' membership.
  function isMember(address _addr, uint256 _tokenId)
    public
    view
    returns (bool)
  {
    return balanceOf(_addr, _tokenId) > 0;
  }

  /// @notice Returns the mint price per FOC
  /// @dev No conversions, so denominated in wei.
  /// @return Price per FOC, denominated in wei.
  function price() public view returns (uint256) {
    return pricePerToken;
  }

  /// @notice Returns the total count of minted FOCs.
  /// @return Number of minted FOCs as an integer.
  function countGroups() public view returns (uint256) {
    return nextTokenId.current() - 1;
  }

  /// @notice Change the mint price of FOCs.
  /// @dev Only the owner can change. No conversions, so denominated in wei.
  /// @param _newPrice the new mint price per FOC
  function setPrice(uint256 _newPrice) public onlyOwner {
    pricePerToken = _newPrice;
  }

  /// @notice Change the max supply of tokens.
  /// @dev Only the owner can change.
  /// @param _newSupply the new maximum number of FOCs
  function setMaxSupply(uint256 _newSupply) public onlyOwner {
    maxSupply = _newSupply;
  }

  /// @notice Change the max owners per token.
  /// @dev Only the owner can change.
  /// @param _newMaxOwners the new maximum number of owners per FOC
  function setMaxOwners(uint256 _newMaxOwners) public onlyOwner {
    maxOwners = _newMaxOwners;
  }

  /// @notice Provides a URL that serves contract-level metadata to marketplaces.
  /// @dev Serves a JSON object per OpenSea standards.
  function contractURI() public view returns (string memory) {
    return "https://bunches.xyz/foc/contract/metadata";
  }
}
