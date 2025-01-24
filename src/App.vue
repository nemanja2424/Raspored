<script setup>
import { onMounted, ref } from 'vue';
import { useRouter, RouterView } from 'vue-router'
import Navigacija from './components/Navigacija.vue';

const router = useRouter();

onMounted(() => {
    console.log("njakovlje@gmail.com");
    console.log("Nemanja123!");

    const access_token = localStorage.getItem('access_token');

    if (!access_token) {
        router.push('/login');
    }

    checkTokenExpiration();
});
function checkTokenExpiration() {
  const tokenExpiration = localStorage.getItem("token_expiration");

  if (tokenExpiration && Date.now() > parseInt(tokenExpiration, 10)) {
    ["access_token", "rola", "token_expiration", "userID"].forEach(item => localStorage.removeItem(item));

    console.log("Token je istekao. Podaci su obrisani iz localStorage.");
  }
}


</script>

<template>

<Navigacija></Navigacija>
<RouterView />
</template>

<style scoped>

</style>
