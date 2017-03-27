import Foundation

extension Double {
    // FROM: http://mathworld.wolfram.com/Box-MullerTransformation.html
    public static func randomNormal() -> Double {
        let random1 = Double(arc4random()) / Double(UInt32.max)
        let random2 = Double(arc4random()) / Double(UInt32.max)
        
        let f1 = sqrt(-2 * log(random1))
        let f2 = 2 * M_PI * random2
        
        return f1 * cos(f2)
    }
    
    public func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
