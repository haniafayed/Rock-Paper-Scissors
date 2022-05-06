
# Rock-Paper-Scissors
*A smart contract written in Solidity that can be usd to break a tie between two people and distribute some reward between them fairly.*

**

## Description of the protocol mechanism and requirements:



 - The smart contract is created by the contest manager. Upon creation,
   the manager deposits the reward and inputs the addresses of the two
   players.
 - A player is expected to enter a hash of his choice (“R”, “P”, “S” for
   “Rock”, “Paper”, “Scissors”) and some secret that they know. They are
   also required to enter a deposit to ensure completion of the game.

> Only the players with the addresses specified by the manager can
> participate in the game and make a choice.

 - Players are only allowed to make a choice before a certain time.
 - Players can then reveal their choice and secret to be able to receive
   their deposit back. 
   

> They are only allowed to reveal their choice after choosing time is
> over and before reveal time is over.

 - Choosing time and reveal time are specified by the manager at the
   beginning of the contract.
 - Only when reveal time is over, can the winner be computed.
 - The winner is computed by comparing the chosen strings of both
   players and deciding the winner according to the game rules. A tie
   results in the reward being split between both players, otherwise,
   the winner gets the entire reward.
 - If one of the players chose not to reveal their choice, they do not
   get their deposit back and the entire reward is sent to the other
   player.
 - Rewards are not paid directly to a winner’s address, instead they are
   stored in the contract as pending returns and the winner can withdraw
   them whenever they like, after the game is over.
