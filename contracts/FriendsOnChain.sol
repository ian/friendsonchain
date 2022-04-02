// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";

contract FriendsOnChain is ERC1155, Ownable {
  using Address for address payable;
  using Counters for Counters.Counter;
  using Strings for uint256;

  uint256 MAX_SUPPLY = 0; // default unlimited
  uint256 MAX_OWNERS = 7; // limit groups to 7 for now
  uint256 PRICE_PER_TOKEN = 0; // by default the price to mint is free

  Counters.Counter private nextTokenId;
  mapping(address => uint8) private greenList;

  constructor() ERC1155("https://bunches.app/metadata/{id}.json") {
    // nextTokenId is initialized to 1, since starting at 0 leads to higher gas cost for the first minter
    nextTokenId.increment();
  }

  /// @notice Mint a token for up to maxOwners addresses
  /// @param to the recipients of the token
  function createGroup(address[] memory to) external payable {
    uint256 currentTokenId = nextTokenId.current();

    require(
      MAX_OWNERS == 0 || to.length < MAX_OWNERS,
      "Maximum number of owners exceeded"
    );
    require(msg.value == PRICE_PER_TOKEN, "Incorrect payment");
    require(
      MAX_SUPPLY == 0 || currentTokenId < MAX_SUPPLY,
      "Maximum number of tokens reached"
    );

    for (uint256 i = 0; i < to.length; i++) {
      _mint(to[i], currentTokenId, 1, "");
    }

    nextTokenId.increment();
  }

  function isMember(address addy, uint256 tokenId) public view returns (bool) {
    return balanceOf(addy, tokenId) > 0;
  }

  // @dev Returns the max token supply allowed by the contract
  function price() public view returns (uint256) {
    return PRICE_PER_TOKEN;
  }

  // @dev Returns the total number of mints
  function totalMinted() public view returns (uint256) {
    return nextTokenId.current() - 1;
  }

  /// @notice Allows to change the price
  /// @dev Allows the owner to change the price
  /// @param newPrice the new price
  function setPrice(uint256 newPrice) public onlyOwner {
    PRICE_PER_TOKEN = newPrice;
  }

  /// @notice Allows to change the max supply
  /// @dev Allows the owner to change max number of tokens
  /// @param newSupply the new maximum number of passes
  function setMaxSupply(uint256 newSupply) public onlyOwner {
    MAX_SUPPLY = newSupply;
  }

  /// @notice Allows to change the max owners per token
  /// @dev Allows the owner to change
  /// @param newOwners the new maximum number of passes
  function setMaxOwners(uint256 newOwners) public onlyOwner {
    MAX_OWNERS = newOwners;
  }
}
