import
  hLibLinux/[memory, render],
  globals, esp

proc createEntity(a: ByteAddress, vm: array[0..15, float32], e: ptr Entity): bool =
  var p = memRead(a, PlayerObject)
  e.address = a
  e.health = p.health
  if e.health < 0 or e.health > 101:
    return false
  e.headPos3D = p.headPos
  if not wts(overlay, vm, p.headPos, e.headPos2D.addr): 
    return false
  e.headPos3D.z += 0.6
  e.feetPos3D = p.feetPos
  if not wts(overlay, vm, p.feetPos, e.feetPos2D.addr): 
    return false
  e.team = p.team
  e.color = if p.team == 1: Basecolors.cyan else: Basecolors.red
  e.name = $cast[cstring](p.name[0].unsafeAddr)
  return true

proc main =
  {.gcsafe.}:
    acProc = intProcess()
    overlay = initOverlay(name="Internal AC ESP", target="AssaultCube")
    let entList = memRead(acProc.baseAddr + Offsets.entList, ByteAddress)
    while overlay.loop():
      let 
        viewMatrix = memRead(acProc.baseAddr + Offsets.viewMatrix, array[0..15, float32])
        playerCount = memRead(acProc.baseAddr + Offsets.playerCount, int32)
      if playerCount != 0:
        for e in 0..playerCount:
            let entAddr = memRead(entList + e * 8, ByteAddress)
            if entAddr != 0:
              var ent: Entity
              if createEntity(memRead(entList + e * 8, ByteAddress), viewMatrix, ent.addr):
                  echo ent.name
                  ent.renderBox()
                  ent.renderHealth()
                  ent.renderName()
                  ent.renderSnapline(overlay.midX)
    overlay.deinit()

when isMainModule:
  var t: Thread[void]
  t.createThread(main)