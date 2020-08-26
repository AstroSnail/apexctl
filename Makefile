ENABLE_CMD_PROBE=1
ENABLE_DATA_PRINT=0
HIDAPI_IMPL=hidapi-libusb
HIDAPI_LONG_INCLUDE=0

CC=c99
CFLAGS=-Werror=all -Wextra -Wpedantic -Os -Isrc
CPPFLAGS=-DENABLE_CMD_PROBE=$(ENABLE_CMD_PROBE) -DENABLE_DATA_PRINT=$(ENABLE_DATA_PRINT) -DHIDAPI_LONG_INCLUDE=$(HIDAPI_LONG_INCLUDE)
CPPLIBS=$$(pkgconf --cflags $(HIDAPI_IMPL))
LDFLAGS=-s
LDLIBS=$$(pkgconf --libs $(HIDAPI_IMPL))

all: apexctl 00-apex.hwdb 00-apexctl.rules 00-apex.conf
all-advanced: apexctl 00-apex-advanced.hwdb 00-apexctl.rules 00-apex.conf

apexctl: src/steelseries.c src/apexctl.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(CPPLIBS) $(LDFLAGS) src/steelseries.c src/apexctl.c $(LDLIBS) -o $@

src/steelseries.c: src/gensteelseries.sh src/steelseries.txt
	src/gensteelseries.sh src/steelseries.txt >$@

00-apex.hwdb: src/genhwdb.sh src/hwdb-body.txt src/steelseries.txt
	src/genhwdb.sh src/steelseries.txt src/hwdb-body.txt >$@

00-apex-advanced.hwdb: src/genhwdb.sh src/hwdb-body-advanced.txt src/steelseries.txt
	src/genhwdb.sh src/steelseries.txt src/hwdb-body-advanced.txt >$@

00-apexctl.rules: src/genrules.sh src/steelseries.txt
	src/genrules.sh src/steelseries.txt >$@

00-apex.conf: src/genxorgconf.sh src/steelseries.txt
	src/genxorgconf.sh src/steelseries.txt >$@

clean:; rm -f apexctl src/steelseries.c 00-apex.hwdb 00-apex-advanced.hwdb 00-apexctl.rules 00-apex.conf

install: all
	misc/install.sh

install-advanced: all-advanced
	env ADVANCED=y misc/install.sh

uninstall:; misc/install.sh -u

.PHONY: all all-advanced clean install install-advanced uninstall
