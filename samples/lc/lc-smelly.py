from qiskit import QuantumCircuit
from numpy import pi

qc = QuantumCircuit(1)


qc.h(0)
qc.z(0)
qc.h(0)



# ------------------------------------------------------------------------------

from qiskit import transpile

# Transpile
qc = transpile(qc, basis_gates=['u1', 'u2', 'u3', 'rz', 'sx', 'x', 'cx', 'id'], optimization_level=0)

# Draw
qc.draw(output='text', filename='lc-smelly.txt', justify='left')
qc.draw(output='latex_source', filename='lc-smelly.tex', justify='left')
qc.draw(output='mpl', filename='lc-smelly.pdf', justify='left', fold=-1)
qc.draw(output='mpl', filename='lc-smelly-folded.pdf', justify='left')

from quantum_circuit_to_binary_matrix import Justify, qc2matrix
qc2matrix(qc, Justify.left, 'lc-smelly.csv')
