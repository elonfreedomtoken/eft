// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "netswap_OG/INetswapRouter.sol";
import "netswap_OG/INetswapFactory.sol";

contract EFT is ERC20, AccessControl {
    using SafeMath for uint256;
    address immutable NetswapFactory_address;
    address immutable NetswapRouter_address;
    address constant Metis_address = 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000;
    address payable immutable dev_address;
    bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");
    bytes32 public constant END_ICO_ROLE = keccak256("END_ICO_ROLE");
    bytes32 public constant STAKING_ROLE = keccak256("STAKING_ROLE");
    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");
    bytes32 public constant LIQUIDITY_ROLE = keccak256("LIQUIDITY_ROLE");

    uint256 public constant decimal = 18;
    uint256 public constant decimal_ending = 10**18;
    uint256 public constant maxSupply = 10000000 * decimal_ending;
    uint256 public totalMinted;
    uint256 public totalBurned;
    bool internal locked;

    uint256 public immutable timeDEPLOYED;
    uint256 public immutable icoLOCK;
    uint256 public immutable liquidityLOCK;
    uint256 public increaseLiquidityLockTime = 0;
    uint256 public immutable stakeLOCK;

    uint256 constant unix_week = 604800;
    uint256 constant unix_month = 2629743;
    uint256 constant unix_six_month = 2629743 * 6;
    
    uint8 constant ratioMetisICO = 128;
    uint8 constant ratioMetisLiquidityPool = 84;
    uint8 constant ratioLiquidity = 2;

    uint256 public constant maxICO = 2500000 * decimal_ending;
    uint256 public constant postICOsupply = 3320312 * decimal_ending;
    
    uint256 public burnRatio=1;
    uint256 public SoldInMetis;
    uint256 public SoldEFT;
    bool private BURNED = false;
    bool private ICO_Ended = false;
    uint256 public initialLiquidityTokens;
    address public LP_address;


    struct period{
        uint256 MaxAmount;
        uint256 CurrentAmount;
        uint256 timeValid;
        bool Active;
        bool burn_Ratio;
    }
    mapping(uint256=>period) BurnPeriods;
    mapping(uint256=>period) WithdrawPeriods;
    uint[] private dev_social_percents = [8, 10, 12, 10, 15, 20];

    constructor(address _n1, address _n2) ERC20("ElonFreedomToken", "EFT") {
        NetswapFactory_address= _n1;
        NetswapRouter_address = _n2;
        //set the times for ico length, liquiditylock, and staking
        timeDEPLOYED = block.timestamp;
        icoLOCK = block.timestamp + unix_month;
        liquidityLOCK = block.timestamp + unix_month + unix_six_month;
        stakeLOCK = block.timestamp + unix_month + unix_six_month + (unix_month * 4);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        dev_address = payable(msg.sender);
        establishMintPeriods();
        establishBurnPeriods();
    }
//modifiers

    modifier _noReentry() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier _timeCheck(){
        require(block.timestamp < icoLOCK,"ICO is over :( ");
        _;
    }

    modifier _endICO(){
        require(block.timestamp > icoLOCK,"ICO is still ongoing :( ");
        require(!ICO_Ended);
        _;
    }

    modifier _initPoolLock(){
        require(block.timestamp > icoLOCK + unix_month,"Supply locked for 1 month after pool creation");
        _;
    }
    
    modifier _lpLock(){
        require(block.timestamp > liquidityLOCK + increaseLiquidityLockTime, "must wait to remove lp");
        _;
    }

    modifier _stakeLOCK(){
        require(block.timestamp > stakeLOCK,"must wait to begin staking");
        _;
    }


//emit functions
    event LOG(string);
    event SOLD(uint256,address);
    event BURNEDSUPPLY(uint256);
    event LPCREATED(uint256,uint256);
    event BALANCES(uint256,uint256);
    event MINTED(uint256);
    event INCREASED_LP_LOCK(string,uint256);
/////////////////////

//contract functions
    function grantRolesArray(bytes32[] calldata _roles, address[] calldata _assignees) public onlyRole(DEFAULT_ADMIN_ROLE){
        for(uint i=0; i < _roles.length;i++){
            grantRole(_roles[i],_assignees[i]);
        }
    }

    function establishMintPeriods() private {
        WithdrawPeriods[0].Active=true;
        WithdrawPeriods[0].MaxAmount = 800000 * decimal_ending;
        WithdrawPeriods[0].timeValid = block.timestamp + unix_month + unix_six_month;
        WithdrawPeriods[0].burn_Ratio = false;
        for(uint i=1;i<=6;i++){
            WithdrawPeriods[i].Active = false;
            WithdrawPeriods[i].MaxAmount = 10000 * dev_social_percents[i-1] * decimal_ending;
            WithdrawPeriods[i].timeValid = block.timestamp + unix_month + unix_six_month.mul(i+1);
            WithdrawPeriods[i].burn_Ratio = true;
        }
    }

    function establishBurnPeriods() private {
        BurnPeriods[0].Active=true;
        BurnPeriods[0].MaxAmount = 1000000 * decimal_ending;
        BurnPeriods[0].timeValid = block.timestamp + unix_month;
        BurnPeriods[1].Active = false;
        BurnPeriods[1].MaxAmount = 1500000 * decimal_ending;
        BurnPeriods[1].timeValid = block.timestamp + (unix_month * 5);
        BurnPeriods[2].Active = false;
        BurnPeriods[2].MaxAmount = 1500000 * decimal_ending;
        BurnPeriods[2].timeValid = block.timestamp + (unix_month * 5) + unix_six_month;
    }

    function stake(address _to, uint256 _amnt) public _stakeLOCK onlyRole(STAKING_ROLE) {
        mint(_to, _amnt);
    }

    function mintToBurn(uint256 _amnt) private {
        mint(address(this), _amnt);
        burn(address(this), _amnt);
    }

    function mint(address _address, uint256 _amnt) private{
        require(totalMinted + _amnt  <= maxSupply, "tried to mint more than total supply");
        _mint(_address, _amnt);
        totalMinted += _amnt;
        emit MINTED(_amnt);
    }

    function burn(address _address, uint256 _amnt) private{
        _burn(_address, _amnt);
        totalBurned+=_amnt;
        emit BURNEDSUPPLY(_amnt);
    }

    function invDevSocialWithdraw(uint256 _amnt) public _initPoolLock onlyRole(DEV_ROLE){
        for(uint i =0; i<=6;i++){
            if(WithdrawPeriods[i].Active){
                if(WithdrawPeriods[i].timeValid > block.timestamp){
                    if(WithdrawPeriods[i].burn_Ratio){
                        WithdrawPeriods[i].MaxAmount = divByRatio(WithdrawPeriods[i].MaxAmount ,burnRatio);
                        WithdrawPeriods[i].burn_Ratio = false;
                    }

                    require(_amnt + WithdrawPeriods[i].CurrentAmount <= WithdrawPeriods[i].MaxAmount,"trying to withdraw too much");
                    mint(msg.sender, _amnt);
                    WithdrawPeriods[i].CurrentAmount += _amnt;
                    break;
                }else{
                    WithdrawPeriods[i].Active = false;
                    if(i+1<7){
                        WithdrawPeriods[i+1].Active = true;
                    }
                }
            }
        }
    }

    receive() external payable {
        emit LOG("receive hit");
        buy();
    }
    fallback() external payable{
        emit LOG("fallback hit");
        buy();
    }

    function buy() public payable _timeCheck _noReentry returns(bool){
        require(msg.value > 0," please send metis");
        uint256 buyAmount = msg.value.mul(ratioMetisICO) ;
        require(buyAmount + SoldEFT <= maxICO, "exceeds the total for sale during ICO");
        uint256 devcut = msg.value.div(2);
        (bool sent, bytes memory data) = dev_address.call{value: devcut}("");
        require(sent, "Failed to send Metis");
        mint(msg.sender,buyAmount);
        SoldEFT += buyAmount;
        SoldInMetis += msg.value;
        emit SOLD(buyAmount,msg.sender);
        return true;
    }

    function endICO() public onlyRole(END_ICO_ROLE) _endICO {
         burnRatio = createRatio(maxICO,SoldEFT);
         //burning unsold and what would be used for Liquidity Pool

        //createPool below
         LP_address = INetswapFactory(NetswapFactory_address).createPair(address(this) ,Metis_address);
         //add Liquidity
         uint256 liquidityEFT = addLiquidity();
        //calculate how much of liquidity not used  in pool to burn
        uint256 maxLiquidity = maxICO.div(ratioLiquidity).div(ratioMetisICO).mul(ratioMetisLiquidityPool);

        //calculate how much to burn from remaining supply
        uint256 restOfSupply =  postICOsupply - divByRatio(postICOsupply,burnRatio);

        uint256 burnAmnt = maxICO - SoldEFT + maxLiquidity - liquidityEFT + restOfSupply;
        if(burnAmnt > 0){
            mintToBurn(burnAmnt);
        }
        ICO_Ended = true;

    }

    function addLiquidity() private returns(uint256){
        uint256 metisLiquidity = address(this).balance;
        uint256 EFTLiquidity = metisLiquidity.mul(ratioMetisLiquidityPool);
        mint(address(this),EFTLiquidity);
        _approve(address(this), NetswapRouter_address, EFTLiquidity);
        (,,initialLiquidityTokens) = INetswapRouter(NetswapRouter_address).addLiquidityMetis{value: metisLiquidity}(
             address(this),
             EFTLiquidity,
             0,
             0,
             address(this),
             block.timestamp + 60
         );

        emit LPCREATED(EFTLiquidity,msg.value);
        return EFTLiquidity;
    }

    function transferLiquidity() public _lpLock onlyRole(LIQUIDITY_ROLE){
        IERC20(LP_address).approve(address(this),IERC20(LP_address).balanceOf(address(this)));
        IERC20(LP_address).transferFrom(address(this),msg.sender,IERC20(LP_address).balanceOf(address(this)));
    }

    function increaseLiquidityLock(uint256 _time) public onlyRole(LIQUIDITY_ROLE){
        increaseLiquidityLockTime += _time;
        emit INCREASED_LP_LOCK("Increased locked changed",increaseLiquidityLockTime + liquidityLOCK);
    }

    function burnPeriod(uint256 _amnt) public onlyRole(BURN_ROLE){
        for(uint i =0; i<3 ;i++){
            if(BurnPeriods[i].Active){
                if(BurnPeriods[i].timeValid > block.timestamp){
                    if(BurnPeriods[i].burn_Ratio){
                        BurnPeriods[i].MaxAmount = divByRatio(BurnPeriods[i].MaxAmount ,burnRatio);
                        BurnPeriods[i].burn_Ratio = false;
                    }
                    require(_amnt + BurnPeriods[i].CurrentAmount <= BurnPeriods[i].MaxAmount,"trying to burn too much");
                    mintToBurn(_amnt);
                    BurnPeriods[i].CurrentAmount += _amnt;
                    break;
                }else{
                    BurnPeriods[i].Active = false;
                    if(i+1<3){
                        BurnPeriods[i+1].Active = true;
                    }
                }
            }
        }

    }

    function createRatio(uint256 _a, uint256 _b) private returns(uint256){
        return _a.mul(100).div(_b);
    }

    function divByRatio(uint256 _a, uint256 _b) private returns(uint256){
        return _a.div(_b).mul(100);
    }


}