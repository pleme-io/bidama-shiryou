use("shiryou/toriyose/danpen")

def printed(text, compact)
  format = if compact
    :compact
  else
    :graphql
  end
  shiryou::toriyose::danpen::render(
    shiryou::toriyose::danpen::parse(text),
    format
  )
rescue e
  "!#{e.kind}: #{e.message}"
end

def shown(findings)
  map((f) -> "#{f[:rule]}: #{f[:message]}", findings)
end

def schema_findings(text)
  shown(
    shiryou::toriyose::danpen::check(shiryou::toriyose::danpen::parse(text))
  )
rescue e
  ["#{e.kind}: #{e.message}"]
end

def prepared(text)
  shiryou::toriyose::danpen::schema_of(shiryou::toriyose::danpen::parse(text))
end

def document_findings(text, schema)
  shown(
    shiryou::toriyose::danpen::check(
      shiryou::toriyose::danpen::parse(text),
      schema
    )
  )
rescue e
  ["#{e.kind}: #{e.message}"]
end
