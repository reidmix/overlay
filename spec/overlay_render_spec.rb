require File.dirname(__FILE__) + '/spec_helper'

describe ActionView::Base do
  describe :alias_method_chain do
    it 'defines chained methods' do
      ActionView::Base.instance_methods.should be_member('render')
      ActionView::Base.instance_methods.should be_member('render_with_missing_default')
      ActionView::Base.instance_methods.should be_member('render_without_missing_default')
    end
  end

  describe :render_with_missing_template do
    before do
      @view = ActionView::Base.new
    end

    describe 'with missing template' do
      before do
        @view.stub!(:render_without_missing_default).and_raise ActionView::MissingTemplate.new(ActionView::PathSet.new, 'foo')
        Thread.current[:missing_default] = true
      end

      describe 'with default' do
        it 'calls render_without_missing_template without default' do
          @view.should_receive(:render_without_missing_default).with({:partial => 'foo'}, {})
          @view.render(:partial => 'foo', :default => 'bar')
        end

        it 'removes missing_default' do
          @view.render(:partial => 'foo', :default => 'bar')
          Thread.current[:missing_default].should be_nil
        end

        it 'returns default' do
          @view.render(:partial => 'foo', :default => 'bar').should == 'bar'
        end

        it 'returns default as nil' do
          @view.render(:partial => 'foo', :default => nil).should be_nil
        end
      end

      describe 'without default' do
        it 'raises error and removes missing_default' do
          lambda { @view.render(:partial => 'foo') }.should raise_error(ActionView::MissingTemplate)
          Thread.current[:missing_default].should be_nil
        end
      end

      after do
        Thread.current[:missing_default] = nil
      end
    end

    describe 'without missing template' do
      it 'raises other errors' do
        @view.stub!(:render_without_missing_default).and_raise RuntimeError.new('suck')
        lambda { @view.render(:partial => 'foo', :defauilt => nil) }.should raise_error(RuntimeError, 'suck')
      end
    end
  end
end
