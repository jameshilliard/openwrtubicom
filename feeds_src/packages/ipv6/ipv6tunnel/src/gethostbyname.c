/* 
 * File:   main.cpp
 * Author: mohiuddinkhan
 *
 * Created on May 17, 2010, 5:23 PM
 */
#include <stdio.h>
#include <netdb.h>
#include <netinet/in.h>
#include <strings.h>
#include <arpa/inet.h>

struct hostent *he;
struct in_addr a;


int main (int argc, char **argv)
{
   static int count=0;
   
    if (argc != 2)
    {
        fprintf(stderr, "usage: %s hostname\n", argv[0]);
        return 1;
    }
    he = gethostbyname (argv[1]);
    if (he)
    {
        /* printf("name: %s\n", he->h_name); */
        /* this section is for alias addresses, wont be used currently so commented.
         while (*he->h_aliases)
         printf("alias: %s\n", *he->h_aliases++); */
            
            
        while (*he->h_addr_list)
        {
            bcopy(*he->h_addr_list++, (char *) &a, sizeof(a));
           
               printf("%s", inet_ntoa(a));
               return 0; /*exit after taking the first ip address itself, do not wait for another one. */
              
             
        }
    }
    else
        herror(argv[0]);
    return 0;
}

