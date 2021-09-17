pragma solidity ^0.4.0;
contract Covid19usecase{
    address public data_contributor; 
    address public user; 
    address public Committee_chair;
    address public Committee_member1;
    address public Data_Access_Committee;
    address public Third_party;
    address public other_collaborator;
    enum contractState { 
        NotReady, Created, ReadyforRequireRequest, ReadyforSubmitRequest, ReadyforReview, Active, Inactive, Aborted, Terminate, Expire
    }   
    enum ThirdPartyPermissionState {
        NotReady, ReadyforReview, Active, Aborted, Terminate
    }
    contractState public state; 
    ThirdPartyPermissionState public Third_party_State; 
    uint startTime;
    uint daysAfter;
    int request_approval_result;
    uint remainTime;
    Contributor[] public contributor;
    Committee_member[] public committee_member;
    int violation=0;
    int prior_written_permission_for_third_party=0;
    //if the users is a researcher from authorized institution.
    int isResearcher=0;
    //if the request contains non-confidential research statement.
    int hasResearchStatement=0;
    //if the request contains project proposal.
    int hasProjectProposal=0;
    //if the request contains requested data access level.
    int hasDataLevel=0;
    int discover_violation1=0;
    int discover_violation2=0;
    int report_violation1=0;
    int report_violation2=0;
    int committee_check1=0;
    int committee_check2=0;
    uint discoverTime1;
    uint reportTime1;
    uint discoverTime2;
    uint reportTime2;
    uint contractInactiveTime;
    int recognize_Contribution=0;
    int isResearchStatementAvailable=0;
    int isProjectTitleAvailable=0;
    int isUserNameAvailable=0;
    int isAccessingInstitutionAvailable=0;
    uint inactiveTime;
    uint reactiveTime;
    
    
    
    struct Contributor {
        string _firstName;
        string _lastName;
    }
    
    struct Committee_member {
        string _firstName;
        string _lastName;
        int id;
    }
    
    //contructor
    constructor() public{
        startTime = block.timestamp;
        daysAfter = 1825; //5 years
        Data_Access_Committee= msg.sender;//address of sender;
        user = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        other_collaborator=0x17F6AD8Ef982297579C203069C1DbfFE4348c372;
        Third_party=0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678;
        
        data_contributor = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        Committee_chair=0x617F2E2fD72FD9D5503197092aC168c91465E7f2;
        Committee_member1=0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
        
        state = contractState.NotReady;
        request_approval_result = 0;
        Third_party_State=ThirdPartyPermissionState.NotReady;
    }
    
    //modifiers
    modifier onlyUser() {
        require(msg.sender == user, "Only user can call this.");
        _;
    }
    modifier onlyContributor() {
        require(msg.sender == data_contributor, "Only data contributor can call this.");
        _;
    }
    modifier inState(contractState _state) {
        require(state == _state, "Invalid state.");
        _;
    }
    /*
    modifier onlyCommittee() {
        require(msg.sender == Committee_chair, "Only Committee members can call this.");
        _;
    }*/
    
    modifier onlyDataAccessCommittee() {
        require(msg.sender == Data_Access_Committee, "Only Data Access Committee can call this");
        _;
    }
    
    modifier onlyOtherCollaborator() {
        require(msg.sender == other_collaborator, "Only Other collaborator can call this");
        _;
    }
    
    modifier onlyThirdParty(){
        require(msg.sender == Third_party, "Only Third_party can call this");
        _;
    }
    
    event RequestApprovalDone(string msg);//to announce result if the request submitted by users could be approved.
    //event ShowRemainingTime(uint remainingTime); 
    
    function addcontributor(string memory _firstName, string memory _lastName) public onlyContributor{
        contributor.push(Contributor(_firstName,_lastName));
    }
    
    function addMember(string memory _firstName, string memory _lastName, int id) public onlyContributor{
        contributor.push(Contributor(_firstName,_lastName));
    }
    
    //Clause1
    //For each proposed Research Project, User(s) agree(s) to submit a Data Use Request to the Data Access Committee 
    //for review and approval to access the Data.
    function CreateContract() public onlyDataAccessCommittee {
        require(state == contractState.NotReady);
            state = contractState.ReadyforRequireRequest; //once locked the container will do a self check on the sensors
            //RequireRequest(msg.sender); //trigger event
    }
    
    
    function RequireRequest() public onlyDataAccessCommittee {
        require(state == contractState.ReadyforRequireRequest);
            state = contractState.ReadyforSubmitRequest; //once locked the container will do a self check on the sensors
            
    }
    
    function UserSubmitRequest() public onlyUser {
        require(state == contractState.ReadyforSubmitRequest);
            state = contractState.ReadyforReview;
    }
    
    //add checklist.
    function Check_isResearcher() public onlyDataAccessCommittee {
        require(state == contractState.ReadyforReview);
        isResearcher=1;
    }
    
    function Check_hasResearchStatement() public onlyDataAccessCommittee {
        require(state == contractState.ReadyforReview);
        hasResearchStatement=1;
    }
    
    function Check_hasProjectProposal() public onlyDataAccessCommittee {
        require(state == contractState.ReadyforReview);
        hasProjectProposal=1;
    }
    
    function Check_hasDataLevel() public onlyDataAccessCommittee {
        require(state == contractState.ReadyforReview);
        hasDataLevel=1;
    }
    
    
    function ApproveRequest(int result) public onlyDataAccessCommittee {
        require((isResearcher==1)&&(hasResearchStatement==1)&&(hasProjectProposal==1)&&(hasDataLevel==1));
        request_approval_result = result;
        if(request_approval_result == 1){ //request is approved.
            state = contractState.Active;
            emit RequestApprovalDone("Request is Approved");
        }
        else if(request_approval_result == 0){ //request is not qpproved.
            state = contractState.Aborted;
            emit RequestApprovalDone("Contract Aborted: Failure."); 
             selfdestruct(msg.sender);
        }
            
    }
    
    //Clause2
    
    //User(s) agree(s) to not attempt to contact any individuals who are the subjects of the Data, any known living relatives, 
    //any Data Contributors, or healthcare providers unless required by law to maintain public health and safety. 
    //User(s) agree to report any unauthorized access use(s) or disclosure(s) of the Data to the Data Access Committee no later than 2 business days after discovery. 
    //The occurrence of a Data Access Incident may be ground for termination or suspension of any access to Data.
    
    //violation 1: If committee reports the users that contacted any individuals who are the subjects of the Data, any known living relatives, 
    //any Data Contributors, or healthcare providers, violation will be set to 1 and the contract will be aborted.
    
    //add committee also check for violation.
    
    
    //if user reports in 2 days, and the committee vertifies the violation, the smart contract would be inactive for 15 days.
    //if user does not report in 2 days, and the committee vertifies the violation, the smart contract would be aborted.
    function userDiscoverCollaboratorContactIndividuals() public onlyUser{
        require(state == contractState.Active);
        discoverTime1=block.timestamp;
        discover_violation1=1;
    }
    
    //report violation1
    function UserReportCollaboratorContactIndividuals() public onlyUser{
        require(discover_violation1==1);
        reportTime1=block.timestamp;
    }
    
    //committee check
    // committee will set committee_check1 to 1 or 0;
    function committeeCheckCollaboratorContactIndividuals(int result) public onlyDataAccessCommittee{
        require(state == contractState.Active);
        if(result==1){
            committee_check1=1;
        }
    }
    
    //set punishment
    function CollaboratorContactIndividualsSuspension() public onlyDataAccessCommittee{
        //implement smart contract be inactive for 15 days.
        if((reportTime1-discoverTime1<=2*1 days)&&(committee_check1==1)){
            state=contractState.Inactive;
            //start calculate inactive time.
            inactiveTime=block.timestamp;
        }
        if((reportTime1-discoverTime1>2*1 days)&&(committee_check1==1)){
            state=contractState.Aborted;
            emit RequestApprovalDone("Contract Aborted: Failure."); 
            selfdestruct(msg.sender);
        }
    }
    
    //check inactive time and turn the contract state to active if over 15 days.
    function stopInactive() public onlyDataAccessCommittee{
        reactiveTime=block.timestamp;
        if(reactiveTime-inactiveTime>=15 days){
            state=contractState.Active;
        }
    }
    
    /*
    function ReportUserContactIndividualsInData() public onlyOtherCollaborator{
        require(state == contractState.Active);
        violation=1;
    }*/
    
    /*
    function AbortedContract() public onlyDataAccessCommittee {
        require(violation==1);
        state = contractState.Aborted;
        emit RequestApprovalDone("Contract Aborted: Failure."); 
         selfdestruct(msg.sender);
    }*/
    
    //Clause3
    //User(s) shall not grant access to the Data to any third party without the prior written permission of the Data Access Committee.
    
    //User(s) require permission for granting access to the data to third party from the data committee.
    function RequirePermissionForThirdParty() public onlyUser{
        Third_party_State=ThirdPartyPermissionState.ReadyforReview;
    }
    
    //add integer input, set 0 or 1.
    function ApproveThirdPartyPermission(int result) public onlyDataAccessCommittee{
        require(Third_party_State==ThirdPartyPermissionState.ReadyforReview);
        if(result==1){
            Third_party_State=ThirdPartyPermissionState.Active;
        }
    }
    
    //Data Access Committee gives prior written permission.
    /*
    function GivePermission() public onlyDataAccessCommittee {
        require(state == contractState.Active);
        prior_written_permission_for_third_party=1;
    }*/
    //If the users report in 2 days, and the violation is vertified by the committee, only the third party permission will be aborted.
    
    //Else if the users does not report in 2 days, and the violation is vertified by the committee, the whole contract and the third mparty permission will be aborted.
    
    function userDiscoverThirdPartyViolation() public onlyUser{
        require(state == contractState.Active);
        discoverTime2=block.timestamp;
        discover_violation2=1;
    }
    
    //report violation2
    function userReportThirdPartyViolation() public onlyUser{
        require(discover_violation2==1);
        reportTime2=block.timestamp;
    }
    
    //committee check
    //if vertify, set result to 1; if not vertify, set result to 0.
    function committeeCheckThirdPartyViolation(int result) public onlyDataAccessCommittee{
        require(state == contractState.Active);
        if(result==1){
            committee_check2=1;
        }
    }
    
    //set punishment
    function ThirdPartyViolationTermination() public onlyDataAccessCommittee{
        if((reportTime2-discoverTime2<=2*1 days)&&(committee_check1==1)){
            Third_party_State=ThirdPartyPermissionState.Aborted;
        }
        else if((reportTime2-discoverTime2>2*1 days)&&(committee_check1==1)){
            Third_party_State=ThirdPartyPermissionState.Aborted;
            state=contractState.Aborted;
            emit RequestApprovalDone("Contract Aborted: Failure."); 
            selfdestruct(msg.sender);
        }
    }
    
    //Write a function for committee vertification.

    
    //violation 2: Committee member report that User grant access to the Data to any third party without the prior written permission of the Data Access Committee.
    /*
    function ReportUserGrantDataAccessToThirdParty() public onlyDataAccessCommittee {
        require(state == contractState.Active);
        //without the prior written permission.
        if(prior_written_permission_for_third_party==0){
            violation=1;
            state = contractState.Aborted;
            emit RequestApprovalDone("Contract Aborted: Failure."); 
             selfdestruct(msg.sender);
        }
    }*/

    
    //Clause4
    //The Data Use Request will remain in effect for a period of five (5) years from the Data Use Request Effective Date 
    //and will automatically expire at the end of this period unless terminated or renewed.
    
    function renewed() public onlyDataAccessCommittee{
        startTime=block.timestamp;
    }
    
    function DetectValid() public onlyDataAccessCommittee{
        require(state == contractState.Active);
        if(block.timestamp > startTime + daysAfter * 1 days){
            state = contractState.Expire;
        }
    }
    
    function terminateRequest() public onlyDataAccessCommittee{
        require(state == contractState.Active);
           state = contractState.Terminate;
           
    }
    
    function ShowRemainingTime() public{
        require(state == contractState.Active);
          remainTime=(daysAfter * 1 days)-(block.timestamp-startTime);
    }
    
    //Clause5
    //User(s) agree(s) to recognize the effort that Data Contributor(s) made in collecting and providing the Data and 
    //allow the following information in the approved Data Use Request to be made publicly available: 
    //non-confidential research statement of the Research Project, Project Title, Users’ names and Accessing Institution(s).
    function recognizeContribution() public onlyUser{
        require(state == contractState.Active);
          recognize_Contribution=1;
    }
    
    function researchStatementAvailable() public onlyUser{
        isResearchStatementAvailable=1;
    }
    
    function projectTitleAvailable() public onlyUser{
        isProjectTitleAvailable=1;
    }
    
    function userNameAvailable() public onlyUser{
        isUserNameAvailable=1;
    }
    
    function accessingInstitutionAvailable() public onlyUser{
        isAccessingInstitutionAvailable=1;
    }
    
    function AgreeContribution() public onlyDataAccessCommittee{
        if(recognize_Contribution==0||isResearchStatementAvailable==0||isProjectTitleAvailable==0||isUserNameAvailable==0||isAccessingInstitutionAvailable==0){
            contractState.Aborted;
        }
    }
    
}