<script setup>
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';
import { useRouter, useRoute, RouterLink } from "vue-router";
import { toast } from 'vue3-toastify';
import { odrediUredjajA, resizeListener } from '../components/device';

onMounted(() => {
  odrediUredjajA();
  resizeListener();
  fetchPodatke();
});
const formatDate = (dateString) => {
    const date = new Date(dateString);
    const pocetak = new Date('2024-01-01');

    if (date < pocetak){
        return "Nije urađen."
    }
    return date.toLocaleDateString('sr-RS');
};
const prosaoRok = (rok) => {
    const rokDatum = new Date(rok);
    const danas = new Date();
    const pocetak = new Date('2024-01-01');

    if (rokDatum < pocetak) {
        return "";
    }
    return rokDatum > danas ? "Zadatak nije urađen." : "Rok je istekao.";
};

const userID = localStorage.getItem('userID');
const token = localStorage.getItem('access_token');
const zadaci = ref([]);
const istorijaZadataka= ref([]);
const kategorije = ref([]);
const desavanja = ref([]);



const fetchPodatke = async() => {
    try {
        const responseZadaci = await axios.get(`api/statistika/${userID}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        istorijaZadataka.value = responseZadaci.data;
         // Filtriranje zadataka prema zadatakID i najnovijem datumu
         const zadaciFiltered = responseZadaci.data.reduce((acc, zadatak) => {
            const zadatakID = zadatak.zadatakID;
            // Ako već postoji zadatak sa istim zadatakID, proveri da li je ovaj noviji
            if (!acc[zadatakID] || Date.parse(zadatak.uradjen) > Date.parse(acc[zadatakID].uradjen)) {
                acc[zadatakID] = zadatak; // Dodaj ili zameni sa novijim zadatkom
            }
            return acc;
        }, {});

        // Konvertuj objekat u niz, jer želimo da radimo sa nizom
        zadaci.value = Object.values(zadaciFiltered);
        zadaci.value.sort(sortiraj);
        const kategorijeResponse = await axios.get(`/api/kategorije/${userID}`,{
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        kategorije.value = kategorijeResponse.data;
        const desavanjaResponse = await axios.get(`/api/kalendar/${userID}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        desavanja.value = desavanjaResponse.data;
    } catch (error) {
        console.error(error)
    }
}
const tip = ref(0);
const filter = ref(1);
const kateg = ref(0);

const sortiraj = (a, b) => {
    return b.izID - a.izID;
}

const procenat = ref(0);
const vremenskiPeriod = ref("nedeljno");
const handleChangeFilter = () => {
    //console.log(filter.value);

    if (filter.value == 2) {
        for (let i = 0; i < zadaci.value.length; i++) {
            const zadatak = zadaci.value[i];
            const number = document.getElementById('number' + zadatak.zadatakID);
            //console.log(zadatak.cilj)
            if (zadatak.cilj > 0) {
                if (vremenskiPeriod.value == "godisnje") {
                    procenat.value = zadatak.brojac / zadatak.cilj * 100;
                    number.innerHTML = procenat.value.toFixed(0) + '%';
                } 
                else if (vremenskiPeriod.value == "mesecno") {
                    const danas = new Date();
                    const preMesecDana = new Date();
                    preMesecDana.setMonth(danas.getMonth() - 1);

                    const datumKreiranja = new Date(zadatak.uradjen);

                    if (datumKreiranja >= preMesecDana) {
                        procenat.value = zadatak.brojac / (zadatak.cilj / 12) * 100;
                        number.innerHTML = procenat.value.toFixed(0) + '%';
                    } else {
                        number.innerHTML = "0%";
                    }
                }
                else{
                    const danas = new Date();
                    const preSedamDana = new Date();
                    preSedamDana.setDate(danas.getDate() - 7);

                    const datumKreiranja = new Date(zadatak.kreiran);

                    if (datumKreiranja >= preSedamDana) {
                        let nedeljniCilj = zadatak.cilj / 52;
                        procenat.value = zadatak.brojac / nedeljniCilj * 100;
                        number.innerHTML = procenat.value.toFixed(0) + '%';
                        //console.log(procenat.value)
                        console.log(zadatak.cilj)
                    } else {
                        number.innerHTML = "0%";
                    }
                }
            }
        }
    }
}

const searchQuery = ref('');
const filtriraniZadaci = computed(() => {
    return zadaci.value.filter(zadatak => {
        const kategorijaMatch = (kateg.value == 0) || 
            (String(zadatak.kategZ).trim().toLowerCase() === String(kateg.value).trim().toLowerCase());

        const pretragaMatch = zadatak.zadatak_opis.toLowerCase().includes(searchQuery.value.toLowerCase());
        
        return kategorijaMatch && pretragaMatch;
    });
});
</script>

<template>
    <div id="fs">
        <div class="kartica" id="pretraga">
            <div class="form-group">
                <input type="text" id="search" class="form-style" placeholder="Pretraži" v-model="searchQuery">
                <font-awesome-icon :icon="['fas', 'search']" class="input-icon2"></font-awesome-icon>
            </div>
            <div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: space-around; width: 80%; padding-top: 5px;">
                <select id="tip" class="form-style" v-model="tip">
                    <option value="0" selected>Ponavljajući zadaci</option>
                    <option value="1">Jednokratni zadaci</option>
                    <option value="2">Dešavanja</option>
                    <option value="3">Kategorije</option>
                </select>
                <select @change="handleChangeFilter" id="filter" class="form-style" v-model="filter">
                    <option value="1" v-if="tip == 0 || tip == 1">Poslednje</option>
                    <option value="2" v-if="tip == 0 || tip == 1">Uspešnost</option>
                </select>
                <select name="" id="poKategoriji" class="form-style" v-model="kateg">
                    <option value="0" selected>Sve kategorije</option>
                    <option v-for="kategorija in kategorije" :key="kategorija.kategID" :value="kategorija.imeKateg">
                        {{ kategorija.imeKateg }}
                    </option>
                </select>
                <select @change="handleChangeFilter" id="vremenskiPeriod" class="form-style" v-model="vremenskiPeriod">
                    <option value="0" selected disabled>Period</option>
                    <option value="godisnje" v-if="tip == 0 || tip == 1">Godišnje</option>
                    <option value="mesecno" v-if="tip == 0 || tip == 1">Mesečno</option>
                    <option value="nedeljno" v-if="tip == 0 || tip == 1">Nedeljno</option>
                </select>
            </div>
        </div>

        <div id="podaci" class="kartica">
            <div id="podaciSviZadaci" class="podaci-element" v-if="tip == 0">
                <h1>Ponavljajući zadaci</h1>
                <div class="odabrani-podaci">
                    <div style="width: 80%;" v-for="zadatak in filtriraniZadaci" :key="zadatak.zadatakID">
                        <div v-if="zadatak.jednokratni == 0" class="flex-row podatak">
                            <div>
                                <h3>{{ zadatak.zadatak_opis }}</h3>
                                <p v-if="kateg == 0">Kategorija: <b>{{ zadatak.kategZ }}</b></p>
                                <p v-if="filter == 2">{{ zadatak.brojac }} / {{ zadatak.cilj }}</p>
                            </div>
                            <div v-if="filter == 1">
                                <p>Poslednji put urađeno: <b>{{ formatDate(zadatak.uradjen) }}</b></p>
                            </div>
                            <div v-if="filter == 2">
                                <div class="wrapper">
                                    <div class="outer">
                                        <div class="inner">
                                            <div :id="'number' + zadatak.zadatakID"></div>
                                        </div>
                                    </div>
                                    <svg width="80px" height="80px">
                                        <defs>
                                            <linearGradient id="linearGradient">
                                                <stop offset="0%" stop-color="darkorange" />
                                                <stop offset="100%" stop-color="yellow" />
                                            </linearGradient>
                                        </defs>
                                        <circle cx="40" cy="40" r="35" />
                                    </svg>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</template>

<style scoped>
h3{
    margin-bottom: 5px;
}
.kartica{
    display: flex;
    flex-wrap: wrap;
    flex-direction: row;
    justify-content: space-around;
    align-items: center;
    width: 95%;
    min-width: 450px;
    height: auto;
    overflow-y: hidden;
    background-color: rgba(41, 41, 41, 0.8);
    border-radius: 30px;
    padding: 15px;
    margin: 5px;
    backdrop-filter: blur(10px);
    filter: drop-shadow(3px 3px 3px rgba(0, 0, 0, 0.5));
    overflow-y: auto;
}
.form-group{ 
    position: relative;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    padding: 0;
    width: 370px;
}
.form-style {
    margin: 3px 0px;
    box-shadow: 0 4px 8px 0 rgba(21,21,21,.2);
    padding: 8px 20px;
    min-height: 30px;
    min-width: 150px;
    border-radius: 4px;
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
.input-icon2{
    position: absolute;
    top: 50%;
    left: 18px;
    transform: translateY(-50%);
    font-size: 24px;
    text-align: left;   
}
#search{
    width: 100%;
}
.podaci-element{
    display: flex;
    flex-wrap: nowrap;
    flex-direction: column;
    align-items: center;
    overflow-y: auto;
    width: 95%;
    height: 100%;
}
.odabrani-podaci{
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
}
.podatak{
    position: relative;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    border-radius: 20px;
    padding: 10px;
    width: 100%;
    background-color: #1c1c1cb4;
    overflow: hidden;
    transition: background-color 0.4s ease-out;
    margin-top: 10px;
}
.wrapper{
    display: flex;
    align-items: center;
    justify-content: center;
    width: 80px;
    height: 80px;
    position: relative;
}
.outer{
    width: 80px;
    height: 80px;
    border-radius: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
}
.inner{
    width: 70px;
    height: 70px;
    border-radius: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
}
#number{
    font-size: 18px;
    font-weight: 700;
    color: pink;
}
svg{
    position: absolute;
    fill: none;
    stroke: url(#linearGradient);
    stroke-width: 5px;
    stroke-dasharray: 218;
    stroke-linecap: round;
    animation: anim 1s ease-in forwards;
}
@keyframes anim {
    
}
</style>