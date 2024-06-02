import gleam/regex
import gleeunit
import gleeunit/should
import server

pub fn main() {
  gleeunit.main()
}

pub fn get_query_parameter_test() {
  server.get_query_parameter("a=1&b=2", "a")
  |> should.equal("1")

  server.get_query_parameter("a=1&b=2", "b")
  |> should.equal("2")
}

pub fn content_security_policy_test() {
  let existing_csp = "script-src 'none'"
  let csp =
    server.content_security_policy("https://example.com/?csp=" <> existing_csp)
  let assert Ok(re) = regex.from_string(existing_csp <> " 'nonce-(.*)'")
  regex.check(with: re, content: csp)
  |> should.be_true
}
