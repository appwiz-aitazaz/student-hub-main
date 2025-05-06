#include<stdio.h>
int main()
{
    int n ,j;
    printf("Enter the number:");
    scanf("%d",&n);
    for(int i=n;i>=0;i--)//col
    {
        for(j=0;j<i+1;j++)//row
        {
            printf("*");
        }
        printf("\n");
    }
    return 0;
}