ENABLE_CMD_PROBE=1
ENABLE_DATA_PRINT=0
HIDAPI_IMPL=hidapi-libusb

CFLAGS=-std=c99 -Werror=all -Wextra -Wpedantic -Os
CPPFLAGS=-DENABLE_CMD_PROBE=$(ENABLE_CMD_PROBE) -DENABLE_DATA_PRINT=$(ENABLE_DATA_PRINT) \
	$$(pkgconf --cflags $(HIDAPI_IMPL))
LDFLAGS=-s $$(pkgconf --libs $(HIDAPI_IMPL))

apexctl:

clean:
	rm apexctl
