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

struct ContentView: View {
    @ObservedObject var bleDevice: BlueToothManger = BlueToothManger()
    var body: some View {
        VStack {
            List (bleDevice.Peripherals, id: \.identifier) {item in
                ListItemView(item: item, delegate: bleDevice)
            }
        }
        Button("print") {
            bleDevice.centralManager?.cancelPeripheralConnection(bleDevice.currentPeripheral!)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
