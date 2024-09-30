#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <mach/mach_time.h>

extern void simd_add_floats(float* a, float* b, float* result, int size);

#define NUM_RUNS 100
#define NUM_TESTS 6
#define INITIAL_SIZE 100000

void c_add_floats(float* a, float* b, float* result, int size) {
    for (int i = 0; i < size; i++) {
        result[i] = a[i] + b[i];
    }
}

double get_time_in_seconds() {
    static mach_timebase_info_data_t timebase_info;
    if (timebase_info.denom == 0) {
        mach_timebase_info(&timebase_info);
    }
    uint64_t time = mach_absolute_time();
    return (double)time * timebase_info.numer / timebase_info.denom / 1e9;
}

void run_test(int size) {
    float *a = aligned_alloc(16, size * sizeof(float));
    float *b = aligned_alloc(16, size * sizeof(float));
    float *result_simd = aligned_alloc(16, size * sizeof(float));
    float *result_c = aligned_alloc(16, size * sizeof(float));

    if (!a || !b || !result_simd || !result_c) {
        fprintf(stderr, "Memory allocation failed for size %d\n", size);
        exit(1);
    }

    // Initialize arrays with some values
    for (int i = 0; i < size; i++) {
        a[i] = (float)rand() / RAND_MAX * 100.0f;
        b[i] = (float)rand() / RAND_MAX * 100.0f;
    }

    // Profiling
    double total_time_simd = 0.0;
    double total_time_c = 0.0;

    for (int run = 0; run < NUM_RUNS; run++) {
        // SIMD version
        double start_time = get_time_in_seconds();
        simd_add_floats(a, b, result_simd, size);
        double end_time = get_time_in_seconds();
        total_time_simd += end_time - start_time;

        // C version
        start_time = get_time_in_seconds();
        c_add_floats(a, b, result_c, size);
        end_time = get_time_in_seconds();
        total_time_c += end_time - start_time;
    }

    double avg_time_simd = total_time_simd / NUM_RUNS;
    double avg_time_c = total_time_c / NUM_RUNS;

    printf("Array size: %d\n", size);
    printf("Average time for SIMD version: %f seconds\n", avg_time_simd);
    printf("Average time for C version: %f seconds\n", avg_time_c);
    printf("Speedup: %f\n\n", avg_time_c / avg_time_simd);

    // Verify results
    for (int i = 0; i < size; i++) {
        if (fabsf(result_simd[i] - result_c[i]) > 1e-6) {
            fprintf(stderr, "Mismatch at index %d: SIMD %f, C %f\n", i, result_simd[i], result_c[i]);
            break;
        }
    }

    // Free allocated memory
    free(a);
    free(b);
    free(result_simd);
    free(result_c);
}

int main(void) {
    srand(time(NULL));

    for (int test = 0; test < NUM_TESTS; test++) {
        int size = INITIAL_SIZE * (1 << test);  // Double the size each time
        run_test(size);
    }

    return 0;
}
