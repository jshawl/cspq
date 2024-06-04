import gleam/bit_array
import gleam/dict
import gleam/io
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import parser

@external(javascript, "./ffi.mjs", "getHash")
pub fn get_hash() -> String

@external(javascript, "./ffi.mjs", "setHash")
pub fn set_hash(h: String) -> Nil

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", get_hash())
}

// MODEL -----------------------------------------------------------------------

pub type Model {
  Model(dict.Dict(String, String))
}

pub fn init(hash) -> #(Model, effect.Effect(a)) {
  let starter_csp = "default-src 'self'; img-src https://*; child-src 'none';"
  let csp = case string.length(hash) {
    0 | 1 -> starter_csp
    _ -> {
      let encoded =
        string.slice(from: hash, at_index: 1, length: string.length(hash))
      case bit_array.base64_decode(encoded) {
        Error(Nil) -> starter_csp
        Ok(v) ->
          case bit_array.to_string(v) {
            Error(Nil) -> starter_csp
            Ok(v) -> v
          }
      }
    }
  }
  #(Model(dict.from_list([#("csp", csp)])), effect.none())
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  InputMessage(key: String, value: String)
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(a)) {
  case msg {
    InputMessage(key, value) -> {
      let Model(d) = model
      let ba = bit_array.from_string(value)
      let encoded = bit_array.base64_encode(ba, True)
      #(
        Model(dict.update(d, key, fn(_) { value })),
        effect.from(fn(_) { set_hash(encoded) }),
      )
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn handler(key: String) {
  InputMessage(key, _)
}

fn view_parsed_csp(parsed: List(#(String, List(String)))) {
  html.dl(
    [],
    list.map(parsed, fn(x) {
      let #(key, values) = x
      element.fragment([
        html.dt([], [
          html.a(
            [
              attribute.href(
                "https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/"
                <> key,
              ),
            ],
            [element.text(key)],
          ),
        ]),
        html.dd([], [
          html.div(
            [],
            // TODO keys and values should be in alphabetical order
            list.map(values, fn(value) { html.code([], [element.text(value)]) }),
          ),
        ]),
      ])
    }),
  )
}

fn view(model: Model) -> Element(Msg) {
  let Model(d) = model

  let parsed = case dict.get(d, "csp") {
    Error(Nil) -> []
    Ok(p) ->
      dict.to_list(parser.parse_csp(p))
      |> list.filter(fn(x) {
        let #(key, _) = x
        key != ""
      })
  }

  let value = case dict.get(d, "csp") {
    Error(_) -> ""
    Ok(v) -> v
  }

  html.div([], [
    html.form([], [
      html.label([], [element.text("csp:")]),
      html.textarea([event.on_input(handler("csp"))], value),
    ]),
    view_parsed_csp(parsed),
  ])
}
