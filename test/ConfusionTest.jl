module ConfusionTest

using Base.Test
using ForwardDiff

using Base.Test


# Perturbation Confusion (Issue #83) #
#------------------------------------#

D = ForwardDiff.derivative

@test D(x -> x * D(y -> x + y, 1), 1) == 1
@test ForwardDiff.gradient(v -> sum(v) * D(y -> y * norm(v), 1), [1]) == ForwardDiff.gradient(v -> sum(v) * norm(v), [1])



const A = rand(10,8)
y = rand(10)
x = rand(8)

@test A == ForwardDiff.jacobian(x) do x
    ForwardDiff.gradient(y) do y
        dot(y, A*x)
    end
end

# Issue #238                         #
#------------------------------------#

m,g = 1, 9.8
t = 1
q = [1,2]
q̇ = [3,4]
L(t,q,q̇) = m/2 * dot(q̇,q̇) - m*g*q[2]

∂L∂q̇(L, t, q, q̇) = ForwardDiff.gradient(a->L(t,q,a), q̇)
Dqq̇(L, t, q, q̇) = ForwardDiff.jacobian(a->∂L∂q̇(L,t,a,q̇), q)
@test Dqq̇(L, t, q, q̇)  == zeros(2,2)


q = [1,2]
p = [5,6]
function Legendre_transformation(F, w)
    z = zeros(w)
    M = ForwardDiff.hessian(F, z)
    b = ForwardDiff.gradient(F, z)
    v = cholfact(M)\(w-b)
    dot(w,v) - F(v)
end
function Lagrangian2Hamiltonian(Lagrangian, t, q, p)
    L = q̇ -> Lagrangian(t, q, q̇)
    Legendre_transformation(L, p)
end

Lagrangian2Hamiltonian(L, t, q, p)
@test ForwardDiff.gradient(a->Lagrangian2Hamiltonian(L, t, a, p), q) == [0.0,g]


end # module
