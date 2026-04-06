#include <stdio.h>
#include <stdarg.h>

extern void my_print(const char*, ...);

int main()
{
    printf("\n>>> main(): start\n\n");

    char *my_str = "dfsdfbb";

    my_print("Hello world!%b\n", 0b10101010100011);

    printf("\n<<< main(): end\n\n");
    return 0;
}
