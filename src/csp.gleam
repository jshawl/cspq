import gleam/dict
import gleam/io
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(dict.Dict(String, String))
}

fn init(_flags) -> Model {
  Model(dict.new())
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  InputMessage(key: String, value: String)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    InputMessage(key, value) -> {
      let Model(d) = model
      Model(dict.update(d, key, fn(_x){
        value
      }))
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let handler = fn (key: String) { 
    fn (value: String) {
      InputMessage(key, value)
    }
  }

  let Model(d) = model
  io.debug(d)

  let value = case dict.get(d, "default-src") {
    Error(_) -> ""
    Ok(v) -> v
  }

  html.form(
    [],
    [
      ui.field(
        [],
        [element.text("default-src:")],
        ui.input([
          attribute.value(value),
          event.on_input(handler("default-src")),
        ]),
        []
      ),
    ]
  )
}