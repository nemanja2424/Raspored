<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import { useRouter } from "vue-router";
import { toast } from "vue3-toastify";

const email = ref("");
const lozinka = ref("");
const router = useRouter();

onMounted(() => {
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

const handleSubmit = async (event) => {
    event.preventDefault();
    try {
        const response = await axios.post("/api/login", {
        email: email.value,
        lozinka: lozinka.value,
        });
        localStorage.setItem("access_token", response.data.access_token);
        localStorage.setItem("rola", response.data.rola);
        localStorage.setItem("userID", response.data.id);
        const expirationTime = Date.now() + 50 * 60 * 1000;
        localStorage.setItem("token_expiration", expirationTime.toString());
        router.push("/").then(() => {
            window.location.reload();
            toast.success(response.data.message);
        });
    } catch (error) {  
        toast.error(error.response.data.message || error.message);
    }
};

const isPasswordVisible = ref(false);

function togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
    const passwordInput = document.getElementById('lozinka');
    passwordInput.type = isPasswordVisible.value ? 'text' : 'password';
}

</script>

<template>
    <div class="blur">
        <div id="login" class="login">
            <form @submit.prevent="handleSubmit">
                <div class="form-group">
                    <input required type="email" class="form-style" placeholder="Email" id="email" v-model="email"/>
                    <font-awesome-icon :icon="['fas', 'at']" class="input-icon" />
                </div>
                <div class="form-group mt-2">
                    <input required type="password" class="form-style" placeholder="Lozinka" id="lozinka" v-model="lozinka"/>
                    <font-awesome-icon :icon="['fas', 'lock']" class="input-icon" />
                    <div class="showHidePassword">
                        <font-awesome-icon :icon="['fas', 'eye']" id="show" />
                        <font-awesome-icon :icon="['fas', 'eye-slash']" id="hide" style="cursor: pointer; display: none" />
                    </div>
                </div>
                <input type="submit" class="dugme" role="button" value="Prijavi se" />
            </form>
        </div>
    </div>
</template>


<style scoped>
#login{
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
#login::before{
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
.dugme:hover{  
    background-color: #6c3dff;
}
@media screen and (min-width: 880px) {
    #login{
        padding: 20px;
        min-width: 600px;
        min-height: 400px;
    }

}
@media screen and (max-width: 880px){
    #login{
        width: 90%;
        min-height: 400px;
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

</style>