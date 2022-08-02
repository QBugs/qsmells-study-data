#!/usr/bin/env python
#
# ------------------------------------------------------------------------------
# Given a [qiskit.circuit.QuantumCircuit](https://qiskit.org/documentation/apidoc/circuit.html)
# object, this script "pretty print" it as a draw.
#
# Usage example:
#    python quantum_circuit_to_draw.py
#        --module-name <str, e.g., wrapper_ch04_02_teleport_fly>
#        --output-type <str, i.e., text, latex_source, or mpl>
#        --output-file <path, e.g., ch04_02_teleport_fly.>
# ------------------------------------------------------------------------------

import argparse
import pathlib
import importlib
import sys

def main():
    parser = argparse.ArgumentParser(description='Convert a quantum circuit object into a matrix.')
    parser.add_argument('--module-name', '-i', help='Module name that has the quantum circuit object `qc`', required=True, type=str)
    parser.add_argument('--output-type', '-t', help='Type of the output: text, latex_source, or mpl', required=True, type=str)
    parser.add_argument('--output-file', '-o', action='store', help='Output file', required=True, type=pathlib.Path)
    args = parser.parse_args()

    module_name: str = args.module_name
    output_type: str = args.output_type
    output_file: str = args.output_file.as_posix()

    wrapper = importlib.import_module(module_name)
    wrapper.qc.draw(output=output_type, filename=output_file, justify='none')

    sys.exit(0)

if __name__ == "__main__":
    main()

# EOF
