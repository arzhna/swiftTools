//
//  AolSymetric.swift
//
//  Created by  Arzhna on 2014. 8. 21.
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Foundation

enum AolSymCryptoType {
    case DES
    case AES
}

class AolSymCrypto {
    
    let algorithmType: AolSymCryptoType
    let keyNumbers: Int
    let keyLength: Int
    let initVectorLength: Int
    let paddingLength: Int
    
    var key: [NSData]
    var iVec: NSData
    
    init(type: AolSymCryptoType) {
        self.algorithmType = type
        
        switch self.algorithmType {
        case .DES:
            self.keyNumbers = 3
            self.keyLength = 8
            self.paddingLength = 8
        case .AES:
            self.keyNumbers = 1
            self.keyLength = 32
            self.paddingLength = 16
        }
        
        self.initVectorLength = 64
        
        self.key = [NSData]()
        self.iVec = NSData()
    }
    
    func generateKeys() {
        let time = Int(Double(NSDate().timeIntervalSince1970)*100000) & 0xFFFF
        var byte = [Byte()]
        
        srandom(UInt32(time))
        
        for j in 0..<self.keyNumbers {
            for i in 0..<self.keyLength {
                byte.insert(Byte(random()%0xFF), atIndex: i)
            }
            self.key.append(NSData(bytes: byte, length: self.keyLength))
            byte.removeAll(keepCapacity: false)
        }
    }
    
    func generateInitVector() {
        let time = Int(Double(NSDate().timeIntervalSince1970)*100000) & 0xFFFF
        var byte = [Byte()]
        
        srandom(UInt32(time))
        for i in 0..<self.initVectorLength {
            byte.insert(Byte(random()%0xFF), atIndex: i)
        }
        
        self.iVec = NSData(bytes: byte, length: self.initVectorLength)
    }
    
    func addPadding(data: NSData) -> NSData {
        // calculate 8Bytes-aligned length
        var alignedLength: Int
        if data.length % self.paddingLength != 0 {
            alignedLength = (data.length / self.paddingLength) * self.paddingLength + self.paddingLength
        } else {
            alignedLength = data.length
        }
        
        // copy data to append dummy
        var tempData = NSMutableData(data: data)
        
        if alignedLength > data.length {
            // create dummy that consist of zero
            var dummyLength = alignedLength - data.length
            let dummyBuffer = UnsafeMutablePointer<CUnsignedChar>.alloc(dummyLength)
            dummyBuffer.initialize(0)
            
            // append dummy
            while(dummyLength>0){
                tempData.appendBytes(dummyBuffer, length: 1)
                dummyLength--
            }
            
            dummyBuffer.dealloc(dummyLength)
        }
        
        return tempData as NSData
    }
    
    func reducePadding(data: NSData) -> NSData {
        var dummyLength = 0
        let dummyBuffer = UnsafeMutablePointer<CUnsignedChar>.alloc(data.length)
        
        // check dummy bytes
        data.getBytes(dummyBuffer, length: data.length)
        
        for i in (data.length-self.paddingLength)..<data.length {
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
    
    // override this functions
    func encrypt(plain: NSData)->NSData {
        return NSData()
    }
    
    func decrypt(cipher: NSData)->NSData {
        return NSData()
    }
}
