<script setup>
import { onMounted, ref } from 'vue';
import { odrediUredjajA, resizeListener } from '../components/device';
import { toast } from 'vue3-toastify';
import axios from 'axios';
import { useRouter } from 'vue-router';

const router = useRouter();
const rolaLS = localStorage.getItem('rola');

onMounted(() => {
    odrediUredjajA();
    fetchKorisnik();
    resizeListener();
    const showIcon = document.getElementById('show');
    const hideIcon = document.getElementById('hide');

    showIcon.style.display = isPasswordVisible.value ? 'block' : 'none';
    hideIcon.style.display = isPasswordVisible.value ? 'none' : 'block';

    showIcon.addEventListener('click', () => {
        togglePasswordVisibility();
        showIcon.style.display = 'none';
        hideIcon.style.display = 'block';
    });

    hideIcon.addEventListener('click', () => {
        togglePasswordVisibility();
        hideIcon.style.display = 'none';
        showIcon.style.display = 'block';
    });
});
const isPasswordVisible = ref(false);

function togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
    const passwordInput = document.getElementById('lozinka');
    passwordInput.type = isPasswordVisible.value ? 'text' : 'password';
}
const ime = ref("");
const email = ref("");
const lozinka = ref("");
const rola = ref(0);
const token = localStorage.getItem('access_token');
const id = localStorage.getItem('userID');
const kategorije = ref([]);
const fetchKorisnik = async () => {
    try {
        const response = await axios.get(`/api/izmenak/${id}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        ime.value = response.data.ime;
        email.value = response.data.email;
        rola.value = response.data.rola;

        const kategorijeResponse = await axios.get(`/api/kategorije/${id}`,{
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        kategorije.value = kategorijeResponse.data;
    } catch (error) {
        
    }
}


const handleSubmitProfil = async() => {
    try {
        const response = await axios.put(`/api/izmenak/${props.id}`,{
            ime: ime.value,
            email: email.value,
            lozinka: lozinka.value,
            rola: rola.value
        },
        {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        router.push('/admin').then(() => toast.success(response.data.message));
    } catch (error) {
        console.error(error)
    }
} 

const novaKateg = ref("");
const handleSubmitKateg = async() => {
    try {
        const response = await axios.post(`/api/kategorije/${id}`,{
            imeKateg: novaKateg.value
        },
        {  
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        const kategorijeResponse = await axios.get(`/api/kategorije/${id}`,{
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        kategorije.value = kategorijeResponse.data;
    } catch (error) {
        console.log(error)
    }
}

const handleDelete = async (kategorija) => {
    try {
        const response = await axios.delete(`/api/izmena-kateg/${kategorija.kategID}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        toast.success(response.data.message);
        fetchKorisnik();
    } catch (error) {
        console.error(error);
    }
}
</script>

<template>
    <div id="fs">
        <div class="kartica">
            <h1>Profil</h1>
            <form @submit.prevent="handleSubmitProfil">
                <div class="form-group">
                    <input required type="text" class="form-style" placeholder="Ime" id="ime" v-model="ime"/>
                    <font-awesome-icon :icon="['fas', 'signature']" class="input-icon" />
                </div>
                <div class="form-group">
                    <input required type="email" class="form-style" placeholder="Email" id="email" v-model="email"/>
                    <font-awesome-icon :icon="['fas', 'at']" class="input-icon" />
                </div>
                <div class="form-group mt-2">
                    <input type="password" class="form-style" placeholder="Nova lozinka" id="lozinka" v-model="lozinka"/>
                    <font-awesome-icon :icon="['fas', 'lock']" class="input-icon" />
                    <div class="showHidePassword">
                        <font-awesome-icon :icon="['fas', 'eye']" id="show" />
                        <font-awesome-icon :icon="['fas', 'eye-slash']" id="hide" style="cursor: pointer; display: none" />
                    </div>
                </div>
                <div class="form-group">
                    <select name="rola" id="rola" class="form-style" required v-model="rola">
                        <option value="0" disabled selected>Odaberi rolu</option>
                        <option value="1">Korisnik</option>
                        <option value="2" v-if="rolaLS === 'admin'">Admin</option>
                    </select>
                    <font-awesome-icon :icon="['fas', 'address-book']" class="input-icon" />
                </div>
                <input type="submit" class="dugme" role="button" value="Izmeni korisnika" />
            </form>
        </div>
        <div class="kartica kateg" id="kateg">
            <div style="margin: 15px 0px;">
                <form @submit.prevent="handleSubmitKateg">
                    <div class="form-group form-group2">
                        <input required type="text" class="form-style" placeholder="Nova kategorija" v-model="novaKateg"/>
                        <font-awesome-icon :icon="['fas', 'tags']" class="input-icon" />
                    </div>
                    <input type="submit" class="dugme" role="button" value="Dodaj kategoriju" style="margin-top: 10px;"/>
                </form>
            </div>
            <h1 style="margin-bottom: 20px;">Kategorije:</h1>
            <div v-for="kategorija in kategorije" :key="kategorija.kategID">
                <div :id="'kateg' + kategorija.kategID" class="zadatak">
                    <b>{{ kategorija.imeKateg }}</b>
                    <div style="display: inline-flex;">
                        <RouterLink :to="'/izmena-kateg/' + kategorija.kategID">
                            <div :id="'izmeni' + kategorija.kategID" class="event-option glow" style="cursor: pointer;">
                                <font-awesome-icon :icon="['fas', 'pen-to-square']" style="cursor: pointer;"/>
                            </div>
                        </RouterLink>
                        <div :id="'obrisi' + kategorija.kategID" class="event-option trash glow" style="cursor: pointer;" @click="handleDelete(kategorija)">
                            <font-awesome-icon :icon="['fas', 'trash-can']" style="cursor: pointer;"/>
                        </div>
                    </div>
                    
                </div>
                
            </div>
        </div>
    </div>
</template>

<style scoped>

.kartica{
    margin-bottom: 20px;
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    background: linear-gradient(45deg, #42f5e6, #6c3dff, #f27cf0, #374bff);
    border-radius: 80px;
    z-index: 1;
}
form{
    display: flex;
    flex-direction: column;
    align-items: center;
}
.kartica::before{
  content: "";
  position: absolute;
  background-color: #292929b7;
  filter: blur(2px);
  width: calc(100% - 4px);
  height: calc(100% - 4px);
  border-radius: 78px;
  z-index: -1;
}
.form-group{ 
    position: relative;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    margin-bottom: 25px;
    padding: 0;
    width: 300px;
}
.form-style {
    box-shadow: 0 4px 8px 0 rgba(21,21,21,.2);
    padding: 13px 20px;
    padding-left: 55px;
    height: 48px;
    width: 100%;
    font-weight: 500;
    border-radius: 4px;
    font-size: 14px;
    line-height: 22px;
    letter-spacing: 0.5px;
    outline: none;
    color: #c4c3ca;
    background-color: #1f2029;
    border: none;
    -webkit-transition: all 200ms linear;
    transition: all 200ms linear;
    box-shadow: 0 4px 8px 0 rgba(21,21,21,.2);
}
.form-style:focus,
.form-style:active {
  border: none;
  outline: none;
  box-shadow: 0 4px 8px 0 rgba(21,21,21,.2);
}
.input-icon {
    position: absolute;
    top: 50%;
    left: 18px;
    transform: translateY(-50%);
    font-size: 24px;
    text-align: left;
}
.dugme{  
    padding: 10px 14px;
    border-radius: 15px;
    border: none;
    font-size: 18px;
    font-weight: 600;
    cursor: pointer;
    background-color: #1f2029;
    color: whitesmoke;
}
.dugme:hover{  
    background-color: #6c3dff;
}

@media screen and (min-width: 880px) {
    .kartica{
        padding: 20px;
        width: 600px;
        height: auto;
        margin-bottom: 20px;
    }
    .zadatak{
        width: 250px;
    }
}
@media screen and (max-width: 880px){
    .kartica{
        width: 90%;
        padding: 20px 0px;
        min-height: 100%;
    }
    .zadatak{
        width: 250px;
    }
}

.showHidePassword{
  display: flex;
  justify-content: center;
  align-items: center;
  position: absolute;
  width: auto;
  height: 48px;
  right: 10px;
  transform: translateY(-50%);
  top: 50%;
}
#show{
  display: none;
  cursor: pointer;
  font-size: 25px;
}
#hide{
  cursor: pointer;
  font-size: 25px;
}





.zadatak {
    position: relative;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    border-radius: 20px;
    padding: 10px;
    background-color: #1c1c1cb4;
    overflow: hidden;
    transition: background-color 0.4s ease-out;
    margin-bottom: 10px;
}

.trash:hover{
    color: red;
}
.zadatak:hover {
    background-color: #1c1c1c30;
}
.zadatak::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    border-radius: 20px;
    background: linear-gradient(45deg, #42f5e6, #6c3dff, #f27cf0, #374bff);
    opacity: 0;
    transition: opacity 0.4s ease-out;
    z-index: -1;
}
.zadatak:hover::before{
    opacity: 1;
}
.form-group2{
    margin-bottom: 5px;
}
</style>