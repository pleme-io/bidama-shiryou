use("shiryou/toriyose/kyasshu", [:schema])

sdl = read_file(
  path_join(
    getenv("GEN_ROOT", "."),
    "bidamas/shiryou/toriyose/danpen/fixtures/schema/kensa.graphql"
  )
)

write_file(
  getenv("GEN_OUT", "bidamas/shiryou/toriyose/kyasshu/keys/kensa.json"),
  unlines([json_stringify(schema(sdl))])
)
