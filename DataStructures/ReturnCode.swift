//
//  ErrorCode.swift
//  DataStructureLibs
//
//  Created by Arzhna Lee on 2014. 7. 22..
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

enum ReturnCode {
    case OK
    case GernricError
    case OutOfBound
    
    func description() -> String {
        switch self {
        case .OK:
            return "OK"
        case .GernricError:
            return "Generic Error"
        case .OutOfBound:
            return "Out Of Bound"
        }
    }
}
