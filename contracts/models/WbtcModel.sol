// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/ModelInterface.sol";
import "../ModelStorage.sol";
import "../3rdDeFiInterfaces/Vault.sol";

contract WbtcModel is ModelInterface, ModelStorage{
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    event Invest( uint balanceInUnderlying, uint timestamp);
    event Withdraw( uint amount, address forge, uint timestamp);

    Vault vault;
    address _yToken;
    address _uRouterV2;

    function initialize( 
        address forge_, 
        address token_,
        address yTok,
        address _vault,
        address uRouterV2_ ) public {

            addToken( token_ );
            setForge( forge_ );
            vault        = Vault(_vault);
            _yToken = yTok;
            _uRouterV2      = uRouterV2_;

    }

    function underlyingBalanceInModel() public override view returns ( uint256 ){
        return IERC20( token( 0 ) ).balanceOf( address( this ) );
    }

    function underlyingBalanceWithInvestment() public override view returns ( uint256 ){
        // Hard Work Now! For Punkers by 0xViktor
        return underlyingBalanceInModel().add( CTokenInterface(vault ).pricePerFullShare().mul( _yTokenBalanceOf() ).div( 1e18 ) );
    }

    function invest() public override {
        
        IERC20( token( 0 ) ).safeApprove( address(vault), underlyingBalanceInModel() );
        vault.depositAll();
        emit Invest( underlyingBalanceInModel(), block.timestamp );
    }

    function withdrawAllToForge() public OnlyForge override{
        vault.withdrawAll();
        uint balance = IERC20(token(0)).balanceOf(address(this));
        IERC20(token(0)).safeTransfer(forge(), balance);

        emit Withdraw(  underlyingBalanceWithInvestment(), forge(), block.timestamp);
    }

    function withdrawToForge( uint256 amount ) public OnlyForge override{
        withdrawTo( amount, forge() );
    }

    function withdrawTo( uint256 amount, address to ) public OnlyForge override{
        
        uint oldBalance = IERC20( token(0) ).balanceOf( address( this ) );
        vault.withdraw(amount);
        uint newBalance = IERC20( token(0) ).balanceOf( address( this ) );
        require(newBalance.sub( oldBalance ) > 0, "MODEL : REDEEM BALANCE IS ZERO");
        IERC20( token( 0 ) ).safeTransfer( to, newBalance.sub( oldBalance ) );
        
        emit Withdraw( amount, forge(), block.timestamp);
    }

    function _yTokenBalanceOf() internal view returns( uint ){
        return CTokenInterface( _yToken ).balanceOf( address( this ) );
    }



}