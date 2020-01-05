ENABLE_CMD_PROBE=1
ENABLE_DATA_PRINT=0
HIDAPI_IMPL=hidapi-libusb

CC=c99
CFLAGS=-Werror=all -Wextra -Wpedantic -Os
CPPFLAGS=-DENABLE_CMD_PROBE=$(ENABLE_CMD_PROBE) -DENABLE_DATA_PRINT=$(ENABLE_DATA_PRINT) $$(pkgconf --cflags $(HIDAPI_IMPL))
LDFLAGS=-s
LIBS=$$(pkgconf --libs $(HIDAPI_IMPL))

apexctl: apexctl.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $? $(LIBS) -o $@

clean:
	rm apexctl
