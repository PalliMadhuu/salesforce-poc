import { LightningElement, track } from 'lwc';
import authenticateUser from '@salesforce/apex/LoginController.authenticateUser';

export default class LoginPage extends LightningElement {
    @track username = '';
    @track password = '';
    @track errorMessage = '';

    handleUsernameChange(event) {
        this.username = event.target.value;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    async handleLogin() {
        try {
            const result = await authenticateUser({ username: this.username, password: this.password });
    
            if (result.status === 'success') {
                // Store user details in sessionStorage
                sessionStorage.setItem('userId', result.userId);
                sessionStorage.setItem('userName', result.userName);
    
                // Navigate to another page (adjust this as needed)
                window.location.href = '/lightning/page/home';
                this.errorMessage='';
            } else {
                this.errorMessage = result.message; 
            }
        } catch (error) {
            this.errorMessage = 'Error logging in';
        }
    }
    }
