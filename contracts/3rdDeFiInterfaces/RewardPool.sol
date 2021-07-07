pragma solidity 0.8.0;


interface RewardPool {

    function earned(address account) external view returns (uint256) ;

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount) external ;

    function withdraw(uint256 amount) external ;

    function exit() external ;

    function balanceOf(address account) external view returns (uint256) ;

    function getReward() external ;
}