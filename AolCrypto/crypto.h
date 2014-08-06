//
//  crypto.h
//  xmlParserTest
//
//  Created by  Arzhna on 2014. 7. 31.
//

#ifndef __xmlParserTest__crypto__
#define __xmlParserTest__crypto__

#define TEST_FUCNTION_ENABLE 0

/* Common Functions */
void printLastError(char *msg);

/* RSA Functions */
int rsa_public_encrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *encrypted);
int rsa_private_decrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *decrypted);
int rsa_private_encrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *encrypted);
int rsa_public_decrypt(unsigned char *key, unsigned char *msg, int data_len, unsigned char *decrypted);

void printLastError(char *msg);

/* DES Functions */
void des_encrypt(unsigned char *key1, unsigned char *key2, unsigned char *key3, unsigned char* iv, unsigned char *msg, int size, unsigned char *encrypted);
void des_decrypt(unsigned char *key1, unsigned char *key2, unsigned char *key3, unsigned char* iv, unsigned char *msg, int size, unsigned char *decrypted);

#if TEST_FUCNTION_ENABLE
void test_crypto(void);
void test_des(void);
#endif
#endif /* defined(__xmlParserTest__crypto__) */
