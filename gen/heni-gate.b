@moduledoc """
heni-gate: every level of shiryou with a mutation file under `heni/mutations/` keeps the caught ratio `heni/ratio.baseline` records for it. A survivor below that ratio, an unsound run, a spec with no row and a row with no spec are each red. The project root is `GEN_ROOT`.

    key_of("heni/mutations/shiryou/toriyose/kyasshu.json") #=> "shiryou/toriyose/kyasshu"
"""

use("hadome", %i[orphans parse recorded])

use("heni", %i[fell? mutations report_text run score sound? survivors])

use("moji", [:trim])
use("retsu", %i[flat_map is_empty last reject size])
use("shisutemu", [:read_or])

CAUGHT = "heni-caught"

TOTAL = "heni-total"

@doc """
root: the project root the gate reads, `GEN_ROOT` or the working directory.

    string?(root) #=> true
"""
def root()
  getenv("GEN_ROOT", ".")
end

@doc """
specs: every mutation file under `heni/mutations/`, sorted.

    list?(specs) #=> true
"""
def specs()
  reject(
    (p) -> not ends_with?(p, ".json"),
    sort_keyed((p) -> p, walk_dir(path_join(root, "heni/mutations")))
  )
end

@doc """
key_of: a mutation file's key, its level path below `bidamas/`.

    key_of("x/heni/mutations/shiryou/happa.json") #=> "shiryou/happa"
"""
def key_of(spec_path)
  replace(last(split(spec_path, "heni/mutations/")), ".json", "")
end

@doc """
package_of: the level directory a mutation file mutates.

    ends_with?(package_of("heni/mutations/shiryou/shuusei.json"), "bidamas/shiryou/shuusei") #=> true
"""
def package_of(spec_path)
  path_join(root, path_join("bidamas", key_of(spec_path)))
end

@doc """
report: one heni run over a mutation file's level, with the blue running this program.
"""
def report(spec_path)
  run(
    {
      package: package_of(spec_path),
      mutations: mutations(json_parse(read_file(spec_path))),
      blue: self_exe,
      test: nil,
      tmp: getenv("TMPDIR", "/tmp")
    }
  )
end

@doc """
ratio_text: a caught ratio as `caught/total`.

    ratio_text({caught: 1, total: 2}) #=> "1/2"
"""
def ratio_text(q)
  "#{to_s(q[:caught])}/#{to_s(q[:total])}"
end

@doc """
recorded_ratio: the ratio the baseline records for a key, or nil.

    recorded_ratio([], "shiryou/happa") #=> nil
"""
def recorded_ratio(rows, key)
  c = recorded(rows, CAUGHT, key)
  t = recorded(rows, TOTAL, key)
  if c.nil? or t.nil?
    nil
  else
    {caught: c, total: t}
  end
end

@doc """
problems: what is wrong with one measured level against the baseline, empty when it holds.

    problems([], "k", {control: 1, results: [], caught: 0, survived: 0, refused: 0, blind: 0}) == [] #=> false
"""
def problems(rows, key, r)
  was = recorded_ratio(rows, key)
  now = score(r)
  if not sound?(r)
    ["#{key}: #{trim(report_text(r))}"]
  elsif was.nil?
    ["#{key}: caught #{ratio_text(now)} and the baseline has no row for it"]
  elsif fell?(was, now)
    names = survivors(r)
    why = if is_empty(names)
      "no survivor, so a caught mutation was removed"
    else
      "survived: #{join(names, ", ")}"
    end
    [
      "#{key}: caught #{ratio_text(now)}, below its recorded #{ratio_text(was)}; #{why}"
    ]
  else
    []
  end
end

@doc """
judge: every problem of the measured levels, and a baseline row no mutation file names.

    judge([], []) #=> []
"""
def judge(rows, measured)
  append(
    flat_map(measured, (m) -> problems(rows, m[:key], m[:r])),
    map(
      (k) -> "#{k}: recorded, and no mutation file names it",
      orphans(rows, CAUGHT, map((m) -> m[:key], measured))
    )
  )
end

test "every level holds its recorded caught ratio"
  rows = parse(read_or(path_join(root, "heni/ratio.baseline"), ""))
  assert size(specs) >= 5
  measured = map((s) -> {key: key_of(s), r: report(s)}, specs)
  bad = judge(rows, measured)
  if not is_empty(bad)
    write_stderr(unlines(bad))
  end
  assert is_empty(bad)
end

def fixture_run(verdicts)
  {
    control: 0,
    refused: 0,
    blind: 0,
    results: map((v) -> {name: "m-#{to_s(v[0])}", verdict: v[1]}, verdicts)
  }
end

test "a survivor below the recorded ratio names its level and itself"
  rows = parse(unlines(["heni-caught: kazu 2", "heni-total: kazu 2"]))
  held = fixture_run([[0, :caught], [1, :caught]])
  assert judge(rows, [{key: "kazu", r: held}]) == []
  fell = fixture_run([[0, :caught], [1, :survived]])
  assert judge(rows, [{key: "kazu", r: fell}]) ==
    ["kazu: caught 1/2, below its recorded 2/2; survived: m-1"]
  assert judge(rows, [{key: "kazu", r: fixture_run([])}]) ==
    ["kazu: caught 0/0, below its recorded 2/2; no survivor, so a caught mutation was removed"]
  assert judge([], [{key: "kazu", r: held}]) ==
    ["kazu: caught 2/2 and the baseline has no row for it"]
  assert judge(rows, []) == ["kazu: recorded, and no mutation file names it"]
  assert size(judge(rows, [{key: "kazu", r: assoc(held, :refused, 1)}])) == 1
end
