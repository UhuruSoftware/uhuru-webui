require 'digest/sha2'
require 'encryptor'

# Encryption class used for password text
#
class Encryption
  # Encrypts a text with given key
  # text = text to be encrypted
  # key = encryption key
  #
  def self.encrypt_text(password, key)
    secret_key = Digest::SHA256::hexdigest(key)
    Encryptor::encrypt(password, :key => secret_key)
  rescue
    nil
  end

  # Decrypts a text with given key
  # text = text to be encrypted
  # key = encryption key
  #
  def self.decrypt_text(password, key)
    secret_key = Digest::SHA256::hexdigest(key)
    Encryptor::decrypt(password, :key => secret_key)
  rescue
    nil
  end
end