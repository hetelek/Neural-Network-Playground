import Foundation

extension Double {
    static func random(mean: Float = 0, deviation: Float = 1) -> Double {
        return Double(arc4random_uniform(200)) / 200.0
    }
}
