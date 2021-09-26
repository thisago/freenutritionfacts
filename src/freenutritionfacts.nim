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

from std/strutils import find, strip, replace
from std/tables import `[]`, toTable, hasKey, Table

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
    name*: string
    grams*: string
    others*: FoodOthers
    nutrients*: FoodNutrients
    vitamins*: FoodVitamins
    minerals*: FoodMinerals
    fat*: FoodFat
    energy*: string # kcal
  FoodNutrients* = object
    carbohydrates*, sugar*, fiber*, protein*, caffeine*,
      water*: string
  FoodMinerals* = object
    calcium*, iron*, phosphorus*, sodium*, copper*, magnesium*, potassium*,
      zinc*, fluorine*, manganese*, selenium*: string
  FoodVitamins* = object
    a*, b1*, b2*, b3*, b5*, b6*, b9*, b12*, c*, d*, e*, k*: string
  FoodFat* = object
    total*, saturated*, cholesterol*: string
  FoodOthers* = object
    alcohol*, ash*: string
  Page* {.pure.} = enum
    pageNutrients = "",
    pageVitamins = "vitamins",
    pageMinerals = "minerals",
    pageCalories = "calories",
    pageFat = "fat"

using
  page: Page
  self: var FoodProps

const url = "http://www.freenutritionfacts.com".parseUri

func gen(url: Uri; path: string; page): string =
  result = uri.`/`(url, path).`$` & "/"
  let pageStr = $page
  if pageStr.len > 0:
    result &= pageStr & "/"
func extractData(node; page): seq[(string, string)] =
  ## Finds the correct info div, get the data and returns it
  var processed: seq[string]
  for box in node.findAll("div", {"class": "row"}):
    # if box has no header, then skip
    if box.findAll("h2", {"class": "no-border"}).len == 0:
      continue
    let title =  box.findAll("h2")[0].innerText
    if title notin processed:
      when extractFromGauge:
        # get info from gauge
        let gaugeInfo = box.findAll("p", {
          "class": "text-xlg inner-top-sm inner-bottom-xs border-bottom"
        })
        if gaugeInfo.len > 0:
          processed.add title
          result.add (title, gaugeInfo[0].innerText)
      else:
        {.fatal: "Not implemented".}
        
    # for each sub section in box
    for subBox in box.findAll("div", {"class": "panel panel-default"}):
      # get subtitle
      let pTitle = subBox.findAll("p", {"class": "h3 text-primary reset-margin"})
      if pTitle.len > 0:
        let title = pTitle[0].innerText
        if title notin processed:
          # get the text
          var p = subBox.findAll("p", {"class": "h4 text-default"})
          if p.len > 0:
            var text = p[0].innerText
            let i = text.find(" |")
            if i >= 0:
              text = text[0..<i]
            processed.add title
            result.add (title, text)
  let gramsEl = node.findAll("p", {"class": "h4 pull-left"})
  if gramsEl.len > 0:
    let grams = gramsEl[0].innerText.replace("Nutrition Facts for ", "").strip()
    result.add ("grams", grams)

func initFoodProps*(name: string): FoodProps =
  FoodProps(name: name)

proc get(t: Table; key: string): string {.inline.} =
  if t.hasKey key:
    result = t[key]

proc extract*(self; page) =
  ## Extract the given path of freenutritionfacts.com site
  var client = newHttpClient()
  let html = client.getContent(url.gen(self.name, page)).parseHtml
  let data = html.extractData(pageNutrients).toTable
  #echo html.extractData(pageNutrients)
  self.grams = data["grams"]
  case page:
  of pageNutrients:
    self.energy = data.get "Energy"
    self.fat.total = data.get "Total Fat"
    self.fat.cholesterol = data.get "Cholesterol"
    self.nutrients.carbohydrates = data.get "Carbohydrates"
    self.nutrients.sugar = data.get "Sugars"
    self.nutrients.fiber = data.get "Dietary fiber"
    self.minerals.sodium = data.get "Sodium"
    self.nutrients.water = data.get "Water"
    self.nutrients.protein = data.get "Protein"
    self.nutrients.caffeine = data.get "Caffeine"
    self.others.ash = data.get "Ash"
    self.others.alcohol = data.get "Alcohol"
  of pageVitamins:
    self.vitamins.a = data.get "Vitamin A"
    self.vitamins.c = data.get "Vitamin C"
    self.vitamins.d = data.get "Vitamin D"
    self.vitamins.e = data.get "Vitamin E"
    self.vitamins.k = data.get "Vitamin K"
    self.vitamins.b1 = data.get "Vitamin B-1"
    self.vitamins.b2 = data.get "Vitamin B-2"
    self.vitamins.b3 = data.get "Vitamin B-3"
    self.vitamins.b5 = data.get "Vitamin B-5"
    self.vitamins.b9 = data.get "Vitamin B-9"
    self.vitamins.b12 = data.get "Vitamin B-12"
  of pageMinerals:
    self.minerals.calcium = data.get "Calcium"
    self.minerals.iron = data.get "Iron"
    self.minerals.phosphorus = data.get "Phosphorus"
    self.minerals.sodium = data.get "Sodium"
    self.minerals.copper = data.get "Copper"
    self.minerals.magnesium = data.get "Magnesium"
    self.minerals.potassium = data.get "Potassium"
    self.minerals.zinc = data.get "Zinc"
    self.minerals.fluorine = data.get "Flourine"
    self.minerals.manganese = data.get "Manganese"
    self.minerals.selenium = data.get "Selenium"
  of pageCalories:
    self.energy = data.get "Energy"
  of pageFat:
    self.fat.total = data.get "Total Fat"
    self.fat.saturated = data.get "Saturated Fat"
    self.fat.cholesterol = data.get "Cholesterol"
  client.close()

proc extractAll*(self) =
  for page in Page:
    if page != Page.pageCalories:
      self.extract page

when isMainModule:
  import pkg/jsony
  #echo "Food:"
  var data = initFoodProps stdin.readLine.strip
  # var data = initFoodProps "wine-alcoholic-beverage" # stdin.readLine.strip
  # var data = initFoodProps "cream" # stdin.readLine.strip
  #data.extract pageNutrients
  #echo data
  #data.extract pageVitamins
  #data.extract pageMinerals
  #data.extract pageCalories
  #data.extract pageFat
  data.extractAll()
  echo data.toJson
