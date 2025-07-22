// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.25;

// internal name
interface _T {
    // pointers to bytes
    // NOTE: these types cannot be used in calldata
    type Fp is uint256;
    type Fp2 is uint256;
    type DirtyFp is uint256;
    type DirtyFp2 is uint256;
    type G1Point is uint256;
    type G2Point is uint256;

    struct Signature {
        // if short signature, pk is 256 bytes (G2), otherwise 128 bytes (G1)
        bytes pk;
        // if short signature, signature is 128 bytes (G1), otherwise 256 bytes (G2)
        bytes signature;
        bytes message;
    }
}

// external name
interface IBLSTypes is _T {}