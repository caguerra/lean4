def g (t : Nat) : Nat := match t with
  | (n+1) => match g n with
    | 0 => 0
    | m + 1 => match g (n - m) with
      | 0 => 0
      | m + 1 => g n
  | 0 => 0
decreasing_by all_goals sorry

attribute [simp] g

#check g.eq_1
#check g.eq_2

theorem ex3 : g (n + 1) = match g n with
    | 0 => 0
    | m + 1 => match g (n - m) with
      | 0 => 0
      | m + 1 => g n := by
  conv => lhs; unfold g
