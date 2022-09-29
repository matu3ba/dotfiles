//! Common AES routines for openssl
//! Take care about file permissions of unencrypted/decrypted files seed, key
//! and the sizes for KEY and IV!

// openssl has relative poor documentation for basics like correct memory handling:
// https://stackoverflow.com/questions/26345175/correct-way-to-free-allocate-the-context-in-the-openssl

#include <openssl/err.h>
#include <openssl/evp.h>

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define ERR_EVP_CIPHER_INIT -1
#define ERR_EVP_CIPHER_UPDATE -2
#define ERR_EVP_CIPHER_FINAL -3
#define ERR_EVP_CTX_NEW -4

#define AES_256_KEY_SIZE 32
#define AES_BLOCK_SIZE 16
#define BUFSIZE 1024

typedef struct _cipher_params_t{
    unsigned char *key;
    unsigned char *iv;
    unsigned int encrypt;
    const EVP_CIPHER *cipher_type;
}cipher_params_t;

// source https://wiki.openssl.org/index.php/EVP_Symmetric_Encryption_and_Decryption
int encrypt256cbc(unsigned char *plaintext, int plaintext_len,
    const unsigned char *key, const unsigned char *iv, unsigned char *ciphertext)
{
    EVP_CIPHER_CTX *ctx;
    int len;
    int ciphertext_len;
    /* Create and initialise the context */
    if(!(ctx = EVP_CIPHER_CTX_new())) {
        ERR_print_errors_fp(stderr);
        return -1;
    }
    // Initialise the encryption operation.
    // IMPORTANT - ensure you use a key and IV size appropriate for your cipher
    if(1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv)) {
        ERR_print_errors_fp(stderr);
        EVP_CIPHER_CTX_free(ctx);
        return -1;
    }
    // Provide the message to be encrypted, and obtain the encrypted output.
    // EVP_EncryptUpdate can be called multiple times if necessary
    if(1 != EVP_EncryptUpdate(ctx, ciphertext, &len, plaintext, plaintext_len)) {
        ERR_print_errors_fp(stderr);
        EVP_CIPHER_CTX_free(ctx);
        return -1;
    }
    ciphertext_len = len;
    // Finalise the encryption. Further ciphertext bytes may be written at
    // this stage.
    if(1 != EVP_EncryptFinal_ex(ctx, ciphertext + len, &len)) {
        ERR_print_errors_fp(stderr);
        EVP_CIPHER_CTX_free(ctx);
        return -1;
    }
    ciphertext_len += len;
    // Clean up
    EVP_CIPHER_CTX_free(ctx);
    return ciphertext_len;
}

// source https://wiki.openssl.org/index.php/EVP_Symmetric_Encryption_and_Decryption
int decrypt256cbc(unsigned char *ciphertext, int ciphertext_len,
    const unsigned char *key, const unsigned char *iv, unsigned char *plaintext)
{
    EVP_CIPHER_CTX *ctx;
    int len;
    int plaintext_len;
    // create and initialise context
    if(!(ctx = EVP_CIPHER_CTX_new())) {
        ERR_print_errors_fp(stderr);
        return -1;
    }
    // Initialise the decryption operation.
    // IMPORTANT - ensure you use a key and IV size appropriate for your cipher
    if(1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv)) {
        ERR_print_errors_fp(stderr);
        EVP_CIPHER_CTX_free(ctx);
        return -1;
    }
    // Provide the message to be decrypted, and obtain the plaintext output.
    // EVP_DecryptUpdate can be called multiple times if necessary.
    if(1 != EVP_DecryptUpdate(ctx, plaintext, &len, ciphertext, ciphertext_len)) {
        ERR_print_errors_fp(stderr);
        EVP_CIPHER_CTX_free(ctx);
        return -1;
    }
    plaintext_len = len;
    // Finalise the decryption. Further plaintext bytes may be written at
    // this stage.
    if(1 != EVP_DecryptFinal_ex(ctx, plaintext + len, &len)) {
        ERR_print_errors_fp(stderr);
        EVP_CIPHER_CTX_free(ctx);
        return -1;
    }
    plaintext_len += len;
    // Clean up
    EVP_CIPHER_CTX_free(ctx);
    return plaintext_len;
}

bool areFilesEqual(FILE *file1, FILE *file2){
    char ch1 = getc(file1);
    char ch2 = getc(file2);
    while (ch1 != EOF && ch2 != EOF){
        if (ch1 != ch2){
            return false;
        }
        ch1 = getc(file1); // naive slow and unbuffered solution
        ch2 = getc(file2);
    }
    return true;
}

// adjusted from https://github.com/kulkarniamit/openssl-evp-demo
// 1e9f2c2afe267d98e7530a16028d798df09d49a2 ./openssl_evp_demo.c
int file_encrypt_decrypt(cipher_params_t *params, FILE *ifp, FILE *ofp)
{
    // enough space in output buffer for additional block
    int cipher_block_size = EVP_CIPHER_block_size(params->cipher_type);
    // ugly VLA with unnecessary performance loss, even though EVP_CIPHER_block_size
    // is a simple getter and the maximum of used input values is comptime known
    unsigned char in_buf[BUFSIZE], out_buf[BUFSIZE + cipher_block_size];

    int num_bytes_read, out_len;
    EVP_CIPHER_CTX *ctx;

    ctx = EVP_CIPHER_CTX_new(); // potentially allocates
    if(ctx == NULL){
        fprintf(stderr, "ERROR: EVP_CIPHER_CTX_new failed. OpenSSL error: %s\n", ERR_error_string(ERR_get_error(), NULL));
        return ERR_EVP_CTX_NEW;
    }

    // check lengths
    if(!EVP_CipherInit_ex(ctx, params->cipher_type, NULL, NULL, NULL, params->encrypt)){
        EVP_CIPHER_CTX_free(ctx);
        return ERR_EVP_CIPHER_INIT;
    }

    OPENSSL_assert(EVP_CIPHER_CTX_key_length(ctx) == AES_256_KEY_SIZE);
    OPENSSL_assert(EVP_CIPHER_CTX_iv_length(ctx) == AES_BLOCK_SIZE);

    // set key and iv
    if(!EVP_CipherInit_ex(ctx, NULL, NULL, params->key, params->iv, params->encrypt)){
        EVP_CIPHER_CTX_free(ctx);
        return ERR_EVP_CIPHER_INIT;
    }

    while(1){
        // read in data in blocks and update cipher on every read
        num_bytes_read = fread(in_buf, sizeof(unsigned char), BUFSIZE, ifp);
        if (ferror(ifp)){
            EVP_CIPHER_CTX_free(ctx);
            return errno;
        }
        if(!EVP_CipherUpdate(ctx, out_buf, &out_len, in_buf, num_bytes_read)){
            EVP_CIPHER_CTX_free(ctx);
            return ERR_EVP_CIPHER_UPDATE;
        }
        fwrite(out_buf, sizeof(unsigned char), out_len, ofp);
        if (ferror(ofp)) {
            EVP_CIPHER_CTX_free(ctx);
            return errno;
        }
        if (num_bytes_read < BUFSIZE) {
            // reached EOF
            break;
        }
    }

    // cipher final block
    if(!EVP_CipherFinal_ex(ctx, out_buf, &out_len)){
        EVP_CIPHER_CTX_free(ctx);
        return ERR_EVP_CIPHER_FINAL;
    }
    fwrite(out_buf, sizeof(unsigned char), out_len, ofp);
    if (ferror(ofp)) {
        EVP_CIPHER_CTX_free(ctx);
        return errno;
    }
    EVP_CIPHER_CTX_free(ctx);
    return 0;
}

