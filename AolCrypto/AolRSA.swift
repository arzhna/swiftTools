//
//  AolRSA.swift
//
//  Created by  Arzhna on 2014. 8. 1
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Foundation

let sizeOfCipher    = 128
let maxSizeOfPlain  = 64*1024

enum RSAKeyType {
    case PublicKey
    case PrivateKey
}

class AolRSA {
    var publicKey: NSData
    var privateKey: NSData
    
    init() {
        self.publicKey = NSData()
        self.privateKey = NSData()
    }
    
    init(publicKey: NSData, privateKey: NSData) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
    
    // RSA
    func encrypt(plain:NSData, usingKey:RSAKeyType) -> NSData {
        // create buffer
        var encrypted = UnsafeMutablePointer<CUnsignedChar>.alloc(sizeOfCipher)
        var encryptedLength: CInt
        
        // convert to ctype from nsdata
        let plainData = UnsafeMutablePointer<CUnsignedChar>(plain.bytes)
        
        // encrypt
        if usingKey == .PublicKey {
            let pubKey = UnsafeMutablePointer<CUnsignedChar>(self.publicKey.bytes)
            encryptedLength = rsa_public_encrypt(pubKey, plainData, CInt(plain.length), encrypted)
        }else{
            let privKey = UnsafeMutablePointer<CUnsignedChar>(self.privateKey.bytes)
            encryptedLength = rsa_private_encrypt(privKey, plainData, CInt(plain.length), encrypted)
        }
        
        // process result
        var result = NSData()
        if encryptedLength > 0 {
            // convert encrypted data to nsdata from ctype
            result = NSData(bytes: encrypted, length: Int(encryptedLength))
        }else{
            println("encrypt failed")
        }
        
        //dealloc buffer
        encrypted.dealloc(sizeOfCipher)
        
        return result
    }
    
    func decrypt(cipher:NSData, usingKey:RSAKeyType) -> NSData {
        // create buffer
        var decrypted = UnsafeMutablePointer<CUnsignedChar>.alloc(maxSizeOfPlain)
        var decryptedLength: CInt
        
        // convert data
        let cipherData = UnsafeMutablePointer<CUnsignedChar>(cipher.bytes)
        
        // decrypt
        if usingKey == .PublicKey {
            let pubKey = UnsafeMutablePointer<CUnsignedChar>(self.publicKey.bytes)
            decryptedLength = rsa_public_decrypt(pubKey, cipherData, CInt(cipher.length), decrypted)
        }else{
            let privKey = UnsafeMutablePointer<CUnsignedChar>(self.privateKey.bytes)
            decryptedLength = rsa_private_decrypt(privKey, cipherData, CInt(cipher.length), decrypted)
        }
        
        // process result
        var result = NSData()
        if decryptedLength > 0 {
            // convert encrypted data to nsdata from ctype
            result = NSData(bytes: decrypted, length: Int(decryptedLength))
        }else{
            println("decrypt failed")
        }
        
        //dealloc buffer
        decrypted.dealloc(maxSizeOfPlain)
        
        return result
    }
}

