//
//  Backport+Toolbar.swift
//  
//
//  Created on 9/2/23.
//

import SwiftUI

public extension Backport where Content: View {
    
    enum BackportVisibility {
        case automatic, visible, hidden
        
        @available(iOS 15.0, *)
        var toOriginal: SwiftUI.Visibility {
            switch self {
            case .automatic: return .automatic
            case .visible: return .visible
            case .hidden: return .hidden
            }
        }
    }
    
    enum BackportToolbarPlacement {
        case automatic, bottomBar, navigationBar, tabBar
        
        @available(iOS 16.0, *)
        var toOriginal: SwiftUI.ToolbarPlacement {
            switch self {
            case .automatic: return .automatic
            case .bottomBar: return .bottomBar
            case .navigationBar: return .navigationBar
            case .tabBar: return .tabBar
            }
        }
    }
    
    @ViewBuilder
    func toolbarBackground(_ visibility: BackportVisibility, for bars: BackportToolbarPlacement) -> some View {
        if #available(iOS 16.0, *) {
            content.toolbarBackground(visibility.toOriginal, for: bars.toOriginal)
        } else {
            content
        }
    }
    
    @ViewBuilder
    func toolbarBackground<S>(_ style: S, for bars: BackportToolbarPlacement) -> some View where S : ShapeStyle {
        if #available(iOS 16.0, *) {
            content.toolbarBackground(style, for: bars.toOriginal)
        } else {
            content
        }
    }

}
