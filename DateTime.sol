pragma solidity ^0.5.0;

/// @title 时间戳类库.
/// @author SinTan1071 - <ryantyler423@gmail.com>
library DateTime {
    struct TimeZone {
        string value;
    }

    struct Date {
        uint16 year;
        uint8 month;
        uint8 day;
    }

    struct UTCDiffer {
        bool shouldAdd;
        uint value;
    }

    modifier validYear(uint16 y){
        require(y > 1970, "年份应该大于1970年");
        _;
    }

    modifier validMonth(uint8 m){
        require(m > 0 && m <= 12, "月份应该是1到12的正整数");
        _;
    }

    modifier validDay(uint16 y, uint8 m, uint8 d){
        uint dayCount = getMonthDays(y, m);
        require(d > 0 && d <= dayCount, "日份不正确");
        _;
    }

    /// @dev 将年月日转化为时间戳，请注意时区的使用.
    /// @param TimeZone 是时区，枚举字符串如下.
    /// @param Date 是DateTime中的Date结构.
    /// UTC+1,UTC+2,UTC+3,UTC+4,UTC+5,UTC+6,
    /// UTC+7,UTC+8,UTC+9,UTC+10,UTC+11,UTC+12,
    /// UTC-11,UTC-10,UTC-9,UTC-8,UTC-7,UTC-6,
    /// UTC-5,UTC-4,UTC-3,UTC-2,UTC-1,UTC
    function toUnix(TimeZone memory tz, Date memory ymd)
    internal
    pure
    validYear(ymd.year)
    validMonth(ymd.month)
    validDay(ymd.year, ymd.month, ymd.day)
    returns (uint)
    {
        uint daysCount = 0;
        for (uint16 i = 1970; i < ymd.year; i++) {
            if (isLeapYear(i)) {
                daysCount += 366;
                continue;
            }
            daysCount += 365;
        }
        for (uint8 j = 1; j < ymd.month; j++) {
            daysCount += getMonthDays(ymd.year, j);
        }
        for (uint8 k = 1; k < ymd.day; k++) {
            daysCount += 1;
        }

        // 一天86400秒
        uint timestamp = daysCount * 1 days;
        UTCDiffer memory differ = checkTimeZone(tz.value);
        if(differ.shouldAdd) {
            timestamp = timestamp + differ.value;
        } else {
            timestamp = timestamp - differ.value;
        }
        return timestamp;
    }

    /// @dev 将时间戳转化为日期，请注意时区的使用.
    /// @param TimeZone 是时区，枚举字符串如下.
    /// @param uint 是时间戳.
    function toDate(TimeZone memory tz, uint timestamp)
    internal
    pure
    returns (Date memory)
    {
        Date memory ymd;
        uint fixedTimestamp;
        UTCDiffer memory differ = checkTimeZone(tz.value);
        // 在重新将时间戳还原为Date日期时，应该将原本该加的做减法，该减的做加法
        if(differ.shouldAdd) {
            fixedTimestamp = timestamp - differ.value;
        } else {
            fixedTimestamp = timestamp + differ.value;
        }
        uint daysCount = fixedTimestamp / 1 days;
        uint Y = daysCount / 365;
        uint D = daysCount % 365;
        uint  YY = Y - 1;
        D -= YY / 4;
        D += YY / 100;
        D -= (YY + 300) / 400;
        while (D < 0)
        {
            Y--;
            D += isLeapYear(uint16(Y + 1970)) ? 366 : 365;
        }
        daysCount = D;
        ymd.year = uint16(Y + 1970);
        uint M;
        uint i;
        uint tmp = daysCount;
        do{
            tmp = daysCount - i;
            M++;
            i += getMonthDays(uint16(Y + 1970), uint8(M));
        } while(daysCount >= i);
        ymd.month = uint8(M);
        ymd.day = uint8(tmp + 1);
        return ymd;
    }

    function checkTimeZone(string memory utc)
    private
    pure
    returns(UTCDiffer memory)
    {
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+1')) {
            return UTCDiffer(false, 1 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+2')) {
            return UTCDiffer(false, 2 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+3')) {
            return UTCDiffer(false, 3 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+4')) {
            return UTCDiffer(false, 4 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+5')) {
            return UTCDiffer(false, 5 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+6')) {
            return UTCDiffer(false, 6 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+7')) {
            return UTCDiffer(false, 7 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+8')) {
            return UTCDiffer(false, 8 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+9')) {
            return UTCDiffer(false, 9 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+10')) {
            return  UTCDiffer(false, 10 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+11')) {
            return  UTCDiffer(false, 11 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC+12')) {
            return  UTCDiffer(false, 12 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC-11')) {
            return  UTCDiffer(true, 11 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC-10')) {
            return  UTCDiffer(true, 10 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC-9')) {
            return UTCDiffer(true, 9 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC-8')) {
            return UTCDiffer(true, 8 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC-7')) {
            return UTCDiffer(true, 7 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC-6')) {
            return UTCDiffer(true, 6 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC-5')) {
            return UTCDiffer(true, 5 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC-4')) {
            return UTCDiffer(true, 4 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC-3')) {
            return UTCDiffer(true, 3 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC-2')) {
            return UTCDiffer(true, 2 hours);
        }
        if (keccak256(abi.encodePacked(utc)) == keccak256('UTC-1')) {
            return UTCDiffer(true, 1 hours);
        }
        return UTCDiffer(false, 0);
    }

    function isLeapYear(uint16 y)
    private
    pure
    returns (bool)
    {
        if ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0){
            return true;
        } else {
            return false;
        }
    }

    function getMonthDays(uint16 y, uint8 m) 
    private
    pure
    returns (uint)
    {
        if (m == 1 || m == 3 || m == 5 || m == 7 || m == 8 || m == 10 || m == 12){
            return 31;
        }
        else if (m == 4 || m == 6 || m == 9 || m == 11){
            // require(ymd.day <= 30, "4 6 9 11 月的日份应该是1到30的正整数");
            return 30;
        }
        else {
            if (isLeapYear(y)) {
                // require(ymd.day <= 29, "闰年2月的日份应该是1到29的正整数");
                return 29;
            }
            else {
                // require(ymd.day <= 28, "平年2月的日份应该是1到28的正整数");
                return 28;
            }
        }
    }
}
