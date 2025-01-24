<script setup>
import axios from 'axios';
import { onMounted, ref } from 'vue';
import { toast } from 'vue3-toastify';
import { useRouter } from 'vue-router';
import { odrediUredjajA, resizeListener } from '../components/device';

const router = useRouter();
const props = defineProps(['id']);
const userId = localStorage.getItem('userID');

onMounted(() => {
    odrediUredjajA();
    fetchZadatak();
    resizeListener();
});

function formatirajRok(apiRok) {
    if (!apiRok) return '';

    const parsedDate = new Date(apiRok);
    const year = parsedDate.getFullYear();
    const month = String(parsedDate.getMonth() + 1).padStart(2, '0');
    const day = String(parsedDate.getDate()).padStart(2, '0');

    return `${year}-${month}-${day}`;
}

const userID = localStorage.getItem('userID')
const token = localStorage.getItem('access_token');
const opis = ref("");
const uradjeno = ref();
const jednokratni = ref();
const brojac = ref();
const rok = ref(null);
const rokAPI = ref(null);
const izabranaKategorija = ref(1);
const kategorije = ref([]);
const fetchZadatak = async() => {
    try{
        const response = await axios.get(`/api/izmena-zadataka/${props.id}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        if(response.data.jednokratni == 1) {
            jednokratni.value = true;
        } else {
            jednokratni.value = false;
        }

        opis.value = response.data.opis;
        uradjeno.value = response.data.uradjeno;
        brojac.value = response.data.brojac;
        rokAPI.value = response.data.rok;
        rok.value = formatirajRok(response.data.rok);
        izabranaKategorija.value = response.data.kategZ;

        const kategorijeResponse = await axios.get(`/api/kategorije/${userId}`,{
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        kategorije.value = kategorijeResponse.data;
    } catch(error) {
        console.log(error)
    }
}

const handleSubmit = async (event) => {
    event.preventDefault();
    const rokZaSlanje = rok.value === "" ? rokAPI.value : rok.value;
    try {
        const response = await axios.put(
            `/api/izmena-zadataka/${props.id}`,
            {
                opis: opis.value,
                uradjeno: uradjeno.value,
                jednokratni: jednokratni.value,
                brojac: brojac.value,
                rok: rokZaSlanje,
                kategZ: izabranaKategorija.value
            },
            {
                headers: {
                    Authorization: `Bearer ${token}`
                }
            }
        );
        router.push(`/zadaci/${userID}`).then(() => {
            toast.success(response.data.message);
        });
    } catch (error) {
        console.error(error);
        toast.error("Došlo je do greške prilikom čuvanja zadatka.");
    }
};

</script>

<template>
    <div id="fs">
        <h1>{{ formatiraniDatum }}</h1>
        <form @submit.prevent="handleSubmit">
            <input type="text" placeholder="Naslov" class="form-style" v-model="opis">
            <div class="jednokratnoDodaj">
                <div style="display: inline-flex;">
                    <label >Dešavanje je jednokratno:&nbsp;</label>
                    <input type="checkbox" class="checkbox" name="jednokratni" v-model="jednokratni">
                </div>
                <div style="display: inline-flex;">
                    <label>Rok:&nbsp;</label>
                    <input type="date" id="rok" v-model="rok" class="form-style">
                </div>
            </div>

            <div class="form-group">
                <select name="kateg" id="kateg" class="form-style" required v-model="izabranaKategorija">
                    <option v-for="kategorija in kategorije" :key="kategorija.kategID" :value="kategorija.kategID">
                        {{ kategorija.imeKateg }}
                    </option>
                </select>
                <font-awesome-icon :icon="['fas', 'address-book']" class="input-icon2" />
            </div>
            
            <button class="dugme glow" type="submit">Sačuvaj</button>
        </form>
    </div>
    
</template>

<style scoped>

input[type="date"]::-webkit-calendar-picker-indicator {
    cursor: pointer;
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="15" viewBox="0 0 24 24"><path fill="%23bbbbbb" d="M20 3h-1V1h-2v2H7V1H5v2H4c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 18H4V8h16v13z"/></svg>');
}
.jednokratnoDodaj{
    display: flex;
    flex-direction: row;
    justify-content: space-around;
    align-items: center;
    margin-top: 10px;
    width: 100%;
    max-width: 550px;
}
form{
    margin-top: 20px;
    min-width: 70%;
    max-width: 90%;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    align-items: center;
}
label, p{
    font-size: 18px; 
    font-weight: 600;
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
    margin-top: 15px;
    box-shadow: 0 4px 8px 0 rgba(21,21,21,.2);
    padding: 8px 20px;
    height: 48px;
    width: 580px;
    border-radius: 4px;
    line-height: 22px;
    letter-spacing: 0.5px;
    outline: none;
    color: #c4c3ca;
    background-color: #000;
    border: none;
    -webkit-transition: all 200ms linear;
    transition: all 200ms linear;
    box-shadow: 0 4px 8px 0 rgba(21,21,21,.2);
    font-size: 20px;
    font-weight: 600;
    text-align: center;
}
.vreme{
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    width: 600px;
    max-width: 100%;
    justify-content: space-around; 
    margin-top: 15px; 
    align-items: center;
}
.tb{
    height: 400px;
}
@media screen and (max-width: 880px) {
    .form-style{
        width: 90%;
    }
    .jednokratnoDodaj{
        flex-wrap: wrap;
    }
    .tb{
        width: 90%;
    }
    .vreme{
        flex-direction: column;
        align-items: center;
        justify-content: space-around;
        height: 200px;
    }
}
.form-style:focus,
.form-style:active {
  border: none;
  outline: none;
  box-shadow: 0 4px 8px 0 rgba(21,21,21,.2);
}
.form-time{
    box-shadow: 0 4px 8px 0 rgba(21,21,21,.2);
    padding: 8px 20px;
    height: 48px;
    width: 140px;
    border-radius: 4px;
    line-height: 22px;
    letter-spacing: 0.5px;
    outline: none;
    color: #c4c3ca;
    background-color: #000;
    border: none;
    text-align: center;
    font-size: 20px;
    font-weight: 600;
}
.form-time:focus,
.form-time:active {
  border: none;
  outline: none;
  box-shadow: 0 4px 8px 0 rgba(21,21,21,.2);
}
input[type="time"]::-webkit-calendar-picker-indicator {
    filter: invert(1) brightness(100%) sepia(0) saturate(0);
}


.input-icon {
    position: absolute;
    top: 50%;
    left: 18px;
    transform: translateY(-50%);
    font-size: 24px;
    text-align: left;
}
.dugme {
    margin-top: 15px;
    padding: 10px 14px;
    border-radius: 18px;
    background-color: #292929;
    color: whitesmoke;
    cursor: pointer;
    font-size: 18px;
    font-weight: 600;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    filter: drop-shadow(3px 3px 3px rgba(0, 0, 0, 0.5));
    position: relative;
    z-index: 2;
    transition: all 0.3s ease-in-out;
    border: none;
}

.dugme::before {
    content: "";
    position: absolute;
    background-color: black;
    width: calc(100% - 4px);
    height: calc(100% - 4px);
    border-radius: 18px;
    z-index: -1;
}

.dugme:hover {
    background: linear-gradient(45deg, #42f5e6, #6c3dff, #f27cf0, #374bff);
}

.dugme:active {
    background-color: #6c3dff;
}

.checkbox {
    -webkit-appearance: none;
    -moz-appearance: none;
    appearance: none;
    width: 24px;
    height: 24px;
    border-radius: 4px;
    background-color: #292929;
    border: 2px solid #ccc;
    position: relative;
    cursor: pointer;
    transition: all 0.3s ease;
    margin-right: 10px;
    display: inline-block;
}

.checkbox:checked {
    background-color: #6c3dff;
    border-color: #6c3dff;
}

.checkbox:checked::after {
    content: '';
    position: absolute;
    top: 1px;
    left: 6px;
    width: 6px;
    height: 12px;
    border: solid #fff;
    border-width: 0 3px 3px 0;
    transform: rotate(45deg);
}

.checkbox:hover {
    border-color: #6c3dff;
}

div > label {
    font-size: 18px;
    font-weight: 600;
    color: #fff;
    display: inline-flex;
    align-items: center;
    transition: color 0.3s ease;
}


div {
    display: flex;
    align-items: center;
    justify-content: flex-start;
}


.input-icon2{
    position: absolute;
    top: 60%;
    left: 18px;
    transform: translateY(-50%);
    font-size: 24px;
    text-align: left;   
}

#rok{
    margin-top: 0px;
    width: 100%;
    max-width: 160px;
}

</style>