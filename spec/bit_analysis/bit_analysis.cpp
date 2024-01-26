#define SC_INCLUDE_FX
#include <systemc>
#include <iostream>
#include <deque>
#include <vector>
#include <cmath>
typedef sc_dt::sc_fix_fast num_t;
typedef std::deque<num_t> array_t;
typedef std::vector<double> orig_array_t;

void copy2fix(array_t &dest, const orig_array_t &src, int W, int F)
{
    for (size_t i = 0; i != src.size(); ++i)
    {
        num_t d(W, F);
        d = src[i];
        if (d.overflow_flag())
            std ::cout << "Overflow in conversion.\n";
        dest.push_back(d);
    }
}
bool passCheck(const orig_array_t &gold, const orig_array_t &sys, double delta)
{

    for (size_t i = 0; i != gold.size(); ++i)
    {
        if (std::abs(gold[i] - sys[i]) > delta)
            return false;
    }
    return true;
}
int sc_main(int argc, char *argv[])
{
    orig_array_t a_orig = {1};                                                             // ono sto stoji uz y[n]
    orig_array_t b_orig = {0.0022860, 0.0457215, 0.0022860, 0.006, 0.0457215, 0.006, 0.007, 0.0457215, 0.007, 0.008}; // ono sto stoji uz x[n]
    orig_array_t x_orig = {0};                                                                                  // pocetni uslovi
    orig_array_t y_orig = {0};                                                                                     // pocetni uslovi

    // 10 samples from our output vector file from the 12001 - 12010 position are:
    orig_array_t gold = {-33, -31, -21, -28, -24, -16, -21, -19, -13, -12};
    orig_array_t sys;
    array_t a;
    array_t b;
    array_t x;
    array_t y;

    const double error_d = 30;
    int W = 16;
    const int F = 16;
    bool pass = false;
    // Main l o o p
    do
    {
        std ::cout << "Starting␣pass␣for␣number␣format␣" << F << " . " << W - F << std ::endl;
        // convert numbers
        copy2fix(a, a_orig, W, F);
        copy2fix(b, b_orig, W, F);
        copy2fix(x, x_orig, W, F);
        copy2fix(y, y_orig, W, F);

        // C a l c u l a t e o u t p u t
        for (size_t i = 0; i < 10; ++i)
        {
            num_t sum(W, F);
            sum = 0;
            for (size_t i = 0; i != b_orig.size(); ++i)
                sum += b[i] * x[i];
            for (size_t i = 0; i != a_orig.size(); ++i)
                sum -= a[i] * y[i];
            x.pop_back();
            x.push_front(0);
            y.pop_back();
            y.push_front(sum);
            sys.push_back(sum.to_double());
            std::cout << sum << "␣";
        }

        std::cout << std::endl;
        // Check i f e r r o r i s s m a l l enough
        pass = passCheck(gold, sys, error_d);
        W++;
        sys.clear();
        a.clear();
        b.clear();
        x.clear();
        y.clear();
    } while (pass == false);
    std::cout << std::endl;

    return 0;
}
