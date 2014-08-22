//
//  AolAES.swift
//
//  Created by  Arzhna on 2014. 8. 21.
//
//  using Triple AES - CBC
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Foundation

class AolAES: AolSymCrypto {
    
    init() {
        // init AolSymCrypto class
        super.init(type: .AES)
        
        // init keys
        self.generateKeys()
    }
    
    init(key: NSData) {
        // init AolSymCrypto class
        super.init(type: .AES)
        
        // set key
        self.key.append(key)
    }
    
    func setNewKey(key: NSData) {
        self.key.removeAll(keepCapacity: false)
        self.key.append(key)
    }
    
    override func encrypt(plain: NSData)->NSData {
        // add padding for 16 Bytes-align
        let alignedData = self.addPadding(plain)
        
        // create buffer
        var encrypted = UnsafeMutablePointer<CUnsignedChar>.alloc(alignedData.length)
        encrypted.initialize(0)
        
        // convert to ctype from nsdata
        let plainData = UnsafeMutablePointer<CUnsignedChar>(alignedData.bytes)
        let key = UnsafeMutablePointer<CUnsignedChar>(self.key[0].bytes)
        
        // copy iv to temp buffer, because of iv is changed in aes
        let iv_enc = NSMutableData(data: self.iVec)
        let iv = UnsafeMutablePointer<CUnsignedChar>(iv_enc.bytes)
        
        aes_encrypt(key, iv, plainData, CUnsignedInt(alignedData.length), encrypted)
        
        // convert encrypted data to nsdata from ctype
        let result = NSData(bytes: encrypted, length: alignedData.length)
        
        //dealloc buffer
        encrypted.dealloc(alignedData.length)
        
        return result
    }
    
    override func decrypt(cipher: NSData)->NSData {
        // Perhaps, cipher is already 16 bytes-aligned. But, do it one more.
        let alignedData = self.addPadding(cipher)
        
        // create buffer
        var decrypted = UnsafeMutablePointer<CUnsignedChar>.alloc(alignedData.length)
        decrypted.initialize(0)
        
        // convert to ctype from nsdata
        let cipherData = UnsafeMutablePointer<CUnsignedChar>(alignedData.bytes)
        let key = UnsafeMutablePointer<CUnsignedChar>(self.key[0].bytes)
        
        // copy iv to temp buffer, because of iv is changed in aes
        let iv_dec = NSMutableData(data: self.iVec)
        let iv = UnsafeMutablePointer<CUnsignedChar>(iv_dec.bytes)
        
        // decrypt
        aes_decrypt(key, iv, cipherData, CUnsignedInt(alignedData.length), decrypted)
        
        // convert decrypted data to nsdata from ctype
        var result = NSData(bytes: decrypted, length: alignedData.length)
        
        // reduce padding
        result = self.reducePadding(result)
        
        //dealloc buffer
        decrypted.dealloc(alignedData.length)
        
        return result
    }
}
