// swift-tools-version: 5.7

import Foundation

public struct AlbertGaoSwift {
    public private(set) var text = "Hello, World!"

    public init() {}
}

public enum AGao {
    enum AGaoErrors: Error {
        case stringNotNumeric
        case invalidNumberOfSeparators
    }

    ///  - parameter source The source to be turned into String
    ///  - parameter front How many numbers do you want to keep before the decimal
    ///  - parameter aft How many numbers do you want to keep after the decimal.
    ///                 If it's 0, "." will be omitted. Defaults to 0.
    ///  - returns The string with at least enough zeros added in the front or the end without modifying its accuracy.
    static func keep0sDouble(_ source: Double, _ front: Int, _ aft: Int = 0) -> String {
        var finalStr = "" // 最终连起来的数组
        let isMinus: Bool = source < 0 // 是否为负数
        if isMinus {
            finalStr.append("-") // 如果是负数，在开头加上"-"
        }
        let absValue: Double = isMinus ? -source : source // 转换为绝对值
        let subStrings: [Substring] = "\(absValue)".split(separator: ".")
        let lengthBeforeDot = subStrings[0].count // 在小数点以前的长度
        let numberOf0sInFront: Int = front - lengthBeforeDot
        if numberOf0sInFront > 0 {
            let zerosAddedBeforeEverything = String(repeating: "0", count: numberOf0sInFront) // 需要再前面加的0
            finalStr.append(zerosAddedBeforeEverything)
        }
        finalStr.append("\(subStrings[0])") // 加上整数部分数字
        if subStrings.count > 1 {
            var afterDecimal = "\(subStrings[1])"
            while afterDecimal.hasSuffix("0") {
                if afterDecimal.count > 1 {
                    afterDecimal.remove(at: afterDecimal.endIndex)
                } else {
                    afterDecimal = ""
                }
            }
            // 小数点后有效数字有几位
            let originalLengthAfterDot: Int = afterDecimal.count
            // 需要补0的数量
            let zerosToAppend: Int = aft - originalLengthAfterDot
            if originalLengthAfterDot > 0 { // 如果有有效数字
                finalStr.append(".\(afterDecimal)") // 先加入小数点 和 有效部分数字
                if zerosToAppend > 0 { // 如果需要补0
                    finalStr.append(String(repeating: "0", count: zerosToAppend)) // 把该补的0补上
                }
            } else if aft > 0 {
                finalStr.append(".")
                finalStr.append(String(repeating: "0", count: aft))
            }
        }
        return finalStr
    }

    ///  - parameter source The source to be turned into String
    ///  - parameter front How many numbers do you want to keep before the decimal
    ///  - parameter aft How many numbers do you want to keep after the decimal.
    ///                 If it's 0, "." will be omitted. Defaults to 0.
    ///  - returns The string with at least enough zeros added in the front or the end without modifying its accuracy.
    static func keep0sInt(_ source: Int, _ front: Int = 2, _ aft: Int = 0) -> String {
        var finalStr = "" // 最终连起来的数组
        let isMinus: Bool = source < 0 // 是否为负数
        if isMinus {
            finalStr.append("-") // 如果是负数，在开头加上"-"
        }
        let absValue = "\(isMinus ? -source : source)" // 转换为绝对值
        let lengthBeforeDot = absValue.count // 在小数点以前的长度
        let numberOf0sInFront: Int = front - lengthBeforeDot
        if numberOf0sInFront > 0 {
            let zerosAddedBeforeEverything = String(repeating: "0", count: numberOf0sInFront) // 需要再前面加的0
            finalStr.append(zerosAddedBeforeEverything)
        }
        finalStr.append(absValue) // 加上整数部分数字
        if aft > 0 { // 要求小数点后的0
            finalStr.append(".") // 先加上小数点
            finalStr.append(String(repeating: "0", count: aft)) // 加上aft数量的0
        }
        return finalStr
    }

    static func isNumeric(_ source: String) -> Bool {
        if let _ = Double(source) {
            return true
        } else {
            return false
        }
    }

    static func get60FromStrings(_ source: String, separator: Character = ":", base: Double = 60) throws -> Double {
        let isMinus = source.hasPrefix("-")
        let subStrings: [Substring] = source.split(separator: separator)
        var result = 0.0

        for (index, value) in subStrings.reversed().enumerated() {
            // 必须全部都能被Parse为Double否则就不是数字
            guard let toAdd = Double(value) else {
                throw AGaoErrors.stringNotNumeric
            }
            result += pow(base, Double(index)) * abs(toAdd)
        }
        return isMinus ? -result : result
    }

    static func getStringFrom60(_ source: Double,
                                numberOfSeparators: Int = 1,
                                separator: (Int) -> String = { _ in ":" },
                                numberFormatter: (Double, Int) -> String = { num, _ in keep0sDouble(num, 2) },
                                base: Double = 60) -> String
    {
        if numberOfSeparators <= 0 {
            return numberFormatter(source, 0)
        } else {
            /// 该source是否为负数
            let isMinus = source.isLess(than: 0)
            /// 该source的绝对值，后面会逐渐减少
            var absValue = isMinus ? -source : source
            /// 将result分为若干的Double
            var result: String = ""
            for index in 0 ... numberOfSeparators {
                /// numberOfSeparators ... 0 倒着来
                let thisLevel: Int = numberOfSeparators - index
                /// 被除数
                let divider: Double = pow(base, Double(thisLevel))
                /// 当前Level被整除后的数字
                let valueOfThisLevel: Double = floor(absValue / divider)
                /// 当前level
                let formattedValueOfThisLevel = numberFormatter(valueOfThisLevel, thisLevel)
                absValue -= divider * valueOfThisLevel
                if thisLevel < numberOfSeparators {
                    let thisSeparator: String = separator(thisLevel)
                    result.append(thisSeparator)
                }
                result.append(formattedValueOfThisLevel)
            }
            return result
        }
    }

    static func sumOf60s(_ source: String ...,
                         numberOfSeparators: Int = 1,
                         numberFormatter: (Double, Int) -> String = { num, _ in keep0sDouble(num, 2) },
                         base: Double = 60) {}
}
