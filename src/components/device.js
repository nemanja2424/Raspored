export const odrediUredjajA = () => {
    let uredjaj;
    const FSElement = document.getElementById('fs');
    const sirinaEk = window.innerWidth;
    
    if (sirinaEk >= 880) {
      uredjaj = "komp";
    } else {
      uredjaj = "tel";
    }
    //console.log(uredjaj)
    if (localStorage.getItem('sidebarStanje') !== null && uredjaj === "komp") {
      const sidebarStanje = localStorage.getItem('sidebarStanje');
      
      if (sidebarStanje === "skupljen") {
        FSElement.style.paddingLeft = '72px';
        FSElement.style.width = 'calc(100% - 72px)';
      } else {
        FSElement.style.paddingLeft = '200px';
        FSElement.style.width = 'calc(100% - 200px)';
      }
    } else {
      FSElement.style.width = '100%';
      FSElement.style.padding = '20px 0px';
    }
  };
  
  export const resizeListener = () => {
    window.addEventListener('resize', () => {
      const sirinaEk = window.innerWidth;
      if (sirinaEk <= 880 || sirinaEk >= 880) {
        odrediUredjajA();
      }
    });
  };
  