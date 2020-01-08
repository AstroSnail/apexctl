ENABLE_CMD_PROBE=1
ENABLE_DATA_PRINT=0
HIDAPI_IMPL=hidapi-libusb

CC=c99
CFLAGS=-Werror=all -Wextra -Wpedantic -Os
CPPFLAGS=-DENABLE_CMD_PROBE=$(ENABLE_CMD_PROBE) -DENABLE_DATA_PRINT=$(ENABLE_DATA_PRINT)
CPPLIBS=$$(pkgconf --cflags $(HIDAPI_IMPL))
LDFLAGS=-s
LIBS=$$(pkgconf --libs $(HIDAPI_IMPL))
TARGET=apexctl

$(TARGET): src/apexctl.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(CPPLIBS) $(LDFLAGS) $? $(LIBS) -o $@

clean:
	rm $(TARGET)

install:
	misc/install.sh

uninstall:
	misc/install.sh -u
