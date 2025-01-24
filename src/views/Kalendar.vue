<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { useRouter, useRoute } from "vue-router";
import { toast } from 'vue3-toastify';
import { odrediUredjajA, resizeListener } from '../components/device';

const desavanjaData = ref([]);
const filteredDesavanja = ref([]);
const router = useRouter();

onMounted(() => {
  odrediUredjajA();
  fetchDesavanja();
  resizeListener();
});

const route = useRoute();
const id = route.params.id;

const fetchDesavanja = async () => {
  try {
    const token = localStorage.getItem('access_token');

    const response = await axios.get(`/api/kalendar/${id}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    desavanjaData.value = response.data;
    obojiDatum(desavanjaData.value);
    //console.log(desavanjaData.value);
  } catch (error) {
    toast.error('Greška prilikom učitavanja desavanja:', error);
    console.log(error)
  }
};

const obojiDatum = async(datumi) => {
  //console.log('Datumi iz backend-a:', datumi);

  const allCells = document.querySelectorAll('.date');
  allCells.forEach(cell => {
    //console.log('Data-date atribut:', cell.getAttribute('data-date'));
    cell.style.color = '';
    cell.style.fontWeight = '';
  });

  datumi.forEach((desavanje) => {
    const eventDate = new Date(desavanje.datum);
    const formattedDate = `${eventDate.getFullYear()}-${String(eventDate.getMonth() + 1).padStart(2, '0')}-${String(eventDate.getDate()).padStart(2, '0')}`;

    //console.log('Formatted Date za bojenje:', formattedDate);

    const cell = document.querySelector(`[data-date="${formattedDate}"]`);
    if (cell) {
      cell.style.color = '#6c3dff';
      cell.style.fontWeight = '600';
      //console.log('Boji ćeliju:', formattedDate, cell);
    } else {
      //console.log('Nije pronađena ćelija za datum:', formattedDate);
    }
  });
}

const meseci = [
  "Januar", "Februar", "Mart", "April", "Maj", "Jun",
  "Jul", "Avgust", "Septembar", "Oktobar", "Novembar", "Decembar"
];

const daysOfWeek = ['Pon', 'Uto', 'Sre', 'Čet', 'Pet', 'Sub', 'Ned'];

const today = {
  year: new Date().getFullYear(),
  month: new Date().getMonth(),
  day: new Date().getDate(),
};

const currentYear = ref(today.year);
const currentMonth = ref(today.month);
const days = ref([]);

function generateCalendar(month, year) {
  const firstDayOfMonth = new Date(year, month, 1);
  const lastDayOfMonth = new Date(year, month + 1, 0);
  const daysInMonth = lastDayOfMonth.getDate();

  const firstDayIndex = (firstDayOfMonth.getDay() + 6) % 7; 
  const totalCells = Math.ceil((firstDayIndex + daysInMonth) / 7) * 7; 

  const tempDays = [];

  const prevMonthLastDay = new Date(year, month, 0).getDate();
  for (let i = firstDayIndex - 1; i >= 0; i--) {
    tempDays.push({
      day: prevMonthLastDay - i,
      isToday: false,
      isOtherMonth: true,
      month: month === 0 ? 11 : month - 1, 
      year: month === 0 ? year - 1 : year,
    });
  }

  for (let i = 1; i <= daysInMonth; i++) {
    tempDays.push({
      day: i,
      isToday: year === today.year && month === today.month && i === today.day,
      isOtherMonth: false,
      month,
      year,
    });
  }

  const remainingCells = totalCells - tempDays.length;
  for (let i = 1; i <= remainingCells; i++) {
    tempDays.push({
      day: i,
      isToday: false,
      isOtherMonth: true,
      month: month === 11 ? 0 : month + 1, 
      year: month === 11 ? year + 1 : year,
    });
  }

  days.value = tempDays;
  setTimeout(() => obojiDatum(desavanjaData.value), 10);
}

function changeMonth(direction) {
  currentMonth.value += direction;
  if (currentMonth.value < 0) {
    currentMonth.value = 11;
    currentYear.value--;
  } else if (currentMonth.value > 11) {
    currentMonth.value = 0;
    currentYear.value++;
  }
  generateCalendar(currentMonth.value, currentYear.value);
  obojiDatum(desavanjaData.value);
}

generateCalendar(currentMonth.value, currentYear.value);

let desavanja = null;
let datum = null;
const otvoriDesavanja = (date, element) => {
  const FSElement = document.getElementById('fs');
  if (desavanja && document.body.contains(desavanja)) {
    FSElement.removeChild(desavanja);
    desavanja = null;
  }

  const mesec = meseci[date.month];
  datum = { ...date };

  desavanja = document.createElement('div');
  desavanja.id = "desavanje"
  desavanja.classList.add('desavanje');
  desavanja.innerHTML = `
      <div class="desavanjeX glow" id="desavanjeX">
        <i class="fas fa-x" style="font-size: 20px;"></i>
      </div>
      <div class="desavanjeR glow" id="desavanjeR">
        <i class="fa-solid fa-rotate-left" style="font-size: 20px;"></i>
      </div>
      <div class="desavanjeHeader">
        <button class="senkaLevo glow" id="nazadDan">
          &nbsp;<i class="fa-solid fa-arrow-left"></i>&nbsp;
        </button>
        <h1 id="datumHeader">${datum.day}. ${mesec} ${datum.year}.</h1>
        <button class="senkaDesno glow" id="napredDan">
          &nbsp;<i class="fa-solid fa-arrow-right"></i>&nbsp;
        </button>
      </div>
      <div class="sva-desavanja">
        <div id="dodataDesavanja">

        </div>
        <div class="moje-desavanje glow" id="novoDesavanje">
          <p>Dodaj novo desavanje</p>
          <i class="fa-solid fa-plus" style="font-size: 50px;"></i>
        </div>
      </div>
  `;
  //console.log("Otvorena dešavanja za datum:", datum);
  //console.log("Dešavanja:", filteredDesavanja.value);

  const savedPosition = JSON.parse(localStorage.getItem('desavanjaPosition'));
  if (savedPosition) {
    desavanja.style.top = savedPosition.top;
    desavanja.style.left = savedPosition.left;
  } else {
    //desavanja.style.bottom = "30px"; 
    //desavanja.style.right = "30px";
  }

  FSElement.appendChild(desavanja);
  const desavanjaDiv = document.getElementById('dodataDesavanja');
  if(element){desavanjaDiv.appendChild(element);}
  dragElement(desavanja);

  const nazadDan = document.getElementById('nazadDan');
  const napredDan = document.getElementById('napredDan');
  const datumHeader = document.getElementById('datumHeader');
  const desavanjeX = document.getElementById('desavanjeX');
  const desavanjeR = document.getElementById('desavanjeR');
  const napraviDesavanjeBtn = document.getElementById('novoDesavanje');

  if (nazadDan && napredDan) {
    nazadDan.addEventListener('click', () => changeDay(datum, datumHeader, -1));
    napredDan.addEventListener('click', () => changeDay(datum, datumHeader, 1));
  }
  if (desavanjeX && desavanjeR && napraviDesavanjeBtn) {
    desavanjeX.addEventListener('click', () => ugasiDesavanje());
    desavanjeR.addEventListener('click', () => resetPozicije());
    napraviDesavanjeBtn.addEventListener('click', () => napraviDesavanje());
  }
};

const filtrirajDesavanja = (datum) => {
  if (!desavanjaData.value || desavanjaData.value.length === 0) {
    otvoriDesavanja(datum);
    //toast.error('Nema dostupnih dešavanja za filtriranje.');
    return;
  }

  filteredDesavanja.value = desavanjaData.value.filter(desavanje => {
    const eventDate = new Date(desavanje.datum);
    const formattedDate = `${eventDate.getFullYear()}-${String(eventDate.getMonth() + 1).padStart(2, '0')}-${String(eventDate.getDate()).padStart(2, '0')}`;
    const selectedDate = `${datum.year}-${String(datum.month + 1).padStart(2, '0')}-${String(datum.day).padStart(2, '0')}`;
    return formattedDate === selectedDate;
  });

  if (filteredDesavanja.value.length > 0) {
    let krajnjiElement = document.createElement('div');
    krajnjiElement.classList.add('dodataDesavanja');
    filteredDesavanja.value.forEach(desavanje => {
      let vreme;
      if (desavanje?.celodnevni === 1) {
        desavanje.celodnevni = "Dešavanje je celodnevno";
        vreme = ""; 
      } else {
        desavanje.celodnevni = "";
        vreme = `${desavanje.odTime} - ${desavanje.doTime}`;
      }

      let element = document.createElement('div');
      element.classList.add('dodato-desavanje', 'glow');
      element.id = `desavanje${desavanje.desavanjaID}`
      element.innerHTML = `
        <h1 style="margin-bottom: 10px; text-align: center;">${desavanje.naslov}</h1>
        <div id="dodajVreme" style="display: inline;"></div>
        <b>
          <span style="font-weight: normal;">Kategorija:</span> ${desavanje.kategD}</br>
          ${desavanje.celodnevni}
          ${vreme}
        </b>
        <p>${desavanje.opis}</p>
        <div style="display: inline-flex;">
          <div class="glow event-option" id="deleteEvent" onclick="obrisi(${desavanje.desavanjaID})"><i class="fa-solid fa-trash-can"></i></div>
          <div class="glow event-option" id="editElement" onclick="izmeniDesavanjeLink(${desavanje.desavanjaID})"><i class="fa-solid fa-pen-to-square"></i></div>
        </div>
      `;
      krajnjiElement.appendChild(element);
    });

    otvoriDesavanja(datum, krajnjiElement);
  } else {
    otvoriDesavanja(datum);
    //toast.info('Nema dešavanja za odabrani datum.');
  }
};

window.izmeniDesavanjeLink = izmeniDesavanjeLink;
async function izmeniDesavanjeLink(id) {
  router.push('/izmena/' + id).then(() => toast.info("Izmenite dešavanje"));
}

window.obrisi = obrisi;
async function obrisi(id) {
  console.log(id);
  let element = document.getElementById(`desavanje${id}`);
  const token = localStorage.getItem('access_token');
  try{
    const response = await axios.delete(`/api/delete-event/${id}`, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
    element.remove();
    toast.success(response.data.message);
  } catch(error){
    toast.error(error);
    console.log(error)
  }
}

const napraviDesavanje = () => {
  const mesec = datum.month + 1;
  const datumLink = `${datum.year}-${String(mesec).padStart(2, '0')}-${String(datum.day).padStart(2, '0')}`;
  router.push(`/novo-desavanje/${encodeURIComponent(datumLink)}`).then(() => 
    toast.info("Napravite novo dešavanje")
  );
};

const ugasiDesavanje = () => {
  const FSElement = document.getElementById('fs');
  FSElement.removeChild(desavanja);
  desavanja = null;
};

const resetPozicije = () => {
  const desavanja = document.getElementById('desavanje');
  if(desavanja) {
    desavanja.style.right = "30px"
    desavanja.style.bottom = "30px"
    desavanja.style.top = ""
    desavanja.style.left = ""
  }
  

  localStorage.removeItem('desavanjaPosition')
}

window.addEventListener('resize', () => {
    const sirinaEk = window.innerWidth;

    if (sirinaEk <= 880) {
      const desavanja = document.getElementById('desavanje');
      if(desavanja) {
        desavanja.style.right = ""
        desavanja.style.bottom = ""
        desavanja.style.top = ""
        desavanja.style.left = ""
      }
      
    } 
    else {
      resetPozicije();
    }
});

function dragElement(element) {
  let dPos1 = 0, dPos2 = 0, dPos3 = 0, dPos4 = 0;

  const dragMouseDown = (e) => {
    e.preventDefault();
    dPos3 = e.clientX;
    dPos4 = e.clientY;

    document.onmousemove = elementDrag;
    document.onmouseup = closeDragElement;
  };

  const elementDrag = (e) => {
    e.preventDefault();
    dPos1 = dPos3 - e.clientX;
    dPos2 = dPos4 - e.clientY;
    dPos3 = e.clientX;
    dPos4 = e.clientY;

    element.style.top = (element.offsetTop - dPos2) + "px";
    element.style.left = (element.offsetLeft - dPos1) + "px";
  };

  const closeDragElement = () => {
    document.onmousemove = null;
    document.onmouseup = null;

    const position = {
      top: element.style.top,
      left: element.style.left
    };
    localStorage.setItem('desavanjaPosition', JSON.stringify(position));
  };

  element.onmousedown = dragMouseDown;
}

const changeDay = (datum, datumHeader, smer) => {
  datum.day += smer;
  if (datum.day < 1) {
    datum.month -= 1;
    if (datum.month < 0) {
      datum.month = 11;
      datum.year -= 1;
    }
    datum.day = new Date(datum.year, datum.month + 1, 0).getDate();
  } else if (datum.day > new Date(datum.year, datum.month + 1, 0).getDate()) {
    datum.month += 1;
    if (datum.month > 11) {
      datum.month = 0;
      datum.year += 1;
    }
    datum.day = 1;
  }
  
  const mesec = meseci[datum.month];
  datumHeader.innerHTML = `${datum.day}. ${mesec}. ${datum.year}.`;
  filtrirajDesavanja(datum);
};



</script>


<template>
  <div id="fs">
    <div class="ceoKalendar">
        <div class="calendar-header">
            <button class="senkaLevo glow" @click="changeMonth(-1)">
              &nbsp;<font-awesome-icon :icon="['fas', 'arrow-left']" class=""/>&nbsp;
            </button>
            <div style="text-align: center;"><h1>{{ currentYear }} - {{ meseci[currentMonth] }}</h1></div>
            <button class="senkaDesno glow" @click="changeMonth(1)">
              &nbsp;<font-awesome-icon :icon="['fas', 'arrow-right']" />&nbsp;
            </button>
            </div>
            <div class="calendar">
            <!-- Dani u nedelji -->
            <div v-for="day in daysOfWeek" :key="day" class="day">
                {{ day }}
            </div>
            <!-- Dani u mesecu -->
            <div
              v-for="(date, index) in days"
              @click="filtrirajDesavanja(date)"
              :key="index"
              class="date glow"
              :class="{ 
                empty: !date, 
                today: date?.isToday, 
                otherMonth: date?.isOtherMonth,
              }"
              :data-date="`${date?.year}-${String(date?.month + 1).padStart(2, '0')}-${String(date?.day).padStart(2, '0')}`"
            >
              {{ date?.day || '' }}
            </div>
        </div>
    </div>
    
  </div>
</template>

<style scoped>
.ceoKalendar{
  width: 90%; 
  display: flex; 
  flex-direction: column; 
  align-items: center;
  background-color: #1c1c1c;
  padding: 15px;
  border-radius: 30px;
  filter: drop-shadow(3px 3px 3px rgba(0, 0, 0, 0.5));
}
.calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    width: 100%;
    max-width: 400px;
    
    user-select: none;
    -webkit-user-select: none; 
    -moz-user-select: none; 
    -ms-user-select: none; 
}

.calendar-header button {
    background-color: #292929;
    color: white;
    border: none;
    border-radius: 10px;
    padding: 5px ;
    cursor: pointer;
    position: relative;
    z-index: 1;
    font-size: 20px
}
.calendar-header button:hover {
  background: linear-gradient(45deg, #42f5e6, #6c3dff, #f27cf0, #374bff);
}
.calendar {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 10px;
    width: 100%;

    user-select: none;
    -webkit-user-select: none; 
    -moz-user-select: none; 
    -ms-user-select: none; 
}

.day {
    font-weight: bold;
    text-align: center;
}

.date {
    padding: 10px;
    /*border: 1px solid #7512e6;*/
    border-radius: 18px;
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
.date:not(.otherMonth)::before{
  content: "";
  position: absolute;
  background-color: #292929;
  width: calc(100% - 4px);
  height: calc(100% - 4px);
  border-radius: 18px;
  z-index: -1;
}
.date:not(.otherMonth):hover{
  background: linear-gradient(45deg, #42f5e6, #6c3dff, #f27cf0, #374bff);
}

.date.today {
    background-color: #6c3dff;
}

.date.otherMonth {
    color: whitesmoke;
    background-color: #00000021;
    filter: none;
}
.has-event{
  color: #6c3dff;
}

@media screen and (min-width: 800px) {
    .date{
      padding: 20px 10px;
      font-size: 20px;
    }
}
@media screen and (max-width: 879px) {
    .calendar{
        gap: 5px;
    }
    
    .date:not(.otherMonth)::before{
      content: "";
      position: absolute;
      background-color: #292929;
      width: calc(100% - 3px);
      height: calc(100% - 4px);
      border-radius: 15px;
      z-index: -1;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
    }
}
</style>
