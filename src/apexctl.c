///////////////////////////////////////////////////////////////////////////////
// ApexCtl: Control SteelSeries Apex keyboards on GNU/Linux!
//
// Copyright 2020 AstroSnail
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
///////////////////////////////////////////////////////////////////////////////

#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if HIDAPI_LONG_INCLUDE
#include <hidapi/hidapi.h>
#else
#include <hidapi.h>
#endif

#include "steelseries.h"

#define ARRAY_LEN(array) (sizeof(array) / sizeof *(array))
#define STRINGIFY(e) #e            // Stringifies without expanding
#define ESTRINGIFY(e) STRINGIFY(e) // Expands and then stringifies

enum {
  SUCCESS = false,
  FAILURE = true,
};

///////////////////////////////////////////////////////////////////////////////

// Enable this to expose the probe command
#ifndef ENABLE_CMD_PROBE
#define ENABLE_CMD_PROBE 0
#endif

// Enable this to also print the data to stdout
#ifndef ENABLE_DATA_PRINT
#define ENABLE_DATA_PRINT 0
#endif

#define REPORT_LEN_MAX 32

///////////////////////////////////////////////////////////////////////////////
// This stuff deals with hidapi

int usb_setup(hid_device **device) {
  size_t i;

  int ret = hid_init();
  if (ret != 0) {
    return ret;
  }

  for (i = 0; i < steelseries_n; ++i) {
    *device = hid_open(steelseries_vendor, steelseries_products[i], 0);
    if (*device != NULL) {
      break;
    }
  }

  if (i == steelseries_n) {
    return -1;
  }

  return 0;
}

int usb_cleanup(hid_device **device) {
  hid_close(*device);
  return hid_exit();
}

int usb_put(hid_device **device, uint8_t const data[REPORT_LEN_MAX],
            size_t bytes) {
  if (ENABLE_DATA_PRINT) {
    for (size_t i = 0; i < bytes; ++i) {
      fprintf(stdout, "%02" PRIX8 " ", data[i]);
    }
    fputs("\n", stdout);
  }

  return hid_send_feature_report(*device, data, bytes);
}

///////////////////////////////////////////////////////////////////////////////
// This stuff sets the data up for sending

enum {
  ID_REBOOT = 0x01,
  ID_KEYS = 0x02,
  ID_POLL = 0x04,
  ID_BRIGHT = 0x05,
  ID_SAVE = 0x06,
  ID_COLORS = 0x07,
};

enum {
  KEYS_OFF = 1,
  KEYS_ON = 2,
};

enum {
  POLL_125 = 0,
  POLL_250 = 1,
  POLL_500 = 2,
  POLL_1000 = 3,
};

bool util_zone(char const *string, uint8_t *zone) {
  int ret = sscanf(string, "%1[1-5]", zone);
  if (ret != 1) {
    return FAILURE;
  }

  *zone -= '0';

  return SUCCESS;
}

bool util_brightness(char const *string, uint8_t *brightness) {
  int ret = sscanf(string, "%1[1-8]", brightness);
  if (ret != 1) {
    return FAILURE;
  }

  *brightness -= '0';

  return SUCCESS;
}

bool util_color(char const *string, uint8_t *red, uint8_t *green,
                uint8_t *blue) {
  int ret = sscanf(string, "%2" SCNx8 "%2" SCNx8 "%2" SCNx8, red, green, blue);
  if (ret != 3) {
    return FAILURE;
  }

  return SUCCESS;
}

int cmd_probe(uint8_t data[REPORT_LEN_MAX], size_t argc, char **argv) {
  if (argc > REPORT_LEN_MAX) {
    return -1;
  }

  for (size_t i = 0; i < argc; ++i) {
    int ret;

    if (strlen(argv[i]) > 2) {
      return -1;
    }

    ret = sscanf(argv[i], "%2" SCNx8, &data[i]);
    if (ret != 1) {
      return -1;
    }
  }

  return argc;
}

int cmd_reboot(uint8_t data[REPORT_LEN_MAX], size_t argc, char **argv) {
  if (argc != 0) {
    return -1;
  }

  (void)argv;

  data[0] = ID_REBOOT;

  return 1;
}

int cmd_keys(uint8_t data[REPORT_LEN_MAX], size_t argc, char **argv) {
  if (argc != 1) {
    return -1;
  }

  data[0] = ID_KEYS;

  if (strcmp(argv[0], "off") == 0) {
    data[2] = KEYS_OFF;
  } else if (strcmp(argv[0], "on") == 0) {
    data[2] = KEYS_ON;
  } else {
    return -1;
  }

  return 3;
}

int cmd_poll(uint8_t data[REPORT_LEN_MAX], size_t argc, char **argv) {
  if (argc != 1) {
    return -1;
  }

  data[0] = ID_POLL;

  if (strcmp(argv[0], "125") == 0) {
    data[2] = POLL_125;
  } else if (strcmp(argv[0], "250") == 0) {
    data[2] = POLL_250;
  } else if (strcmp(argv[0], "500") == 0) {
    data[2] = POLL_500;
  } else if (strcmp(argv[0], "1000") == 0) {
    data[2] = POLL_1000;
  } else {
    return -1;
  }

  return 3;
}

int cmd_bright(uint8_t data[REPORT_LEN_MAX], size_t argc, char **argv) {
  if (argc != 2 || strlen(argv[0]) != 1 || strlen(argv[1]) != 1) {
    return -1;
  }

  uint8_t zone, brightness;
  int ret;

  ret = util_zone(argv[0], &zone);
  ret |= util_brightness(argv[1], &brightness);
  if (ret == FAILURE) {
    return -1;
  }

  data[0] = ID_BRIGHT;
  data[1] = zone;
  data[2] = brightness;

  return 3;
}

int cmd_save(uint8_t data[REPORT_LEN_MAX], size_t argc, char **argv) {
  if (argc != 0) {
    return -1;
  }

  (void)argv;

  data[0] = ID_SAVE;

  return 1;
}

int cmd_colors(uint8_t data[REPORT_LEN_MAX], size_t argc, char **argv) {
  if (argc > 5) {
    return -1;
  }

  data[0] = ID_COLORS;

  size_t i;

  // Order: South, East, North, West, Logo
  for (i = 0; i < argc; ++i) {
    // Default: white, brightest
    uint8_t red = 0xFF, green = 0xFF, blue = 0xFF, brightness = 8;
    int ret;
    char temp[7] = "";

    switch (strlen(argv[i])) {
    case 1:
      if (argv[i][0] == '0') {
        // Special case: do not affect
        continue;
      } else {
        ret = util_brightness(argv[i], &brightness);
        if (ret == FAILURE) {
          return -1;
        }
      }
      break;

    case 4:
      ret = util_brightness(&argv[i][3], &brightness);
      if (ret == FAILURE) {
        return -1;
      }
      // Fallthrough
    case 3:
      temp[0] = temp[1] = argv[i][0];
      temp[2] = temp[3] = argv[i][1];
      temp[4] = temp[5] = argv[i][2];
      ret = util_color(temp, &red, &green, &blue);
      if (ret == FAILURE) {
        return -1;
      }
      break;

    case 7:
      ret = util_brightness(&argv[i][6], &brightness);
      if (ret == FAILURE) {
        return -1;
      }
      // Fallthrough
    case 6:
      ret = util_color(argv[i], &red, &green, &blue);
      if (ret == FAILURE) {
        return -1;
      }
      break;

    default:
      return -1;
    }

    size_t offset = 4 * i + 2;
    data[offset + 0] = red;
    data[offset + 1] = green;
    data[offset + 2] = blue;
    data[offset + 3] = brightness;
  }

  return 4 * i + 2;
}

///////////////////////////////////////////////////////////////////////////////

struct {
  char const *command;
  char const *description;
  char const *usage;
  char const *explain;
  int (*function)(uint8_t[REPORT_LEN_MAX], size_t, char **);
} const commands[] = {
#if ENABLE_CMD_PROBE
    {"probe", "Probe for new commands.", "<numbers>",
     "(up to " ESTRINGIFY(REPORT_LEN_MAX) " 2-digit hex numbers)", cmd_probe},
#endif
    {"reboot", "Reboot the keyboard.", "", "(no arguments)", cmd_reboot},
    {"keys", "Enable or disable extra keys.", "<on|off>", "", cmd_keys},
    {"poll", "Set polling frequency.", "<frequency>",
     "(125, 250, 500, or 1000)", cmd_poll},
    {"bright", "Set backlight brightness.", "<zone> <brightness>",
     "(see below)", cmd_bright},
    {"save", "[NEW&BUGGY] Save state changed since keyboard power-on.", "",
     "(no arguments)", cmd_save},
    {"colors", "Set colors and brightnesses per-zone.", "<colors>",
     "(see below)", cmd_colors},
};

void help(char const *argv0) {
  size_t n = ARRAY_LEN(commands);

  fprintf(stderr, "Usage: %s <command> [arguments...]\n\n", argv0);

  fputs("Commands:\n", stderr);
  for (size_t i = 0; i < n; ++i) {
    fprintf(stderr, "  %-6s  %s\n", commands[i].command,
            commands[i].description);
  }
  fputs("\n", stderr);

  fputs("Commands usage:\n", stderr);
  for (size_t i = 0; i < n; ++i) {
    fprintf(stderr, "  %-6s %-19s  %s\n", commands[i].command,
            commands[i].usage, commands[i].explain);
  }

  fputs(
      "\n"
      "Brightness specification:\n"
      "  The meaning of <zone> will depend on which keyboard you're using.\n"
      "  For the Apex, zones 1 to 5 set south, east, north, west and logo "
      "zones.\n"
      "  For the Apex RAW, zone 1 is the whole keyboard.\n"
      "\n"
      "  <brightness> is a number from 1 to 8.\n"
      "  1 will turn off the keyboard backlight for the specified zone.\n"
      "  2 is minimum brightness, 8 is maximum.\n"
      "\n"
      "Color specification:\n"
      "  Up to 5 colors can be specified.\n"
      "  For the Apex, they set south, east, north, west and logo zones in "
      "that order.\n"
      "  This command is not functional in the Apex RAW.\n"
      "  The formats are case-insensitive.\n"
      "\n"
      "  Format   Example  Meaning\n"
      "  RRGGBBA  ABCDEF4  Sets color to triplet #ABCDEF and brightness to 4\n"
      "  RRGGBB   ABCDEF   Equivalent to ABCDEF8\n"
      "  RGBA     ACE4     Equivalent to AACCEE4\n"
      "  RGB      ACE      Equivalent to AACCEE8\n"
      "  A        4        Equivalent to FFFFFF4\n"
      "  0                 SPECIAL: Does not affect the zone\n"
      "\n"
      "For the Apex, this command may be used to turn off the backlight in all "
      "zones:\n"
      "  # apexctl colors 1 1 1 1 1\n"
      "For the Apex RAW, you will instead need to use the bright command:\n"
      "  # apexctl bright 1 1\n"
      "After running it, you may use the save command immediately to keep it "
      "off the\n"
      "next time the keyboard is powered on.\n",
      stderr);
}

int main(int _argc, char **argv) {
  size_t argc = _argc;

  if (argc < 2) {
    help(argv[0]);
    return 0;
  }

  uint8_t data[REPORT_LEN_MAX] = {0};
  size_t i, n = ARRAY_LEN(commands);
  int ret = 0;

  for (i = 0; i < n; ++i) {
    if (strcmp(argv[1], commands[i].command) == 0) {
      ret = commands[i].function(data, argc - 2, &argv[2]);
      break;
    }
  }

  if (i < n && ret > 0) {
    size_t bytes = ret;

    hid_device *device;
    ret = usb_setup(&device);

    if (ret == 0) {
      usb_put(&device, data, bytes);
    } else {
      fputs("Failed to find a supported keyboard.\n", stderr);
      fputs("Supported models are:\n", stderr);
      for (size_t i = 0; i < steelseries_n; ++i) {
        fprintf(stderr, "  %s\n", steelseries_names[i]);
      }
      fputs("If you're using one of these, try re-running as root.\n", stderr);
    }

    usb_cleanup(&device);
  } else {
    help(argv[0]);
  }

  return ret ? EXIT_FAILURE : EXIT_SUCCESS;
}
