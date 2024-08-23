class ContactsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
    def new
      @contact = Contact.new
    end
    
    def create
    @contact = Contact.new(contact_params)
    if @contact.save
      ContactMailer.contact_mail(@contact, current_user).deliver
      redirect_to root_path, notice: 'お問い合わせ内容を送信しました'
    else
      render :new
    end
  end
    
  private
    def contact_params
      # Only allow a list of trusted parameters through.
      params.require(:contact).permit(:name, :content)
    end
end
