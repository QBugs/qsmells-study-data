#!/usr/bin/env python
#
# ------------------------------------------------------------------------------
# Given a [qiskit.circuit.QuantumCircuit](https://qiskit.org/documentation/apidoc/circuit.html)
# object, this script "pretty print" it as a coverage matrix.  Each row represents
# a quantum or classical bit, and each column represents an quantum operation
# performed in one or more quantum or classical bits.
#
# Usage example:
#    from quantum_circuit_to_binary_matrix import qc2matrix
#
#    from qiskit import QuantumCircuit, QuantumRegister
#    reg = QuantumRegister(3, name='reg')
#    qc = QuantumCircuit(reg)
#    qc.x(reg[0])
#    qc.x(reg)
#    qc.x(reg[1])
#    qc.x(reg[0])
#    qc.x(reg[2])
#    qc.x(reg[1])
#
#    qc2matrix(qc, 'example.csv')
#
# Which prints out to the stdout the following dataframe
#          x-0  x-1  x-2  x-3  x-4  x-5  x-6  x-7
# q-reg-0    1    1    0    0    0    1    0    0
# q-reg-1    0    0    1    0    1    0    0    1
# q-reg-2    0    0    0    1    0    0    1    0
# 
# and to the provided output file the following matrix
# ,x-0,x-1,x-2,x-3,x-4,x-5,x-6,x-7
# q-reg-0,1,1,0,0,0,1,0,0
# q-reg-1,0,0,1,0,1,0,0,1
# q-reg-2,0,0,0,1,0,0,1,0
#
# Or using its command line version as:
#    python quantum_circuit_to_binary_matrix.py
#        --module-name <str, e.g., wrapper_ch04_02_teleport_fly>
#        --output-file <path, e.g., ch04_02_teleport_fly.csv>
# ------------------------------------------------------------------------------

import argparse
import pathlib
import importlib
import sys

import numpy as np
import pandas as pd

from qiskit.circuit import QuantumCircuit
from qiskit.circuit.quantumcircuitdata import CircuitInstruction
from qiskit.circuit.instruction import Instruction
from qiskit.circuit.quantumregister import QuantumRegister, Qubit
from qiskit.circuit.classicalregister import ClassicalRegister, Clbit

def extract_qubit_id(qubit: Qubit) -> str:
    quantumRegister: QuantumRegister = qubit.register
    id = 'q-%s-%d' % (quantumRegister.name, qubit.index)
    return(id)

def extract_clbit_id(clbit: Clbit) -> str:
    classicalRegister: ClassicalRegister = clbit.register
    id = 'c-%s-%d' % (classicalRegister.name, clbit.index)
    return(id)

def extract_op_id(operation: Instruction) -> str:
    params_types = []
    for param in operation.params:
        params_types.append(str(type(param).__name__))
    id = '%s(%s)' % (operation.name, ','.join(params_types))
    return(id)

def qc2matrix(qc: QuantumCircuit, output_file_path) -> pd.DataFrame:
    # Collect QuantumCircuit's data
    qubits = qc.qubits
    clbits = qc.clbits
    qdata  = qc.data

    # Initialize matrix where the number of rows is equal to the number of qubits +
    # number of clbits and the number of columns is equal to the number of operations
    # in the circuit.  By default, each cell is initialized as False, as no qubit or
    # clbit has been involved in any operation.

    matrix = np.zeros((len(qubits)+len(clbits), len(qdata)), dtype=int)

    col_names = []
    row_names = []

    # Collect qubits' names
    for qubit in qubits:
        row_names.append(extract_qubit_id(qubit))
    # Collect clbits' names
    for clbit in clbits:
        row_names.append(extract_clbit_id(clbit))
    # Collect operations' names
    for index in range(len(qdata)):
        col_names.append('%s-%d' % (extract_op_id(qdata[index].operation), index))

    # Initialize 'matrix' as a dataframe and name rows and columns accordingly
    df = pd.DataFrame(matrix, columns=col_names, index=row_names)

    # Populate dataframe with operations' data
    for index in range(len(qdata)):
        circuitInstruction: CircuitInstruction = qdata[index]

        # Operation
        operation: Instruction = circuitInstruction.operation
        col_name = '%s-%d' % (extract_op_id(operation), index)

        # In some qubit(s) and/or clbit(s)
        op_qubits = circuitInstruction.qubits
        for op_qubit in op_qubits:
            df[col_name][extract_qubit_id(op_qubit)] = 1
        op_clbits = circuitInstruction.clbits
        for op_clbit in op_clbits:
            df[col_name][extract_clbit_id(op_clbit)] = 1

    sys.stdout.write(str(df) + '\n')
    df.to_csv(output_file_path, header=True, index=True, sep=';', mode='w')

    return(df)

def main():
    parser = argparse.ArgumentParser(description='Convert a quantum circuit object into a matrix.')
    parser.add_argument('--module-name', '-i', help='Module name that has the quantum circuit object `qc`', required=True, type=str)
    parser.add_argument('--output-file', '-o', action='store', help='Output file', required=True, type=pathlib.Path)
    args = parser.parse_args()

    module_name: str = args.module_name
    output_file: str = args.output_file.as_posix()

    wrapper = importlib.import_module(module_name)
    qc2matrix(wrapper.qc, output_file)

    sys.exit(0)

if __name__ == "__main__":
    main()

# EOF
