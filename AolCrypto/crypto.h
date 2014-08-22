//
//  crypto.h
//  xmlParserTest
//
//  Created by  Arzhna on 2014. 7. 31.
//


#ifndef __xmlParserTest__crypto__
#define __xmlParserTest__crypto__

#define TEST_FUCNTION_ENABLE 0




/*********************
 *
 *  Common functions
 *
 *********************/

void printLastError(char *msg);



/*********************
 *
 *  RSA functions
 *
 *********************/

int rsa_public_encrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *encrypted);
int rsa_private_decrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *decrypted);
int rsa_private_encrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *encrypted);
int rsa_public_decrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *decrypted);

void printLastError(char *msg);



/*********************
 *
 *  DES functions
 *
 *********************/

void des_encrypt(unsigned char *key1, unsigned char *key2, unsigned char *key3, unsigned char* iv, unsigned char *msg, unsigned int data_len, unsigned char *encrypted);
void des_decrypt(unsigned char *key1, unsigned char *key2, unsigned char *key3, unsigned char* iv, unsigned char *msg, unsigned int data_len, unsigned char *decrypted);



/*********************
 *
 *  AES functions
 *
 *********************/

void aes_encrypt(unsigned char *key, unsigned char *iv, unsigned char *msg, unsigned int data_len, unsigned char *encrypted);
void aes_decrypt(unsigned char *key, unsigned char *iv, unsigned char *msg, unsigned int data_len, unsigned char *decrypted);



/*********************
 *
 *  HASH functions
 *
 *********************/

void sha256(unsigned char *msg, unsigned char *hashed);



/*********************
 *
 *  Test functions
 *
 *********************/

#if TEST_FUCNTION_ENABLE
void test_crypto(void);
void test_des(void);
void test_aes(void);
#endif


#endif /* defined(__xmlParserTest__crypto__) */
