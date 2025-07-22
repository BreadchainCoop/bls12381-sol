// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Fp381} from "../src/Fp.sol";
import {FpFixtures} from "../test/fixtures/FpFixtures.sol";
import {_T} from "../src/interface/Types.sol";

contract FpTest is Test, FpFixtures {
    using Fp381 for _T.DirtyFp;
    using Fp381 for _T.DirtyFp2;

    function test_clean() public {
        for (uint i = 0; i < cleanTests.length; i++) {
            CleanTest memory test_ = cleanTests[i];
            _T.DirtyFp dirtyFp = Fp381.newFp(test_.input);
            _T.Fp cleanFp = Fp381.clean(dirtyFp);
            assertEq(Fp381.mem(cleanFp), test_.clean);
        }
    }

    function test_nullify() public {
        for (uint i = 0; i < nullifyTests.length; i++) {
            NullifyTest memory test_ = nullifyTests[i];
            _T.DirtyFp dirtyFp = Fp381.newFp(test_.input);
            Fp381.nullify(dirtyFp);
            bytes memory result = Fp381.mem(Fp381.clean(dirtyFp));
            bytes memory expected = new bytes(64);
            assertEq(result, expected);
        }
    }

    function test_inverseFp1() public {
        for (uint i = 0; i < inverseTestsFp1.length; i++) {
            InverseTestFp1 memory test_ = inverseTestsFp1[i];
            _T.Fp fp = Fp381.clean(Fp381.newFp(test_.input));
            _T.Fp invertedFp = Fp381.inverse(fp);
            assertEq(Fp381.mem(invertedFp), test_.outputClean);
        }
    }

    function test_inverseFp2() public {
        for (uint i = 0; i < inverseTestsFp2.length; i++) {
            InverseTestFp2 memory test_ = inverseTestsFp2[i];
            _T.Fp2 fp2 = Fp381.clean(Fp381.newFp2(test_.input));
            _T.Fp2 invertedFp2 = Fp381.inverse(fp2);
            assertEq(Fp381.mem(invertedFp2), test_.outputClean);
        }
    }

    function test_addFp1() public {
        AddTestFp1 memory test_ = addTestsFp1[2];
        _T.DirtyFp a = Fp381.newFp(test_.inputA);
        _T.DirtyFp b = Fp381.newFp(test_.inputB);
        _T.DirtyFp c = Fp381.newFp(hex"");
        bool overflow = Fp381.add(a, b, c);
        assertEq(overflow, test_.overflow, "overflow mismatch");
        assertEq(Fp381.mem(c), test_.output, "result mismatch");
    }

    function test_subFp1() public {
        for (uint i = 0; i < subTestsFp1.length; i++) {
            SubTestFp1 memory test_ = subTestsFp1[i];
            _T.DirtyFp a = Fp381.newFp(test_.inputA);
            _T.DirtyFp b = Fp381.newFp(test_.inputB);
            _T.DirtyFp c = Fp381.newFp(hex"");
            bool underflow = Fp381.sub(a, b, c);
            assertEq(underflow, test_.underflow, "underflow mismatch");
            if (!underflow) {
                assertEq(Fp381.mem(c), test_.output, "result mismatch");
            }
        }
    }

    function test_addFp2() public {
        for (uint i = 0; i < addTestsFp2.length; i++) {
            AddTestFp2 memory test_ = addTestsFp2[i];
            _T.DirtyFp2 a = Fp381.newFp2(test_.inputA);
            _T.DirtyFp2 b = Fp381.newFp2(test_.inputB);
            _T.DirtyFp2 c = Fp381.newFp2(hex"");
            bool overflow = Fp381.add(a, b, c);
            if (overflow) {
                c.nullify();
            }
            assertEq(overflow, test_.overflow, "overflow mismatch");
            assertEq(Fp381.mem(c), test_.output, "result mismatch");
        }
    }

    function test_subFp2() public {
        for (uint i = 0; i < subTestsFp2.length; i++) {
            SubTestFp2 memory test_ = subTestsFp2[i];
            _T.DirtyFp2 a = Fp381.newFp2(test_.inputA);
            _T.DirtyFp2 b = Fp381.newFp2(test_.inputB);
            _T.DirtyFp2 c = Fp381.newFp2(hex"");
            bool underflow = Fp381.sub(a, b, c);
            if (underflow) {
                c.nullify();
            }
            assertEq(underflow, test_.underflow, "underflow mismatch");
            if (!underflow) {
                assertEq(Fp381.mem(c), test_.output, "result mismatch");
            }
        }
    }
}