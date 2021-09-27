from std/httpclient import newHttpClient, close, getContent, HttpClient
from std/xmltree import `$`
from std/strutils import parseInt, multiReplace, toLowerAscii

import freenutritionfacts/base

type
  FoodCategory* = object
    name*: string
    foods*: seq[string]

using
  self: var FoodCategory

func initFoodCategory*(name: string): FoodCategory =
  ## Initialize the `foodCategory` object
  result.name = name

proc parse*(self; html: XmlNode): bool =
  ## Parses the given HTML and returns true if not last page
  try:
    let
      currentPage = html.findAll("li", @{"class":"active"})[0].innerText.parseInt
      lastPage = html.findAll("li")[^2].innerText.parseInt
    result = currentPage < lastPage
  except: discard

  for food in html.findAll("a", {"class": "list-group-item"}):
    self.foods.add food.innerText  

proc extractAll*(self) =
  ## Extracts the items of given category page
  template  getPage(c: HttpClient; url: Uri; page: int): XmlNode =
    var u = $url
    if page > 1:
      u = $(url / $page)
    parseHtml c.getContent $u & '/'
  let url = url / self.name
  var
    client = newHttpClient()
    page = 1
    html = client.getPage(url, page)
  while self.parse html:
    html = client.getPage(url, page)
    inc page
  client.close()

func toFoodName*(readableName: string): string =
  readableName.multiReplace({
    " ": "-",
    ",": ""
  }).toLowerAscii

when isMainModule:
  import pkg/jsony
  # var category = initFoodCategory "fruits-and-fruit-juices"
  var category = initFoodCategory "baby-foods/babyfood"
  category.extractAll()
  echo category.toJson
  echo category.foods[^1].toFoodName
