
import random
from py_ecc.bls12_381 import field_modulus

# Usage:
# python3 generate_fp_fixtures.py > test/fixtures/FpFixtures.sol

STRUCTS = \
"""
    struct CleanTest {
        bytes input;
        bytes clean;
    }

    struct NullifyTest {
        bytes input;
    }

    struct InverseTestFp1 {
        bytes input;
        bytes outputClean;
    }

    struct InverseTestFp2 {
        bytes input;
        bytes outputClean;
    }

    struct AddTestFp1 {
        bytes inputA;
        bytes inputB;
        bytes output;
        bool overflow;
    }

    struct SubTestFp1 {
        bytes inputA;
        bytes inputB;
        bytes output;
        bool underflow;
    }

    struct AddTestFp2 {
        bytes inputA;
        bytes inputB;
        bytes output;
        bool overflow;
    }

    struct SubTestFp2 {
        bytes inputA;
        bytes inputB;
        bytes output;
        bool underflow;
    }

    CleanTest[] internal cleanTests;
    NullifyTest[] internal nullifyTests;
    InverseTestFp1[] internal inverseTestsFp1;
    InverseTestFp2[] internal inverseTestsFp2; 
    AddTestFp1[] internal addTestsFp1;
    SubTestFp1[] internal subTestsFp1;
    AddTestFp2[] internal addTestsFp2;
    SubTestFp2[] internal subTestsFp2;
"""

def sol_bytes(x: int) -> str:
    return f"{x:0128x}"

def sol_bytes_fp2(c0: int, c1: int) -> str:
    return f"{c0:0128x}{c1:0128x}"

def clean_tests(r: random.Random, count: int):
    inputs = [r.randbytes(64) for _ in range(count)]
    ints = [int.from_bytes(a, "big") for a in inputs]
    fps = [x % field_modulus for x in ints]
    fixtures = [f"cleanTests.push(CleanTest({{ input: hex\"{sol_bytes(x)}\", clean: hex\"{sol_bytes(y)}\" }}));" for x, y in zip(ints, fps)]
    
    return fixtures

def nullify_tests(r: random.Random, count: int):
    inputs = [r.randbytes(64) for _ in range(count)]
    ints = [int.from_bytes(a, "big") for a in inputs]
    fixtures = [f"nullifyTests.push(NullifyTest({{ input: hex\"{sol_bytes(x)}\" }}));" for x in ints]
    return fixtures

def inverse_tests_fp1(r: random.Random, count: int):
    inputs = [r.randrange(0, field_modulus) for _ in range(count)]
    inverses = [(field_modulus - i) % field_modulus for i in inputs]
    fixtures = [f"inverseTestsFp1.push(InverseTestFp1({{ input: hex\"{sol_bytes(x)}\", outputClean: hex\"{sol_bytes(y)}\" }}));" for x, y in zip(inputs, inverses)]
    return fixtures

def inverse_tests_fp2(r: random.Random, count: int):
    inputs = [(r.randrange(0, field_modulus), r.randrange(0, field_modulus)) for _ in range(count)]
    inverses = [((field_modulus - c0) % field_modulus, (field_modulus - c1) % field_modulus) for c0, c1 in inputs]
    fixtures = [f"inverseTestsFp2.push(InverseTestFp2({{ input: hex\"{sol_bytes_fp2(x[0], x[1])}\", outputClean: hex\"{sol_bytes_fp2(y[0], y[1])}\" }}));" for x, y in zip(inputs, inverses)]
    return fixtures

def add_tests_fp1(r: random.Random, count: int):
    MAX_VAL = 2**512
    no_overflow_count = count // 2
    overflow_count = count - no_overflow_count

    fixtures = []

    for _ in range(no_overflow_count):
        a = r.randrange(0, MAX_VAL // 2)
        b = r.randrange(0, MAX_VAL // 2)
        c = a + b
        fixtures.append(f"addTestsFp1.push(AddTestFp1({{ inputA: hex\"{sol_bytes(a)}\", inputB: hex\"{sol_bytes(b)}\", output: hex\"{sol_bytes(c)}\", overflow: false }}));")

    for _ in range(overflow_count):
        a = r.randrange(MAX_VAL // 2, MAX_VAL)
        b = r.randrange(MAX_VAL // 2, MAX_VAL)
        c = (a + b) % MAX_VAL
        fixtures.append(f"addTestsFp1.push(AddTestFp1({{ inputA: hex\"{sol_bytes(a)}\", inputB: hex\"{sol_bytes(b)}\", output: hex\"{sol_bytes(0)}\", overflow: true }}));")

    return fixtures

def sub_tests_fp1(r: random.Random, count: int):
    MAX_VAL = 2**512
    no_underflow_count = count // 2
    underflow_count = count - no_underflow_count
    
    fixtures = []

    for _ in range(no_underflow_count):
        a = r.randrange(MAX_VAL // 2, MAX_VAL)
        b = r.randrange(0, MAX_VAL // 2)
        c = a - b
        fixtures.append(f"subTestsFp1.push(SubTestFp1({{ inputA: hex\"{sol_bytes(a)}\", inputB: hex\"{sol_bytes(b)}\", output: hex\"{sol_bytes(c)}\", underflow: false }}));")

    for _ in range(underflow_count):
        a = r.randrange(0, MAX_VAL // 2)
        b = r.randrange(MAX_VAL // 2, MAX_VAL)
        c = (a - b + MAX_VAL) % MAX_VAL
        fixtures.append(f"subTestsFp1.push(SubTestFp1({{ inputA: hex\"{sol_bytes(a)}\", inputB: hex\"{sol_bytes(b)}\", output: hex\"{sol_bytes(0)}\", underflow: true }}));")
        
    return fixtures

def add_tests_fp2(r: random.Random, count: int):
    MAX_VAL = 2**512
    fixtures = []
    
    for i in range(count):
        case = i % 4
        a0, b0, overflow0 = 0, 0, False
        a1, b1, overflow1 = 0, 0, False

        if case == 0:
            a0 = r.randrange(0, MAX_VAL // 2)
            b0 = r.randrange(0, MAX_VAL // 2)
            a1 = r.randrange(0, MAX_VAL // 2)
            b1 = r.randrange(0, MAX_VAL // 2)
        elif case == 1:
            a0 = r.randrange(MAX_VAL // 2, MAX_VAL)
            b0 = r.randrange(MAX_VAL // 2, MAX_VAL)
            a1 = r.randrange(0, MAX_VAL // 2)
            b1 = r.randrange(0, MAX_VAL // 2)
        elif case == 2:
            a0 = r.randrange(0, MAX_VAL // 2)
            b0 = r.randrange(0, MAX_VAL // 2)
            a1 = r.randrange(MAX_VAL // 2, MAX_VAL)
            b1 = r.randrange(MAX_VAL // 2, MAX_VAL)
        elif case == 3:
            a0 = r.randrange(MAX_VAL // 2, MAX_VAL)
            b0 = r.randrange(MAX_VAL // 2, MAX_VAL)
            a1 = r.randrange(MAX_VAL // 2, MAX_VAL)
            b1 = r.randrange(MAX_VAL // 2, MAX_VAL)

        c0, overflow0 = (a0 + b0) % MAX_VAL, (a0 + b0) >= MAX_VAL
        c1, overflow1 = (a1 + b1) % MAX_VAL, (a1 + b1) >= MAX_VAL

        overflow = overflow0 or overflow1
        
        fixtures.append(f"addTestsFp2.push(AddTestFp2({{ inputA: hex\"{sol_bytes_fp2(a0, a1)}\", inputB: hex\"{sol_bytes_fp2(b0, b1)}\", output: hex\"{sol_bytes_fp2(c0, c1) if not overflow else sol_bytes_fp2(0, 0)}\", overflow: {str(overflow).lower()} }}));")

    return fixtures

def sub_tests_fp2(r: random.Random, count: int):
    MAX_VAL = 2**256
    fixtures = []

    for i in range(count):
        case = i % 4
        a0, b0, underflow0 = 0, 0, False
        a1, b1, underflow1 = 0, 0, False

        if case == 0:
            a0 = r.randrange(MAX_VAL // 2, MAX_VAL)
            b0 = r.randrange(0, MAX_VAL // 2)
            a1 = r.randrange(MAX_VAL // 2, MAX_VAL)
            b1 = r.randrange(0, MAX_VAL // 2)
        elif case == 1:
            a0 = r.randrange(0, MAX_VAL // 2)
            b0 = r.randrange(MAX_VAL // 2, MAX_VAL)
            a1 = r.randrange(MAX_VAL // 2, MAX_VAL)
            b1 = r.randrange(0, MAX_VAL // 2)
        elif case == 2:
            a0 = r.randrange(MAX_VAL // 2, MAX_VAL)
            b0 = r.randrange(0, MAX_VAL // 2)
            a1 = r.randrange(0, MAX_VAL // 2)
            b1 = r.randrange(MAX_VAL // 2, MAX_VAL)
        elif case == 3:
            a0 = r.randrange(0, MAX_VAL // 2)
            b0 = r.randrange(MAX_VAL // 2, MAX_VAL)
            a1 = r.randrange(0, MAX_VAL // 2)
            b1 = r.randrange(MAX_VAL // 2, MAX_VAL)

        c0, underflow0 = (a0 - b0 + MAX_VAL) % MAX_VAL, a0 < b0
        c1, underflow1 = (a1 - b1 + MAX_VAL) % MAX_VAL, a1 < b1
        underflow = underflow0 or underflow1

        fixtures.append(f"subTestsFp2.push(SubTestFp2({{ inputA: hex\"{sol_bytes_fp2(a0, a1)}\", inputB: hex\"{sol_bytes_fp2(b0, b1)}\", output: hex\"{sol_bytes_fp2(c0, c1) if not underflow else sol_bytes_fp2(0, 0)}\", underflow: {str(underflow).lower()} }}));")
    
    return fixtures

def main():
    r = random.Random(1234)
    count = 4
    lines = clean_tests(r, count) + \
        nullify_tests(r, count) + \
        inverse_tests_fp1(r, count) + \
        inverse_tests_fp2(r, count) + \
        add_tests_fp1(r, count) + \
        sub_tests_fp1(r, count) + \
        add_tests_fp2(r, count) + \
        sub_tests_fp2(r, count)

    lines = ["        " + line for line in lines]
    contract = "\n".join(lines)
    contract = f"// SPDX-License-Identifier: GPL-3.0\npragma solidity >=0.8.25;\n\nabstract contract FpFixtures {{{STRUCTS}\n    constructor() {{\n{contract}\n    }}\n}}"
    print(contract)

if __name__ == "__main__":
    main()
