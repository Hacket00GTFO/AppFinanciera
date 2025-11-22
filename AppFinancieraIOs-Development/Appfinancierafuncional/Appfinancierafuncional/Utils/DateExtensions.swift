import Foundation

extension Date {
    // Formateo de fechas
    func formattedString(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: self)
    }
    
    func formattedString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: self)
    }
    
    // Cálculos de períodos
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var endOfWeek: Date {
        let calendar = Calendar.current
        let startOfWeek = self.startOfWeek
        return calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? self
    }
    
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var endOfMonth: Date {
        let calendar = Calendar.current
        let startOfMonth = self.startOfMonth
        let range = calendar.range(of: .day, in: .month, for: startOfMonth) ?? 1..<32
        let lastDay = range.upperBound - 1
        return calendar.date(byAdding: .day, value: lastDay, to: startOfMonth) ?? self
    }
    
    var startOfYear: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var endOfYear: Date {
        let calendar = Calendar.current
        let startOfYear = self.startOfYear
        return calendar.date(byAdding: .year, value: 1, to: startOfYear)?.addingTimeInterval(-1) ?? self
    }
    
    // Cálculos de períodos personalizados
    func startOfPeriod(days: Int) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: self)
        let daysToSubtract = calendar.component(.weekday, from: self) - calendar.firstWeekday
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfDay) ?? self
    }
    
    func endOfPeriod(days: Int) -> Date {
        let calendar = Calendar.current
        let startOfPeriod = self.startOfPeriod(days: days)
        return calendar.date(byAdding: .day, value: days - 1, to: startOfPeriod) ?? self
    }
    
    // Verificaciones de períodos
    func isInCurrentWeek() -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    func isInCurrentMonth() -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    func isInCurrentYear() -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    // Cálculos de días
    var daysFromNow: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: self).day ?? 0
    }
    
    var daysAgo: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: self, to: Date()).day ?? 0
    }
    
    // Formateo para períodos
    var periodDescription: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(self, inSameDayAs: now) {
            return "Hoy"
        } else if calendar.isDate(self, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
            return "Ayer"
        } else if calendar.isDate(self, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: now) ?? now) {
            return "Mañana"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d 'de' MMMM"
            formatter.locale = Locale(identifier: "es_MX")
            return formatter.string(from: self)
        }
    }
    
    // Formateo para reportes
    var reportFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }
    
    var monthYearFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: self)
    }
}
