extern int printd( int i );

int fact( int n ) {
  if (n <= 1)
    return 1;
  return n*fact(n-1);
}

int main() {
  printd(fact(10));
  return 0;
}

int tamere(int j) {
  if (tamere(1) * fact(5) > 6) {
    return main();
  }
}

int test2() {
  return 0;
}

int test(int a, int b, int c, int j) {
  return test(1, 2, 3, test(1, 2, 3, 6));
}