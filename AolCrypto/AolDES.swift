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
    
    init(key1: NSData, key2: NSData, key3: NSData) {
        self.desKey = [NSData]()
        self.desKey.append(key1)
        self.desKey.append(key2)
        self.desKey.append(key3)
        
        self.iVec = NSData()
    }
    
    deinit {
        self.desKey.removeAll(keepCapacity: false)
    }
    
    
    
    // private methods
    func addDummyTo8BytesAlign(data: NSData) -> NSData {
        // calculate 8Bytes-aligned length
        var alignedLength: Int
        if data.length % 8 != 0 {
            alignedLength = (data.length/8)*8 + 8
        } else {
            alignedLength = data.length
        }
        
        // copy data to append dummy
        var tempData = NSMutableData(data: data)
        
        if alignedLength > data.length {
            // create dummy that consist of zero
            let dummyLength = alignedLength - data.length
            let dummyBuffer = UnsafeMutablePointer<CUnsignedChar>.alloc(dummyLength)
            dummyBuffer.initialize(0)
            
            // append dummy
            tempData.appendBytes(dummyBuffer, length: dummyLength)
            
            dummyBuffer.dealloc(dummyLength)
        }
        
        return tempData as NSData
    }
    
    func reduceDummyTo8BytesAlign(data: NSData) -> NSData {
        var dummyLength = 0
        let dummyBuffer = UnsafeMutablePointer<CUnsignedChar>.alloc(data.length)
        
        // check dummy bytes
        data.getBytes(dummyBuffer, length: data.length)
        for i in (data.length-8)..<data.length {
            if dummyBuffer[i] == 0 {
                dummyLength++
            }
        }
        
        // copy dummy-reduced data
        var reducedData: NSData
        if dummyLength > 0 {
            reducedData = NSData(bytes: dummyBuffer, length: data.length-dummyLength)
        }else{
            reducedData = NSData(data: data)
        }
        
        dummyBuffer.dealloc(data.length)
        
        return reducedData
    }
    
    
    
    // public methods
    func generateKeys(){
        let time = Int(Double(NSDate().timeIntervalSince1970)*100000) & 0xFFFF
        var byte = [Byte()]

        srandom(UInt32(time))
        
        for j in 0..<keyNumber {
            for i in 0..<keyLength {
                byte.insert(Byte(random()%0xFF), atIndex: i)
            }
            self.desKey.append(NSData(bytes: byte, length: keyLength))
            byte.removeAll(keepCapacity: false)
        }
    }
    
    func generateInitVector(){
        let time = Int(Double(NSDate().timeIntervalSince1970)*100000) & 0xFFFF
        var byte = [Byte()]

        srandom(UInt32(time))
        for i in 0..<initVectorLength {
            byte.insert(Byte(random()%0xFF), atIndex: i)
        }
        self.iVec = NSData(bytes: byte, length: initVectorLength)
    }
    
    func encrypt(plain: NSData)->NSData {
        // 8 Bytes-align 
        let alignedData = self.addDummyTo8BytesAlign(plain)
        
        // create buffer
        var encrypted = UnsafeMutablePointer<CUnsignedChar>.alloc(alignedData.length)
        encrypted.initialize(0)
        
        // convert to ctype from nsdata
        let plainData = UnsafeMutablePointer<CUnsignedChar>(alignedData.bytes)
        let key1 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[0].bytes)
        let key2 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[1].bytes)
        let key3 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[2].bytes)
        let iv = UnsafeMutablePointer<CUnsignedChar>(self.iVec.bytes)
        
        des_encrypt(key1, key2, key3, iv, plainData, CInt(alignedData.length), encrypted)
        
        // convert encrypted data to nsdata from ctype
        let result = NSData(bytes: encrypted, length: alignedData.length)
        
        //dealloc buffer
        encrypted.dealloc(alignedData.length)
        
        return result
    }
    
    func decrypt(cipher: NSData)->NSData {
        // Perhaps, cipher is already 8 bytes-aligned. But, do it one more.
        let alignedData = self.addDummyTo8BytesAlign(cipher)
        
        // create buffer
        var decrypted = UnsafeMutablePointer<CUnsignedChar>.alloc(alignedData.length)
        decrypted.initialize(0)
        
        // convert to ctype from nsdata
        let cipherData = UnsafeMutablePointer<CUnsignedChar>(alignedData.bytes)
        let key1 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[0].bytes)
        let key2 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[1].bytes)
        let key3 = UnsafeMutablePointer<CUnsignedChar>(self.desKey[2].bytes)
        let iv = UnsafeMutablePointer<CUnsignedChar>(self.iVec.bytes)
        
        // decrypt
        des_decrypt(key1, key2, key3, iv, cipherData, CInt(alignedData.length), decrypted)
        
        // convert decrypted data to nsdata from ctype
        var result = NSData(bytes: decrypted, length: alignedData.length)
        
        // reduce dummy data
        result = reduceDummyTo8BytesAlign(result)
        
        //dealloc buffer
        decrypted.dealloc(alignedData.length)
        
        return result

    }
}
