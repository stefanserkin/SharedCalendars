import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import createEvent from '@salesforce/apex/SharedCalendarController.createEvent';

export default class SharedCalendarNewEvent extends LightningModal {
    /**
     * The record id of the shared calendar 
     * the event should be added to
     */
    @api calendarId;

    /**
     * Event type setting custom metadatas passed from parent component
     */
    @api eventTypeSettings;

    error;
    saveInProcess = false;

    /**
     * Event properties
     */
    subjectValue;
    typeValue;
    locationValue;
    startDateTimeValue;
    endDateTimeValue;

    /**
     * Getter in case its helpful to include dynamic data
     */
    get modalHeader() {
        return `Submit Event for Approval`;
    }

    /**
     * Available types
     */
    get typeOptions() {
        let options = [];
        if (this.eventTypeSettings != null && this.eventTypeSettings.length > 0) {
            this.eventTypeSettings.forEach(ets => {
                const option = {label: ets.MasterLabel, value: ets.MasterLabel};
                options.push(option);
            });
        }
        return options;
    }

    /**
     * Handle input
     */

    handleTypeChange(event) {
        this.typeValue = event.detail.value;
    }

    handleSubjectChange(event) {
        this.subjectValue = event.detail.value;
    }

    handleLocationChange(event) {
        this.locationValue = event.detail.value;
    }

    handleStartDateTimeChange(event) {
        this.startDateTimeValue = event.detail.value;
    }

    handleEndDateTimeChange(event) {
        this.endDateTimeValue = event.detail.value;
    }


    /**
     * Actions
     */

    handleCancel() {
        this.close('canceled');
    }

    handleClose() {
        this.close('success');
    }
    
    async handleSave() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if (allValid) {
            this.saveInProcess = true;
            // Create event obj
            let record = {};
            record.sobjectType = 'Event';
            record.WhatId = this.calendarId;
            record.Subject = this.subjectValue;
            record.Type = this.typeValue;
            record.Location = this.locationValue;
            record.StartDateTime = this.startDateTimeValue;
            record.EndDateTime = this.endDateTimeValue;
            record.IsVisibleInSelfService = false;
            record.Approval_Status__c = 'New';

            // Invoke apex method to insert event
            createEvent({obj: record})
                .then((result) => {
                    this.saveInProcess = false;
                    this.handleClose();
                }).catch((error) => {
                    this.error = error;
                    console.error(this.error);
                });
        }
    }

}