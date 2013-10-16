ifndef CFLAGS
CFLAGS = -O2 -g -I ../src
endif
LIBS=-lnl

all: _i6rdcalc i6rdcalc gethostbyname dhcpcalc

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

i6rdcalc: i6rdPrefixCalc.o 
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

dhcpcalc: dhcpcalc.o 
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

_i6rdcalc: test.o 
	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

gethostbyname:  gethostbyname.o
		$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

clean: 
	rm gethostbyname 
	rm _i6rdcalc
	rm dhcpcalc
	rm i6rdcalc
	rm  *.o

