import { LightningElement, api, track, wire } from 'lwc';
import saveTicket from '@salesforce/apex/TicketController.saveTicket';
import getRoles from '@salesforce/apex/RoleController.getRoles';

export default class SlideFormComponent extends LightningElement {
    @api isOpen = false; // Controlled by parent
    @track selectedDepartment = '';
    @track ticketName = '';
    @track ticketDescription = '';
    @track fileData = null;
    @track departmentOptions = [];
    @track selectedDepartmentName = '';

    @wire(getRoles)
    wiredRoles({ error, data }) {
        if (data) {
            this.departmentOptions = data.map(role => ({ label: role.Role_Name__c, value: role.Id }));
        } else if (error) {
            console.error('Error fetching roles:', error);
        }
    }

    handleDepartmentChange(event) {
        this.selectedDepartment = event.target.value;
        const selectedDepartmentObj = this.departmentOptions.find(department => department.value === event.target.value);
        this.selectedDepartmentName = selectedDepartmentObj ? selectedDepartmentObj.label : '';
    }

    handleNameChange(event) {
        this.ticketName = event.target.value;
    }

    handleDescriptionChange(event) {
        this.ticketDescription = event.target.value;
    }

    handleFileUpload(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            this.fileData = uploadedFiles[0].documentId; // Capture ContentDocumentId
            console.log('File Uploaded Successfully! Document ID:', this.fileData);
        }
    }

    async handleSave() {
        const userId = sessionStorage.getItem('userName');
        if (!userId) {
            console.log('User not authenticated');
            return;
        }
        
        if (!this.ticketName || !this.ticketDescription || !this.selectedDepartment) {
            this.showToast('Error', 'Please fill all required fields, including an image', 'error');
            return;
        }
    
        const ticketRecord = {
            name: this.ticketName,
            description: this.ticketDescription,
            department: this.selectedDepartmentName,
            fileData: this.fileData,
            departmentId: this.selectedDepartment,
        };
    
        try {
            await saveTicket({ ticketData: JSON.stringify(ticketRecord), userName: userId });
            this.showToast('Success', 'Ticket Created Successfully!', 'success');
            this.closeDrawer(); // Close drawer after successful save
        } catch (error) {
            console.error('Error creating ticket:', error);
            this.showToast('Error', 'Error creating ticket: ' + (error.body ? error.body.message : error.message), 'error');
        }
    }

    closeDrawer() {
        this.dispatchEvent(new CustomEvent('closedrawer')); // Notify parent component to close the drawer
    }
}
