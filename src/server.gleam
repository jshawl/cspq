import gleam/bit_array
import gleam/io
import gleam/list
import gleam/string
import lustre/element
import lustre/element/html

pub type Request

pub type Response

@external(javascript, "./ffi.mjs", "response")
pub fn response(
  status: Int,
  headers: List(#(String, String)),
  body: String,
) -> Response

@external(javascript, "./ffi.mjs", "url")
pub fn url(req: Request) -> String

pub fn handle_request(request: Request) -> Response {
  let headers = [#("content-type", "text/html")]
  let html = request |> url |> params |> get_response_body
  response(200, headers, html)
}

pub type Params =
  List(#(String, String))

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

pub fn app_html() -> String {
  html.script(
    [],
    "console.log('plus my own')"
  ) |> element.to_string
}

pub fn get_response_body(params: Params) -> String {
  params |> get_query_param("html") |> base64_decode <> app_html()
}
