# LetterOfCredit_Ethereum
Its a digital letter of credit network project made to run on Ethereum protocol.

Letter of Credit Network


OVERVIEW

This network tracks letters of credit from application through to closure. 


GOALS

The primary aim is to digitalise the Letter of Credit (LC) paperwork process and create efficiencies by sharing that data using digital ledger technology (DLT) between corporates, their trading partners, and banks. Hence banks can make faster financing decisions, and there’s far less reconciliation between companies and their trading partners..

Tech Stack used:-

(1) Ethereum protocol
(2) Parity client ( Ethereum Client )
(3) Python Django Rest Framework and web3.py  ( proposed for backend system )


Letter of Credit Network components 

(1) User :- A user can be an individual or a company who wants to trade against a commodity 			through this network.

(2) Bank :- It can be any financial institution who deals with trade finance.

(3) Sales Contract :- It can be taken as pre trade agreement (MoU), which will be used to request		 letter of credit from the bank.

(4) Letter of Credit :- It is a document issued by the buyer's bank on behalf of him stating his 			integrity toward the trade.







Letter of Credit Process 


 Both parties agree on a certain points (monetary, quality, quantity, etc)  respective of their trade and the seller create an MoU or Sales Contract and send it to the Buyer. The function which will be used for this is :-
function createSalesContract(uint buyerID, uint sellerId,string memory commodity, uint weight, uint price, string memory grade, string memory deliveryDate, string memory additionalInfo, string memory createdOn) public returns(uint salesContractID)  
		
After it the Buyer accepts and show this sales contact to his bank and request for a letter of credit over it. The functions which will be used for this are :-
function AcceptSalesContract(uint salesContractID) public returns(bool success)
function requestLC(uint salesContractID, uint issuedOn, uint approvedAmount ) public returns(uint lcID) 
Buyers Bank can accept or reject this request. If accepted the amount stated in the letter of credit request will be deposited to an Escrow account between buyer and seller. The functions using which he can accept or reject the request are:-
function acceptLC(uint lcID) public returns(bool success)
function rejectLC(uint lcID) public returns(bool success) 
If buyer's  bank accept the letter of credit request then this letter of credit is created and sent to seller's bank for acceptance. Seller's bank can accept or reject the letter of credit. The functions which will be used for this acceptance and rejection are :-
function clientAcceptLC(uint lcID) public returns(bool success)
function clientRejectLC(uint lcID) public returns(bool success)   

 If seller's bank accepts the letter of credit then seller produces and deliver the goods to the buyer. After delivery and verification the seller change the status of the trade to delivered. If not received then the seller changes the trade status to not delivered. The functions which will be used in this are :-
function commodityReceived(uint lcID) public returns(bool success)
function commodityNotReceived(uint lcID) public returns(bool success)  

According to the status of the trade buyer's bank transfer the fund to seller's  account or refund it to the buyer's account . The functions used for these actions are:-
function clearFunds(uint lcID) public returns(bool success)
function refundFunds(uint lcID) public returns(bool success)  
