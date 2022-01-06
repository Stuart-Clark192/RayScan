//
//  RayScanViewModel.swift
//  RayScan
//
//  Created by Stuart Clark on 23/12/2021.
//

import Foundation
import SwiftUI

class RayScanViewModel: ObservableObject {
    
    @Published var ray: Ray
    var walls: [Wall] = []
    
    init() {
        
        ray = Ray(pos: Vector2(100, 200), dir: Vector2(1, 0))
        
        walls.append(Wall(from: Vector2(600, 200), to: Vector2(600, 400)))
        walls.append(Wall(from: Vector2(450, 100), to: Vector2(500, 130)))
        walls.append(Wall(from: Vector2(500, 200), to: Vector2(500, 400)))
        walls.append(Wall(from: Vector2(200, 100), to: Vector2(400, 100)))
    }
    
    func updateRayPos(newPos: Vector2, screenSize: CGSize) {
        
        let correctedVector = Vector2(newPos.x, Float(screenSize.height) - newPos.y)
        ray.pos = correctedVector
        objectWillChange.send()
    }
    
    func lookAt(newDir: Vector2, screenSize: CGSize) {
        let correctedY = Float(screenSize.height) - newDir.y
        let correctedVector = Vector2(newDir.x - ray.pos.x, correctedY - ray.pos.y)
        ray.dir = correctedVector.normalized()
        objectWillChange.send()
    }
    
    func drawRay() -> some View {
        
        return ray.draw(toVector: test())
    }
    
    func test() -> Vector2? {
        
        var closest: Vector2?
        var smallestU: Float = 99999999999.0
        
        for wall in walls {
            
            
            let x1 = wall.from.x
            let y1 = wall.from.y
            let x2 = wall.to.x
            let y2 = wall.to.y
            
            let x3 = ray.pos.x
            let y3 = ray.pos.y
            let x4 = ray.pos.x + (ray.dir.x)
            let y4 = ray.pos.y + (ray.dir.y)
            
            let denominator = ((x1 - x2) * (y3 - y4)) - ((y1 - y2) * (x3 - x4))
            
            if denominator == 0 {
                
                // Our lines are perfectly parallel
                return nil
            }
            
            let t = (((x1 - x3) * (y3 - y4)) - ((y1 - y3) * (x3 - x4))) / denominator
            let u = (((x1 - x3) * (y1 - y2)) - ((y1 - y3) * (x1 - x2))) / denominator
            
            if t > 0 && t < 1 && u > 0 {
                let intersectX = (x1 + t * (x2 - x1))
                let intersectY = (y1 + t * (y2 - y1))
                
                if u < smallestU {
                    smallestU = u
                    closest = Vector2(intersectX, intersectY)
                }
            }
        }
        return closest
    }
}

class Ray: ObservableObject {
    var pos: Vector2
    var dir: Vector2
    
    init(pos: Vector2, dir: Vector2) {
        self.pos = pos
        self.dir = dir
    }
    
    func draw() -> some View {
        let to = Vector2(pos.x + (dir.x * 10), pos.y + (dir.y * 10))
        return Path { path in
            path.move(to: CGPoint(x: CGFloat(pos.x), y: CGFloat(pos.y)))
            path.addLine(to: CGPoint(x: CGFloat(to.x), y: CGFloat(to.y)))
        }.stroke(Color.white, lineWidth: 1)
    }
    
    func draw(toVector: Vector2?) -> some View {
        let to = toVector ?? Vector2(pos.x + (dir.x * 10), pos.y + (dir.y * 10))
        return Path { path in
            path.move(to: CGPoint(x: CGFloat(pos.x), y: CGFloat(pos.y)))
            path.addLine(to: CGPoint(x: CGFloat(to.x), y: CGFloat(to.y)))
        }.stroke(Color.white, lineWidth: 1)
    }
}

struct Wall: Identifiable {
    var id: UUID = UUID()
    let from: Vector2
    let to: Vector2
    
    func draw() -> some View {
        Path { path in
            path.move(to: CGPoint(x: CGFloat(from.x), y: CGFloat(from.y)))
            path.addLine(to: CGPoint(x: CGFloat(to.x), y: CGFloat(to.y)))
        }.stroke(Color.white, lineWidth: 1)
    }
}
