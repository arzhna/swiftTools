//
//  crypto.c
//
//  Created by  Arzhna on 2014. 7. 31.
//

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#include <stdio.h>
#include <string.h>
#include <openssl/pem.h>
#include <openssl/ssl.h>
#include <openssl/rsa.h>
#include <openssl/evp.h>
#include <openssl/bio.h>
#include <openssl/err.h>
#include <openssl/des.h>
#include <openssl/aes.h>
#include <openssl/sha.h>

#include "crypto.h"


/*********************
 *
 *  Common functions
 *
 *********************/

void printLastError(char *msg)
{
    char *err = malloc(130);
    ERR_load_crypto_strings();
    ERR_error_string(ERR_get_error(), err);
    printf("%s ERROR: %s\n",msg, err);
    free(err);
}

void dumpData(unsigned char* data, int length)
{
    int i;
    
    printf("====== dump data(%d) ======\n",length);
    for(i=0;i<length;i++){
        if(i%8==0 && i!=0)
            printf("\n");
        printf("0x%02x, ",data[i]);
    }
    printf("\n");
    printf("===========================\n");
}

/*********************
 *
 *  RSA functions
 *
*********************/

#define padding RSA_PKCS1_PADDING

RSA* createRSA(unsigned char *key, int isPublic)
{
    RSA *rsa= NULL;
    BIO *keybio ;
    
    keybio = BIO_new_mem_buf(key, -1);
    
    if (keybio==NULL)
    {
        printf( "Failed to create key BIO");
        return 0;
    }
    
    if(isPublic)
    {
        rsa = PEM_read_bio_RSA_PUBKEY(keybio, &rsa,NULL, NULL);
    }
    else
    {
        rsa = PEM_read_bio_RSAPrivateKey(keybio, &rsa,NULL, NULL);
    }
    
    if(rsa == NULL)
    {
        printf( "Failed to create RSA");
    }
    
    return rsa;
}

int rsa_public_encrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *encrypted)
{
    int result = 0;
    RSA *rsa = createRSA(key, 1);
    
    if(rsa!=NULL){
        result = RSA_public_encrypt(data_len, msg, encrypted, rsa, padding);
    }
    
    return result;
}

int rsa_private_decrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *decrypted)
{
    int result = 0;
    RSA *rsa = createRSA(key, 0);
    
    if(rsa!=NULL){
        result = RSA_private_decrypt(data_len, msg, decrypted, rsa, padding);
    }
    
    return result;
}

int rsa_private_encrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *encrypted)
{
    int result = 0;
    RSA *rsa = createRSA(key, 0);
    
    if(rsa!=NULL){
        result = RSA_private_encrypt(data_len, msg, encrypted, rsa, padding);
    }
    
    return result;
}


int rsa_public_decrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *decrypted)
{
    int result = 0;
    RSA *rsa = createRSA(key, 1);
    
    if(rsa!=NULL){
        result = RSA_public_decrypt(data_len, msg, decrypted, rsa, padding);
    }
    
    return result;
}

/*********************
 *
 *  DES functions (TDES-EDE3-CBC)
 *
 *********************/

DES_key_schedule getDesKeySchedule(unsigned char* key)
{
    DES_key_schedule schedule;
    DES_cblock cBlock;
    
    memcpy(cBlock, key, 8);
    DES_set_odd_parity(&cBlock);
    DES_set_key_checked(&cBlock, &schedule);
    
    return schedule;
}

void des_encrypt(unsigned char *key1, unsigned char *key2, unsigned char *key3, unsigned char* iv, unsigned char *msg, unsigned int data_len, unsigned char *encrypted)
{
    DES_key_schedule schedule1;
    DES_key_schedule schedule2;
    DES_key_schedule schedule3;
    
    /* Prepare the key for use with DES_ede3_cbc_encrypt */
    schedule1 = getDesKeySchedule(key1);
    schedule2 = getDesKeySchedule(key2);
    schedule3 = getDesKeySchedule(key3);
    
    /* Encryption occurs here */
    DES_ede3_cbc_encrypt(msg, encrypted, data_len, &schedule1, &schedule2, &schedule3, (DES_cblock*)&iv, DES_ENCRYPT);
}

void des_decrypt(unsigned char *key1, unsigned char *key2, unsigned char *key3, unsigned char* iv, unsigned char *msg, unsigned int data_len, unsigned char *decrypted)
{
    DES_key_schedule schedule1;
    DES_key_schedule schedule2;
    DES_key_schedule schedule3;
    
    /* Prepare the key for use with DES_ede3_cbc_encrypt */
    schedule1 = getDesKeySchedule(key1);
    schedule2 = getDesKeySchedule(key2);
    schedule3 = getDesKeySchedule(key3);
    
    /* Decryption occurs here */
    DES_ede3_cbc_encrypt(msg, decrypted, data_len, &schedule1, &schedule2, &schedule3, (DES_cblock*)&iv, DES_DECRYPT);
}


/*********************
 *
 *  AES functions (AES-CBC)
 *
 *********************/

#define AES_KEY_LENGTH  256

void aes_encrypt(unsigned char *key, unsigned char *iv, unsigned char *msg, unsigned int data_len, unsigned char *encrypted)
{
    AES_KEY enc_key;
    
    AES_set_encrypt_key(key, AES_KEY_LENGTH, &enc_key);
    
    AES_cbc_encrypt(msg, encrypted, data_len, &enc_key, iv, AES_ENCRYPT);
}

void aes_decrypt(unsigned char *key, unsigned char *iv, unsigned char *msg, unsigned int data_len, unsigned char *decrypted)
{
    AES_KEY dec_key;
    
    AES_set_decrypt_key(key, AES_KEY_LENGTH, &dec_key);
    
    AES_cbc_encrypt(msg, decrypted, data_len, &dec_key, iv, AES_DECRYPT);
}

/*********************
 *
 *  HASH functions
 *
 *********************/

void sha256(unsigned char *msg, unsigned char *hashed)
{
    int i = 0;
    unsigned char hash[SHA256_DIGEST_LENGTH];
    
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, msg, strlen((const char*)msg));
    SHA256_Final(hash, &sha256);
    
    for(i = 0; i < SHA256_DIGEST_LENGTH; i++)
    {
        sprintf((char*)(hashed + (i * 2)), "%02x", hash[i]);
    }
    
    hashed[64] = 0;
}


/*********************
 *
 *  TEST functions
 *
 *********************/

#if TEST_FUCNTION_ENABLE
void test_rsa(void){
 
    unsigned char plainText[2048/8] = "Hi-Roo, World"; //key length : 2048

    unsigned char publicKey[]="-----BEGIN PUBLIC KEY-----\n"\
        "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDfJY/YNJZ7kbZQS3SLaZIPh6sd\n"\
        "nLAflwOQHHC6Snpef7kd1JZUsBDoEppyvsB8sE2EehCZhrtU8a7SwpJvakP97n9D\n"\
        "JkHEZ6m0cibHxSrJBWujgISzQIJ7iTgfY+suY4KTdysT4AeYGmsIOu8KHAv3Xw8H\n"\
        "R3ocn5azreQj/7GwjQIDAQAB\n"\
        "-----END PUBLIC KEY-----";

     
    unsigned char privateKey[]="-----BEGIN RSA PRIVATE KEY-----\n"\
        "MIICXgIBAAKBgQDfJY/YNJZ7kbZQS3SLaZIPh6sdnLAflwOQHHC6Snpef7kd1JZU\n"\
        "sBDoEppyvsB8sE2EehCZhrtU8a7SwpJvakP97n9DJkHEZ6m0cibHxSrJBWujgISz\n"\
        "QIJ7iTgfY+suY4KTdysT4AeYGmsIOu8KHAv3Xw8HR3ocn5azreQj/7GwjQIDAQAB\n"\
        "AoGAOwU+VJskKi7SH861VqJnpX/mvIBS/Sf+I0HCdyN31kLF/aPa1y9yaU9yVmMp\n"\
        "mlEvT5jRhynhpof+C3S3MozSynqLEqwoHDSTZS7CDoeJiiQoNfDUkfy1dZuBpLqm\n"\
        "hQfG03s9+WJgzeiq2VMO3BlL6BMWpXTbG8jlj1F1/pgqdykCQQD8H83m7e4RYQy+\n"\
        "KMip4JpYxosl5dw9Z1MEAQ5diFTpKQskM38Jwc6T8efLzMem4SB4n0xbb98MpgcR\n"\
        "t7ZeFmxbAkEA4pO4mpYViWs3ot8riWdmRKOHOMNdkLdY1ESe42zO7cESYWs9hPus\n"\
        "f3YsTzsVWhTfexZQCKdAYUSdvNobXhGLNwJBAKw6iaxkAooKsuq/73vke2uDjZCA\n"\
        "+jdT+ui0U/ze4ao5KGw9ZV3j79sul/qnVAeSqFzd7QpVXJhGXnPi/Ig/ZxsCQQDE\n"\
        "UNoSlxfyCUQbiuJeG4kwz7/KHvxi93mv8gT5aL2iozcZ0aFsJ+Q+TFX4EGlfs9Yv\n"\
        "ABY4aTIPFTTW/OPZjbnhAkEAoqKwDvB+Ut+kCVUwXElcOMxg5vk+16N0Xz+szdsg\n"\
        "A/mEjvUaxSbFOQLoJtH7oHVYmcav5fm2KknPWp3mOiiimA==\n"\
        "-----END RSA PRIVATE KEY-----";
     
    unsigned char  encrypted[4098]={};
    unsigned char decrypted[4098]={};
    int encrypted_length;
    int decrypted_length;
     
    encrypted_length = rsa_public_encrypt(publicKey, plainText, (int)(strlen((const char*)plainText)), encrypted);
    if(encrypted_length == -1)
    {
        printLastError("Public Encrypt failed ");
        exit(0);
    }
    printf("Encrypted length =%d\n",encrypted_length);
     
    decrypted_length = rsa_private_decrypt(privateKey, encrypted, encrypted_length, decrypted);
    if(decrypted_length == -1)
    {
        printLastError("Private Decrypt failed ");
        exit(0);
    }
    printf("Decrypted Text =%s\n",decrypted);
    printf("Decrypted Length =%d\n",decrypted_length);
    
    encrypted_length= rsa_private_encrypt(privateKey, plainText, (int)(strlen((const char*)plainText)), encrypted);
    if(encrypted_length == -1)
    {
        printLastError("Private Encrypt failed");
        exit(0);
    }
    printf("Encrypted length =%d\n",encrypted_length);
     
    decrypted_length = rsa_public_decrypt(publicKey, encrypted, encrypted_length, decrypted);
    if(decrypted_length == -1)
    {
        printLastError("Public Decrypt failed");
        exit(0);
    }
    printf("Decrypted Text =%s\n",decrypted);
    printf("Decrypted Length =%d\n",decrypted_length);
}

void test_des(void)
{
    unsigned char key1[]="password";
    unsigned char key2[]="abcdefgh";
    unsigned char key3[]="arzhnaks";
    unsigned char iv[]="0";
    
    unsigned char clear[] = "This is a secret message. I'm Arzhna Lee. I'm listening a song that is Chloe of Grouplove.";

    unsigned char *decrypted;
    unsigned char *encrypted;
    int i;
    int ntimes = 1;
    
    encrypted=(unsigned char*)malloc(sizeof(clear));
    decrypted=(unsigned char*)malloc(sizeof(clear));
    
    for(i=0;i<ntimes; i++){
        memset(encrypted, 0, sizeof(clear));
        memset(decrypted, 0, sizeof(clear));
        
        printf("\nClear text\t : %s \n",clear);
        des_encrypt(key1, key2, key3, iv, clear, sizeof(clear), encrypted);
        //printf("Encrypted text\t : %s \n",encrypted);
        des_decrypt(key1, key2, key3, iv, encrypted, sizeof(clear), decrypted);
        printf("Decrypted text\t : %s \n",decrypted);
    }
    
    free(encrypted);
    free(decrypted);
}

void test_aes(void)
{
    static unsigned char aes_key[] = {
        0x83, 0xFE, 0xA5, 0xAD, 0x6D, 0xC9, 0x97, 0x94,
        0x56, 0x83, 0x64, 0xB7, 0x52, 0x3A, 0x71, 0x6A,
        0xA9, 0x38, 0xE3, 0xCA, 0xB2, 0x62, 0x1F, 0x2F,
        0x45, 0x3D, 0x19, 0x8C, 0x02, 0x90, 0xB2, 0x76
    };
    
    static unsigned char iv[] = {
        0x24, 0x46, 0x35, 0x5D, 0x75, 0xA9, 0xF2, 0x84,
        0x0C, 0x51, 0x6D, 0x1F, 0xCD, 0xFF, 0xEF, 0x63
    };

    unsigned char aes_input[] = "This is a secret message. I'm Arzhna Lee. I'm listening a song that is Chloe of Grouplove.";
    
    unsigned int inputslength = sizeof(aes_input);
    
    // buffers for encryption and decryption
    const unsigned int encslength = ((inputslength + AES_BLOCK_SIZE) / AES_BLOCK_SIZE) * AES_BLOCK_SIZE;
    
    //const size_t encslength = ((inputslength + AES_BLOCK_SIZE) / AES_BLOCK_SIZE) * AES_BLOCK_SIZE;
    unsigned char enc_out[encslength];
    unsigned char dec_out[inputslength];
    
    memset(enc_out, 0, sizeof(enc_out));
    memset(dec_out, 0, sizeof(dec_out));
    
    unsigned char iv_dec[AES_BLOCK_SIZE], iv_enc[AES_BLOCK_SIZE];
    
    memcpy(iv_enc, iv, AES_BLOCK_SIZE);
    memcpy(iv_dec, iv, AES_BLOCK_SIZE);
    
    // so i can do with this aes-cbc-128 aes-cbc-192 aes-cbc-256
    aes_encrypt(aes_key, iv_enc, aes_input, inputslength, enc_out);
    aes_decrypt(aes_key, iv_dec, enc_out, encslength, dec_out);

    
    printf("original:\t");
    printf("%s\n", aes_input);
    
    
    printf("decrypt:\t");
    printf("%s\n", dec_out);
}
#endif
