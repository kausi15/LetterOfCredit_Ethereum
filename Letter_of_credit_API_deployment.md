## API deployment 


We will be using Django Rest framework for creating API's for Letter of credit system. 
The Flow of API will be:-

                                    
                                    API Request <--> API Layer <--> Ethereum Chain
    
  

We can learn more about django rest framework and its project deployment here https://www.django-rest-framework.org/#quickstart

As we have deployed a django project using earlier link we will be creating an api for sales contract requesting. We will be
using web3.py module for communicating with ethereum and the smart contract.

We will be writing this me in view.py file.

    import web3
    
    def getConnection():
        w3 = web3.Web3(web3.Web3.HTTPProvider('http://URL:Port'))
        return w3
        
    def getContract():
        w3 = getConnection()
        deployed_contract = w3.eth.contract(address = address_of_the smart_contract,
                            abi = ABI of the deployed contract)
        
        return w3
        
    class SalesContract(viewsets.APIViewSet):
    
        def Post(self,request):
            w3 = getContract()
            w3chain = getConnection()
            user_acc = request.data['user_account_address']
            nonce = w3.eth.getTransactionCount(user_acc) 
            txn_build=  w3.functions.createSalesContract(user.request['buyerID'], user.request['sellerId'],user.request['commodity'],
                        user.request['weight'], user.request['price'], user.request['grade'], user.request['deliveryDate'],
                        user.request['additionalInfo'], user.request['createdOn']) 
                        .buildTransaction({
                            'chainId': 1,
                            'gas': 70000,
                            'gasPrice': w3.toWei('1', 'gwei'),
                            'nonce': nonce,
                         })
            private_key = request.data['private_key']
            signed_txn = web3.eth.account.sign_transaction(txn_build, private_key=private_key)
            hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
            receipt = w3chain.getTransactionReceipt(hash)
            result = w3.events.salesContractCreated()..processReceipt(receipt)
            result = { "result" : result[0]['args'] }
            result = json.dumpps(result)
            return Response(result, status=status.HTTP_201_CREATED)
            
            
            
