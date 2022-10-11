#include <efivar/efiboot.h>

#include <ctype.h>
#include <errno.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static void
print_dp(unsigned char *dp, ssize_t dp_size)
{
    printf("HEX: ");
    for (size_t i = 0; i < dp_size; ++i) {
        printf("0x%02x ", dp[i]);
    }
    printf("\n\n");

    printf("ASCII: ");
    for (size_t i = 0; i < dp_size; ++i) {
        printf("%c", isprint(dp[i]) ? dp[i] : '?');
    }
    printf("\n\n");

    ssize_t buf_sz = efidp_format_device_path(NULL, 0,
                                              (const_efidp)dp, dp_size);
    if (buf_sz <= 0)
        return;

    char *buf = alloca(buf_sz);
    if (buf == NULL)
        return;

    buf_sz = efidp_format_device_path(buf, buf_sz,
                                      (const_efidp)dp, dp_size);
    if (buf_sz <= 0)
        return;

    printf("DP: %s\n", buf);
}

static bool
make_dp(const char filepath[], unsigned char **dp_buf, ssize_t *dp_size)
{
    ssize_t sz;

    sz = efi_generate_file_device_path(NULL,
                                       0,
                                       filepath,
                                       EFIBOOT_OPTIONS_IGNORE_FS_ERROR |
                                       EFIBOOT_ABBREV_HD);
    if (sz < 0) {
        printf("first call failed: %s\n", strerror(errno));
        return false;
    }

    *dp_size = sz;

    *dp_buf = malloc(*dp_size);
    if (*dp_buf == NULL) {
        printf("dp_buf alloc failed: %s\n", strerror(errno));
        return false;
    }

    sz = efi_generate_file_device_path(*dp_buf,
                                       *dp_size,
                                       filepath,
                                       EFIBOOT_OPTIONS_IGNORE_FS_ERROR |
                                       EFIBOOT_ABBREV_HD);
    if (sz != *dp_size) {
        printf("second call failed: %s\n", strerror(errno));
        return false;
    }

    return true;
}

static void
make_loadopt(unsigned char *dp_buf, ssize_t dp_size)
{
    uint32_t attributes = 1; /* LOAD_OPTION_ACTIVE */
    const unsigned char *label = "label";
    const unsigned char *loader_str = "\0L\0O\0A\0D\0E\0R\0"; /* Pseudo UTF-16 */
    ssize_t loader_sz = 14;

    ssize_t sz = efi_loadopt_create(NULL,
                                    0,
                                    attributes,
                                    (efidp)dp_buf,
                                    dp_size,
                                    (void *)label,
                                    (void *)loader_str,
                                    loader_sz);
    if (sz < 0) {
        printf("1st efi_loadopt_create() call failed: %s\n", strerror(errno));
        return;
    }

    unsigned char *opt = malloc(sz);
    ssize_t opt_size = sz;
    sz = efi_loadopt_create(opt,
                            opt_size,
                            attributes,
                            (efidp)dp_buf,
                            dp_size,
                            (void *)label,
                            (void *)loader_str,
                            loader_sz);
    if (sz != opt_size)
        printf("2nd efi_loadopt_create() call failed: %s\n", strerror(errno));
    else
        printf("\nefi_loadopt_create() has succeeded\n");

    free(opt);
}

int
main(int argc, char *argv[])
{
    if (argc != 2) {
        printf("Usage: %s path\n", argv[0]);
        return 1;
    }

    ssize_t dp_size;
    unsigned char *dp_buf;
    if (!make_dp(argv[1], &dp_buf, &dp_size))
        return 1;

    print_dp(dp_buf, dp_size);
    make_loadopt(dp_buf, dp_size);

    free(dp_buf);

    return 0;
}
