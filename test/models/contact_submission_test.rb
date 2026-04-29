require "test_helper"

class ContactSubmissionTest < ActiveSupport::TestCase
  # --- Validations ---

  test "valid particulier contact" do
    contact = ParticulierContact.new(
      name: "Jean Dupont", email: "jean@example.com",
      region: "wallonie", status: "pending"
    )
    assert contact.valid?
  end

  test "invalid without name" do
    contact = ParticulierContact.new(email: "jean@example.com", region: "wallonie", status: "pending")
    assert_not contact.valid?
    assert_includes contact.errors[:name], "can't be blank"
  end

  test "invalid with malformed email" do
    contact = ParticulierContact.new(name: "Test", email: "not-an-email", region: "wallonie", status: "pending")
    assert_not contact.valid?
    assert contact.errors[:email].any?
  end

  test "invalid with unknown region" do
    contact = ParticulierContact.new(name: "Test", email: "t@t.com", region: "luxembourg", status: "pending")
    assert_not contact.valid?
    assert contact.errors[:region].any?
  end

  test "invalid with message over 2000 chars" do
    contact = ParticulierContact.new(
      name: "Test", email: "t@t.com", region: "wallonie",
      status: "pending", message: "x" * 2001
    )
    assert_not contact.valid?
    assert contact.errors[:message].any?
  end

  test "message of exactly 2000 chars is valid" do
    contact = ParticulierContact.new(
      name: "Test", email: "t@t.com", region: "wallonie",
      status: "pending", message: "x" * 2000
    )
    assert contact.valid?
  end

  # --- Callbacks ---

  test "email is downcased before validation" do
    contact = ParticulierContact.new(
      name: "Test", email: "TEST@EXAMPLE.COM", region: "wallonie", status: "pending"
    )
    contact.valid?
    assert_equal "test@example.com", contact.email
  end

  test "status defaults to pending on create" do
    contact = ParticulierContact.new(name: "Test", email: "t@t.com", region: "wallonie")
    contact.valid?
    assert_equal "pending", contact.status
  end

  test "submitted_at is set on create" do
    contact = ParticulierContact.new(name: "Test", email: "t@t.com", region: "wallonie")
    contact.valid?
    assert_not_nil contact.submitted_at
  end

  # --- Scopes ---

  test "pending scope returns only pending contacts" do
    pending = contact_submissions(:particulier_pending)
    assert_equal "pending", pending.status
    assert_includes ContactSubmission.pending, pending
  end

  # --- Instance methods ---

  test "pending? returns true for pending status" do
    assert contact_submissions(:particulier_pending).pending?
  end

  test "processed? returns true for processed status" do
    assert contact_submissions(:acp_processed).processed?
  end

  test "mark_as_read! sets read_at" do
    contact = contact_submissions(:particulier_pending)
    assert_nil contact.read_at
    contact.mark_as_read!
    assert_not_nil contact.reload.read_at
  end
end
