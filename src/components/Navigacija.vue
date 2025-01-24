<script setup>
import { ref, onMounted, provide } from 'vue';
import { RouterLink, useRouter } from 'vue-router';

const sidebarStanje = ref("");
const uredjaj = ref("");
const router = useRouter();
const userID = ref();
const rolaLS = localStorage.getItem('rola');



onMounted(() => {
    userID.value = localStorage.getItem("userID");
    odrediUredjaj();
});

const odrediUredjaj = () => {
    const sirinaEk = window.innerWidth;
    if(sirinaEk >= 880){
        uredjaj.value = "komp";
    } else {
        uredjaj.value = "tel";
    }
    //console.log(uredjaj.value);

    const sidebar = document.getElementById('sidebar');
    if (uredjaj.value === "komp"){
        if (localStorage.getItem('sidebarStanje') !== null) {
            sidebarStanje.value = localStorage.getItem('sidebarStanje');

            const tekst = document.querySelectorAll('.tekst');
            const ikona = document.getElementById('sidebarIkona');
            
            if (sidebarStanje.value === "skupljen") {
                tekst.forEach(el => {
                    el.style.display = 'none';
                });
                sidebar.style.width = '1%';
                ikona.style.transform = 'rotate(90deg)';
            } else {
                sidebar.style.width = '20%';
                tekst.forEach(el => {
                    el.style.display = 'flex';
                });
                ikona.style.transform = 'rotate(270deg)';
            }
        } 
        else {
            localStorage.setItem('sidebarStanje', 'rasiren');
            sidebar.style.width = '20%';
        }
    }
}

window.addEventListener('resize', () => {
    const sirinaEk = window.innerWidth;

    if (sirinaEk <= 880) {
        odrediUredjaj();
        //console.log("tel");
    } else {
        odrediUredjaj();
        //console.log("komp");
    }
});

const toggleSidebar = () => {
    const tekst = document.querySelectorAll('.tekst');
    const ikona = document.getElementById('sidebarIkona');
    const sidebar = document.getElementById('sidebar');

    if (uredjaj.value === "komp"){
    
        sidebar.style.width = sidebarStanje.value === "rasiren" ? "1%" : "20%";

        sidebarStanje.value = sidebarStanje.value === "rasiren" ? "skupljen" : "rasiren";

        const FSElement = document.getElementById('fs');
        if (FSElement) {
            FSElement.style.paddingLeft = sidebarStanje.value === "rasiren" ? "200px" : "72px";
            FSElement.style.width = sidebarStanje.value === "rasiren" ? 'calc(100% - 200px)' : 'calc(100% - 72px)';
            FSElement.style.transition = 'all 0.3s ease';
        }
        
        
        ikona.style.transform = sidebarStanje.value === "skupljen" ? 'rotate(90deg)' : 'rotate(270deg)';

        localStorage.setItem('sidebarStanje', sidebarStanje.value);
        
        tekst.forEach(el => {
            //el.style.display = sidebarStanje.value === "rasiren" ? 'flex' : 'none';
            el.style.display = 'flex';
        });
    }
};

const openTelSidebar = () => {
    console.log("tel open");

    const sidebarTel = document.getElementById('sidebarTel');
    const skupiSidebarTel = document.getElementById('sidebarSirinaTel');
    sidebarTel.style.width = '200px';
    sidebarTel.style.borderImageSlice = '1';
    sidebarTel.style.borderRight = '2px solid';
    sidebarTel.style.borderImageSource = 'linear-gradient(45deg, #42f5e6, #6c3dff, #f27cf0, #374bff)';
    skupiSidebarTel.style.display = 'flex';

    const blur = document.createElement('div');
    blur.setAttribute('id', 'blur');
    blur.style.position = 'fixed'; 
    blur.style.top = '0'; 
    blur.style.left = '0';
    blur.style.width = '100%'; 
    blur.style.height = '100%';
    blur.style.backgroundColor = 'rgba(0, 0, 0, 0.5)'; 
    blur.style.backdropFilter = 'blur(5px)'; 
    blur.style.zIndex = '999';
    blur.addEventListener('click', closeTelSidebar);

    document.body.appendChild(blur);

}
const closeTelSidebar = () => {
    console.log("tel close");

    const sidebarTel = document.getElementById('sidebarTel');
    const skupiSidebarTel = document.getElementById('sidebarSirinaTel');
    const blur = document.getElementById('blur');
    sidebarTel.style.width = '0px';
    sidebarTel.style.borderRight = '0px'
    skupiSidebarTel.style.display = 'none';
    blur.remove();
}

const odjava = () => {
    localStorage.removeItem("access_token");
    localStorage.removeItem("rola");
    localStorage.removeItem("token_expiration");
    localStorage.removeItem("userID");
    router.push('/login');
}


</script>

<template>
    <div class="sidebar" id="sidebar">
        <div class="logo">
            <img src="../assets/media/logo.svg">
        </div>
        <nav>
            <RouterLink to="/">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'house']" class="ikona"/></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Početna</div>
                </div>
            </RouterLink>
            <RouterLink v-if="userID" :to="'/kalendar/' + userID">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'calendar-days']" class="ikona"/></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Kalendar</div>
                </div>
            </RouterLink>

            <RouterLink v-if="userID" :to="'/zadaci/' + userID">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'calendar-check']" class="ikona"/></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Zadaci</div>
                </div>
            </RouterLink>
            <RouterLink to="/statistika">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'chart-pie']" class="ikona"/></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Statistika</div>
                </div>
            </RouterLink>
            <RouterLink to="/savetnik">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'robot']" class="ikona"/></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Savetnik</div>
                </div>
            </RouterLink>
            <RouterLink to="/profil">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'user']" /></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Profil</div>
                </div>
            </RouterLink>
            <RouterLink v-if="rolaLS === 'admin'" to="/admin">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'laptop-code']" /></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Admin</div>
                </div>
            </RouterLink>
            <div class="item pointer" @click="odjava">
                <div><font-awesome-icon :icon="['fas', 'right-from-bracket']" /></div>
                <div class="tekst">&nbsp;&nbsp;&nbsp;Odjava</div>
            </div>
        </nav>
        <div id="sidebarSirina" class="item pointer" @click="toggleSidebar">
            <div><font-awesome-icon :icon="['far', 'square-caret-up']" rotation=270 class="ikona" id="sidebarIkona"/></div>
            <!--<div class="tekst">&nbsp;&nbsp;Skupi sidebar</div>-->
        </div>
    </div>

    <div v-if="uredjaj === 'tel'" id="ikonaSidebarTel" @click="openTelSidebar"><font-awesome-icon :icon="['fas', 'bars']" /></div>
    <div id="sidebarTel">
        <div class="logo">
            <img src="../assets/media/logo.svg">
        </div>
        <nav>
            <RouterLink to="/">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'house']" class="ikona"/></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Početna</div>
                </div>
            </RouterLink>
            <RouterLink v-if="userID" :to="'/kalendar/' + userID">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'calendar-days']" class="ikona"/></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Kalendar</div>
                </div>
            </RouterLink>

            <RouterLink v-if="userID" :to="'/zadaci/' + userID">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'calendar-check']" class="ikona"/></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Zadaci</div>
                </div>
            </RouterLink>
            <RouterLink to="/statistika">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'chart-pie']" class="ikona"/></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Statistika</div>
                </div>
            </RouterLink>
            <RouterLink to="/savetnik">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'robot']" class="ikona"/></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Savetnik</div>
                </div>
            </RouterLink>
            <RouterLink to="/profil">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'user']" /></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Profil</div>
                </div>
            </RouterLink>
            <RouterLink v-if="rolaLS === 'admin'" to="/admin">
                <div class="item pointer">
                    <div><font-awesome-icon :icon="['fas', 'laptop-code']" /></div>
                    <div class="tekst">&nbsp;&nbsp;&nbsp;Admin</div>
                </div>
            </RouterLink>
            <div class="item pointer" @click="odjava">
                <div><font-awesome-icon :icon="['fas', 'right-from-bracket']" /></div>
                <div class="tekst">&nbsp;&nbsp;&nbsp;Odjava</div>
            </div>
        </nav>
        <div id="sidebarSirinaTel" class="item pointer" @click="closeTelSidebar">
            <div><font-awesome-icon :icon="['far', 'square-caret-up']" rotation=270 class="ikona" id="sidebarIkona"/></div>
            <!--<div class="tekst">&nbsp;&nbsp;Skupi sidebar</div>-->
        </div>
    </div>
</template>

<style scoped>
.logo{
    display: flex;
    flex-direction: row;
    justify-content: center;
    /*padding: 8px;
    border-bottom: 1px solid #490b8f;*/
}
.logo img{
    width: 50px;
}
h1{
    font-size: 32px;
    margin: 0;
}
.sidebar{
    position: fixed;
    display: flex;
    flex-direction: column;
    padding: 10px 0;
    height: calc(100vh - 20px);
    background-color: #15161c;
    z-index: 1000;
    max-width: 200px;
    min-width: 72px;

    border-right: 2px solid;
    border-image-slice: 1;
    border-image-source: linear-gradient(45deg, #42f5e6, #6c3dff, #f27cf0, #374bff);

    overflow: hidden;
    transition: width 0.4s ease-out;

    user-select: none;
    -webkit-user-select: none; 
    -moz-user-select: none; 
    -ms-user-select: none; 
}
nav{
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    padding: 20px;
    width: auto;
}
a{
    font-size: 20px;
    -webkit-tap-highlight-color: transparent;
}
.ikona{
    width: 22px;
    font-size: 22px;
}
.item{
    display: flex;
    flex-direction: row;
    justify-content: flex-start;
    align-items: center;
    margin-bottom: 6px;
    padding: 5px;
    overflow: hidden;
    font-size: 20px;
}
.item:hover{
    color: whitesmoke;
    background-color: #6c3dff;
    padding: 5px;
    border-radius: 5px;
}
#sidebarSirina{
    position: fixed;
    bottom: 40px;
    left: 20px;
    display: flex;
    flex-direction: row;
    align-items: center;
}
#sidebarSirinaTel{
    position: fixed;
    bottom: 40px;
    left: 20px;
    display: none;
    flex-direction: row;
    align-items: center;
}
#sidebarIkona {
    transition: transform 0.4s ease;
}
@media screen and (min-width: 800px) {
    .sidebar{
        width: 200px;
    }
}
@media screen and (max-width: 879px) {
    .sidebar{
        display: none;
    }
}

#sidebarTel{
    position: fixed;
    display: flex;
    flex-direction: column;
    padding: 10px 0;
    height: calc(100vh - 20px);
    background-color: #15161c;
    z-index: 1000;
    width: 0px;

    overflow: hidden;
    transition: width 0.4s ease-out;
}
#ikonaSidebarTel{
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    position: fixed;
    bottom: 30px;
    left: 20px;
    background-color: #6c3dff;
    width: 30px;
    padding: 8px;
    border-radius: 50px;
    font-size: 30px;
    color: whitesmoke;
    z-index: 100;
}
.tekst{
    font-size: 20px;
}
</style>