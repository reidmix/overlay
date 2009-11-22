require File.dirname(__FILE__) + '/spec_helper'

describe Overlay do
  describe :alias_method_chain do
    it 'defines chained methods' do
      ActionView::PathSet.instance_methods.should be_member('find_template')
      ActionView::PathSet.instance_methods.should be_member('find_template_with_overlay')
      ActionView::PathSet.instance_methods.should be_member('find_template_without_overlay')
    end
  end

  describe :find_template_with_overlay do
    before do
      @paths = ActionView::PathSet.new([@path = mock('Path', :[] => nil)])
    end

    describe 'with no overlay match' do
      it 'calls find_template_without_overlay' do
        @paths.should_receive(:find_template_without_overlay).with('foo', nil, true).and_return :template
        @paths.find_template('foo').should == :template
      end

      it 'passes find_template_without_overlay' do
        @paths.should_receive(:find_template_without_overlay).with('foo', 'html', false).and_return :template
        @paths.find_template('foo', 'html', false).should == :template
      end

      it 'returns template if it response to render' do
        template = mock('template', :render => true)
        @paths.find_template(template).should == template
      end
    end

    describe 'with overlay and locale match' do
      before do
        Overlay.stub!(:current).and_return 'emusic'
        @path.stub!(:[]).with('foo_emusic.en').and_return :en_template
      end

      it 'returns template' do
        @paths.find_template('foo').should == :en_template
      end

      it 'returns template when matched with leading slash' do
        @paths.find_template('/foo').should == :en_template
      end
    end

    describe 'with overlay and format match' do
      before do
        Overlay.stub!(:current).and_return 'emusic'
        @path.stub!(:[]).with('foo_emusic.html').and_return :html_template
      end

      it 'returns template' do
        @paths.find_template('foo', 'html').should == :html_template
      end

      it 'returns template when matched with leading slash' do
        @paths.find_template('/foo', 'html').should == :html_template
      end
    end

    describe 'with overlay, locale and format match' do
      before do
        Overlay.stub!(:current).and_return 'emusic'
        @path.stub!(:[]).with('foo_emusic.en.html').and_return :en_html_template
      end

      it 'returns template' do
        @paths.find_template('foo', 'html').should == :en_html_template
      end

      it 'returns template when matched with leading slash' do
        @paths.find_template('/foo', 'html').should == :en_html_template
      end
    end
  end
end