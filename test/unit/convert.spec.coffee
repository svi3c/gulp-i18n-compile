convert = require "../../src/convert"

describe "convert", ->

  it "should turn the json into an object containing one object per locale", ->
    out = convert
      hello:
        en: "hello"
        de: "hallo"

    expect(out).toEqual
      en:
        hello: "hello"
      de:
        hello: "hallo"

  it "should preserve compressed keys", ->
    out = convert
      foo:
        bar:
          en: "baz"
      "foo.bar":
        en: "baz"

    expect(out).toEqual
      en:
        foo:
          bar: "baz"
        "foo.bar": "baz"