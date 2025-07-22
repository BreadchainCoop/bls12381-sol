// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.25;

import {console} from "forge-std/console.sol";
import {_T} from "./interface/Types.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

library Fp381 {
    bytes constant P     = hex"1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab";
    bytes constant P64   = hex"000000000000000000000000000000001a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab";
    bytes constant P64_2 = hex"000000000000000000000000000000001a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab000000000000000000000000000000001a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab";

    function newFp(bytes memory a) internal pure returns (_T.DirtyFp result) {
        require(a.length <= 64, FpInputTooLarge(a.length));
        bytes memory resultBytes = new bytes(64);
        uint256 pad = 64 - a.length;
        assembly {
            mcopy(add(add(resultBytes, 0x20), pad), add(a, 0x20), 64)
            result := resultBytes
        }
    }

    function newFp2(bytes memory a) internal pure returns (_T.DirtyFp2 result) {
        require(a.length <= 128, Fp2InputTooLarge(a.length));
        bytes memory resultBytes = new bytes(128);
        uint256 pad = 128 - a.length;
        assembly {
            mcopy(add(add(resultBytes, 0x20), pad), add(a, 0x20), 128)
            result := resultBytes
        }
    }

    function dirtyRef(_T.Fp a) internal pure returns (_T.DirtyFp result) {
        assembly {
            result := a
        }
    }

    function dirtyRef(_T.Fp2 a) internal pure returns (_T.DirtyFp2 result) {
        assembly {
            result := a
        }
    }

    function clean(_T.DirtyFp a) internal view returns (_T.Fp result) {
        bytes memory aBytes;
        assembly {
            aBytes := a
        }
        aBytes = Math.modExp(aBytes, hex"01", P);
        uint256 pad = 64 - aBytes.length;
        bytes memory fp_bytes = new bytes(64);
        assembly {
            mcopy(add(add(fp_bytes, 0x20), pad), add(aBytes, 0x20), 64)
            result := fp_bytes
        }
    }

    // TODO: This is implemented really inefficiently but only because
    // when I implemented it efficiently I had the weirdest memory bugs
    function clean(_T.DirtyFp2 a) internal view returns (_T.Fp2 result) {
        _T.DirtyFp a0;
        _T.DirtyFp a1;
        bytes memory a0Bytes = new bytes(64);
        bytes memory a1Bytes = new bytes(64);
        assembly {
            a0 := a0Bytes
            a1 := a1Bytes
            mcopy(add(a0Bytes, 0x20), add(a, 0x20), 64)
            mcopy(add(a1Bytes, 0x20), add(a, 0x60), 64)
        }
        _T.Fp a0Clean = Fp381.clean(a0);
        _T.Fp a1Clean = Fp381.clean(a1);
        bytes memory resultBytes = new bytes(128);
        assembly {
            mcopy(add(resultBytes, 0x20), add(a0Clean, 0x20), 64)
            mcopy(add(resultBytes, 0x60), add(a1Clean, 0x20), 64)
            result := resultBytes
        }
    }

    function nullify(_T.DirtyFp a) internal pure {
        assembly {
            mstore(add(a, 0x20), 0)
            mstore(add(a, 0x40), 0)
        }
    }

    function nullify(_T.DirtyFp2 a) internal pure {
        assembly {
            mstore(add(a, 0x20), 0)
            mstore(add(a, 0x40), 0)
            mstore(add(a, 0x60), 0)
            mstore(add(a, 0x80), 0)
        }
    }

    function add(_T.DirtyFp a, _T.DirtyFp b) internal pure returns (_T.DirtyFp result, bool isOverflow) {
        bytes memory resultBytes = new bytes(64);
        assembly {
            result := resultBytes
        }
        isOverflow = Fp381.add(a, b, result);
    }

    // if result is overflow, then won't allocate memory and return 0
    // cleaning one of the dirty fps will be enough to pass the overflow
    function add(_T.DirtyFp a, _T.DirtyFp b, _T.DirtyFp dest) internal pure returns (bool isOverflow) {
        uint256 c;
        uint256 d;
        assembly {
            let a_lower := mload(add(a, 0x40))
            let b_lower := mload(add(b, 0x40))
            c := add(a_lower, b_lower)
            let is_carry := lt(c, a_lower)
            let a_upper := mload(add(a, 0x20))
            let b_upper := mload(add(b, 0x20))
            d := add(add(a_upper, b_upper), is_carry)
            isOverflow := lt(d, a_upper)
        }
        if (isOverflow) {
            return true;
        }
        assembly {
            mstore(add(dest, 0x40), c)
            mstore(add(dest, 0x20), d)
        }
    }

    function sub(_T.DirtyFp a, _T.DirtyFp b) internal pure returns (_T.DirtyFp result, bool is_underflow) {
        bytes memory resultBytes = new bytes(64);
        assembly {
            result := resultBytes
        }
        is_underflow = Fp381.sub(a, b, result);
    }

    function sub(_T.DirtyFp a, _T.DirtyFp b, _T.DirtyFp dest) internal pure returns (bool isUnderflow) {
        uint256 c;
        uint256 d;
        assembly {
            let a_lower := mload(add(a, 0x40))
            let b_lower := mload(add(b, 0x40))
            let is_carry := lt(a_lower, b_lower)
            c := sub(a_lower, b_lower)
            let a_upper := mload(add(a, 0x20))
            let b_upper := mload(add(b, 0x20))
            isUnderflow := or(lt(a_upper, is_carry), lt(a_upper, b_upper))
            d := sub(sub(a_upper, b_upper), is_carry)
        }
        if (isUnderflow) {
            return true;
        }
        assembly {
            mstore(add(dest, 0x40), c)
            mstore(add(dest, 0x20), d)
        }
    }

    function add(_T.DirtyFp2 a, _T.DirtyFp2 b, _T.DirtyFp2 dest) internal pure returns (bool isOverflow) {
        // WARNING: These are not really safe DirtyFp because the a1 and b1 are not really bytes arrays
        // The `add` function for fp1 does not depend on reading the bytes array's length, only the contents, so it works
        _T.DirtyFp a0;
        _T.DirtyFp a1;
        _T.DirtyFp b0;
        _T.DirtyFp b1;
        _T.DirtyFp dest0;
        _T.DirtyFp dest1;

        assembly {
            a0 := a
            a1 := add(a, 0x40)
            b0 := b
            b1 := add(b, 0x40)
            dest0 := dest
            dest1 := add(dest, 0x40)
        }

        isOverflow = Fp381.add(a0, b0, dest0) || Fp381.add(a1, b1, dest1);
    }

    function sub(_T.DirtyFp2 a, _T.DirtyFp2 b, _T.DirtyFp2 dest) internal pure returns (bool isUnderflow) {
        // WARNING: These are not really safe DirtyFp because the a1 and b1 are not really bytes arrays
        // The `sub` function for fp1 does not depend on reading the bytes array's length, only the contents, so it works
        _T.DirtyFp a0;
        _T.DirtyFp a1;
        _T.DirtyFp b0;
        _T.DirtyFp b1;
        _T.DirtyFp dest0;
        _T.DirtyFp dest1;

        assembly {
            a0 := a
            a1 := add(a, 0x40)
            b0 := b
            b1 := add(b, 0x40)
            dest0 := dest
            dest1 := add(dest, 0x40)
        }

        isUnderflow = Fp381.sub(a0, b0, dest0) || Fp381.sub(a1, b1, dest1);
    }

    function inverse(_T.Fp a) internal pure returns (_T.Fp result) {
        bytes memory resultBytes = new bytes(64);
        assembly {
            result := resultBytes
        }
        Fp381.inverse(a, result);
    }

    function inverse(_T.Fp a, _T.Fp dest) internal pure {
        bytes memory p64 = P64;
        _T.DirtyFp pFp;
        assembly {
            pFp := p64
        }
        bool isUnderflow = Fp381.sub(pFp, Fp381.dirtyRef(a), Fp381.dirtyRef(dest));
        require(!isUnderflow, UnexpectedUnderflow());
    }

    function inverse(_T.Fp2 a) internal pure returns (_T.Fp2 result) {
        bytes memory resultBytes = new bytes(128);
        assembly {
            result := resultBytes
        }
        Fp381.inverse(a, result);
    }

    function inverse(_T.Fp2 a, _T.Fp2 dest) internal pure {
        bytes memory p64_2 = P64_2;
        _T.DirtyFp2 pFp2;
        assembly {
            pFp2 := p64_2
        }
        bool isUnderflow = Fp381.sub(pFp2, Fp381.dirtyRef(a), Fp381.dirtyRef(dest));
        require(!isUnderflow, UnexpectedUnderflow());
    }

    /**
     * @dev Converts an Fp field element to its byte representation
     * @param element The Fp field element to convert
     * @return result The byte representation of the field element
     */
    function mem(_T.Fp element) internal pure returns (bytes memory result) {
        assembly {
            result := element
        }
    }

    /**
     * @dev Converts an Fp2 field element to its byte representation
     * @param element The Fp2 field element to convert
     * @return result The byte representation of the field element
     */
    function mem(_T.Fp2 element) internal pure returns (bytes memory result) {
        assembly {
            result := element
        }
    }

    function mem(_T.DirtyFp element) internal pure returns (bytes memory result) {
        assembly {
            result := element
        }
    }

    function mem(_T.DirtyFp2 element) internal pure returns (bytes memory result) {
        assembly {
            result := element
        }
    }

    error FpInputTooLarge(uint256 length);
    error Fp2InputTooLarge(uint256 length);
    error UnexpectedUnderflow();
}