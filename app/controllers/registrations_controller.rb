class RegistrationsController < Devise::RegistrationsController

  def create
    if user = try_to_sign_in(params[:user])
      sign_in(user)
      redirect_to root_url, notice: 'You have already signed up, so we just let you in'
    else
      super
    end
  end

  protected

  def try_to_sign_in(data)
    data ||= {}
    email, pwd = data[:email], data[:password]
    existing = User.find_by_email(email)
    return false unless existing and existing.valid_password?(pwd)
    existing
  end

end


