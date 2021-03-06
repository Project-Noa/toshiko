# author: Ethosa
## It provides a primitive display image.
import
  ../thirdparty/opengl,
  ../core,
  ../nodes/node,
  control


type
  TextureRectObj* = object of ControlObj
    texture_mode*: TextureMode
    texture_anchor*: AnchorRef
    texture_filter*: ColorRef
    texture*: GlTextureObj
  TextureRectRef* = ref TextureRectObj


proc TextureRect*(name: string = "TextureRect"): TextureRectRef =
  ## Creates a new TextureRect.
  ##
  ## Arguments:
  ## - `name` is a node name.
  runnableExamples:
    var texture = TextureRect("TextureRect")
  nodepattern(TextureRectRef)
  controlpattern()
  result.rect_size = Vector2(40, 40)
  result.texture = GlTextureObj()
  result.texture_mode = TEXTUREMODE_FILL_XY
  result.texture_anchor = Anchor(0, 0, 0, 0)
  result.texture_filter = Color(1f, 1f, 1f)
  result.kind = TEXTURE_RECT_NODE



method draw*(self: TextureRectRef, w, h: float) =
  ## This uses in the `window.nim`.
  let
    x = -w/2 + self.rect_global_position.x
    y = h/2 - self.rect_global_position.y

  procCall self.ControlRef.draw(w, h)
  glColor4f(self.texture_filter.r, self.texture_filter.g, self.texture_filter.b, self.texture_filter.a)


  if self.texture.texture > 0'u32:
    glEnable(GL_TEXTURE_2D)
    glBindTexture(GL_TEXTURE_2D, self.texture.texture)

    glBegin(GL_QUADS)
    case self.texture_mode
    of TEXTUREMODE_FILL_XY:
      glTexCoord2f(0, 0)
      glVertex2f(x, y)
      glTexCoord2f(0, 1)
      glVertex2f(x, y - self.rect_size.y)
      glTexCoord2f(1, 1)
      glVertex2f(x + self.rect_size.x, y - self.rect_size.y)
      glTexCoord2f(1, 0)
      glVertex2f(x + self.rect_size.x, y)
    of TEXTUREMODE_KEEP_ASPECT_RATIO:
      let
        w = self.rect_size.x / self.texture.size.x
        h = self.rect_size.y / self.texture.size.y
        q = if w < h: w else: h
        x1 = x + (self.rect_size.x*self.texture_anchor.x1) - (self.texture.size.x*q)*self.texture_anchor.x2
        y1 = y - (self.rect_size.y*self.texture_anchor.y1) + (self.texture.size.y*q)*self.texture_anchor.y2
        x2 = x1 + self.texture.size.x*q
        y2 = y1 - self.texture.size.y*q
      glTexCoord2f(0, 0)
      glVertex2f(x1, y1)
      glTexCoord2f(0, 1)
      glVertex2f(x1, y2)
      glTexCoord2f(1, 1)
      glVertex2f(x2, y2)
      glTexCoord2f(1, 0)
      glVertex2f(x2, y1)
    of TEXTUREMODE_CROP:
      if self.texture.size.x < self.rect_size.x:
        let q = self.rect_size.x / self.texture.size.x
        self.texture.size.x *= q
        self.texture.size.y *= q
      if self.texture.size.y < self.rect_size.y:
        let q = self.rect_size.y / self.texture.size.y
        self.texture.size.x *= q
        self.texture.size.y *= q
      let
        x1 = self.rect_size.x / self.texture.size.x
        y1 = self.rect_size.y / self.texture.size.y
        x2 = normalize(self.texture_anchor.x1 - x1*self.texture_anchor.x2, 0, 1)
        y2 = normalize(self.texture_anchor.y1 - y1*self.texture_anchor.y2, 0, 1)
        x3 = normalize(x2 + x1, 0, 1)
        y3 = normalize(y2 + y1, 0, 1)
      glTexCoord2f(x2, y2)
      glVertex2f(x, y)
      glTexCoord2f(x2, y3)
      glVertex2f(x, y - self.rect_size.y)
      glTexCoord2f(x3, y3)
      glVertex2f(x + self.rect_size.x, y - self.rect_size.y)
      glTexCoord2f(x3, y2)
      glVertex2f(x + self.rect_size.x, y)
    glEnd()
    glDisable(GL_TEXTURE_2D)

method loadTexture*(self: TextureRectRef, file: cstring) {.base.} =
  ## Loads texture from file.
  ##
  ## Arguments:
  ## - `file` is an image file path.
  self.texture = load(file)

method setTexture*(self: TextureRectRef, gltexture: GlTextureObj) {.base.} =
  ## Changes texture.
  ##
  ## Arguments:
  ## - `gltexture` is a texture, loaded via load(file, mode=GL_RGB).
  self.texture = gltexture

method setTextureAnchor*(self: TextureRectRef, anchor: AnchorRef) {.base.} =
  ## Changes texture anchor.
  self.texture_anchor = anchor

method setTextureAnchor*(self: TextureRectRef, x1, y1, x2, y2: float) {.base.} =
  ## Changes texture anchor.
  ##
  ## ARguments:
  ## - `x1` and `y1` is an anchor relative to TextureRect size.
  ## - `x2` and `y2` is an anchor relative to texture size.
  self.texture_anchor = Anchor(x1, y1, x2, y2)

method setTextureMode*(self: TextureRectRef, mode: TextureMode) {.base.} =
  ## Changes texture mode.
  ## `mode` should be `TEXTURE_MODE_FIL_XY`, `TEXTUREMODE_CROP` or `TEXTUREMODE_KEEP_ASPECT_RATIO`.
  self.texture_mode = mode

method setTextureFilter*(self: TextureRectRef, color: ColorRef) {.base.} =
  ## Changes texture filter color.
  self.texture_filter = color
