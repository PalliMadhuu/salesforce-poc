import { LightningElement,track } from 'lwc';

export default class HomeComponent extends LightningElement {
    @track isDrawerOpen = false;

    handleButtonClick() {
        this.isDrawerOpen = true;
    }}