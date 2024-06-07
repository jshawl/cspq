import gleam/io
import gleam/regex
import gleeunit
import gleeunit/should
import server

pub fn main() {
  gleeunit.main()
}

pub fn params_test() {
  server.params("https://example.com/?a=1&b=2&c=3")
  |> should.equal([#("a", "1"), #("b", "2"), #("c", "3")])
  server.params("https://example.com/")
  |> should.equal([#("", "")])
}

pub fn get_query_param_test() {
  server.get_query_param([#("a", "1")], "a")
  |> should.equal("1")
}

pub fn base64_decode_test() {
  server.base64_decode("PHNjcmlwdD5jb25zb2xlLmxvZygneHNzIScpPC9zY3JpcHQ-")
  |> should.equal("<script>console.log('xss!')</script>")
}

pub fn get_response_body_test() {
  let assert Ok(re) = regex.from_string("<script>console.log\\('xss!'\\)</script>(.*)")
  re
  |> regex.check(server.get_response_body([
    #("html", "PHNjcmlwdD5jb25zb2xlLmxvZygneHNzIScpPC9zY3JpcHQ-"),
  ], "nonce"))
  |> should.be_true
}

pub fn create_nonce_test(){
  let assert Ok(re) = regex.from_string("[A-Z0-9]+")
  re
  |> regex.check(server.create_nonce())
  |> should.be_true
}
