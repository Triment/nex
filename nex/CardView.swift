//
//  CardView.swift
//  nex
//
//  Created by triment on 2022/6/9.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct CardView:View {
    let peripheral: CBPeripheral
    let action: ()->Void
    @State var state: String = "connect"
    var body: some View {
        HStack{
            VStack (alignment: .leading) {
                Text(peripheral.name!)
                    .font(.title2)
                    .foregroundColor(.purple)
                Text("\(peripheral.identifier)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(state){
                changeState()
            }
        }
        .padding(10)
        .frame(height: 60)
    }
    func changeState() {
        action()
        guard state != "disconnect" else {
            state = "connect"
            return
        }
        state = "disconnect"
    }

}
