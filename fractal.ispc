struct Complex {
    double re;
    double im;
};

// operations
inline Complex complex_make(double re, double im) {
    Complex c;
    c.re = re;
    c.im = im;
    return c;
}

inline Complex complex_sub(Complex a, Complex b) {
    Complex c;
    c.re = a.re - b.re;
    c.im = a.im - b.im;
    return c;
}

inline Complex complex_mul(Complex a, Complex b) {
    Complex c;
    c.re = a.re * b.re - a.im * b.im;
    c.im = a.re * b.im + a.im * b.re;
    return c;
}

inline Complex complex_div(Complex a, Complex b) {
    Complex c;
    double denom = b.re * b.re + b.im * b.im;
    c.re = (a.re * b.re + a.im * b.im) / denom;
    c.im = (a.im * b.re - a.re * b.im) / denom;
    return c;
}

inline double complex_abs(Complex a) {
    return sqrt(a.re * a.re + a.im * a.im);
}

inline double complex_abs_sq(Complex a) {
    return a.re * a.re + a.im * a.im;
}
// poly & dpoly
inline Complex poly(Complex z, uniform int power) {
    Complex result = complex_make(1.0, 0.0);
    for (uniform int i = 0; i < power; i++) {
        result = complex_mul(result, z);
    }
    result.re -= 1.0;
    return result;
}

inline Complex dpoly(Complex z, uniform int power) {
    Complex result = complex_make(1.0, 0.0);
    for (uniform int i = 0; i < power - 1; i++) {
        result = complex_mul(result, z);
    }
    result.re *= power;
    result.im *= power;
    return result;
}
// drawit
export void drawit_ispc(uniform double r[],
                        uniform double g[],
                        uniform double b[],
                        uniform int SX, uniform int SY,
                        uniform int power) {
    uniform double SQ3 = 1.7320508075688772;
    uniform double scaleX = 10.0 / SX;
    uniform double scaleY = 10.0 / SY;

    foreach (y = 0 ... SY, x = 0 ... SX) {
        int idx = y * SX + x;

        Complex z = complex_make(
            x * (scaleX) - 5.0,
            -(y * (scaleY) - 5.0)
        );

        Complex w = poly(z, power);

        double f = 1.0;
        double s = 1.0;

        while (f > 0.01 && complex_abs_sq(w) > 0.01) {
            Complex dw = dpoly(z, power);
            Complex step = complex_div(w, dw);
            z = complex_sub(z, step);

            f *= 0.95;
            s = -s;
            w = poly(z, power);
        }

        Complex dw = dpoly(z, power);
        Complex step = complex_div(w, dw);
        z = complex_sub(z, step);

        for (uniform int n = 0; n < 10; ++n) {
            Complex p = poly(z, power);
            Complex dp = dpoly(z, power);
            Complex step = complex_div(p, dp);
            z = complex_sub(z, step);
        }

        double abs_z = complex_abs(z);
        if (abs_z > 0.0) {
            z.re = f * z.re / abs_z;
            z.im = f * z.im / abs_z;
        }
        r[idx] = 0.5 * f + 0.24 * z.re - (SQ3 * 0.24) * z.im;
        g[idx] = 0.5 * f + 0.24 * z.re + (SQ3 * 0.24) * z.im;
        b[idx] = 0.5 * f - 0.48 * z.re;
    }
}