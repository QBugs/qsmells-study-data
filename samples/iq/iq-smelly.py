from qiskit import QuantumRegister, QuantumCircuit
from numpy import pi

qreg_q = QuantumRegister(2, 'q')
qc = QuantumCircuit(qreg_q)

qc.h(qreg_q)

qc.p(pi / 2, qreg_q[0])
qc.barrier()

qc.p(pi / 4, qreg_q[1])

# ------------------------------------------------------------------------------

from qiskit import transpile

# Transpile
qc = transpile(qc, basis_gates=['u1', 'u2', 'u3', 'rz', 'sx', 'x', 'cx', 'id'], optimization_level=0)

# Draw
qc.draw(output='text', filename='iq-smelly.txt', justify='left')
qc.draw(output='latex_source', filename='iq-smelly.tex', justify='left')
qc.draw(output='mpl', filename='iq-smelly.pdf', justify='left', fold=-1)
qc.draw(output='mpl', filename='iq-smelly-folded.pdf', justify='left')

from quantum_circuit_to_matrix import Justify, qc2matrix
qc2matrix(qc, Justify.left, 'iq-smelly.csv')
