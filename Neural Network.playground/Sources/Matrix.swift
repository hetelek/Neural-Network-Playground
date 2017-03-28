import Foundation

public class Matrix: ExpressibleByArrayLiteral, CustomStringConvertible, Collection {
    // MARK: - Properties
    private(set) var elements: [[Double]]
    public var rows: Int { return elements.count }
    public var columns: Int { return elements[0].count }
    
    
    // MARK: - Intializers
    required public init(arrayLiteral elements: [Double]...) {
        self.elements = elements
    }
    
    public init(elements: [[Double]]) {
        self.elements = elements
    }
    
    public init(rows: Int, columns: Int, repeating: Double) {
        let innerArray = Array<Double>(repeating: repeating, count: columns)
        self.elements = Array<Array<Double>>(repeating: innerArray, count: rows)
    }
    
    public init(rows: Int, columns: Int) {
        let innerArray = Array<Double>(repeating: 0, count: columns)
        elements = Array<Array<Double>>(repeating: innerArray, count: rows)
        
        for row in 0..<rows {
            for col in 0..<columns {
                elements[row][col] = Double.randomNormal()
            }
        }
    }
    
    
    // MARK: - Operation funcations
    public func elementMap(transform: (Double) -> Double) -> Matrix {
        return Matrix.applyOperation(lhs: self, operation: transform)
    }
    
    public func elementwiseProduct(matrix: Matrix) -> Matrix {
        return Matrix.applyOperation(lhs: self, rhs: matrix, operation: *)
    }
    
    public func sum() -> Double {
        var sum: Double = 0
        
        for row in 0..<rows {
            sum += elements[row].reduce(0, +)
        }
        
        return sum
    }
    
    public func max() -> (value: Double, row: Int, column: Int) {
        // inital values
        var value: Double = 0
        var valueRow = -1
        var valueColumn = -1
        
        // loop through each value, update when we hit a new max
        for row in 0..<rows {
            for col in 0..<columns {
                let newValue = self[row][col]
                if newValue > value {
                    value = newValue
                    valueRow = row
                    valueColumn = col
                }
            }
        }
        
        return (value, valueRow, valueColumn)
    }
    
    
    // MARK: - Operators
    static private func applyOperation(lhs: Matrix, rhs: Matrix, operation: (Double, Double) -> Double) -> Matrix {
        assert(lhs.rows == rhs.rows)
        assert(lhs.columns == rhs.columns)
        
        var elements: [[Double]] = lhs.elements
        for row in 0..<lhs.rows {
            for col in 0..<lhs.columns {
                elements[row][col] = operation(elements[row][col], rhs.elements[row][col])
            }
        }
        
        return Matrix(elements: elements)
    }
    
    static private func applyOperation(lhs: Matrix, operation: (Double) -> Double) -> Matrix {
        var elements: [[Double]] = lhs.elements
        for row in 0..<lhs.rows {
            for col in 0..<lhs.columns {
                elements[row][col] = operation(elements[row][col])
            }
        }
        
        return Matrix(elements: elements)
    }
    
    static public func +(lhs: Matrix, rhs: Matrix) -> Matrix {
        return applyOperation(lhs: lhs, rhs: rhs, operation: +)
    }
    
    static public func -(lhs: Matrix, rhs: Matrix) -> Matrix {
        return applyOperation(lhs: lhs, rhs: rhs, operation: -)
    }
    
    static public func /(lhs: Matrix, rhs: Matrix) -> Matrix {
        return applyOperation(lhs: lhs, rhs: rhs, operation: /)
    }
    
    static public func *(lhs: Matrix, rhs: Matrix) -> Matrix {
        assert(lhs.columns == rhs.rows)
        
        let elements = Matrix(rows: lhs.rows, columns: rhs.columns, repeating: 0)
        for row in 0..<elements.rows {
            for col in 0..<elements.columns {
                
                var products = lhs[row]
                for lhCol in 0..<products.count {
                    products[lhCol] *= rhs[lhCol][col]
                }
                
                elements[row][col] = products.reduce(0, +)
            }
        }
        
        return elements
    }
    
    static public func +(lhs: Matrix, rhs: Double) -> Matrix {
        return applyOperation(lhs: lhs) { $0 + rhs }
    }
    
    static public func -(lhs: Matrix, rhs: Double) -> Matrix {
        return applyOperation(lhs: lhs) { $0 - rhs }
    }
    
    static public func /(lhs: Matrix, rhs: Double) -> Matrix {
        return applyOperation(lhs: lhs) { $0 / rhs }
    }
    
    static public func *(lhs: Matrix, rhs: Double) -> Matrix {
        return applyOperation(lhs: lhs) { $0 * rhs }
    }
    
    static public func ^(lhs: Matrix, rhs: Double) -> Matrix {
        return applyOperation(lhs: lhs) { pow($0, rhs) }
    }
    
    public func transpose() -> Matrix {
        let transposed = Matrix(rows: columns, columns: rows, repeating: 0)
        for row in 0..<rows {
            for col in 0..<columns {
                transposed[col][row] = self[row][col]
            }
        }
        
        return transposed
    }
    
    // MARK: - Collection conformance
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return rows }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    public subscript(position: Int) -> [Double] {
        get {
            return self.elements[position]
        }
        set {
            assert(newValue.count == columns)
            self.elements[position] = newValue
        }
    }
    
    
    // MARK: - CustomStringConvertible conformance
    public var description: String {
        get {
            let strings: [String] = elements.map { (doubles) -> String in
                
                let doublesAsString = doubles.map({ (double) -> String in
                    if double >= 0 {
                        return String(format: "%.5f", double)
                    }
                    return String(format: "%.4f", double)
                })
                
                return doublesAsString.joined(separator: " ")
            }
            
            let formattedElements = strings.joined(separator: "\n  ")
            return "[ " + formattedElements + " ]"
        }
    }
}
