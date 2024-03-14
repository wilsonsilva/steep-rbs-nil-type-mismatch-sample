class Event
  attr_reader :pubkey
  attr_accessor :id, :sig

  def initialize(pubkey:, id: nil, sig: nil)
    @pubkey = pubkey
    @id = id
    @sig = sig
  end

  def verify_signature
    return false if id.nil? || pubkey.nil? || sig.nil? # <--- Ignored by Steep

    valid_sig?(id, pubkey, sig)
  end

  def valid_sig?(message, public_key, signature)
    true
  end
end
