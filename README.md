## BLS12381-sol
```mermaid
classDiagram

    class BLS12381Lib {
        <<abstract>>
        <<library>>
        +address G1_ADD_PRECOMPILE
        +address G1_MSM_PRECOMPILE
        +address G2_ADD_PRECOMPILE
        +address G2_MSM_PRECOMPILE
        +address PAIRING_CHECK_PRECOMPILE
        +address MAP_FP_TO_G1_PRECOMPILE
        +address MAP_FP2_TO_G2_PRECOMPILE
        +bytes G1_GENERATOR
        +bytes G1_GENERATOR_NEG
        +bytes G2_GENERATOR
        +bytes G2_GENERATOR_NEG
        +g1Generator()
        +g2Generator()
        +verifySignatureG1()
        +verifySignatureG2()
        +mulBaseG1()
        +mulBaseG2()
        +mulG1()
        +mulG2()
        +addG1()
        +addG2()
        +mapFpToG1()
        +mapFp2ToG2()
        +x()
        +y()
        +mem()
    }

    class RFC9380 {
        <<abstract>>
        +uint256 B_IN_BYTES
        +uint256 S_IN_BYTES
        +uint256 L
        +bytes P
        +string HASH_TO_G1_DST
        +string HASH_TO_G2_DST
        +hashToG1()
        +hashToG2()
        +hashToFp()
        +hashToFp2()
        +expandMessageXMD()
        +I2OSP()
    }


```

## Documentation

A utility for verifying BLS12-381 signatures are defined by [EIP2537](https://eips.ethereum.org/EIPS/eip-2537)
## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
