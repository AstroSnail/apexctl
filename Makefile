ENABLE_CMD_PROBE=1            # Enable the probe command, for testing
ENABLE_DATA_PRINT=0           # Enable a printout of data sent to the keyboard, for debugging
ENABLE_EXPERIMENTAL_SUPPORT=0 # Enable the M800 and Apex 3
HIDAPI_IMPL=hidapi-libusb     # hidapi-libusb or hidapi-hidraw
HIDAPI_LONG_INCLUDE=0         # Use the long include path, to fix builds

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
	if [ "$(ENABLE_EXPERIMENTAL_SUPPORT)" != "1" ]; then \
	  src/gensteelseries.sh src/steelseries.txt >$@; \
	else \
	  $(MAKE) src/steelseries-cat.txt; \
	  src/gensteelseries.sh src/steelseries-cat.txt >$@; \
	fi

src/steelseries-cat.txt: src/steelseries.txt src/steelseries-experimental.txt
	cat src/steelseries.txt src/steelseries-experimental.txt >$@

00-apex.hwdb: src/genhwdb.sh src/hwdb-body.txt src/steelseries.txt
	src/genhwdb.sh src/steelseries.txt src/hwdb-body.txt >$@

00-apex-advanced.hwdb: src/genhwdb.sh src/hwdb-body-advanced.txt src/steelseries.txt
	src/genhwdb.sh src/steelseries.txt src/hwdb-body-advanced.txt >$@

00-apexctl.rules: src/genrules.sh src/steelseries.txt
	src/genrules.sh src/steelseries.txt >$@

00-apex.conf: src/genxorgconf.sh src/steelseries.txt
	src/genxorgconf.sh src/steelseries.txt >$@

clean:; rm -f apexctl src/steelseries.c src/steelseries-cat.txt 00-apex.hwdb 00-apex-advanced.hwdb 00-apexctl.rules 00-apex.conf

install: all
	misc/install.sh

install-advanced: all-advanced
	env ADVANCED=y misc/install.sh

uninstall:; misc/install.sh -u

.PHONY: all all-advanced clean install install-advanced uninstall
