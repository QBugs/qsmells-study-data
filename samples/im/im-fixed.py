from qiskit import QuantumRegister, ClassicalRegister, QuantumCircuit

qreg_q = QuantumRegister(3, 'q')
creg_c = ClassicalRegister(2, 'c')
qc = QuantumCircuit(qreg_q, creg_c)

qc.h(qreg_q[0])

qc.cnot(qreg_q[0], qreg_q[1])
qc.cnot(qreg_q[0], qreg_q[2])
qc.h(qreg_q[0])

qc.measure(qreg_q[1], creg_c[0])
qc.measure(qreg_q[2], creg_c[1])

# ------------------------------------------------------------------------------

from qiskit import transpile

# Transpile
qc = transpile(qc, basis_gates=['u1', 'u2', 'u3', 'rz', 'sx', 'x', 'cx', 'id'], optimization_level=0)

# Draw
qc.draw(output='text', filename='im-fixed.txt', justify='left')
qc.draw(output='latex_source', filename='im-fixed.tex', justify='left')
qc.draw(output='mpl', filename='im-fixed.pdf', justify='left', fold=-1)
qc.draw(output='mpl', filename='im-fixed-folded.pdf', justify='left')

from quantum_circuit_to_matrix import Justify, qc2matrix
qc2matrix(qc, Justify.left, 'im-fixed.csv')
