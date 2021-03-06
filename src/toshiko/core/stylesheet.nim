# author: Ethosa
import macros


type
  StyleSheetObj* = object
    dict*: seq[tuple[key, value: string]]
  StyleSheetRef* = ref StyleSheetObj


proc StyleSheet*(arg: seq[tuple[key, value: string]] = @[]): StyleSheetRef =
  StyleSheetRef(dict: arg)

proc StyleSheet*(arg: openarray[tuple[key, value: string]]): StyleSheetRef =
  var res: seq[tuple[key, value: string]] = @[]
  for i in arg:
    res.add(i)
  StyleSheetRef(dict: res)

proc `$`*(a: StyleSheetRef): string =
  for i in a.dict:
    result &= i.key & ": " & i.value & ";\n"
  if result != "":
    result = result[0..^2]

proc `[]`*(a: StyleSheetRef, key: string): string =
  for i in a.dict:
    if i.key == key:
      return i.value

proc `[]=`*(a: StyleSheetRef, key, value: string) =
  for i in 0..a.dict.high:
    if a.dict[i].key == key:
      a.dict[i].value = value
      return
  a.dict.add((key, value))

proc count*(a: StyleSheetRef): int =
  ## Returns styles count.
  a.dict.len()


# --- Macros --- #
proc toStr(a: NimNode): string =
  result =
    case a.kind
    of nnkIdent, nnkStrLit:
      $a
    of nnkIntLit:
      $(intVal(a))
    of nnkFloatLit:
      $(floatVal(a))
    of nnkInfix:
      $a[1] & "-" & $a[2]
    else:
      ""
  if a.kind == nnkCall:
    for i in 1..a.len()-1:
      result &= a[i].toStr() & ", "
    if result != "":
      result = $a[0] & "(" & result[0..^3] & ")"
    else:
      result = $a[0] & "()"


macro style*(obj: untyped): untyped =
  ## Translates CSS-like code into StyleSheet.
  ##
  ## ### Example
  ## .. code-block:: nim
  ##
  ##    echo style(
  ##      {
  ##        background-color: rgba(255, 255, 255, 1),
  ##        color: rgb(0, 0, 0)
  ##      }
  ##    )
  if obj.kind == nnkTableConstr:
    var
      cssp = StyleSheetRef(dict: @[])
      arr = newNimNode(nnkBracket)

    for child in obj.children():
      if child.kind == nnkExprColonExpr:
        cssp[child[0].toStr()] = child[1].toStr()

    for i in cssp.dict:
      arr.add(newPar(newLit(i.key), newLit(i.value)))

    result = newCall("StyleSheet", newCall("@", arr))
