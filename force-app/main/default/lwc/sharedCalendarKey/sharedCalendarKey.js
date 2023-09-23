import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SharedCalendarNewEvent from 'c/sharedCalendarNewEvent';
import getEventTypeSettings from '@salesforce/apex/SharedCalendarController.getEventTypeSettings';
import IS_GUEST_USER from '@salesforce/user/isGuest';

export default class SharedCalendarKey extends LightningElement {
    @api sharedCalendarId;
    isLoading = false;
    error;

    isGuest = IS_GUEST_USER;

    wiredEventTypeSettings = [];
    eventTypeSettings;

    @wire(getEventTypeSettings)
    wiredResult(result) {
        this.isLoading = true;
        this.wiredEventTypeSettings = result;
        if (result.data) {
            let rows = JSON.parse( JSON.stringify(result.data) );
            rows.forEach(row => {
                let itemStyle = 'background-color:' + row.Calendar_Background_Color__c + 
                    ';color: ' + row.Calendar_Text_Color__c + 
                    ';border: 1px solid ' + row.Calendar_Border_Color__c + ';border-radius: 5px' + 
                    ';text-align: center;padding: 0.25rem 1rem 0.25rem 1rem';
                row.keyItemStyle = itemStyle;
            });
            this.eventTypeSettings = rows;
            this.error = undefined;
        } else if (result.error) {
            this.eventTypeSettings = undefined;
            this.error = result.error;
            console.error(this.error);
        }
    }

    /**
     * Open new event modal
     */
    async addNewEvent() {
        const result = await SharedCalendarNewEvent.open({
            size: 'small',
            description: 'Add a new event to the shared calendar',
            calendarId: this.sharedCalendarId,
            eventTypeSettings: this.eventTypeSettings
        });
        if (result == 'success') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!',
                    message: 'The event has been submitted for review',
                    variant: 'success',
                    mode: 'sticky'
                })
            );
        }
    }

}