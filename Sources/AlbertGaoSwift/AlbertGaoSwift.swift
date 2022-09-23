// swift-tools-version: 5.7

public struct AlbertGaoSwift {
    public private(set) var text = "Hello, World!"

    public init() {}
}

public enum AGao {
    ///  - parameter source The source to be turned into String
    ///  - parameter front How many numbers do you want to keep before the decimal
    ///  - parameter aft How many numbers do you want to keep after the decimal. If it's 0, "." will be omitted. Defaults to 0.
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
    ///  - parameter aft How many numbers do you want to keep after the decimal. If it's 0, "." will be omitted. Defaults to 0.
    ///  - returns The string with at least enough zeros added in the front or the end without modifying its accuracy.
    static func keep0sInt(_ source: Int, _ front: Int, _ aft: Int = 0) -> String {
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
}
