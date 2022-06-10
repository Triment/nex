//
//  ContentView.swift
//  nex
//
//  Created by triment on 2022/6/8.
//

import SwiftUI
import CoreBluetooth


struct ListItemView: View {
    let peripheral: CBPeripheral
    let centralManger: CBCentralManager
    let bluetoothManger: BlueToothManger
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                Text(peripheral.name!)
                    .font(.title)
                Text("\(peripheral.identifier)")
                    .font(.subheadline)
            }
            Button("选中"){
                centralManger.connect(peripheral)
                bluetoothManger.currentPeripheral = peripheral
            }
        }
        .padding()
    }
    init(item: CBPeripheral, delegate: BlueToothManger){
        peripheral = item
        centralManger = delegate.centralManager!
        bluetoothManger = delegate
    }
}

enum Action: String{
    case Connect, Disconnect
}

struct ContentView: View {
    @StateObject var bleDevice: BlueToothManger = BlueToothManger()
    func changeConnect(ble: BlueToothManger, peripheral: CBPeripheral) -> Void {
        switch peripheral.state {
        case .connected:
            ble.centralManager?.cancelPeripheralConnection(peripheral)
        case .disconnected:
            ble.connect(peripheral: peripheral)
        @unknown default:
            return
        }
    }
    var body: some View {
        VStack {
            List (bleDevice.Peripherals, id: \.identifier) {item in
                CardView(peripheral: item, action: {changeConnect(ble: bleDevice, peripheral: item)})//连接action
                //ListItemView(item: item, delegate: bleDevice)
            }
            Button("search") {
                bleDevice.centralManager?.scanForPeripherals(withServices: nil)
            }
        }
    }
}
