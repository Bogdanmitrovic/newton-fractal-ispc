//
// Created by Bogdan Mitrovic on 1. 11. 2025..
//
#include <cstdio>
#include <cstdlib>
#include <ctime>

#define STB_IMAGE_WRITE_IMPLEMENTATION

#include "stb_image_write.h"

#include "fractal_ispc.h"

#define SX 1111
#define SY 1111

int main(int argc, char **argv) {
    int power = 5;

    if (argc > 1) {
        power = atoi(argv[1]);
        if (power < 2) {
            printf("Power must be at least 2.\n");
            return 1;
        }
    }

    double *r = new double[SX * SY];
    double *g = new double[SX * SY];
    double *b = new double[SX * SY];

    clock_t start = clock();
    ispc::drawit_ispc(r, g, b, SX, SY, power);

    clock_t end = clock();
    double elapsed = static_cast<double>(end - start) / CLOCKS_PER_SEC;
    printf("time: %.3f seconds\n", elapsed);

    unsigned char *rgb = new unsigned char[SX * SY * 3];

    for (int i = 0; i < SX * SY; i++) {
        double tr = r[i];
        double tg = g[i];
        double tb = b[i];
        rgb[i * 3 + 0] = tr <= 0 ? 0 : (tr >= 1 ? 255 : static_cast<unsigned char>(tr * 255));
        rgb[i * 3 + 1] = tg <= 0 ? 0 : (tg >= 1 ? 255 : static_cast<unsigned char>(tg * 255));
        rgb[i * 3 + 2] = tb <= 0 ? 0 : (tb >= 1 ? 255 : static_cast<unsigned char>(tb * 255));
    }

    char filename[64];
    snprintf(filename, sizeof(filename), "newtroot_%d.png", power);

    if (!stbi_write_png(filename, SX, SY, 3, rgb, SX * 3)) {
        printf("Failed to write PNG file\n");
        delete[] r;
        delete[] g;
        delete[] b;
        delete[] rgb;
        return 1;
    }

    delete[] r;
    delete[] g;
    delete[] b;
    delete[] rgb;

    return 0;
}