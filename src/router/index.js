import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Kalendar from '../views/Kalendar.vue'
import Login from '../views/Login.vue'
import NovoDesavanje from '../views/NovoDesavanje.vue'
import IzmenaDesavanja from '../views/IzmenaDesavanja.vue'
import Zadaci from '../views/Zadaci.vue'
import IzmenaZadatka from '../views/IzmenaZadatka.vue'
import Admin from '../views/Admin.vue'
import NoviKorisnik from '../views/NoviKorisnik.vue'
import IzmenaKorisnika from '../views/IzmenaKorisnika.vue'
import Profil from '../views/Profil.vue'
import Statistika from '../views/Statistika.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/home',
      name: 'Home',
      component: Home
    },
    {
      path: '/kalendar/:id',
      name: 'Kalendar',
      component: Kalendar
    },
    {
      path: '/zadaci/:id',
      name: 'Zadaci',
      component: Zadaci
    },
    {
      path: '/login',
      name: 'Login',
      component: Login
    },
    {
      path: '/novo-desavanje/:datum',
      name: 'novo-desavanje',
      component: NovoDesavanje,
      props: true
    },
    {
      path: '/izmena/:id',
      name: 'izmena',
      component: IzmenaDesavanja,
      props: true
    },
    {
      path: '/izmenaz/:id',
      name: 'izmenaz',
      component: IzmenaZadatka,
      props: true
    },
    {
      path: '/admin',
      name: 'Admin',
      component: Admin
    },
    {
      path: '/novi-korisnik',
      name: 'NoviKorisnik',
      component: NoviKorisnik
    },
    {
      path: '/izmenak/:id',
      name: 'izmenak',
      component: IzmenaKorisnika,
      props: true
    },
    {
      path: '/profil',
      name: 'Profil',
      component: Profil
    },
    {
      path: '/statistika',
      name: 'Statistika',
      component: Statistika
    }
  ]
})

export default router
