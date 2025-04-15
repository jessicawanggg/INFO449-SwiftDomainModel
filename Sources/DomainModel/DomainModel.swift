struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    var amount : Int
    var currency : String

    private static let exchangeRatesToUSD: [String: Double] = [
        "USD": 1.0,
        "GBP": 2.0,
        "EUR": 2.0 / 3.0,
        "CAN": 0.8
    ]
    
    
    init(amount: Int, currency: String) {
        if let _ = Money.exchangeRatesToUSD[currency] {
            self.amount = amount
            self.currency = currency
        } else {
            self.amount = amount
            self.currency = "USD"
        }
    }
    func convert(_ to: String) -> Money {
        guard let fromRate = Money.exchangeRatesToUSD[self.currency] else {
            return Money(amount: self.amount, currency: "USD")
        }
        guard let toRate = Money.exchangeRatesToUSD[to] else {
            return Money(amount: self.amount, currency: "USD")
        }
        let usdAmount = Double(self.amount) * fromRate
        let convertedAmount = Int((usdAmount / toRate).rounded())
        return Money(amount: convertedAmount, currency: to)
    }
    func add(_ other: Money) -> Money {
        let selfInOtherCurrency = self.convert(other.currency)
        return Money(amount: selfInOtherCurrency.amount + other.amount, currency: other.currency)
    }
    func subtract(_ other: Money) -> Money {
        let otherInSelfCurrency = other.convert(self.currency)
        return Money(amount: self.amount - otherInSelfCurrency.amount, currency:self.currency)
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    var title: String
    var type: JobType
    
    init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    func calculateIncome(_ hours: Int) -> Int {
        switch type {
        case .Hourly(let rate):
            return Int(rate * Double(hours))
        case .Salary(let salary):
            return Int(salary)
        }
    }
    func raise(byAmount amount: Double) {
        switch type {
        case .Hourly(let rate):
            type = .Hourly(rate + amount)
        case .Salary(let salary):
            let increased = salary + UInt(amount)
            type = .Salary(increased)
        }
    }
    func raise(byPercent percent: Double) {
        switch type {
        case .Hourly(let rate):
            type = .Hourly(rate * (1.0 + percent))
        case .Salary(let salary):
            let increased = UInt(Double(salary) * (1.0 + percent))
            type = .Salary(increased)
        }
    }
    // Extra credit
    func convert() {
        switch self.type {
        case .Hourly(let rate):
            let salary = UInt(((rate * 2000) / 1000.0).rounded(.up) * 1000)
            self.type = .Salary(salary)
        case .Salary:
            break
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    let firstName: String
    let lastName: String
    let age: Int

    var job: Job? {
        didSet {
            if age < 16 {
                job = nil
            }
        }
    }
    var spouse: Person? {
        didSet {
            if age < 18 {
                spouse = nil
            }
        }
    }
    init(firstName: String?, lastName: String?, age: Int) {
        self.firstName = firstName ?? ""
        self.lastName = lastName ?? ""
        self.age = age
    }
    func toString() -> String {
        let jobDesc = job.map { j in
            switch j.type {
            case .Hourly(let rate): return "Hourly(\(rate))"
            case .Salary(let salary): return "Salary(\(salary))"
            }
        } ?? "nil"
        let spouseDesc = spouse?.firstName ?? "nil"
        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(jobDesc) spouse:\(spouseDesc)]"
    }
    
    // Extra credit
    var description: String {
        if !firstName.isEmpty && !lastName.isEmpty {
            return "\(firstName) \(lastName)"
        } else if !firstName.isEmpty {
            return firstName
        } else {
            return lastName
        }
    }
}

////////////////////////////////////
// Family
//
public class Family {
    var members: [Person] = []

    init(spouse1: Person, spouse2: Person) {
        guard spouse1.spouse == nil && spouse2.spouse == nil else {
            fatalError("One or both persons are already married")
        }
        spouse1.spouse = spouse2
        spouse2.spouse = spouse1
        members.append(spouse1)
        members.append(spouse2)
    }
    func haveChild(_ child: Person) -> Bool {
        if members[0].age >= 21 || members[1].age >= 21 {
            members.append(child)
            return true
        }
        return false
    }
    func householdIncome() -> Int {
        return members.reduce(0) { total, person in
            if let job = person.job {
                return total + job.calculateIncome(2000)
            }
            return total
        }
    }
}
