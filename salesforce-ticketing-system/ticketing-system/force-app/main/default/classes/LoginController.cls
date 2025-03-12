/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-10-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class LoginController {
    @AuraEnabled
    public static Map<String, String> authenticateUser(String username, String password) {
        Map<String, String> response = new Map<String, String>();
        try {
            // Fetch user details from the custom object
            User__c userRecord = [
                SELECT Name, User_Name__c, Password__c FROM User__c 
                WHERE User_Name__c = :username 
                LIMIT 1
            ];

            // Check if password matches
            if (userRecord != null && userRecord.Password__c == password) { 
                response.put('status', 'success');
                response.put('userId', userRecord.Name);  // Using Name instead of Id
                response.put('userName', userRecord.User_Name__c);
            } else {
                response.put('status', 'error');
                response.put('message', 'Invalid username or password');
            }
        } catch (Exception e) {
            response.put('status', 'error');
            response.put('message', 'Login failed: ' + e.getMessage());
        }
        return response;
    }
}
