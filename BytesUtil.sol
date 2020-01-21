pragma solidity ^0.5.0;

library BytesUtil {

    function trim(bytes32 x)
    internal
    pure
    returns (bytes32)
    {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    /**
     * 对Bytes32进行concatenate
     */
    function assemConcat(bytes32 b1, bytes32 b2)
    internal
    pure
    returns (bytes memory)
    {
        bytes memory result = new bytes(64);
        assembly {
            mstore(add(result, 32), b1)
            mstore(add(result, 64), b2)
        }
        return result;
    }

    function xorConcat(bytes32 b1, bytes32 b2) // 异或的逆运算为通过
    internal
    pure
    returns (bytes32)
    {
        return b1 ^ b2;
    }

    function hashConcat(bytes32 b1, bytes32 b2)
    internal
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(b1, b2));
    }

    function abiConcat(bytes32 x, bytes32 y)
    internal
    pure
    returns (bytes memory) 
    {
        return abi.encodePacked(x, y);
    }

    /**
     * string类型和bytes32互转
     */
    function stringToBytes32(string memory source)
    internal
    pure
    returns (bytes32 result) 
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function stringToBytes(string memory s)
    internal
    pure
    returns (bytes memory)
    {
        bytes memory b3 = bytes(s);
        return b3;
    }

    function bytes32ToString(bytes32 x)
    internal
    pure
    returns (string memory)
    {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function bytes32ArrayToString(bytes32[] memory data)
    internal
    pure
    returns (string memory)
    {
        bytes memory bytesString = new bytes(data.length * 32);
        uint urlLength;
        for (uint i=0; i<data.length; i++) {
            for (uint j=0; j<32; j++) {
                byte char = byte(bytes32(uint(data[i]) * 2 ** (8 * j)));
                if (char != 0) {
                    bytesString[urlLength] = char;
                    urlLength += 1;
                }
            }
        }
        bytes memory bytesStringTrimmed = new bytes(urlLength);
        for (uint k=0; k<urlLength; k++) {
            bytesStringTrimmed[k] = bytesString[k];
        }
        return string(bytesStringTrimmed);
    }

    /**
     * address类型和bytes32互转
     */
    function addressToBytes32(address a)
    internal
    pure
    returns(bytes32) {
        return bytes32(uint(uint160(a)));
    }

    function bytes32ToAddress(bytes32 b)
    public
    pure
    returns(address) {
        return address(uint160(uint(b)));
    }

    /**
     * uint类型和bytes32互转
     */
    function uintToBytesAssem(uint x)
    internal
    pure
    returns (bytes memory b)
    {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }

    function uintToBytes(uint x)
    internal
    pure
    returns (bytes memory c)
    {
        bytes32 b = bytes32(x);
        c = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            c[i] = b[i];
        }
    }

    function uintToBytes32(uint v)
    internal
    pure
    returns (bytes32 ret)
    {
        if (v == 0) {
            ret = '0';
        } else {
            while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }

    function bytesToUInt(bytes32 v)
    internal
    pure
    returns (uint ret) {
        require(v == 0x0, 'can not convert 0x0 to any uint');

        uint digit;

        for (uint i = 0; i < 32; i++) {
            digit = uint((uint(v) / (2 ** (8 * (31 - i)))) & 0xff);
            if (digit == 0) {
                break;
            } else if (digit < 48 || digit > 57) {
                revert('error when convert bytes32 to uint');
            }
            ret *= 10;
            ret += (digit - 48);
        }
        return ret;
    }
}
