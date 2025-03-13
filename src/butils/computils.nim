import std/[tables,logging,strformat]

proc compareLists*[T](list1, list2: seq[T]): (seq[T], seq[T], seq[T])
proc compareTableKeys*[K, V](t1, t2: Table[K, V]): (seq[K], seq[K], seq[K])
proc compareTableKeys*[K, V](t1, t2: OrderedTable[K, V]): (seq[K], seq[K], seq[K])
proc compareTableValues*[K, V](t1, t2: Table[K, V]): (seq[tuple[key: K, val: V]],seq[tuple[key: K, val: V]],seq[tuple[key: K, val1: V, val2: V]])
proc compareTableValues*[K, V](t1, t2: OrderedTable[K, V]): (seq[tuple[key: K, val: V]],seq[tuple[key: K, val: V]],seq[tuple[key: K, val1: V, val2: V]])
proc compareTableKeysWithList*[K, V](t: OrderedTable[K, V], l: seq[K]): (seq[K], seq[K], seq[K])
proc getKeylist*[K, V](t: Table[K, V]): seq[K]
proc getKeylist*[K, V](t: OrderedTable[K, V]): seq[K]

proc compareListWithTableKeys*[T, V](list: seq[T], t: Table[T, V]): (seq[T], seq[T], seq[T])

proc compareListWithTableKeys*[T, V](list: seq[T], t: Table[T, V]): (seq[T], seq[T], seq[T]) =
  var
    onlylist: seq[T] = @[]
    onlytab:  seq[T] = @[]
    intersect: seq[T] = @[]
  var ts = t
  for e in list:
    if ts.hasKey(e):
      ts.del(e)
      intersect.add(e)
    else:
      onlylist.add(e)
  if ts.len() > 0:
    for k in ts.keys():
      onlytab.add(k)
  return(onlylist, onlytab, intersect)


proc compareLists*[T](list1, list2: seq[T]): (seq[T], seq[T], seq[T]) =
  var t1, t2 = initOrderedTable[T, bool]()
  
  for e in list1:
    if hasKey(t1, e):
      error(fmt("can only compare tow lists with unique keys! found dupplicate key in list 1: {e}"))
      system.quit(-38)
    t1[e] = true
  for e in list2:
    if hasKey(t2, e):
      error(fmt("can only compare tow lists with unique keys! found dupplicate key in list 2: {e}"))
      system.quit(-38)
    t2[e] = true
  return compareTableKeys(t1, t2)

proc classTableKeysWithValues*[K, V](t1, t2: Table[K, V]): (Table[K,V],Table[K,V],Table[K,V]) =
  var valuesListOnly1, valuesIntersect = initTable[K,V]()
  var valuesListOnly2 = t2
  for k, v in pairs(t1):
    if hasKey(t2, k):
      valuesIntersect[k] = v
      del(valuesListOnly2, k)
    else:
      valuesListOnly1[k] = v
  return (valuesListOnly1, valuesListOnly2, valuesIntersect)

proc classOrderedTableKeysWithValues*[K, V](t1, t2: OrderedTable[K, V]): (OrderedTable[K,V],OrderedTable[K,V],OrderedTable[K,V]) =
  var valuesListOnly1, valuesIntersect = initOrderedTable[K,V]()
  var valuesListOnly2 = t2
  for k, v in pairs(t1):
    if hasKey(t2, k):
      valuesIntersect[k] = v
      del(valuesListOnly2, k)
    else:
      valuesListOnly1[k] = v
  return (valuesListOnly1, valuesListOnly2, valuesIntersect)
  
proc compareTableKeys*[K, V](t1, t2: Table[K, V]): (seq[K], seq[K], seq[K]) =
  var valuesListOnly1, valuesListOnly2, valuesIntersect: seq[K] = @[]
  var t2s = t2
  for val in keys(t1):
    if hasKey(t2, val):
      valuesIntersect.add(val)
      del(t2s, val)
    else:
      valuesListOnly1.add(val)
  if len(t2s) > 0:
    for val in keys(t2s):
      valuesListOnly2.add(val)
  return (valuesListOnly1, valuesListOnly2, valuesIntersect)

proc compareTableKeys*[K, V](t1, t2: OrderedTable[K, V]): (seq[K], seq[K], seq[K]) =
  var valuesListOnly1, valuesListOnly2, valuesIntersect: seq[K] = @[]
  var t2s = t2
  for val in keys(t1):
    if hasKey(t2, val):
      valuesIntersect.add(val)
      del(t2s, val)
    else:
      valuesListOnly1.add(val)
  if len(t2s) > 0:
    for val in keys(t2s):
      valuesListOnly2.add(val)
  return (valuesListOnly1, valuesListOnly2, valuesIntersect)

proc compareTableKeys*[K, V, W](t1: Table[K, V], t2: Table[K, W]): (seq[K], seq[K], seq[K]) =
  var valuesListOnly1, valuesListOnly2, valuesIntersect: seq[K] = @[]
  var t2s = t2
  for val in keys(t1):
    if hasKey(t2, val):
      valuesIntersect.add(val)
      del(t2s, val)
    else:
      valuesListOnly1.add(val)
  if len(t2s) > 0:
    for val in keys(t2s):
      valuesListOnly2.add(val)
  return (valuesListOnly1, valuesListOnly2, valuesIntersect)

proc compareTableKeysWithList*[K, V](t: OrderedTable[K, V], l: seq[K]): (seq[K], seq[K], seq[K]) =
  var valuesListOnly1, valuesListOnly2, valuesIntersect: seq[K] = @[]
  var ts = t
  for val in l:
    if hasKey(t, val):
      valuesIntersect.add(val)
      del(ts, val)
    else:
      valuesListOnly1.add(val)
  if len(ts) > 0:
    for val in keys(ts):
      valuesListOnly2.add(val)
  return (valuesListOnly1, valuesListOnly2, valuesIntersect)

  
proc compareTableValues*[K, V](t1, t2: Table[K, V]): (seq[tuple[key: K, val: V]],seq[tuple[key: K, val: V]],seq[tuple[key: K, val1: V, val2: V]]) =
  var t1only,t2only: seq[tuple[key: K, val: V]] = @[]
  var diff: seq[tuple[key: K, val1: V, val2: V]] = @[]
  var t2shadow = t2
  for val in keys(t1):
    if hasKey(t2,val):
      del(t2shadow, val)
      if t1[val] != t2[val]:
        diff.add((key: val, val1: t1[val], val2: t2[val]))
    else:
      t1only.add((key: val, val: t1[val]))
  for val in keys(t2shadow):
    t2only.add((key: val, val: t2shadow[val]))
  return (t1only, t2only, diff)

proc compareTableValues*[K, V](t1, t2: OrderedTable[K, V]): (seq[tuple[key: K, val: V]],seq[tuple[key: K, val: V]],seq[tuple[key: K, val1: V, val2: V]]) =
  var t1only,t2only: seq[tuple[key: K, val: V]] = @[]
  var diff: seq[tuple[key: K, val1: V, val2: V]] = @[]
  var t2shadow = t2
  for val in keys(t1):
    if hasKey(t2,val):
      del(t2shadow, val)
      if t1[val] != t2[val]:
        diff.add((key: val, val1: t1[val], val2: t2[val]))
    else:
      t1only.add((key: val, val: t1[val]))
  for val in keys(t2shadow):
    t2only.add((key: val, val: t2shadow[val]))
  return (t1only, t2only, diff)

proc concatKeyAndValues*[K, V](t: Table[K, V], concatPrefix: string = "-", concatSuffix: string = ""): seq[string] =
  result = @[]
  for k, v in values(t):
    result.add(fmt("{k}{concatPrefix}{v}{concatSuffix}"))

proc concatKeyAndValues*[K, V](t: OrderedTable[K, V], concatPrefix: string = "-", concatSuffix: string = ""): seq[string] =
  result = @[]
  for k, v in pairs(t):
    result.add(fmt("{k}{concatPrefix}{v}{concatSuffix}"))

proc getKeylist*[K, V](t: Table[K, V]): seq[K] =
  result = @[]
  for key in keys(t):
    result.add(key)

proc getKeylist*[K, V](t: OrderedTable[K, V]): seq[K] =
  result = @[]
  for key in keys(t):
    result.add(key)


    
when isMainModule:
  let l1 = {"1": "oans", "2": "zwei", "4": "vier"}.toOrderedTable
  let l2 = {"1": "eins", "3": "drei", "4": "vierhare"}.toOrderedTable
  let (l1o, l2o, i) = compareTableValues(l1, l2)
  echo l1o
  echo l2o
  echo i
