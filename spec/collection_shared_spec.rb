require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

# TODO: test all instance methods when collection is loaded and not loaded

describe 'A Collection', :shared => true do
  before do
    %w[ @article_repository @model @other @article @articles @other_articles ].each do |ivar|
      raise "+#{ivar}+ should be defined in before block" unless instance_variable_get(ivar)
    end
  end

  after do
    @articles.dup.destroy!
  end

  it 'should respond to #<<' do
    @articles.should respond_to(:<<)
  end

  describe '#<<' do
    before do
      @resource = @model.new(:title => 'Title')
      @return = @articles << @resource
    end

    it 'should return a Collection' do
      @return.should be_kind_of(DataMapper::Collection)
    end

    it 'should return self' do
      @return.object_id.should == @articles.object_id
    end

    it 'should append the Resource to the Collection' do
      @articles.last.object_id.should == @resource.object_id
    end

    it 'should relate the Resource to the Collection' do
      @resource.collection.object_id.should == @articles.object_id
    end
  end

  it 'should respond to #all' do
    @articles.should respond_to(:all)
  end

  describe '#all' do
    describe 'with no arguments' do
      before do
        @return = @articles.all
      end

      it 'should return a Collection' do
        @return.should be_kind_of(DataMapper::Collection)
      end

      it 'should return self' do
        @return.object_id.should == @articles.object_id
      end

      describe 'the query' do
        before do
          @query = @return.query
        end

        it 'should have an offset equal to 0' do
          @query.offset.should == 0
        end

        it 'should have a limit equal to nil' do
          @query.limit.should be_nil
        end
      end
    end

    describe 'with query' do
      before do
        @return = @articles.all(:limit => 10, :offset => 10)
      end

      it 'should return a Collection' do
        @return.should be_kind_of(DataMapper::Collection)
      end

      it 'should return a new Collection' do
        @return.object_id.should_not == @articles.object_id
      end

      it 'should have a different query than original Collection' do
        @return.query.should_not == @articles.query
      end

      it 'is empty when passed an offset that is out of range' do
        pending do
          empty_collection = @return.all(:offset => 10)
          empty_collection.should == []
          empty_collection.should be_loaded
        end
      end
    end
  end

  it 'should respond to #at' do
    @articles.should respond_to(:at)
  end

  describe '#at' do
    describe 'with positive offset' do
      before do
        @return = @resource = @articles.at(0)
      end

      it 'should return a Resource' do
        @return.should be_kind_of(DataMapper::Resource)
      end

      it 'should return the Resource by offset' do
        @return.key.should == @article.key
      end
    end

    describe 'with negative offset' do
      before do
        @return = @resource = @articles.at(-1)
      end

      it 'should return a Resource' do
        @return.should be_kind_of(DataMapper::Resource)
      end

      it 'should return the Resource by offset' do
        @return.key.should == @article.key
      end
    end
  end

  it 'should respond to #build' do
    @articles.should respond_to(:build)
  end

  describe '#build' do
    before do
      @return = @resource = @articles.build(:content => 'Content')
    end

    it 'should return a Resource' do
      @return.should be_kind_of(DataMapper::Resource)
    end

    it 'should be a Resource with expected attributes' do
      @resource.attributes.only(:content).should == { :content => 'Content' }
    end

    it 'should be a new Resource' do
      @resource.should be_new_record
    end

    it 'should append the Resource to the Collection' do
      @articles.last.object_id.should == @resource.object_id
    end

    it 'should use the query conditions to set default values' do
      @resource.attributes.only(:title).should == { :title => 'Sample Article' }
    end
  end

  it 'should respond to #clear' do
    @articles.should respond_to(:clear)
  end

  describe '#clear' do
    before do
      @resources = @articles.entries
      @return = @articles.clear
    end

    it 'should return a Collection' do
      @return.should be_kind_of(DataMapper::Collection)
    end

    it 'should return self' do
      @return.object_id.should == @articles.object_id
    end

    it 'should make the Collection empty' do
      @articles.should be_empty
    end

    it 'should orphan each removed Resource from the Collection' do
      @resources.each { |r| r.collection.object_id.should_not == @articles.object_id }
    end
  end

  it 'should respond to #collect!' do
    @articles.should respond_to(:collect!)
  end

  describe '#collect!' do
    before do
      @resources = @articles.entries
      @return = @articles.collect! { |r| @model.new(:title => 'Title') }
    end

    it 'should return a Collection' do
      @return.should be_kind_of(DataMapper::Collection)
    end

    it 'should return self' do
      @return.object_id.should == @articles.object_id
    end

    it 'should update the Collection inline' do
      @articles.should == [ @model.new(:title => 'Title') ]
    end

    it 'should orphan each replaced Resource from the Collection' do
      pending do
        @resources.each { |r| r.collection.object_id.should_not == @articles.object_id }
      end
    end
  end

  it 'should respond to #concat' do
    @articles.should respond_to(:concat)
  end

  describe '#concat' do
    before do
      @resources = @other_articles.entries
      @return = @articles.concat(@other_articles)
    end

    it 'should return a Collection' do
      @return.should be_kind_of(DataMapper::Collection)
    end

    it 'should return self' do
      @return.object_id.should == @articles.object_id
    end

    it 'should concatenate the two collections' do
      @return.should == [ @article, @other ]
    end

    it 'should relate each concatenated Resource from the Collection' do
      pending do
        @resources.each { |r| r.collection.object_id.should == @articles.object_id }
      end
    end
  end

  it 'should respond to #create' do
    @articles.should respond_to(:create)
  end

  describe '#create' do
    before do
      @return = @resource = @articles.create(:content => 'Content')
    end

    it 'should return a Resource' do
      @return.should be_kind_of(DataMapper::Resource)
    end

    it 'should be a Resource with expected attributes' do
      @resource.attributes.only(:content).should == { :content => 'Content' }
    end

    it 'should be a saved Resource' do
      @resource.should_not be_new_record
    end

    it 'should append the Resource to the Collection' do
      @articles.last.object_id.should == @resource.object_id
    end

    it 'should use the query conditions to set default values' do
      @resource.attributes.only(:title).should == { :title => 'Sample Article' }
    end

# XXX: how can this be refactored without a mock that fails?
#    it 'should not append the resource if it was not saved' do
#      @article_repository.should_receive(:create).and_return(false)
#      @model.should_receive(:repository).at_least(:once).and_return(@article_repository)
#
#      article = @articles.create
#      article.should be_new_record
#
#      article.collection.object_id.should_not == @articles.object_id
#      @articles.should_not include(article)
#    end
  end

  it 'should respond to #delete' do
    @articles.should respond_to(:delete)
  end

  describe '#delete' do
    describe 'with a Resource within the Collection' do
      before do
        @return = @resource = @articles.delete(@article)
      end

      it 'should return a DataMapper::Resource' do
        @return.should be_kind_of(DataMapper::Resource)
      end

      it 'should be the expected Resource' do
        @resource.should == @article  # may be different object_id depending on the Adapter
      end

      it 'should orphan the Resource' do
        @resource.collection.object_id.should_not == @articles.object_id
      end
    end

    describe 'with a Resource not within the Collection' do
      before do
        @return = @articles.delete(@other)
      end

      it 'should return nil' do
        @return.should be_nil
      end
    end
  end

  it 'should respond to #delete_at' do
    @articles.should respond_to(:delete_at)
  end

  describe '#delete_at' do
    describe 'with an index within the Collection' do
      before do
        @return = @resource = @articles.delete_at(0)
      end

      it 'should return a DataMapper::Resource' do
        @return.should be_kind_of(DataMapper::Resource)
      end

      it 'should be the expected Resource' do
        @resource.should == @article  # may be different object_id depending on the Adapter
      end

      it 'should orphan the Resource' do
        @resource.collection.object_id.should_not == @articles.object_id
      end
    end

    describe 'with an index not within the Collection' do
      before do
        @return = @articles.delete_at(1)
      end

      it 'should return nil' do
        @return.should be_nil
      end
    end
  end

  it 'should respond to #destroy' do
    @articles.should respond_to(:destroy)
  end

  describe '#destroy' do
    before do
      pending do
        @return = @articles.destroy
      end
    end

    it 'should return true' do
      @return.should be_true
    end

    it 'should remove the resources from the datasource' do
      @model.all(:title => 'Sample Article').should be_empty
    end

    it 'should clear the collection' do
      @articles.should be_empty
    end
  end

  it 'should respond to #destroy!' do
    @articles.should respond_to(:destroy!)
  end

  describe '#destroy!' do
    before do
      @return = @articles.destroy!
    end

    it 'should return true' do
      @return.should be_true
    end

    it 'should remove the resources from the datasource' do
      @model.all(:title => 'Sample Article').should be_empty
    end

    it 'should clear the collection' do
      @articles.should be_empty
    end

    it 'should skip foreign key validation'
  end

  it 'should respond to #first' do
    @articles.should respond_to(:first)
  end

  describe '#first' do
    describe 'with no arguments' do
      before do
        @return = @resource = @articles.first
      end

      it 'should return a Resource' do
        @return.should be_kind_of(DataMapper::Resource)
      end

      it 'should be first Resource in the Collection' do
        @resource.should == @article
      end
    end

    describe 'with limit specified' do
      before do
        @return = @collection = @articles.first(1)
      end

      it 'should return a Collection' do
        @return.should be_kind_of(DataMapper::Collection)
      end

      it 'should be the first N Resources in the Collection' do
        @collection.should == [ @article ]
      end
    end

    describe 'with query specified' do
      before do
        @return = @resource = @articles.first(:content => 'Sample')
      end

      it 'should return a Resource' do
        @return.should be_kind_of(DataMapper::Resource)
      end

      it 'should should be the first Resource in the Collection matching the query' do
        @resource.should == @article
      end
    end

    describe 'with limit and query specified' do
      before do
        @return = @collection =  @articles.first(1, :content => 'Sample')
      end

      it 'should return a Collection' do
        @return.should be_kind_of(DataMapper::Collection)
      end

      it 'should be the first N Resources in the Collection matching the query' do
        @collection.should == [ @article ]
      end
    end
  end

  it 'should respond to #get' do
    @articles.should respond_to(:get)
  end

#  describe '#get' do
#    it 'should find a resource in a collection by key' do
#      article = @articles.get(*@new_article.key)
#      article.should be_kind_of(DataMapper::Resource)
#      article.id.should == @new_article.id
#    end
#
#    it "should find a resource in a collection by typecasting the key" do
#      article = @articles.get(@new_article.key.to_s)
#      article.should be_kind_of(DataMapper::Resource)
#      article.id.should == @new_article.id
#    end
#
#    it 'should not find a resource not in the collection' do
#      @query.update(:offset => 0, :limit => 3)
#      @david = Zebra.create(:name => 'David', :age => 15,  :notes => 'Albino')
#      @articles.get(@david.key).should be_nil
#    end
#  end

  it 'should respond to #get!' do
    @articles.should respond_to(:get!)
  end

#  describe '#get!' do
#    it 'should find a resource in a collection by key' do
#      article = @articles.get!(*@new_article.key)
#      article.should be_kind_of(DataMapper::Resource)
#      article.id.should == @new_article.id
#    end
#
#    it 'should raise an exception if the resource is not found' do
#      @query.update(:offset => 0, :limit => 3)
#      @david = Zebra.create(:name => 'David', :age => 15,  :notes => 'Albino')
#      lambda {
#        @articles.get!(@david.key)
#      }.should raise_error(DataMapper::ObjectNotFoundError)
#    end
#  end

  it 'should respond to #insert' do
    @articles.should respond_to(:insert)
  end

#  describe '#insert' do
#    it 'should return self' do
#      @articles.insert(1, @steve).object_id.should == @articles.object_id
#    end
#  end

  it 'should respond to #last' do
    @articles.should respond_to(:last)
  end

  describe '#last' do
    describe 'with no arguments' do
      before do
        @return = @resource = @articles.last
      end

      it 'should return a Resource' do
        @return.should be_kind_of(DataMapper::Resource)
      end

      it 'should be last Resource in the Collection' do
        @resource.should == @article
      end
    end

    describe 'with limit specified' do
      before do
        @return = @collection = @articles.last(1)
      end

      it 'should return a Collection' do
        @return.should be_kind_of(DataMapper::Collection)
      end

      it 'should be the last N Resources in the Collection' do
        @collection.should == [ @article ]
      end
    end

    describe 'with query specified' do
      before do
        @return = @resource = @articles.last(:content => 'Sample')
      end

      it 'should return a Resource' do
        @return.should be_kind_of(DataMapper::Resource)
      end

      it 'should should be the last Resource in the Collection matching the query' do
        @resource.should == @article
      end
    end

    describe 'with limit and query specified' do
      before do
        @return = @collection =  @articles.last(1, :content => 'Sample')
      end

      it 'should return a Collection' do
        @return.should be_kind_of(DataMapper::Collection)
      end

      it 'should be the last N Resources in the Collection matching the query' do
        @collection.should == [ @article ]
      end
    end
  end

  it 'should respond to #load' do
    @articles.should respond_to(:load)
  end

#  describe '#load' do
#    it 'should load resources from the identity map when possible' do
#      @steve.collection = nil
#      @article_repository.identity_map(@model).should_receive(:get).with([ @steve.id ]).and_return(@steve)
#
#      collection = @article_repository.read_many(@query.merge(:id => @steve.id))
#
#      collection.size.should == 1
#      collection.map { |r| r.object_id }.should == [ @steve.object_id ]
#
#      @steve.collection.object_id.should == collection.object_id
#    end
#
#    it 'should return a Resource' do
#      @articles.load([ @steve.id, @steve.name, @steve.age ]).should be_kind_of(DataMapper::Resource)
#    end
#  end

  it 'should respond to #pop' do
    @articles.should respond_to(:pop)
  end

#  describe '#pop' do
#    it 'should orphan the resource from the collection' do
#      collection = @steve.collection
#
#      # resource is related
#      @steve.collection.object_id.should == collection.object_id
#
#      collection.should have(1).entries
#      collection.pop.object_id.should == @steve.object_id
#      collection.should be_empty
#
#      # resource is orphaned
#      @steve.collection.object_id.should_not == collection.object_id
#    end
#
#    it 'should return a Resource' do
#      @articles.pop.key.should == @steve.key
#    end
#  end

  it 'should respond to #push' do
    @articles.should respond_to(:push)
  end

#  describe '#push' do
#    it 'should relate each new resource to the collection' do
#      # resource is orphaned
#      @new_article.collection.object_id.should_not == @articles.object_id
#
#      @articles.push(@new_article)
#
#      # resource is related
#      @new_article.collection.object_id.should == @articles.object_id
#    end
#
#    it 'should return self' do
#      @articles.push(@steve).object_id.should == @articles.object_id
#    end
#  end

  it 'should respond to #reject!' do
    @articles.should respond_to(:reject!)
  end

#  describe '#reject!' do
#    it 'should return self if resources matched the block' do
#      @articles.reject! { |article| true }.object_id.should == @articles.object_id
#    end
#
#    it 'should return nil if no resources matched the block' do
#      @articles.reject! { |article| false }.should be_nil
#    end
#  end

  it 'should respond to #reload' do
    @articles.should respond_to(:reload)
  end

#  describe '#reload' do
#    it 'should return self' do
#      @articles.reload.object_id.should == @articles.object_id
#    end
#
#    it 'should replace the collection' do
#      original = @articles.dup
#      @articles.reload.should == @articles
#      @articles.should == original
#    end
#
#    it 'should reload lazily initialized fields' do
#      pending 'Move to unit specs'
#
#      @article_repository.should_receive(:all) do |model,query|
#        model.should == @model
#
#        query.should be_instance_of(DataMapper::Query)
#        query.reload.should     == true
#        query.offset.should     == 0
#        query.limit.should      == 10
#        query.order.should      == []
#        query.fields.should     == @model.properties.defaults
#        query.links.should      == []
#        query.includes.should   == []
#        query.conditions.should == [ [ :eql, @model.properties[:id], [ 1, 2, 3 ] ] ]
#
#        @articles
#      end
#
#      @articles.reload
#    end
#  end

  it 'should respond to #replace' do
    @articles.should respond_to(:replace)
  end

#  describe '#replace' do
#    it "should orphan each existing resource from the collection if loaded?" do
#      entries = @articles.entries
#
#      # resources are related
#      entries.each { |r| r.collection.object_id.should == @articles.object_id }
#
#      @articles.should have(3).entries
#      @articles.replace([]).object_id.should == @articles.object_id
#      @articles.should be_empty
#
#      # resources are orphaned
#      entries.each { |r| r.collection.object_id.should_not == @articles.object_id }
#    end
#
#    it 'should relate each new resource to the collection' do
#      # resource is orphaned
#      @new_article.collection.object_id.should_not == @articles.object_id
#
#      @articles.replace([ @new_article ])
#
#      # resource is related
#      @new_article.collection.object_id.should == @articles.object_id
#    end
#
#    it 'should replace the contents of the collection' do
#      other = [ @new_article ]
#      @articles.should_not == other
#      @articles.replace(other)
#      @articles.should == other
#      @articles.object_id.should_not == @other_articles.object_id
#    end
#  end

  it 'should respond to #reverse' do
    @articles.should respond_to(:reverse)
  end

#  describe '#reverse' do
#    [ true, false ].each do |loaded|
#      describe "on a collection where loaded? == #{loaded}" do
#        before do
#          @articles.to_a if loaded
#        end
#
#        it 'should return a Collection with reversed entries' do
#          reversed = @articles.reverse
#          reversed.should be_kind_of(DataMapper::Collection)
#          reversed.object_id.should_not == @articles.object_id
#          reversed.entries.should == @articles.entries.reverse
#
#          reversed.query.order.size.should == 1
#          reversed.query.order.first.property.should == @model.properties[:id]
#          reversed.query.order.first.direction.should == :desc
#        end
#      end
#    end
#  end

  it 'should respond to #shift' do
    @articles.should respond_to(:shift)
  end

#  describe '#shift' do
#    it 'should orphan the resource from the collection' do
#      collection = @new_article.collection
#
#      # resource is related
#      @new_article.collection.object_id.should == collection.object_id
#
#      collection.should have(1).entries
#      collection.shift.object_id.should == @new_article.object_id
#      collection.should be_empty
#
#      # resource is orphaned
#      @new_article.collection.object_id.should_not == collection.object_id
#    end
#
#    it 'should return a Resource' do
#      @articles.shift.key.should == @new_article.key
#    end
#  end

  [ :slice, :[] ].each do |method|
    it "should respond to ##{method}" do
      @articles.should respond_to(method)
    end

#    describe "##{method}" do
#      describe 'with an index' do
#        it 'should return a Resource' do
#          resource = @articles.send(method, 0)
#          resource.should be_kind_of(DataMapper::Resource)
#          resource.id.should == @new_article.id
#        end
#      end
#
#      describe 'with a start and length' do
#        it 'should return a Collection' do
#          sliced = @articles.send(method, 0, 1)
#          sliced.should be_kind_of(DataMapper::Collection)
#          sliced.object_id.should_not == @articles.object_id
#          sliced.length.should == 1
#          sliced.map { |r| r.id }.should == [ @new_article.id ]
#        end
#      end
#
#      describe 'with a Range' do
#        it 'should return a Collection' do
#          sliced = @articles.send(method, 0..1)
#          sliced.should be_kind_of(DataMapper::Collection)
#          sliced.object_id.should_not == @articles.object_id
#          sliced.length.should == 2
#          sliced.map { |r| r.id }.should == [ @new_article.id, @bessie.id ]
#        end
#      end
#    end
  end

  it 'should respond to #slice!' do
    @articles.should respond_to(:slice)
  end

#  describe '#slice!' do
#    describe 'with an index' do
#      it 'should return a Resource' do
#        resource = @articles.slice!(0)
#        resource.should be_kind_of(DataMapper::Resource)
#      end
#    end
#
#    describe 'with a start and length' do
#      it 'should return an Array' do
#        sliced = @articles.slice!(0, 1)
#        sliced.class.should == Array
#        sliced.map { |r| r.id }.should == [ @new_article.id ]
#      end
#    end
#
#    describe 'with a Range' do
#      it 'should return a Collection' do
#        sliced = @articles.slice(0..1)
#        sliced.should be_kind_of(DataMapper::Collection)
#        sliced.object_id.should_not == @articles.object_id
#        sliced.length.should == 2
#        sliced[0].id.should == @new_article.id
#        sliced[1].id.should == @bessie.id
#      end
#    end
#  end

  it 'should respond to #sort!' do
    @articles.should respond_to(:sort!)
  end

#  describe '#sort!' do
#    it 'should return self' do
#      @articles.sort! { |a,b| 0 }.object_id.should == @articles.object_id
#    end
#  end

  it 'should respond to #unshift' do
    @articles.should respond_to(:unshift)
  end

#  describe '#unshift' do
#    it 'should relate each new resource to the collection' do
#      # resource is orphaned
#      @new_article.collection.object_id.should_not == @articles.object_id
#
#      @articles.unshift(@new_article)
#
#      # resource is related
#      @new_article.collection.object_id.should == @articles.object_id
#    end
#
#    it 'should return self' do
#      @articles.unshift(@steve).object_id.should == @articles.object_id
#    end
#  end

  it 'should respond to #update!' do
    @articles.should respond_to(:update!)
  end

#  describe '#update!' do
#    it 'should update the resources in the collection' do
#      pending do
#        # this will not pass with new update!
#        # update! should never loop through and set attributes
#        # even if it is loaded, and it will not reload the
#        # changed objects (even with reload=true, as objects
#        # are created is not in any identity map)
#        names = [ @new_article.name, @bessie.name, @steve.name ]
#        @articles.map { |r| r.name }.should == names
#        @articles.update!(:name => 'John')
#        @articles.map { |r| r.name }.should_not == names
#        @articles.map { |r| r.name }.should == %w[ John ] * 3
#      end
#    end
#
#    it 'should not update loaded resources unless forced' do
#      pending 'Fix in-memory adapter to return copies of data'
#      @article_repository.scope do
#        articles = @articles.reload
#        article  = articles.first
#
#        article.title.should == 'Sample Article'
#
#        articles.update!(:title => 'Updated Article')
#
#        article.title.should == 'Sample Article'
#      end
#    end
#
#    it 'should update loaded resources if forced' do
#      @article_repository.scope do |r|
#        articles = @articles.reload
#        article  = @model.first(:title => 'Sample Article')
#
#        articles.update!({ :title => 'Updated Article' }, true)
#
#        article.title.should == 'Updated Article'
#      end
#    end
#
#    it 'should update collection-query when updating' do
#      get_condition = lambda do |collection,name|
#        collection.query.conditions.detect { |c| c[0] == :eql && c[1].name == name }[2]
#      end
#
#      @article_repository.scope do
#        articles = @articles.all(:title => 'Sample Article')
#        get_condition.call(articles, :title).should == 'Sample Article'
#        articles.length.should == 1
#        articles.update!(:title => 'Updated Article')
#        articles.length.should == 1
#        get_condition.call(articles, :title).should == 'Updated Article'
#      end
#    end
#  end
end
