//
//  SSLTestFunctions.swift
//
//  Created by  Arzhna on 2014. 8. 1.
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Foundation

func RsaTest(nTimes:Int){
    
    let plainText: NSString = "This is a secret message. I'm Arzhna Lee. I'm listening a song that is Chloe of Grouplove."
    var encryptedData = NSData()
    var decryptedData = NSData()

    //let resourcePath = "/Users/arzhna/Develop/swiftWorkspace/xmlParserTest/resources/"
    let resourcePath = "/Users/arzhna/Develop/git/hi-roo/xmlParserTest/resources/"
    var path: NSString

    // load keys
    path = NSBundle(path: resourcePath).pathForResource("pubkey", ofType: "data")
    let publicKey = NSData(contentsOfFile: path)
    
    path = NSBundle(path: resourcePath).pathForResource("privkey", ofType: "data")
    let privateKey = NSData(contentsOfFile: path)
    
    // generate AolRSA Instance
    let rsa = AolRSA(publicKey: publicKey, privateKey: privateKey)
    
    println("== RSA Test ==")
    println("Plain Text: \(plainText)\n")

    // 1st test
    println("== Encrypt using PublicKey, Decrypt using PrivateKey ==")
    
    // initialize counters and buffer
    var successCount = 0
    var failCount = 0
    var decryptedText = ""
    
    //start test
    for i in 0..<nTimes {
        // encrypt
        encryptedData = rsa.encrypt(plainText.dataUsingEncoding(NSASCIIStringEncoding), usingKey: .PublicKey)
        if encryptedData.length != 128 {
            failCount++
            continue
        }
        
        // decrypt
        decryptedData = rsa.decrypt(encryptedData, usingKey: .PrivateKey)
        if decryptedData.length != plainText.length {
            failCount++
            continue
        }
        
        // convert decrypted data to NSString type
        decryptedText = NSString(data: decryptedData, encoding: NSASCIIStringEncoding)
        
        // compare decrypted text and plain text
        if plainText == decryptedText {
            successCount++
        }else{
            print("!")
            failCount++
        }
        
        if i%100==0 {
            print(".")
        }
    }
    println("\n\(successCount) times success!! \(failCount) times fail!!")
    println("Decrypted Text: \(decryptedText)\n")
    
    // 2nd test
    println("== Encrypt using PrivateKey, Decrypt using PublicKey ==")
    
    // initialize counters and buffer
    successCount = 0
    failCount = 0
    decryptedText = ""
    
    //start test
    for i in 0..<nTimes {
        // encrypt
        encryptedData = rsa.encrypt(plainText.dataUsingEncoding(NSASCIIStringEncoding), usingKey: .PrivateKey)
        if encryptedData.length != 128 {
            failCount++
            continue
        }
        
        // decrypt
        decryptedData = rsa.decrypt(encryptedData, usingKey: .PublicKey)
        if decryptedData.length != plainText.length {
            failCount++
            continue
        }
        
        // convert decrypted data to NSString type
        decryptedText = NSString(data: decryptedData, encoding: NSASCIIStringEncoding)
        
        // compare decrypted text and plain text
        if plainText == decryptedText {
            successCount++
        }else{
            print("!")
            failCount++
        }
        
        if i%100==0 {
            print(".")
        }
    }
    
    // print result
    println("\n\(successCount) times success!! \(failCount) times fail!!")
    println("Decrypted Text : \(decryptedText)\n\n")
}

func DesTest(nTimes:Int) {
    
    let plain:NSString = "This is a secret message. I'm Arzhna Lee. I'm listening a song that is Chloe of Grouplove."
    var decryptedText = ""

    println("== DES Test ==")
    println("Plain Text : \(plain)")
    
    // generate AolDES Instance
    let des = AolDES()
    
    // initialize counters
    var successCount = 0
    var failCount = 0
    
    // test start
    for i in 0..<nTimes {
        // generate new initial vector
        des.generateInitVector()

        // encrypt
        let cipher = des.encrypt(plain.dataUsingEncoding(NSASCIIStringEncoding))
        if cipher.length != plain.length {
            failCount++
            continue
        }
        
        // decrypt
        let decrypted = des.decrypt(cipher)
        if decrypted.length != cipher.length {
            failCount++
            continue
        }
        
        // convert decrypted data to NSString type
        decryptedText = NSString(data: decrypted, encoding: NSASCIIStringEncoding)
        
        // compare decrypted text and plain text
        if decryptedText == plain {
            successCount++
        }else{
            print("!")
            failCount++
        }
        
        if i%100==0 {
            print(".")
        }
    }
    
    // print result
    println("\n\(successCount) times success!! \(failCount) times fail!!")
    println("Decrypted Text : \(decryptedText)")
}
