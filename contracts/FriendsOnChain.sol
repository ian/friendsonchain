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

  uint256 private maxSupply = 0; // default unlimited
  uint256 private maxOwners = 7; // limit groups to 7 for now
  uint256 private pricePerToken = 0; // in case you want to charge for this

  Counters.Counter private nextTokenId;
  mapping(address => uint8) private greenList;

  constructor() ERC1155("https://bunches.app/metadata/{id}.json") {
    // nextTokenId is initialized to 1, since starting at 0 leads to higher gas cost for the first minter
    nextTokenId.increment();
  }

  /// @notice Mint a token for up to maxOwners addresses
  /// @param _to the recipients of the token
  function createGroup(address[] memory _to) external payable {
    uint256 currentTokenId = nextTokenId.current();

    require(
      maxOwners == 0 || _to.length < maxOwners,
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

    nextTokenId.increment();
  }

  function isMember(address _addy, uint256 _tokenId)
    public
    view
    returns (bool)
  {
    return balanceOf(_addy, _tokenId) > 0;
  }

  // @dev Returns the max token supply allowed by the contract
  function price() public view returns (uint256) {
    return pricePerToken;
  }

  // @dev Returns the total number of mints
  function totalMinted() public view returns (uint256) {
    return nextTokenId.current() - 1;
  }

  /// @notice Allows to change the price
  /// @dev Allows the owner to change the price
  /// @param _newPrice the new price
  function setPrice(uint256 _newPrice) public onlyOwner {
    pricePerToken = _newPrice;
  }

  /// @notice Allows to change the max supply
  /// @dev Allows the owner to change max number of tokens
  /// @param _newSupply the new maximum number of passes
  function setMaxSupply(uint256 _newSupply) public onlyOwner {
    maxSupply = _newSupply;
  }

  /// @notice Allows to change the max owners per token
  /// @dev Allows the owner to change
  /// @param _newMaxOwners the new maximum number of passes
  function setMaxOwners(uint256 _newMaxOwners) public onlyOwner {
    maxOwners = _newMaxOwners;
  }
}
