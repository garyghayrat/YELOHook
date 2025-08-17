// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPool} from "lib/aave-v3-core/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "lib/aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {DataTypes} from "lib/aave-v3-core/contracts/protocol/libraries/types/DataTypes.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockAavePool is IPool {
    mapping(address asset => mapping(address user => uint256 balance)) public aTokenBalances;

    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external override {
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        aTokenBalances[asset][msg.sender] += amount;
    }

    function withdraw(address asset, uint256 amount, address to) external override returns (uint256) {
        aTokenBalances[asset][to] -= amount;
        IERC20(asset).transfer(to, amount);
        return amount;
    }

    function mintUnbacked(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external override {}

    function backUnbacked(address asset, uint256 amount, uint256 fee) external override returns (uint256) {
        return 0;
    }

    function supplyWithPermit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode,
        uint256 deadline,
        uint8 permitV,
        bytes32 permitR,
        bytes32 permitS
    ) external override {}

    function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf)
        external
        override
    {}

    function repay(address asset, uint256 amount, uint256 interestRateMode, address onBehalfOf)
        external
        override
        returns (uint256)
    {
        return 0;
    }

    function repayWithPermit(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        address onBehalfOf,
        uint256 deadline,
        uint8 permitV,
        bytes32 permitR,
        bytes32 permitS
    ) external override returns (uint256) {
        return 0;
    }

    function repayWithATokens(address asset, uint256 amount, uint256 interestRateMode)
        external
        override
        returns (uint256)
    {
        return 0;
    }

    function swapBorrowRateMode(address asset, uint256 interestRateMode) external override {}

    function rebalanceStableBorrowRate(address asset, address user) external override {}

    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external override {}

    function liquidationCall(
        address collateralAsset,
        address debtAsset,
        address user,
        uint256 debtToCover,
        bool receiveAToken
    ) external override {}

    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata interestRateModes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external override {}

    function flashLoanSimple(
        address receiverAddress,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external override {}

    function getUserAccountData(address user)
        external
        view
        override
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        return (0, 0, 0, 0, 0, 0);
    }

    function initReserve(
        address asset,
        address aTokenAddress,
        address stableDebtAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress
    ) external override {}

    function dropReserve(address asset) external override {}

    function setReserveInterestRateStrategyAddress(address asset, address rateStrategyAddress) external override {}

    function setConfiguration(address asset, DataTypes.ReserveConfigurationMap calldata configuration)
        external
        override
    {}

    function getConfiguration(address asset)
        external
        view
        override
        returns (DataTypes.ReserveConfigurationMap memory)
    {
        DataTypes.ReserveConfigurationMap memory config;
        return config;
    }

    function getUserConfiguration(address user)
        external
        view
        override
        returns (DataTypes.UserConfigurationMap memory)
    {
        DataTypes.UserConfigurationMap memory userConfig;
        return userConfig;
    }

    function getReserveNormalizedIncome(address asset) external view override returns (uint256) {
        return 0;
    }

    function getReserveNormalizedVariableDebt(address asset) external view override returns (uint256) {
        return 0;
    }

    function getReserveData(address asset) external view override returns (DataTypes.ReserveData memory) {
        DataTypes.ReserveData memory data;
        return data;
    }

    function finalizeTransfer(
        address asset,
        address from,
        address to,
        uint256 amount,
        uint256 balanceFromBefore,
        uint256 balanceToBefore
    ) external override {}

    function getReservesList() external view override returns (address[] memory) {
        return new address[](0);
    }

    function getReserveAddressById(uint16 id) external view override returns (address) {
        return address(0);
    }

    function ADDRESSES_PROVIDER() external view override returns (IPoolAddressesProvider) {
        return IPoolAddressesProvider(address(0));
    }

    function updateBridgeProtocolFee(uint256 bridgeProtocolFee) external override {}

    function updateFlashloanPremiums(uint128 flashLoanPremiumTotal, uint128 flashLoanPremiumToProtocol)
        external
        override
    {}

    function configureEModeCategory(uint8 id, DataTypes.EModeCategory memory config) external override {}

    function getEModeCategoryData(uint8 id) external view override returns (DataTypes.EModeCategory memory) {
        DataTypes.EModeCategory memory emode;
        return emode;
    }

    function setUserEMode(uint8 categoryId) external override {}

    function getUserEMode(address user) external view override returns (uint256) {
        return 0;
    }

    function resetIsolationModeTotalDebt(address asset) external override {}

    function MAX_STABLE_RATE_BORROW_SIZE_PERCENT() external view override returns (uint256) {
        return 0;
    }

    function FLASHLOAN_PREMIUM_TOTAL() external view override returns (uint128) {
        return 0;
    }

    function BRIDGE_PROTOCOL_FEE() external view override returns (uint256) {
        return 0;
    }

    function FLASHLOAN_PREMIUM_TO_PROTOCOL() external view override returns (uint128) {
        return 0;
    }

    function MAX_NUMBER_RESERVES() external view override returns (uint16) {
        return 0;
    }

    function mintToTreasury(address[] calldata assets) external override {}

    function rescueTokens(address token, address to, uint256 amount) external override {}

    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external override {}
}
