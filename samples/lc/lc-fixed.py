from qiskit import QuantumCircuit
from numpy import pi

qc = QuantumCircuit(1)






qc.x(0)

# ------------------------------------------------------------------------------

from qiskit import transpile

# Transpile
qc = transpile(qc, basis_gates=['u1', 'u2', 'u3', 'rz', 'sx', 'x', 'cx', 'id'], optimization_level=0)

# Draw
qc.draw(output='text', filename='lc-fixed.txt', justify='left')
qc.draw(output='latex_source', filename='lc-fixed.tex', justify='left')
qc.draw(output='mpl', filename='lc-fixed.pdf', justify='left', fold=-1)
qc.draw(output='mpl', filename='lc-fixed-folded.pdf', justify='left')

from quantum_circuit_to_binary_matrix import Justify, qc2matrix
qc2matrix(qc, Justify.left, 'lc-fixed.csv')
