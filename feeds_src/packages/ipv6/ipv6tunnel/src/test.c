#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <stdlib.h>


#define ERROR_LOG
//#define DEBUG
// 2001:fed0:2f11:0102
static char ip6Prefx[30] = "2001:23::/32";
static char ip4Addr[30] = "10.11.1.2";
static char ip4Mask[30] = "255.255.255.255";
static char i6RdPrefx[30];
static int ip6MaskLen=0;
static int i6rdMaskLen=0;
static int ip4MaskLen=0;

static struct sockaddr_in6 servaddr6;
static struct sockaddr_in servaddr;
static void getNumBitsInIp6Prefx()
{
}
static void buildIpv4Part(char* ip4Addr, char *ip4Mask, char* tmpStr);

// if /n is less than thenumber of bytes in prefx, invalid, show error


static void addZeros(char *tmpStr)
{

	printf("ipv6 addr part=%s ip6 mask= %d\n",tmpStr, ip6MaskLen);
	int QuadesInMask= ip6MaskLen/4;
	int iLen=strlen(tmpStr);
    if(iLen > 8)
	{
    	iLen = iLen-2;
	}
	else if(iLen > 4)
	{
		iLen--;
	}
	else
		;

    if(QuadesInMask > iLen)
    {
    	printf("append zeros\n");
        strcpy(ip6Prefx, tmpStr);
    }

    int iAddColon=0;
    strcat(tmpStr,":");

    //while(iZerosToBeAdded--)
    {
        iAddColon++;
        if(iAddColon>4)
        {
            strcat(tmpStr,":");
            iAddColon=0;
        }
        strcat(tmpStr,"0");
    }
}
static void sanityCheck(char* prefxFrmSP)
{
	   int iLen=strlen(prefxFrmSP);
	   if(iLen > 8)
	   {
		   iLen = iLen-2;
	   }
	   else if(iLen > 4)
       {
	        iLen--;
	   }
	   else
	       ;
	   int QuadesInMask= ip6MaskLen/4;
       if(QuadesInMask > iLen)
       {
	        //printf("append zeros\n");
    	   return;
	   }
	   else if(QuadesInMask < iLen)
	   {
		   #ifdef ERROR_LOG
	       printf("bad ipv6 prefix. exiting...\n");
	       #endif
	       exit(-1);
	   }
	   else
	   {
	       #ifdef DEBUG
	        //printf("Just perfect Ipv6 prefx\n");
	       #endif
	       return;
	   }
}

static void appendIpv4(char* ip4Addr, char *ip4Mask, char* tmpStr)
{

	static struct sockaddr_in sockaddrtemp;

//	inet_pton(AF_INET6, ip6Prefx, &servaddr6.sin6_addr );
	inet_pton(AF_INET6, ip4Addr, &sockaddrtemp.sin_addr);



//	int ip4AddrInt = htonl(ip4Addr);
//	ip4AddrInt  = ip4AddrInt  << (*ip4Mask);

}

static void buildIpv6PrefixPart()
{
    //void *addrPtr;
    char *prefxFrmSP,*tmpMask, tmp[150];
    const char delimiter[]= "/";
    strcpy(tmp,ip6Prefx);
    prefxFrmSP=strtok(tmp,delimiter);
    tmpMask=strtok(NULL,delimiter);
    char tmpStr[20];
    memcpy(tmpStr, prefxFrmSP, strlen(prefxFrmSP)-2);
    tmpStr[strlen(prefxFrmSP)-2]='\0';

    strcpy(prefxFrmSP,tmpStr);
    #ifdef DEBUG
//    printf("ip6Mask str= %s\n",tmpMask);
    #endif

    ip6MaskLen = atoi(tmpMask);
    // This checks the sanity of the prefix received.
    sanityCheck(prefxFrmSP);
#ifdef DEBUG
    printf("interim Final SP Prefix= %s\n", prefxFrmSP);
#endif
    int cnt=0;
    int isZeroToBeAppened=2;
    while(prefxFrmSP[cnt++] !='\0')
    {
    	if(prefxFrmSP[cnt]==':')
    	{
    		isZeroToBeAppened= isZeroToBeAppened+2;
    	}
    }
    if(isZeroToBeAppened<ip6MaskLen/8)
    {
    	int i=ip6MaskLen/8;
#ifdef DEBUG
		printf("append1 zeros\n");
#endif
		if(i%2)
		{
			strcat(prefxFrmSP,":");
			strcat(prefxFrmSP,"00");
		}
		else
		{
			strcat(prefxFrmSP,":");
			strcat(prefxFrmSP,"0000");
		}
    }
    else
    {
#ifdef DEBUG
    	printf("do nothing\n");
#endif
    }
#ifdef DEBUG
    printf("Final SP Prefix= %s\n", prefxFrmSP);
#endif
#if 1
    buildIpv4Part(ip4Addr, ip4Mask, prefxFrmSP);
#else
    appendIpv4(ip4Addr, ip4Mask, prefxFrmSP);
#endif
    inet_pton(AF_INET6, ip6Prefx, &servaddr6.sin6_addr );
    //printf("%d\n", &servaddr6.sin6_addr);
    return;
}
static char* stringreverse(char* str, int length)
{
	// we need temp pointers to the beginning and
	// end of the sequence we wish to reverse
//	printf(":2.3.1:\n");
	if(str==NULL)
		return NULL;
	char *start = str, *end = str + length - 1;
	while(start < end)
	{
		// swap characters, and move pointers towards
		// the middle of the sequence
		char temp = *start;
		*start++ = *end;
		*end-- = temp;
	}
//	printf(":2.3.2:\n");
	// return the reversed string
	return str;
}
static void buildIpv4Part(char* ip4Addr, char *ip4Mask, char* tmpStr)
{
    unsigned long tmpIp4;
    char tmpIpv4Str[16];
#ifdef DEBUG
    printf("ipv4 addr part calculation...%s\n", tmpStr);
#endif
    //ip4Addr="10.10.4.0";
    //ip4Mask="255.255.0.0";
    //char tmpStr[20] = "2003:f09:67:54";
    struct sockaddr_in ip4AddrTmp, ip4MaskTmp;
    inet_pton(AF_INET, ip4Addr, &ip4AddrTmp.sin_addr );
    inet_pton(AF_INET, ip4Mask, &ip4MaskTmp.sin_addr );
    tmpIp4 = (ip4AddrTmp.sin_addr.s_addr & ~ip4MaskTmp.sin_addr.s_addr);
    inet_ntop(AF_INET, &tmpIp4, tmpIpv4Str, sizeof(tmpIpv4Str));
    int i=0;
    while(*tmpIpv4Str!='\0')
    {
        if( (tmpIpv4Str[i] == '.')
            ||
            (tmpIpv4Str[i] == '0')
          )
        {
            i++;
        }
        else
            break;
    }
#ifdef DEBUG
   printf("modified addr part:%s\n", &tmpIpv4Str[i]);
#endif
// this portion is for tokeniing the chopped ip4 addr part
   char *str =&tmpIpv4Str[i];
   char * pch;
// this is to find out the length of the ipv4 addr part.
static int len=0;
{
    char *pch1;
    char a[10];
    char s[20];
    memcpy(s,str, strlen(str));
    s[strlen(str)]='\0';
    char *str1=s;
    pch1 = strtok (str1,".");
    while (pch1 != NULL)
    {
        pch1 = strtok (NULL, ".");
        len++;
    }
}
   /***********prepare ip6 prefix part for appending***************/
   char t[20], *left, *right;
   char tmp[30];
   strcpy(tmp,tmpStr);
   char *rev= stringreverse((char*)tmp, strlen(tmp));

   left = strtok(rev, ":");
   right=strtok(NULL, "");
   //printf("left= %s\n", left);
   //printf("right= %s\n", right);
   if(right!=NULL)
   {
	   char* t1=stringreverse((char*) right, strlen(right));
	   strcpy(right,t1);
   }

   //printf("right= %s\n", right);
   int startWithColon=0;
   if(left!=NULL)
   {
	   if(strlen(left)<=2)
	   {
#ifdef DEBUG
		   printf("append ':' later\n");
#endif
		   //printf("rev= %s", rev);
		   char *tmp1=stringreverse((char*)rev, strlen(rev));
		   if(!tmp1)
			   return;
//		   printf("x.0\n");
		   strcat(right, ":");
		   strcat(right, tmp1);
		   //   printf("prefx part tokenize= %s\n", tmp1);
		   //	   printf("prefx part tokenize1= %s\n", right);
//		   printf("x.1\n");
		   strcpy(tmpStr, right);
		   // add ip4 here only
	   }
	   else
	   {
		   startWithColon++;
#ifdef DEBUG
		   printf("append ':' here\n");
#endif
		   char *tmp1=stringreverse((char*)rev, strlen(rev));
		   if(tmp1==NULL)
			   return;
//		   printf("tmp1=%s\n",tmp1);
		   if(right!=NULL)
		   {
//			   printf("x.2.1\n");
			   strcat(right, ":");
			   strcat(right, tmp1);
		   }
#if 0
		   else if(left!=NULL)
		   {
			   printf("x.2.2\n");
			   strcat(left, ":");
			   printf("x.2.2.1\n");
			   strcat(left, tmp1);
			   printf("x.2.2.2\n");
		   }
#endif
		   char a[100]; // temp vaiable used as 'right can not be appended'
		   if(right!=NULL)
			   strcpy(a,right);
		   else
			   strcpy(a,left);
		   strcat(a, ":");
//		   printf("prefx part tokenize= %s\n", a);
		   strcpy(tmpStr, a);
	   }
   }

   // end
   static int cnt= 0;

#if 0
#else
   static int numOfByteIp4Addr=0;
   //int ip6PartLen = strlen(tmpStr);
#ifdef DEBUG
   printf("tmpStr = %s\n", tmpStr);
#endif
   pch = strtok (str,".");
   static int onlyOnce=1;
   while (pch != NULL)
   {
	   int k=atoi(pch);
	   //TODO: represent the number in hex.

	   if(cnt>1)
	   {
		  // printf(":2:");
		   strcat(tmpStr, ":");
		   cnt=0;
	   }
	   cnt++;

	   char hexNum[20];
	   sprintf(hexNum,"%.2x",k);
	   strcat(tmpStr, hexNum);
	   // Make sure, you have to add in the : ended ip6 prefix or char ended string.
	   if(!startWithColon)
	   {
		   if(onlyOnce)
		   {
		//	   printf(":1:\n");
			   strcat(tmpStr, ":");
			   cnt=0;
			   startWithColon++;
			   onlyOnce=0;
		   }
	   }
	   pch = strtok(NULL, ".");
	  //printf("interimfinal 6RD Prefix= %s\n",tmpStr);
  }
#endif
    if(tmpStr[strlen(tmpStr)-1] == ':')
    	tmpStr[strlen(tmpStr)-1]='\0';
    strcpy(i6RdPrefx,tmpStr);
//    printf("interimfinal 6RD Prefix= %s\n",tmpStr);
    //OutPut: now I have chopped addr part of IPv4 in tmpIpv4 string.
}

void checkInputSanity(char *ip6Prefx)
{

}
// Ipv6 prefix - 2002::43::/32 or /64 by default
// IPv4 entire address, chop network part using mask, and append the addr into ipv6 prefix.
// make sure you get a 64 bit ipv6 prefix, if not then append 0s.

int main (int argc, char *argv[])
{
    #if 1
    if(argc < 4)
	{
		printf("insufficient arguments\n");
		printf("usage: ./prefix 2001:1::/32 10.2.3.4 255.255.255.0\n");
		return -1;
	}
	else
	#else
	#endif
	{
	    #if 0
	    //static char *ip6Prefx = "2001:23::/32";
        //static char *ip4Addr = "10.31.1.2";
        //static char *ip4Mask = "255.0.0.0";
        #else
        checkInputSanity(argv[1]);
        strcpy(ip6Prefx,argv[1]);
        strcpy(ip4Addr,argv[2]);
        ip4MaskLen=atoi(argv[3]);
#if 1
        switch (ip4MaskLen)
        {
            case 16:
                strcpy(ip4Mask,"255.255.0.0");
                break;
            case 8:
                strcpy(ip4Mask,"255.0.0.0");
                break;
            case 24:
                strcpy(ip4Mask,"255.255.255.0");
                break;
            case 32:
                printf("invalid ip4 prefix\n");
                break;
            default:
                printf("no valid ip4 prefix\n");
                break;
        }
        //printf("ip4 mask received: %d\n", ip4MaskLen);
        #else
        strcpy(ip4Mask,argv[3]);
        #endif
        #endif
		//this is to count bits & prepare v6 prefix part in Ipv6 prefix assigned by Service provider.
		buildIpv6PrefixPart();
		i6rdMaskLen = ip4MaskLen+ip6MaskLen;
		if(i6rdMaskLen>64)
        {
            printf("Total prefix length exceeds 6RD limit (64). exiting...\n");
            exit(-1);
	    }
	    else if (i6rdMaskLen==64)
	    {
	        //give as it is.
	            strcat(i6RdPrefx, "::/");
                //printf("final 6RD Prefix= %s\n",tmpStr);
                char s[4];
                sprintf(s,"%d", ip4MaskLen+ip6MaskLen);
                strcat(i6RdPrefx, s);
#ifdef DEBUG
                printf("final 6RD Prefix= %s\n",i6RdPrefx);
#else
//                printf("%s\n",i6RdPrefx);
#endif
        }
        else
        {
#if 1
        	int i=strlen(i6RdPrefx)-1;
//        	while(i6RdPrefx[i++]!='\0')
        	{
//				i++;
        	}
        	int k=0;
        	while(i6RdPrefx[i--]!=':')
        	{
//        		printf("k= %d\n",k);
        		k++;
        	}
        	if(k<3)
        	{
//        		printf("k<2= %d\n",k);
        		strcat(i6RdPrefx,"00");
        	}
        	else
        	{
        		//        		printf("k>= %d\n",k);
        		;
        	}

#else

            //append zeros to make it 64 bit
            int iZerosToBeAdded = (64-i6rdMaskLen)/4;
            int iAddColon=0;
            //strcat(i6RdPrefx,":");
            while(iZerosToBeAdded--)
            {
                iAddColon++;
                if(iAddColon>4)
                {
                    strcat(i6RdPrefx,":");
                    iAddColon=0;
                }
                strcat(i6RdPrefx,"0");
            }
#endif
            strcat(i6RdPrefx, "::/");
            //printf("final 6RD Prefix= %s\n",tmpStr);
            char s[4];
            sprintf(s,"%d", (32-ip4MaskLen)+ip6MaskLen);
            strcat(i6RdPrefx, s);

//            printf("final 6RD Prefix= %s\n",i6RdPrefx);
//            struct sockaddr_in6 ip6AddrTmp;
//            inet_pton(AF_INET6, i6RdPrefx, &ip6AddrTmp.sin6_addr );
            //inet_ntop();
//            inet_ntop(AF_INET, &ip6AddrTmp, i6RdPrefx, sizeof(i6RdPrefx));
//            printf("final 6RD Prefix1= %s\n",i6RdPrefx);
        }
#ifdef DEBUG
		printf("final 6RD Prefix= %s\n",i6RdPrefx);
#else

#endif
		struct sockaddr_in6 ip6AddrTmp;
		inet_pton(AF_INET6, i6RdPrefx, &ip6AddrTmp.sin6_addr );
		            //inet_ntop();
		inet_ntop(AF_INET6, &ip6AddrTmp, i6RdPrefx, sizeof(i6RdPrefx));
#ifdef DEBUG
         printf("final 6RD Prefix1= %s\n",i6RdPrefx);
#else
         printf("%s\n",i6RdPrefx);
#endif
	}
  return 0;
}
