#include <stdio.h>
#include <stdlib.h>
#include <complex.h>

#define STB_IMAGE_WRITE_IMPLEMENTATION

#include "stb_image_write.h"

#define SQ3 1.7320508075688772
#define SX 1111
#define SY 1111

_Complex double poly(_Complex double z, int power);

_Complex double dpoly(_Complex double z, int power);

void drawit(int power);

double gr[SY][SX][3];

int main(int argc, char **argv) {
    int power = 5;
    if (argc > 1) {
        power = atoi(argv[1]);
        if (power < 2) {
            printf("Power must be at least 2.\n");
            return (1);
        }
    }

    drawit(power);

    unsigned char *rgb = malloc(SX * SY * 3);
    for (int y = 0; y < SY; y++) {
        for (int x = 0; x < SX; x++) {
            for (int c = 0; c < 3; c++) {
                double t = gr[y][x][c];
                int idx = (y * SX + x) * 3 + c;
                rgb[idx] = t <= 0 ? 0 : (t >= 1 ? 255 : t * 255);
            }
        }
    }

    char filename[32];
    sprintf(filename, "newtroot_%d.png", power);
    stbi_write_png(filename, SX, SY, 3, rgb, SX * 3);
    free(rgb);

    return 0;
}

_Complex double poly(_Complex double z, int power) {
    _Complex double result = 1;
    for (int i = 0; i < power; i++)
        result *= z;
    return result - 1;
}

_Complex double dpoly(_Complex double z, int power) {
    _Complex double result = 1;
    for (int i = 0; i < power - 1; i++)
        result *= z;
    return power * result;
}

void drawit(int power) {
    int x, y, n;
    _Complex double z, w;
    double f, s;
    for (y = 0; y < SY; ++y)
        for (x = 0; x < SX; ++x) {
            z = (x * (10. / SX) - 5) - (y * (10. / SY) - 5) * 1i;
            w = poly(z, power);

            for (f = s = 1; f > .01 && (__real__(w * ~w)) > .01;
                 f *= .95, s = -s, w = poly(z, power))
                z = z - w / dpoly(z, power);
            z = z - w / (dpoly(z, power));

            for (n = 0; n < 10; ++n)
                z = z - (poly(z, power) / (dpoly(z, power)));

            //z = f * (z * z) / (z * ~z);
            z = f * z / cabs(z);

            gr[y][x][0] = .5 * f /*+.02*s*f*/ + .24 * (__real__(z)) -
                          (SQ3 * .24) * (__imag__(z));
            gr[y][x][1] = .5 * f /*+.02*s*f*/ + .24 * (__real__(z)) +
                          (SQ3 * .24) * (__imag__(z));
            gr[y][x][2] = .5 * f /*+.02*s*f*/ - .48 * (__real__(z));
        }
}


