from qiskit import QuantumCircuit

qc = QuantumCircuit(3)
qc.unitary([
 [1, 0, 0, 0, 0, 0, 0, 0],
 [0, 1, 0, 0, 0, 0, 0, 0],
 [0, 0, 1, 0, 0, 0, 0, 0],
 [0, 0, 0, 1, 0, 0, 0, 0],
 [0, 0, 0, 0, 1, 0, 0, 0],
 [0, 0, 0, 0, 0, 1, 0, 0],
 [0, 0, 0, 0, 0, 0, 0, 1],
 [0, 0, 0, 0, 0, 0, 1, 0]
], [0, 1, 2])

# ------------------------------------------------------------------------------

from qiskit import transpile
from quantum_circuit_to_binary_matrix import Justify, qc2matrix

# Transpile
a = transpile(qc, basis_gates=['u1', 'u2', 'u3', 'rz', 'sx', 'x', 'cx', 'id', 'unitary'], optimization_level=0)

# Draw
a.draw(output='text', filename='cg-hidden-smelly.txt', justify='left')
a.draw(output='latex_source', filename='cg-hidden-smelly.tex', justify='left')
a.draw(output='mpl', filename='cg-hidden-smelly.pdf', justify='left', fold=-1)
a.draw(output='mpl', filename='cg-hidden-smelly-folded.pdf', justify='left')

qc2matrix(a, Justify.left, 'cg-hidden-smelly.csv')

# Transpile
b = transpile(qc, basis_gates=['u1', 'u2', 'u3', 'rz', 'sx', 'x', 'cx', 'id'], optimization_level=0)

# Draw
b.draw(output='text', filename='cg-smelly.txt', justify='left')
b.draw(output='latex_source', filename='cg-smelly.tex', justify='left')
b.draw(output='mpl', filename='cg-smelly.pdf', justify='left', fold=-1)
b.draw(output='mpl', filename='cg-smelly-folded.pdf', justify='left')

qc2matrix(b, Justify.left, 'cg-smelly.csv')
