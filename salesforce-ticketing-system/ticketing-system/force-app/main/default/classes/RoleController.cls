/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-11-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class RoleController {
    @AuraEnabled(cacheable=true)
    public static List<Role__c> getRoles() {
        return [SELECT Id, Role_Name__c FROM Role__c WHERE Role_Name__c NOT IN ('Admin', 'User')];
    }
}
