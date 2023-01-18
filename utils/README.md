# Utils

Directory with utility scripts, functions, data, etc., to support any analysis or experiment.

- [`scripts/quantum_circuit_to_draw.py`](scripts/quantum_circuit_to_draw.py)

Given a [qiskit.circuit.QuantumCircuit](https://qiskit.org/documentation/apidoc/circuit.html) object, this script "pretty print" it as a draw.

Usage example

```bash
python quantum_circuit_to_draw.py
    --module-name <str, e.g., wrapper_adapt_vqe>
    --output-type <str, i.e., text, latex_source, or mpl>
    --output-file <path, e.g., adapt_vqe.txt>
```

for example, to draw the quantum circuit of the quantum program `adapt_vqe` as a draw (feature support out-of-box by [qiskit](https://qiskit.org/documentation/stubs/qiskit.circuit.QuantumCircuit.draw.html)), run

```bash
# Load utility script
source "scripts/utils.sh"

# Activate custom Python virtual environment
_activate_virtual_environment

# Augment Python's PATH with our custom wrappers
export PYTHONPATH="../../subjects/scripts/wrappers:$PYTHONPATH"

python quantum_circuit_to_draw.py \
  --module-name wrapper_adapt_vqe \
  --output-type "text" \
  --output-file "../../subjects/data/generated/transpiled-quantum-circuit-as-draw/adapt_vqe.txt"

# Deactivate custom Python virtual environment
_deactivate_virtual_environment
```

which generates the `../../subjects/data/generated/transpiled-quantum-circuit-as-draw/adapt_vqe.tex` file with the following content

```
┌───┐   ┌──────────┐┌─────────┐┌───┐┌────────────────┐┌───┐┌─────────┐»
q_0: ───┤ X ├───┤ U1(-π/2) ├┤ U2(0,π) ├┤ X ├┤ Rz(-0.25*t[0]) ├┤ X ├┤ U2(0,π) ├»
├───┤   └──────────┘└──┬───┬──┘└─┬─┘└────────────────┘└─┬─┘└──┬───┬──┘»
q_1: ───┤ X ├──────────────────┤ X ├─────■──────────────────────■─────┤ X ├───»
┌──┴───┴──┐   ┌───┐       └─┬─┘                                  └─┬─┘   »
q_2: ┤ U2(0,π) ├───┤ X ├─────────■──────────────────────────────────────■─────»
└─────────┘   └─┬─┘                                                      »
q_3: ────────────────■────────────────────────────────────────────────────────»
                                                                      »
«     ┌─────────┐┌──────────┐┌─────────┐┌───┐┌───────────────┐┌───┐┌─────────┐»
...
```

- [`scripts/quantum_circuit_to_matrix.py`](scripts/quantum_circuit_to_matrix.py)

Given a [qiskit.circuit.QuantumCircuit](https://qiskit.org/documentation/apidoc/circuit.html) object, this script "pretty print" it as a coverage matrix.  Each row represents a quantum or classical bit, each column represents a timestamp in the circuit, and each cell represents a quantum operation performed in circuit.

Usage example through its API

```python
from quantum_circuit_to_matrix import Justify, qc2matrix

from qiskit import QuantumCircuit, QuantumRegister
reg = QuantumRegister(3, name='reg')
qc = QuantumCircuit(reg)
qc.x(reg[0])
qc.x(reg)
qc.x(reg[1])
qc.x(reg[0])
qc.x(reg[2])
qc.x(reg[1])

qc2matrix(qc, Justify.none, 'example.csv')
```

which prints out to the stdout the following dataframe

```
           1    2    3    4    5    6    7    8
q-reg-0  x()  x()  x()
q-reg-1                 x()  x()  x()
q-reg-2                                x()  x()
```

and to the provided output file (e.g., `example.csv`) the following matrix

```
;1;2;3;4;5;6;7;8
q-reg-0;x();x();x();;;;;
q-reg-1;;;;x();x();x();;
q-reg-2;;;;;;;x();x()
```

Usage example through its command line version

```bash
python quantum_circuit_to_matrix.py \
  --module-name <str, e.g., wrapper_ch04_02_teleport_fly> \
  [--justify <str, i.e., "left" or "none">] \
  [--transpile <bool, transpile the circuit, if enable>] \
  --output-file <path, e.g., ch04_02_teleport_fly.csv>
```

for example, to draw the quantum circuit of the quantum program `adapt_vqe` as a matrix (see Section V.A.1), run

```bash
# Load utility script
source "scripts/utils.sh"

# Activate custom Python virtual environment
_activate_virtual_environment

# Augment Python's PATH with our custom wrappers
export PYTHONPATH="../../subjects/scripts/wrappers:$PYTHONPATH"

python quantum_circuit_to_matrix.py \
  --module-name wrapper_adapt_vqe \
  --justify "left" \
  --transpile-circuit \
  --output-file "../../subjects/data/generated/quantum-circuit-as-matrix/adapt_vqe.csv"

# Deactivate custom Python virtual environment
_deactivate_virtual_environment
```

which generates the `../../subjects/data/generated/quantum-circuit-as-matrix/adapt_vqe.csv` file with the following content

```
;1
q-q-0;EvolvedOps(ParameterVectorElement,ParameterVectorElement)
q-q-1;EvolvedOps(ParameterVectorElement,ParameterVectorElement)
q-q-2;EvolvedOps(ParameterVectorElement,ParameterVectorElement)
q-q-3;EvolvedOps(ParameterVectorElement,ParameterVectorElement)
```

- [`scripts/utils.sh`](scripts/utils.sh) A set of utility functions for any bash script to ease the execution of repetitive tasks.

Usage example:

```bash
source "utils/scripts/utils.sh"
```

- [`statistics/utils.R`](statistics/utils.R) A set of utility functions for [R](https://www.r-project.org) to ease any statistical analysis.

Usage example:

```R
source('utils/statistics/utils.R')
```
