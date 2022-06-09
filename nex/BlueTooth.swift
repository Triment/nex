//
//  BlueTooth.swift
//  nex
//
//  Created by triment on 2022/6/8.
//

import Foundation
import CoreBluetooth


//蓝牙服务uuid

struct CBUUIDs{

    static let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

}

class BlueToothManger: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate ,ObservableObject {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {//外设完成更新状态调用
        
    }
    
    @Published var centralManager:CBCentralManager?//扫描、发现、连接、管理外设
    @Published var Peripherals: [CBPeripheral] = []//centeralManger发现的外设,这个对象可以发现外设上的服务和特性，服务本身可以包含其他服务的引用
    @Published var currentPeripheral: CBPeripheral?
    @Published var currentBlueToothState: String?
    @Published var txCharacteristic: CBCharacteristic!//发送特征
    @Published var rxCharacteristic: CBCharacteristic!//接受特征
    //@Published var currentPeripheralDelegate: BlueToothPeripheralDelegateManger//外设代理
    func centralManagerDidUpdateState(_ central: CBCentralManager) {//更新状态
        switch central.state {
          case .poweredOff:
            currentBlueToothState = "未打开"
          case .poweredOn:
            currentBlueToothState = "已开启"
            startScan()//开机自动扫描
          case .unsupported:
            currentBlueToothState = "不支持"
          case .unauthorized:
            currentBlueToothState = "未验证"
          case .unknown:
            currentBlueToothState = "未知"
          case .resetting:
            currentBlueToothState = "重置"
          @unknown default:
            print("Error")
      }
    }
    
    //发现外设调用
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print("Peripheral Discovered: \(peripheral)")
//        print("Peripheral name: \(peripheral.name)")
//        print ("Advertisement Data : \(advertisementData)")
        guard !Peripherals.contains(peripheral), let deviceName = peripheral.name, deviceName.count > 0 else {
            return
        }
        Peripherals.append(peripheral)
        print(peripheral.identifier)
        print(peripheral.description)
        print(peripheral.name as Any)
    }
    //连接蓝牙之后调用
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        currentPeripheral?.discoverServices(nil)//触发服务发现
    }
    //外设代理发现服务调用
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")

        if ((error) != nil) {
            print("服务发现出错: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        //发现服务的特征
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)//触发特征发现
        }
        print("发现服务: \(services)")
    }
    //扫描外设特性后调用
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        guard let characteristics = service.characteristics else {
          return
      }

        print("Found \(characteristics.count) characteristics.")

        for characteristic in characteristics {
            print("特性id\(characteristic.uuid)")
            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {
                rxCharacteristic = characteristic

                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                peripheral.readValue(for: characteristic)

                print("RX Characteristic: \(rxCharacteristic.uuid)")
            }

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
                txCharacteristic = characteristic
                print("TX Characteristic: \(txCharacteristic.uuid)")
            }
        }
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
        centralManager = CBCentralManager(delegate: self, queue: nil)//初始化中心管理器、、queue为事件调度队列，nil表示使用主调度
    }
    
    func connect(peripheral: CBPeripheral){
        currentPeripheral = peripheral
        centralManager?.connect(currentPeripheral!)//连接外设
        centralManager?.stopScan()
        currentPeripheral?.delegate = self
    }
    
    func startScan() -> Void {
        centralManager?.scanForPeripherals(withServices: [])//扫描指定服务条件
    }
}
