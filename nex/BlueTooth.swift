//
//  BlueTooth.swift
//  nex
//
//  Created by triment on 2022/6/8.
//

import Foundation
import CoreBluetooth

class BlueToothPeripheralDelegateManger: NSObject, CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        <#code#>
    }
    
    
}

class BlueToothManger: NSObject, CBCentralManagerDelegate, ObservableObject {
    @Published var centralManager:CBCentralManager?
    @Published var Peripherals: [CBPeripheral] = []
    @Published var currentPeripheral: CBPeripheral?
    @Published var currentPeripheralDelegate: BlueToothPeripheralDelegateManger
    func centralManagerDidUpdateState(_ central: CBCentralManager) {//更新状态
        switch central.state {
          case .poweredOff:
              print("Is Powered Off.")
          case .poweredOn:
              print("Is Powered On.")
              startScan()
          case .unsupported:
              print("Is Unsupported.")
          case .unauthorized:
          print("Is Unauthorized.")
          case .unknown:
              print("Unknown")
          case .resetting:
              print("Resetting")
          @unknown default:
            print("Error")
      }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard !Peripherals.contains(peripheral), let deviceName = peripheral.name, deviceName.count > 0 else {
            return
        }
        Peripherals.append(peripheral)
        print(peripheral.identifier)
        print(peripheral.description)
        print(peripheral.name as Any)
    }
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        switch event {
        case .peerDisconnected:
            print("断开")
        case .peerConnected:
            print("连接")
        @unknown default:
            print("未知")
        }
    }
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() -> Void {
        centralManager?.scanForPeripherals(withServices: nil)
    }
}
