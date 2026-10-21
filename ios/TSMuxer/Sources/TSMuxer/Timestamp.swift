/// MPEG-TS timing helpers. The muxer itself lands in M3.
public enum TSConstants {
    /// Every transport stream packet is exactly 188 bytes.
    public static let packetSize = 188
    /// First byte of every TS packet.
    public static let syncByte: UInt8 = 0x47
    /// PTS/DTS clock rate.
    public static let clockRate: Int64 = 90_000
    /// PTS/DTS are 33-bit fields and wrap around.
    public static let timestampMask: UInt64 = (1 << 33) - 1
}

public enum Timestamp {
    /// Converts a rational timestamp (as found in a CMTime: value / timescale seconds)
    /// to 90 kHz ticks, wrapped to 33 bits. Rounds to the nearest tick.
    public static func ticks90kHz(value: Int64, timescale: Int32) -> UInt64 {
        precondition(timescale > 0, "timescale must be positive")
        let scale = Int64(timescale)
        // value * 90000 / scale without overflowing for large values.
        let whole = (value / scale) * TSConstants.clockRate
        let remainder = value % scale
        let fraction = (remainder * TSConstants.clockRate * 2 + scale) / (scale * 2)
        let ticks = whole + fraction
        // Two's-complement wrap keeps negative inputs inside the 33-bit range too.
        return UInt64(bitPattern: ticks) & TSConstants.timestampMask
    }
}
