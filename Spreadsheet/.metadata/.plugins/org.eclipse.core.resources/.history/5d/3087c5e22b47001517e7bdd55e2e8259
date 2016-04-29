/*
 *  Spreadsheet for Spreadsheet_V1 page  
 *  NOTE - This class has the functionality to fetch the Sobject records and display it on the page 
 *  @author - Suhas
 *  Date - 19/5/2015
 */

public with sharing class SpreadsheetController extends PaginationClass {

    //Map for storing the records of SpreadsheetSetting.
    public Map<String, SpreadsheetSetting__c> spreadSheetCSMap;

    //Map for storing the records of SpreadsheetObjectFieldSet.
    public Map<String, SpreadsheetObjectFieldSet__c> spreadsheetObjectFieldMap;

    //Map of feilds to display as header.
    public Map<String, String> fieldsSObjectMap { get; set; }

    //Set of feilds to display as header
    Set<String> fieldsToDisplaySet {get; set; }

    public String rowNumbersToDelete {get; set; }

    //Stores the objectnumber from the URL.
    public String objectNumberCustomSettingStr;

    //List of records to be displayed on page.
    public list<recordWrapper> sObjectRecordList { get; set;}

    //Saves current page number
    public integer currentPageNo {
                                    get{
                                        return pageNumber;
                                    }
                                    set;
                                 }

    //Saves last page number
    public integer lastPageNo {
                                    get{
                                        return lastPageNumber;
                                    }
                                    set;
                                 }
                                 
    public String objectName;

    String fieldSetObjectName = '';                                 

    //Map to save globla describe result
    Map<String, Schema.SObjectType> GlobalDescribeMap;

    //Determines if all the records on the page are selected
    public boolean isAllSelected{ get; set; }

    //Constructor.
    public SpreadsheetController() {

        init();
    }

    // Initialization block.
    public void init() {
        spreadSheetCSMap = new Map<String, SpreadsheetSetting__c>();
        spreadsheetObjectFieldMap = new Map<String, SpreadsheetObjectFieldSet__c>();
        fieldsSObjectMap = new Map<String, String>();
        sObjectRecordList = new list<recordWrapper>(); 
        objectNumberCustomSettingStr = '';
        rowNumbersToDelete = '';
        objectNumberCustomSettingStr = apexpages.currentpage().getparameters().get('ObjectNumber');
        system.debug('objectNumberCustomSettingStr====>> '+objectNumberCustomSettingStr);
        fieldsToDisplaySet = new Set<String>();
        isAllSelected = false;
        getCustomSetting();
        querySObject();
    }

    //To fetch the values from the custom setting.
    public void getCustomSetting() {

        spreadSheetCSMap = SpreadsheetSetting__c.getAll();
        system.debug('spreadSheetCSMap====>>> '+spreadSheetCSMap);

        spreadsheetObjectFieldMap = SpreadsheetObjectFieldSet__c.getAll();
        system.debug('spreadsheetObjectFieldMap====>>> '+spreadsheetObjectFieldMap);
    } 

    //Query to the Sobject is performed here.
    public void querySObject() {

        String query = createQuery();
        system.debug('query in querySObject =====>> '+query);
        if(!String.isBlank(query)) {
            List<sObject> lstRecords = Database.query(query);
            pageSize = 10;
            sObjectRecordList = getPaginatedRecords(lstRecords);
            //sObjectRecords = Database.query(query);
            system.debug('sObjectRecords =====>> '+sObjectRecordList);
            //sObjectRecords.setPageSize(100);
        }
    }

    //Creates the query for quering on the Sobject selected from the custom setting.
    public String createQuery() {

        String query = '';
        String commaSeperatedFieldStr = commaSeperatedFields();
        system.debug('commaSeperatedFieldStr====>> '+commaSeperatedFieldStr);
        String selectStr = 'Select ';
        String fromStr = ' From ';

        if(!String.isBlank(commaSeperatedFieldStr) && commaSeperatedFieldStr != '::') {
            if(! String.isBlank(commaSeperatedFieldStr.split('::')[0]) && !String.isBlank(commaSeperatedFieldStr.split('::')[1])) {
                query += selectStr;
                query += commaSeperatedFieldStr.split('::')[0];
                query += fromStr;
                query += commaSeperatedFieldStr.split('::')[1];
            }
        }
        system.debug('query=====>> '+query);
        return query;
    } 

    //Reads the field set from the custom setting and creates the string of comma separated string. 
    public String commaSeperatedFields() {

        String queryFieldsAndObject = '';
        String fieldsetObject = getFieldsetObject();
        String fieldSetName = '';

        system.debug('fieldsetObject====>> '+fieldsetObject);
        if(!String.isBlank(fieldsetObject)) {
            fieldSetName = fieldsetObject.split('::')[0];
            fieldSetObjectName = fieldsetObject.split('::')[1];
        }

        system.debug('fieldSetName====>> '+fieldSetName);
        system.debug('fieldSetObjectName====>> '+fieldSetObjectName);

        if(! String.isBlank(fieldSetName) && !String.isBlank(fieldSetObjectName)) {
            system.debug('This is the commaSeperatedFields if.....');
            //Reads the fieldset.
            GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(fieldSetObjectName);
            system.debug('SObjectTypeObj====>> '+SObjectTypeObj);
            
            if(SObjectTypeObj != null){
                Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
                system.debug('DescribeSObjectResultObj====>> '+DescribeSObjectResultObj);
                Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    
                system.debug('fieldSetObj.....  '+fieldSetObj);
                system.debug('This is the second debug in the commaSeperatedFields if.....');
                
                if(fieldSetObj != null) {
                    //Creates the string of comma separated fields and fills the map of fields. 
                    for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()) {
                        system.debug('This is the commaSeperatedFields if for.....'+ fieldSetMemberObj);
                        fieldsSObjectMap.put(fieldSetMemberObj.getFieldPath(), fieldSetMemberObj.getLabel());
                        queryFieldsAndObject += fieldSetMemberObj.getFieldPath() + ', ';
                    }
                    queryFieldsAndObject += getCommaSeparatedRequiredFields();
                    
                    queryFieldsAndObject = queryFieldsAndObject.removeEnd(', ');
                    system.debug('queryFieldsAndObject====>> '+queryFieldsAndObject);
                    system.debug('fieldsSObjectMap====>> '+fieldsSObjectMap);
                }            
            }
        }
        queryFieldsAndObject += '::' + fieldSetObjectName;
        system.debug('queryFieldsAndObject===>> '+queryFieldsAndObject);
        return queryFieldsAndObject;
    }
    
    //Read all required fields of the object except those in fieldset
    public string getCommaSeparatedRequiredFields(){
        string queryFieldsAndObject = '';

        Schema.SObjectType sObjType = GlobalDescribeMap.get(fieldSetObjectName) ;
        Schema.DescribeSObjectResult dsr = sObjType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = dsr.fields.getMap() ;
        List<String> lstrequiredfields = new List<String>();
        
        for(String f : fields.keyset())
        {
         Schema.DescribeFieldResult desribeResult = fields.get(f).getDescribe();
         if( desribeResult.isCreateable()  && !desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate() )
         {    
             if(!fieldsSObjectMap.containsKey(desribeResult.getName())){
                fieldsSObjectMap.put(desribeResult.getName(), desribeResult.getLabel());
                queryFieldsAndObject += desribeResult.getName() + ', ';          
             }

        
         }
        } 
        
        return queryFieldsAndObject;       
    }

    //Read the field set and object name from the Custom setting.
    public String getFieldsetObject() {
        boolean isValidObjectNumber = false;
        String fieldSetObjectStr = '';
        system.debug('objectNumberCustomSettingStr in getFieldsetObject====>>> '+objectNumberCustomSettingStr);
        
        for(SpreadsheetSetting__c spreadsheetSettingObj : SpreadsheetSetting__c.getAll().values()){
            if(spreadsheetSettingObj.ObjectNumber__c == Integer.valueOf(objectNumberCustomSettingStr))
                isValidObjectNumber = true;
        } 
               
        if(spreadSheetCSMap != null && isValidObjectNumber) {

            for(String str : spreadSheetCSMap.keySet()) {
                if(!String.isBlank(objectNumberCustomSettingStr) && spreadSheetCSMap.get(str).ObjectNumber__c == Integer.valueOf(objectNumberCustomSettingStr)) {
                    system.debug('spreadSheetCSMap.get(str).ObjectNumber__c====>> '+Integer.valueOf(spreadSheetCSMap.get(str).ObjectNumber__c));
                    system.debug('Integer.valueOf(objectNumberCustomSettingStr)====>> '+Integer.valueOf(objectNumberCustomSettingStr));
                    if(spreadsheetObjectFieldMap.containsKey(spreadSheetCSMap.get(str).SpreadsheetObject__c)) {
                        system.debug('This line is executed in getFieldsetObject in side if....');
                        fieldSetObjectStr = spreadsheetObjectFieldMap.get(spreadSheetCSMap.get(str).SpreadsheetObject__c).ObjectFieldSet__c;
                        fieldSetObjectStr += '::';
                        fieldSetObjectStr += spreadsheetObjectFieldMap.get(spreadSheetCSMap.get(str).SpreadsheetObject__c).Object__c;
                        objectName = spreadsheetObjectFieldMap.get(spreadSheetCSMap.get(str).SpreadsheetObject__c).Object__c;
                    }
                }
            }
        }
        else{
            ApexPages.Message msgInvalidObjectNumber = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Object Number.');
            ApexPages.addMessage(msgInvalidObjectNumber);        
        }
        system.debug('fieldSetObjectStr before return===>> '+fieldSetObjectStr);
        return fieldSetObjectStr;
    }
    
    public void addNewRecord(){
        lastRowCounter += 1;
        Schema.SObjectType t = GlobalDescribeMap.get(fieldSetObjectName); // obtain sObject description from the schema
        SObject newRecord = t.newSObject();
        recordWrapper recordObj = new recordWrapper(newRecord,lastRowCounter);
        sObjectRecordList.add(recordObj);
    }

    //This saves the current record displayed on the page.
    public void save() {
        sObject currentRecord;
        //system.debug('sObjectRecordList : ' + sObjectRecordList);
        string currentRowNumber = apexpages.currentpage().getparameters().get('currentRowNumber');  
        //system.debug('currentRowNumber : ' + currentRowNumber );
        //system.debug('sObjectRecordList : ' + sObjectRecordList);
        for(recordWrapper recordObj : sObjectRecordList ){
            if(recordObj.rowCounter == Integer.valueOf(currentRowNumber) )
                currentRecord = recordObj.record;
                
        }
        system.debug('currentRecord : '+currentRowNumber + '->' + currentRecord);
        if( currentRecord != null)  
            upsert currentRecord;
    }
    
    public void next(){
        sObjectRecordList = nextPage();
    }
    
    public void previous(){
        sObjectRecordList = previousPage();  
    }
    
    public void first(){
        sObjectRecordList = firstPage(); 
    }
    
    public void last(){
        sObjectRecordList = lastPage();  
    }           
    
    
    //Saves all the records of the current page
    public void savePage() {
        system.debug('sObjectRecords =====>> '+sObjectRecordList);
        
        if(sObjectRecordList != null && !sObjectRecordList.isEmpty()){
            List<sObject> lstRecordToInsert =  new List<sObject>();
            List<sObject> lstRecordToUpdate =  new List<sObject>();
                    
            for(recordWrapper recordWrapObj : sObjectRecordList){
                if(recordWrapObj.record.Id != null)
                    lstRecordToUpdate.add(recordWrapObj.record);
                else
                    lstRecordToInsert.add(recordWrapObj.record);                
            }
            
            if(!lstRecordToUpdate.isEmpty())
                update lstRecordToUpdate;
            if(!lstRecordToInsert.isEmpty())
                insert lstRecordToInsert;   
        }
        else{
            ApexPages.Message msgNoRecords = new ApexPages.Message(ApexPages.Severity.INFO,'INFO: There are no records on page to save.');
            ApexPages.addMessage(msgNoRecords);         
        }

    }
    
    //Deletes all the selected records
    public void deleteSelected(){
        system.debug('sObjectRecordList used to Delete1 : ' + sObjectRecordList);
        system.debug('rowNumbersToDelete : ' + rowNumbersToDelete);
        rowNumbersToDelete = rowNumbersToDelete.removeEnd(',');
        List<Database.DeleteResult> lstDeleteResult = new List<Database.DeleteResult>();
        map<integer,integer> mapRowRecordToRemoveFromList =  new map<integer,integer>();
        map<id,string> mapErroredIdMessage =  new map<id,string>();        
        List<integer> lstRowNumbers = new List<integer>();
        for(String rowNumber : rowNumbersToDelete.split(',')){
            mapRowRecordToRemoveFromList.put(integer.valueOf(rowNumber),integer.valueOf(rowNumber));
        }
        system.debug('rowNumbersToDelete : ' + mapRowRecordToRemoveFromList);
        
        integer noOfRecordsDeleted = 0;
        if(sObjectRecordList != null && !sObjectRecordList.isEmpty()){
            List<sObject> lstRecordToDelete =  new List<sObject>();
            for(recordWrapper recordWrapObj : sObjectRecordList){
                if(recordWrapObj.record.Id != null && mapRowRecordToRemoveFromList.containsKey(recordWrapObj.rowCounter)){
                    lstRecordToDelete.add(recordWrapObj.record);  
                }
            }
            if(!lstRecordToDelete.isEmpty()){
                lstDeleteResult = Database.delete(lstRecordToDelete,false);
                for(Database.DeleteResult dr : lstDeleteResult){
                   if(!dr.isSuccess()){
                       mapErroredIdMessage.put(dr.getId(),dr.getErrors()[0].getMessage());
                   }
                }
            }
           system.debug('sObjectRecordList before :' + sObjectRecordList.size());
           system.debug('lstDeleteResult==>' + lstDeleteResult);
           if(!mapRowRecordToRemoveFromList.isEmpty()){
                integer rowIndex = sObjectRecordList.size() - 1;
                while(rowIndex >= 0){
                    system.debug('mapErroredIdMessage.containsKey(sObjectRecordList[rowIndex].record.Id) : ' + mapErroredIdMessage.containsKey(sObjectRecordList[rowIndex].record.Id));
                    if(mapRowRecordToRemoveFromList.containsKey(sObjectRecordList[rowIndex].rowCounter) && !mapErroredIdMessage.containsKey(sObjectRecordList[rowIndex].record.Id)){
                        sObjectRecordList.remove(rowIndex);
                        noOfRecordsDeleted ++;
                    } 
                    rowIndex--;               
                }
                if(noOfRecordsDeleted > 0)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Number of rows deleted : ' + noOfRecordsDeleted));
            }
            
            system.debug('mapErroredIdMessage : ' + mapErroredIdMessage);
            
            if(!mapErroredIdMessage.isEmpty()){
                for(String errorMessage : mapErroredIdMessage.values())
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            }
        } else {
            ApexPages.Message msgNoRecords = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: There are no records on page to delete.');
            ApexPages.addMessage(msgNoRecords);         
        }  
        system.debug('noOfRecordsDeleted : ' + noOfRecordsDeleted);
        system.debug('sObjectRecordList :' + sObjectRecordList);
    }
    
    //Redirect to page 
    public Pagereference redirectToListViewFilter() {
        Pagereference pRef = new Pagereference('/apex/ListViewFilter?sObject='+objectName);
        pRef.setRedirect(true);
        return pRef;
    }
    
   /*  //Deletes all the selected records
    public void deleteSelected(){
        system.debug('sObjectRecordList used to Delete1 : ' + sObjectRecordList);
        integer noOfRecordsDeleted = 0;
        if(sObjectRecordList != null && !sObjectRecordList.isEmpty()){
            List<sObject> lstRecordToDelete =  new List<sObject>();
            map<integer,sObject> mapRowRecordToRemoveFromList =  new map<integer,sObject>();
                    
            for(recordWrapper recordWrapObj : sObjectRecordList){
                
                if(recordWrapObj.record.Id != null && recordWrapObj.isSelected){
                    lstRecordToDelete.add(recordWrapObj.record);  
                    mapRowRecordToRemoveFromList.put(recordWrapObj.rowCounter,recordWrapObj.record);                                   
                }

                else if(recordWrapObj.record.Id == null && recordWrapObj.isSelected)
                    mapRowRecordToRemoveFromList.put(recordWrapObj.rowCounter,recordWrapObj.record);                
            }
            
            if(!lstRecordToDelete.isEmpty())
                delete lstRecordToDelete;
            if(!mapRowRecordToRemoveFromList.isEmpty()){
                for(integer rowIndex = 0; rowIndex <= sObjectRecordList.size();rowIndex ++){
                    if(mapRowRecordToRemoveFromList.containsKey(sObjectRecordList[rowIndex].rowCounter)){
                        sObjectRecordList.remove(rowIndex);
                        noOfRecordsDeleted ++;
                        rowIndex--;
                    }
                }
            }
                  
        }
        else{
            ApexPages.Message msgNoRecords = new ApexPages.Message(ApexPages.Severity.INFO,'INFO: There are no records on page to delete.');
            ApexPages.addMessage(msgNoRecords);         
        }  
        system.debug('noOfRecordsDeleted : ' + noOfRecordsDeleted);
             
    }   */
}