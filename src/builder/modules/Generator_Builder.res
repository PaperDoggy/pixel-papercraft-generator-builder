open Dom2

type textureDef = {
  id: string,
  url: string,
  standardWidth: int,
  standardHeight: int,
}

type imageDef = {
  id: string,
  url: string,
}

type thumnbnailDef = {url: string}

type videoDef = {url: string}

type instructionsDef = React.element

type generatorDef = {
  id: string,
  name: string,
  history: array<string>,
  thumbnail: option<thumnbnailDef>,
  video: option<videoDef>,
  instructions: option<instructionsDef>,
  images: array<imageDef>,
  textures: array<textureDef>,
  script: unit => unit,
}

type position = (int, int)

type rectangleLegacy = {
  x: int,
  y: int,
  w: int,
  h: int,
}

type rectangle = (int, int, int, int)

module Input = {
  type rangeArgs = {
    min: int,
    max: int,
    value: int,
    step: int,
  }

  type textureArgs = {
    standardWidth: int,
    standardHeight: int,
    choices: array<string>,
  }

  type id = string
  type pageId = string

  type t =
    | Text(id, string)
    | CustomStringInput(id, (string => unit) => React.element)
    | RegionInput(pageId, (int, int, int, int), unit => unit)
    | TextureInput(id, textureArgs)
    | BooleanInput(id)
    | SelectInput(id, array<string>)
    | RangeInput(id, rangeArgs)
    | ButtonInput(id, unit => unit)
}

module Model = {
  type pageRegion = {
    pageId: string,
    region: (int, int, int, int),
  }

  type values = {
    images: Js.Dict.t<Generator_ImageWithCanvas.t>,
    textures: Js.Dict.t<Generator_Texture.t>,
    booleans: Js.Dict.t<bool>,
    selects: Js.Dict.t<string>,
    ranges: Js.Dict.t<int>,
    strings: Js.Dict.t<string>,
  }

  type t = {
    inputs: array<Input.t>,
    pages: array<Generator_Page.t>,
    currentPage: option<Generator_Page.t>,
    values: values,
  }

  let make = () => {
    inputs: [],
    pages: [],
    currentPage: None,
    values: {
      images: Js.Dict.empty(),
      textures: Js.Dict.empty(),
      booleans: Js.Dict.empty(),
      selects: Js.Dict.empty(),
      ranges: Js.Dict.empty(),
      strings: Js.Dict.empty(),
    },
  }
}

let findPage = (model: Model.t, id) => model.pages->Js.Array2.find(page => page.id === id)

let getCanvasWithContextPixelColor = (canvasWithContext: Generator_CanvasWithContext.t, x, y) => {
  let {width, height, contextWithAlpha} = canvasWithContext
  let data = Dom2.Context2d.getImageData(contextWithAlpha, 0, 0, width, height).data
  let pixelIndex = y * width + x
  let arrayIndex = pixelIndex * 4
  let r = Belt.Array.get(data, arrayIndex)
  let g = Belt.Array.get(data, arrayIndex + 1)
  let b = Belt.Array.get(data, arrayIndex + 2)
  let a = Belt.Array.get(data, arrayIndex + 3)
  switch (r, g, b, a) {
  | (Some(r), Some(g), Some(b), Some(a)) => Some((r, g, b, a))
  | _ => None
  }
}

let getTexturePixelColor = (model: Model.t, textureId, x, y) => {
  let texture = Js.Dict.get(model.values.textures, textureId)
  switch texture {
  | None => None
  | Some(texture) => getCanvasWithContextPixelColor(texture.imageWithCanvas.canvasWithContext, x, y)
  }
}

let getImagePixelColor = (model: Model.t, imageId, x, y) => {
  let imageWithCanvas = Js.Dict.get(model.values.images, imageId)
  switch imageWithCanvas {
  | None => None
  | Some(imageWithCanvas) => getCanvasWithContextPixelColor(imageWithCanvas.canvasWithContext, x, y)
  }
}

let getPagePixelColor = (model: Model.t, pageId, x, y) => {
  let page = findPage(model, pageId)
  switch page {
  | None => None
  | Some(page) => getCanvasWithContextPixelColor(page.canvasWithContext, x, y)
  }
}

let getCurrentPagePixelColor = (model: Model.t, x, y) => {
  switch model.currentPage {
  | None => None
  | Some(page) => getCanvasWithContextPixelColor(page.canvasWithContext, x, y)
  }
}

let hasInput = (model: Model.t, idToFind: string) => {
  Js.Array2.find(model.inputs, input => {
    let id = switch input {
    | Text(id, _) => id
    | RegionInput(_, _, _) => ""
    | CustomStringInput(id, _) => id
    | TextureInput(id, _) => id
    | BooleanInput(id) => id
    | SelectInput(id, _) => id
    | RangeInput(id, _) => id
    | ButtonInput(id, _) => id
    }
    id === idToFind
  })
}

let clearStringInputValues = (model: Model.t) => {
  {
    ...model,
    values: {
      ...model.values,
      strings: Js.Dict.empty(),
    },
  }
}

let setStringInputValue = (model: Model.t, id: string, value: string) => {
  let strings = Js.Dict.fromArray(Js.Dict.entries(model.values.strings))
  Js.Dict.set(strings, id, value)
  {
    ...model,
    values: {
      ...model.values,
      strings: strings,
    },
  }
}

let getStringInputValue = (model: Model.t, id: string) => {
  let value = Js.Dict.get(model.values.strings, id)
  switch value {
  | None => ""
  | Some(value) => value
  }
}

let setBooleanInputValue = (model: Model.t, id: string, value: bool) => {
  let booleans = Js.Dict.fromArray(Js.Dict.entries(model.values.booleans))
  Js.Dict.set(booleans, id, value)
  {
    ...model,
    values: {
      ...model.values,
      booleans: booleans,
    },
  }
}

let getBooleanInputValue = (model: Model.t, id: string) => {
  let value = Js.Dict.get(model.values.booleans, id)
  switch value {
  | None => false
  | Some(value) => value
  }
}

let getBooleanInputValueWithDefault = (model: Model.t, id: string, default: bool) => {
  let value = Js.Dict.get(model.values.booleans, id)
  switch value {
  | None => default
  | Some(value) => value
  }
}

let setSelectInputValue = (model: Model.t, id: string, value: string) => {
  let selects = Js.Dict.fromArray(Js.Dict.entries(model.values.selects))
  Js.Dict.set(selects, id, value)
  {
    ...model,
    values: {
      ...model.values,
      selects: selects,
    },
  }
}

let getSelectInputValue = (model: Model.t, id: string) => {
  let value = Js.Dict.get(model.values.selects, id)
  switch value {
  | None => ""
  | Some(value) => value
  }
}

let setRangeInputValue = (model: Model.t, id: string, value: int) => {
  let ranges = Js.Dict.fromArray(Js.Dict.entries(model.values.ranges))
  Js.Dict.set(ranges, id, value)
  {
    ...model,
    values: {
      ...model.values,
      ranges: ranges,
    },
  }
}

let getRangeInputValue = (model: Model.t, id: string): int => {
  let value = Js.Dict.get(model.values.ranges, id)
  switch value {
  | None => 0
  | Some(value) => value
  }
}

let hasBooleanValue = (model: Model.t, id: string) => {
  switch Js.Dict.get(model.values.booleans, id) {
  | None => false
  | Some(_) => true
  }
}

let hasSelectValue = (model: Model.t, id: string) => {
  switch Js.Dict.get(model.values.selects, id) {
  | None => false
  | Some(_) => true
  }
}

let hasRangeValue = (model: Model.t, id: string) => {
  switch Js.Dict.get(model.values.ranges, id) {
  | None => false
  | Some(_) => true
  }
}

let usePage = (model: Model.t, id) => {
  let page = findPage(model, id)
  switch page {
  | Some(page) => {
      ...model,
      currentPage: Some(page),
    }
  | None => {
      let page = Generator_Page.make(id)
      let pages = Js.Array2.concat(model.pages, [page])
      {
        ...model,
        pages: pages,
        currentPage: Some(page),
      }
    }
  }
}

let getDefaultPageId = () => "Page"

let getCurrentPageId = (model: Model.t) => {
  switch model.currentPage {
  | None => getDefaultPageId()
  | Some(page) => page.id
  }
}

let ensureCurrentPage = (model: Model.t) => {
  switch model.currentPage {
  | None => usePage(model, getDefaultPageId())
  | Some(_) => model
  }
}

let defineRegionInput = (model: Model.t, region: (int, int, int, int), callback) => {
  let pageId = getCurrentPageId(model)
  let inputs = Js.Array2.concat(model.inputs, [Input.RegionInput(pageId, region, callback)])
  {...model, inputs: inputs}
}

let defineCustomStringInput = (
  model: Model.t,
  id: string,
  fn: (string => unit) => React.element,
) => {
  let inputs = Js.Array2.concat(model.inputs, [Input.CustomStringInput(id, fn)])
  {...model, inputs: inputs}
}

let defineBooleanInput = (model: Model.t, id: string, initial: bool) => {
  let inputs = Js.Array2.concat(model.inputs, [Input.BooleanInput(id)])
  let newModel = {...model, inputs: inputs}
  if !hasBooleanValue(model, id) {
    setBooleanInputValue(newModel, id, initial)
  } else {
    newModel
  }
}

let defineButtonInput = (model: Model.t, id: string, onClick) => {
  let inputs = Js.Array2.concat(model.inputs, [Input.ButtonInput(id, onClick)])
  let newModel = {...model, inputs: inputs}
  newModel
}

let defineSelectInput = (model: Model.t, id: string, options: array<string>) => {
  let inputs = Js.Array2.concat(model.inputs, [Input.SelectInput(id, options)])
  let newModel = {...model, inputs: inputs}
  if !hasSelectValue(model, id) {
    let value = Js.Array2.length(options) > 0 ? options[0] : ""
    setSelectInputValue(newModel, id, value)
  } else {
    newModel
  }
}

let defineRangeInput = (model: Model.t, id: string, rangeArgs: Input.rangeArgs) => {
  let inputs = Js.Array2.concat(model.inputs, [Input.RangeInput(id, rangeArgs)])
  let newModel = {...model, inputs: inputs}
  if !hasRangeValue(model, id) {
    setRangeInputValue(newModel, id, rangeArgs.value)
  } else {
    newModel
  }
}

let defineTextureInput = (model: Model.t, id, options) => {
  let input = Input.TextureInput(id, options)
  let inputs = Js.Array2.concat(model.inputs, [input])
  {
    ...model,
    inputs: inputs,
  }
}

let defineText = (model: Model.t, text: string) => {
  let isText = input =>
    switch input {
    | Input.Text(_) => true
    | _ => false
    }
  let textCount = model.inputs->Js.Array2.filter(isText)->Js.Array2.length
  let id = "text-" ++ Js.Int.toString(textCount + 1)
  let input = Input.Text(id, text)
  let inputs = Js.Array2.concat(model.inputs, [input])
  {
    ...model,
    inputs: inputs,
  }
}

let fillBackgroundColor = (model: Model.t, color: string) => {
  switch model.currentPage {
  | None => model
  | Some(currentPage) => {
      let currentPage = findPage(model, currentPage.id)
      switch currentPage {
      | None => model
      | Some(currentPage) => {
          let {width, height} = currentPage.canvasWithContext
          let newCanvas = Generator_CanvasWithContext.make(width, height)
          let previousFillStyle = newCanvas.context->Context2d.getFillStyle
          newCanvas.context->Context2d.setFillStyle(color)
          newCanvas.context->Context2d.fillRect(0, 0, width, height)
          newCanvas.context->Context2d.drawCanvasXY(currentPage.canvasWithContext.canvas, 0, 0)
          newCanvas.context->Context2d.setFillStyle(previousFillStyle)

          let newCurrentPage = {
            ...currentPage,
            canvasWithContext: newCanvas,
          }

          let newPages = Belt.Array.map(model.pages, page => {
            page.id === newCurrentPage.id ? newCurrentPage : page
          })

          let newModel = {
            ...model,
            pages: newPages,
            currentPage: Some(newCurrentPage),
          }

          newModel
        }
      }
    }
  }
}

let getOffset = ((x1, y1): position, (x2, y2): position) => {
  let x1 = Belt.Int.toFloat(x1)
  let y1 = Belt.Int.toFloat(y1)
  let x2 = Belt.Int.toFloat(x2)
  let y2 = Belt.Int.toFloat(y2)

  let w = x2 -. x1
  let h = y2 -. y1

  /* When a line is drawn and its start and end coords are integer values, the
  resulting line is drawn in between to rows of pixels, resulting in a line
  that is two pixels wide and half transparent. To fix this, the line's start
  and end positions need to be offset 0.5 pixels in the direction normal to the
  line. The following code gets the angle of the line, and gets the components
  for a translation in the direction perpendicular to the angle using vector
  resolution: https://physics.info/vector-components/summary.shtml This results
  in a fully opaque line with the correct width if the line is vertical or
  horizontal, but antialiasing may still affect lines at other angles.
 */
  let angle = Js.Math.atan2(~y=h, ~x=w, ())
  let ox = Js.Math.sin(angle) *. 0.5
  let oy = Js.Math.cos(angle) *. 0.5

  (ox, oy)
}

let drawLine = (
  model: Model.t,
  (x1, y1): position,
  (x2, y2): position,
  ~color: string,
  ~width: int,
  ~pattern: array<int>,
  ~offset: int,
) => {
  let (ox, oy) = getOffset((x1, y1), (x2, y2))

  switch model.currentPage {
  | None => model
  | Some(currentPage) => {
      let context = currentPage.canvasWithContext.context
      context->Context2d.beginPath
      context->Context2d.strokeStyle(color)
      context->Context2d.lineWidth(width)
      context->Context2d.setLineDash(pattern)
      context->Context2d.lineDashOffset(offset)
      context->Context2d.moveTo(Belt.Int.toFloat(x1) +. ox, Belt.Int.toFloat(y1) +. oy)
      context->Context2d.lineTo(Belt.Int.toFloat(x2) +. ox, Belt.Int.toFloat(y2) +. oy)
      context->Context2d.stroke

      model
    }
  }
}

let drawImage = (model: Model.t, id: string, (x, y): position) => {
  let model = ensureCurrentPage(model)
  let currentPage = model.currentPage
  let image = Js.Dict.get(model.values.images, id)
  switch (currentPage, image) {
  | (Some(page), Some(imageWithCanvas)) =>
    Context2d.drawImageXY(page.canvasWithContext.context, imageWithCanvas.image, x, y)
  | _ => ()
  }
  model
}

let addImage = (model: Model.t, id: string, image: Image.t) => {
  let imageWithCanvas = Generator_ImageWithCanvas.makeFromImage(image)
  let images = Js.Dict.fromArray(Js.Dict.entries(model.values.images))
  Js.Dict.set(images, id, imageWithCanvas)
  {
    ...model,
    values: {
      ...model.values,
      images: images,
    },
  }
}

let addTexture = (model: Model.t, id: string, texture: Generator_Texture.t) => {
  let textures = Js.Dict.fromArray(Js.Dict.entries(model.values.textures))
  Js.Dict.set(textures, id, texture)
  {
    ...model,
    values: {
      ...model.values,
      textures: textures,
    },
  }
}

let clearTexture = (model: Model.t, id: string) => {
  let entries =
    Js.Dict.entries(model.values.textures)->Js.Array2.filter(((textureId, _)) => textureId !== id)
  let textures = Js.Dict.fromArray(entries)
  {
    ...model,
    values: {
      ...model.values,
      textures: textures,
    },
  }
}

let drawTexture = (
  model: Model.t,
  id: string,
  (sx, sy, sw, sh): rectangle,
  (dx, dy, dw, dh): rectangle,
  ~flip: Generator_Texture.flip,
  ~rotate: Generator_Texture.rotate,
  ~blend: Generator_Texture.blend,
  ~pixelate: bool,
  (),
) => {
  let model = ensureCurrentPage(model)
  let currentPage = model.currentPage
  let texture = Js.Dict.get(model.values.textures, id)
  switch (currentPage, texture) {
  | (Some(page), Some(texture)) =>
    Generator_Texture.draw(
      texture,
      page,
      sx,
      sy,
      sw,
      sh,
      dx,
      dy,
      dw,
      dh,
      ~flip,
      ~rotate,
      ~blend,
      ~pixelate,
      (),
    )
  | _ => ()
  }
  model
}

let hasImage = (model: Model.t, id: string) => {
  let image = Js.Dict.get(model.values.images, id)
  switch image {
  | None => false
  | Some(_) => true
  }
}

let hasTexture = (model: Model.t, id: string) => {
  let texture = Js.Dict.get(model.values.textures, id)
  switch texture {
  | None => false
  | Some(_) => true
  }
}

let drawText = (model: Model.t, text: string, position: position, size: int) => {
  let model = ensureCurrentPage(model)
  switch model.currentPage {
  | None => ()
  | Some(currentPage) => {
      let (x, y) = position
      let font = Belt.Int.toString(size) ++ "px sans-serif"
      currentPage.canvasWithContext.context->Context2d.font(font)
      currentPage.canvasWithContext.context->Context2d.fillText(text, x, y)
    }
  }
  model
}
