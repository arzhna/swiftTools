//
//  AolDES.swift
//
//  Created by  Arzhna on 2014. 8. 1.
//
//  using Triple DES - EDE3 - CBC
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Foundation

class AolDES: AolSymCrypto {
    
    init() {
        // init AolSymCrypto class
        super.init(type: .DES)
        
        // init keys
        self.generateKeys()
    }
    
    init(key1: NSData, key2: NSData, key3: NSData) {
        // init AolSymCrypto class
        super.init(type: .DES)
        
        // init keys
        self.key.append(key1)
        self.key.append(key2)
        self.key.append(key3)
    }
    
    func setNewKey(key1: NSData, key2: NSData, key3: NSData) {
        self.key.removeAll(keepCapacity: false)
        self.key.append(key1)
        self.key.append(key2)
        self.key.append(key3)
    }
    
    override func encrypt(plain: NSData)->NSData {
        // add padding for 8 Bytes-align
        let alignedData = self.addPadding(plain)
        
        // create buffer
        var encrypted = UnsafeMutablePointer<CUnsignedChar>.alloc(alignedData.length)
        encrypted.initialize(0)
        
        // convert to ctype from nsdata
        let plainData = UnsafeMutablePointer<CUnsignedChar>(alignedData.bytes)
        let key1 = UnsafeMutablePointer<CUnsignedChar>(self.key[0].bytes)
        let key2 = UnsafeMutablePointer<CUnsignedChar>(self.key[1].bytes)
        let key3 = UnsafeMutablePointer<CUnsignedChar>(self.key[2].bytes)
        let iv = UnsafeMutablePointer<CUnsignedChar>(self.iVec.bytes)
        
        des_encrypt(key1, key2, key3, iv, plainData, CUnsignedInt(alignedData.length), encrypted)
        
        // convert encrypted data to nsdata from ctype
        let result = NSData(bytes: encrypted, length: alignedData.length)
        
        //dealloc buffer
        encrypted.dealloc(alignedData.length)
        
        return result
    }
    
    override func decrypt(cipher: NSData)->NSData {
        // Perhaps, cipher is already 8 bytes-aligned. But, do it one more.
        let alignedData = self.addPadding(cipher)
        
        // create buffer
        var decrypted = UnsafeMutablePointer<CUnsignedChar>.alloc(alignedData.length)
        decrypted.initialize(0)
        
        // convert to ctype from nsdata
        let cipherData = UnsafeMutablePointer<CUnsignedChar>(alignedData.bytes)
        let key1 = UnsafeMutablePointer<CUnsignedChar>(self.key[0].bytes)
        let key2 = UnsafeMutablePointer<CUnsignedChar>(self.key[1].bytes)
        let key3 = UnsafeMutablePointer<CUnsignedChar>(self.key[2].bytes)
        let iv = UnsafeMutablePointer<CUnsignedChar>(self.iVec.bytes)

        // decrypt
        des_decrypt(key1, key2, key3, iv, cipherData, CUnsignedInt(alignedData.length), decrypted)
        
        // convert decrypted data to nsdata from ctype
        var result = NSData(bytes: decrypted, length: alignedData.length)
        
        // reduce padding
        result = self.reducePadding(result)
        
        //dealloc buffer
        decrypted.dealloc(alignedData.length)
        
        return result
    }
}
