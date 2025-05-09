/-!
# Tests of the structure elaborator
-/

-- We want to see the exact constructors in tests.
set_option pp.structureInstances false
set_option pp.proofs true


/-!
Diamond, look at the constructors and flat constructors
-/
namespace Test1

structure S1 (α : Type) where
  x : α
  y : Nat

structure S2 (α : Type) extends S1 α where
  z : Nat

structure S3 (α : Type) extends S1 α where
  w : Nat

structure S4 (α : Type) extends S2 α, S3 α where
  x' : α

/-- info: Test1.S1.mk {α : Type} (x : α) (y : Nat) : S1 α -/
#guard_msgs in #check S1.mk
/-- info: Test1.S2.mk {α : Type} (toS1 : S1 α) (z : Nat) : S2 α -/
#guard_msgs in #check S2.mk
/-- info: Test1.S3.mk {α : Type} (toS1 : S1 α) (w : Nat) : S3 α -/
#guard_msgs in #check S3.mk
/-- info: Test1.S4.mk {α : Type} (toS2 : S2 α) (w : Nat) (x' : α) : S4 α -/
#guard_msgs in #check S4.mk
/--
info: def Test1.S1._flat_ctor : {α : Type} → α → Nat → S1 α :=
fun α x y => S1.mk x y
-/
#guard_msgs in #print S1._flat_ctor
/--
info: def Test1.S2._flat_ctor : {α : Type} → α → Nat → Nat → S2 α :=
fun α x y z => S2.mk (S1.mk x y) z
-/
#guard_msgs in #print S2._flat_ctor
/--
info: def Test1.S3._flat_ctor : {α : Type} → α → Nat → Nat → S3 α :=
fun α x y w => S3.mk (S1.mk x y) w
-/
#guard_msgs in #print S3._flat_ctor
/--
info: def Test1.S4._flat_ctor : {α : Type} → α → Nat → Nat → Nat → α → S4 α :=
fun α x y z w x' => S4.mk (S2.mk (S1.mk x y) z) w x'
-/
#guard_msgs in #print S4._flat_ctor
/-- info: Test1.S4._flat_ctor {α : Type} (x : α) (y z w : Nat) (x' : α) : S4 α -/
#guard_msgs in #check S4._flat_ctor

end Test1

/-!
Verify existence of default value definitions
-/
namespace TestD1

structure D1 where
  x := 1
structure D2 extends D1 where
structure D3 extends D1 where
  x := 3
structure D4 extends D2, D3

/--
info: @[reducible] def TestD1.D1.x._default : Nat :=
id 1
-/
#guard_msgs in #print D1.x._default
/-- error: unknown constant 'D2.x._default' -/
#guard_msgs in #print D2.x._default
/--
info: @[reducible] def TestD1.D2.x._inherited_default : Nat :=
id 1
-/
#guard_msgs in #print D2.x._inherited_default
/--
info: @[reducible] def TestD1.D3.x._default : Nat :=
id 3
-/
#guard_msgs in #print D3.x._default
/-- error: unknown constant 'D4.x._default' -/
#guard_msgs in #print D4.x._default
/--
info: @[reducible] def TestD1.D4.x._inherited_default : Nat :=
id 3
-/
#guard_msgs in #print D4.x._inherited_default

end TestD1

/-!
Verify default value definitions can support parameters
-/
namespace TestD2

structure D1 (α : Type) [Inhabited α] where
  x : α := default
structure D2 (α : Type) [Inhabited α] extends D1 α where
structure D3 extends D1 Nat where

/--
info: @[reducible] def TestD2.D1.x._default : {α : Type} → {inst : Inhabited α} → α :=
fun {α} {inst} => id default
-/
#guard_msgs in #print D1.x._default
/-- error: unknown constant 'D2.x._default' -/
#guard_msgs in #print D2.x._default
/--
info: @[reducible] def TestD2.D2.x._inherited_default : {α : Type} → {inst : Inhabited α} → α :=
fun {α} {inst} => id default
-/
#guard_msgs in #print D2.x._inherited_default
/-- error: unknown constant 'D3.x._default' -/
#guard_msgs in #print D3.x._default
/--
info: @[reducible] def TestD2.D3.x._inherited_default : Nat :=
id default
-/
#guard_msgs in #print D3.x._inherited_default

end TestD2

/-!
Make sure class parents can be used in successive parents
-/
namespace Test2_1

local infixl:70 (priority := high) " * " => Mul.mul

class AssociativeMul (α : Type _) [Mul α] : Prop where
  mul_assoc (x y z : α) : x * y * z = x * (y * z)

class Semigroup (α : Type _) extends Mul α, AssociativeMul α where

/--
info: Test2_1.Semigroup.mk.{u_1} {α : Type u_1} [toMul : Mul α] [toAssociativeMul : AssociativeMul α] : Semigroup α
-/
#guard_msgs in #check Semigroup.mk
/--
info: def Test2_1.Semigroup._flat_ctor.{u_1} : {α : Type u_1} →
  (mul : α → α → α) → (∀ (x y z : α), @Eq α (mul (mul x y) z) (mul x (mul y z))) → Semigroup α :=
fun α mul mul_assoc => @Semigroup.mk α (@Mul.mk α mul) (@AssociativeMul.mk α (@Mul.mk α mul) mul_assoc)
-/
#guard_msgs in set_option pp.explicit true in #print Semigroup._flat_ctor
/--
info: Test2_1.Semigroup._flat_ctor.{u_1} {α : Type u_1} (mul : α → α → α)
  (mul_assoc : ∀ (x y z : α), @Eq α (mul (mul x y) z) (mul x (mul y z))) : Semigroup α
-/
#guard_msgs in set_option pp.explicit true in #check Semigroup._flat_ctor

end Test2_1

/-!
Make sure instances can come from parents with overlapping fields
-/
namespace Test2_2

structure Add2 (α : Type _) where
  add : α → α → α

class Add3 (α : Type _) extends Add2 α, Add α where
  h (x : α) : x + x = x

/--
info: Test2_2.Add3._flat_ctor.{u_1} {α : Type u_1} (add : α → α → α)
  (h : ∀ (x : α), @Eq α (@HAdd.hAdd α α α (@instHAdd α (@Add.mk α add)) x x) x) : Add3 α
-/
#guard_msgs in set_option pp.explicit true in #check Add3._flat_ctor

end Test2_2

/-!
Example that used to be in a comment at `getFieldDefaultValue?`.
The issue was that the default value function was in terms of subobject fields,
so there could be a cyclic dependency.
With a field-centric view in #7302, this is no longer an issue to consider.
-/
namespace Test3

structure A where
  a : Nat

structure B where
  a : Nat
  b : Nat
  c : Nat

structure C extends B where
  d : Nat
  c := b + d

structure D extends A, C

/--
info: @[reducible] def Test3.D.c._inherited_default : Nat → Nat → Nat :=
fun b d => @id Nat (@HAdd.hAdd Nat Nat Nat (@instHAdd Nat instAddNat) b d)
-/
#guard_msgs in set_option pp.explicit true in #print D.c._inherited_default

end Test3

/-!
Make sure we can fill in `toMagma` at the use of `mul`.
It used to be (before #7302) that `mul` would see that the type of `a`, `b`, and `c` were `toMagma.α`,
which would cause unification to fill in the `M` argument.
However, now the types of these variables are just `α`, with no connection to `toMagma`.
We use the heuristic that parent structures should effectively be singleton types while elaborating fields,
and so the `?M : Magma` metavariable should be assigned with `toMagma`.
-/

namespace Test4

structure Magma where
  α   : Type u
  mul : α → α → α

instance : CoeSort Magma (Type u) where
  coe s := s.α

abbrev mul {M : Magma} (a b : M) : M :=
  M.mul a b

local infixl:70 (priority := high) " * " => mul

structure Semigroup extends Magma where
  mul_assoc (a b c : α) : a * b * c = a * (b * c)

/--
info: Test4.Semigroup.mk.{u_1} (toMagma : Magma)
  (mul_assoc :
    ∀ (a b c : toMagma.α), @Eq toMagma.α (@mul toMagma (@mul toMagma a b) c) (@mul toMagma a (@mul toMagma b c))) :
  Semigroup
-/
#guard_msgs in set_option pp.explicit true in #check Semigroup.mk

/--
info: def Test4.Semigroup._flat_ctor.{u_1} : (α : Type u_1) →
  (mul : α → α → α) →
    (∀ (a b c : α),
        @Eq α (@Test4.mul (Magma.mk α mul) (@Test4.mul (Magma.mk α mul) a b) c)
          (@Test4.mul (Magma.mk α mul) a (@Test4.mul (Magma.mk α mul) b c))) →
      Semigroup :=
fun α mul mul_assoc => Semigroup.mk (Magma.mk α mul) mul_assoc
-/
#guard_msgs in set_option pp.explicit true in #print Semigroup._flat_ctor

end Test4

/-!
Default value involving parent instance
-/
namespace Test5

structure C (α : Type) extends Mul α where
  (x y : α)
  z := x * y

/--
info: @[reducible] def Test5.C.z._default : {α : Type} → (α → α → α) → α → α → α :=
fun {α} mul x y => @id α (@HMul.hMul α α α (@instHMul α (@Mul.mk α mul)) x y)
-/
#guard_msgs in set_option pp.explicit true in #print C.z._default

end Test5

/-!
Test from a docstring in Elab/StructInst, to check computed defaults.
-/
namespace Test6

structure A where
  x : Nat := 1

structure B extends A where
  y : Nat := x + 1
  x := y + 1

structure C extends B where
  z : Nat := 2*y
  x := z + 3

/--
info: @[reducible] def Test6.A.x._default : Nat :=
id 1
-/
#guard_msgs in #print A.x._default
/--
info: @[reducible] def Test6.B.y._default : Nat → Nat :=
fun x => id (x + 1)
-/
#guard_msgs in #print B.y._default
/--
info: @[reducible] def Test6.B.x._default : Nat → Nat :=
fun y => id (y + 1)
-/
#guard_msgs in #print B.x._default
/--
info: @[reducible] def Test6.C.x._default : Nat → Nat :=
fun z => id (z + 3)
-/
#guard_msgs in #print C.x._default
/--
info: @[reducible] def Test6.C.y._inherited_default : Nat → Nat :=
fun x => id (x + 1)
-/
#guard_msgs in #print C.y._inherited_default
/--
info: @[reducible] def Test6.C.z._default : Nat → Nat :=
fun y => id (2 * y)
-/
#guard_msgs in #print C.z._default

end Test6

/-!
Dependent types to an inherited field
-/
namespace Test7

structure A1 where
  n : Nat
structure A2 extends A1 where
  h : n > 0

/--
info: def Test7.A2._flat_ctor : (n : Nat) → n > 0 → A2 :=
fun n h => A2.mk (A1.mk n) h
-/
#guard_msgs in #print A2._flat_ctor

end Test7
