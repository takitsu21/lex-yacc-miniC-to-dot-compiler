extern int printd( int i );



int main() {
   int i, x;
   for (i=0; i<10; i=i+1) {
	if (i==5) break;
   }
   printd(i);
   return (i+3);
}
