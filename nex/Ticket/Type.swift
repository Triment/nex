//
//  Type.swift
//  nex
//
//  Created by triment on 2022/6/16.
//

import Foundation

protocol Block {
    associatedtype MataData
    var x: Int { set get }
    var y: Int { set get }
    var left: Int { set get }
    var right: Int { set get }
    var bottom: Int { set get }
    var top: Int { set get }
    var mataData: Self.MataData { set get }
}

extension String {

    init?(gbkData: Data) {
        //获取GBK编码, 使用GB18030是因为它向下兼容GBK
        let cfEncoding = CFStringEncodings.GB_18030_2000

        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))

        //从GBK编码的Data里初始化NSString, 返回的NSString是UTF-16编码
        if let str = NSString(data: gbkData, encoding: encoding) {
            self = str as String
        } else {
            return nil
        }
    }

    var gbkData: Data {

        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        let gbkData = (self as NSString).data(using: encoding)!

        return gbkData
    }
}

enum AlignmentType: UInt8 {
    case left = 0, center, right
}

enum TextAttributeType {
    case bold(Bool)
    case scale(UInt8, UInt8)
    case underline
    case alignment(AlignmentType)
}

struct TextAttribute {
    var rawValue = [UInt8]()
    var printModel: UInt8 = 0
    init (_ attr: TextAttributeType...){
        rawValue = [27, 33, printModel]
        for attribute in attr {
            switch attribute {
            case let .bold(value):
                printModel += 8
                value ? rawValue += [27,33,printModel] : nil
            case let .scale(x, y):
                rawValue += [29,33]
                rawValue.append(((x-1)<<4)|(y-1))
            case .underline:
                printModel += 128
                rawValue += [27, 33, printModel]
            case let .alignment(align):
                rawValue += [27, 97, align.rawValue]
            }
        }
    }
}



struct PlainText {
    var content: String
    var attribute: [UInt8]
    init(_ str: String, attr: TextAttribute){
        self.content = str
        self.attribute = attr.rawValue
    }
}

struct TextBlock: Block {
    var x: Int
    
    var y: Int
    
    var left: Int
    
    var right: Int
    
    var bottom: Int
    
    var top: Int
    
    var mataData: PlainText
    
    typealias MataData = PlainText
    
    init(x: Int, y: Int, left: Int = 0, right: Int = 0, bottom: Int = 0, top: Int = 0, mataData: PlainText){
        self.x = x
        self.y = y
        self.left = left
        self.right = right
        self.bottom = bottom
        self.top = top
        self.mataData = mataData
    }
}


