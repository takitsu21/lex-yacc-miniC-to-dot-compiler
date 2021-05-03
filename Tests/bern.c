int a, b, c;
extern int printd(int i);


int test( int d ) {
    a = b + c;
    if(1==1)
    {
        int e;
        if (1==1)
        {

            int f;

            d = f;
        }
        if (d==e)
        {
            int g;
            g = c + d;
            d = g;
        }
    }
    return d;
}


int test2( int g ) {
    printd(1);
    if(a==b)
    {
        int h;
        h = 0;
        if (g==h)
        {
            int i;
            i = 0;
            a = i + b + g;
            return a;
        }
    }
    return h;
}

int main() {
    int x,y;
    x = test(x);
    y = test2(2);

    return x + y;
}