@moduledoc """
shiryou (資料, materials): the blue bidamas for data a program declares and keeps: fetched frontend data, amendments and template leaves. Each is a level of this tree, reached as `shiryou::<level>::<word>` after `use("shiryou/<level>")`.

    length(members) #=> 3
"""

@doc """
members: the levels of shiryou, in the order they joined it.

    nth(0, members) #=> "toriyose"
"""
def members()
  %w[toriyose shuusei happa]
end

test "members names each level once"
  assert length(members) == 3
  assert members[0] == "toriyose"
end
