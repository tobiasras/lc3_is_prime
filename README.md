# LC-3 Prime Number Checker

This project is an LC-3 assembly program that reads a number from the keyboard, checks whether it is prime, prints the result, and then repeats forever.

## What the program does

- Prompts the user to enter a number.
- Accepts one-digit or two-digit decimal input (`0` to `99`).
- Rejects non-numeric input and asks again.
- Runs a primality check.
- Prints either:
  - `The number is a prime`
  - `The number is not a prime`

## Main flow

The main program in `is_prime.asm` follows this loop:

1. Initialize the stack pointer.
2. Call `readS` to read and parse input.
3. If input is invalid (`-1`), restart input.
4. Call `isPrime` to compute prime/non-prime.
5. Call `resultS` to print the result.
6. Repeat.

## Project structure

- `is_prime.asm`  
  Full program entry point and all routines in one file.

- `routines/`  
  Individual routine copies extracted from `is_prime.asm`:
  - `readS.asm`
  - `isNotNumber.asm`
  - `multiply.asm`
  - `isPrime.asm`
  - `resultS.asm`

- `flow_diagrams/`  
  Diagram exports that visualize routine/program logic.

## Routines overview

- `readS`  
  Reads keyboard input, validates characters, and returns a parsed number (or `-1` on invalid input).

- `isNotNumber`  
  Checks whether an ASCII character is a digit and converts it to numeric value.

- `multiply`  
  Multiplies two positive integers by repeated addition.

- `isPrime`  
  Returns `1` if input is prime, `0` otherwise.

- `resultS`  
  Prints the prime/not-prime message based on the flag in `R0`.

## How to run

Use any LC-3 simulator (for example, PennSim):

1. Open/load `is_prime.asm`.
2. Assemble the program.
3. Run from `.ORIG x3000`.
4. Type input in the console and press Enter.

