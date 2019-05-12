import Foundation

extension UInt16 {
    init(randomIn range: CountableClosedRange<Int>) {
        self = UInt16(arc4random_uniform(UInt32(UInt16(range.upperBound - range.lowerBound)))) + UInt16(range.lowerBound)
    }
}

extension Bool {
    static func random(likelyHoodPercentage: Int = 50) -> Bool {
        precondition(likelyHoodPercentage >= 0 && likelyHoodPercentage <= 100)

        return UInt16(likelyHoodPercentage) >= UInt16(randomIn: 1...100)
    }
}

extension UInt16 {
    init(bits: [Bool]) {
        var number: UInt16 = 0
        var exponent: UInt16 = 0

        for bit in bits.reversed() {
            let bitValue: UInt16 = bit ? 1 : 0
            number += bitValue * UInt16(pow(2, Float(exponent)))

            exponent += 1
        }

        self = number
    }

    var numberOfSetBits: Int {
        var count: Int = 0
        var number = self

        while number > 0 {
            if number.lastBit == 1  {
                count += 1
            }

            number >>= 1
        }

        return count
    }

    var lastBit: UInt16 {
        return self & 1
    }

    public static var numberOfBits: Int {
        return Int(log2(Double(UInt16.max)))
    }

    func numberOfBitsEqual(in number: UInt16) -> Int {
        var count: Int = 0

        for (lhs, rhs) in zip(self.bits, number.bits) {
            if lhs == rhs {
                count += 1
            }
        }

        return count
    }

    var bits: [Bool] {
        var bits: [Bool] = []

        var number = self
        var allOnes = UInt16.max

        while allOnes > 0 {
            let newBit: Bool

            if number > 0 {
                newBit = number.lastBit == allOnes.lastBit

                number >>= 1
            }
            else {
                newBit = false
            }

            bits.insert(newBit, at: 0)

            allOnes >>= 1
        }

        return bits
    }

    public var asBinaryString: String {
        return self.bits.map { $0 ? "1" : "0" }.joined(separator: "")
    }
}
