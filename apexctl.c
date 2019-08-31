///////////////////////////////////////////////////////////////////////////////
// ApexCtl: Control SteelSeries Apex and Apex RAW keyboards on GNU/Linux!
//
// Rewrite of a utility with the same name:
//   <https://github.com/tuxmark5/ApexCtl>
// With some influence from Apex-Macros:
//   <https://github.com/Gibtnix/Apex-Macros>
//
// Copyright (C) 2019  AstroSnail
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///////////////////////////////////////////////////////////////////////////////

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <hidapi.h>

#define ARRAY_LEN(array) (sizeof (array) / sizeof *(array))

///////////////////////////////////////////////////////////////////////////////

// Enable this to expose the probe command
#ifndef ENABLE_CMD_PROBE
#define ENABLE_CMD_PROBE 0
#endif

// Enable this to also print the data to stdout
#ifndef ENABLE_DATA_PRINT
#define ENABLE_DATA_PRINT 0
#endif

// If you change this, don't forget to fix probe's explain entry
#define REPORT_LEN_MAX 32

///////////////////////////////////////////////////////////////////////////////
// This stuff deals with hidapi

int usb_setup (
	hid_device * * device
) {
	uint16_t vendor = 0x1038;
	uint16_t products [] = {
		0x1200, // Apex RAW
		0x1202, // Apex
		0x1206, // Apex 350
		0x1208  // Apex 300
	};
	size_t i;
	size_t n = ARRAY_LEN(products);
	int ret;

	ret = hid_init();
	if (ret != 0) {
		return ret;
	}

	for (i = 0; i < n; ++i) {
		*device = hid_open(vendor, products[i], 0);
		if (*device != NULL) {
			break;
		}
	}

	if (i == n) {
		return -1;
	}

	return 0;
}

int usb_cleanup (
	hid_device * * device
) {
	hid_close(*device);
	return hid_exit();
}


int cmd_put (
	hid_device * * device,
	uint8_t const data [REPORT_LEN_MAX],
	size_t bytes
) {
	size_t i;

	if (ENABLE_DATA_PRINT == 1) {
		for (i = 0; i < bytes; ++i) {
			printf("%x ", data[i]);
		}
		printf("\n");
	}

	return hid_send_feature_report(*device, data, bytes);
}

///////////////////////////////////////////////////////////////////////////////
// This stuff sets the data up for sending

enum {
	ID_REBOOT = 0x01,
	ID_KEYS   = 0x02,
	ID_POLL   = 0x04,
	ID_BRIGHT = 0x05,
	ID_COLORS = 0x07
};

enum {
	KEYS_OFF = 1,
	KEYS_ON  = 2
};

enum {
	POLL_125  = 0,
	POLL_250  = 1,
	POLL_500  = 2,
	POLL_1000 = 3
};


int util_digit_decompose (
	char const * string,
	char const * allow,
	uint8_t * num
) {
	if (
		strlen(string) != 1 ||
		strspn(string, allow) != 1
	) {
		return EXIT_FAILURE;
	}

	*num = string[0] - '0';

	return EXIT_SUCCESS;
}

int util_digit_zone (
	char const * string,
	uint8_t * zone
) {
	return util_digit_decompose(string, "12345", zone);
}

int util_digit_brightness (
	char const * string,
	uint8_t * brightness
) {
	return util_digit_decompose(string, "12345678", brightness);
}

int util_hex_to_num (
	char const * string,
	uint8_t * num
) {
	int res;

	res = sscanf(string, "%"SCNx8, num);
	if (res != 1) {
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}

int util_1hex_component (
	char const * string,
	uint8_t * component
) {
	char buffer [3] = "";

	buffer[0] = buffer[1] = string[0];

	return util_hex_to_num(buffer, component);
}

int util_2hex_component (
	char const * string,
	uint8_t * component
) {
	char buffer [3] = "";

	buffer[0] = string[0];
	buffer[1] = string[1];

	return util_hex_to_num(buffer, component);
}


int cmd_probe (
	uint8_t data [REPORT_LEN_MAX],
	size_t argc,
	char * * argv
) {
	size_t i;
	int ret;

	for (i = 0; i < argc; ++i) {
		ret = util_hex_to_num(argv[i], &data[i]);
		if (ret != 0) {
			return -1;
		}
	}

	return argc;
}


int cmd_reboot (
	uint8_t data [REPORT_LEN_MAX],
	size_t argc,
	char * * argv
) {
	(void) argc; // Always 0
	(void) argv;

	data[0] = ID_REBOOT;

	return 1;
}


int cmd_keys (
	uint8_t data [REPORT_LEN_MAX],
	size_t argc,
	char * * argv
) {
	(void) argc; // Always 1

	data[0] = ID_KEYS;

	if (strcmp(argv[0], "off") == 0) {
		data[2] = KEYS_OFF;
		return 3;
	}

	if (strcmp(argv[0], "on") == 0) {
		data[2] = KEYS_ON;
		return 3;
	}

	return -1;
}


int cmd_poll (
	uint8_t data [REPORT_LEN_MAX],
	size_t argc,
	char * * argv
) {
	(void) argc; // Always 1

	data[0] = ID_POLL;

	if (strcmp(argv[0], "125") == 0) {
		data[2] = POLL_125;
		return 3;
	}

	if (strcmp(argv[0], "250") == 0) {
		data[2] = POLL_250;
		return 3;
	}

	if (strcmp(argv[0], "500") == 0) {
		data[2] = POLL_500;
		return 3;
	}

	if (strcmp(argv[0], "1000") == 0) {
		data[2] = POLL_1000;
		return 3;
	}

	return -1;
}


int cmd_bright (
	uint8_t data [REPORT_LEN_MAX],
	size_t argc,
	char * * argv
) {
	uint8_t zone, brightness;
	int ret;

	(void) argc; // Always 2

	data[0] = ID_BRIGHT;

	ret  = util_digit_zone(argv[0], &zone);
	ret |= util_digit_brightness(argv[1], &brightness);

	if (ret) {
		return -1;
	}

	data[1] = zone;
	data[2] = brightness;

	return 3;
}


int cmd_colors (
	uint8_t data [REPORT_LEN_MAX],
	size_t argc,
	char * * argv
) {
	uint8_t red, green, blue, brightness;
	size_t i, offset;
	int ret;

	data[0] = ID_COLORS;

	// Order: South, East, North, West, Logo
	for (i = 0; i < argc; ++i) {
		// Default: white, brightest
		red = green = blue = 0xff;
		brightness = 8;

		switch (strlen(argv[i])) {
		case 1:
			if (argv[i][0] == '0') {
				// Special case: do not affect
				continue;
			} else {
				ret = util_digit_brightness(&argv[i][0], &brightness);
				if (ret != 0) {
					return -1;
				}
			}
			break;

		case 4:
			ret = util_digit_brightness(&argv[i][3], &brightness);
			if (ret != 0) {
				return -1;
			}
			// Fallthrough
		case 3:
			ret  = util_1hex_component(&argv[i][0], &red);
			ret |= util_1hex_component(&argv[i][1], &green);
			ret |= util_1hex_component(&argv[i][2], &blue);
			if (ret) {
				return -1;
			}

			break;

		case 7:
			ret = util_digit_brightness(&argv[i][6], &brightness);
			if (ret != 0) {
				return -1;
			}
			// Fallthrough
		case 6:
			ret  = util_2hex_component(&argv[i][0], &red);
			ret |= util_2hex_component(&argv[i][2], &green);
			ret |= util_2hex_component(&argv[i][4], &blue);
			if (ret) {
				return -1;
			}

			break;

		default:
			return -1;
		}

		offset = 4 * i + 2;
		data[offset + 0] = red;
		data[offset + 1] = green;
		data[offset + 2] = blue;
		data[offset + 3] = brightness;
	}

	return 4 * i + 2;
}

///////////////////////////////////////////////////////////////////////////////

struct {
	char const * cmd;
	char const * desc;
	char const * usage;
	char const * explain;
	int (* function) (uint8_t [REPORT_LEN_MAX], size_t, char * *);
	size_t args;
	int varargs; // Non-zero to allow fewer args than specified
} const commands[] = {
#if ENABLE_CMD_PROBE
	{
		"probe", "Probe for new commands.",
		"<numbers>", "(up to 32 2-digit hex numbers)",
		cmd_probe, REPORT_LEN_MAX, 1
	},
#endif
	{
		"reboot", "Reboot the keyboard.",
		"", "(no arguments)",
		cmd_reboot, 0, 0
	},
	{
		"keys", "Enable or disable extra keys.",
		"<on|off>", "",
		cmd_keys, 1, 0
	},
	// Poll commented out cuz it's sketchy
	// Might only work with the Apex RAW, which I don't have
	/*{
		"poll", "Set polling frequency.",
		"<frequency>", "(125, 250, 500, or 1000)",
		cmd_poll, 1, 0
	},*/
	{
		"bright", "Set backlight brightness.",
		"<zone> <brightness>", "(zone 1-5, brightness 1-8)",
		cmd_bright, 2, 0
	},
	{
		"colors", "Set colors and brightnesses per-zone.",
		"<colors>", "(see below)",
		cmd_colors, 5, 1
	}
};

void help (
	char const * argv0
) {
	size_t i;
	size_t n = ARRAY_LEN(commands);

	printf("Usage: %s <command> [arguments...]\n", argv0);
	puts("");

	puts("Commands:");
	for (i = 0; i < n; ++i) {
		printf("  %-6s  %s\n", commands[i].cmd, commands[i].desc);
	}
	puts("");

	puts("Commands usage:");
	for (i = 0; i < n; ++i) {
		printf("  %-6s %-19s  %s\n", commands[i].cmd, commands[i].usage, commands[i].explain);
	}
	puts("");

	puts("Color specification:");
	puts("  Up to 5 colors can be specified.");
	puts("  They set south, east, north, west and logo zones, in that order.");
	puts("  The formats are case-insensitive.");
	puts("");
	puts("  Format   Example  Meaning");
	puts("  RRGGBBA  ABCDEF4  Sets color to triplet #ABCDEF and brightness to 4 (from 1 to 8)");
	puts("  RRGGBB   ABCDEF   Equivalent to ABCDEF8");
	puts("  RGBA     ACE4     Equivalent to AACCEE4");
	puts("  RGB      ACE      Equivalent to AACCEE8");
	puts("  A        4        Equivalent to FFFFFF4");
	puts("  0                 SPECIAL: Does not affect the zone");
}


int main (
	int _argc,
	char * * argv
) {
	hid_device * device;
	uint8_t data [REPORT_LEN_MAX] = {0};
	size_t argc = _argc;
	size_t i;
	size_t n = ARRAY_LEN(commands);
	size_t bytes;
	int ret = 0;

	if (argc < 2) {
		help(argv[0]);
		return 0;
	} else {
		for (i = 0; i < n; ++i) {
			if (strcmp(argv[1], commands[i].cmd) == 0) {
				if (
					( commands[i].varargs && argc - 2 <= commands[i].args) ||
					(!commands[i].varargs && argc - 2 == commands[i].args)
				) {
					ret = commands[i].function(data, argc - 2, &argv[2]);
				} else {
					ret = -1;
				}
				break;
			}
		}
	}

	if (i < n && ret >= 0) {
		bytes = ret;

		ret = usb_setup(&device);
		if (ret == 0) {
			cmd_put(&device, data, bytes);
		} else {
			fputs("Re-run as root!\n", stderr);
		}
		usb_cleanup(&device);
	} else {
		help(argv[0]);
	}

	return ret;
}
