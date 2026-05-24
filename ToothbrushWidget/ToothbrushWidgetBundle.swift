//
//  ToothbrushWidgetBundle.swift
//  ToothbrushWidget
//
//  Created by Kenshin Sasaki on 2026/05/24.
//

import WidgetKit
import SwiftUI

@main
struct ToothbrushWidgetBundle: WidgetBundle {
    var body: some Widget {
        ToothbrushWidget()
        ToothbrushWidgetControl()
        ToothbrushWidgetLiveActivity()
    }
}
