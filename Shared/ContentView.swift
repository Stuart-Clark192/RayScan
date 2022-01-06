//
//  ContentView.swift
//  Shared
//
//  Created by Stuart Clark on 16/12/2021.
//

import SwiftUI
import simd

struct ContentView: View {
    
    
    @State private var fromX: CGFloat = 200
    @State private var fromY: CGFloat = 100
    @State private var imageSize: CGSize = .zero
    
    @ObservedObject private var viewModel = RayScanViewModel()
    
    var body: some View {
        
        ZStack {
            GeometryReader { geometry in
                
//                viewModel.ray.draw()
                viewModel.drawRay()
                ForEach(viewModel.walls) { wall in
                    wall.draw()
                }
                if let point = viewModel.test() {
                    drawIntersect(point: point)
                }
            }
        }.background(Color.black)
        .getSize {
            imageSize = $0
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged {
                    fromX = $0.location.x
                    fromY = $0.location.y
                }
            
        ).onAppear(perform: {
            NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
                fromX = $0.locationInWindow.x
                fromY = $0.locationInWindow.y
//                viewModel.updateRayPos(newPos: Vector2(Scalar(fromX), Scalar(fromY)), screenSize: imageSize)
                viewModel.lookAt(newDir: Vector2(Scalar(fromX), Scalar(fromY)), screenSize: imageSize)
                return $0
            }
        })
    }
    
    private func drawIntersect(point: Vector2) -> some View {
        return Circle()
            .fill(Color.blue)
            .position(x: CGFloat(point.x), y: CGFloat(point.y))
            .frame(width: 6, height: 6, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}

extension View {
    func getSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}
