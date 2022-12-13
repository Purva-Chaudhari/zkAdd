#!/bin/bash

cd contracts/circuits

mkdir Add

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling Add.circom..."

# compile circuit

circom Add.circom --r1cs --wasm --sym -o Add
snarkjs r1cs info Add/Add.r1cs

# Start a new zkey and make a contribution

snarkjs groth16 setup Add/Add.r1cs powersOfTau28_hez_final_10.ptau Add/circuit_0000.zkey
snarkjs zkey contribute Add/circuit_0000.zkey Add/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey Add/circuit_final.zkey Add/verification_key.json

# generate solidity contract
snarkjs zkey export solidityverifier Add/circuit_final.zkey ../AddVerifier.sol

cd ../..