public with sharing class Spreadsheet_V1_SController extends PaginationClass {
    
    /*All the get set variables declared*/
    //List of records to be displayed on page.
    public list<RecordWrapper> sObjectRecordList { get; set;}

    //Saves current page number
    public Integer currentPageNo {
                                    get{
                                        return pageNumber;
                                    }
                                    set;
                                 }

    //Saves last page number
    public Integer lastPageNo {
                                  get{
                                      return lastPageNumber;
                                  }
                                  set;
                              }

    //Map of feilds to display as header.
    public Map<String, String> fieldsSObjectMap { get; set; }

    public String rowNumbersToDelete { get; set; }

    //Determines if all the records on the page are selected
    public boolean isAllSelected{ get; set; }

    //Gets the selected value from the List View drop down.
    public String selectedListView { get; set; }

    //List of the list view option to be displayed.
    public List<SelectOption> listViewOptions { get; set; }

    /*All the public class level variables*/
    //Stores the objectnumber from the URL.
    //public String objectNumberCustomSettingStr;

    //Holds the object name from URL. 
    public String objectName;

    private String fieldSetObjectName = '';
    
    //Holds the user id of current logged in user.
    public String currentLoggedInUser;

    //Map to save globla describe result.
    private Map<String, Schema.SObjectType> GlobalDescribeMap;
    
    //Map of List view records 
    public Map<String, Spreadsheet_User_List_View_Configuration__c> mapSpreadsheetUserListViewConfiguration;

    //Constructor.
    public Spreadsheet_V1_SController() {
        init();
    }

    // Initialization block.
    public void init() {
        fieldsSObjectMap = new Map<String, String>();
        sObjectRecordList = new list<RecordWrapper>(); 
        objectName = '';
        rowNumbersToDelete = '';
        objectName = apexpages.currentpage().getparameters().get('ObjectName');
        currentLoggedInUser = UserInfo.getUserId();     
        system.debug('objectName====>> '+objectName);
        system.debug('currentLoggedInUser====>> '+currentLoggedInUser);
        isAllSelected = false;
        mapSpreadsheetUserListViewConfiguration = new Map<String, Spreadsheet_User_List_View_Configuration__c>();
        queryListViewObject();
        checkListViewSelectedValue();
    }

    /*Use Case 1 :
        On Page load check if the userId and object name is already there as a record in the Spreadsheet User List View Configuration object.
        If yes then proceed with filling of the List View drop down. If no then initialize a default view of required fields.
    */
    //Queries the List View Spreadsheet User List View Configuration object.
    public void queryListViewObject() {
        system.debug('This is querylistViewObject======>>>>');
        String queryListViewObjectStr = GenerateQuery.generateQuery('Spreadsheet_User_List_View_Configuration__c');
        system.debug('queryListViewObjectStr=====>>>>'+queryListViewObjectStr);
        if(!String.isBlank(queryListViewObjectStr)) {
            queryListViewObjectStr += ' where ';
            queryListViewObjectStr += ' list_view_userid__c =: currentLoggedInUser';
            queryListViewObjectStr += ' and ';
            queryListViewObjectStr += ' list_view_object_name__c =: objectName';
        }
        system.debug('queryListViewObjectStr==after where ==>>>'+queryListViewObjectStr);
        List<Spreadsheet_User_List_View_Configuration__c> listViewLst = new List<Spreadsheet_User_List_View_Configuration__c>();
        Spreadsheet_User_List_View_Configuration__c objSULVC = initiateListViewDefault();
        listViewLst.add(objSULVC);
        mapSpreadsheetUserListViewConfiguration.put(objSULVC.List_View_Unique_Name__c, objSULVC);
        if(!String.isBlank(queryListViewObjectStr) && !queryListViewObjectStr.startsWith(' where ')) {
            system.debug('This is inside queryListViewObjectStr if=====-=-==->>>');
            for(Spreadsheet_User_List_View_Configuration__c objSULVCLoop : Database.query(queryListViewObjectStr)) {
                listViewLst.add(objSULVCLoop);
            }
        }
        system.debug('listViewLst====>>>> '+listViewLst);
        if(!listViewLst.isEmpty()) {
            system.debug('This is listViewLst is not empty===>>>');
            for(Spreadsheet_User_List_View_Configuration__c objSULVCLoop : listViewLst) {
                mapSpreadsheetUserListViewConfiguration.put(objSULVCLoop.List_View_Unique_Name__c, objSULVCLoop);
            }
            getListView(listViewLst);
        } /*else {
            system.debug('This is listViewLst is empty===>>>');
            Spreadsheet_User_List_View_Configuration__c objSULVC = initiateListViewDefault();
            listViewLst.add(objSULVC);
            mapSpreadsheetUserListViewConfiguration.put(objSULVC.List_View_Unique_Name__c, objSULVC);
            getListView(listViewLst);
        }*/
        system.debug('mapSpreadsheetUserListViewConfiguration====>>>'+mapSpreadsheetUserListViewConfiguration);
    }

    //Populates the option list to be displayed in the List view on the page.
    public void getListView(List<Spreadsheet_User_List_View_Configuration__c> listViewLst) {
        system.debug('This is getListView===>>>>');
        system.debug('listViewLst in getListView===>>>'+listViewLst);
        List<SelectOption> options = new List<SelectOption>();
        listViewOptions = new List<SelectOption>();
        for (Spreadsheet_User_List_View_Configuration__c objsObject : listViewLst) {
            options.add(new SelectOption(objsObject.List_View_Unique_Name__c, objsObject.Name));        
        }
        system.debug('options====>>>>'+options);
        listViewOptions = options;
    }

    //If the userID and Object name not found in the record list of Spreadsheet User List View Configuration object,
    //then initiate the default view record.
    public Spreadsheet_User_List_View_Configuration__c initiateListViewDefault() {
        system.debug('This is the createListViewDefault===>>>');
        Spreadsheet_User_List_View_Configuration__c objDefaultSULVC = new Spreadsheet_User_List_View_Configuration__c();
        objDefaultSULVC.Name = objectName + ' Default View';
        objDefaultSULVC.List_View_isSelected__c = true;
        objDefaultSULVC.List_View_WhereClause__c = '';
        objDefaultSULVC.List_View_UserId__c = currentLoggedInUser;
        objDefaultSULVC.List_View_Unique_Name__c = SpreadsheetUtility.generateListViewUniqueName(UserInfo.getUserName(), objectName, 'Default View');
        objDefaultSULVC.List_View_Select_Fields__c =getCommaSeparatedRequiredFields();
        objDefaultSULVC.List_View_Object_Name__c =objectName;
        system.debug('objDefaultSULVC====>>>>>'+objDefaultSULVC);
        return objDefaultSULVC;
    }
    /*Use Case 1 ends here*/

    //Check if default default is present in the map.
    public void checkListViewSelectedValue() {
        system.debug('This is checkListViewSelectedValue===>>>');
        if(!String.isBlank(selectedListView)) {
        	system.debug('This is selectedListView not blank===>>>'+selectedListView);
            populateFieldsSObjectMap(mapSpreadsheetUserListViewConfiguration.get(selectedListView));
            querySobject(mapSpreadsheetUserListViewConfiguration.get(selectedListView));
        } else {
        	system.debug('This is selectedListView blank default===>>>');
            if(mapSpreadsheetUserListViewConfiguration.containsKey(SpreadsheetUtility.generateListViewUniqueName(UserInfo.getUserName(), objectName, 'Default View'))) {
                populateFieldsSObjectMap(mapSpreadsheetUserListViewConfiguration.get(SpreadsheetUtility.generateListViewUniqueName(UserInfo.getUserName(), objectName, 'Default View')));
                querySobject(mapSpreadsheetUserListViewConfiguration.get(SpreadsheetUtility.generateListViewUniqueName(UserInfo.getUserName(), objectName, 'Default View')));
            }
        }
    }

    //Populate the fields sobject Map of Sobject. This is used on page to display the table header and accordingly the values.
    public void populateFieldsSObjectMap(Spreadsheet_User_List_View_Configuration__c objSULVC) {
    	fieldsSObjectMap.clear();
        String[] fieldsLst = objSULVC.List_View_Select_Fields__c.split(', ');
        system.debug('fieldsLst====>>>>'+fieldsLst);
        Map<String, Schema.SObjectField> objectFieldsMap = new Map<String, Schema.SObjectField>();
        objectFieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        system.debug('objectFieldsMap======>>>>>>>>'+objectFieldsMap);
        for(String fieldKey : fieldsLst) {
            if(objectFieldsMap.containsKey(fieldKey)) {
                Schema.DescribeFieldResult objDfr = objectFieldsMap.get(fieldKey).getDescribe();
                fieldsSObjectMap.put(objDfr.getName(), objDfr.getLabel());
            }
        }
        system.debug('fieldsSObjectMap=====>>>>>'+fieldsSObjectMap);
    }

    //Query the sObject to fetch the records.
    public void querySobject(Spreadsheet_User_List_View_Configuration__c objSULVC) {
        String sObjectQueryStr = GenerateQuery.generateQuery(objSULVC);
        system.debug('sObjectQueryStr====>>>>'+sObjectQueryStr);
        if(!String.isBlank(sObjectQueryStr)) {
            List<sObject> lstRecords = Database.query(sObjectQueryStr);
            pageSize = 10;
            sObjectRecordList = getPaginatedRecords(lstRecords);
            system.debug('sObjectRecords =====>> '+sObjectRecordList);
        }
    }

    //Read all required fields of the object except those in fieldset.
    public string getCommaSeparatedRequiredFields() {
        system.debug('This is getCommaSeparatedRequiredFields====>>>>>>');
        String queryFieldsAndObject = '';
        GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult dsr = sObjType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = dsr.fields.getMap() ;
        for(String field : fields.keyset()) {
            Schema.DescribeFieldResult desribeResult = fields.get(field).getDescribe();
            if(desribeResult.isCreateable() && !desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate()) {    
                queryFieldsAndObject += desribeResult.getName() + ', ';          
            }
        }
        queryFieldsAndObject = queryFieldsAndObject.removeEnd(', ');
        system.debug('queryFieldsAndObject=====>>>>>'+queryFieldsAndObject);
        return queryFieldsAndObject;       
    }

    //Add the new record to the list. 
    public void addNewRecord() {
        lastRowCounter += 1;
        Schema.SObjectType t = GlobalDescribeMap.get(objectName); // obtain sObject description from the schema
        SObject newRecord = t.newSObject();
        RecordWrapper recordObj = new RecordWrapper(newRecord,lastRowCounter);
        sObjectRecordList.add(recordObj);
    }

    //This saves the current record displayed on the page.
    public void save() {
        sObject currentRecord;
        string currentRowNumber = apexpages.currentpage().getparameters().get('currentRowNumber');  
        for(RecordWrapper recordObj : sObjectRecordList ){
            if(recordObj.rowCounter == Integer.valueOf(currentRowNumber)) currentRecord = recordObj.record;
        }
        system.debug('currentRecord : '+currentRowNumber + '->' + currentRecord);
        if( currentRecord != null) upsert currentRecord;
    }

    //Methods for Pagination. Extended from Pagination class. 
    public void next() {
        sObjectRecordList = nextPage();
    }

    public void previous() {
        sObjectRecordList = previousPage();  
    }

    public void first() {
        sObjectRecordList = firstPage(); 
    }

    public void last() {
        sObjectRecordList = lastPage();  
    }           
    //Methods for Pagination ends here.

    //Saves all the records of the current page
    public void savePage() {
        system.debug('sObjectRecords =====>> '+sObjectRecordList);

        if(sObjectRecordList != null && !sObjectRecordList.isEmpty()){
            List<sObject> lstRecordToInsert =  new List<sObject>();
            List<sObject> lstRecordToUpdate =  new List<sObject>();

            for(RecordWrapper recordWrapObj : sObjectRecordList){
                if(recordWrapObj.record.Id != null) {
                    lstRecordToUpdate.add(recordWrapObj.record);
                } else {
                    lstRecordToInsert.add(recordWrapObj.record);
                }
            }
            if(!lstRecordToUpdate.isEmpty()) update lstRecordToUpdate;
            if(!lstRecordToInsert.isEmpty()) insert lstRecordToInsert;   
        } else {
            ApexPages.Message msgNoRecords = new ApexPages.Message(ApexPages.Severity.INFO,'INFO: There are no records on page to save.');
            ApexPages.addMessage(msgNoRecords);         
        }
    }

    //Deletes all the selected records
    public void deleteSelected() {
        system.debug('sObjectRecordList used to Delete1 : ' + sObjectRecordList);
        system.debug('rowNumbersToDelete : ' + rowNumbersToDelete);
        rowNumbersToDelete = rowNumbersToDelete.removeEnd(',');
        List<Database.DeleteResult> lstDeleteResult = new List<Database.DeleteResult>();
        map<integer,integer> mapRowRecordToRemoveFromList =  new map<integer,integer>();
        map<id,string> mapErroredIdMessage =  new map<id,string>();        
        List<integer> lstRowNumbers = new List<integer>();
        for(String rowNumber : rowNumbersToDelete.split(',')) {
            mapRowRecordToRemoveFromList.put(integer.valueOf(rowNumber),integer.valueOf(rowNumber));
        }
        system.debug('rowNumbersToDelete : ' + mapRowRecordToRemoveFromList);

        Integer noOfRecordsDeleted = 0;
        if(sObjectRecordList != null && !sObjectRecordList.isEmpty()) {
            List<sObject> lstRecordToDelete =  new List<sObject>();
            for(RecordWrapper recordWrapObj : sObjectRecordList) {
                if(recordWrapObj.record.Id != null && mapRowRecordToRemoveFromList.containsKey(recordWrapObj.rowCounter)){
                    lstRecordToDelete.add(recordWrapObj.record);  
                }
            }
            if(!lstRecordToDelete.isEmpty()) {
                lstDeleteResult = Database.delete(lstRecordToDelete,false);
                for(Database.DeleteResult dr : lstDeleteResult) {
                   if(!dr.isSuccess()) {
                       mapErroredIdMessage.put(dr.getId(),dr.getErrors()[0].getMessage());
                   }
                }
            }
            system.debug('sObjectRecordList before :' + sObjectRecordList.size());
            system.debug('lstDeleteResult==>' + lstDeleteResult);
            if(!mapRowRecordToRemoveFromList.isEmpty()) {
                integer rowIndex = sObjectRecordList.size() - 1;
                while(rowIndex >= 0){
                    system.debug('mapErroredIdMessage.containsKey(sObjectRecordList[rowIndex].record.Id) : ' + mapErroredIdMessage.containsKey(sObjectRecordList[rowIndex].record.Id));
                    if(mapRowRecordToRemoveFromList.containsKey(sObjectRecordList[rowIndex].rowCounter) && !mapErroredIdMessage.containsKey(sObjectRecordList[rowIndex].record.Id)){
                        sObjectRecordList.remove(rowIndex);
                        noOfRecordsDeleted ++;
                    } 
                    rowIndex--;               
               }
               if(noOfRecordsDeleted > 0) {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Number of rows deleted : ' + noOfRecordsDeleted));
               }
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
}