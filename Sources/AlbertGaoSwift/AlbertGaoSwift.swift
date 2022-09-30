// swift-tools-version: 5.7
import Foundation

public enum AGao {
    public enum AGaoErrors: Error {
        case stringNotNumeric
        case invalidNumberOfSeparators
    }

    /// Loads Json inside the project
    public static func loadJsonInApp<T: Decodable>(_ fileName: String) -> T {
        let data: Data

        guard let file = Bundle.main.url(forResource: fileName, withExtension: nil)
        else {
            fatalError("Couldn't find \(fileName) in main bundle.")
        }

        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(fileName) from main bundle:\n\(error)")
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(fileName) as \(T.self):\n\(error)")
        }
    }

    public static func saveJson(jsonObject: some Encodable, toFilename filename: String) throws -> Bool {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(filename)
            fileURL = fileURL.appendingPathExtension("json")
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            try data.write(to: fileURL, options: [.atomicWrite])
            return true
        }

        return false
    }

    public static func loadJSON(withFilename filename: String) throws -> Any? {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(filename)
            fileURL = fileURL.appendingPathExtension("json")
            let data = try Data(contentsOf: fileURL)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .mutableLeaves])
            return jsonObject
        }
        return nil
    }

    ///  - parameter source The source to be turned into String
    ///  - parameter front How many numbers do you want to keep before the decimal
    ///  - parameter aft How many numbers do you want to keep after the decimal.
    ///                 If its 0, "." will be omitted. Defaults to 0.
    ///  - returns The string with at least enough zeros added in the front or the end without modifying its accuracy.
    public static func keep0sDouble(_ source: Double, _ front: Int, _ aft: Int = 0) -> String {
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
    ///                 If its 0, "." will be omitted. Defaults to 0.
    ///  - returns The string with at least enough zeros added in the front or the end without modifying its accuracy.
    public static func keep0sInt(_ source: Int, _ front: Int = 2, _ aft: Int = 0) -> String {
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

    /// Detects if a string is numeric or not
    public static func isNumeric(_ source: String) -> Bool {
        if Double(source) != nil {
            return true
        } else {
            return false
        }
    }

    public static let defaultFormatter: (Double, Int) -> String
        = { num, _ in keep0sDouble(num, 2) }

    /// - parameter source : A sexagesimal string
    /// - parameter separator : The separator used to parse the string. Defaults to ":".
    /// - parameter base : The system you are using to parse the source. Defaults to 60.
    /// - returns The number calculated by the source. For instance, "2:30" would result in 150.
    public static func get60FromStrings(_ source: String, separator: Character = ":", base: Double = 60) throws -> Double {
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

    public struct Parse60Result {
        public let numbers: [Double], formatted: String, isMinus: Bool
    }

    /// - parameter source : A sexagesimal string
    /// - parameter separators : The separators used to join the numbers together.
    /// - parameter numberFormatter : How each number would look like.
    ///                     The first argument is the number itself.
    ///            The second argument is the number of power of 60 that the current number is using.
    /// - parameter base : The system you are using to finalize the result. Defaults to 60.
    public static func getStringFrom60(_ source: Double,
                                       separators: [String] = [":"],
                                       numberFormatter: (Double, Int) -> String = defaultFormatter,
                                       base: Double = 60) -> Parse60Result
    {
        let numberOfSeparators = separators.count
        if numberOfSeparators <= 0 {
            return Parse60Result(numbers: [Double](), formatted: numberFormatter(source, 0), isMinus: false)
        } else {
            var numbers: [Double] = []
            /// 该source是否为负数
            let isMinus = source.isLess(than: 0)
            /// 该source的绝对值，后面会逐渐减少
            var absValue = isMinus ? -source : source
            /// 将result分为若干的Double
            var result = ""
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
                result.append(formattedValueOfThisLevel)
                numbers.append(valueOfThisLevel)
                if index < numberOfSeparators {
                    let thisSeparator: String = separators[index]
                    result.append(thisSeparator)
                }
            }
            return Parse60Result(numbers: numbers, formatted: result, isMinus: isMinus)
        }
    }

    /// - parameter source : Sexagesimal strings
    /// - parameter separatorOfSource : The separator used to parse the string. Defaults to ":".
    /// - parameter separators : The separators used to join the numbers (of the result) together.
    /// - parameter numberFormatter : How each number would look like.
    ///                  The first argument is the number itself.
    ///                  The second argument is the number of power of 60 that the current number is using.
    /// - parameter base : The system you are using to finalize the result. Defaults to 60.
    public static func sumOf60s(_ source: [String],
                                separatorOfSource separator: Character = ":",
                                separators: [String] = [":"],
                                numberFormatter: (Double, Int) -> String = defaultFormatter,
                                base: Double = 60)
        throws -> (inStr: String, inDouble: Double)
    {
        var sumOfResult = 0.0
        for str in source {
            guard let item = try? get60FromStrings(str, separator: separator, base: base) else {
                throw AGaoErrors.invalidNumberOfSeparators
            }
            sumOfResult += item
        }
        return (
            inStr: getStringFrom60(sumOfResult, separators: separators, numberFormatter: numberFormatter, base: base).formatted,
            inDouble: sumOfResult
        )
    }

    /// - parameter source : The string to be separated.
    /// - parameter reg : The regular expression to separate the source.
    /// - returns The source string is separated into whatever matches the regular expression
    ///                 as well as those that doesnt match.
    ///                 The result.joined() should == source .
    public static func separate(_ source: String, by reg: NSRegularExpression) -> [String] {
        let matchResult = reg.matches(in: source, range: NSRange(location: 0, length: source.count))
        var lastStart = 0
        var finalResult: [String] = []
        for result in matchResult {
            let start: Int = result.range.location
            let lengthOfRange: Int = result.range.length
            if lastStart < start - 1 {
                // 上次的结果的下一个index比start要小
                // 证明中间夹了一个字符串
                let startingIndexOfStringInBetween: String.Index = source.index(source.startIndex, offsetBy: lastStart)
                let endingIndexOfStringInBetween: String.Index =
                    source.index(startingIndexOfStringInBetween, offsetBy: start - lastStart)
                let ranging = startingIndexOfStringInBetween ..< endingIndexOfStringInBetween
                finalResult.append(String(source[ranging]))
            }
            let startingIndex: String.Index = source.index(source.startIndex, offsetBy: start)
            let endingIndex: String.Index = source.index(startingIndex, offsetBy: lengthOfRange)
            let ranging = startingIndex ..< endingIndex
            finalResult.append(String(source[ranging]))
            lastStart = result.range.upperBound
        }
        if lastStart < source.count - 1 {
            let startingIndex: String.Index = source.index(source.startIndex, offsetBy: lastStart)
            let ranging = startingIndex ..< source.endIndex
            finalResult.append(String(source[ranging]))
        }
        return finalResult
    }

    /// - parameter source The string to parse.
    /// - returns The source converted to its reg pattern.
    ///  for example : toRawRegPattern( "[Hello]" ) -> #"\[Hello\]"#
    public static func toRawRegPattern(_ source: String) -> String {
        return source
            .replacingOccurrences(of: #"$"#, with: #"\$"#)
            .replacingOccurrences(of: #"("#, with: #"\("#)
            .replacingOccurrences(of: #")"#, with: #"\)"#)
            .replacingOccurrences(of: #"*"#, with: #"\*"#)
            .replacingOccurrences(of: #"+"#, with: #"\+"#)
            .replacingOccurrences(of: #"."#, with: #"\."#)
            .replacingOccurrences(of: #"["#, with: #"\["#)
            .replacingOccurrences(of: #"]"#, with: #"\]"#)
            .replacingOccurrences(of: #"?"#, with: #"\?"#)
            .replacingOccurrences(of: #"^"#, with: #"\^"#)
            .replacingOccurrences(of: #"|"#, with: #"\|"#)
            .replacingOccurrences(of: #"{"#, with: #"\{"#)
            .replacingOccurrences(of: #"}"#, with: #"\}"#)
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: #"/"#, with: "\\/")
    }
}

public struct Time60: Comparable, AdditiveArithmetic, Equatable {
    /// The actual amount parsed from the string initially.
    public var amount: Double
    /// How each number would look like.
    ///  The first argument is the number itself.
    ///  The second argument is the number of power of 60 that the current number is using.
    public var formatter: (Double, Int) -> String
    /// The system you are using to finalize the result. Defaults to 60.
    public var base: Double = 60
    /// The separators used to join the numbers together.
    public var separators = [":"]
    /// The formatted "number:number" string.
    public var parsed: AGao.Parse60Result {
        AGao.getStringFrom60(amount,
                             separators: separators,
                             numberFormatter: formatter,
                             base: base)
    }

    public init(source: String,
                separator: Character = ":",
                formatter: @escaping (Double, Int) -> String = AGao.defaultFormatter,
                base: Double = 60,
                separators: [String] = [":"])
    {
        let amount = (try? AGao.get60FromStrings(source, separator: separator, base: base)) ?? Double.nan
        self.amount = amount
        self.formatter = formatter
        self.base = base
        self.separators = separators
    }

    public init(amount: Double,
                formatter: @escaping (Double, Int) -> String = AGao.defaultFormatter,
                base: Double = 60,
                separators: [String] = [":"])
    {
        self.amount = amount
        self.formatter = formatter
        self.base = base
        self.separators = separators
    }

    public static var zero: Time60 = .init(amount: 0)
    public static func < (lhs: Time60, rhs: Time60) -> Bool {
        lhs.amount < rhs.amount
    }

    public static func == (lhs: Time60, rhs: Time60) -> Bool {
        lhs.amount == rhs.amount
    }

    public static func + (lhs: Time60, rhs: Time60) -> Time60 {
        var result = lhs
        result.amount += rhs.amount
        return result
    }

    public static func - (lhs: Time60, rhs: Time60) -> Time60 {
        var result = lhs
        result.amount -= rhs.amount
        return result
    }
}
