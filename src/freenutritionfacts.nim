#[
  Created at: 09/24/2021 20:57:44 Friday
  Modified at: 09/24/2021 11:26:16 PM Friday

        Copyright (C) 2021 Thiago Navarro
  See file "license" for details about copyright
]#

from std/httpclient import newHttpClient, close, getContent
from std/uri import parseUri, `$`, Uri

from std/htmlparser import parseHtml
from std/xmltree import `$`, findAll, XmlNode, attr, items, innerText

from std/strutils import find, strip

const extractFromGauge = true

using
  node: XmlNode

func findAll(node; tagName: string; attrs: openArray[(string, string)];
             caseInsensitive = false): seq[XmlNode] =
  ## Find all tags with given attributes
  for node in node.findAll(tagName, caseInsensitive):
    for (key, val) in attrs:
      if val == node.attr key:
        result.add node

type
  FoodProps* = object
    usedGrams*: int
    nutrients*: FoodNutrients
    vitamins*: FoodVitamins
    minerals*: FoodMinerals
    energy*: string # kcal
    totalFat*: string
  FoodNutrients* = object
    carbohydrates*, sugar*, fiber*, protein*, caffeine*,
        water*, alcohol*, ash*: string
  FoodMinerals* = object
    calcium*, iron*, phosphorus*, sodium*, copper*, magnesium*, potassium*,
        zinc*, fluorin*, manganese*, selenium*: string
  FoodVitamins* = object
    a*, b1*, b2*, b3*, b5*, b6*, b9*, b12*, c*, d*, e*, k*: string

  Page* {.pure.} = enum
    pageNutrients = "",
    pageVitamins = "vitamins",
    pageMinerals = "minerals",
    pageCalories = "calories",
    pageFat = "fat"

using
  page: Page
  self: var FoodProps

const url = "http://freenutritionfacts.com".parseUri

func gen(url: Uri; path: string; page): string =
  result = uri.`/`(url, path).`$` & "/"
  let pageStr = $page
  if pageStr.len > 0:
    result &= pageStr & "/"
func getInfo(node; page; name: string; isHeader = true): string =
  ## Finds the correct info div, get the data and returns it
  block loop:
    for box in node.findAll("div", {"class": "row"}):
      # if box has no header, then skip
      if box.findAll("h2", {"class": "no-border"}).len == 0:
        continue
      # if searching header
      if isHeader:
        if box.findAll("h2")[0].innerText == name:
          when extractFromGauge:
            # get info from gauge
            let gaugeInfo = box.findAll("p", {
              "class": "text-xlg inner-top-sm inner-bottom-xs border-bottom"
            })[0]
            result = gaugeInfo.innerText
          else:
            {.fatal: "Not implemented".}
      else:
        # for each sub section in box
        for subBox in box.findAll("div", {"class": "panel panel-default"}):
          # if subtitle is same as searching name
          if subBox.findAll("p", {"class": "h3 text-primary reset-margin"})[0].innerText == name:
            # get the text
            var text = subBox.findAll("p", {"class": "h4 text-default"})[0].innerText
            let i = text.find(" |")
            if i >= 0:
              text = text[0..<i]
            result = text

  result = result.strip()

  if result.len == 0:
    doAssert false, "Error in parse"

proc get*(self; page; path: string) =
  ## Extract the given path of freenutritionfacts.com site
  var client = newHttpClient()
  let html = client.getContent(url.gen(path, page)).parseHtml
  template get(node; name: string; isHeader = true): untyped =
    node.getInfo(pageNutrients, name, isHeader)
  case page:
  of pageNutrients:
    self.energy = html.get("Energy")
    self.totalFat = html.get("Total Fat")
    self.nutrients.carbohydrates = html.get("Carbohydrates")
    self.nutrients.sugar = html.get("Sugars", false)
    self.nutrients.fiber = html.get("Dietary fiber", false)
    self.minerals.sodium = html.get("Sodium")
    self.nutrients.water = html.get("Water")
    self.nutrients.protein = html.get("Protein", false)
    self.nutrients.ash = html.get("Ash", false)
  else:
    echo page
    doAssert false, "Page not implemented"
  client.close()

when isMainModule:
  var data: FoodProps
  data.get(pageNutrients, "apples")
  echo data
