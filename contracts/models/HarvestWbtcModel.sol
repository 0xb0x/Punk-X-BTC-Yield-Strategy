pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/ModelInterface.sol";
import "../ModelStorage.sol";
import "../3rdDeFiInterfaces/IUniswapV2Router.sol";
import {FVault} from "../3rdDeFiInterfaces/fVault.sol";
import "../3rdDeFiInterfaces/RewardPool.sol";

contract HarvestModel is ModelInterface, ModelStorage{
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    event Swap( uint farm_amount, uint256 underlying_balance );

    // address _fToken;
    address _farm;
    address _fToken;
    address vault;
    address _uRouterV2;
    address _rewardPool;

    function initialize( 
        address forge_, 
        address token_,
        address fToken_,
        address farm_, 
        address _vault,
        address rewardPool_,
        address uRouterV2_ ) public {

            addToken( token_ );
            setForge( forge_ );
            _fToken         = fToken_;
            _farm           = farm_;
            vault           = _vault;
            _uRouterV2      = uRouterV2_;
            _rewardPool     = rewardPool_;

            require(FVault(vault).underlying() == token_);

    }

    // returns balance of underlying token
    function underlyingBalanceInModel() public override view returns ( uint256 ){
        return IERC20( token( 0 ) ).balanceOf( address( this ) );
    }

    // returns balance of underlying token + investments
    function underlyingBalanceWithInvestment() public override view returns ( uint256 ){
        uint256 notUndBal = _fTokenBalanceOf().add(RewardPool(_rewardPool).balanceOf(address(this)));
        return underlyingBalanceInModel().add(notUndBal.mul(FVault( _fToken ).getPricePerFullShare()).div(1e18));
    }

    // deposit underlying token into vault to recieve fvault and stake in Reward Pool
    function invest() public override {
        IERC20( token( 0 ) ).safeApprove( vault , underlyingBalanceInModel() );
        FVault(vault).depositFor(underlyingBalanceInModel(), address(this) );
        RewardPool(_rewardPool).stake(_fTokenBalanceOf());
        emit Invest( underlyingBalanceInModel(), block.timestamp );
    }
    
    // claim farm token, swap to farm underlying and invest
    function reInvest() public{
        _claimFarm();
        _swapFarmToUnderlying();
        invest();
    }

    function withdrawAllToForge() public OnlyForge override{
        _claimFarm();
        _swapFarmToUnderlying();
        RewardPool(_rewardPool).exit();
        FVault(vault).withdraw(_fTokenBalanceOf());
        IERC20(token(0)).safeTransfer(forge(), underlyingBalanceInModel());

        emit Withdraw(  underlyingBalanceWithInvestment(), forge(), block.timestamp);
    }

    function withdrawToForge( uint256 amount ) public OnlyForge override{
        withdrawTo( amount, forge() );
    }

    function withdrawTo( uint256 amount, address to ) public OnlyForge override{
        // Hard Work Now! For Punkers by 0xViktor
        uint oldBalance = IERC20( token(0) ).balanceOf( address( this ) );
        if(amount > oldBalance){
            uint amt = amount.sub(oldBalance);
            uint balRP = RewardPool(_rewardPool).balanceOf(address(this));
            uint tokenPrice = FVault( _fToken ).getPricePerFullShare();
            uint totalBal = balRP.mul(tokenPrice).div(1e18);
            require (amt < totalBal) ;
            uint amt2wd = amount.div(tokenPrice);
            RewardPool(_rewardPool).withdraw(amt2wd);
            FVault(vault).withdraw( amt2wd );
        }
        IERC20( token( 0 ) ).safeTransfer(to, amount);
        emit Withdraw( amount, forge(), block.timestamp);
    }

    function _fTokenBalanceOf() internal view returns( uint ){
        return IERC20(_fToken).balanceOf( address( this ) );
    }

    // 
    function _claimFarm() internal {
        RewardPool(_rewardPool).getReward();
    }

    function _swapFarmToUnderlying() internal {
    
        uint balance = IERC20(_farm).balanceOf(address(this));
        if (balance > 0) {

            IERC20(_farm).safeApprove(_uRouterV2, balance);
            
            address[] memory path = new address[](3);
            path[0] = address(_farm);
            path[1] = IUniswapV2Router02( _uRouterV2 ).WETH();
            path[2] = address( token( 0 ) );

            IUniswapV2Router02(_uRouterV2).swapExactTokensForTokens(
                balance,
                1,
                path,
                address(this),
                block.timestamp + ( 15 * 60 )
            );

            emit Swap(balance, underlyingBalanceInModel());
        }
    }

}