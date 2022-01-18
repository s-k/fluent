import Vapor
import FluentKit
import SQLKit

struct RequestQueryInstrumentation: StorageKey {
    typealias Value = QueryInstrumentation
}

struct FluentInstrumentationKey: StorageKey {
    typealias Value = FluentInstrumentation
}

struct FluentInstrumentation {
    let enabled: Bool
}

extension Application.Fluent.Instrumentation {
    var instrumentationEnabled: Bool {
        storage[FluentInstrumentationKey.self]?.enabled ?? false
    }

    var storage: Storage {
        get {
            self.fluent.application.storage
        }
        nonmutating set {
            self.fluent.application.storage = newValue
        }
    }

    var instrumentation: QueryInstrumentation? {
        return storage[RequestQueryInstrumentation.self]
    }

    /// The stored per-query performance records
    public var queryRecords: [SQLQueryPerformanceRecord] {
        return instrumentation?.queryRecords ?? []
    }
    
    /// The stored aggregate performance record for the database configuration
    public var aggregateData: SQLQueryPerformanceRecord? {
        return instrumentation?.aggregateRecord
    }
    
    /// The stored aggregate performance record for the process as a whole. May be empty.
    public var globalData: SQLQueryPerformanceRecord {
        return QueryInstrumentation.readGlobalRecordSnapshot()
    }

    /// Start instrumenting queries
    public func start() {
        storage[FluentInstrumentationKey.self] = .init(enabled: true)
        storage[RequestQueryInstrumentation.self] = .init()
    }

    /// Stop instrumenting queries
    public func stop() {
        storage[FluentInstrumentationKey.self] = .init(enabled: false)
    }

    /// Clear the instrumented query records (clears aggregate stats but not the global record)
    public func clear() {
        storage[RequestQueryInstrumentation.self] = .init()
    }
}
