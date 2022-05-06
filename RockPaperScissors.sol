// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract RockPaperScissors{

    address manager;
    address payable player1;
    address payable player2;

    uint256 public reward;
    uint public state;

    uint public choosingTime;
    uint public revealTime;

    struct Choice {
        bytes32 hashedChoice;
        uint256 deposit;
    }

    // The address of the person playing should be one of the addresses identfied by the manager.
    modifier onlyKnownPlayers(){
        require(msg.sender == player1 || msg.sender == player2);
        _;
    } 

    modifier onlyBefore(uint time) {
        require(block.timestamp <= time);
        _;
    }

    modifier onlyAfter(uint time) {
        require (block.timestamp >= time);
        _;
    }

    constructor(
        address payable _player1, 
        address payable _player2, 
        uint _choosingTime, 
        uint _revealTime
    ) 
        payable 
    {
        manager = msg.sender;
        reward = msg.value;
        player1 = _player1;
        player2 = _player2;
        choosingTime = block.timestamp + _choosingTime;
        revealTime = choosingTime + _revealTime;
    }

    mapping(address => Choice) hashedChoices;
    mapping(address => uint256) pendingReturns;
    mapping(address => string) choices;

    // Player inputs hashed choice.
    // A deposit is required to play.
    function choose(bytes32 hashedChoice) public payable onlyKnownPlayers onlyBefore(choosingTime) {
        require(msg.value > 0);
        hashedChoices[msg.sender] = Choice(hashedChoice, msg.value);
    }

    // Revealed choice is compared to previously input hashed choice.
    // Deposit can be returned if reveal is honest.
    function revealChoice(
        string memory _choice, 
        bytes32 secret
    ) 
        public 
        onlyAfter(choosingTime) 
        onlyBefore(revealTime) 
    {
        Choice memory choice = hashedChoices[msg.sender];
        if(keccak256(abi.encodePacked(_choice, secret)) == choice.hashedChoice){
            pendingReturns[msg.sender] = choice.deposit;
            choices[msg.sender] = _choice;
        }
    }
    
    // Choices of both players are compared to compute winner.
    // "P" beats "R", "R" beats "S", "S" beats "P"
    // state indicates who receives the reward: 1 indicates player1,
    // 2 indicates player2 & 0 indicates a tie. 
    function computeWinner() internal {

        if(bytes(choices[player1]).length == 0){
            state = 2;
        }
        else if(bytes(choices[player2]).length == 0){
            state = 1;
        }
        else if(keccak256(bytes(choices[player1])) == keccak256(bytes(choices[player2]))){
            state = 0;
        }
        else if( (keccak256(bytes(choices[player1])) == keccak256(bytes("R")) ) 
        && (keccak256(bytes(choices[player2])) == keccak256(bytes("P")))){
            state = 2;
        }
        else if((keccak256(bytes(choices[player1])) == keccak256(bytes("R"))) && 
        (keccak256(bytes(choices[player2])) == keccak256(bytes("S")))){
            state = 1;
        }
        else if( (keccak256(bytes(choices[player1])) == keccak256(bytes("S")) ) && 
        (keccak256(bytes(choices[player2])) == keccak256(bytes("R")))){
            state = 2;
        }
        else if((keccak256(bytes(choices[player1])) == keccak256(bytes("S"))) && 
        (keccak256(bytes(choices[player2])) == keccak256(bytes("P")))){
            state = 1;
        }
        else if( (keccak256(bytes(choices[player1])) == keccak256(bytes("P")) ) && 
        (keccak256(bytes(choices[player2])) == keccak256(bytes("R")))){
            state = 1;
        }
        else if((keccak256(bytes(choices[player1])) == keccak256(bytes("P"))) && 
        (keccak256(bytes(choices[player2])) == keccak256(bytes("S")))){
            state = 2;
        }
    }

    function revealWinner() public  onlyAfter(revealTime) {
        computeWinner();
        if(state == 0){
            pendingReturns[player1] += reward/2;
            pendingReturns[player2] += reward/2;
        }
        else if(state == 1){
            pendingReturns[player1] += reward;
        }
        else if(state == 2){
            pendingReturns[player2] += reward;
        }
    }

    function withdrawReturns() public {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0){
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }
}