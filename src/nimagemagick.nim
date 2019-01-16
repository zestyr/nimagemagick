import nimagemagick/magickwand
export magickwand

type
  Wand* = object
    impl*: ptr MagickWand

proc `=destroy`*(wand: var Wand) =
  wand.impl = DestroyMagickWand(wand.impl)

converter bToM*(b: bool): MagickBooleanType =
  if b: MagickTrue else: MagickFalse

converter mToB*(m: MagickBooleanType): bool =
  if m.int == 1: true else: false

proc wandException*(wand: Wand) =
  var
    severity: ExceptionType
    description = MagickGetException(wand.impl, addr severity)
    error = $(severity.int) & ": " & $description
  MagickRelinquishMemory(description)
  raise newException(IOError, error)

proc genesis* =
  MagickWandGenesis()

proc terminus* =
  MagickWandTerminus()

proc newWand*(): Wand =
  result.impl = NewMagickWand()

proc cloneWand*(wand: Wand): Wand =
  result.impl = CloneMagickWand(wand.impl)

proc readImage*(wand: Wand; image: string) =
  if not MagickReadImage(wand.impl, image):
    wandException(wand)

proc newWand*(image: string): Wand =
  result = newWand()
  if not MagickReadImage(result.impl, image):
    wandException(result)

proc writeImage*(wand: Wand; image: string) =
  if not MagickWriteImage(wand.impl, image):
    wandException(wand)

proc displayImage*(wand: Wand; server="") =
  if not MagickDisplayImage(wand.impl, server):
    wandException(wand)

proc appendImages*(wand: Wand; stack: bool): Wand =
  result.impl = MagickAppendImages(wand.impl, stack)

proc addImage*(wand, addWand: Wand): bool {.discardable.} =
  MagickAddImage(wand.impl, addWand.impl)

proc setSize*(wand: Wand; width, height: SomeNumber): bool {.discardable.} =
  MagickSetSize(wand.impl, width.uint, height.uint)

proc setFirstIterator*(wand: Wand) =
  MagickSetFirstIterator(wand.impl)

proc setLastIterator*(wand: Wand) =
  MagickSetLastIterator(wand.impl)

proc liquidRescale*(wand: Wand; columns, rows: SomeNumber; deltaX=1.0; rigidity=1.0): bool {.discardable.} =
  MagickLiquidRescaleImage(wand.impl, columns.uint, rows.uint, deltaX.cdouble, rigidity.cdouble)

proc resizeImage*(wand: Wand; columns, rows: SomeNumber; filter=LanczosFilter): bool {.discardable.} =
  MagickResizeImage(wand.impl, columns.uint, rows.uint, filter)

proc width*(wand: Wand): int =
  MagickGetImageWidth(wand.impl).int

proc height*(wand: Wand): int =
  MagickGetImageHeight(wand.impl).int

proc getSize*(wand: Wand): (int, int) =
  (wand.width, wand.height)