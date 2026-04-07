#include <stdio.h>
#include <stdarg.h>

extern void my_print(const char*, ...);

int main()
{
    printf("\n>>> main(): start\n\n");

    char *my_str = "dfsdfbb";

    my_print("%o\n %d %s %x %d %c %b %%\n %d %s %x %d %c %b %%\n", -1, -1, "love", 3802, 100, 33, 127, -1, "love", 3802, 100, 33, 127);

    printf("\n<<< main(): end\n\n");
    return 0;
}
