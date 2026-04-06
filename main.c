#include <stdio.h>
#include <stdarg.h>

extern void my_print(const char*, ...);

int main()
{
    printf("\n>>> main(): start\n\n");

    char *my_str = "dfsdfbbbbasjdbkaj";

    my_print("Hello world!a jhfvlbvhdkjcnasjsjdhsjdbshbdfhjsbdfhbsdfhjkbsdmfbsdjkhfbksdbfjhksdbf,sdbfbsdfjbsdlhjvaosiulbvddbhddsklfnsdnf.aksdnflasdf,ajksdbfljhsakbdf.,jsdbflkjsabdfjasdbfalidfb,jassdfsndflknsdfjnafdnkajnfkadlnjas.fakdsfjsndlfkakfjnbksdfbnakdjbfkladbfsadfsndf.avsdjvfsjdfvjkavfjhsdvfjhasvdfjhvasdjhfvsajdhfvjhasdvfjhsvadfjhvasdjfvasjkfvkajdfvkjasdvfkasjdhfvksajdfksfdndfvosdagfw\n");

    printf("\n<<< main(): end\n\n");
    return 0;
}
