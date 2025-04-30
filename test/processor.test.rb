# frozen_string_literal: true

test "basic" do
	processed = StrictIvars::Processor.call(<<~RUBY)
		def foo
			@foo
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo
			#{guarded(:@foo)}
		end
	RUBY
end

test "conditional" do
	processed = StrictIvars::Processor.call(<<~RUBY)
		def foo
			bar if @foo
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo
			bar if #{guarded(:@foo)}
		end
	RUBY
end

test "multiple reads" do
	processed = StrictIvars::Processor.call(<<~RUBY)
		def foo
			@foo
			@foo
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo
			#{guarded(:@foo)}
			@foo
		end
	RUBY
end

test "if conditional" do
	processed = StrictIvars::Processor.call(<<~RUBY)
		def foo
			@a

			if @b
				@a
				@b
				@c
			else
				@a
				@b
				@c
			end

			@a
			@b
			@c
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo
			#{guarded(:@a)}

			if #{guarded(:@b)}
				@a
				@b
				#{guarded(:@c)}
			else
				@a
				@b
				#{guarded(:@c)}
			end

			@a
			@b
			#{guarded(:@c)}
		end
	RUBY
end

test "case" do
	processed = StrictIvars::Processor.call(<<~RUBY)
		@a

		case @b
		when @c
			@a
			@b
			@c
			@d
		else
			@a
			@b
			@c
			@d
		end

		@a
		@b
		@c
		@d
	RUBY

	assert_equal_ruby processed, <<~RUBY
		#{guarded(:@a)}

		case #{guarded(:@b)}
		when #{guarded(:@c)}
			@a
			@b
			@c
			#{guarded(:@d)}
		else
			@a
			@b
			#{guarded(:@c)}
			#{guarded(:@d)}
		end

		@a
		@b
		#{guarded(:@c)}
		#{guarded(:@d)}
	RUBY
end

test "open method definition def" do
	processed = StrictIvars::Processor.call(<<~RUBY)
		def foo
			@a
			@a
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo
			#{guarded(:@a)}
			@a
	RUBY
end

test "class isolation" do
	processed = StrictIvars::Processor.call(<<~RUBY)
		@a
		@a

		class Foo
			@a
			@a
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		#{guarded(:@a)}
		@a

		class Foo
			#{guarded(:@a)}
			@a
		end
	RUBY
end

test "module isolation" do
	processed = StrictIvars::Processor.call(<<~RUBY)
		@a
		@a

		module Foo
			@a
			@a
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		#{guarded(:@a)}
		@a

		module Foo
			#{guarded(:@a)}
			@a
		end
	RUBY
end

test "block isolation" do
	processed = StrictIvars::Processor.call(<<~RUBY)
		@a
		@a

		anything do
			@a
			@a
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		#{guarded(:@a)}
		@a

		anything do
			#{guarded(:@a)}
			@a
		end
	RUBY
end

test "singleton class isolation" do
	processed = StrictIvars::Processor.call(<<~RUBY)
		@a
		@a

		class << self
			@a
			@a
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		#{guarded(:@a)}
		@a

		class << self
			#{guarded(:@a)}
			@a
		end
	RUBY
end

test "manual defined? guard" do
	processed = StrictIvars::Processor.call(<<~RUBY)
		def foo
			if defined?(@foo)
				@foo
			else
				@foo = 1
			end
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo
			if defined?(@foo)
				@foo
			else
				@foo = 1
			end
		end
	RUBY
end

def guarded(name)
	"(defined?(#{name.name}) ? #{name.name} : (::Kernel.raise(::StrictIvars::NameError.new('Undefined instance variable #{name.name}'))))"
end
