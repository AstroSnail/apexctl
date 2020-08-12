ENABLE_CMD_PROBE=1
ENABLE_DATA_PRINT=0
HIDAPI_IMPL=hidapi-libusb
HIDAPI_LONG_INCLUDE=0

CC=c99
CFLAGS=-Werror=all -Wextra -Wpedantic -Os
CPPFLAGS=-DENABLE_CMD_PROBE=$(ENABLE_CMD_PROBE) -DENABLE_DATA_PRINT=$(ENABLE_DATA_PRINT) -DHIDAPI_LONG_INCLUDE=$(HIDAPI_LONG_INCLUDE)
CPPLIBS=$$(pkgconf --cflags $(HIDAPI_IMPL))
LDFLAGS=-s
LIBS=$$(pkgconf --libs $(HIDAPI_IMPL))
TARGET=apexctl

$(TARGET): src/apexctl.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(CPPLIBS) $(LDFLAGS) $? $(LIBS) -o $@

clean:; rm $(TARGET)
install:; misc/install.sh
install-advanced:; env ADVANCED=y misc/install.sh
uninstall:; misc/install.sh -u
.PHONY: clean install install-advanced uninstall
