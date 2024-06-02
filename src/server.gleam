import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/uri
import parser

pub fn response_body(url: String) {
  url
}

fn nonce() {
  list.fold([0, 0, 0, 0, 0], "", fn(acc, _) {
    acc <> int.to_base36(int.random(10_000))
  })
}

pub fn get_query_parameter(query_string: String, key: String) {
  case uri.parse_query(query_string) {
    Error(Nil) -> ""
    Ok(kvs) -> {
      case
        list.find(kvs, fn(x) {
          let #(k, _) = x
          k == key
        })
      {
        Error(Nil) -> ""
        Ok(e) -> {
          let #(_, v) = e
          v
        }
      }
    }
  }
}

pub fn content_security_policy(url: String) {
  case uri.parse(url) {
    Error(_) -> ""
    Ok(v) ->
      case v.query {
        None -> ""
        Some(qs) ->
          get_query_parameter(qs, "csp")
          |> parser.modify_csp("script-src", "'nonce-" <> nonce() <> "'")
          |> parser.parsed_csp_to_string
      }
  }
}
