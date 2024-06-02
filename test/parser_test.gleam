import gleam/dict
import gleeunit
import gleeunit/should
import parser

pub fn main() {
  gleeunit.main()
}

pub fn parse_csp_test() {
  let csp =
    parser.parse_csp("default-src 'none'; img-src 'self' https://example.com;")

  dict.get(csp, "default-src")
  |> should.equal(Ok(["'none'"]))

  dict.get(csp, "img-src")
  |> should.equal(Ok(["'self'", "https://example.com"]))
}

pub fn modify_csp_test() {
  let csp = "default-src 'none'; img-src 'self' https://example.com;"
  let modified_csp =
    parser.modify_csp(csp, "img-src", "https://not-example.com")
  dict.get(modified_csp, "img-src")
  |> should.equal(
    Ok(["'self'", "https://example.com", "https://not-example.com"]),
  )
}

pub fn parsed_csp_to_string_test() {
  let csp = "default-src 'none'; img-src 'self' https://example.com;"
  let parsed_csp = parser.parse_csp(csp)
  let stringified_csp = parser.parsed_csp_to_string(parsed_csp)
  stringified_csp
  |> should.equal(csp)
}
