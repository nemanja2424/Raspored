<script setup>
import { onMounted, ref } from 'vue';
import { odrediUredjajA, resizeListener } from '../components/device';
import { toast } from 'vue3-toastify';
import axios from 'axios';
import { RouterLink } from 'vue-router';

const rolaLS = localStorage.getItem('rola');

onMounted(() => {
  odrediUredjajA();
  fetchAdminData();
  resizeListener();
});

const korisnici = ref([]);
const desavanja = ref([]);
const zadaci = ref([]);
const token = localStorage.getItem('access_token');
const fetchAdminData = async () => {
  try {

    const response = await axios.get('/api/admin', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    const adminData = response.data;
  
    //console.log(adminData);
    korisnici.value = adminData.korisnici;
    desavanja.value = adminData.desavanja;
    zadaci.value = adminData.zadaci;


  } catch (error) {
    toast.error('Greška prilikom učitavanja podataka:', error);
    console.log(error);
  }
};

let potvrdjenoK = false;
const potvrdibrisanjeK = async(id) => {
  const element = document.getElementById(`brisanjeK${id}`);
  const red = document.getElementById(`redK${id}`);
  
  if (!potvrdjenoK) {
    element.style.backgroundColor = 'red';
    element.style.color = 'red';
    element.innerHTML = 'Potvrdi';
    potvrdjenoK = true;
    console.log("ceka se potvrda za id: " + id)

    setTimeout(() => {
      if (!potvrdjenoK) return;
      element.style.backgroundColor = '';
      element.style.color = '';
      element.innerHTML = 'Obriši';
      potvrdjenoK = false;
      console.log("odustalo se od brisanja za id: " + id)
    }, 5000);
    
  } else {
    element.addEventListener('click', async function confirmDeletion() {
      console.log('Obrisan');
      const response = await axios.delete(`/api/izmenak/${id}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      console.log("obrisan id: " + id);
      toast.info("Korisnik je obrisan.");
      red.remove();

      element.removeEventListener('click', confirmDeletion);
      potvrdjenoK = false;
    });
  }
};

let potvrdjenoD = false;
const potvrdibrisanjeD = async(id) => {
  const element = document.getElementById(`brisanjeD${id}`);
  const red = document.getElementById(`redD${id}`);
  
  if (!potvrdjenoD) {
    element.style.backgroundColor = 'red';
    element.style.color = 'red';
    element.innerHTML = 'Potvrdi';
    potvrdjenoD = true;
    console.log("ceka se potvrda za id: " + id)

    setTimeout(() => {
      if (!potvrdjenoD) return;
      element.style.backgroundColor = '';
      element.style.color = '';
      element.innerHTML = 'Obriši';
      potvrdjenoD = false;
      console.log("odustalo se od brisanja za id: " + id)
    }, 5000);
    
  } else {
    element.addEventListener('click', async function confirmDeletion() {
      try{
        const response = await axios.delete(`/api/delete-event/${id}`, {
          headers: {
            Authorization: `Bearer ${token}`
          }
        });
        element.remove();
        toast.success(response.data.message);
        red.remove();
      } catch(error){
        toast.error(error);
        console.log(error)
      }
      element.removeEventListener('click', confirmDeletion);
      potvrdjenoD = false;
    });
  }
};

let potvrdjenoZ = null;
const potvrdibrisanjeZ = async (id) => {
  const element = document.getElementById(`brisanjeZ${id}`);
  const red = document.getElementById(`redZ${id}`);

  if (potvrdjenoZ !== id) {
    if (potvrdjenoZ !== null) {
      const prevElement = document.getElementById(`brisanjeZ${potvrdjenoZ}`);
      if (prevElement) {
        prevElement.style.backgroundColor = '';
        prevElement.style.color = '';
        prevElement.innerHTML = 'Obriši';
      }
    }

    element.style.backgroundColor = 'red';
    element.style.color = 'red';
    element.innerHTML = 'Potvrdi';
    potvrdjenoZ = id;

    setTimeout(() => {
      if (potvrdjenoZ === id) {
        element.style.backgroundColor = '';
        element.style.color = '';
        element.innerHTML = 'Obriši';
        potvrdjenoZ = null;
      }
    }, 5000);
  } else {
    try {
      const response = await axios.delete(`/api/izmena-zadataka/${id}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      toast.success(response.data.message);
      red.remove();
    } catch (error) {
      toast.error('Došlo je do greške prilikom brisanja zadatka.');
    }

    element.style.backgroundColor = '';
    element.style.color = '';
    element.innerHTML = 'Obriši';
    potvrdjenoZ = null;
  }
};

const potvrdiTotBrisanje = async (tabela) => {
  const potvrdiBrisanjeElement = document.createElement('div');
  const blurElement = document.createElement('div');
  const appElement = document.getElementById('app')
  
  blurElement.classList.add('blur');
  potvrdiBrisanjeElement.classList.add('login');

  potvrdiBrisanjeElement.innerHTML = `
    <h3>Da li ste sigurni da želite obrisati sve podatke?</h3>
    <div style="display: inline-flex; margin-top: 15px;">
      <button id="da" class="dugme da" style="margin-right: 10px;">Obriši</button>
      <button id="ne" class="dugme ne">Odustajem</button>
    </div>
  `;

  appElement.appendChild(blurElement);
  blurElement.appendChild(potvrdiBrisanjeElement);
  const daElement = document.getElementById('da');
  const neElement = document.getElementById('ne');

  neElement.addEventListener('click', () =>{
    blurElement.remove();
    potvrdiBrisanjeElement.remove();
  });
  daElement.addEventListener('click', async () => {
    try {
      const response = await axios.delete(`/api/brisanje-svega/${tabela}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
      });
      fetchAdminData();
      toast.success(response.data.message);
      blurElement.remove();
      potvrdiBrisanjeElement.remove();
    } catch (error) {
      console.error(error)
    }
  });

}

</script>

<template>
  <div id="fs" v-if="rolaLS === 'admin'">
    <h1 style="padding-bottom: 10px;">Users</h1>
    <div style="display: inline-flex;">
      <RouterLink class="izmena izmena2 glow" id="noviKorisnik" to="novi-korisnik">Add user</RouterLink>
    </div>
    <table>
      <thead>
        <tr>
          <td>ID</td>
          <td>Name</td>
          <td>Email</td>
          <td>Role</td>
          <td>Created</td>
          <td rowspan="2">Edit</td>
        </tr>
      </thead>
      <tbody>
        <tr v-for="korisnik in korisnici" :key="korisnik.userID" :id="'redK' + korisnik.userID">
          <td>{{ korisnik.userID }}</td>
          <td>{{ korisnik.ime }}</td>
          <td>{{ korisnik.email }}</td>
          <td>{{ korisnik.rola_ime }}</td>
          <td>{{ korisnik.kreirano }}</td>
          <RouterLink :to="'/izmenak/' + korisnik.userID" class="izmena">Edit</RouterLink>
          <a class="izmena brisanje" :id="'brisanjeK' + korisnik.userID" @click="potvrdibrisanjeK(korisnik.userID)">Delete</a>
        </tr>
      </tbody>
    </table>
    <h1 style="padding: 10px;">Events</h1>
    <div class="izmena izmena2 glow" @click="potvrdiTotBrisanje('desavanja')">Delete all events</div>
    <table>
      <thead>
        <tr>
          <td>ID</td>
          <td>User</td>
          <td>Title</td>
          <td>All-day</td>
          <td>Date</td>
          <td>Start</td>
          <td>End</td>
          <td>Created</td>
          <td rowspan="2">Edit</td>
        </tr>
      </thead>
      <tbody>
        <tr v-for="desavanje in desavanja" :key="desavanje.desavanjaID" :id="'redD' + desavanje.desavanjaID">
          <td>{{ desavanje.desavanjaID }}</td>
          <td>{{ desavanje.korisnik_ime }}</td>
          <td>{{ desavanje.naslov }}</td>
          <td>{{ desavanje.celodnevni == 1 ? "Yes" : "No" }}</td>
          <td>{{ desavanje.datum }}</td>
          <td>{{ desavanje.odTime }}</td>
          <td>{{ desavanje.doTime }}</td>
          <td>{{ desavanje.kreiran }}</td>
          <RouterLink :to="'/izmena/' + desavanje.desavanjaID" class="izmena">Edit</RouterLink>
          <a class="izmena brisanje" :id="'brisanjeD' + desavanje.desavanjaID" @click="potvrdibrisanjeD(desavanje.desavanjaID)">Delete</a>
        </tr>
      </tbody>
    </table>
    <h1 style="padding: 10px;">Tasks</h1>
    <div class="izmena izmena2 glow" @click="potvrdiTotBrisanje('zadaci')">Delete all tasks</div>
    <table>
      <thead>
        <td>ID</td>
        <td>User</td>
        <td>Description</td>
        <td>One-time</td>
        <td>Completed</td>
        <td>Counter</td>
        <td>Deadline</td>
        <td>Created</td>
        <td>Edit</td>
      </thead>
      <tbody>
        <tr v-for="zadatak in zadaci" :key="zadatak.zadatakID" :id="'redZ' + zadatak.zadatakID">
          <td>{{ zadatak.zadatakID }}</td>
          <td>{{ zadatak.korisnicko_ime }}</td>
          <td>{{ zadatak.opis }}</td>
          <td>{{ zadatak.jednokratni == 1 ? "Yes" : "No" }}</td>
          <td>{{ zadatak.uradjeno == 1 ? "Yes" : "No" }}</td>
          <td>{{ zadatak.brojac }}</td>
          <td>{{ zadatak.rok }}</td>
          <td>{{ zadatak.kreiran }}</td>
          <RouterLink :to="'/izmenaz/' + zadatak.zadatakID" class="izmena">Edit</RouterLink>
          <a class="izmena brisanje" :id="'brisanjeZ' + zadatak.zadatakID" @click="potvrdibrisanjeZ(zadatak.zadatakID)">Delete</a>
        </tr>
      </tbody>
    </table>
  </div>
</template>


<style scoped>
table{
  margin: 15px 0px;
  width: 90%; 
  background-color: #1c1c1c;
  padding: 15px;
  border-radius: 30px;
  filter: drop-shadow(3px 3px 3px rgba(0, 0, 0, 0.5));
  border-collapse: separate;
  border-spacing: 5px;
}
td{
  margin: 2px;
  text-align: center;
  background-color: black;
  padding: 8px;
  border-radius: 10px;
}
tbody td{
  background-color: #292929;
}
.izmena {
    /*border: 1px solid #7512e6;*/
    border-radius: 11px;
    background-color: #292929;
    cursor: pointer;
    min-height: 30px;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
    filter: drop-shadow(3px 3px 3px rgba(0, 0, 0, 0.5));
    position: relative;
    z-index: 2;
    transition: all 0.3s ease-in-out;
}
.izmena::before{
  content: "";
  position: absolute;
  background-color: #292929;
  width: calc(100% - 4px);
  height: calc(100% - 4px);
  border-radius: 9px;
  z-index: -1;
}
.izmena:hover{
  background: linear-gradient(45deg, #42f5e6, #6c3dff, #f27cf0, #374bff);
}
.izmena:hover::before{
  background-color: black;
}
.brisanje{
  margin-top: 2px;
}
.izmena2{
  background: linear-gradient(45deg, #42f5e6, #6c3dff, #f27cf0, #374bff);
  margin: 10px;
  padding: 8px;
}
</style>