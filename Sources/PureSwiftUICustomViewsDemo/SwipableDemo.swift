//
//  SwipableDemo.swift
//  Houseclip
//
//  Created by Yuki Chiba on 7/22/20.
//  Copyright © 2020 KICONIA WORKS. All rights reserved.
//

import SwiftUI

struct SwipableDemoView: View{
    @State var swiped1: Bool = false
    @State var swiping1: CGFloat = 0.0
    var body: some View {
        VStack{
            Swipable {
                Text("Swip me!!")
            }
            .monitor(swipedMonitor: SwipedMonitor(monitoringDirection: .ANY,
                                                  targetDistance: 50,
                                                  allowSubDirection: true,
                                                  handleSwiped: {self.swiped1 = true},
                                                  handleNotSwiped: {}))
                .monitor(swipingMonitor: SwipingMonitor(monitoringDirection: .POSITIVE_X,
                                                        targetDistance: 100,
                                                        allowSubDirection: false,
                                                        handle: {v in self.swiping1 = v}))
            if swiped1{
                Text("Swiped1")
            }
            else{
                Text("Not Swiped1")
            }
            
            Text("Swiping1 \(swiping1)")
        }
    }
}

struct SwipableDemo_Previews: PreviewProvider {
    static var previews: some View {
        SwipableDemoView()
    }
}
