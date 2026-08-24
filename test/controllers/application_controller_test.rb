require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "redirects the bare apex domain to the canonical www host" do
    host! "primes-services.be"
    https!
    get "/"

    assert_response :moved_permanently
    assert_equal "https://www.primes-services.be/", response.headers["Location"]
  end

  test "preserves path and query string when redirecting the apex" do
    host! "primes-services.be"
    https!
    get "/pages/about?foo=bar"

    assert_response :moved_permanently
    assert_equal "https://www.primes-services.be/pages/about?foo=bar", response.headers["Location"]
  end

  test "does not redirect requests already on the canonical host" do
    host! "www.primes-services.be"
    get "/"

    assert_response :success
  end
end
