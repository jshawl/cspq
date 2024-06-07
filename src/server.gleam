import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html
import parser

pub type Request

pub type Response

pub type Params =
  List(#(String, String))

pub type Headers =
  List(#(String, String))

@external(javascript, "./ffi.mjs", "response")
pub fn response(
  status: Int,
  headers: List(#(String, String)),
  body: String,
) -> Response

@external(javascript, "./ffi.mjs", "url")
pub fn url(req: Request) -> String

pub fn handle_request(request: Request) -> Response {
  let nonce = create_nonce()
  let query_parameters = request |> url |> params
  let headers = query_parameters |> get_response_headers(nonce)
  let html = query_parameters |> get_response_body(nonce)
  response(200, headers, html)
}

pub fn params(url: String) -> Params {
  case string.split(url, "?") {
    [_, query_string] -> query_string
    [] | [_] | [_, _, ..] -> ""
  }
  |> string.split("&")
  |> list.map(fn(x) {
    case string.split(x, "=") {
      [key, value] -> #(key, value)
      [] | [_] | [_, _, ..] -> #("", "")
    }
  })
}

pub fn get_query_param(params: Params, key: String) -> String {
  case
    list.find(params, fn(x) {
      let #(k, _) = x
      k == key
    })
  {
    Error(Nil) -> ""
    Ok(f) -> {
      let #(_, v) = f
      v
    }
  }
}

pub fn base64_decode(string: String) -> String {
  case bit_array.base64_url_decode(string) {
    Error(Nil) -> ""
    Ok(decoded) ->
      case bit_array.to_string(decoded) {
        Error(Nil) -> ""
        Ok(s) -> s
      }
  }
}

pub fn app_html(nonce: String) -> String {
  html.script(
    [attribute.attribute("nonce", nonce)],
    "addEventListener('securitypolicyviolation', (e) => {
      const {blockedURI, violatedDirective, originalPolicy} = e
      console.log(e)
      parent.postMessage(JSON.stringify({blockedURI, violatedDirective, originalPolicy}),'*')
    })",
  )
  |> element.to_string
}

pub fn get_response_body(params: Params, nonce: String) -> String {
  params |> get_query_param("html") |> base64_decode <> app_html(nonce)
}

pub fn create_nonce() -> String {
  list.fold([0, 0, 0, 0, 0, 0, 0], "", fn(accumulator, _) {
    accumulator <> int.to_base36(int.random(10_000))
  })
}

pub fn get_response_headers(params: Params, nonce: String) -> Headers {
  let csp =
    params
    |> get_query_param("csp")
    |> base64_decode
    |> parser.modify_csp("script-src", "'nonce-" <> nonce <> "'")
    |> parser.parsed_csp_to_string
  [#("content-security-policy", csp), #("content-type", "text/html")]
}
