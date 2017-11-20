

const APP = {
  async init() {
    console.log('initialized');
    
    await BikeShare.init();
    
    console.log('bikeshare contract initialized');
    
    qs('#purchaseCredits').onclick = () => {
      BikeShare.purchaseCredits(1);
    }
    
  }
};

const qs = (sel) => document.querySelector(sel);

window.onload = APP.init;
