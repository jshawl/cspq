import cosepo
import cosepo/directive
import gleam/dict
import gleam/io
import gleam/list
import lustre
import lustre/attribute
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre_hash_state

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

// MODEL -----------------------------------------------------------------------

pub type Model {
  Model(dict.Dict(String, String))
}

pub fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  let starter_csp = "default-src 'none'; img-src https://*; child-src 'none';"
  let starter_scripts = "<script>console.log('yay!')</script>"
  #(
    Model(
      dict.from_list([#("csp", starter_csp), #("scripts", starter_scripts)]),
    ),
    lustre_hash_state.init(HashChange),
  )
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  InputMessage(key: String, value: String)
  HashChange(key: String, value: String)
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(a)) {
  let Model(d) = model
  case msg {
    HashChange(key, value) -> {
      #(
        Model(
          dict.update(d, key, fn(_) { value |> lustre_hash_state.from_base64 }),
        ),
        lustre_hash_state.noop(),
      )
    }
    InputMessage(key, value) -> {
      #(
        Model(dict.update(d, key, fn(_) { value })),
        lustre_hash_state.update(key, value |> lustre_hash_state.to_base64),
      )
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn handler(key: String) {
  InputMessage(key, _)
}

fn view_parsed_csp(parsed: Result(cosepo.ContentSecurityPolicy, String)) {
  case parsed {
    Ok(p) -> {
      let cosepo.ContentSecurityPolicy(directives) = p
      html.dl(
        [],
        list.map(directives, fn(x) {
          io.debug("x is:")
          io.debug(directive.get_name(x))
          element.fragment([
            html.dt([], [
              html.a(
                [
                  attribute.href(
                    "https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/"
                    <> directive.get_name(x),
                  ),
                ],
                [element.text(directive.get_name(x))],
              ),
            ]),
            html.dd([], [
              html.div(
                [],
                // TODO keys and values should be in alphabetical order
                list.map(directive.get_value(x), fn(value) {
                  html.code([], [element.text(value)])
                }),
              ),
            ]),
          ])
        }),
      )
    }
    Error(message) ->
      html.p([attribute.class("error")], [element.text(message)])
  }
}

fn view(model: Model) -> Element(Msg) {
  let Model(d) = model

  let csp = case dict.get(d, "csp") {
    Error(_) -> ""
    Ok(v) -> v
  }

  let parsed = cosepo.parse(csp)

  html.div([], [
    html.h1([], [element.text("cspreview")]),
    html.form([], [
      html.h2([], [element.text("Content Security Policy")]),
      html.label([], [element.text("csp:")]),
      html.textarea([event.on_input(handler("csp"))], csp),
    ]),
    view_parsed_csp(parsed),
  ])
}
