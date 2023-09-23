# Asphalt Green Shared Calendars

## Making event records eligible for the Master Calendar

Access to events is granted via a Sharing Rule on the Shared Calendar object. The Guest User profile is granted access whenever it has a Related To/WhatId of a Shared Calendar with its Public flag checked.

When staff submit records for approval, the Shared Calendar lookup of the Event record is populated, but not the WhatId. When an Event record has its Approval Status set to ‘Approved’, the Public flag is checked and the WhatId is set to the Shared Calendar, enabling public access.

## Sharing calendar to all staff

The calendar must be accessible to internal and external users. Public Calendars should allow us to easily open up sharing access. A record-triggered flow looks for newly created Events related to a Shared Calendar with a defined Public Calendar ID. If found, the Public Calendar is set as the OwnerId of the Event, adding it to the public Calendar record.

## Default Event Styles

Default event styles can be defined by Event Type. Create an Event Type Setting custom metadata record for each Type value.


## Docs

- [Quip](https://quip.com/HJejArp9qrcb/Asphalt-Green-Shared-Calendars)
