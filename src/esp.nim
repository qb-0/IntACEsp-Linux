import
  hLibLinux/render, globals

proc wts*(a: Overlay, matrix: array[0..15, float32], pos: Vec3, dest: ptr Vec2): bool =
  var 
    clip: Vec3
    ndc: Vec2

  # z = w
  clip.z = pos.x * matrix[3] + pos.y * matrix[7] + pos.z * matrix[11] + matrix[15]
  if clip.z < 0.2:
    return false

  clip.x = pos.x * matrix[0] + pos.y * matrix[4] + pos.z * matrix[8] + matrix[12]
  clip.y = pos.x * matrix[1] + pos.y * matrix[5] + pos.z * matrix[9] + matrix[13]

  ndc.x = clip.x / clip.z
  ndc.y = clip.y / clip.z

  dest.x = (a.width / 2 * ndc.x) + (ndc.x + a.width / 2)
  dest.y = (a.height / 2 * ndc.y) + (ndc.y + a.height / 2)
  return true

proc renderBox*(self: Entity) =
  var
    head = self.headPos2D.y - self.feetPos2D.y
    width = head / 2
    center = width / -2
  
  cornerBox(
    self.feetPos2D.x + center, 
    self.feetPos2D.y, 
    width, 
    head + 5, 
    self.color,
    BaseColors.black,
    1
  )

proc renderHealth*(self: Entity) =
  var
    head = self.headPos2D.y - self.feetPos2D.y
    width = head / 2
    center = width / -2

  valueBar(
    self.feetPos2D.x + center - 5, self.feetPos2D.y,
    self.feetPos2D.x + center - 5, self.headPos2D.y + 5,
    2,
    100.float,
    self.health.float,
  )

proc renderSnapline*(self: Entity, midX: int) =
  dashedLine(
    midX.float, 0, 
    self.feetPos2D.x, self.feetPos2D.y, 1.0, 
    self.color,
  )

proc renderName*(self: Entity) =
  renderString(
    self.headPos2D.x, self.headPos2D.y + 20,
    self.name, BaseColors.white, true
  )