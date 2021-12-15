import json

from solc import compile_standard
from web3 import Web3, EthereumTesterProvider
import web3
web3.eth.handleRevert = True

w3 = Web3(EthereumTesterProvider())
w3.eth.default_account = w3.eth.accounts[0]

def get_contract(filename, contract_name):

    with open(filename) as f:
        compiled_sol = compile_standard({
            "language": "Solidity",
            "sources": {
                filename: {
                    "content": f.read()
                }
            },
            "settings": {
                "outputSelection": {
                    "*": {
                        "*": [
                            "metadata", "evm.bytecode",
                            "evm.bytecode.sourceMap"
                        ]
                    }
                }
            }
        })
    
    # get bytecode
    bytecode = compiled_sol['contracts'][filename][contract_name]['evm']['bytecode']['object']
    # get abi
    abi = json.loads(compiled_sol['contracts'][filename][contract_name]['metadata'])['output']['abi']

    contract = w3.eth.contract(abi=abi, bytecode=bytecode)

    # Submit the transaction that deploys the contract
    tx_hash = contract.constructor().transact()
    # Wait for the transaction to be mined, and get the transaction receipt
    tx_receipt = w3.eth.getTransactionReceipt(tx_hash)

    return w3.eth.contract(
        address=tx_receipt.contractAddress,
        abi=abi
    )
