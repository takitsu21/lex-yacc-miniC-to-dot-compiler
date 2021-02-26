#include <stdio.h>
#include <stdlib.h>
#include <memory.h>


int writeDotFile(const char* src) {
    FILE* fp;
    fp = fopen("test.dot", "a");
    if (fp == NULL) {
        fprintf(stderr, "File cannot be opened\n");
        return 0;
    }
    printf("DOTCONVERSION %s\n", src);
    fprintf(fp, "%s", src);

    return 1;
}

const char* newString(char* str1, char* str2) {
    printf("TRY TO CONCATENATE %s and %s\n", str1, str2);
    char * str3 = (char *) malloc(1 + strlen(str1)+ strlen(str2) );
    strcpy(str3, str1);
    strcat(str3, str2);
    return str3;
}

// int main(void) {
//     char* test = newString("str1", "str2");
//     printf("%s\n", test);
//     return 0;
// }