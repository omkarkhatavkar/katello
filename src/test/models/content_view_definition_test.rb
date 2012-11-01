#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'

class ContentViewDefinitionTest < MiniTest::Rails::ActiveSupport::TestCase

  def setup
    models = ["Organization", "KTEnvironment", "User", "Product", "Repository"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
    @content_view_def = FactoryGirl.build(:content_view_definition)
  end

  def teardown
    @content_view_def.destroy if @content_view_def.persisted?
  end

  def test_create
    assert @content_view_def.save
  end

  def test_bad_name
    content_view_def = FactoryGirl.build(:content_view_definition, :name => "")
    assert content_view_def.invalid?
    assert content_view_def.errors.has_key?(:name)
  end

  def test_destroy_with_content_views
    content_view = FactoryGirl.create(:content_view)
    definition = FactoryGirl.create(:content_view_definition,
                                    :content_views => [content_view])
    assert definition.destroy
    assert_not_nil ContentView.find_by_id(content_view.id)
  end

  def test_publish
    content_view_def = FactoryGirl.create(:content_view_definition)
    content_view = content_view_def.publish
    refute_nil content_view
    refute_empty content_view_def.content_views.reload
    assert_includes content_view_def.content_views, content_view
  end

  def test_products
    @content_view_def.save!
    provider = FactoryGirl.build_stubbed(:provider)
    product = FactoryGirl.create(:product, :provider => provider)
    @content_view_def.products << product
    assert_includes product.content_view_definitions.reload, @content_view_def
  end

  def test_repos
    @content_view_def.save!
    provider = FactoryGirl.build_stubbed(:provider)
    product = FactoryGirl.build_stubbed(:product, :provider => provider)
    env_product = FactoryGirl.build_stubbed(:environment_product,
                                            :product => product)
    repo = FactoryGirl.create(:repository, :environment_product => env_product)
    @content_view_def.repositories << repo
    assert_equal repo.content_view_definition.reload, @content_view_def
    assert_includes @content_view_def.repositories.reload, repo
  end
end
