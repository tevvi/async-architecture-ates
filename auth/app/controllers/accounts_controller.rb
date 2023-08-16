class AccountsController < ApplicationController
  before_action :authenticate_account!, only: [:index]

  def index; end

  def current
    render :json => current_account
  end

  private

  def current_account
    if doorkeeper_token
      Account.find(doorkeeper_token.resource_owner_id)
    else
      super
    end
  end
end