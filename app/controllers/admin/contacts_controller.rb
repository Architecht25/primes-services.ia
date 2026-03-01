# Contrôleur pour gérer les contacts en admin
class Admin::ContactsController < Admin::BaseController
  def index
    @contacts = ContactSubmission
      .order(created_at: :desc)
      .limit(100)

    # Filtres
    @contacts = @contacts.where(submission_type: params[:type]) if params[:type].present?
    @contacts = @contacts.where('created_at >= ?', params[:from]) if params[:from].present?
    @contacts = @contacts.where('created_at <= ?', params[:to]) if params[:to].present?

    # Recherche
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @contacts = @contacts.where(
        'email LIKE ? OR phone LIKE ? OR first_name LIKE ? OR last_name LIKE ?',
        search_term, search_term, search_term, search_term
      )
    end

    # Compter le total avant les filtres
    @contacts_total = @contacts.count

    # Stats pour les filtres
    @stats = {
      total: ContactSubmission.count,
      by_type: ContactSubmission.group(:submission_type).count,
      recent: ContactSubmission.where('created_at >= ?', 24.hours.ago).count
    }
  end

  def show
    @contact = ContactSubmission.find(params[:id])
    @contact.mark_as_read! unless @contact.read?
  end

  def export
    @contacts = ContactSubmission.order(created_at: :desc)

    respond_to do |format|
      format.csv do
        send_data ContactExportService.to_csv(@contacts),
          filename: "contacts_#{Date.today}.csv",
          type: 'text/csv'
      end
      format.json do
        render json: @contacts
      end
    end
  end

  def mark_read
    @contact = ContactSubmission.find(params[:id])
    @contact.update(read_at: Time.current)
    redirect_to admin_contacts_path, notice: 'Contact marqué comme lu'
  end

  def bulk_action
    contact_ids = params[:contact_ids] || []
    action = params[:bulk_action]

    case action
    when 'mark_read'
      ContactSubmission.where(id: contact_ids).update_all(read_at: Time.current)
      flash[:notice] = "#{contact_ids.count} contacts marqués comme lus"
    when 'delete'
      ContactSubmission.where(id: contact_ids).destroy_all
      flash[:notice] = "#{contact_ids.count} contacts supprimés"
    when 'export'
      contacts = ContactSubmission.where(id: contact_ids)
      send_data ContactExportService.to_csv(contacts),
        filename: "contacts_selection_#{Date.today}.csv",
        type: 'text/csv'
      return
    end

    redirect_to admin_contacts_path
  end
end
