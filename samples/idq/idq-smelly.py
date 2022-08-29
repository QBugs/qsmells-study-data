from qiskit import QuantumRegister, ClassicalRegister, QuantumCircuit
from numpy import pi

qreg_q = QuantumRegister(3, 'q')
creg_c = ClassicalRegister(4, 'c')
qc = QuantumCircuit(qreg_q, creg_c)

qc.h(qreg_q)

qc.p(pi / 2, qreg_q[0])
qc.z(qreg_q[0])
qc.s(qreg_q[0])

qc.barrier()

qc.p(pi / 4, qreg_q[1])
qc.z(qreg_q[1])
qc.s(qreg_q[1])

qc.barrier()
qc.h(qreg_q[2])
qc.p(pi / 8, qreg_q[2])
qc.z(qreg_q[2])
qc.s(qreg_q[2])
qc.measure_all()


# ------------------------------------------------------------------------------

from qiskit import transpile

# Transpile
qc = transpile(qc, basis_gates=['u1', 'u2', 'u3', 'rz', 'sx', 'x', 'cx', 'id'], optimization_level=0)

# Draw
qc.draw(output='text', filename='idq-smelly.txt', justify='left')
qc.draw(output='latex_source', filename='idq-smelly.tex', justify='left')
qc.draw(output='mpl', filename='idq-smelly.pdf', justify='left', fold=-1)
qc.draw(output='mpl', filename='idq-smelly-folded.pdf', justify='left')

from quantum_circuit_to_binary_matrix import Justify, qc2matrix
qc2matrix(qc, Justify.left, 'idq-smelly.csv')
