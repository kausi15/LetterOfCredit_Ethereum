pragma solidity ^0.5.11;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract tradeFinance is Ownable {
    
    // struct of parties & assets
    
    // Bank Structure
    struct bank {
        string name;
        address rootAccount;
        mapping (address => uint) accountBalance;
        mapping (address => uint) escrow;
        mapping (address => user) users;
    }
    
    // User Structure
    struct user {
        string name;
        address accountAddress;
        uint Bank;
    }
    
    
    // Sales Contract Statuses
    enum scStatus { APPROVED, REJECTED, REQUESTED, DELIVERED, NOT_DELIVERED }
    
    // Sales Contract Structure
    struct salesContract {
        uint buyer;
        uint seller;
        address buyerAcc;
        address sellerAcc;
        string commodity;
        uint weight;
        uint price;
        string grade;
        string deliveryDate;
        string additionalInfo;
        string createdOn;
        bool locked;
        scStatus status;
    }
    
    // Letter of Credit Statuses
    enum lcStatus { APPROVED, REJECTED, REQUESTED, ENCASHED, REFUNDED } 
    enum secondBankAcceptance { ACCEPTED, REJECTED, MODIFICATION, REQUESTED}
    
    // Letter of Credit Structure
    struct letterOfCredit {
       uint salesContractID;
       string sellerName;
       uint sellerID;
       uint buyerID;
       string buyerName;
       string commodity;
       uint weight;
       uint price;
       string deliveryDate;
       uint approvedAmount;
       uint IssuerBank;
       uint clientBank;
       lcStatus status;
       secondBankAcceptance clientBankStatus;
       uint issuedOn;
    }
    
    uint numOfBank;
    uint numOfSalesContract;
    uint numOfletterOfCredits;
    uint numOfUser;
    
    // parties
    mapping (uint => bank) banks;
    mapping (uint => user) users;
    mapping (uint => salesContract) SalesContract;
    mapping (uint => letterOfCredit) LetterOfCredit;
    
    
    // Txn Events
    event bankAdded(string name, uint bankID);
    event userAdded(string name,address accountAddress,uint bankID);
    event salesContractCreated(uint salesContractID, uint sellerId, uint buyerID);
    event SalesContractAccepted(uint salesContractID,uint buyerID,uint sellerID);
    event SalesContractRejected(uint salesContractID,uint buyerID,uint sellerID);
    event lcRequested(uint lcID,uint buyerBank,uint buyerID,uint salesContractID,lcStatus status);
    event lcAccepted(uint lcID, uint clientBank,uint IssuerBank,uint seller,uint buyer, uint salesContractID);
    event clientLCAccepted(uint lcID, uint clientBank,uint IssuerBank,uint seller,uint buyer, uint salesContractID);
    event lcRejected(uint lcID,uint IssuerBank,uint buyer);
    event ClientLCRejected(uint lcID, uint clientBank,uint IssuerBank,uint seller,uint buyer, uint salesContractID);
    event deliveryReceived(uint lcID, uint clientBank,uint IssuerBank,uint seller,uint buyer, uint salesContractID);
    event deliveryNotReceived(uint lcID, uint clientBank,uint IssuerBank,uint seller,uint buyer, uint salesContractID);
    event fundTransfered(uint lcID, uint clientBank,uint IssuerBank,uint seller,uint buyer, uint salesContractID, uint amount);
    event fundReverted(uint lcID, uint clientBank,uint IssuerBank,uint seller,uint buyer, uint salesContractID, uint amount);
    
    
    //addBank Function 
    function addBank(string memory name, address bankAccount) onlyOwner() public returns (uint bankID) {
        bankID = numOfBank++;
        banks[bankID] = bank(name,bankAccount);
        emit bankAdded(name, bankID);
    }
    
    function addUser(string memory name,address accountAddress, uint bankID ) onlyOwner() public returns (uint userID) {
        userID = numOfUser++;
        users[userID] = user(name,accountAddress,bankID);
        emit userAdded(name,accountAddress,bankID);
    }
    
    function addBalance(uint userID, uint amount) onlyOwner() public returns(bool success){
        user storage u = users[userID];
        banks[u.Bank].accountBalance[u.accountAddress] += amount;
        return true;
    }
    
    function balanceOf(uint userID) view public returns(uint balance){
        user storage u = users[userID];
        balance = banks[u.Bank].accountBalance[u.accountAddress];
         
    }
    
    function userInfo(uint userID) view public returns(string memory name,address accountAddress,uint Bank){
        user storage u = users[userID];
        return(u.name,u.accountAddress,u.Bank);
    }
    
    
    function lcInfo(uint lcID) view public returns(uint salesContractID,uint sellerID,uint buyerID,string memory commodity,uint weight,uint price,string memory deliveryDate,uint approvedAmount,uint IssuerBank,
    uint clientBank,uint issuedOn){
        letterOfCredit storage lc = LetterOfCredit[lcID];
        return(lc.salesContractID,lc.sellerID,lc.buyerID,lc.commodity,lc.weight,lc.price,lc.deliveryDate
        ,lc.approvedAmount,lc.IssuerBank,lc.clientBank,lc.issuedOn);
    }
    
    function lcStatusInfo(uint lcID) view public returns(lcStatus status, secondBankAcceptance clientBankStatus) {
        letterOfCredit storage lc = LetterOfCredit[lcID];
        status=lc.status;
        clientBankStatus=lc.clientBankStatus;
    }
    
    
    function createSalesContract(uint buyerID, uint sellerId,string memory commodity, uint weight, 
    uint price, string memory grade, string memory deliveryDate, string memory additionalInfo, string memory createdOn) public returns(uint salesContractID) {
        require(msg.sender == users[sellerId].accountAddress, "Seller account address and Sales Contract creator account address is not same");
        salesContractID = numOfSalesContract++;
        SalesContract[salesContractID] = salesContract(buyerID,sellerId,users[buyerID].accountAddress,users[sellerId].accountAddress,
        commodity,weight,price,grade,deliveryDate,additionalInfo,createdOn,false,scStatus.REQUESTED);
        //emit salesContractCreated(buyerID,sellerId,users[buyerID].accountAddress,users[sellerId].accountAddress,
        //commodity,weight,price,grade,deliveryDate,additionalInfo,createdOn,scStatus.REQUESTED);
        emit salesContractCreated(salesContractID,sellerId ,buyerID);
    }
    
    function readSalesContract(uint salesContractID) view public returns(uint buyerID, uint sellerId,string memory commodity, uint weight, 
    uint price, string memory grade, string memory deliveryDate, string memory createdOn, scStatus status, address buyer_acc, address seller_acc) {
        salesContract storage sc = SalesContract[salesContractID];
        buyerID = sc.buyer;
        sellerId = sc.seller;
        commodity = sc.commodity;
        weight = sc.weight;
        price = sc.price;
        grade = sc.grade;
        deliveryDate = sc.deliveryDate;
        createdOn = sc.createdOn;
        status = sc.status;
        buyer_acc = sc.buyerAcc;
        seller_acc = sc.sellerAcc;
    }
    
    function readSalesContractPrivate(uint salesContractID) view public returns(uint buyerID, uint sellerId,string memory commodity, uint weight, 
    uint price, string memory grade, string memory deliveryDate, string memory additionalInfo, string memory createdOn, scStatus status) {
        
        salesContract storage sc = SalesContract[salesContractID];
        require(msg.sender == sc.buyerAcc || msg.sender == sc.sellerAcc,"This respective account doesn't have permissions to view the private data.");
        
        buyerID = sc.buyer;
        sellerId = sc.seller;
        commodity = sc.commodity;
        weight = sc.weight;
        price = sc.price;
        grade = sc.grade;
        deliveryDate = sc.deliveryDate;
        createdOn = sc.createdOn;
        status = sc.status;
        additionalInfo = sc.additionalInfo;
    }
    
    function readSalesContractPrivateAdmin(uint salesContractID) onlyOwner() view public returns(uint buyerID, uint sellerId,string memory commodity, uint weight, 
    uint price, string memory grade, string memory deliveryDate, string memory additionalInfo, string memory createdOn, scStatus status) {
        
        salesContract storage sc = SalesContract[salesContractID];
        
        buyerID = sc.buyer;
        sellerId = sc.seller;
        commodity = sc.commodity;
        weight = sc.weight;
        price = sc.price;
        grade = sc.grade;
        deliveryDate = sc.deliveryDate;
        createdOn = sc.createdOn;
        status = sc.status;
        additionalInfo = sc.additionalInfo;
    }
    
    function AcceptSalesContract(uint salesContractID) public returns(bool success) {
        salesContract storage sc = SalesContract[salesContractID];
        require(msg.sender == sc.buyerAcc, "Account address of the buyer and transactor is not same.");
        sc.locked = true;
        sc.status = scStatus.APPROVED;
        emit SalesContractAccepted(salesContractID,sc.buyer,sc.seller);
        return true;
        
    }
    
    function RejectSalesContract(uint salesContractID) public returns(bool success) {
        salesContract storage sc = SalesContract[salesContractID];
        if (msg.sender == sc.buyerAcc)
            return false;
        require(msg.sender == sc.buyerAcc, "Account address of the buyer and transactor is not same.");
        sc.locked = true;
        sc.status = scStatus.REJECTED;
        emit SalesContractRejected(salesContractID,sc.buyer,sc.seller);
        return true;
    }
    
    function requestLC(uint salesContractID, uint issuedOn, uint approvedAmount ) public returns(uint lcID) {
        salesContract storage sc = SalesContract[salesContractID];
        require(sc.buyerAcc == msg.sender, "The Account address of buyer in Sales Contract and transactor is not matching.");
        require(sc.status == scStatus.APPROVED && sc.locked == true, "The Sales Contract is not approved.");
        lcID = numOfletterOfCredits++;
        user memory buyer = users[sc.buyer];
        user memory seller = users[sc.seller];
        require(banks[buyer.Bank].accountBalance[buyer.accountAddress] >= sc.price, "The buyer doesn't have sufficient balance in account.");
        banks[buyer.Bank].accountBalance[buyer.accountAddress] = banks[buyer.Bank].accountBalance[buyer.accountAddress] - sc.price;
       
        banks[buyer.Bank].escrow[buyer.accountAddress] = sc.price;
        LetterOfCredit[lcID] = letterOfCredit(salesContractID, seller.name, sc.seller,
         sc.buyer,buyer.name, sc.commodity,sc.weight,sc.price,sc.deliveryDate,
        approvedAmount,buyer.Bank, seller.Bank,lcStatus.REQUESTED,secondBankAcceptance.REQUESTED,issuedOn ); 
        emit lcRequested(lcID,buyer.Bank,sc.buyer,salesContractID,lcStatus.REQUESTED);
    }
    
    function acceptLC(uint lcID) public returns(bool success) {
        letterOfCredit storage lc = LetterOfCredit[lcID];
        require(msg.sender == banks[lc.IssuerBank].rootAccount,"The transactor don't have permission to access this Letter of credit.");
        require(lc.status == lcStatus.REQUESTED, "Existing or rejected letter of credit.");
        lc.clientBankStatus = secondBankAcceptance.REQUESTED;
        lc.status = lcStatus.APPROVED;
        emit lcAccepted(lcID, lc.clientBank,lc.IssuerBank,lc.sellerID,lc.buyerID, lc.salesContractID);
        return true;
        
    }
    
    function rejectLC(uint lcID) public returns(bool success) {
        letterOfCredit storage lc = LetterOfCredit[lcID];
        salesContract storage sc = SalesContract[lc.salesContractID];
        require(msg.sender == banks[lc.IssuerBank].rootAccount,"The transactor don't have permission to access this Letter of credit.");
        require(lc.status == lcStatus.REQUESTED, "Letter of credit has been exhausted or approved.");
        lc.status = lcStatus.REJECTED;
        sc.status = scStatus.REJECTED;
        uint price = banks[lc.IssuerBank].escrow[users[lc.buyerID].accountAddress];
        banks[lc.IssuerBank].escrow[users[lc.buyerID].accountAddress] -= price;
        banks[lc.IssuerBank].accountBalance[users[lc.buyerID].accountAddress] += price;
        lc.status = lcStatus.REFUNDED;
        emit lcRejected(lcID,lc.IssuerBank,lc.buyerID);
        return true;
    }
    
    function clientAcceptLC(uint lcID) public returns(bool success) {
        letterOfCredit storage lc = LetterOfCredit[lcID];
        require(msg.sender == banks[lc.clientBank].rootAccount,"The transactor don't have permission to access this Letter of credit.");
        require(lc.clientBankStatus == secondBankAcceptance.REQUESTED, "Existing or rejected letter of credit.");
        lc.clientBankStatus = secondBankAcceptance.ACCEPTED;
        emit clientLCAccepted(lcID, lc.clientBank,lc.IssuerBank,lc.sellerID,lc.buyerID, lc.salesContractID);
        return true;
        
    }
    
    function clientRejectLC(uint lcID) public returns(bool success) {
        letterOfCredit storage lc = LetterOfCredit[lcID];
        salesContract storage sc = SalesContract[lc.salesContractID];
        require(msg.sender == banks[lc.clientBank].rootAccount,"The transactor don't have permission to access this Letter of credit.");
        require(lc.clientBankStatus == secondBankAcceptance.REQUESTED, "Existing or rejected letter of credit.");
        lc.clientBankStatus = secondBankAcceptance.REJECTED;
        sc.status = scStatus.REJECTED;
        uint price = banks[lc.IssuerBank].escrow[users[lc.buyerID].accountAddress];
        banks[lc.IssuerBank].escrow[users[lc.buyerID].accountAddress] -= price;
        banks[lc.IssuerBank].accountBalance[users[lc.buyerID].accountAddress] += price;
        lc.status = lcStatus.REJECTED;
        emit ClientLCRejected(lcID, lc.clientBank,lc.IssuerBank,lc.sellerID,lc.buyerID, lc.salesContractID);
        return true;
        
    }
    
    function commodityReceived(uint lcID) public returns(bool success) {
        letterOfCredit storage lc = LetterOfCredit[lcID];
        salesContract storage sc = SalesContract[lc.salesContractID];
        require(msg.sender == users[lc.buyerID].accountAddress,"The transactor don't have permission to change the status for this delivery.");
        sc.status = scStatus.DELIVERED;
        emit deliveryReceived(lcID, lc.clientBank,lc.IssuerBank,lc.sellerID,lc.buyerID, lc.salesContractID);
        return true;
    }
    
    function commodityNotReceived(uint lcID) public returns(bool success) {
        letterOfCredit storage lc = LetterOfCredit[lcID];
        salesContract storage sc = SalesContract[lc.salesContractID];
        require(msg.sender == users[lc.buyerID].accountAddress,"The transactor don't have permission to change the status for this delivery.");
        sc.status = scStatus.NOT_DELIVERED;
        emit deliveryNotReceived(lcID, lc.clientBank,lc.IssuerBank,lc.sellerID,lc.buyerID, lc.salesContractID);
        return true;
    }
    
    function clearFunds(uint lcID) public returns(bool success) {
        letterOfCredit storage lc = LetterOfCredit[lcID];
        salesContract storage sc = SalesContract[lc.salesContractID];
        require(msg.sender == banks[lc.IssuerBank].rootAccount, "The transactor is not the bank who issued the letter of credit.");
        require(lc.clientBankStatus == secondBankAcceptance.ACCEPTED,"The letter of credit is not been accepted by clients bank.");
        require(lc.status == lcStatus.APPROVED, "The letter of credit has been handelde or waiting for aprroval.");
        require(sc.status == scStatus.DELIVERED, "The commodity has not been delivered.");
        
        uint price = banks[lc.IssuerBank].escrow[users[lc.buyerID].accountAddress];
        banks[lc.IssuerBank].escrow[users[lc.buyerID].accountAddress] -= price;
        banks[lc.clientBank].accountBalance[users[lc.sellerID].accountAddress] += price;
        lc.status = lcStatus.ENCASHED;
        emit fundTransfered(lcID, lc.clientBank,lc.IssuerBank,lc.sellerID,lc.buyerID, lc.salesContractID,price);
        return true;
    }
    
    function refundFunds(uint lcID) public returns(bool success) {
        letterOfCredit storage lc = LetterOfCredit[lcID];
        salesContract storage sc = SalesContract[lc.salesContractID];
        require(msg.sender == banks[lc.IssuerBank].rootAccount, "The transactor is not the bank who issued the letter of credit.");
        require(lc.status == lcStatus.APPROVED, "Letter of credit has not been approved by buyers Bank.");
        require(lc.clientBankStatus == secondBankAcceptance.ACCEPTED, "Letter of credit has not been accepted by sellers bank.");
        require(sc.status == scStatus.NOT_DELIVERED, "Letter of credit has been rejected or the commodities is delivered or in-process.");
        uint price = banks[lc.IssuerBank].escrow[users[lc.buyerID].accountAddress];
        banks[lc.IssuerBank].escrow[users[lc.buyerID].accountAddress] -= price;
        banks[lc.IssuerBank].accountBalance[users[lc.buyerID].accountAddress] += price;
        lc.status = lcStatus.REFUNDED;
        emit fundReverted(lcID, lc.clientBank,lc.IssuerBank,lc.sellerID,lc.buyerID, lc.salesContractID,price);
        return true;
    }
    
}
