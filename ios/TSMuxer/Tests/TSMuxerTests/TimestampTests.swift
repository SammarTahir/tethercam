import XCTest
@testable import TSMuxer

final class TimestampTests: XCTestCase {
    func testConstants() {
        XCTAssertEqual(TSConstants.packetSize, 188)
        XCTAssertEqual(TSConstants.syncByte, 0x47)
    }

    func testOneSecondIs90kTicks() {
        XCTAssertEqual(Timestamp.ticks90kHz(value: 1, timescale: 1), 90_000)
        XCTAssertEqual(Timestamp.ticks90kHz(value: 600, timescale: 600), 90_000)
    }

    func testFrameDurations() {
        // 30 fps -> 3000 ticks, 60 fps -> 1500 ticks.
        XCTAssertEqual(Timestamp.ticks90kHz(value: 1, timescale: 30), 3_000)
        XCTAssertEqual(Timestamp.ticks90kHz(value: 1, timescale: 60), 1_500)
        // Camera clocks commonly use a nanosecond timescale.
        XCTAssertEqual(Timestamp.ticks90kHz(value: 33_333_333, timescale: 1_000_000_000), 3_000)
    }

    func testWrapsAt33Bits() {
        let wrapSeconds = Int64(TSConstants.timestampMask + 1) / TSConstants.clockRate
        let remainderTicks = Int64(TSConstants.timestampMask + 1) % TSConstants.clockRate
        let ticks = Timestamp.ticks90kHz(value: wrapSeconds + 1, timescale: 1)
        XCTAssertEqual(ticks, UInt64(TSConstants.clockRate - remainderTicks))
    }

    func testLargeHostTimeDoesNotOverflow() {
        // ~30 days of uptime in nanoseconds.
        let ns: Int64 = 30 * 24 * 3600 * 1_000_000_000
        let ticks = Timestamp.ticks90kHz(value: ns, timescale: 1_000_000_000)
        XCTAssertLessThanOrEqual(ticks, TSConstants.timestampMask)
        XCTAssertEqual(ticks, UInt64(30 * 24 * 3600 * 90_000) & TSConstants.timestampMask)
    }
}
