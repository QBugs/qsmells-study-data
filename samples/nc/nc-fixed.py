from qiskit import QuantumCircuit, Aer
from qiskit import transpile
from qiskit.circuit import Parameter

theta = Parameter('0')

def init_circuit(theta):
    qc = QuantumCircuit(5, 1) # 5 Quantum and 1 Classical register

    qc.h(0)
    for i in range(4):
        qc.cx(i, i+1)

    qc.barrier()
    qc.rz(theta, range(5))
    qc.barrier()

    for i in reversed(range(4)):
        qc.cx(i, i+1)
    qc.h(0)
    qc.measure(0, 0)

    return qc

theta_range = [0.00, 0.25, 0.50, 0.75, 1.00]





qc = init_circuit(theta)
circuits = [qc.bind_parameters({theta: theta_val})
           for theta_val in theta_range]
backend = Aer.get_backend('qasm_simulator')
job = backend.run(transpile(circuits, backend))
job.result().get_counts()

# ------------------------------------------------------------------------------

from qiskit import transpile

# Transpile
qc = transpile(qc, basis_gates=['u1', 'u2', 'u3', 'rz', 'sx', 'x', 'cx', 'id'], optimization_level=0)

# Draw
qc.draw(output='text', filename='nc-fixed.txt', justify='left')
qc.draw(output='latex_source', filename='nc-fixed.tex', justify='left')
qc.draw(output='mpl', filename='nc-fixed.pdf', justify='left', fold=-1)
qc.draw(output='mpl', filename='nc-fixed-folded.pdf', justify='left')

from quantum_circuit_to_matrix import Justify, qc2matrix
qc2matrix(qc, Justify.left, 'nc-fixed.csv')
