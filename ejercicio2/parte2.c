#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>

const char* courses[] = {
    "IP", "M1", "F1", "ED", "M2", "F2", "PA", "BD", "RC", "SO",
    "IS", "SI", "IA", "CG", "DW", "SD", "BiD", "RO", "CS", "AA"
};

int prerequisites_count[] = {
    0, 0, 0, 1, 1, 1, 2, 1, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2
};

int prerequisites[20][2] = {
    {}, {}, {}, {0}, {1}, {2}, {3,4}, {3}, {6,5}, {6,8}, {6}, {8,7}, {6,4}, {5,6}, {7,8}, {9,8}, {7,4}, {5,6}, {11,9}, {6,4}
};

typedef struct {
    int count;
    int list[20];
} DependentsList;

DependentsList dependents[20];

#define N 20

sem_t sem_start[N];
pthread_t threads[N];

int prereqs_remaining[N];

pthread_mutex_t lock;

void* course_thread(void* arg) {
    int course_id = *(int*)arg;
    free(arg);

    sem_wait(&sem_start[course_id]);

    printf("Curso completado: %s\n", courses[course_id]);

    pthread_mutex_lock(&lock);
    for (int i = 0; i < dependents[course_id].count; i++) {
        int dep = dependents[course_id].list[i];
        prereqs_remaining[dep]--;
        if (prereqs_remaining[dep] == 0) {
            sem_post(&sem_start[dep]);
        }
    }
    pthread_mutex_unlock(&lock);

    return NULL;
}

int main() {
    pthread_mutex_init(&lock, NULL);

    for (int i = 0; i < N; i++) {
        prereqs_remaining[i] = prerequisites_count[i];
    }

    for (int c = 0; c < N; c++) {
        for (int p = 0; p < prerequisites_count[c]; p++) {
            int pre = prerequisites[c][p];
            dependents[pre].list[dependents[pre].count++] = c;
        }
    }

    for (int i = 0; i < N; i++) {
        sem_init(&sem_start[i], 0, 0);
    }

    for (int i = 0; i < N; i++) {
        if (prereqs_remaining[i] == 0) {
            sem_post(&sem_start[i]);
        }
    }

    for (int i = 0; i < N; i++) {
        int* id = (int*)malloc(sizeof(int));
        *id = i;
        pthread_create(&threads[i], NULL, course_thread, id);
    }

    for (int i = 0; i < N; i++) {
        pthread_join(threads[i], NULL);
    }

    for (int i = 0; i < N; i++) {
        sem_destroy(&sem_start[i]);
    }
    pthread_mutex_destroy(&lock);

    return 0;
}