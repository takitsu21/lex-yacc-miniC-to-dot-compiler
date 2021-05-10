/* passe */

int tab[3][4][5];
int a[0];

int main() {
  tab[1][2] = a;
}

/* passe pas */

int tab[3][4][5];
int a[0];

int main() {
  tab[1][2] = a[0];
}

/* passe */

int tab[3][4][5];
int a[0];

int main() {
  a = tab[1][2];
}

/* passe pas */

int tab[3][4][5];
int a[0];

int main() {
  tab[1][2] = 0
}

/* passe */

int tab[3][4][5];
int a[0];

int main() {
  tab[1][2][0] = a[0];
}