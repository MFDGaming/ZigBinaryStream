// Copyright Alexander Argentakis
// Repo: https://github.com/MFDGaming/ZigBinaryStream
// This file is licensed under the MIT license

const std = @import("std");

pub const EndOfStreamError = error{EndOfStream};
pub const VarIntTooLongError = error{VarIntTooLong};

pub const BinaryStream = struct {
    buffer: std.ArrayList(u8),
    offset: usize,

    pub fn destroy(self: *BinaryStream) void {
        self.buffer.deinit();
    }

    pub fn reset(self: *BinaryStream) void {
        self.buffer.deinit();
        self.offset = 0;
        self.buffer = std.ArrayList(u8).init(std.heap.page_allocator);
    }

    pub fn getSize(self: *BinaryStream) usize {
        return self.buffer.items.len;
    }

    pub fn getBuffer(self: *BinaryStream) []u8 {
        return self.buffer.items;
    }

    pub fn isEndOfStream(self: *BinaryStream) bool {
        if (self.offset < self.getSize()) {
            return false;
        }
        return true;
    }

    pub fn read(self: *BinaryStream, size: usize) []u8 {
        var buffer: []u8 = self.buffer.items[self.offset..self.offset + size];
        self.offset += size;
        return buffer;
    }

    pub fn write(self: *BinaryStream, buffer: []u8) !void {
        try self.buffer.appendSlice(buffer);
    }

    pub fn readUnsignedByte(self: *BinaryStream) u8 {
        var byteArray: []u8 = self.read(1);
        return byteArray[0];
    }

    pub fn writeUnsignedByte(self: *BinaryStream, value: u8) !void {
        var byteArray: [1]u8 = [_]u8{value};
        try self.write(byteArray[0..1]);
    }

    pub fn readByte(self: *BinaryStream) i8 {
        return @bitCast(i8, self.readUnsignedByte());
    }

    pub fn writeByte(self: *BinaryStream, value: i8) !void {
        try self.writeUnsignedByte(@bitCast(u8, value));
    }

    pub fn readUnsignedShortLe(self: *BinaryStream) u16 {
        var byteArray: []u8 = self.read(2);
        return @as(u16, byteArray[0]) | (@as(u16, byteArray[1]) << 8);
    }

    pub fn writeUnsignedShortLe(self: *BinaryStream, value: u16) !void {
        var byteArray: [2]u8 = [_]u8{
            @truncate(u8, value & 0xff),
            @truncate(u8, (value >> 8) & 0xff)
        };
        try self.write(byteArray[0..2]);
    }

    pub fn readShortLe(self: *BinaryStream) i16 {
        return @bitCast(i16, self.readUnsignedShortLe());
    }

    pub fn writeShortLe(self: *BinaryStream, value: i16) !void {
        try self.writeUnsignedShortLe(@bitCast(u16, value));
    }

    pub fn readUnsignedShortBe(self: *BinaryStream) u16 {
        var byteArray: []u8 = self.read(2);
        return (@as(u16, byteArray[0]) << 8) | @as(u16, byteArray[1]);
    }

    pub fn writeUnsignedShortBe(self: *BinaryStream, value: u16) !void {
        var byteArray: [2]u8 = [_]u8{
            @truncate(u8, (value >> 8) & 0xff),
            @truncate(u8, value & 0xff)
        };
        try self.write(byteArray[0..2]);
    }

    pub fn readShortBe(self: *BinaryStream) i16 {
        return @bitCast(i16, self.readUnsignedShortBe());
    }

    pub fn writeShortBe(self: *BinaryStream, value: i16) !void {
        try self.writeUnsignedShortBe(@bitCast(u16, value));
    }

    pub fn readUnsignedTriadLe(self: *BinaryStream) u24 {
        var byteArray: []u8 = self.read(3);
        return @as(u24, byteArray[0]) | (@as(u24, byteArray[1]) << 8) | (@as(u24, byteArray[2]) << 16);
    }

    pub fn writeUnsignedTriadLe(self: *BinaryStream, value: u24) !void {
        var byteArray: [3]u8 = [_]u8{
            @truncate(u8, value & 0xff),
            @truncate(u8, (value >> 8) & 0xff),
            @truncate(u8, (value >> 16) & 0xff)
        };
        try self.write(byteArray[0..3]);
    }

    pub fn readTriadLe(self: *BinaryStream) i24 {
        return @bitCast(i24, self.readUnsignedTriadLe());
    }

    pub fn writeTriadLe(self: *BinaryStream, value: i24) !void {
        try self.writeUnsignedTriadLe(@bitCast(u24, value));
    }

    pub fn readUnsignedTriadBe(self: *BinaryStream) u24 {
        var byteArray: []u8 = self.read(3);
        return (@as(u24, byteArray[0]) << 16) | (@as(u24, byteArray[1]) << 8) | @as(u24, byteArray[2]);
    }

    pub fn writeUnsignedTriadBe(self: *BinaryStream, value: u24) !void {
        var byteArray: [3]u8 = [_]u8{
            @truncate(u8, (value >> 16) & 0xff),
            @truncate(u8, (value >> 8) & 0xff),
            @truncate(u8, value & 0xff)
        };
        try self.write(byteArray[0..3]);
    }

    pub fn readTriadBe(self: *BinaryStream) i24 {
        return @bitCast(i24, self.readUnsignedTriadBe());
    }

    pub fn writeTriadBe(self: *BinaryStream, value: i24) !void {
        try self.writeUnsignedTriadBe(@bitCast(u24, value));
    }

    pub fn readUnsignedIntLe(self: *BinaryStream) u32 {
        var byteArray: []u8 = self.read(4);
        return @as(u32, byteArray[0]) | (@as(u32, byteArray[1]) << 8) | (@as(u32, byteArray[2]) << 16) | (@as(u32, byteArray[3]) << 24);
    }

    pub fn writeUnsignedIntLe(self: *BinaryStream, value: u32) !void {
        var byteArray: [4]u8 = [_]u8{
            @truncate(u8, value & 0xff),
            @truncate(u8, (value >> 8) & 0xff),
            @truncate(u8, (value >> 16) & 0xff),
            @truncate(u8, (value >> 24) & 0xff)
        };
        try self.write(byteArray[0..4]);
    }

    pub fn readIntLe(self: *BinaryStream) i32 {
        return @bitCast(i32, self.readUnsignedIntLe());
    }

    pub fn writeIntLe(self: *BinaryStream, value: i32) !void {
        try self.writeUnsignedIntLe(@bitCast(u32, value));
    }

    pub fn readUnsignedIntBe(self: *BinaryStream) u32 {
        var byteArray: []u8 = self.read(4);
        return (@as(u32, byteArray[0]) << 24) | (@as(u32, byteArray[1]) << 16) | (@as(u32, byteArray[2]) << 8) | @as(u32, byteArray[3]);
    }

    pub fn writeUnsignedIntBe(self: *BinaryStream, value: u32) !void {
        var byteArray: [4]u8 = [_]u8{
            @truncate(u8, (value >> 24) & 0xff),
            @truncate(u8, (value >> 16) & 0xff),
            @truncate(u8, (value >> 8) & 0xff),
            @truncate(u8, value & 0xff)
        };
        try self.write(byteArray[0..4]);
    }

    pub fn readIntBe(self: *BinaryStream) i32 {
        return @bitCast(i32, self.readUnsignedIntBe());
    }

    pub fn writeIntBe(self: *BinaryStream, value: i32) !void {
        try self.writeUnsignedIntBe(@bitCast(u32, value));
    }

    pub fn readUnsignedLongLe(self: *BinaryStream) u64 {
        var byteArray: []u8 = self.read(8);
        return @as(u64, byteArray[0]) | (@as(u64, byteArray[1]) << 8) | (@as(u64, byteArray[2]) << 16) | (@as(u64, byteArray[3]) << 24) | (@as(u64, byteArray[4]) << 32) | (@as(u64, byteArray[5]) << 40) | (@as(u64, byteArray[6]) << 48) | (@as(u64, byteArray[7]) << 56);
    }

    pub fn writeUnsignedLongLe(self: *BinaryStream, value: u64) !void {
        var byteArray: [8]u8 = [_]u8{
            @truncate(u8, value & 0xff),
            @truncate(u8, (value >> 8) & 0xff),
            @truncate(u8, (value >> 16) & 0xff),
            @truncate(u8, (value >> 24) & 0xff),
            @truncate(u8, (value >> 32) & 0xff),
            @truncate(u8, (value >> 40) & 0xff),
            @truncate(u8, (value >> 48) & 0xff),
            @truncate(u8, (value >> 56) & 0xff)
        };
        try self.write(byteArray[0..8]);
    }

    pub fn readLongLe(self: *BinaryStream) i64 {
        return @bitCast(i64, self.readUnsignedLongLe());
    }

    pub fn writeLongLe(self: *BinaryStream, value: i64) !void {
        try self.writeUnsignedLongLe(@bitCast(u64, value));
    }

    pub fn readUnsignedLongBe(self: *BinaryStream) u64 {
        var byteArray: []u8 = self.read(8);
        return (@as(u64, byteArray[0]) << 56) | (@as(u64, byteArray[1]) << 48) | (@as(u64, byteArray[2]) << 40) | (@as(u64, byteArray[3]) << 32) | (@as(u64, byteArray[4]) << 24) | (@as(u64, byteArray[5]) << 16) | (@as(u64, byteArray[6]) << 8) | @as(u64, byteArray[7]);
    }

    pub fn writeUnsignedLongBe(self: *BinaryStream, value: u64) !void {
        var byteArray: [8]u8 = [_]u8{
            @truncate(u8, (value >> 56) & 0xff),
            @truncate(u8, (value >> 48) & 0xff),
            @truncate(u8, (value >> 40) & 0xff),
            @truncate(u8, (value >> 32) & 0xff),
            @truncate(u8, (value >> 24) & 0xff),
            @truncate(u8, (value >> 16) & 0xff),
            @truncate(u8, (value >> 8) & 0xff),
            @truncate(u8, value & 0xff)
        };
        try self.write(byteArray[0..8]);
    }

    pub fn readLongBe(self: *BinaryStream) i64 {
        return @bitCast(i64, self.readUnsignedLongBe());
    }

    pub fn writeLongBe(self: *BinaryStream, value: i64) !void {
        try self.writeUnsignedLongBe(@bitCast(u64, value));
    }
    
    pub fn readFloatLe(self: *BinaryStream) f32 {
        return @bitCast(f32, self.readUnsignedIntLe());
    }

    pub fn writeFloatLe(self: *BinaryStream, value: f32) !void {
        try self.writeUnsignedIntLe(@bitCast(u32, value));
    }
     
    pub fn readFloatBe(self: *BinaryStream) f32 {
        return @bitCast(f32, self.readUnsignedIntBe());
    }

    pub fn writeFloatBe(self: *BinaryStream, value: f32) !void {
        try self.writeUnsignedIntBe(@bitCast(u32, value));
    }
    
    pub fn readDoubleLe(self: *BinaryStream) f64 {
        return @bitCast(f64, self.readUnsignedLongLe());
    }

    pub fn writeDoubleLe(self: *BinaryStream, value: f64) !void {
        try self.writeUnsignedLongLe(@bitCast(u64, value));
    }
    
    pub fn readDoubleBe(self: *BinaryStream) f64 {
        return @bitCast(f64, self.readUnsignedLongBe());
    }

    pub fn writeDoubleBe(self: *BinaryStream, value: f64) !void {
        try self.writeUnsignedLongBe(@bitCast(u64, value));
    }
    
    pub fn readUnsignedVarInt(self: *BinaryStream) !u32 {
        var value: u32 = 0;
        var i: u5 = 0;
        while (i < 35) : (i += 7) {
            if (self.isEndOfStream()) {
                return error.EndOfStream;
            }
            var toRead: u8 = self.readUnsignedByte();
            value |= @as(u32, (toRead & 0x7f)) << i;
            if ((toRead & 0x80) == 0) {
                return value;
            }
        }
        return error.VarIntTooLong;
    }
    
    pub fn writeUnsignedVarInt(self: *BinaryStream, value: u32) !void {
        var v: u32 = value;
        var i: u8 = 0;
        while (i < 5) : (i += 1) {
            var toWrite: u8 = @truncate(u8, v & 0x7f);
            v >>= 7;
            if (v != 0) {
                try self.writeUnsignedByte(toWrite | 0x80);
            } else {
                try self.writeUnsignedByte(toWrite);
                break;
            }
        }
    }
    
    pub fn readVarInt(self: *BinaryStream) !i32 {
        var raw: u32 = try self.readUnsignedVarInt();
        var temp: u32 = if ((raw & 1) == 1) ~(raw >> 1) else raw >> 1;
        return @bitCast(i32, temp);
    }

    pub fn writeVarInt(self: *BinaryStream, value: i32) !void {
        var raw: u32 = if (value >= 0) @bitCast(u32, value) << 1 else ((~@bitCast(u32, value)) << 1) | 1;
        try self.writeUnsignedVarInt(raw);
    }

    pub fn readUnsignedVarLong(self: *BinaryStream) !u64 {
        var value: u64 = 0;
        var i: u6 = 0;
        while (i < 70) : (i += 7) {
            if (self.isEndOfStream()) {
                return error.EndOfStream;
            }
            var toRead: u8 = self.readUnsignedByte();
            value |= @as(u64, (toRead & 0x7f)) << i;
            if ((toRead & 0x80) == 0) {
                return value;
            }
        }
        return error.VarIntTooLong;
    }
    
    pub fn writeUnsignedVarLong(self: *BinaryStream, value: u64) !void {
        var v: u64 = value;
        var i: u8 = 0;
        while (i < 10) : (i += 1) {
            var toWrite: u8 = @truncate(u8, v & 0x7f);
            v >>= 7;
            if (v != 0) {
                try self.writeUnsignedByte(toWrite | 0x80);
            } else {
                try self.writeUnsignedByte(toWrite);
                break;
            }
        }
    }
    
    pub fn readVarLong(self: *BinaryStream) !i64 {
        var raw: u64 = try self.readUnsignedVarLong();
        var temp: u64 = if ((raw & 1) == 1) ~(raw >> 1) else raw >> 1;
        return @bitCast(i64, temp);
    }

    pub fn writeVarLong(self: *BinaryStream, value: i64) !void {
        var raw: u64 = if (value >= 0) @bitCast(u64, value) << 1 else ((~@bitCast(u64, value)) << 1) | 1;
        try self.writeUnsignedVarLong(raw);
    }

    pub fn readBool(self: *BinaryStream) bool {
        return self.readUnsignedByte() != 0;
    }

    pub fn writeBool(self: *BinaryStream, value: bool) !void {
        try self.writeUnsignedByte(if (value) 1 else 0);
    }
};

pub fn construct() BinaryStream {
    var stream: BinaryStream = BinaryStream{
        .buffer = std.ArrayList(u8).init(std.heap.page_allocator),
        .offset = 0
    };
    return stream;
}