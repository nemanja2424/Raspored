import { createApp } from 'vue'
import App from './App.vue'
import Vue3Toastify from 'vue3-toastify';
import "vue3-toastify/dist/index.css"
import router from './router'
import './assets/main.css';
import axios from 'axios';

import { library } from '@fortawesome/fontawesome-svg-core';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { far } from '@fortawesome/free-regular-svg-icons';
library.add(fas, far);


const app = createApp(App)

app.use(Vue3Toastify, {
    autoClose: 3000,
});

app.use(router)
app.component('font-awesome-icon', FontAwesomeIcon);


app.mount('#app')
