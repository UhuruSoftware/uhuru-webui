require 'digest/sha2'
require 'encryptor'

class Encryption
  def self.encrypt_text(text, key1)
    secret_key1 = Digest::SHA256::hexdigest(key1)
    Encryptor::encrypt(text, :key => secret_key1)
  rescue
    nil
  end

  def self.decrypt_text(text, key1)
    secret_key1 = Digest::SHA256::hexdigest(key1)
    Encryptor::decrypt(text, :key => secret_key1)
  rescue
    nil
  end
end