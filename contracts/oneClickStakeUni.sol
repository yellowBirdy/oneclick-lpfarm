// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.6;

import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol";

import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IWETH.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/token/ERC20/IERC20.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/access/Ownable.sol";

/**
 * @title GetUniNDRLP
 * @dev Store & retrieve value in a variable
 */
contract GetUniNDRLP is Ownable {

    address public factory;
    address public router;
    address public NDR;


    
    constructor() public {
        router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
        NDR = 0x739763a258640919981F9bA610AE65492455bE53;
    }

    /**
     * @dev setFactory value in variable
     * @param _factory value to store
     */
    function setFactory(address _factory) external onlyOwner() {
        factory = _factory;
    } 
    /**
     * @dev setRouter value in variable
     * @param _router value to store
     */
    function setRouter(address _router) external onlyOwner() {
        router = _router;
    } /**
     * @dev setNdr value in variable
     * @param _ndr value to store
     */
    function setNdr(address _ndr) external onlyOwner() {
        NDR = _ndr;
    }
    
    
    /**
     * @dev getNDR Return qty of puchased LP 
     *
     * @param minNDRAmountOut expects a quote run externally and slippageTolerance applied to it to the the min
     * @param WETHAmount 

     **/
    function getNDR(uint WETHAmount, uint minNDRAmountOut) internal returns(uint256 NDRAmountOut) {
        IUniswapV2Router02 uniswapRouterV2 = IUniswapV2Router02(router);

        address WETH = uniswapRouterV2.WETH();
        address pair = UniswapV2Library.pairFor(factory, WETH, NDR);

        
                //check for slippage 
        (uint WETHReserve, uint NDRReserve) = UniswapV2Library.getReserves(factory, WETH, NDR);
        NDRAmountOut = UniswapV2Library.getAmountOut(WETHAmount, WETHReserve, NDRReserve);
        require (NDRAmountOut >= minNDRAmountOut, "GetUniNDRLP: INSUFFICIENT_OUTPUT_AMOUNT");
        
        //send half weth to pair
        
       IWETH(WETH).transfer(pair, WETHAmount);
       
        //swap half of weth to pair
        uint amount0out;
        uint amount1out;
        if (WETH < NDR ) {
            amount0out = 0;
            amount1out = NDRAmountOut;
        } else {
            amount0out = NDRAmountOut;
            amount1out = 0;
        }
        IUniswapV2Pair(pair).swap(amount0out, amount1out, address(this), new bytes(0));
        
    } 
    
    /**
    * @dev getLp Return qty of puchased LP 
    *
    * @param NDRAmount equivalent ndr
    * @param WETHAmount equivalent weth
    
    **/
    function getLp(uint WETHAmount, uint NDRAmount) internal returns(uint256) {
        IUniswapV2Router02 uniswapRouterV2 = IUniswapV2Router02(router);

        address WETH = uniswapRouterV2.WETH();
        address pair = UniswapV2Library.pairFor(factory, WETH, NDR);

    
        IWETH(WETH).transfer(pair, WETHAmount);
       
        IWETH(WETH).transfer(pair, msg.value/2);
        IERC20(NDR).transfer(pair, NDRAmount); 
        //mint(to: msg.sender) 
        return IUniswapV2Pair(pair).mint(msg.sender);
    } 
    /**
     * @dev getLP Return qty of puchased LP 
     *
     * @param minNDRAmountOut expects a quote run externally and slippageTolerance applied to it to the the min
     **/
     function swapGetLp(uint minNDRAmountOut) external payable returns(uint256) {
        IUniswapV2Router02 uniswapRouterV2 = IUniswapV2Router02(router);

        address WETH = uniswapRouterV2.WETH();
        
        //wrap eth

        //address pair = UniswapV2Library.pairFor(factory, WETH, NDR);

        IWETH(WETH).deposit{value : msg.value}();
        require(address(this).balance == 0 , "GetUniNDRLP: INSUFFICIENT_INPUT_AMOUNT");
        
        
        uint NDRAmount = getNDR(msg.value/2, minNDRAmountOut);
        return getLp(msg.value/2, NDRAmount);
        

        //check for slippage 
        //(uint WETHReserve, uint NDRReserve) = UniswapV2Library.getReserves(factory, WETH, NDR);
        //uint NDRAmountOut = UniswapV2Library.getAmountOut(msg.value/2, WETHReserve, NDRReserve);
        //require (NDRAmountOut >= minNDRAmountOut, "GetUniNDRLP: INSUFFICIENT_OUTPUT_AMOUNT");

 
        //send half weth to pair
        
       // IWETH(WETH).transfer(pair, msg.value/2);
         
             
        //swap half of weth to pair
        //uint amount0out;
        //uint amount1out;
        //if (WETH < NDR ) {
        //    amount0out = 0;
        //    amount1out = NDRAmountOut;
        //} else {
        //    amount0out = NDRAmountOut;
        //    amount1out = 0;
        //}
        //IUniswapV2Pair(pair).swap(amount0out, amount1out, address(this), new bytes(0));
        
        //send tokens back to pair
        //IWETH(WETH).transfer(pair, msg.value/2);
        //IERC20(NDR).transfer(pair, NDRAmountOut); 
        //mint(to: msg.sender) 
        //return IUniswapV2Pair(pair).mint(msg.sender);
        

     }
 
}

