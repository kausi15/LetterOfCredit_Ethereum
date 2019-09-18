## Ethereum smart contract deployment using python and web3.py

# import the required modules in a python file

    import json

    from web3 import Web3
    from solc import compile_standard

# Solidity source code:- Copy your solidity smart contract code and paste in the content part and name your code in source part.
     
     
     compiled_sol = compile_standard({
         "language": "Solidity",
         "sources": {
             ## Name of the smart contract ## "Greeter.sol": {
             ## Paste your smart contract here ## "content": '''
                     pragma solidity ^0.5.0;

                     contract Greeter {
                       string public greeting;

                           greeting = 'Hello';
                       }

                       function setGreeting(string memory _greeting) public {
                           greeting = _greeting;
                       }

                       function greet() view public returns (string memory) {
                           return greeting;
                       }
                     }
                   '''
             }
         },
         "settings":
             {
                 "outputSelection": {
                     "*": {
                         "*": [
                             "metadata", "evm.bytecode"
                             , "evm.bytecode.sourceMap"
                         ]
                     }
                 }
             }
     })

# web3.py instance :- You can connect to any ethereum chain using its IP and Port.
     w3 = Web3(Web3.HTTPProvider('http://url:port'))

# set pre-funded account as sender
     w3.eth.defaultAccount = w3.eth.accounts[0]

# get bytecode
     bytecode = compiled_sol['contracts']['Greeter.sol']['Greeter']['evm']['bytecode']['object']

# get abi
     abi = json.loads(compiled_sol['contracts']['Greeter.sol']['Greeter']['metadata'])['output']['abi']

     Greeter = w3.eth.contract(abi=abi, bytecode=bytecode)

# Submit the transaction that deploys the contract
     tx_hash = Greeter.constructor().transact()

# Wait for the transaction to be mined, and get the transaction receipt
     tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

     greeter = w3.eth.contract(
     address=tx_receipt.contractAddress,
     abi=abi
     )
# You can call functions by

     greeter.functions.greet().call()
     Output:- 'Hello'

     tx_hash = greeter.functions.setGreeting('Nihao').transact()
     tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
     greeter.functions.greet().call()
     Output:- 'Nihao'
     
# The full code look like

    import json

    from web3 import Web3
    from solc import compile_standard
    
    compiled_sol = compile_standard({
         "language": "Solidity",
         "sources": {
             ## Name of the smart contract ## "Greeter.sol": {
             ## Paste your smart contract here ## "content": '''
                     pragma solidity ^0.5.0;

                     contract Greeter {
                       string public greeting;

                           greeting = 'Hello';
                       }

                       function setGreeting(string memory _greeting) public {
                           greeting = _greeting;
                       }

                       function greet() view public returns (string memory) {
                           return greeting;
                       }
                     }
                   '''
             }
         },
         "settings":
             {
                 "outputSelection": {
                     "*": {
                         "*": [
                             "metadata", "evm.bytecode"
                             , "evm.bytecode.sourceMap"
                         ]
                     }
                 }
             }
     })
     
     w3 = Web3(Web3.HTTPProvider('http://url:port'))
     w3.eth.defaultAccount = w3.eth.accounts[0]
     bytecode = compiled_sol['contracts']['Greeter.sol']['Greeter']['evm']['bytecode']['object']
     abi = json.loads(compiled_sol['contracts']['Greeter.sol']['Greeter']['metadata'])['output']['abi']

     Greeter = w3.eth.contract(abi=abi, bytecode=bytecode)
     tx_hash = Greeter.constructor().transact()
     tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

     greeter = w3.eth.contract(
     address=tx_receipt.contractAddress,
     abi=abi
     )
     greeter.functions.greet().call()
     Output:- 'Hello'

     tx_hash = greeter.functions.setGreeting('Nihao').transact()
     tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
     greeter.functions.greet().call()
     Output:- 'Nihao'
     
# You can read more on https://web3py.readthedocs.io/en/stable/contracts.html 
