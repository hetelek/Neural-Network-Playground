import UIKit

public extension UIImage {
    public convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
    public func resize(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return newImage!
    }
    
    public func grayScalePixelIntensities() -> [Double] {
        var pixels: [Double] = []
        
        for row in 0..<Int(size.width) {
            for col in 0..<Int(size.height) {
                let (r, g, b) = self.getPixelColor(pos: CGPoint(x: row, y: col))
                print(Double(r))
                pixels.append(Double(r))
            }
        }
        
        return pixels
    }
    
    func getPixelColor(pos: CGPoint) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo])
        let g = CGFloat(data[pixelInfo + 1])
        let b = CGFloat(data[pixelInfo + 2])
        let a = CGFloat(data[pixelInfo + 3])
        
        return (r, g, b)
    }
}
