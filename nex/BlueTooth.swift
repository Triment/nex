//
//  BlueTooth.swift
//  nex
//
//  Created by triment on 2022/6/8.
//

import Foundation
import CoreBluetooth
import Printer
import UIKit



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
    @Published var currentCharacteristic: CBCharacteristic!//当前注册的服务
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
        print(advertisementData)
        print(RSSI)
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
            print(service.uuid)
            if service.uuid == CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455"){
                print("电源通用")
                peripheral.discoverCharacteristics(nil, for: service)//触发特征发现
            }
            
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
            if characteristic.uuid == CBUUID(string: "49535343-1E4D-4BD9-BA61-23C647249616"){
                rxCharacteristic = characteristic
                currentPeripheral?.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid == CBUUID(string: "49535343-8841-43F4-A8D4-ECBE34729BB3"){
                currentPeripheral?.setNotifyValue(true, for: characteristic)
                txCharacteristic = characteristic
            }
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
            if CBUUID(string: "0x2A19") == characteristic.uuid {
                print("电池状态")
                currentPeripheral?.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?){
        print("通知", characteristic.value)
    }
    
    //接受外设通知
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        var value = [UInt8](characteristic.value!)
        print("value",value)
    }
    
    func sendCommand(cmd: [Data]){
//        for i in cmd {
//            print([UInt8](i))
//        }
        //currentPeripheral?.writeValue(<#T##data: Data##Data#>, for: <#T##CBDescriptor#>)
        //var payload = Data(cmd)
        //var setGBK:[UInt8] = [27, 64,255, 254, 49, 0, 50, 0, 51, 0, 27, 74, 70]
        //currentPeripheral?.writeValue(Data(setGBK), for: txCharacteristic,type: .withResponse)
//        print(cmd)
//        currentPeripheral?.writeValue(Data([0xc1,0xd6,0xd6,0xbe,0xec,0xc5]), for: txCharacteristic,type: .withResponse)
        for i in cmd {
            currentPeripheral?.writeValue(i, for: txCharacteristic, type: .withResponse)
        }
        currentPeripheral?.writeValue(Data([12]), for: txCharacteristic, type: .withResponse)
    }
    
    func printContent(_ content: String) {
        var tick = Ticket(
            .title(content),
            .blank(2),
            .kv(k: "署名", v: "林帅")
            
        )
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(1586))
        let gbk = String.Encoding(rawValue: encoding)
        sendCommand(cmd: tick.data(using: gbk))
    }
    /**
     49535343-FE7D-4AE5-8FA9-9FAFD205E455
     Device Information
     444E414C-4933-4543-AE2E-F30CB91BB70D
     */
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
