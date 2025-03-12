/**
 * @description       : Ticket Controller for handling ticket operations
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-11-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class TicketController {
    
    @AuraEnabled(cacheable=true)
    public static Id getPendingStatusId() {
        List<Ticket_Status__c> statusRecords = [
            SELECT Id FROM Ticket_Status__c WHERE Status_Name__c = 'Pending' LIMIT 1
        ];
        return (!statusRecords.isEmpty()) ? statusRecords[0].Id : null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Id getResolvedStatusId() {
        List<Ticket_Status__c> statusRecords = [
        SELECT Id FROM Ticket_Status__c WHERE Status_Name__c = 'Resolved' LIMIT 1
    ];
        return (!statusRecords.isEmpty()) ? statusRecords[0].Id : null;
    }
    @AuraEnabled
    public static void saveTicket(String ticketData, String userName) {
        try {
            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(ticketData);
            
            // Fetch "Pending" status ID
            Id pendingStatusId = getPendingStatusId();
            
            // 🔹 Fetch the actual User__c record using the Auto Number field
            List<User__c> userList = [
                SELECT Id FROM User__c WHERE User_Name__c	 = :userName LIMIT 1
            ];
            
            if (userList.isEmpty()) {
                throw new AuraHandledException('Error: No user found for Auto Number: ' + userName);
            }
            
            User__c userRecord = userList[0];
            
            // ✅ Create Ticket Record with Correct User ID
            Ticket__c ticket = new Ticket__c(
                Name = (String) data.get('name'),
            Ticket_Description__c = (String) data.get('description'),
            Ticket_Status__c = pendingStatusId,
            User__c = userRecord.Id , // ✅ Use the correct Salesforce record ID
            Ticket_Department__c= (String) data.get('department'),
            Department_Id__c	 = (String) data.get('departmentId'),
            Ticket_Status_Name__c='Pending'
                );
            
            insert ticket;
            System.debug('✅ Ticket Created: ' + ticket.Id);
        } catch (Exception e) {
            System.debug('❌ Error Creating Ticket: ' + e.getMessage());
            throw new AuraHandledException('Ticket creation failed: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Ticket__c> getUserTickets(String userName) {
        try {
            System.debug('🔹 Received userName: ' + userName);
            
            // Step 1: Fetch the User ID
            List<User__c> userList = [SELECT Id FROM User__c WHERE User_Name__c = :userName LIMIT 1];
            if (userList.isEmpty()) {
                throw new AuraHandledException('❌ No user found for User_Name__c: ' + userName);
            }
            Id userId = userList[0].Id;
            System.debug('✅ Found User ID: ' + userId);
            
            // Step 2: Get Role IDs from User_Role_Assignment__c
            List<Id> roleIds = new List<Id>();
            List<User_Role_Assignment__c> userRoles = [SELECT Role__c FROM User_Role_Assignment__c WHERE User__c = :userId];
            
            for (User_Role_Assignment__c roleAssignment : userRoles) {
                roleIds.add(roleAssignment.Role__c);
            }
            
            System.debug('✅ Found ' + roleIds.size() + ' roles for User: ' + roleIds);
            
            // Step 3: Check if the user is an Admin (assuming Admins have a special Role)
            Boolean isAdmin = roleIds.contains('Admin_Role_Id'); // Replace with actual Admin Role Id
            
            // Step 4: Fetch Tickets based on Role or Admin Access
            List<Ticket__c> tickets = new List<Ticket__c>();
            
            if (isAdmin) {
                // Admin sees all tickets
                tickets = [SELECT Id, Name, Ticket_Description__c, Ticket_Status__c, Ticket_Status_Name__c,
                                  Ticket_Department__c, Department_Id__c, Ticket_Id__c, CreatedById, 
                                  LastModifiedById, OwnerId, User__c, CreatedDate, LastModifiedDate
                           FROM Ticket__c 
                           ORDER BY CreatedDate DESC];
            } else {
                tickets = [SELECT Id, Name, Ticket_Description__c, Ticket_Status__c, Ticket_Status_Name__c,
                                  Ticket_Department__c, Department_Id__c, Ticket_Id__c, CreatedById, 
                                  LastModifiedById, OwnerId, User__c, CreatedDate, LastModifiedDate
                           FROM Ticket__c
                           WHERE User__c = :userId OR Department_Id__c IN :roleIds
                           ORDER BY CreatedDate DESC];
            }            
            System.debug('✅ Retrieved ' + tickets.size() + ' tickets');
            return tickets;
            
        } catch (Exception e) {
            System.debug('❌ Error Fetching Tickets: ' + e.getMessage());
            throw new AuraHandledException('Error Fetching Tickets: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Id> getUserRoles(String userName) {
        try {
            List<User__c> userList = [SELECT Id FROM User__c WHERE User_Name__c = :userName LIMIT 1];
            if (userList.isEmpty()) {
                throw new AuraHandledException('❌ No user found for User_Name__c: ' + userName);
            }
            
            Id userId = userList[0].Id;
            
            List<Id> roleIds = new List<Id>();
            List<User_Role_Assignment__c> userRoles = [SELECT Role__c FROM User_Role_Assignment__c WHERE User__c = :userId];
            for (User_Role_Assignment__c roleAssignment : userRoles) {
                roleIds.add(roleAssignment.Role__c);
            }
            
            return roleIds;
        } catch (Exception e) {
            System.debug('❌ Error Fetching User Roles: ' + e.getMessage());
            throw new AuraHandledException('Error Fetching User Roles: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void resolveTicketApex(Id ticketId) {
        try {
            Id resolvedStatusId = getResolvedStatusId();

            Ticket__c ticket = [SELECT Id, Ticket_Status__c, Ticket_Status_Name__c FROM Ticket__c WHERE Id = :ticketId LIMIT 1];
            
            // Update both status fields using the fetched Resolved ID
            ticket.Ticket_Status__c = resolvedStatusId;
            ticket.Ticket_Status_Name__c = 'Resolved';
            
            update ticket;
        } catch (Exception e) {
            throw new AuraHandledException('Error resolving ticket: ' + e.getMessage());
        }
    }
    
    
    
}