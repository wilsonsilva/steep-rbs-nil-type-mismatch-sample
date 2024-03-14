# Bug Report on Steep: Ruby::ArgumentTypeMismatch

A sample project to reproduce the issue with Steep in which it ignores 3 `nil` checks on the same expression.

Offending code:

```ruby
class Event
  attr_reader :pubkey
  attr_accessor :id, :sig

  def initialize(pubkey:, id: nil, sig: nil) # <--- Note that id and sig can be nil
    @pubkey = pubkey
    @id = id
    @sig = sig
  end

  def verify_signature
    return false if id.nil? || pubkey.nil? || sig.nil? # <--- Ignored by Steep

    valid_sig?(id, pubkey, sig) # <--- pubkey and sig should not be nil here. The line above ensures that
  end

  def valid_sig?(message, public_key, signature)
    true
  end
end
```

RBS:

```rbs
class Event
  attr_reader pubkey: String
  attr_accessor id: String?  # <--- id can be nil
  attr_accessor sig: String?  # <--- sig can be nil

  def initialize: (pubkey: String, ?id: String?, ?sig: String?) -> void
  def verify_signature: -> bool
  def valid_sig?: (String, String, String) -> bool # <--- none can be nil
end
```

## Expected behavior

No errors should be reported by Steep. The method `valid_sig?` requires non-nullable arguments. And the method `verify_signature` **ensures** that the arguments `id`, `pubkey` and `sig` are not null before calling the method `valid_sig?`.

```
$ bundle exec steep check
# Type checking files:

.....................................................................................

No type error detected. 🫖
```

## Actual behavior

The following error is reported by Steep:

```
$ bundle exec steep check
nostr.rb:24:27: [error] Cannot pass a value of type `(::String | nil)` as an argument of type `::String`
│   (::String | nil) <: ::String
│     nil <: ::String
│
│ Diagnostic ID: Ruby::ArgumentTypeMismatch
│
└     crypto.valid_sig?(id, pubkey, sig)
                                    ~~~

Detected 1 problem from 1 file
```

But only when the 3 nil checks on the same expression. Fewer nil checks do not trigger the error.

## Workaround

Use 2 or fewer nil checks on the same expression.

```ruby
def verify_signature
  return false if id.nil? || pubkey.nil?
  return false if sig.nil?

  valid_sig?(id, pubkey, sig)
end
```

## Steps to reproduce

1. Clone the repository
2. Run `bundle install`
3. Run `bundle exec steep check`

## Environment

- Ruby version: `3.3.0`
- Steep version: `1.6.0`
- RBS version: `3.4.4`
- OS: `macOS Sonoma 14.4 (23E214)`
