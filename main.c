#include <stdio.h>
#include <stdarg.h>

extern void my_print(const char*, ...);

int main() {
    printf("\n>>> main(): start\n\n");

    char *my_str = "dfsdf";

    my_print("Hello %s %d %d %d %d %d %d world!\n", my_str, 14, 15, 16, 17, 18, 19);

    printf("\n<<< main(): end\n\n");
    return 0;
}
