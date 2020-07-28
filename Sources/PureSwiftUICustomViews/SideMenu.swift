//
//  SideMenu.swift
//  Houseclip
//
//  Created by Yuki Chiba on 7/28/20.
//  Copyright © 2020 KICONIA WORKS. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
class SideMenuVisible: ObservableObject
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
struct SideMenu<Content: View>: View {
    
    @ObservedObject private var visible: SideMenuVisible
    @State var swipeProgress: Float = 0.0
    
    private var withStaticWidth: Bool
    private var widthRate: Float
    private var staticWidth: Float
    private var swipeSensitivity: Float
    
    private var content: (CGFloat, CGFloat) -> Content
    
    private func contentWidth(geometry: GeometryProxy) -> CGFloat{
        if withStaticWidth{
            return CGFloat(self.staticWidth)
        }
        return geometry.size.width * CGFloat(widthRate)
    }
    
    init(visible: SideMenuVisible,
         withStaticWidth: Bool = false,
         widthRate: Float = 0.6,
         staticWidth: Float = 100,
         swipeSensitivity: Float = 0.3,
         _ content: @escaping () -> Content) {
        self.visible = visible
        self.withStaticWidth = withStaticWidth
        self.widthRate = widthRate
        self.staticWidth = staticWidth
        self.swipeSensitivity = swipeSensitivity
        self.content = {(_: CGFloat, _: CGFloat) in content()}
    }
    
    init(visible: SideMenuVisible,
         withStaticWidth: Bool = false,
         widthRate: Float = 0.6,
         staticWidth: Float = 100,
         swipeSensitivity: Float = 0.3,
         _ content: @escaping (CGFloat, CGFloat) -> Content) {
        self.visible = visible
        self.withStaticWidth = withStaticWidth
        self.widthRate = widthRate
        self.staticWidth = staticWidth
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
                HStack{
                    Swipable(minimumDistance: 10, coordinateSpace: .global){
                        ZStack{
                            Rectangle()
                                .opacity(0.01)
                            self.content(self.contentWidth(geometry: geometry), geometry.size.height)
                                .frame(width: self.contentWidth(geometry: geometry),
                                       height: geometry.size.height)
                        }}
                        .monitor(swipingMonitor: SwipingMonitor(monitoringDirection: .NEGATIVE_X,
                                                                targetDistance: self.contentWidth(geometry: geometry),
                                                                allowSubDirection: false,
                                                                handle: {v in
                                                                    self.swipeProgress = Float(v)}))
                        .monitor(swipedMonitor: SwipedMonitor(monitoringDirection: .NEGATIVE_X,
                                                              targetDistance: self.contentWidth(geometry: geometry) * CGFloat(self.swipeSensitivity),
                                                              allowSubDirection: false,
                                                              handleSwiped: {
                                                                self.visible.hide()
                                                                self.swipeProgress = 0.0},
                                                              handleNotSwiped: {
                                                                withAnimation{
                                                                    self.swipeProgress = 0.0}}))
                        .frame(width: self.contentWidth(geometry: geometry),
                               height: geometry.size.height)
                        .offset(x: self.visible.visible ? -self.contentWidth(geometry: geometry) * CGFloat(self.swipeProgress) : -self.contentWidth(geometry: geometry))
                    Spacer()}
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
