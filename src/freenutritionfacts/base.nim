from std/uri import parseUri, `/`
export uri

from std/htmlparser import parseHtml
export htmlparser

from std/xmltree import findAll, XmlNode, attr, items, innerText
export xmltree

from std/httpclient import newHttpClient, close, getContent
export httpclient

const url* = "http://www.freenutritionfacts.com".parseUri

using
  node: XmlNode

type
  FindAttr* = tuple
    attr, val: string

# TODO: Move this to `findxml`
func findAll*(node; tagName: string; attrs: openArray[FindAttr];
             caseInsensitive = false): seq[XmlNode] =
  ## Find all tags with given attributes
  for node in node.findAll(tagName, caseInsensitive):
    for (key, val) in attrs:
      if val == node.attr key:
        result.add node
func findAll*(node; sels: openArray[(string, seq[FindAttr])];
              caseInsensitive = false): seq[XmlNode] =
  ## querySelectorAll
  var el = node
  for (name, attrs) in sels:
    result = el.findAll(name, attrs, caseInsensitive)
    if result.len == 0:
      break
    el = result[0]
