#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <limits.h>

//#define MACHINE_LITTLE_ENDIAN
#define ERROR_LOG
//#define DEBUG

static char ip6Prefx[INET6_ADDRSTRLEN] = "2001:23::/32";
static char ip4Addr[30] = "10.11.1.2";
static char ip4Mask[30] = "255.255.255.255";
static char i6RdPrefx[INET6_ADDRSTRLEN];
static int ip6MaskLen=0;
static int i6rdMaskLen=0;
static int ip4MaskLen=0;

// This is to show the bit pattern of an array (any object)
void show(const void *object, size_t size)
{
   const unsigned char *byte;
   for ( byte = object; size--; ++byte )
   {
      unsigned char mask;
      for ( mask = 1 << (CHAR_BIT - 1); mask; mask >>= 1 )
      {
         putchar(mask & *byte ? '1' : '0');
      }
      putchar(' ');
   }
   putchar('\n');
}
void shiftl(void *object, size_t size)
{
	   unsigned char *byte;
	   for ( byte = object; size--; ++byte )
	   {
	      unsigned char bit = 0;
	      if ( size )
	      {
	         bit = byte[1] & (1 << (CHAR_BIT - 1)) ? 1 : 0;
	      }
	      *byte <<= 1;
	      *byte  |= bit;
	   }
}
// This program returns the endian ness of a machine
int isMachineLittleEndian()
{
	union{

		int i;
		char c;
	}u;
	u.i = 1;
	if(u.c)
		return 1;	// little endian
	else
		return 0;
}

static void appendIpv4(char* ip4Addr, char *ip4Mask, char* ip6PrefxPart)
{
	static struct sockaddr_in sockaddrtemp;
	inet_pton(AF_INET, ip4Addr, &sockaddrtemp.sin_addr);
	// prepare ipv4 part
	// this is done because i want to shift the byte at memory locations.
	// and this is a little endian machine.
	// make decision based on the endianness of the machine.
	if(isMachineLittleEndian())
		sockaddrtemp.sin_addr.s_addr = sockaddrtemp.sin_addr.s_addr >> ip4MaskLen;
	else
		sockaddrtemp.sin_addr.s_addr = sockaddrtemp.sin_addr.s_addr << ip4MaskLen;

	char tempBuf[16];
	memset(tempBuf,0,16);
	memcpy(&tempBuf[12], &sockaddrtemp.sin_addr.s_addr, 4);
	// Calculate the number of bytes to be left shifted in the temp buff
	int i= 128 -32 - ip6MaskLen;

#ifdef DEBUG
	show(tempBuf, sizeof tempBuf);
#endif
	while(i--)
		shiftl(tempBuf, sizeof tempBuf);
#ifdef DEBUG
	show(tempBuf, sizeof tempBuf);
#endif
	;
	char aNetworkOrder[INET6_ADDRSTRLEN], bStrOrder[INET6_ADDRSTRLEN];
	inet_pton(AF_INET6, ip6PrefxPart, aNetworkOrder);
	inet_ntop(AF_INET6, aNetworkOrder, bStrOrder, INET6_ADDRSTRLEN);
#if 1
#ifdef DEBUG
	printf("ip6 prefix masked1=");
#endif
	unsigned char tmp[16];
	memset(tmp, 0xff, 16);
	int m=128 - ip6MaskLen;
#ifdef DEBUG
	show(tmp, sizeof tmp);
	show(aNetworkOrder, sizeof tmp);
#endif
	while(m--)
			shiftl(tmp, sizeof tempBuf);

	int l=0;
	while(l < 16)
	{
		aNetworkOrder[l] =
			aNetworkOrder[l] & tmp[l] ;
		l++;
	}
#ifdef DEBUG
	show(tmp, 16);
	show(aNetworkOrder, 16);
#endif
#endif

#ifdef DEBUG
	printf("final prefix1= %s\n", bStrOrder);
#endif
	int j=0;
#ifdef DEBUG
	show(aNetworkOrder,16);
#endif
	while(j < 16)
	{
		aNetworkOrder[j] =
			aNetworkOrder[j] | tempBuf[j] ;
		j++;
	}
	inet_ntop(AF_INET6, aNetworkOrder, bStrOrder, INET6_ADDRSTRLEN);
	strcpy(i6RdPrefx, bStrOrder);
#ifdef DEBUG
	printf("final = %s\n", bStrOrder);
#endif
}

static int
isrfc1918addr(char* ip4Addr)

{

	static struct sockaddr_in sockaddrtemp;
	inet_pton(AF_INET, ip4Addr, &sockaddrtemp.sin_addr);

    /*
     * returns 1 if private address range:
     * 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16
     */
    if ((ntohl(sockaddrtemp.sin_addr.s_addr) & 0xff000000) >> 24 == 10 ||
        (ntohl(sockaddrtemp.sin_addr.s_addr) & 0xfff00000) >> 16 == 172 * 256 + 16 ||
        (ntohl(sockaddrtemp.sin_addr.s_addr) & 0xffff0000) >> 16 == 192 * 256 + 168)
        return 1;

    return 0;
}
static void buildIpv6PrefixPart()
{
    char *prefxFrmSP,*tmpMask, tmp[150];
    const char delimiter[]= "/";
    strcpy(tmp,ip6Prefx);
    prefxFrmSP=strtok(tmp,delimiter);
    tmpMask=strtok(NULL,delimiter);
//    printf("interim Final SP Prefix= %s\n", prefxFrmSP);
    char tmpStr[20];
    ip6MaskLen = atoi(tmpMask);
//    printf("ip6 mask len= %d\n", ip6MaskLen);
    memcpy(tmpStr, prefxFrmSP, strlen(prefxFrmSP)-2);
    tmpStr[strlen(prefxFrmSP)-2]='\0';
    appendIpv4(ip4Addr, ip4Mask, prefxFrmSP);
    return;
}

// Ipv6 prefix - 2002::43::/32 or /64 by default
// IPv4 entire address, chop network part using mask, and append the addr into ipv6 prefix.
// make sure you get a 64 bit ipv6 prefix, if not then append 0s.
int main (int argc, char *argv[])
{
	int maskLenOption=0;
    if(argc < 4)
	{
		printf("insufficient arguments\n");
		printf("usage: ./prefix 2001:1::/32 202.4.3.2 16\n");
		return -1;
	}
	else
	{
	        strcpy(ip6Prefx,argv[1]);
	        strcpy(ip4Addr,argv[2]);
	        if (isrfc1918addr(ip4Addr)==1)
	        {
	        	printf("RFC 1918 Address found 6Rd cannot work behind NAT, exiting");
	        	exit (0);
	        }
#ifdef DEBUG
	        else
	        {
	        	printf("RFC 1918 Address not found,so I will continue");
	        }
#endif
	        ip4MaskLen=atoi(argv[3]);
	        if(argc == 5)
	        {
	        	maskLenOption = atoi(argv[4]);
	        }
		//this is to count bits & prepare v6 prefix part in Ipv6 prefix assigned by Service provider.
		buildIpv6PrefixPart();
		i6rdMaskLen = (32-ip4MaskLen)+ip6MaskLen;
		//Printf("Total prefix length = %d\n", i6rdMaskLen);
		if(i6rdMaskLen>64)
	        {
        	    printf("Total prefix length exceeds 6RD limit (64). exiting...\n");
        	    exit(-1);
		}
#if 0
	    else if (i6rdMaskLen==64)
	    {
	        //give as it is.
	    	strcat(i6RdPrefx, "::/");
            //printf("final 6RD Prefix= %s\n",tmpStr);
            char s[4];
            sprintf(s,"%d", ip4MaskLen+ip6MaskLen);
            strcat(i6RdPrefx, s);
        }
#endif
        else
        {
            strcat(i6RdPrefx, "/");
            char s[4];
            if(maskLenOption)
            {
            	sprintf(s,"%d", (32-ip4MaskLen)+ip6MaskLen);
            }
            else
            {
                sprintf(s,"%d", 64);
            }
            strcat(i6RdPrefx, s);
            printf("%s\n",i6RdPrefx);
        }

		struct sockaddr_in6 ip6AddrTmp;
		inet_pton(AF_INET6, i6RdPrefx, &ip6AddrTmp.sin6_addr );
		inet_ntop(AF_INET6, &ip6AddrTmp, i6RdPrefx, sizeof(i6RdPrefx));
	}
  return 0;
}
