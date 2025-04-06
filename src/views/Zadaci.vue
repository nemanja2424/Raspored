<script setup>
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';
import { useRouter, useRoute, RouterLink } from "vue-router";
import { toast } from 'vue3-toastify';
import { odrediUredjajA, resizeListener } from '../components/device';


onMounted(() => {
  odrediUredjajA();
  resizeListener();
  fetchZadatke();
});

const formatDate = (dateString) => {
    const date = new Date(dateString);
    const pocetak = new Date('2024-01-01');

    if (date < pocetak){
        return "Nema roka."
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


const route = useRoute();
const idUsera = route.params.id;
const token = localStorage.getItem('access_token');
const zadaci = ref([]);
const kategorije = ref();
const izabranaKategorija = ref(1);
const fetchZadatke = async() => {
    try{
        const response = await axios.get(`/api/zadaci/${idUsera}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        zadaci.value = response.data;
        const kategorijeResponse = await axios.get(`/api/kategorije/${idUsera}`,{
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        kategorije.value = kategorijeResponse.data;
    } catch(error) {
        toast.error("Zadaci nisu učitani")
        console.log(error)
    }
}




const opisDodaj = ref("");
const jednokratniDodaj = ref(true);
const rokDodaj = ref(null);
const uradjenoDodaj = ref(false);
const brojacDodaj = ref(0);
const period = ref("nedeljno")
const brCilj = ref(0)
const cilj = computed(() => {
    if (period.value === "nedeljno") {
        return brCilj.value * 52;
    } else if (period.value === "mesecno") {
        return brCilj.value * 12;
    } else {
        return brCilj.value;
    }
});

const handleSubmit = async() => {
    try{
        const response = await axios.post(`/api/zadaci/${idUsera}`, {
            opis: opisDodaj.value,
            jednokratni: jednokratniDodaj.value,
            rok: rokDodaj.value,
            uradjeno: uradjenoDodaj.value,
            brojac: brojacDodaj.value,
            kategZ: izabranaKategorija.value,
            cilj: cilj.value,
            period: period.value
        },
        {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        opisDodaj.value = '';
        rokDodaj.value = null;
        jednokratniDodaj.value = true;

        fetchZadatke();
    } catch(error) {
        console.log(error)
    }
}
const handleUradjeno = async(zadatak) => {
    try{
        const formattedDate = new Date(zadatak.rok).toISOString().split('T')[0];
        zadatak.uradjeno = 1;
        const response = await axios.put(`/api/izmena-zadataka/${zadatak.zadatakID}`,{
            opis: zadatak.opis,
            uradjeno: zadatak.uradjeno,
            jednokratni: zadatak.jednokratni,
            brojac: zadatak.brojac,
            rok: formattedDate,
            kategZ: zadatak.IDKategorije,
            cilj: zadatak.cilj,
            period: zadatak.period
        },
        {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        toast.success(response.data.message);
        fetchZadatke();
    } catch(error){
        toast.error("Zadatak nije ažuriran")
    }
}
const handleBrojac = async(zadatak) => {
    try{
        //const formattedDate = new Date(zadatak.rok).toISOString().split('T')[0];
        zadatak.brojac += 1;
        await new Promise(resolve => setTimeout(resolve, 20));
        const response = await axios.put(`/api/izmena-zadataka/${zadatak.zadatakID}`,{
            opis: zadatak.opis,
            uradjeno: zadatak.uradjeno,
            jednokratni: zadatak.jednokratni,
            brojac: zadatak.brojac,
            rok: null,
            kategZ: zadatak.IDKategorije,
            cilj: zadatak.cilj,
            period: zadatak.period
        },
        {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        await new Promise(resolve => setTimeout(resolve, 20));
        fetchZadatke();
        await new Promise(resolve => setTimeout(resolve, 20));
        const istorija = await axios.post(`/api/brojac/${zadatak.zadatakID}`, {}, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
    } catch(error){
        toast.error("Zadatak nije ažuriran")
    }
}
const handleReset = async(zadatak) => {
    try{
        await new Promise(resolve => setTimeout(resolve, 20));
        //const formattedDate = new Date(zadatak.rok).toISOString().split('T')[0];
        zadatak.brojac = 0;
        const response = await axios.put(`/api/izmena-zadataka/${zadatak.zadatakID}`,{
            opis: zadatak.opis,
            uradjeno: zadatak.uradjeno,
            jednokratni: zadatak.jednokratni,
            brojac: zadatak.brojac,
            rok: null,
            kategZ: zadatak.IDKategorije,
            cilj: zadatak.cilj,
            period: zadatak.period
        },
        {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        await new Promise(resolve => setTimeout(resolve, 20));
        fetchZadatke();
        await new Promise(resolve => setTimeout(resolve, 20));
        const istorija = await axios.delete(`/api/brojac/${zadatak.zadatakID}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
    } catch(error){
        toast.error("Zadatak nije ažuriran")
    }
}
const handleDelete = async(zadatak) => {
    try{
        const response = await axios.delete(`/api/izmena-zadataka/${zadatak.zadatakID}`, {
            headers: {
                Authorization: `Bearer ${token}`
            }
        });
        fetchZadatke();

    } catch(error){
        toast.error("Zadatak nije ažuriran")
    }
}

</script>

<template>
    <div id="fs">
        <div id="dodajZadatak">
            <form @submit.prevent="handleSubmit">
                <input type="text" placeholder="Add task" class="form-style" v-model="opisDodaj" required>
                <div class="jednokratnoDodaj">
                    <div style="display: inline-flex;">
                        <label>Event is one-time:&nbsp;</label>
                        <input type="checkbox" class="checkbox" name="jednokratni" v-model="jednokratniDodaj" checked>
                    </div>
                    <div style="display: inline-flex;">
                        <label>Deadline:&nbsp;</label>
                        <input type="date" id="rok" v-model="rokDodaj" class="form-style">
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
                <div class="clij-grupa">
                    <div class="form-group period-element">
                        <select name="period" id="period" class="form-style" v-model="period">
                            <option value="nedeljno" selected>Weekly</option>
                            <option value="mesecno">Monthly</option>
                            <option value="godisnje">Yearly</option>
                        </select>
                        <font-awesome-icon :icon="['fas', 'trophy']" class="input-icon2" />
                    </div>
                    <input id="cilj" type="number" class="form-style" placeholder="Repetition goal" v-model="brCilj">
                </div>
                <button class="dugme glow" type="submit">Save</button>
            </form>
        </div>
        <div id="dodatiZadaci">
            <div class="kartica">
                <h1>One-time tasks</h1>
                <div id="jednokratni">
                    <div v-for="zadatak in zadaci" :key="zadatak.zadatakID">
                        <div class="zadatak" v-if="zadatak.jednokratni === 1 && zadatak.uradjeno === 0">
                            <div>
                                <h3 style="margin-bottom: 7px;">{{ zadatak.opis }}</h3>
                                <p>Category: <b>{{ zadatak.kategZ }}</b></p>
                                <p>Deadline: <b>{{ formatDate(zadatak.rok) }}</b></p>
                                <p>{{ prosaoRok(zadatak.rok) }}</p>
                            </div>
                            
                            <div style="display: inline-flex;">
                                <div :id="'uradi' + zadatak.zadatakID" class="event-option tick glow" style="cursor: pointer;" @click="handleUradjeno(zadatak)">
                                    <font-awesome-icon :icon="['fas', 'check']" style="cursor: pointer;"/>
                                </div>
                                <RouterLink :to="'/izmenaz/' + zadatak.zadatakID">
                                    <div :id="'izmeni' + zadatak.zadatakID" class="event-option glow" style="cursor: pointer;">
                                        <font-awesome-icon :icon="['fas', 'pen-to-square']" style="cursor: pointer;"/>
                                    </div>
                                </RouterLink>
                                <div :id="'obrisi' + zadatak.zadatakID" class="event-option trash glow" style="cursor: pointer;" @click="handleDelete(zadatak)">
                                    <font-awesome-icon :icon="['fas', 'trash-can']" style="cursor: pointer;"/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="kartica">
                <h1>Repeating tasks</h1>
                <div id="ponavljajuci" class="mojskrol">
                    <div v-for="zadatak in zadaci" :key="zadatak.zadatakID">
                        <div class="zadatak" v-if="zadatak.jednokratni === 0 && zadatak.uradjeno !== 1">
                            <div>
                                <h3 style="margin-bottom: 7px;">{{ zadatak.opis }}</h3>
                                <p>Done {{ zadatak.brojac }} times.</p>
                                <p>Category: <b>{{ zadatak.kategZ }}</b></p>
                            </div>
                            <div style="display: inline-flex;">
                                <div :id="'brojac' + zadatak.zadatakID" class="event-option tick glow" style="cursor: pointer;" @click="handleBrojac(zadatak)">
                                    <font-awesome-icon :icon="['fas', 'check']" style="cursor: pointer;"/>
                                </div>
                                <RouterLink :to="'/izmenaz/' + zadatak.zadatakID">
                                    <div :id="'izmeni' + zadatak.zadatakID" class="event-option glow" style="cursor: pointer;">
                                        <font-awesome-icon :icon="['fas', 'pen-to-square']" style="cursor: pointer;"/>
                                    </div>
                                </RouterLink>
                                <div :id="'reset' + zadatak.zadatakID" class="event-option glow" style="cursor: pointer;" @click="handleReset(zadatak)">
                                    <font-awesome-icon :icon="['fas', 'arrow-rotate-left']" style="cursor: pointer;"/>
                                </div>
                                <div :id="'obrisi' + zadatak.zadatakID" class="event-option trash glow" style="cursor: pointer;" @click="handleDelete(zadatak)">
                                    <font-awesome-icon :icon="['fas', 'trash-can']" style="cursor: pointer;"/>
                                </div>
                                <div :id="'uradi' + zadatak.zadatakID" class="event-option tick glow" style="cursor: pointer;" @click="handleUradjeno(zadatak)">
                                    <font-awesome-icon :icon="['fas', 'check-double']" style="cursor: pointer;"/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="kartica">
                <h1>Completed tasks</h1>
                <div id="uradjeni">
                    <div v-for="zadatak in zadaci" :key="zadatak.zadatakID">
                        <div class="zadatak" v-if="zadatak.uradjeno === 1">
                            <div>
                                <h3>{{ zadatak.opis }}</h3>
                                <b>Completed</b>
                                <p>Category: <b>{{ zadatak.kategZ }}</b></p>
                            </div>
                            
                            <div style="display: inline-flex;">
                                <div :id="'obrisi' + zadatak.zadatakID" class="event-option trash glow" style="cursor: pointer;" @click="handleDelete(zadatak)">
                                    <font-awesome-icon :icon="['fas', 'trash-can']" style="cursor: pointer;"/>
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
#dodatiZadaci{
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    width: 95%;
    height: 500px;
    margin-top: 30px;
    justify-content: space-around;
    margin-bottom: 30px;
}
.kartica{
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    align-items: center;
    width: 30%;
    min-width: 400px;
    height: auto;
    max-height: 500px;
    overflow-y: hidden;
    background-color: rgba(41, 41, 41, 0.8);
    border-radius: 30px;
    padding: 15px;
    margin: 5px;
    backdrop-filter: blur(10px);
    filter: drop-shadow(3px 3px 3px rgba(0, 0, 0, 0.5));
    overflow-y: auto;
}
.kartica h1{
    margin-bottom: 20px;
}
.kartica * {
    cursor: default;
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
.tick:hover{
    color: #07bc0c;
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
#jednokratni, #ponavljajuci, #uradjeni{
    display: flex;
    flex-direction: column;
    align-items: center;
    overflow: auto;
    width: 100%;
    align-items: stretch;
}
form{
    margin-top: 20px;
    min-width: 70%;
    max-width: 100%;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    align-items: center;
    background-color: #1c1c1c95;
    padding: 15px;
    padding-top: 30px;
    backdrop-filter: blur(5px);
    border-radius: 30px;
    filter: drop-shadow(5px 5px 3px rgba(0, 0, 0, 0.5));
}
.jednokratnoDodaj{
    display: flex;
    flex-direction: row;
    justify-content: space-around;
    align-items: center;
    margin-top: 10px;
    width: 100%;
}
label {
    font-size: 18px;
    font-weight: 600;
    color: #fff;
    display: inline-flex;
    align-items: center;
    transition: color 0.3s ease;
}
.form-style {
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
#rok{
    width: 100%;
    max-width: 160px;
}
input[type="date"]::-webkit-calendar-picker-indicator {
    cursor: pointer;
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="15" viewBox="0 0 24 24"><path fill="%23bbbbbb" d="M20 3h-1V1h-2v2H7V1H5v2H4c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 18H4V8h16v13z"/></svg>');
}
.form-group{ 
    position: relative;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    margin-top: 15px;
    padding: 0;
    width: 300px;
}
.input-icon2{
    position: absolute;
    top: 50%;
    left: 18px;
    transform: translateY(-50%);
    font-size: 24px;
    text-align: left;   
}
.clij-grupa{
    flex-wrap: wrap;
    display: inline-flex;
    justify-content: space-around;
    align-items: center;
    margin-top: 10px;
    width: 100%;
}
#period{
    width: 250px;
}
.period-element{
    width: auto;
    margin-top: 0px;
}
#cilj{
    width: 200px;
    padding: 0px 20px;
}
@media screen and (max-width: 880px) {
    #fs{
        padding: 0px;
    }
    #dodajZadatak{
        max-width: 95%;
    }
    .form-style{
        max-width: 90%;
    }
    .jednokratnoDodaj{
        flex-wrap: wrap;
    }
    #dodatiZadaci{
        height: auto;
    }
    .kartica{
        min-width: 90%;
        max-width: 90%;
    }
}
#jednokratni::-webkit-scrollbar,
#ponavljajuci::-webkit-scrollbar,
#uradjeni::-webkit-scrollbar-thumb:hover {
    width: 8px;
}
#jednokratni::-webkit-scrollbar-track,
#ponavljajuci::-webkit-scrollbar-track,
#uradjeni::-webkit-scrollbar-thumb:hover {
    background-color: #555;
    border-radius: 10px;
}
#jednokratni::-webkit-scrollbar-thumb,
#ponavljajuci::-webkit-scrollbar-thumb,
#uradjeni::-webkit-scrollbar-thumb:hover {
    background-color: #888;
    border-radius: 10px;
}
#jednokratni::-webkit-scrollbar-thumb:hover,
#ponavljajuci::-webkit-scrollbar-thumb:hover,
#uradjeni::-webkit-scrollbar-thumb:hover {
    background-color: #1c1c1c;
}

#uradjeni::-webkit-scrollbar {
    width: 8px;
}

#uradjeni::-webkit-scrollbar-thumb {
    background-color: #888;
    border-radius: 10px;
}

#uradjeni::-webkit-scrollbar-thumb:hover {
    background-color: #1c1c1c;
}

#uradjeni::-webkit-scrollbar-track {
    background-color: #555;
    border-radius: 10px;
}

</style>