int a, b, c;
extern int printd(int i);

int foo(int d)
{
    a = b + c;
    if (1 == 1)
    {
        int e;
        if (1 == 1)
        {

            int f;
            d = f;
            while (f > d) {
                d = 1;
            }
        }
        if (d == e)
        {
            switch (a)
            {
            case 1:
                return a;
            case 2:
                return foo(5);
            default:
                return e;
            }
        }
    }
    return d;
}

int bar(int g)
{
    printd(1);
    if (a == b)
    {
        int h;
        h = 0;
        if (g == h && a > 0 || h == 0 && (h & 0) > a)
        {
            int i;
            i = 0;
            a = i + b + g;
            return a;
        }
        else
        {
            int i;
            for ( i = 0; i < 10; i = i + 1) {
                if (i == 5) {
                    break;
                }
            }
        }
    }
    return g;
}

int main()
{
    int tab[2][3];
    int x, y;
    x = foo(x);
    y = bar(2);

    return x + y + main();
}