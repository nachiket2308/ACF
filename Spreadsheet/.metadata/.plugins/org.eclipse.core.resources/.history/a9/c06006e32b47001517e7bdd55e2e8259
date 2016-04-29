public with sharing class SpreadsheetUtility {
    //Generates the unique name for List view.
    public static String generateListViewUniqueName(String userName, String objectName, String viewName) {
        //Format of the Unique name - View Name + Object Name + User Name.
        system.debug('viewName utility======>>>>'+viewName.replaceAll('\\s+',' '));
        String uniqueName = '';
        uniqueName = viewName.replaceAll('\\s+','');
        uniqueName += objectName;
        uniqueName += userName;
        system.debug('uniqueName========>>>'+uniqueName); 
        return uniqueName;
    }
}