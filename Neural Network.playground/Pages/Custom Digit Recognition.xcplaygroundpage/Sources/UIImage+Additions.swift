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
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return newImage!
    }
    
    public func grayScalePixelIntensities() -> [Double] {
        var pixels: [Double] = []
        
        // First get the image into your data buffer
        guard let cgImage = cgImage else {
            print("CGContext creation failed")
            return []
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let pixelCount = width * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawdata = calloc(height * width * 4, MemoryLayout<CUnsignedChar>.size)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: rawdata, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("CGContext creation failed")
            return []
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Now your rawData contains the image data in the RGBA8888 pixel format.
        var byteIndex = 0
        for _ in 0..<pixelCount {
            let red = CGFloat(rawdata!.load(fromByteOffset: byteIndex, as: UInt8.self)) / 255.0
            let green = CGFloat(rawdata!.load(fromByteOffset: byteIndex + 1, as: UInt8.self)) / 255.0
            let blue = CGFloat(rawdata!.load(fromByteOffset: byteIndex + 2, as: UInt8.self)) / 255.0
            byteIndex += bytesPerPixel
            
            let pixel = Double(red + green + blue) / 3.0
            pixels.append(pixel)
        }
        
        free(rawdata)
        
        return pixels
    }
}
