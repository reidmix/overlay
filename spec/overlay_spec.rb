require File.dirname(__FILE__) + '/spec_helper'

describe Overlay do
  before do
    Thread.current[:overlay] = nil
  end

  describe :constants do
    it 'defines default pattern' do
      Overlay.should be_const_defined('DEFAULT_PATTERN')
      Overlay::DEFAULT_PATTERN.should == ':view'
    end

    it 'defines default separator' do
      Overlay.should be_const_defined('DEFAULT_SEPARATOR')
      Overlay::DEFAULT_SEPARATOR.should == '-'
    end
  end

  describe 'class methods' do
    before do
      if Object.const_defined?('Overlay')
        Object.send(:remove_const, :Overlay)
        load 'overlay.rb'
      end
    end

    describe :pattern do
      it 'has a default' do
        Overlay.pattern.should == Overlay::DEFAULT_PATTERN
      end

      it 'is set' do
        Overlay.pattern = ':cobrand-:product'
        Overlay.pattern.should == ':cobrand-:product'
      end
    end

    describe :separator do
      it 'has a default' do
        Overlay.separator.should == Overlay::DEFAULT_SEPARATOR
      end

      it 'is set' do
        Overlay.separator = '_'
        Overlay.separator.should == '_'
      end
    end

    describe :current do
      it 'is nil if Thread.current[:overlay] is not set' do
        Overlay.current.should be_nil
      end

      it 'is Thread.current[:overlay]' do
        Thread.current[:overlay] = 'test'
        Overlay.current.should == 'test'
      end
    end

    describe :current= do
      it 'sets Thead.current[:overlay] with interpolation of :view' do
        Overlay.should_receive(:interpolate).with(:view => 'foo').and_return 'bar'
        Overlay.current = 'foo'
        Thread.current[:overlay].should == 'bar'
      end

      it 'sets Thead.current[:overlay] with interpolation of custom hash' do
        Overlay.should_receive(:interpolate).with(:cobrand => 'foo', :product => 'bar').and_return 'baz'
        Overlay.current = {:cobrand => 'foo', :product => 'bar'}
        Thread.current[:overlay].should == 'baz'
      end
    end

    describe :set_view do
      it 'sets Thead.current[:overlay] with interpolation of :view' do
        Overlay.should_receive(:interpolate).with(:view => 'foo').and_return 'bar'
        Overlay.set_view 'foo'
        Thread.current[:overlay].should == 'bar'
      end

      it 'sets Thead.current[:overlay] with interpolation of custom hash' do
        Overlay.should_receive(:interpolate).with(:cobrand => 'foo', :product => 'bar').and_return 'baz'
        Overlay.set_view :cobrand => 'foo', :product => 'bar'
        Thread.current[:overlay].should == 'baz'
      end
    end

    describe :interpolate do
      before do
        class << Overlay
          public :interpolate
        end
      end

      describe 'with default pattern' do
        it 'is replaced with value' do
          Overlay.interpolate(:view => 'foo').should == 'foo'
        end

        it 'returns empty string with nil value' do
          Overlay.interpolate(:view => nil).should == ''
        end

        it 'returns pattern with no matched value' do
          Overlay.interpolate(:foo => 'bar').should == ':view'
        end
      end

      describe 'with custom pattern' do
        before do
          Overlay.pattern = ':cobrand-:type-:product'
        end

        it 'replaces all values' do
          Overlay.interpolate(:cobrand => 'emusic',  :type => 'free', :product => 'mp3').should == 'emusic-free-mp3'
        end

        it 'returns only two replaced when one is nil' do
          Overlay.interpolate(:cobrand  => nil,      :type => 'free', :product => 'mp3').should == 'free-mp3'
          Overlay.interpolate(:cobrand  => 'emusic', :type => nil,    :product => 'mp3').should == 'emusic-mp3'
          Overlay.interpolate(:cobrand  => 'emusic', :type => 'free', :product => nil).should   == 'emusic-free'
        end

        it 'returns only one replace when two are nil' do
          Overlay.interpolate(:cobrand  => 'emusic', :type => nil,    :product => nil).should   == 'emusic'
          Overlay.interpolate(:cobrand  => nil,      :type => 'free', :product => nil).should   == 'free'
          Overlay.interpolate(:cobrand  => nil,      :type => nil,    :product => 'mp3').should == 'mp3'
        end

        it 'returns empty string when all nil values' do
          Overlay.interpolate(:cobrand  => nil, :type => nil, :product => nil).should == ''
        end

        it 'returns pattern with no matched value' do
          Overlay.interpolate(:foo => 'bar').should == ':cobrand-:type-:product'
        end
      end

      describe 'with custom separator' do
        before do
          Overlay.pattern   = ':cobrand_:type_:product'
          Overlay.separator = '_'
        end

        it 'replaces all values' do
          Overlay.interpolate(:cobrand => 'emusic',  :type => 'free', :product => 'mp3').should == 'emusic_free_mp3'
        end

        it 'returns only two replaced when one is nil' do
          Overlay.interpolate(:cobrand  => nil,      :type => 'free', :product => 'mp3').should == 'free_mp3'
          Overlay.interpolate(:cobrand  => 'emusic', :type => nil,    :product => 'mp3').should == 'emusic_mp3'
          Overlay.interpolate(:cobrand  => 'emusic', :type => 'free', :product => nil).should   == 'emusic_free'
        end

        it 'returns only one replace when two are nil' do
          Overlay.interpolate(:cobrand  => 'emusic', :type => nil,    :product => nil).should   == 'emusic'
          Overlay.interpolate(:cobrand  => nil,      :type => 'free', :product => nil).should   == 'free'
          Overlay.interpolate(:cobrand  => nil,      :type => nil,    :product => 'mp3').should == 'mp3'
        end

        it 'returns empty string when all nil values' do
          Overlay.interpolate(:cobrand  => nil, :type => nil, :product => nil).should == ''
        end

        it 'returns pattern with no matched value' do
          Overlay.interpolate(:foo => 'bar').should == ':cobrand_:type_:product'
        end
      end
    end
  end
end
