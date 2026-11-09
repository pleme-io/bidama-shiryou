@moduledoc """
toriyose (取り寄せ, fetching on order) — what a frontend asks for and keeps.

Three levels: `toriyose/danpen` (GraphQL documents: one grammar, parsed,
checked and rendered), `toriyose/outou` (a request answered over danpen's
documents) and `toriyose/kyasshu` (the normalized entity store of the
frontend data runtime). The root defines nothing; a `use("toriyose")` brings
all three.

    shiryou::toriyose::kyasshu::key(["User", 7]) #=> "User:7"
"""

test "the root reaches each of its levels by its full path"
  assert shiryou::toriyose::kyasshu::key(["User", 7]) == "User:7"
  assert shiryou::toriyose::danpen::render(
    shiryou::toriyose::danpen::parse("{a}")
  ) == unlines(["{", "  a", "}"])
  assert shiryou::toriyose::outou::request(
    shiryou::toriyose::outou::fixture,
    "{ hero { id } }"
  ) == {data: {"hero" => {"id" => "2001"}}}
end
