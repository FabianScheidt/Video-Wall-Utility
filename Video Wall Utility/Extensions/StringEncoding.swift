import Foundation

extension String.Encoding {
    static let gb18030: String.Encoding = {
        let cfEnc = CFStringEncodings.GB_18030_2000
        let nsEnc = CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(cfEnc.rawValue)
        )
        return String.Encoding(rawValue: nsEnc)
    }()
}
