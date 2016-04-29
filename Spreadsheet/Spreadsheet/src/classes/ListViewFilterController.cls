/*
 *  ListViewFilterController for ListViewFilter page.
 *  NOTE - This class is controller for ListViewFilter page.
 *  @author - Suhas
 *  Date - 14/8/2015
 */
public with sharing class ListViewFilterController {

    public String viewNameString                    { get; set; }
    public String viewUniqueNameString              { get; set; }
    public SelectOption[] selectedFields            { get; set; }
    public List<SelectOption>displayUserFieldsList  { get; set; }

    public Id currentLoggedInUser;
    public String sObjectName;
    public String displayFields;

    //Default constructor. 
    public ListViewFilterController() {
        init();
    }

    //Initialization block.
    public void init() {
        currentLoggedInUser = UserInfo.getUserId();
        system.debug('currentLoggedInUser=====>>>'+currentLoggedInUser);
        sObjectName = apexpages.currentpage().getparameters().get('sObject');
        system.debug('sObjectName=====>>>>>'+sObjectName);
        displayUserFieldsList = new List<SelectOption>();
        selectedFields = new List<SelectOption>();
        getUserFields();
    }

    //Gets the fields which are accessible and editable by a user.
    public void getUserFields() {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = GlobalDescribeMap.get(sObjectName);
        Schema.DescribeSObjectResult dsr = sObjType.getDescribe() ;
        Map<String,Schema.SObjectField> fieldMap = dsr.fields.getMap() ;
        system.debug('fieldMap====>>>>>'+fieldMap);
        for(String field : fieldMap.keyset()) {
            Schema.DescribeFieldResult desribeResult = fieldMap.get(field).getDescribe();
            if(desribeResult.isCreateable() && desribeResult.isAccessible() && !desribeResult.isCalculated()) {    
                displayUserFieldsList.add(new SelectOption(desribeResult.getName(), desribeResult.getLabel()));       
            }
        }
    }

    public void saveConfigurationRecord() {
        system.debug('selectedFields====>>>>'+selectedFields);//displayFields
        system.debug('viewNameString===>>>'+viewNameString);
        Spreadsheet_User_List_View_Configuration__c objSULVC = new Spreadsheet_User_List_View_Configuration__c(); 
        objSULVC.Name = viewNameString;                        
        objSULVC.List_View_isSelected__c = false; 
        objSULVC.List_View_WhereClause__c = '';
        objSULVC.List_View_UserId__c = currentLoggedInUser;
        objSULVC.List_View_Unique_Name__c = SpreadsheetUtility.generateListViewUniqueName(currentLoggedInUser, sObjectName, viewNameString);  
        objSULVC.List_View_Select_Fields__c =  getCommaseparatedFields(selectedFields);
        objSULVC.List_View_Object_Name__c = sObjectName;
        Database.insert(objSULVC);
        system.debug('objSULVC====>>>>>'+objSULVC);
    }

    //This method is used for generating the string of comma separated fields.
    public String getCommaseparatedFields(SelectOption[] selectedFields) {
        String selectedCommaSeparatedFields = '';
        for(SelectOption objSO : selectedFields) {
            selectedCommaSeparatedFields += objSO.getValue();
            selectedCommaSeparatedFields += ', ';
        }
        selectedCommaSeparatedFields = selectedCommaSeparatedFields.removeEnd(', ');
        system.debug('selectedCommaSeparatedFields====>>>>'+selectedCommaSeparatedFields);
        return selectedCommaSeparatedFields;
    }
}