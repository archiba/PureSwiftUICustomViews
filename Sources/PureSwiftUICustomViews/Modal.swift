//
//  CustomModal.swift
//  Houseclip
//
//  Created by Yuki Chiba on 7/28/20.
//  Copyright © 2020 KICONIA WORKS. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
class ModalVisible: ObservableObject
{
    @Published var visible: Bool = false
    
    public func show()
    {
        withAnimation{
            self.visible = true}
    }
    
    public func hide()
    {
        withAnimation{
            self.visible = false}
    }
}

@available(iOS 13.0, *)
struct Modal<Content: View>: View {
    
    @ObservedObject private var visible: ModalVisible
    @State var swipeProgress: Float = 0.0
    
    private var withStaticHeight: Bool
    private var heightRate: Float
    private var staticHeight: Float
    private var swipeSensitivity: Float
    
    private var content: (CGFloat, CGFloat) -> Content
    
    private func contentHeight(geometry: GeometryProxy) -> CGFloat{
        if withStaticHeight{
            return CGFloat(self.staticHeight)
        }
        return geometry.size.width * CGFloat(heightRate)
    }
    
    init(visible: ModalVisible,
         withStaticHeight: Bool = false,
         heightRate: Float = 0.6,
         staticHeight: Float = 100,
         swipeSensitivity: Float = 0.3,
         _ content: @escaping () -> Content) {
        self.visible = visible
        self.withStaticHeight = withStaticHeight
        self.heightRate = heightRate
        self.staticHeight = staticHeight
        self.swipeSensitivity = swipeSensitivity
        self.content = {(_: CGFloat, _: CGFloat) in content()}
    }
    
    init(visible: ModalVisible,
         withStaticHeight: Bool = false,
         heightRate: Float = 0.6,
         staticHeight: Float = 100,
         swipeSensitivity: Float = 0.3,
         _ content: @escaping (CGFloat, CGFloat) -> Content) {
        self.visible = visible
        self.withStaticHeight = withStaticHeight
        self.heightRate = heightRate
        self.staticHeight = staticHeight
        self.swipeSensitivity = swipeSensitivity
        self.content = content
    }
    
    var body: some View {
        GeometryReader { (geometry:GeometryProxy) in
            ZStack{
                Group{
                    if self.visible.visible{
                        Clickable{
                            Rectangle()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .background(Color.black)
                                .opacity(0.6)}
                            .monitor(ClickMonitor(handleStart: {},
                                                  handleEnd: {
                                                    self.visible.hide()}))}}
                VStack{
                    Spacer()
                    Swipable(minimumDistance: 10, coordinateSpace: .global){
                        ZStack{
                            Rectangle()
                                .opacity(0.01)
                            self.content(geometry.size.width, self.contentHeight(geometry: geometry))
                                .frame(width: geometry.size.width,
                                       height: self.contentHeight(geometry: geometry))
                        }}
                        .monitor(swipingMonitor: SwipingMonitor(monitoringDirection: .POSITIVE_Y,
                                                                targetDistance: self.contentHeight(geometry: geometry),
                                                                allowSubDirection: false,
                                                                handle: {v in
                                                                    self.swipeProgress = Float(v)}))
                        .monitor(swipedMonitor: SwipedMonitor(monitoringDirection: .POSITIVE_Y,
                                                              targetDistance: self.contentHeight(geometry: geometry) * CGFloat(self.swipeSensitivity),
                                                              allowSubDirection: false,
                                                              handleSwiped: {
                                                                self.visible.hide()
                                                                self.swipeProgress = 0.0},
                                                              handleNotSwiped: {
                                                                withAnimation{
                                                                    self.swipeProgress = 0.0}}))
                        .frame(width: geometry.size.width,
                               height: self.contentHeight(geometry: geometry))
                        .offset(y: self.visible.visible ? self.contentHeight(geometry: geometry) * CGFloat(self.swipeProgress) : self.contentHeight(geometry: geometry))
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

