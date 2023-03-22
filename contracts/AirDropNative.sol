// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./AirDrop.sol";

contract AirDropNative is AirDrop {
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    event AirDropFailed(
        bytes32 indexed eventID,
        IERC20 indexed token,
        address indexed receiver,
        uint amount
    );

    receive() external payable {}

    function airDropNativeSameAmount(
        string memory _eventID,
        bool _allowFail,
        uint _gasLimit,
        uint _amount,
        address[] memory _receivers
    ) external payable onlyOwner {
        uint length = _receivers.length;
        require(length > 0, "AirDrop: No receivers provided");

        bytes32 eventID = keccak256(abi.encode(_eventID));
        for (uint i = 0; i < length; ) {
            _airDropNative(
                eventID,
                _allowFail,
                _receivers[i],
                _amount,
                _gasLimit
            );
            unchecked {
                ++i;
            }
        }
    }

    function airDropNative(
        string memory _eventID,
        bool _allowFail,
        uint _gasLimit,
        uint[] memory _amounts,
        address[] memory _receivers
    ) external payable onlyOwner {
        uint length = _receivers.length;
        require(length > 0, "AirDrop: No receivers provided");
        require(_amounts.length == length, "AirDrop: Amounts count mismatch");

        bytes32 eventID = keccak256(abi.encode(_eventID));
        for (uint i = 0; i < length; ) {
            _airDropNative(
                eventID,
                _allowFail,
                _receivers[i],
                _amounts[i],
                _gasLimit
            );

            unchecked {
                ++i;
            }
        }
    }

    function withdrawNative(
        address _receiver,
        uint _amount
    ) external onlyOwner {
        transferETH(_receiver, _amount, 0, false);
        emit TokenWithdrawed(IERC20(ETH), _receiver, _amount);
    }

    function _airDropNative(
        bytes32 _eventID,
        bool _allowFail,
        address _receiver,
        uint256 _amount,
        uint256 _gasLimit
    ) internal {
        require(
            dropped[_eventID][IERC20(ETH)][_receiver] == 0,
            "AirDrop: Dropped"
        );

        dropped[_eventID][IERC20(ETH)][_receiver] = _amount;

        bool success = transferETH(_receiver, _amount, _gasLimit, _allowFail);

        if (success) {
            emit AirDropped(_eventID, IERC20(ETH), _receiver, _amount);
        } else {
            emit AirDropFailed(_eventID, IERC20(ETH), _receiver, _amount);
        }
    }

    function transferETH(
        address _to,
        uint256 _amount,
        uint256 _gasLimit,
        bool _allowFail
    ) internal returns (bool success) {
        if (_gasLimit > 0) {
            (success, ) = _to.call{value: _amount, gas: _gasLimit}("");
        } else {
            (success, ) = _to.call{value: _amount}("");
        }
        require(success || _allowFail, "AirDrop: Transfer Failed");
    }
}
