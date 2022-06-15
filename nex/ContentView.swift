//
//  ContentView.swift
//  nex
//
//  Created by triment on 2022/6/8.
//

import SwiftUI
import CoreBluetooth



struct ContentView: View {
    @StateObject var BluetoothManger = BlueToothManger()
    
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
            List (BluetoothManger.Peripherals, id: \.identifier) {item in
                CardView(peripheral: item, action: {changeConnect(ble: BluetoothManger, peripheral: item)})//连接action
                //ListItemView(item: item, delegate: bleDevice)
            }
            Button("search") {
                BluetoothManger.centralManager?.scanForPeripherals(withServices: [])
            }
        }
    }
}
