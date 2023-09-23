public without sharing class SharedCalendarController {

    @TestVisible
    private static final String EVENT_RECORD_TYPE_NAME = 'CC_Calendar_Event';
    
    private static Id defaultOwnerId;
    private static Id eventRecordTypeId;
    
    @AuraEnabled(cacheable=true)
    public static List<Event_Type_Setting__mdt> getEventTypeSettings() {
        return [
            SELECT Id, 
                   MasterLabel, 
                   DeveloperName, 
                   Calendar_Background_Color__c, 
                   Calendar_Text_Color__c, 
                   Calendar_Border_Color__c
              FROM Event_Type_Setting__mdt
              WITH USER_MODE
             ORDER BY MasterLabel ASC
        ];
    }

    @AuraEnabled(cacheable=false)
    public static String createEvent(
        SObject obj
    ) {
        try {
            Event ev = (Event) obj;
            System.debug(ev);

            // Set record type id for shared calendar events
            ev.RecordTypeId = getEventRecordTypeId();

            // Set default owner to public calendar
            // If no public calendar is defined, set to system admin
            // Portal users cannot own event records
            ev.OwnerId = getDefaultOwnerId(ev.WhatId);

            // Insert event
            Database.insert(ev, AccessLevel.SYSTEM_MODE);

            // Return the record id for the new event
            return ev.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    private static Id getDefaultOwnerId(
        Id calendarId
    ) {
        if (defaultOwnerId == null) {
            List<Shared_Calendar__c> lstCalendars = [SELECT Public_Calendar_ID__c FROM Shared_Calendar__c WHERE Id = :calendarId WITH SYSTEM_MODE LIMIT 1];
            if (!lstCalendars.isEmpty() && lstCalendars.get(0).Public_Calendar_ID__c != null) {
                defaultOwnerId = lstCalendars.get(0).Public_Calendar_ID__c;
            } else {
                defaultOwnerId = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1].Id;
            }
        }
        return defaultOwnerId;
    }

    private static Id getEventRecordTypeId() {
        if (eventRecordTypeId == null) {
            eventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName()
                .get(EVENT_RECORD_TYPE_NAME).getRecordTypeId();
        }
        return eventRecordTypeId;
    }

}