/*
 ============================================================================
 Name        : DhcpStringCalc.c
 Author      : ryadav
 Version     :
 Copyright   : Your copyright notice
 Description : Hello World in C, Ansi-style
 ============================================================================
 */
struct i6rd_Struct
{
	unsigned int cOption_6RD;
	unsigned char cOptionLen;
	unsigned char cIpv4MaskLen;
	unsigned char c6rdPrfxLen;
	unsigned char iArr_6rdPrfx[17];

	unsigned char i6rdBrIpv4Addr[5];
};

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	if(argc<3)
	{
		printf("Insufficient Arguments,\nUsage: ./DhcpStringCalc \"2001::21 10.2.3.2 24\" \"1 or 2 or 3\" \n");
		exit(-1);
	}
    char *pch1;
	char s[120];
	memcpy(s,argv[1], strlen(argv[1]));
    char *str1=s;
    pch1=strtok (str1," ");
    char outStr[10][50], i=0;
    while (pch1 != NULL)
    {

    	strcpy(outStr[i++], pch1);
        pch1 = strtok (NULL, " ");
	}

    if(!strcmp(argv[2],"1"))
    	printf("%s\n", outStr[0]);
    else if(!strcmp(argv[2],"2"))
    	printf("%s\n", outStr[1]);
    else if(!strcmp(argv[2],"3"))
    	printf("%s\n", outStr[2]);
    else
    	printf("I am expecting three parameters in a string separated with a space\n");
    i=0;
}

