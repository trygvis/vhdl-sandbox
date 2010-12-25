#include <stdio.h>
#include <getopt.h>
#include <ftdi.h>
#include <time.h>
#include <unistd.h>

char output;

#define bit_0 (1 << 0)
#define bit_1 (1 << 1)
#define bit_2 (1 << 2)
#define bit_3 (1 << 3)
#define bit_4 (1 << 4)
#define bit_5 (1 << 5)
#define bit_6 (1 << 6)
#define bit_7 (1 << 7)

const int bit_rw = bit_5;
const int bit_e = bit_6;
const int bit_rs = bit_7;

struct ftdi_context ftdi;

/*
              RS RW   7 6 5 4  3 2 1 0
Clear display: 0  0   0 0 0 0  0 0 0 1
Return home    0  0   0 0 0 0  0 0 1 0
Entry mode set 0  0   0 0 0 0  0 1 I/D S
Display        0  0   0 0 0 0  1 D C B, D=display, C=curson, B=blink
               0  0   0 0 0 0  1 1 1 1, display on, curson on, blink off

Function set   0  0   0 0 1 DL  N F - -, DL=data length, N=display lines, F=font
 */

const int t_as = 1; // 140ns, address setup
const int t_ah = 1; // 20ns, address hold
const int t_pw = 1; // 450ns, pulse width

const int t_init1 = 4500;
const int t_init2 = 100;
const int t_exec = 80;

void lcd_strobe(int rs, int rw, unsigned char b) {
    unsigned char c1 = (b >> 4) & 0x0f;
    c1 = rs ? c1 | bit_rs : c1 & ~bit_rs;
    c1 = rw ? c1 | bit_rw : c1 & ~bit_rw;

    unsigned char c2 = b & 0x0f;
    c2 = rs ? c2 | bit_rs : c2 & ~bit_rs;
    c2 = rw ? c2 | bit_rw : c2 & ~bit_rw;

    printf("strobing: %02x\n", b);
    //printf(" high: %x\n", b & 0x0f);
    //printf(" low : %x\n", (b >> 4) & 0x0f);

    unsigned char buf[4] = {
        c1 | bit_e,
        c1,
        c2 | bit_e,
        c2
    };
    if(ftdi_write_data(&ftdi, buf, sizeof(buf)) < 0) {
        fprintf(stderr, "Unable to write data: %s\n", ftdi_get_error_string(&ftdi));
        exit(EXIT_FAILURE);
    }
}

void lcd_command(unsigned char b) {
    lcd_strobe(0, 0, b);
    usleep(4100);
    /*
    lcd_strobe(0, 0, (b >> 4) & 0x0f);
    usleep(100);
    lcd_strobe(0, 0, 0x0f & b);
    usleep(100);
    */
}

void lcd_data(unsigned char b) {
    lcd_strobe(1, 0, b);
    /*
    lcd_strobe(1, 0, (b >> 4) & 0x0f);
    usleep(100);
    lcd_strobe(1, 0, 0x0f & b);
    usleep(100);
    */
}

int main(int argc, char* argv[]) {
    int err;

    int interface, vid = 0x0403, pid = 0x6001;

    {
        int i;
        while ((i = getopt(argc, argv, "i:v:p:")) != -1)
        {
            switch (i)
            {
                case 'i': // 0=ANY, 1=A, 2=B, 3=C, 4=D
                    interface = strtoul(optarg, NULL, 0);
                    break;
                case 'v':
                    vid = strtoul(optarg, NULL, 0);
                    break;
                case 'p':
                    pid = strtoul(optarg, NULL, 0);
                    break;
                default:
                    fprintf(stderr, "usage: %s [-i interface] [-v vid] [-p pid]\n", *argv);
                    exit(-1);
            }
        }
    }

    err = ftdi_init(&ftdi);
    if(err < 0) {
       fprintf(stderr, "Could not initialize libftdi."); 
       return EXIT_FAILURE;
    }

    ftdi_set_interface(&ftdi, interface);

    err = ftdi_usb_open(&ftdi, vid, pid);
    if(err < 0) {
        fprintf(stderr, "Could not open usb device %04x:%04x: %s\n", vid, pid, ftdi_get_error_string(&ftdi));
        return EXIT_FAILURE;
    }

    /*
    err = ftdi_usb_reset(&ftdi);
    if(err < 0) {
        fprintf(stderr, "Could not reset usb device: %s\n", ftdi_get_error_string(&ftdi));
        return EXIT_FAILURE;
    }
    */

    err = ftdi_set_baudrate(&ftdi, 921600);
    if (err < 0) {
        fprintf(stderr, "Unable to set baudrate: %s", ftdi_get_error_string(&ftdi));
        return EXIT_FAILURE;
    }

    //err = ftdi_set_bitmode(&ftdi, 0xff, BITMODE_RESET);
    //err = ftdi_set_bitmode(&ftdi, 0xff, BITMODE_BITBANG);
    err = ftdi_set_bitmode(&ftdi, 0xff, BITMODE_SYNCBB);
    if(err < 0) {
        fprintf(stderr, "Could set bit mode %s\n", ftdi_get_error_string(&ftdi));
        return EXIT_FAILURE;
    }

    /*
    err = ftdi_write_data_set_chunksize(&ftdi, 1);
    if(err < 0) {
        fprintf(stderr, "Could set chunk size %s\n", ftdi_get_error_string(&ftdi));
        return EXIT_FAILURE;
    }
    */

    /*
    char buf[1];
    for(int i = 0; i < 10; i++) {
        buf[0] = (i % 2) ? 0xff : 0x00;

        if((err = ftdi_write_data(&ftdi, buf, sizeof(buf))) < 0) {
            fprintf(stderr, "Unable to write data: %s\n", ftdi_get_error_string(&ftdi));
            return EXIT_FAILURE;
        }
        fprintf(stdout, "err=%d\n", err);
    }
    */

    // send_instruction(0xff);

    // Internal reset/wake up
    /*
    lcd_strobe(0, 0, 0x02);
    usleep(t_init1);
    lcd_strobe(0, 0, 0x02);
    usleep(t_init2);
    lcd_strobe(0, 0, 0x03);
    usleep(t_init1);
    lcd_strobe(0, 0, 0x02);
    usleep(t_init2);
    */
#define CLEAR       0x01

#define HOMECURSOR  0x02

#define ENTRYMODE   0x04
#define E_MOVERIGHT 0x02
#define E_MOVELEFT  0x00
#define EDGESCROLL  0x01
#define NOSCROLL    0x00

#define ONOFFCTRL   0x08    /* Only reachable with EXTREG clear */
#define DISPON      0x04
#define DISPOFF     0x00
#define CURSORON    0x02
#define CURSOROFF   0x00
#define CURSORBLINK 0x01
#define CURSORNOBLINK   0x00

#define FUNCSET     0x20
#define IF_8BIT     0x10
#define IF_4BIT     0x00
#define TWOLINE     0x08
#define ONELINE     0x00

    lcd_command(FUNCSET | IF_4BIT | TWOLINE);
    lcd_command(FUNCSET | IF_4BIT | TWOLINE);
    lcd_command(FUNCSET | IF_4BIT | TWOLINE);
    lcd_command(FUNCSET | IF_4BIT | TWOLINE);

    lcd_command(ONOFFCTRL | DISPON | CURSOROFF | CURSORNOBLINK);
    lcd_command(CLEAR);
    lcd_command(ENTRYMODE | E_MOVERIGHT | NOSCROLL);
    lcd_command(HOMECURSOR);

    char* d = argv[1];
    while(*d != '\0') {
        lcd_data(*d);
        d++;
    }

    ftdi_usb_close(&ftdi);
    ftdi_deinit(&ftdi);

    return EXIT_SUCCESS;
}
