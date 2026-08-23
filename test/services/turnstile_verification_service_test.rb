require "test_helper"

class TurnstileVerificationServiceTest < ActiveSupport::TestCase
  test "passes (fail-open) when no secret key is configured" do
    with_secret_key(nil) do
      assert TurnstileVerificationService.verify("whatever", remote_ip: "1.2.3.4")
    end
  end

  test "rejects a blank token when a secret key is configured" do
    with_secret_key("test_secret") do
      assert_not TurnstileVerificationService.verify(nil, remote_ip: "1.2.3.4")
      assert_not TurnstileVerificationService.verify("", remote_ip: "1.2.3.4")
    end
  end

  test "accepts a token Cloudflare confirms as valid" do
    with_secret_key("test_secret") do
      with_stubbed_post(->(*) { Struct.new(:parsed_response).new({ "success" => true }) }) do
        assert TurnstileVerificationService.verify("valid-token", remote_ip: "1.2.3.4")
      end
    end
  end

  test "rejects a token Cloudflare confirms as invalid" do
    with_secret_key("test_secret") do
      with_stubbed_post(->(*) { Struct.new(:parsed_response).new({ "success" => false }) }) do
        assert_not TurnstileVerificationService.verify("invalid-token", remote_ip: "1.2.3.4")
      end
    end
  end

  test "fails open if the Cloudflare API call errors out" do
    with_secret_key("test_secret") do
      with_stubbed_post(->(*) { raise Net::ReadTimeout }) do
        assert TurnstileVerificationService.verify("some-token", remote_ip: "1.2.3.4")
      end
    end
  end

  private

  def with_secret_key(value)
    original = ENV["TURNSTILE_SECRET_KEY"]
    ENV["TURNSTILE_SECRET_KEY"] = value
    yield
  ensure
    ENV["TURNSTILE_SECRET_KEY"] = original
  end

  # Remplace temporairement HTTParty.post (pas d'appel réseau en test).
  def with_stubbed_post(implementation)
    original_post = HTTParty.method(:post)
    HTTParty.define_singleton_method(:post, &implementation)
    yield
  ensure
    HTTParty.define_singleton_method(:post, original_post)
  end
end
