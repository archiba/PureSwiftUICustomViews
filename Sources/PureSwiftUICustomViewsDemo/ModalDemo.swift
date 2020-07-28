//
//  ModalDemo.swift
//  Houseclip
//
//  Created by Yuki Chiba on 7/28/20.
//  Copyright © 2020 KICONIA WORKS. All rights reserved.
//

import SwiftUI


struct ModalDemo: View {
    @ObservedObject var visible: ModalVisible
    
    var body: some View {
        ZStack{
            Button(action: {self.visible.show()}) {Text("Show")}
            
            Modal(visible: visible) { width, height in
                VStack(alignment: .leading){
                    Text("A")
                    Button(action: {}) {Text("Button")}}
                    .frame(width: width, height: height)
                    .background(Color.gray)
                    .shadow(radius: 10)}
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ModalDemo_Previews: PreviewProvider {
    static var previews: some View {
        let visible = ModalVisible()
        return ModalDemo(visible: visible)
    }
}
