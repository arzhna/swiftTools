//
//  AolHash.swift
//
//  Created by Arzhna Lee on 2014. 8. 22.
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Foundation

class AolHash {
    
    class func hashUsingSha256(msg: NSData)-> NSData {
        
        let hashedLength = 64
        
        // create buffer
        var hashedData = UnsafeMutablePointer<CUnsignedChar>.alloc(hashedLength)
        hashedData.initialize(0)
        
        // convert to ctype from nsdata
        let orgData = UnsafeMutablePointer<CUnsignedChar>(msg.bytes)
        
        // hash
        sha256(orgData, hashedData)
        
        // convert decrypted data to nsdata from ctype
        var result = NSData(bytes: hashedData, length: hashedLength)

        //dealloc buffer
        hashedData.dealloc(hashedLength)
        
        return result
    }
}