/*
 *  This is a utility class with the methods for generating the queries for Sobjects.
 *  NOTE - This is a utility class with the methods for generating the queries for Sobjects.
 *  @author - Suhas
 *  Date - 18/08/2015
 */
public with sharing class GenerateQuery {
	
    public static final String SELECTSTR = ' select ';
    public static final String FROMSTR = ' from '; 
    
    //Creates the query for quering on the Sobject selected from the custom setting.
    public static String generateQuery(String objectName) {
        String query = '';
        String commaSeperatedFieldStr = commaSeperatedFields(objectName);
        system.debug('commaSeperatedFieldStr====>> '+commaSeperatedFieldStr);

        if(!String.isBlank(commaSeperatedFieldStr)) {
            query += SELECTSTR;
            query += commaSeperatedFieldStr;
            query += FROMSTR;
            query += objectName;
        }
        system.debug('query=====>> '+query);
        return query;
    }

    //Creates the query for sObject taking Spreadsheet User List View Configuration object.
    public static String generateQuery(Spreadsheet_User_List_View_Configuration__c objSULVC) {
        system.debug('This is GenerateQuery generateQuery====>>>>');
        String querySobject = '';
        querySobject += SELECTSTR;
        if(!String.isBlank(objSULVC.List_View_Select_Fields__c)) {
            querySobject += objSULVC.List_View_Select_Fields__c;
        } else {
            querySobject += objSULVC.Id;
        }
        querySobject += FROMSTR;
        querySobject += objSULVC.List_View_Object_Name__c;
        if(!String.isBlank(objSULVC.List_View_WhereClause__c)) {
            querySobject += objSULVC.List_View_WhereClause__c;
        }
        system.debug('querySobject===>>>>'+querySobject);
        return querySobject;
    }

    //Method gets all the fields of the sObject.
    public static String commaSeperatedFields(String objectName) {
        Map<String, Schema.SObjectField> objectFieldsMap = new Map<String, Schema.SObjectField>();
        objectFieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        string sObjectFields = '';
        for (String field : objectFieldsMap.keySet()) {
            if ((objectFieldsMap.get(field).getDescribe().isAccessible())) {
                sObjectFields += String.escapeSingleQuotes(field);
                sObjectFields += ',';
            }
        }
        sObjectFields = sObjectFields.removeEnd(',');
        return sObjectFields;
    }
}