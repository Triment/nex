//
//  PeripheralDelegate.swift
//  nex
//
//  Created by triment on 2022/6/10.
//

import Foundation
import CoreBluetooth

//外设代理
class BluetoothPeripheralDelegate: NSObject, CBPeripheralDelegate {
    
    private var servives: Set<String>!//外设服务
    private var characteristics: Set<CBUUID>?//特征uuid
    
    private(set) var writablePeripheral: CBPeripheral?
    private(set) var writableCharacteristic: CBCharacteristic? {
        didSet {
            
        }
    }
}
