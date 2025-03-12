import { LightningElement, wire, track } from 'lwc';
import getUserTickets from '@salesforce/apex/TicketController.getUserTickets';
import getUserRoles from '@salesforce/apex/TicketController.getUserRoles';
import resolveTicketApex from '@salesforce/apex/TicketController.resolveTicketApex';

export default class TicketTable extends LightningElement {
    @track userName;
    @track tickets = [];
    @track userRoles = [];
    @track columns = [];
    dataLoaded = { roles: false, tickets: false }; // Track data loading status

    defaultColumns = [
        { label: 'Ticket Name', fieldName: 'Name', type: 'text' },
        { label: 'Description', fieldName: 'Ticket_Description__c', type: 'text' },
        { label: 'Status Name', fieldName: 'Ticket_Status_Name__c', type: 'text' },
        { label: 'Department', fieldName: 'Ticket_Department__c', type: 'text' },
        { label: 'Ticket ID', fieldName: 'Ticket_Id__c', type: 'text' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date' }
    ];
    connectedCallback() {
        this.userName = sessionStorage.getItem('userName');
        if (!this.userName) {
            console.error(' No userName found in sessionStorage');
        }
        this.columns = [...this.defaultColumns]; // Initially, hide the action button
    }

    @wire(getUserRoles, { userName: '$userName' })
    wiredRoles({ error, data }) {
        if (data) {
            console.log('🔹 Raw Data from Apex:', JSON.stringify(data));
            this.userRoles = JSON.parse(JSON.stringify(data));
            console.log('✅ Processed User Roles:', this.userRoles);
            this.dataLoaded.roles = true;
            this.checkAndUpdateColumns();
        } else if (error) {
            console.error('❌ Error fetching user roles:', error);
        }
    }

    @wire(getUserTickets, { userName: '$userName' })
    wiredTickets({ error, data }) {
        if (data) {
            this.tickets = JSON.parse(JSON.stringify(data));
            console.log('✅ Tickets:', this.tickets);
            this.dataLoaded.tickets = true;
            this.checkAndUpdateColumns();
        } else if (error) {
            console.error('❌ Error fetching tickets:', error);
        }
    }

    checkAndUpdateColumns() {
        if (this.dataLoaded.roles && this.dataLoaded.tickets) {
            this.updateColumns();
        }
    }

    updateColumns() {
        // Define the action column with dynamic enable/disable logic
        this.actionColumn = {
            label: 'Action',
            type: 'button',
            fieldName: 'actionDisabled',
            typeAttributes: {
                label: 'Resolve',
                name: 'resolve',
                variant: 'brand',
                disabled: { fieldName: 'actionDisabled' }
            }
        };

        // Add the action column to the table
        this.columns = [...this.defaultColumns, this.actionColumn];

        // Update tickets with the "actionDisabled" field
        this.tickets = this.tickets.map(ticket => {

            const isDisabled = !this.userRoles.some(role => role === ticket.Department_Id__c) || ticket.Ticket_Status_Name__c === 'Resolved';
            return { ...ticket, actionDisabled: isDisabled };
        });

        console.log('✅ Updated Tickets:', this.tickets);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'resolve' && !row.actionDisabled) {
            this.resolveTicket(row.Id);
        }
    }

    resolveTicket(ticketId) {
        console.log(`Resolving ticket: ${ticketId}`);
    
        resolveTicketApex({ ticketId })
            .then(() => {
                console.log(`Ticket ${ticketId} successfully resolved in the database`);
    
                // Wait for the next ticket fetch (ensure data consistency)
                this.dataLoaded.tickets = false;
    
                return refreshApex(this.wiredTickets);
            })
            .catch(error => {
                console.error(' Error resolving ticket:', error);
            });
    }
    }
