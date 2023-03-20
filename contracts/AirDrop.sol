// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AirDrop is Ownable {
    using SafeERC20 for IERC20;

    mapping(bytes32 => mapping(IERC20 => mapping(address => uint)))
        public dropped;

    event AirDropped(
        bytes32 indexed eventID,
        IERC20 indexed token,
        address indexed receiver,
        uint amount
    );

    event TokenWithdrawed(IERC20 token, address receiver, uint amount);

    function airDropSameTokenSameAmount(
        string memory _eventID,
        IERC20 _token,
        uint _amount,
        address[] memory _receivers
    ) external onlyOwner {
        uint length = _receivers.length;
        require(length > 0, "AirDrop: No receivers provided");

        bytes32 eventID = keccak256(abi.encode(_eventID));
        for (uint i = 0; i < length; ) {
            _airDrop(eventID, _token, _receivers[i], _amount);
            unchecked {
                ++i;
            }
        }
    }

    function airDropSameToken(
        string memory _eventID,
        IERC20 _token,
        uint[] memory _amounts,
        address[] memory _receivers
    ) external onlyOwner {
        uint length = _receivers.length;
        require(length > 0, "AirDrop: No receivers provided");
        require(_amounts.length == length, "AirDrop: Amounts count mismatch");

        bytes32 eventID = keccak256(abi.encode(_eventID));
        for (uint i = 0; i < length; ) {
            _airDrop(eventID, _token, _receivers[i], _amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    function airDrop(
        string memory _eventID,
        IERC20[] memory _tokens,
        uint[] memory _amounts,
        address[] memory _receivers
    ) external onlyOwner {
        uint length = _receivers.length;
        require(length > 0, "AirDrop: No receivers provided");
        require(_tokens.length == length, "AirDrop: Token count mismatch");
        require(_amounts.length == length, "AirDrop: Amounts count mismatch");

        bytes32 eventID = keccak256(abi.encode(_eventID));
        for (uint i = 0; i < length; ) {
            _airDrop(eventID, _tokens[i], _receivers[i], _amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    function withdrawToken(
        IERC20 _token,
        address _receiver,
        uint _amount
    ) external onlyOwner {
        _token.safeTransfer(_receiver, _amount);
        emit TokenWithdrawed(_token, _receiver, _amount);
    }

    function _airDrop(
        bytes32 _eventID,
        IERC20 _token,
        address _receiver,
        uint _amount
    ) internal {
        require(dropped[_eventID][_token][_receiver] == 0, "AirDrop: Dropped");
        dropped[_eventID][_token][_receiver] = _amount;
        _token.safeTransfer(_receiver, _amount);
        emit AirDropped(_eventID, _token, _receiver, _amount);
    }
}
