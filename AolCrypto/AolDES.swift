//
//  AolDES.swift
//
//  Created by  Arzhna on 2014. 8. 1.
//
//  using Triple DES - EDE3 - CBC
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Foundation

let keyNumber = 3
let keyLength = 8
let initVectorLength = 56

class AolDES {
    
    var desKey: [NSData]
    var iVec: NSData
    
    init() {
        // init keys and iVector
        self.desKey = [NSData]()
        self.iVec = NSData()
        
        self.generateKeys()
    }
    
    deinit {
        self.desKey.removeAll(keepCapacity: false)
    }
    
    init(key1: NSData, key2: NSData, key3: NSData) {
        self.desKey = [NSData]()
        self.desKey.append(key1)
        self.desKey.append(key2)
        self.desKey.append(key3)
        
        self.iVec = NSData()
    }
    
    func generateKeys(){
        let time = NSDate().timeIntervalSince1970
        var byte = [Byte()]

        srandom(UInt32(Int(time)))
        
        for j in 0..<keyNumber {
            for i in 0..<keyLength {
                byte.insert(Byte(random()%0xFF), atIndex: i)
            }
            self.desKey.append(NSData(bytes: byte, length: keyLength))
            byte.removeAll(keepCapacity: false)
        }
    }
    
    func generateInitVector(){
        let time = NSDate().timeIntervalSince1970
        var byte = [Byte()]
        
        srandom(UInt32(Int(time)))
        for i in 0..<initVectorLength {
            byte.insert(Byte(random()%0xFF), atIndex: i)
        }
        self.iVec = NSData(bytes: byte, length: initVectorLength)
    }
    
    func encrypt(plain: NSData)->NSData {
        // create buffer
        var encrypted = UnsafeMutablePointer<CUnsignedChar>.alloc(plain.length)
        
        // convert to ctype from nsdata
        let plainData = UnsafeMutablePointer<CUnsignedChar>(plain.bytes)
        let key1 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[0].bytes)
        let key2 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[1].bytes)
        let key3 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[2].bytes)
        let iv = UnsafeMutablePointer<CUnsignedChar>(self.iVec.bytes)
        
        des_encrypt(key1, key2, key3, iv, plainData, CInt(plain.length), encrypted)
        
        // convert encrypted data to nsdata from ctype
        let result = NSData(bytesNoCopy: encrypted, length: plain.length)
        
        //dealloc buffer
        encrypted.dealloc(plain.length)
        
        return result
    }
    
    func decrypt(cipher: NSData)->NSData {
        // create buffer
        var decrypted = UnsafeMutablePointer<CUnsignedChar>.alloc(cipher.length)
       
        // convert to ctype from nsdata
        let cipherData = UnsafeMutablePointer<CUnsignedChar>(cipher.bytes)
        let key1 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[0].bytes)
        let key2 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[1].bytes)
        let key3 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[2].bytes)
        let iv = UnsafeMutablePointer<CUnsignedChar>(self.iVec.bytes)
        
        // decrypt
        des_decrypt(key1, key2, key3, iv, cipherData, CInt(cipher.length), decrypted)
        
        // convert decrypted data to nsdata from ctype
        let result = NSData(bytes: decrypted, length: cipher.length)
        
        //dealloc buffer
        decrypted.dealloc(cipher.length)
        
        return result

    }
}
