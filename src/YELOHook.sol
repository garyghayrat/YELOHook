// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseHook} from "@openzeppelin/uniswap-hooks/src/base/BaseHook.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager, SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {ERC6909Claims} from "@uniswap/v4-core/src/ERC6909Claims.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPool} from "lib/aave-v3-core/contracts/interfaces/IPool.sol";

contract YieldEarningLimitOrdersHook is BaseHook, ERC6909Claims {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;

    // NOTE: ---------------------------------------------------------
    // state variables should typically be unique to a pool
    // a single hook contract should be able to service multiple pools
    // ---------------------------------------------------------------
    mapping(PoolId poolId => mapping(int24 targetTick => mapping(bool zeroForOne => uint256 amount))) public limitOrders;
    mapping(uint256 orderId => uint256 claimsMinted) public claimsMintedPerOrderId;

    IPool public immutable AAVE_POOL;

    mapping(PoolId => uint256 count) public beforeSwapCount;
    mapping(PoolId => uint256 count) public afterSwapCount;

    mapping(PoolId => uint256 count) public beforeAddLiquidityCount;
    mapping(PoolId => uint256 count) public beforeRemoveLiquidityCount;

    constructor(IPoolManager _poolManager, IPool _aavePool) BaseHook(_poolManager) {
        AAVE_POOL = _aavePool;
    }

    function orderId(PoolKey calldata _key, int24 _targetTick, bool _zeroForOne) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(_key, _targetTick, _zeroForOne)));
    }

    function sellToken(PoolKey calldata _key, bool _zeroForOne) public pure returns (IERC20) {
        return _zeroForOne ? IERC20(Currency.unwrap(_key.currency0)) : IERC20(Currency.unwrap(_key.currency1));
    }

    function placeOrder(PoolKey calldata _key, int24 _targetTick, bool _zeroForOne, uint256 _amount) public {
        IERC20 _sellToken = sellToken(_key, _zeroForOne);
        _sellToken.transferFrom(msg.sender, address(this), _amount);

        _sellToken.approve(address(AAVE_POOL), _amount);
        AAVE_POOL.supply(address(_sellToken), _amount, address(this), 0);

        uint256 _orderId = orderId(_key, _targetTick, _zeroForOne);
        limitOrders[_key.toId()][_targetTick][_zeroForOne] += _amount;

        claimsMintedPerOrderId[_orderId] += _amount;
        _mint(msg.sender, _orderId, _amount);
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: true,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    // -----------------------------------------------
    // NOTE: see IHooks.sol for function documentation
    // -----------------------------------------------

    function _afterInitialize(address, PoolKey calldata key, uint160, int24 tick) internal override returns (bytes4) {
        return this.afterInitialize.selector;
    }

    function _afterSwap(address, PoolKey calldata key, SwapParams calldata, BalanceDelta, bytes calldata)
        internal
        override
        returns (bytes4, int128)
    {
        afterSwapCount[key.toId()]++;
        return (BaseHook.afterSwap.selector, 0);
    }

    function _beforeSwap(address, PoolKey calldata key, SwapParams calldata, bytes calldata)
        internal
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        beforeSwapCount[key.toId()]++;
        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function _beforeAddLiquidity(address, PoolKey calldata key, ModifyLiquidityParams calldata, bytes calldata)
        internal
        override
        returns (bytes4)
    {
        beforeAddLiquidityCount[key.toId()]++;
        return BaseHook.beforeAddLiquidity.selector;
    }

    function _beforeRemoveLiquidity(address, PoolKey calldata key, ModifyLiquidityParams calldata, bytes calldata)
        internal
        override
        returns (bytes4)
    {
        beforeRemoveLiquidityCount[key.toId()]++;
        return BaseHook.beforeRemoveLiquidity.selector;
    }
}
