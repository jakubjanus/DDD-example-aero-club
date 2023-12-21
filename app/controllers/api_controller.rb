# frozen_string_literal: true

class ApiController < ActionController::API
  rescue_from StandardError, with: :handle_error

  def handle_error(error)
    result = { error_type: error.class, error_message: error.message, stack_trace: error.backtrace }
    result[:stack_trace] = error.backtrace if Rails.env.development?

    render json: result, status: 500
  end
end
