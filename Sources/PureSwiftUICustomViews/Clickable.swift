//
//  Clickable.swift
//  Houseclip
//
//  Created by Yuki Chiba on 7/22/20.
//  Copyright © 2020 KICONIA WORKS. All rights reserved.
//

import SwiftUI

struct ClickMonitor
{
    var handleStart: () -> Void
    var handleEnd: () -> Void
}

struct ClickMonitors
{
    let monitors: [ClickMonitor]
    
    init(_ monitors: [ClickMonitor] = []) {
        self.monitors = monitors
    }
    
    public func handleStart() {
        for monitor in monitors {
            monitor.handleStart()
        }
    }
    
    public func handleEnd() {
        for monitor in monitors {
            monitor.handleEnd()
        }
    }
}

@available(iOS 13.0, *)
struct Clickable<Content: View>: View {
    
    var content : Content
    var clickMonitors: ClickMonitors = ClickMonitors()
    @State var tapped: Bool = false
    
    init(_ content: () -> Content)
    {
        self.content = content()
    }
    
    init(monitors: [ClickMonitor],
         _ content: () -> Content)
    {
        self.content = content()
        self.clickMonitors = ClickMonitors(monitors)
    }
    
    public func monitor(_ monitor: ClickMonitor)
        -> Clickable
    {
        var newMonitors = self.clickMonitors.monitors
        newMonitors.append(monitor)
        return Clickable(monitors: newMonitors){
            self.content
        }
    }
    
    var body: some View {
        self.content
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { (value) in
                if value {
                    self.clickMonitors.handleStart()
                    return
                }
                self.clickMonitors.handleEnd()
                return
            }) {
                //
            }
    }
}
