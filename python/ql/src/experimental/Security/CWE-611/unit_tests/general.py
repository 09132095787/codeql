from flask import request, Flask
from io import StringIO
import xml.etree, xml.etree.ElementTree
import lxml.etree
import xml.dom.minidom, xml.dom.pulldom
import xmltodict

'''
XML Parsers:
  xml.etree.ElementTree.XMLParser() - no options, vuln by default
  lxml.etree.XMLParser() - no_network=True huge_tree=False resolve_entities=True
  lxml.etree.get_default_parser() - no options, default above options
  xml.sax.make_parser() - parser.setFeature(xml.sax.handler.feature_external_ges, True)

XML Parsing:
  string:
    xml.etree.ElementTree.fromstring(list)
    xml.etree.ElementTree.XML
    lxml.etree.fromstring(list)
    lxml.etree.XML
    xmltodict.parse

  file StringIO(), BytesIO(b):
    xml.etree.ElementTree.parse
    lxml.etree.parse
    xml.dom.(mini|pull)dom.parse(String)
'''

@app.route("/XMLParser-Empty&xml.etree.ElementTree.fromstring")
def test1():
  xml_content = request.args['xml_content'] # <?xml version="1.0"?><!DOCTYPE dt [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><test>&xxe;</test>

  parser = lxml.etree.XMLParser()
  return xml.etree.ElementTree.fromstring(xml_content, parser=parser).text # 'root...'

@app.route("/XMLParser-Empty&xml.etree.ElementTree.parse")#!
def test1():
  xml_content = request.args['xml_content'] # <?xml version="1.0"?><!DOCTYPE dt [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><test>&xxe;</test>

  parser = lxml.etree.XMLParser()
  return xml.etree.ElementTree.parse(StringIO(xml_content), parser=parser).getroot().text # 'jorgectf'

@app.route("/XMLParser-Empty&lxml.etree.fromstring")
def test1():
  xml_content = request.args['xml_content'] # <?xml version="1.0"?><!DOCTYPE dt [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><test>&xxe;</test>

  parser = lxml.etree.XMLParser()
  return lxml.etree.fromstring(xml_content, parser=parser).text # 'jorgectf'

@app.route("/XMLParser-Empty&xml.etree.parse")#!
def test1():
  xml_content = request.args['xml_content'] # <?xml version="1.0"?><!DOCTYPE dt [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><test>&xxe;</test>

  parser = lxml.etree.XMLParser()
  return lxml.etree.parse(StringIO(xml_content), parser=parser).getroot().text # 'jorgectf'

@app.route("/xmltodict-disable_entities_False")
def test2():
  xml_content = request.args['xml_content'] # <?xml version="1.0"?><!DOCTYPE dt [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><test>&xxe;</test>

  return xmltodict.parse(xml_content, disable_entities=False)


