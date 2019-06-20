class Api::V1::BaseController < ApplicationController

  def index
    render json: { message: OK }, status: :ok
  end

  def success_response(response_payload, status_code = :ok)
    render json: response_payload, status: status_code
  end

  def error_response(message, errors, status_code)
    render json: { message: message, errors: errors }, status: status_code
  end
  
end
