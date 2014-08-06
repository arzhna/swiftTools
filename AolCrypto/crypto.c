//
//  crypto.c
//  xmlParserTest
//
//  Created by  Arzhna on 2014. 7. 31.
//

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#include <openssl/pem.h>
#include <openssl/ssl.h>
#include <openssl/rsa.h>
#include <openssl/evp.h>
#include <openssl/bio.h>
#include <openssl/err.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <openssl/des.h>

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

void des_encrypt(unsigned char *key1, unsigned char *key2, unsigned char *key3, unsigned char* iv, unsigned char *msg, int size, unsigned char *encrypted)
{
    DES_key_schedule schedule1;
    DES_key_schedule schedule2;
    DES_key_schedule schedule3;
    
    /* Prepare the key for use with DES_ede3_cbc_encrypt */
    schedule1 = getDesKeySchedule(key1);
    schedule2 = getDesKeySchedule(key2);
    schedule3 = getDesKeySchedule(key3);
    
    /* Encryption occurs here */
    DES_ede3_cbc_encrypt(msg, encrypted, size, &schedule1, &schedule2, &schedule3, (DES_cblock*)&iv, DES_ENCRYPT);
}

void des_decrypt(unsigned char *key1, unsigned char *key2, unsigned char *key3, unsigned char* iv, unsigned char *msg, int size, unsigned char *decrypted)
{
    DES_key_schedule schedule1;
    DES_key_schedule schedule2;
    DES_key_schedule schedule3;
    
    /* Prepare the key for use with DES_ede3_cbc_encrypt */
    schedule1 = getDesKeySchedule(key1);
    schedule2 = getDesKeySchedule(key2);
    schedule3 = getDesKeySchedule(key3);
    
    /* Decryption occurs here */
    DES_ede3_cbc_encrypt(msg, decrypted, size, &schedule1, &schedule2, &schedule3, (DES_cblock*)&iv, DES_DECRYPT);
}

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
     
    encrypted_length = rsa_public_encrypt(plainText,(int)(strlen((const char*)plainText)),publicKey,encrypted);
    if(encrypted_length == -1)
    {
        printLastError("Public Encrypt failed ");
        exit(0);
    }
    printf("Encrypted length =%d\n",encrypted_length);
     
    decrypted_length = rsa_private_decrypt(encrypted,encrypted_length,privateKey, decrypted);
    if(decrypted_length == -1)
    {
        printLastError("Private Decrypt failed ");
        exit(0);
    }
    printf("Decrypted Text =%s\n",decrypted);
    printf("Decrypted Length =%d\n",decrypted_length);
    
    encrypted_length= rsa_private_encrypt(plainText,(int)(strlen((const char*)plainText)),privateKey,encrypted);
    if(encrypted_length == -1)
    {
        printLastError("Private Encrypt failed");
        exit(0);
    }
    printf("Encrypted length =%d\n",encrypted_length);
     
    decrypted_length = rsa_public_decrypt(encrypted,encrypted_length,publicKey, decrypted);
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
    unsigned char key[]="password";
    unsigned char clear[]="This is a secret message";
    unsigned char *decrypted;
    unsigned char *encrypted;
    
    encrypted=(unsigned char*)malloc(sizeof(clear));
    decrypted=(unsigned char*)malloc(sizeof(clear));
    memset(encrypted, 0, sizeof(clear));
    memset(decrypted, 0, sizeof(clear));
    
    printf("Clear text\t : %s \n",clear);
    des_encrypt(key, clear, sizeof(clear), encrypted);
    printf("Encrypted text\t : %s \n",encrypted);
    des_decrypt(key, encrypted, sizeof(clear), decrypted);
    printf("Decrypted text\t : %s \n",decrypted);
    
    free(encrypted);
    free(decrypted);
}
#endif
