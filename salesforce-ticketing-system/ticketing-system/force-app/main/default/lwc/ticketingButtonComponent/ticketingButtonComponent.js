import { LightningElement, api } from 'lwc';

export default class TicketingButtonComponent extends LightningElement {
    @api label;   // Accepts the button label
    @api variant; // Accepts the button style (brand, success, etc.)

    handleClick() {
        console.log('Button clicked! Dispatching event.'); // Debugging
        this.dispatchEvent(new CustomEvent('buttonclick', {
            bubbles: true,  // Allows event to bubble up
            composed: true  // Allows event to cross shadow DOM
        }));
    }
}
