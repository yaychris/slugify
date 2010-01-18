require "rubygems"
require "active_record"
require "contest"
require "slugify"
require "models"

# set the KCODE so active support's multibyte strings work
$KCODE = "UTF8"


class TestSlugify < Test::Unit::TestCase
  setup do
    @page = Page.new :title => "Yay Hooray"
    @user = User.new :name => "Fox Mulder"
    @file = Upload.new :file_name => "hello.jpg"
  end

  should "have #slugify class method" do
    assert Page.respond_to?(:slugify)
  end

  context "calling #slugify" do
    context "with no arguments" do
      should "define instance method" do
        assert Page.new.respond_to?(:slugify)
        assert Page.new.respond_to?(:slugify!)
      end
    end

    context "with from field set" do
      should "define instance method" do
        assert User.new.respond_to?(:slugify)
        assert User.new.respond_to?(:slugify!)
      end
    end

    context "with :to option set" do
      should "define instance method" do
        assert Upload.new.respond_to?(:slugify)
        assert Upload.new.respond_to?(:slugify!)
      end
    end

    context "with missing columns" do
      should "raise an exception" do
        assert_raises(Slugify::MissingColumnError) do
          Failure.slugify :blech, :to => :valid_to
        end

        assert_raises(Slugify::MissingColumnError) do
          Failure.slugify :valid_from, :to => :blaugh
        end
      end
    end
  end

  context "calling #slugify instance method" do
    context "with nil from field" do
      setup do
        @page = Page.new
      end

      should "set slug to nil" do
        assert_nothing_raised { @page.slugify }
        assert_nil @page.slug
      end
    end

    context "with from field set" do
      should "set the slug" do
        assert_nothing_raised { @page.slugify }
        assert_equal "yay-hooray", @page.slug

        assert_nothing_raised { @user.slugify }
        assert_equal "fox-mulder", @user.slug

        assert_nothing_raised { @file.slugify }
        assert_equal "hello-jpg", @file.short_name
      end

      should "not overwrite an existing slug" do
        @page.slug = "page"
        @user.slug = "user"
        @file.short_name = "file"

        assert_nothing_raised { @page.slugify }
        assert_equal "page", @page.slug

        assert_nothing_raised { @user.slugify }
        assert_equal "user", @user.slug

        assert_nothing_raised { @file.slugify }
        assert_equal "file", @file.short_name
      end

      context "with true argument" do
        should "force a reload" do
          @page.slug = "page"
          @user.slug = "user"
          @file.short_name = "file"

          assert_nothing_raised { @page.slugify(true) }
          assert_equal "yay-hooray", @page.slug

          assert_nothing_raised { @user.slugify(true) }
          assert_equal "fox-mulder", @user.slug

          assert_nothing_raised { @file.slugify(true) }
          assert_equal "hello-jpg", @file.short_name
        end
      end
    end
  end

  context "calling #slugify! (bang) instance method" do
    should "force a reload" do
      @page.slug = "page"
      @user.slug = "user"
      @file.short_name = "file"

      assert_nothing_raised { @page.slugify(true) }
      assert_equal "yay-hooray", @page.slug

      assert_nothing_raised { @user.slugify(true) }
      assert_equal "fox-mulder", @user.slug

      assert_nothing_raised { @file.slugify(true) }
      assert_equal "hello-jpg", @file.short_name
    end
  end

  context "when validating" do
    setup do
      Page.create :title => "Yay", :slug => "yay"
      @page = Page.new
    end

    should "validate presence of slug" do
      assert !@page.valid?
      assert @page.errors.on(:slug)
    end

    should "validate uniqueness of slug" do
      @page.title = "Yay"

      assert !@page.valid?
      assert_match /taken/, @page.errors.on(:slug)
    end

    should "validate format of slug" do
      @page.slug = "yay hooray"

      assert !@page.valid?
      assert_match /invalid/, @page.errors.on(:slug)
    end
  end
end
