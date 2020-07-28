//
//  ClickableDemo.swift
//  Houseclip
//
//  Created by Yuki Chiba on 7/22/20.
//  Copyright © 2020 KICONIA WORKS. All rights reserved.
//

import SwiftUI

struct ClickableDemoView : View {
    @State var text: String = "Nothing to display"
    var body: some View {
        Clickable<Text> {
            Text(text)
        }
        .monitor(ClickMonitor(handleStart: {self.text = "Tap started"},
                              handleEnd: {self.text = "Tap ended"}))
    }
}

struct ClickableDemo_Previews: PreviewProvider {
    static var previews: some View {
        ClickableDemoView()
    }
}
