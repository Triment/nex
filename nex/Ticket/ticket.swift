//
//  ticket.swift
//  nex
//
//  Created by triment on 2022/6/15.
//

import Foundation



enum AtomType {
    case text
    case blank
    case image
    case qrCode
    case graph
}


struct Token {
    var type: AtomType
    var attributes: [[UInt8]]
    var mataData: [[UInt8]]
    
    static func Text(_ str: String, attr: [[UInt8]] = [[28,38]]) -> Token{
        return Token(type: .text, attributes: attr, mataData:[[UInt8](str.gbkData)])
    }
}

class Ticket: NSObject {
    private var tokens = [Token]()
    init(_ tokens: Token...) {
        self.tokens = tokens
    }
    
    func compute(_ tok:Token)->Data{
        switch tok.type {
        case .text:
            var data:[UInt8] = []
            for i in tok.attributes {
                for j in i {
                    data.append(j)
                }
            }
            for i in tok.mataData {
                for j in i {
                    data.append(j)
                }
            }
            data += [27,74,70]
            return Data(data)
        case .blank:
            return  Data()
        case .image:
            return  Data()
        case .qrCode:
            return  Data()
        case .graph:
            return  Data()
        }
    }
    
    func getBytes()->[Data]{
        var data = [Data]()
        for tok in tokens {
            data.append(compute(tok))
        }
        return data
    }
}
