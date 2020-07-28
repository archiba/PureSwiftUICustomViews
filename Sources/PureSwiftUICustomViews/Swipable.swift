//
//  Swipable.swift
//  Houseclip
//
//  Created by Yuki Chiba on 7/21/20.
//  Copyright © 2020 KICONIA WORKS. All rights reserved.
//

import SwiftUI


enum SwipeDirection
{
    case ANY
    case X
    case Y
    case POSITIVE_X
    case NEGATIVE_X
    case POSITIVE_Y
    case NEGATIVE_Y
}

func calcPrimaryDirection(x: CGFloat, y: CGFloat)
    -> SwipeDirection
{
    let absX = abs(x)
    let absY = abs(y)
    if absX == absY {
        return .ANY
    }
    
    if absX > absY {
        if x < 0 {
            return .NEGATIVE_X
        }
        return .POSITIVE_X
    }
    
    if y < 0 {
        return .NEGATIVE_Y
    }
    return .POSITIVE_Y
}

func isDirectionMatch(primary: SwipeDirection, target: SwipeDirection)
    -> Bool
{
    switch target {
    case .ANY:
        return true
    case .X:
        return (primary == .POSITIVE_X) || (primary == .NEGATIVE_X)
    case .Y:
        return (primary == .POSITIVE_Y) || (primary == .NEGATIVE_Y)
    default:
        return primary == target
    }
}

func distanceForDirection(direction: SwipeDirection,
                          x: CGFloat,
                          y: CGFloat)
    -> CGFloat
{
    switch direction {
    case .ANY:
        return sqrt(pow(x, 2) + pow(y, 2))
    case .X:
        return abs(x)
    case .Y:
        return abs(y)
    case .POSITIVE_X:
        return max(0, x)
    case .NEGATIVE_X:
        return max(0, -x)
    case .POSITIVE_Y:
        return max(0, y)
    case .NEGATIVE_Y:
        return max(0, -y)
    }
}

protocol OnSwipedDelegate: AnyObject
{
    func handleSwiped()
}

protocol OnSwipingDelegate: AnyObject
{
    func handleSwiping(progress: CGFloat)
}

struct SwipedMonitor
{
    var monitoringDirection: SwipeDirection
    var targetDistance: CGFloat
    var allowSubDirection: Bool
    
    var handleSwiped: () -> Void
    var handleNotSwiped: () -> Void
    
    func update(x: CGFloat, y: CGFloat)
    {
        let primaryDirection = calcPrimaryDirection(x: x, y: y)
        if !allowSubDirection &&
            !isDirectionMatch(primary: primaryDirection, target: monitoringDirection)
        {
            self.handleNotSwiped()
            return
        }
        
        let distance = distanceForDirection(direction: monitoringDirection,
                                            x: x,
                                            y: y)
        if distance < targetDistance {
            self.handleNotSwiped()
            return
        }
        self.handleSwiped()
    }
}

struct SwipingMonitor
{
    var monitoringDirection: SwipeDirection
    var targetDistance: CGFloat
    var allowSubDirection: Bool
    var handle: (CGFloat) -> Void
    
    func update(x: CGFloat, y: CGFloat)
    {
        let primaryDirection = calcPrimaryDirection(x: x, y: y)
        if !allowSubDirection &&
            !isDirectionMatch(primary: primaryDirection, target: monitoringDirection)
        {
            self.handle(0.0)
        }
        
        let distance = distanceForDirection(direction: monitoringDirection,
                                            x: x,
                                            y: y)
        
        self.handle(min(1.0, distance / targetDistance))
    }
}

class SwipingMonitors
{
    var monitors: [SwipingMonitor]
    
    init(monitors: [SwipingMonitor])
    {
        self.monitors = monitors
    }
    
    func update(start: CGPoint, current: CGPoint)
    {
        let x = current.x - start.x
        let y = current.y - start.y
        for monitor in monitors {
            monitor.update(x: x, y: y)
        }
    }
}

class SwipedMonitors
{
    var monitors: [SwipedMonitor]
    
    init(monitors: [SwipedMonitor])
    {
        self.monitors = monitors
    }
    
    func update(start: CGPoint, current: CGPoint)
    {
        let x = current.x - start.x
        let y = current.y - start.y
        for monitor in monitors {
            monitor.update(x: x, y: y)
        }
    }
}

@available(iOS 13.0, *)
struct Swipable<Content: View>: View {
    
    var content: Content
    var minimumDistance: CGFloat = 0
    var coordinateSpace: CoordinateSpace = .global
    
    var swipedMonitors: SwipedMonitors
    var swipingMonitors: SwipingMonitors
    
    init(_ content: () -> Content) {
        self.content = content()
        self.swipedMonitors = SwipedMonitors(monitors: [])
        self.swipingMonitors = SwipingMonitors(monitors: [])
    }
    
    init(minimumDistance: CGFloat,
         coordinateSpace: CoordinateSpace,
         _ content: () -> Content)
    {
        self.content = content()
        self.minimumDistance = minimumDistance
        self.coordinateSpace = coordinateSpace
        self.swipedMonitors = SwipedMonitors(monitors: [])
        self.swipingMonitors = SwipingMonitors(monitors: [])
    }
    
    init(minimumDistance: CGFloat,
         coordinateSpace: CoordinateSpace,
         swipedMonitors: [SwipedMonitor],
         swipingMonitors: [SwipingMonitor],
         _ content: () -> Content)
    {
        self.content = content()
        self.minimumDistance = minimumDistance
        self.coordinateSpace = coordinateSpace
        self.swipedMonitors = SwipedMonitors(monitors: swipedMonitors)
        self.swipingMonitors = SwipingMonitors(monitors:swipingMonitors)
    }
    
    var body: some View {
        content
            .highPriorityGesture(DragGesture(minimumDistance: minimumDistance,
                                             coordinateSpace: coordinateSpace)
                .onChanged({ (value) in
                    self.swipingMonitors.update(start: value.startLocation, current: value.location)
                })
                .onEnded({ (value) in
                    self.swipedMonitors.update(start: value.startLocation, current: value.location)
                })
        )
    }
    
    func monitor(swipedMonitor: SwipedMonitor)
        -> Swipable
    {
        var monitors = self.swipedMonitors.monitors
        monitors.append(swipedMonitor)
        return Swipable(minimumDistance: self.minimumDistance,
                        coordinateSpace: self.coordinateSpace,
                        swipedMonitors: monitors,
                        swipingMonitors: self.swipingMonitors.monitors,
                        {self.content})
    }
    
    func monitor(swipingMonitor: SwipingMonitor)
        -> Swipable
    {
        var monitors = self.swipingMonitors.monitors
        monitors.append(swipingMonitor)
        return Swipable(minimumDistance: self.minimumDistance,
                        coordinateSpace: self.coordinateSpace,
                        swipedMonitors: self.swipedMonitors.monitors,
                        swipingMonitors: monitors,
                        {self.content})
    }
}
