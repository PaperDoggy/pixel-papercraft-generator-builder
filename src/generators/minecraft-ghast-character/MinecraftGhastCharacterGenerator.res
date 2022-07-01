let requireImage = fileName => Generator.requireImage("./images/" ++ fileName)
let requireTexture = fileName => Generator.requireImage("./textures/" ++ fileName)

let id = "minecraft-ghast-character"

let name = "Minecraft Ghast Character"
let video: Generator.videoDef = {url: "https://www.youtube.com/embed/vG-mXWu0OlA?rel=0"}
let history = ["28 May 2022 PaperDoggy - Initial script developed."]

let thumbnail: Generator.thumnbnailDef = {
  url: Generator.requireImage("./thumbnail/thumbnail-256.jpeg"),
}

let images: array<Generator.imageDef> = [{id: "OverlayBee", url: requireImage("OverlayBee.png")}]
let textures: array<Generator.textureDef> = [
  {
    id: "Skin",
    url: requireTexture("Steve.png"),
    standardWidth: 64,
    standardHeight: 64,
  },
]
let steve = TextureMap.MinecraftCharacter.steve
let alex = TextureMap.MinecraftCharacter.alex

module DrawSmall = {
  let drawBody = (ox, oy, texture) => {
    Generator.drawTexture(texture, steve.base.head.front, (ox, oy, 128, 128), ())
    Generator.drawTexture(texture, steve.base.head.right, (ox - 129, oy, 128, 128), ())
    Generator.drawTexture(texture, steve.base.head.left, (ox + 129, oy, 128, 128), ())
    Generator.drawTexture(texture, steve.base.head.back, (ox + 129 * 2, oy, 128, 128), ())
    Generator.drawTexture(texture, steve.base.head.top, (ox, oy - 129, 128, 128), ())
    Generator.drawTexture(
      texture,
      steve.base.head.bottom,
      (ox, oy + 129, 128, 128),
      ~flip=#Vertical,
      (),
    )
    Generator.drawTab((ox - 129 - 30, oy, 30, 128), #West, ())
    Generator.drawTab((ox - 129, oy - 30, 128, 30), #North, ())
    Generator.drawTab((ox + 129, oy - 30, 128, 30), #North, ())
    Generator.drawTab((ox + 129 + 129, oy - 30, 128, 30), #North, ())
    Generator.drawTab((ox - 129, oy + 128, 128, 30), #South, ())
    Generator.drawTab((ox + 129, oy + 128, 128, 30), #South, ())
    Generator.drawTab((ox + 129 + 129, oy + 128, 128, 30), #South, ())
    Generator.drawLine((ox + 129 + 129 + 129, oy), (ox - 129, oy), ~color="#bebebe", ~width=1, ())
    Generator.drawLine((ox - 130, oy), (ox - 130, oy + 129), ~color="#bebebe", ~width=1, ())
    Generator.drawLine(
      (ox + 129 + 129 + 128, oy),
      (ox + 129 + 129 + 128, oy + 129),
      ~color="#bebebe",
      ~width=1,
      (),
    )
    Generator.drawLine(
      (ox - 129, oy + 128),
      (ox + 129 + 129 + 129, oy + 128),
      ~color="#bebebe",
      ~width=1,
      (),
    )
    Generator.drawLine((ox - 1, oy - 129), (ox - 1, oy + 128 + 129), ~color="#bebebe", ~width=1, ())
    Generator.drawLine((ox - 1, oy - 130), (ox + 129, oy - 130), ~color="#bebebe", ~width=1, ())
    Generator.drawLine(
      (ox + 128, oy - 129),
      (ox + 128, oy + 128 + 129),
      ~color="#bebebe",
      ~width=1,
      (),
    )
    Generator.drawLine(
      (ox - 1, oy + 129 * 2 - 1),
      (ox + 129, oy + 129 * 2 - 1),
      ~color="#bebebe",
      ~width=1,
      (),
    )
    Generator.drawLine(
      (ox + 129 + 128, oy - 1),
      (ox + 129 + 128, oy + 128),
      ~color="#bebebe",
      ~width=1,
      (),
    )
  }
  let drawTentacle = (ox, oy, texture) => {
    Generator.drawTexture(texture, steve.base.head.front, (ox, oy, 128, 128), ())
    Generator.drawTexture(texture, steve.base.head.right, (ox - 129, oy, 128, 128), ())
    Generator.drawTexture(texture, steve.base.head.left, (ox + 129, oy, 128, 128), ())
    Generator.drawTexture(texture, steve.base.head.back, (ox + 129 * 2, oy, 128, 128), ())
    Generator.drawTexture(texture, steve.base.head.top, (ox, oy - 129, 128, 128), ())
    Generator.drawTexture(
      texture,
      steve.base.head.bottom,
      (ox, oy + 129, 128, 128),
      ~flip=#Vertical,
      (),
    )
    Generator.drawTab((ox - 129 - 30, oy, 30, 128), #West, ())
    Generator.drawTab((ox - 129, oy - 30, 128, 30), #North, ())
    Generator.drawTab((ox + 129, oy - 30, 128, 30), #North, ())
    Generator.drawTab((ox + 129 + 129, oy - 30, 128, 30), #North, ())
    Generator.drawTab((ox - 129, oy + 128, 128, 30), #South, ())
    Generator.drawTab((ox + 129, oy + 128, 128, 30), #South, ())
    Generator.drawTab((ox + 129 + 129, oy + 128, 128, 30), #South, ())
    Generator.drawLine((ox + 129 + 129 + 129, oy), (ox - 129, oy), ~color="#bebebe", ~width=1, ())
    Generator.drawLine((ox - 130, oy), (ox - 130, oy + 129), ~color="#bebebe", ~width=1, ())
    Generator.drawLine(
      (ox + 129 + 129 + 128, oy),
      (ox + 129 + 129 + 128, oy + 129),
      ~color="#bebebe",
      ~width=1,
      (),
    )
    Generator.drawLine(
      (ox - 129, oy + 128),
      (ox + 129 + 129 + 129, oy + 128),
      ~color="#bebebe",
      ~width=1,
      (),
    )
    Generator.drawLine((ox - 1, oy - 129), (ox - 1, oy + 128 + 129), ~color="#bebebe", ~width=1, ())
    Generator.drawLine((ox - 1, oy - 130), (ox + 129, oy - 130), ~color="#bebebe", ~width=1, ())
    Generator.drawLine(
      (ox + 128, oy - 129),
      (ox + 128, oy + 128 + 129),
      ~color="#bebebe",
      ~width=1,
      (),
    )
    Generator.drawLine(
      (ox - 1, oy + 129 * 2 - 1),
      (ox + 129, oy + 129 * 2 - 1),
      ~color="#bebebe",
      ~width=1,
      (),
    )
    Generator.drawLine(
      (ox + 129 + 128, oy - 1),
      (ox + 129 + 128, oy + 128),
      ~color="#bebebe",
      ~width=1,
      (),
    )
  }
}
let script = () => {
  Generator.defineSelectInput("Character 1 skin model type", ["Steve", "Alex"])
  Generator.defineTextureInput(
    "Skin",
    {
      standardWidth: 64,
      standardHeight: 64,
      choices: [],
    },
  )
  let alexModel1 = Generator.getSelectInputValue("Character 1 skin model type") === "Alex"

  DrawSmall.drawBody(180, 140, "Skin")
}

let generator: Generator.generatorDef = {
  id: id,
  name: name,
  thumbnail: Some(thumbnail),
  video: Some(video),
  instructions: None,
  images: images,
  textures: textures,
  script: script,
  history: history,
}
