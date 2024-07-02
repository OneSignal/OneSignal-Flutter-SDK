//
//  ExampleWidgetBundle.swift
//  ExampleWidget
//
//  Created by Brian Smith on 4/30/24.
//  Copyright © 2024 The Chromium Authors. All rights reserved.
//

import WidgetKit
import SwiftUI

#if !targetEnvironment(macCatalyst)
@main
struct ExampleWidgetBundle: WidgetBundle {
    var body: some Widget {
        ExampleWidgetLiveActivity()
    }
}
#endif
