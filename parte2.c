// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
// #include <pthread.h>
// #include <unistd.h>

// typedef struct {
//     const char *nombre;
//     const char *codigo;
//     int prereqCount;          // cuantas prerequisitas faltan para poder cursarla
//     int dependCount;          // cuantas materias dependen de esta
//     int *dependIndices;       // indices de las materias que dependen de ésta
// } Materia;

// enum {
//     IP,  
//     M1,  
//     F1,  
//     ED,
//     M2,  
//     F2,
//     PA,  
//     BD,  
//     RC, 
//     SO,  
//     IS,  
//     SI, 
//     IA,  
//     CG,  
//     DW,  
//     SD,  
//     BD2, 
//     RO,  
//     CS,  
//     AA,  
//     TOTAL_MATERIAS
// };

// Materia materias[TOTAL_MATERIAS] = {
//     {"Introduccion a la Programacion", "IP", 0, 0, NULL},
//     {"Matematicas I", "M1", 0, 0, NULL},
//     {"Fisica I", "F1", 0, 0, NULL},
//     {"Estructuras de Datos", "ED", 1, 0, NULL},       // req: IP
//     {"Matematicas II", "M2", 1, 0, NULL},             // req: M1
//     {"Fisica II", "F2", 1, 0, NULL},                  // req: F1
//     {"Programacion Avanzada", "PA", 2, 0, NULL},      // req: ED, M2
//     {"Bases de Datos", "BD", 1, 0, NULL},             // req: ED
//     {"Redes de Computadoras", "RC", 2, 0, NULL},      // req: PA, F2
//     {"Sistemas Operativos", "SO", 2, 0, NULL},        // req: PA, RC
//     {"Ingenieria de Software", "IS", 1, 0, NULL},     // req: PA
//     {"Seguridad Informatica", "SI", 2, 0, NULL},      // req: RC, BD
//     {"Inteligencia Artificial", "IA", 2, 0, NULL},    // req: PA, M2
//     {"Computacion Grafica", "CG", 2, 0, NULL},        // req: F2, PA
//     {"Desarrollo Web", "DW", 2, 0, NULL},             // req: BD, RC
//     {"Sistemas Distribuidos", "SD", 2, 0, NULL},      // req: SO, RC
//     {"Big Data", "BD2", 2, 0, NULL},                  // req: BD, M2 (Se llama BD2 en enum para no confundir)
//     {"Robotica", "RO", 2, 0, NULL},                   // req: F2, PA
//     {"Ciberseguridad", "CS", 2, 0, NULL},             // req: SI, SO
//     {"Analisis de Algoritmos", "AA", 2, 0, NULL}      // req: PA, M2
// };

// // relaciones de precedencia (edges)
// // para cada materia, indicamos de cuáles depende y agregamos esta materia como dependiente
// // en la lista de las materias prerequisito.
// typedef struct {
//     int materia;
//     int prereqs[10];   //indice de las materias prerequisito
//     int prereqCount;
// } Dependencia;

// Dependencia dependencias[] = {
//     {ED, {IP}, 1},
//     {M2, {M1}, 1},
//     {F2, {F1}, 1},
//     {PA, {ED, M2}, 2},
//     {BD, {ED}, 1},
//     {RC, {PA, F2}, 2},
//     {SO, {PA, RC}, 2},
//     {IS, {PA}, 1},
//     {SI, {RC, BD}, 2},
//     {IA, {PA, M2}, 2},
//     {CG, {F2, PA}, 2},
//     {DW, {BD, RC}, 2},
//     {SD, {SO, RC}, 2},
//     {BD2, {BD, M2}, 2},
//     {RO, {F2, PA}, 2},
//     {CS, {SI, SO}, 2},
//     {AA, {PA, M2}, 2},
//     // Las materias IP, M1, F1 no tienen prerequisitos, no se añaden.
// };

// // Para cada materia prerequisito, tenemos que añadir la materia dependiente a su lista.
// // Primero determinamos cuántos dependientes tiene cada uno para hacer el malloc correspondiente.
// static int dependCountArray[TOTAL_MATERIAS] = {0};

// // Sincronización
// pthread_mutex_t mtx = PTHREAD_MUTEX_INITIALIZER;
// pthread_cond_t cond = PTHREAD_COND_INITIALIZER;

// // Contador de cuántas materias faltan por "cursar".
// int materiasRestantes = TOTAL_MATERIAS;

// // Función simulando la "cursada" de una materia
// void *cursarMateria(void *arg) {
//     int idx = *(int *)arg;
//     free(arg);
//     printf("Cursando %s (%s)...\n", materias[idx].nombre, materias[idx].codigo);
//     fflush(stdout);

//     //una vez cursada, actualizamos las dependencias
//     pthread_mutex_lock(&mtx);

//     //por cada materia que depende de esta, decrementamos su prereqCount
//     for (int i = 0; i < materias[idx].dependCount; i++) {
//         int depIdx = materias[idx].dependIndices[i];
//         materias[depIdx].prereqCount--;
//         if (materias[depIdx].prereqCount == 0) {
//             // Esta materia ya se puede cursar, lanzamos un hilo para ella
//             int *argDep = malloc(sizeof(int));
//             *argDep = depIdx;
//             pthread_t th;
//             pthread_create(&th, NULL, cursarMateria, argDep);
//             pthread_detach(th);
//         }
//     }

//     materiasRestantes--;
//     if (materiasRestantes == 0) {
//         //todas cursadas, señalamos para que main pueda continuar
//         pthread_cond_signal(&cond);
//     }

//     pthread_mutex_unlock(&mtx);
//     return NULL;
// }

// int main() {
//     //inicializamos el conteo de dependencias a partir de las dependencias declaradas
//     for (int i = 0; i < (int)(sizeof(dependencias)/sizeof(dependencias[0])); i++) {
//         int mat = dependencias[i].materia;
//         for (int j = 0; j < dependencias[i].prereqCount; j++) {
//             int prereq = dependencias[i].prereqs[j];
//             dependCountArray[prereq]++;
//         }
//     }

//     //asignamos espacio para las listas de dependientes
//     for (int i = 0; i < TOTAL_MATERIAS; i++) {
//         if (dependCountArray[i] > 0) {
//             materias[i].dependIndices = (int *)malloc(sizeof(int)*dependCountArray[i]);
//         }
//     }

//     //llenamos las listas de dependientes
//     int *currentPos = (int *)calloc(TOTAL_MATERIAS, sizeof(int));
//     for (int i = 0; i < (int)(sizeof(dependencias)/sizeof(dependencias[0])); i++) {
//         int mat = dependencias[i].materia;
//         for (int j = 0; j < dependencias[i].prereqCount; j++) {
//             int prereq = dependencias[i].prereqs[j];
//             int pos = currentPos[prereq]++;
//             materias[prereq].dependIndices[pos] = mat;
//             materias[prereq].dependCount++;
//         }
//     }
//     free(currentPos);

//     //lanzamos hilos para todas las materias que no tengan prerequisitos (prereqCount = 0)
//     pthread_mutex_lock(&mtx);
//     for (int i = 0; i < TOTAL_MATERIAS; i++) {
//         if (materias[i].prereqCount == 0) {
//             int *arg = malloc(sizeof(int));
//             *arg = i;
//             pthread_t th;
//             pthread_create(&th, NULL, cursarMateria, arg);
//             pthread_detach(th);
//         }
//     }

//     //esperamos a que todas las materias terminen
//     while (materiasRestantes > 0) {
//         pthread_cond_wait(&cond, &mtx);
//     }
//     pthread_mutex_unlock(&mtx);

//     //liberamos memoria
//     for (int i = 0; i < TOTAL_MATERIAS; i++) {
//         if (materias[i].dependIndices) {
//             free(materias[i].dependIndices);
//         }
//     }

//     printf("Todas las materias han sido cursadas!\n");
//     return 0;
// }
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>

const char* courses[] = {
    "IP", "M1", "F1", "ED", "M2", "F2", "PA", "BD", "RC", "SO",
    "IS", "SI", "IA", "CG", "DW", "SD", "BiD", "RO", "CS", "AA"
};

// Precedencias: para cada índice, se listan los prerequisitos por sus índices
// Por ejemplo, ED (3) depende de IP (0), M2 (4) depende de M1 (1), etc.
int prerequisites_count[] = {
    0, // IP
    0, // M1
    0, // F1
    1, // ED: IP(0)
    1, // M2: M1(1)
    1, // F2: F1(2)
    2, // PA: ED(3), M2(4)
    1, // BD: ED(3)
    2, // RC: PA(6), F2(5)
    2, // SO: PA(6), RC(8)
    1, // IS: PA(6)
    2, // SI: RC(8), BD(7)
    2, // IA: PA(6), M2(4)
    2, // CG: F2(5), PA(6)
    2, // DW: BD(7), RC(8)
    2, // SD: SO(9), RC(8)
    2, // BiD: BD(7), M2(4)
    2, // RO: F2(5), PA(6)
    2, // CS: SI(11), SO(9)
    2  // AA: PA(6), M2(4)
};

int prerequisites[20][2] = {
    {},           // IP
    {},           // M1
    {},           // F1
    {0},          // ED: IP(0)
    {1},          // M2: M1(1)
    {2},          // F2: F1(2)
    {3,4},        // PA: ED(3), M2(4)
    {3},          // BD: ED(3)
    {6,5},        // RC: PA(6), F2(5)
    {6,8},        // SO: PA(6), RC(8)
    {6},          // IS: PA(6)
    {8,7},        // SI: RC(8), BD(7)
    {6,4},        // IA: PA(6), M2(4)
    {5,6},        // CG: F2(5), PA(6)
    {7,8},        // DW: BD(7), RC(8)
    {9,8},        // SD: SO(9), RC(8)
    {7,4},        // BiD: BD(7), M2(4)
    {5,6},        // RO: F2(5), PA(6)
    {11,9},       // CS: SI(11), SO(9)
    {6,4}         // AA: PA(6), M2(4)
};

// Para saber quién depende de quién, construimos la lista de dependientes (hijos)
typedef struct {
    int count;
    int list[20];
} DependentsList;

DependentsList dependents[20];

// Número total de cursos
#define N 20

// Semáforos
sem_t sem_start[N];    // semáforo que indica a cada curso cuándo puede iniciar (cuando sus prereqs estén listas)
pthread_t threads[N];   // un hilo por curso

// Array para contar cuántos prereqs quedan
int prereqs_remaining[N];

pthread_mutex_t lock; // Para proteger actualizaciones en prereqs_remaining y dependents

void* course_thread(void* arg) {
    int course_id = *(int*)arg;
    free(arg); // liberar el índice dinámico

    // Esperar a que prereqs_remaining[course_id] == 0
    sem_wait(&sem_start[course_id]);

    // Ahora que puede comenzar, "imprime" el curso:
    printf("Curso completado: %s\n", courses[course_id]);

    // Una vez completado este curso, avisar a sus dependientes
    pthread_mutex_lock(&lock);
    for (int i = 0; i < dependents[course_id].count; i++) {
        int dep = dependents[course_id].list[i];
        prereqs_remaining[dep]--;
        if (prereqs_remaining[dep] == 0) {
            // Si ya no quedan prereqs para dep, liberamos su semáforo
            sem_post(&sem_start[dep]);
        }
    }
    pthread_mutex_unlock(&lock);

    return NULL;
}

int main() {
    // Inicializar mutex
    pthread_mutex_init(&lock, NULL);

    // Inicializar prereqs_remaining
    for (int i = 0; i < N; i++) {
        prereqs_remaining[i] = prerequisites_count[i];
    }

    // Construir la lista de dependientes
    // Por cada curso, por cada prerequisito de ese curso,
    // agregar este curso a la lista de dependientes del prerequisito.
    for (int c = 0; c < N; c++) {
        for (int p = 0; p < prerequisites_count[c]; p++) {
            int pre = prerequisites[c][p];
            dependents[pre].list[dependents[pre].count++] = c;
        }
    }

    // Inicializar semáforos
    for (int i = 0; i < N; i++) {
        sem_init(&sem_start[i], 0, 0);
    }

    // Los cursos sin prerequisitos pueden arrancar ya
    for (int i = 0; i < N; i++) {
        if (prereqs_remaining[i] == 0) {
            sem_post(&sem_start[i]);
        }
    }

    // Crear hilos
    for (int i = 0; i < N; i++) {
        int* id = (int*)malloc(sizeof(int));
        *id = i;
        pthread_create(&threads[i], NULL, course_thread, id);
    }

    // Esperar a que todos terminen
    for (int i = 0; i < N; i++) {
        pthread_join(threads[i], NULL);
    }

    // Destruir semáforos y mutex
    for (int i = 0; i < N; i++) {
        sem_destroy(&sem_start[i]);
    }
    pthread_mutex_destroy(&lock);

    return 0;
}