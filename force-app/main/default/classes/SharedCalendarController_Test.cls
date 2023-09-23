@IsTest
private class SharedCalendarController_Test {
    
    @IsTest
    static void testGetEventTypeSettings() {
        List<Event_Type_Setting__mdt> lstSettings;

        Test.startTest();
        lstSettings = SharedCalendarController.getEventTypeSettings();
        Test.stopTest();

        List<Event_Type_Setting__mdt> lstSettingsToVerify = Event_Type_Setting__mdt.getAll().values();

        Assert.areEqual(lstSettingsToVerify.size(), lstSettings.size(), 'Did not receive all available event type settings');
    }

    @IsTest
    static void testCreateEvent() {
        Shared_Calendar__c calendar = new Shared_Calendar__c(Name = 'Test Shared Calendar');
        insert calendar;

        Event record = new Event();
        record.WhatId = calendar.Id;
        record.Subject = 'Test Event';
        record.Type = 'Other';
        record.Location = 'Test Location';
        record.StartDateTime = Datetime.now().addDays(1);
        record.EndDateTime = Datetime.now().addDays(1).addHours(1);
        record.IsVisibleInSelfService = false;
        
        Id eventId;
        Test.startTest();
        eventId = SharedCalendarController.createEvent(record);
        Test.stopTest();

        Event refreshedEvent = [SELECT Id, Subject, WhatId FROM Event WHERE Id = :eventId LIMIT 1];

        Assert.areEqual(record.Subject, refreshedEvent.Subject, 'Received incorrect subject');
        Assert.areEqual(calendar.Id, refreshedEvent.WhatId, 'Event should be associated with shared calendar');
    }

    @IsTest
    static void testGetDefaultOwnerId() {
        String fakePublicCalendarId = '023000000000000001';
        Shared_Calendar__c calendar = new Shared_Calendar__c(
            Name = 'Test Shared Calendar', 
            Public_Calendar_ID__c = fakePublicCalendarId
        );
        insert calendar;

        String returnedId;
        Test.startTest();
        returnedId = SharedCalendarController.getDefaultOwnerId(calendar.Id);
        Test.stopTest();

        Assert.areEqual(fakePublicCalendarId, returnedId, 'Should have received provided public calendar id');
    }

    @IsTest
    static void testCreateEventWithDmlException() {
        Shared_Calendar__c calendar = new Shared_Calendar__c(Name = 'Test Shared Calendar');
        insert calendar;

        Event record = new Event();
        record.WhatId = calendar.Id;
        record.Subject = 'Test Event';
        record.Type = 'Other';
        record.Location = 'Test Location';
        record.StartDateTime = Datetime.now().addDays(1);
        record.IsVisibleInSelfService = false;
        record.Approval_Status__c = 'New';

        Boolean hasException = false;
        Test.startTest();
        try {
            Id eventId = SharedCalendarController.createEvent(record);
        } catch (Exception e) {
            hasException = true;
        }
        Test.stopTest();

        Assert.isTrue(hasException, 'Should have received an exception for not providing duration');
    }

}