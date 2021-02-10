//
//  Date+Formatter.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/10.
//

import Foundation

public extension Date {
  func stringYYMMDD_HHmm() -> String {
    let formatter = DateFormatter.dateFormatterOfyyMMdd_HHmm()
    return formatter.string(from: self)
  }

  func stringYYYYMMDD_HHmm() -> String {
    let formatter = DateFormatter.dateFormatterOfyyyyMMdd_HHmm()
    return formatter.string(from: self)
  }

  func stringYYYYMMDD(with join: String = ".") -> String {
    let formatter = DateFormatter.dateFormatterOfyyyyMMdd(with: join)
    return formatter.string(from: self)
  }

  func stringYYYYMMMDD(lang: String) -> String {
    let formatter = DateFormatter.dateFormatterOfyyyyMMMdd(lang: lang)
    return formatter.string(from: self)
  }

  func stringYYYYMMDDE(with join: String = ".") -> String {
    let formatter = DateFormatter.dateFormatterOfyyyyMMddE(with: join)
    return formatter.string(from: self)
  }

  func stringMMddHHmm() -> String {
    let formatter = DateFormatter.dateFormatterOfMMdd_HHmm()
    return formatter.string(from: self)
  }

  func stringMMdd(with join: String = ".") -> String {
    let formatter = DateFormatter.dateFormatterOfMMdd(with: join)
    return formatter.string(from: self)
  }

  func stringHHmm() -> String {
    let formatter = DateFormatter.dateFormatterOfHHmm()
    return formatter.string(from: self)
  }

  func stringForCalendar() -> String {
    let formatter = DateFormatter.dateFormatterOfyyyyMMddv2()
    return formatter.string(from: self)
  }

  func stringForRequest() -> String {
    let formatter = DateFormatter.dateFormatterOfyyyyMMddv2()
    return formatter.string(from: self)
  }

  func stringBeforeNow() -> String {
    let diff = Int64((self.timeIntervalSinceNow).rounded()) * -1
    let minuteInSec: Int64 = 60
    let hourInSec: Int64 = minuteInSec * 60
    let dayInSec: Int64 = hourInSec * 24
    let monthInSec: Int64 = dayInSec * 30
    let yearInSec: Int64 = dayInSec * 365

    if (diff < minuteInSec) {
      return "방금전"
    } else if (diff < (minuteInSec * 60)) {
      return "\(diff / minuteInSec)분 전"
    } else if (diff < (hourInSec * 24)) {
      return "\(diff / hourInSec)시간 전"
    } else if (diff < (dayInSec * 30)) {
      return "\(diff / dayInSec)일 전"
    } else if (diff < (monthInSec * 12)) {
      return "\(diff / monthInSec)달 전"
    } else {
      return "\(diff / yearInSec)년 전"
    }
  }
}

public extension DateFormatter {
  static func dateFormatterOfyyMMdd_HHmm() -> DateFormatter {
    struct Static {
      static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd HH:mm"
        formatter.calendar = Foundation.Calendar.gregorian
        return formatter
      }
    }
    return Static.dateFormatter
  }

  static func dateFormatterOfyyyyMMdd_HHmm() -> DateFormatter {
    struct Static {
      static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        formatter.calendar = Foundation.Calendar.gregorian
        return formatter
      }
    }
    return Static.dateFormatter
  }

  static func dateFormatterOfyyyyMMdd(with join: String = ".") -> DateFormatter {
    return DateFormatter().apply {
      $0.dateFormat = "yyyy\(join)MM\(join)dd"
      $0.calendar = Foundation.Calendar.gregorian
    }
  }

  static func dateFormatterOfyyyyMMMdd(with join: String = " ", lang: String) -> DateFormatter {
    return DateFormatter().apply {
      $0.dateFormat = "yyyy\(join)MMM\(join)dd"
      $0.calendar = Foundation.Calendar.gregorian
      $0.locale = Locale(identifier: lang)
    }
  }

  static func dateFormatterOfyyyyMMddE(with join: String = ".") -> DateFormatter {
    return DateFormatter().apply {
      $0.dateFormat = "yyyy\(join)MM\(join)dd(E)"
      $0.calendar = Foundation.Calendar.gregorian
    }
  }

  static func dateFormatterOfMMdd_HHmm() -> DateFormatter {
    struct Static {
      static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd HH:mm"
        formatter.calendar = Foundation.Calendar.gregorian
        return formatter
      }
    }
    return Static.dateFormatter
  }

  static func dateFormatterOfMMdd(with join: String = ".") -> DateFormatter {
    return DateFormatter().apply {
      $0.dateFormat = "MM\(join)dd"
      $0.calendar = Foundation.Calendar.gregorian
    }
  }

  static func dateFormatterOfHHmm() -> DateFormatter {
    struct Static {
      static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.calendar = Foundation.Calendar.gregorian
        return formatter
      }
    }
    return Static.dateFormatter
  }

  static func dateFormatterOfyyyyMMddv2() -> DateFormatter {
    struct Static {
      static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Foundation.Calendar.gregorian
        return formatter
      }
    }
    return Static.dateFormatter
  }
}
