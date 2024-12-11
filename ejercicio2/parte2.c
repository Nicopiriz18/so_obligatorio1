#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>

sem_t s_IP, s_M1, s_F1;
sem_t s_ED, s_M2, s_F2;
sem_t s_PA, s_BD, s_RC, s_SO, s_IS, s_SI, s_IA, s_CG, s_DW, s_SD, s_BGD, s_RO, s_CS, s_AA;

void *func_IP(void *arg){
    printf("Introduccion a la Programacion (IP)\n");
    sem_post(&s_IP);
    return NULL;
}

void *func_M1(void *arg){
    printf("Matematicas I (M1)\n");
    sem_post(&s_M1);
    return NULL;
}

void *func_F1(void *arg){
    printf("Fisica I (F1)\n");
    sem_post(&s_F1);
    return NULL;
}

void *func_ED(void *arg){
    sem_wait(&s_IP);
    printf("Estructuras de Datos (ED)\n");
    sem_post(&s_ED);
    sem_post(&s_ED);
    return NULL;
}

void *func_M2(void *arg){
    sem_wait(&s_M1);
    printf("Matematicas II (M2)\n");
    sem_post(&s_M2);
    sem_post(&s_M2);
    sem_post(&s_M2);
    sem_post(&s_M2);
    return NULL;
}

void *func_F2(void *arg){
    sem_wait(&s_F1);
    printf("Fisica II (F2)\n");
    sem_post(&s_F2);
    sem_post(&s_F2);
    sem_post(&s_F2);
    return NULL;
}

void *func_BD(void *arg){
    sem_wait(&s_ED);
    printf("Bases de Datos (BD)\n");
    sem_post(&s_BD);
    sem_post(&s_BD);
    sem_post(&s_BD);
    return NULL;
}

void *func_IS(void *arg){
    sem_wait(&s_PA);
    printf("Ingenieria de Software (IS)\n");
    sem_post(&s_IS);
    return NULL;
}

void *func_PA(void *arg){
    sem_wait(&s_ED); 
    sem_wait(&s_M2);
    printf("Programacion Avanzada (PA)\n");
    for(int i=0; i<9; i++){
        sem_post(&s_PA);
    }
    return NULL;
}

void *func_RC(void *arg){
    sem_wait(&s_PA);
    sem_wait(&s_F2);
    printf("Redes de Computadoras (RC)\n");
    for(int i=0; i<5; i++){
        sem_post(&s_RC);
    }
    return NULL;
}

void *func_SO(void *arg){
    sem_wait(&s_PA);
    sem_wait(&s_RC);
    printf("Sistemas Operativos (SO)\n");
    sem_post(&s_SO);
    sem_post(&s_SO);
    return NULL;
}

void *func_SI(void *arg){
    sem_wait(&s_RC);
    sem_wait(&s_BD);
    printf("Seguridad Informatica (SI)\n");
    sem_post(&s_SI);
    return NULL;
}

void *func_IA(void *arg){
    sem_wait(&s_PA);
    sem_wait(&s_M2);
    printf("Inteligencia Artificial (IA)\n");
    sem_post(&s_IA);
    return NULL;
}

void *func_CG(void *arg){
    sem_wait(&s_F2);
    sem_wait(&s_PA);
    printf("Computacion Grafica (CG)\n");
    sem_post(&s_CG);
    return NULL;
}

void *func_DW(void *arg){
    sem_wait(&s_BD);
    sem_wait(&s_RC);
    printf("Desarrollo Web (DW)\n");
    sem_post(&s_DW);
    return NULL;
}

void *func_SD(void *arg){
    sem_wait(&s_SO);
    sem_wait(&s_RC);
    printf("Sistemas Distribuidos (SD)\n");
    sem_post(&s_SD);
    return NULL;
}

void *func_BGD(void *arg){
    sem_wait(&s_BD);
    sem_wait(&s_M2);
    printf("Big Data (BGD)\n");
    sem_post(&s_BGD);
    return NULL;
}

void *func_RO(void *arg){
    sem_wait(&s_F2);
    sem_wait(&s_PA);
    printf("Robotica (RO)\n");
    sem_post(&s_RO);
    return NULL;
}

void *func_CS(void *arg){
    sem_wait(&s_SI);
    sem_wait(&s_SO);
    printf("Ciberseguridad (CS)\n");
    sem_post(&s_CS);
    return NULL;
}

void *func_AA(void *arg){
    sem_wait(&s_PA);
    sem_wait(&s_M2);
    printf("Analisis de Algoritmos (AA)\n");
    sem_post(&s_AA);
    return NULL;
}

int main(){
    sem_init(&s_IP, 0, 0);
    sem_init(&s_M1, 0, 0);
    sem_init(&s_F1, 0, 0);
    sem_init(&s_ED, 0, 0);
    sem_init(&s_M2, 0, 0);
    sem_init(&s_F2, 0, 0);
    sem_init(&s_PA, 0, 0);
    sem_init(&s_BD, 0, 0);
    sem_init(&s_RC, 0, 0);
    sem_init(&s_SO, 0, 0);
    sem_init(&s_IS, 0, 0);
    sem_init(&s_SI, 0, 0);
    sem_init(&s_IA, 0, 0);
    sem_init(&s_CG, 0, 0);
    sem_init(&s_DW, 0, 0);
    sem_init(&s_SD, 0, 0);
    sem_init(&s_BGD, 0, 0);
    sem_init(&s_RO, 0, 0);
    sem_init(&s_CS, 0, 0);
    sem_init(&s_AA, 0, 0);

    pthread_t t_IP, t_M1, t_F1, t_ED, t_M2, t_F2, t_PA, t_BD, t_RC, t_SO;
    pthread_t t_IS, t_SI, t_IA, t_CG, t_DW, t_SD, t_BGD, t_RO, t_CS, t_AA;

    pthread_create(&t_IP, NULL, func_IP, NULL);
    pthread_create(&t_M1, NULL, func_M1, NULL);
    pthread_create(&t_F1, NULL, func_F1, NULL);
    pthread_create(&t_ED, NULL, func_ED, NULL);
    pthread_create(&t_M2, NULL, func_M2, NULL);
    pthread_create(&t_F2, NULL, func_F2, NULL);
    pthread_create(&t_PA, NULL, func_PA, NULL);
    pthread_create(&t_BD, NULL, func_BD, NULL);
    pthread_create(&t_RC, NULL, func_RC, NULL);
    pthread_create(&t_SO, NULL, func_SO, NULL);
    pthread_create(&t_IS, NULL, func_IS, NULL);
    pthread_create(&t_SI, NULL, func_SI, NULL);
    pthread_create(&t_IA, NULL, func_IA, NULL);
    pthread_create(&t_CG, NULL, func_CG, NULL);
    pthread_create(&t_DW, NULL, func_DW, NULL);
    pthread_create(&t_SD, NULL, func_SD, NULL);
    pthread_create(&t_BGD, NULL, func_BGD, NULL);
    pthread_create(&t_RO, NULL, func_RO, NULL);
    pthread_create(&t_CS, NULL, func_CS, NULL);
    pthread_create(&t_AA, NULL, func_AA, NULL);

    pthread_join(t_IP, NULL);
    pthread_join(t_M1, NULL);
    pthread_join(t_F1, NULL);
    pthread_join(t_ED, NULL);
    pthread_join(t_M2, NULL);
    pthread_join(t_F2, NULL);
    pthread_join(t_PA, NULL);
    pthread_join(t_BD, NULL);
    pthread_join(t_RC, NULL);
    pthread_join(t_SO, NULL);
    pthread_join(t_IS, NULL);
    pthread_join(t_SI, NULL);
    pthread_join(t_IA, NULL);
    pthread_join(t_CG, NULL);
    pthread_join(t_DW, NULL);
    pthread_join(t_SD, NULL);
    pthread_join(t_BGD, NULL);
    pthread_join(t_RO, NULL);
    pthread_join(t_CS, NULL);
    pthread_join(t_AA, NULL);

    sem_destroy(&s_IP);
    sem_destroy(&s_M1);
    sem_destroy(&s_F1);
    sem_destroy(&s_ED);
    sem_destroy(&s_M2);
    sem_destroy(&s_F2);
    sem_destroy(&s_PA);
    sem_destroy(&s_BD);
    sem_destroy(&s_RC);
    sem_destroy(&s_SO);
    sem_destroy(&s_IS);
    sem_destroy(&s_SI);
    sem_destroy(&s_IA);
    sem_destroy(&s_CG);
    sem_destroy(&s_DW);
    sem_destroy(&s_SD);
    sem_destroy(&s_BGD);
    sem_destroy(&s_RO);
    sem_destroy(&s_CS);
    sem_destroy(&s_AA);

    return 0;
}
