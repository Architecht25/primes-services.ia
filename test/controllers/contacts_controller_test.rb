require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_contact_url
    assert_response :success
  end

  test "creates a contact submission and sends admin notification" do
    assert_difference("ContactSubmission.count", 1) do
      assert_enqueued_emails 1 do
        post contacts_url, params: {
          contact_submission: {
            name: "Jean Dupont",
            email: "jean@example.com",
            phone: "0470123456",
            region: "wallonie",
            message: "Je souhaite une analyse de ma situation."
          }
        }
      end
    end

    assert_redirected_to contact_url(ContactSubmission.last)
  end

  test "honeypot silently discards the submission" do
    assert_no_difference("ContactSubmission.count") do
      post contacts_url, params: {
        contact_submission: { name: "Bot", email: "bot@example.com", region: "wallonie" },
        website: "http://spam.example.com"
      }
    end

    assert_redirected_to new_contact_url
  end

  test "invalid submission re-renders the form" do
    assert_no_difference("ContactSubmission.count") do
      post contacts_url, params: { contact_submission: { name: "", email: "", region: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "show is only accessible to the submitter" do
    post contacts_url, params: {
      contact_submission: {
        name: "Marie Curie", email: "marie@example.com", region: "bruxelles", message: "Test"
      }
    }
    contact = ContactSubmission.last

    get contact_url(contact)
    assert_response :success

    # Une autre session (autre visiteur) ne doit pas pouvoir accéder à la page de confirmation
    open_session do |other|
      other.get contact_url(contact)
      other.assert_redirected_to root_url
    end
  end
end
