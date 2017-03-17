import Foundation

extension Double {
    // FROM: http://mathworld.wolfram.com/Box-MullerTransformation.html
    static func randomNormal() -> Double {
        var value: Double = 0
        
        let random1 = Double(arc4random()) / Double(UInt32.max)
        let random2 = Double(arc4random()) / Double(UInt32.max)
        
        let f1 = sqrt(-2 * log(random1))
        let f2 = 2 * M_PI * random2
        
        value = f1 * cos(f2)
        
        return value
    }
}
