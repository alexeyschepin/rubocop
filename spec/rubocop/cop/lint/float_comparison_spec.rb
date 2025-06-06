# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FloatComparison, :config do
  it 'registers an offense when comparing with float' do
    expect_offense(<<~RUBY)
      x == 0.1
      ^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
      0.1 == x
      ^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
      x != 0.1
      ^^^^^^^^ Avoid inequality comparisons of floats as they are unreliable.
      0.1 != x
      ^^^^^^^^ Avoid inequality comparisons of floats as they are unreliable.
      x.eql?(0.1)
      ^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
      0.1.eql?(x)
      ^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'registers an offense when comparing with float returning method' do
    expect_offense(<<~RUBY)
      x == Float(1)
      ^^^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
      x == '0.1'.to_f
      ^^^^^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
      x == 1.fdiv(2)
      ^^^^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'registers an offense when comparing with arithmetic operator on floats' do
    expect_offense(<<~RUBY)
      x == 0.1 + y
      ^^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
      x == y + Float('0.1')
      ^^^^^^^^^^^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
      x == y + z * (foo(arg) + '0.1'.to_f)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'registers an offense when comparing with method on float receiver' do
    expect_offense(<<~RUBY)
      x == 0.1.abs
      ^^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'does not register an offense when comparing with float method ' \
     'that can return numeric and returns integer' do
    expect_no_offenses(<<~RUBY)
      x == 1.1.ceil
    RUBY
  end

  it 'registers an offense when comparing with float method ' \
     'that can return numeric and returns float' do
    expect_offense(<<~RUBY)
      x == 1.1.ceil(1)
      ^^^^^^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'does not register an offense when comparing with float using epsilon' do
    expect_no_offenses(<<~RUBY)
      (x - 0.1) < epsilon
    RUBY
  end

  it 'does not register an offense when comparing with rational literal' do
    expect_no_offenses(<<~RUBY)
      value == 0.2r
    RUBY
  end

  it 'does not register an offense when comparing against zero' do
    expect_no_offenses(<<~RUBY)
      x == 0.0
      x.to_f == 0
      x.to_f.abs == 0.0
      x != 0.0
      x.to_f != 0
      x.to_f.zero?
      x.to_f.nonzero?
    RUBY
  end

  it 'does not register an offense when comparing against nil' do
    expect_no_offenses(<<~RUBY)
      Float('not_a_float', exception: false) == nil
      nil != Float('not_a_float', exception: false)
    RUBY
  end

  it 'does not register an offense when comparing with multiple arguments' do
    expect_no_offenses(<<~RUBY)
      x.==(0.1, 0.2)
      x.!=(0.1, 0.2)
      x.eql?(0.1, 0.2)
      x.equal?(0.1, 0.2)
    RUBY
  end

  it 'registers an offense for `eql?` called with safe navigation' do
    expect_offense(<<~RUBY)
      x&.eql?(0.1)
      ^^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'registers an offense for `equal?` called with safe navigation' do
    expect_offense(<<~RUBY)
      x&.equal?(0.1)
      ^^^^^^^^^^^^^^ Avoid equality comparisons of floats as they are unreliable.
    RUBY
  end

  it 'registers an offense when using float in case statement' do
    expect_offense(<<~RUBY)
      case value
      when 1.0
           ^^^ Avoid float literal comparisons in case statements as they are unreliable.
        foo
      when 2.0
           ^^^ Avoid float literal comparisons in case statements as they are unreliable.
        bar
      end
    RUBY
  end

  it 'registers an offense when using float in case statement with multiple conditions' do
    expect_offense(<<~RUBY)
      case value
      when 1.0, 2.0
                ^^^ Avoid float literal comparisons in case statements as they are unreliable.
           ^^^ Avoid float literal comparisons in case statements as they are unreliable.
        foo
      end
    RUBY
  end

  it 'does not register an offense when using zero float in case statement' do
    expect_no_offenses(<<~RUBY)
      case value
      when 0.0
        foo
      end
    RUBY
  end

  it 'does not register an offense when using non-float in case statement' do
    expect_no_offenses(<<~RUBY)
      case value
      when 1
        foo
      when 'string'
        bar
      end
    RUBY
  end
end
