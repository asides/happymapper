# frozen_string_literal: true

require 'spec_helper'

class CatalogTree
  include HappyMapper

  tag 'CatalogTree'
  register_namespace 'xmlns', 'urn:eventis:prodis:onlineapi:1.0'
  register_namespace 'xsi', 'http://www.w3.org/2001/XMLSchema-instance'
  register_namespace 'xsd', 'http://www.w3.org/2001/XMLSchema'

  attribute :code, String

  has_many :nodes, 'CatalogNode', tag: 'Node', xpath: '.'
end

class CatalogNode
  include HappyMapper

  tag 'Node'

  attribute :back_office_id, String, tag: 'vodBackOfficeId'

  has_one :name, String, tag: 'Name'
  # other important fields

  has_many :translations, 'CatalogNode::Translations', tag: 'Translation', xpath: 'child::*'

  class Translations
    include HappyMapper
    tag 'Translation'

    attribute :language, String, tag: 'Language'
    has_one :name, String, tag: 'Name'
  end

  has_many :nodes, CatalogNode, tag: 'Node', xpath: 'child::*'
end

describe HappyMapper do
  let(:catalog_tree) { CatalogTree.parse(fixture_file('inagy.xml'), single: true) }

  it 'is not nil' do
    expect(catalog_tree).not_to be_nil
  end

  it 'has the attribute code' do
    expect(catalog_tree.code).to eq('NLD')
  end

  it 'has many nodes' do
    expect(catalog_tree.nodes).not_to be_empty
    expect(catalog_tree.nodes.length).to eq(2)
  end

  context 'first node' do
    let(:first_node) { catalog_tree.nodes.first }

    it 'has a name' do
      expect(first_node.name).to eq('Parent 1')
    end

    it 'has translations' do
      expect(first_node.translations.length).to eq(2)

      expect(first_node.translations.first.language).to eq('en-GB')

      expect(first_node.translations.last.name).to eq('Parent 1 de')
    end

    it 'has subnodes' do
      expect(first_node.nodes).to be_kind_of(Enumerable)
      expect(first_node.nodes).not_to be_empty
      expect(first_node.nodes.length).to eq(1)
    end

    it 'first node - first node name' do
      expect(first_node.nodes.first.name).to eq('First')
    end
  end
end
