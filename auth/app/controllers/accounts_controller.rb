class AccountsController < ApplicationController
  before_action :authenticate_account!, only: [:index]

  def index; end
end