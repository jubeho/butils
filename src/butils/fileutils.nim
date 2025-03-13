import std/[os]

proc getFiles*(args: seq[string], pattern: seq[string] = @[".reqif", ".json"]): seq[string]
proc getFilesHandleFiles(fp: string, pattern: seq[string]): seq[string]
proc getFilesHandleDirs(dir: string, pattern: seq[string]): seq[string]

proc getFiles*(args: seq[string], pattern: seq[string] = @[".reqif", ".json"]): seq[string] =
  echo args
  result = @[]
  for arg in args:
    let fi = getFileInfo(arg)
    if fi.kind == pcFile:
      result.add(getFilesHandleFiles(arg, pattern))
    elif fi.kind == pcDir:
      result.add(getFilesHandleDirs(arg, pattern))
    else:
      discard

proc getFilesHandleFiles(fp: string, pattern: seq[string]): seq[string] =
  result = @[]
  let (_, _, ext) = splitFile(fp)
  if ext == ".zip":
    discard
    # let extractDir = joinPath(dir, name)
    # try:
    #   extractAll(fp, extractDir)
    # except:
    #   echo "somethings went wrong unzip the file... :( perhaps unzip destination already exists!?"
    #   return result
    # result.add(getFilesFromExtractedZip(extractDir, pattern))
  elif ext == ".reqifz":
    echo ".reqifz not implemented yet"
  elif ext in pattern:
    result.add(fp)

proc getFilesHandleDirs(dir: string, pattern: seq[string]): seq[string] =
  result = @[]
  for path in os.walkDirRec(dir):
    let (_, _, ext) = splitFile(path)
    if ext in pattern:
      result.add(path)
