using MethodOfLines, Test, ModelingToolkit

@testset "count differentials 1D" begin
    @parameters t x
    @variables u(..)
    Dt = Differential(t)

    Dx = Differential(x)
    eq  = Dt(u(t,x)) ~ -Dx(u(t,x))
    @test first(MethodOfLines.differential_order(eq.rhs, x.val)) == 1
    @test isempty(MethodOfLines.differential_order(eq.rhs, t.val))
    @test first(MethodOfLines.differential_order(eq.lhs, t.val)) == 1
    @test isempty(MethodOfLines.differential_order(eq.lhs, x.val))

    Dxx = Differential(x)^2
    eq  = Dt(u(t,x)) ~ Dxx(u(t,x))
    @test first(MethodOfLines.differential_order(eq.rhs, x.val)) == 2
    @test isempty(MethodOfLines.differential_order(eq.rhs, t.val))
    @test first(MethodOfLines.differential_order(eq.lhs, t.val)) == 1
    @test isempty(MethodOfLines.differential_order(eq.lhs, x.val))

    Dxxxx = Differential(x)^4
    eq  = Dt(u(t,x)) ~ -Dxxxx(u(t,x))
    @test first(MethodOfLines.differential_order(eq.rhs, x.val)) == 4
    @test isempty(MethodOfLines.differential_order(eq.rhs, t.val))
    @test first(MethodOfLines.differential_order(eq.lhs, t.val)) == 1
    @test isempty(MethodOfLines.differential_order(eq.lhs, x.val))
end

@testset "count differentials 2D" begin
    @parameters t x y
    @variables u(..)
    Dxx = Differential(x)^2
    Dyy = Differential(y)^2
    Dt = Differential(t)

    eq  = Dt(u(t,x,y)) ~ Dxx(u(t,x,y)) + Dyy(u(t,x,y))
    @test first(MethodOfLines.differential_order(eq.rhs, x.val)) == 2
    @test first(MethodOfLines.differential_order(eq.rhs, y.val)) == 2
    @test isempty(MethodOfLines.differential_order(eq.rhs, t.val))
    @test first(MethodOfLines.differential_order(eq.lhs, t.val)) == 1
    @test isempty(MethodOfLines.differential_order(eq.lhs, x.val))
    @test isempty(MethodOfLines.differential_order(eq.lhs, y.val))
end

@testset "count with mixed terms" begin
    @parameters t x y
    @variables u(..)
    Dxx = Differential(x)^2
    Dyy = Differential(y)^2
    Dx = Differential(x)
    Dy = Differential(y)
    Dt = Differential(t)

    eq  = Dt(u(t,x,y)) ~ Dxx(u(t,x,y)) + Dyy(u(t,x,y)) + Dx(Dy(u(t,x,y)))
    @test MethodOfLines.differential_order(eq.rhs, x.val) == Set([2, 1])
    @test MethodOfLines.differential_order(eq.rhs, y.val) == Set([2, 1])
end

@testset "Kuramoto–Sivashinsky equation" begin
    @parameters x, t
    @variables u(..)
    Dt = Differential(t)
    Dx = Differential(x)
    Dx2 = Differential(x)^2
    Dx3 = Differential(x)^3
    Dx4 = Differential(x)^4

    α = 1
    β = 4
    γ = 1
    eq = Dt(u(x,t)) + u(x,t)*Dx(u(x,t)) + α*Dx2(u(x,t)) + β*Dx3(u(x,t)) + γ*Dx4(u(x,t)) ~ 0
    @test MethodOfLines.differential_order(eq.lhs, x.val) == Set([4, 3, 2, 1])
end