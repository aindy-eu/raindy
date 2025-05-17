# frozen_string_literal: true

class ChatsController < ApplicationController
  # If we want to use the dom_id and dom_class helpers, we can uncomment this line.
  # include ActionView::RecordIdentifier

  before_action :set_chat, only: %i[ show edit update destroy drawer_list_item ]

  # GET /chats
  def index
    @chats = current_user.chats
  end

  # GET /chats/1
  def show
  end

  # GET /chats/new
  def new
    @chat = current_user.chats.new
  end

  # GET /chats/1/edit
  def edit
  end

  # POST /chats
  def create
    @chat = current_user.chats.new(chat_params)

    respond_to do |format|
      if @chat.save
        @first_chat = current_user.chats.count == 1
        format.turbo_stream
        format.html { redirect_to chats_path, notice: t("helpers.created", model: Chat.model_name.human) }
      else
        flash.now[:alert] = t("helpers.created_failed", model: Chat.model_name.human)
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chats/1
  def update
    respond_to do |format|
      if @chat.update(chat_params)
        flash.now[:success] = t("helpers.updated", model: Chat.model_name.human)
        format.turbo_stream
        format.html { redirect_to @chat, notice: t("helpers.updated", model: Chat.model_name.human) }
      else
        flash.now[:alert] = t("helpers.update_failed", model: Chat.model_name.human)
        format.turbo_stream { render :update_error, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chats/1
  # Attempts to destroy the chat using `destroy` (non-bang version).
  # - Returns `true` if deletion succeeds
  # - Returns `false` if deletion is blocked (e.g. callbacks or associations)
  # - Does NOT raise an exception
  # Use this version when you want to handle failure gracefully
  def destroy
    if @chat.destroy
      flash.now[:success] = t("helpers.deleted", model: Chat.model_name.human)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chats_path, status: :see_other, notice: t("helpers.deleted", model: Chat.model_name.human) }
      end
    else
      flash.now[:alert] = t("helpers.delete_failed", model: Chat.model_name.human)
      respond_to do |format|
        format.turbo_stream { render :destroy_error, status: :unprocessable_entity }
        format.html { redirect_to chats_path, alert: t("helpers.delete_failed", model: Chat.model_name.human) }
      end
    end
  end

  # Alternate version using `destroy!` (bang method). Hint: There is no route for this action.
  # - Raises `ActiveRecord::RecordNotDestroyed` on failure
  # - Use this version if you prefer fail-fast logic or want to rescue errors explicitly
  # - Useful in service objects or when wrapping in a transaction
  def destroy_with_exception_handling
    # Destroy! - will raise if destruction fails
    @chat.destroy!
    flash.now[:success] = t("helpers.deleted", model: Chat.model_name.human)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to chats_path, status: :see_other, notice: t("helpers.deleted", model: Chat.model_name.human) }
    end
  rescue ActiveRecord::RecordNotDestroyed => e
    Rails.logger.warn("Chat deletion failed: #{e.message}")
    flash.now[:alert] = t("helpers.delete_failed", model: Chat.model_name.human)
    respond_to do |format|
      format.turbo_stream { render :destroy_error, status: :unprocessable_entity }
      format.html { redirect_to chats_path, alert: t("helpers.delete_failed", model: Chat.model_name.human) }
    end
  end

  # Today I discovered that Rails will automatically render `views/chats/drawer_list_item.html.erb`
  # as long as the route exists, the view file is present, and `@chat` is set.
  # We define this method explicitly for clarity, documentation, and to enable testing or future logic.
  def drawer_list_item
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      @chat = current_user.chats.find_by(id: params.expect(:id))
      unless @chat
        redirect_to chats_path, alert: t("authorization.denied")
        # Stop execution to prevent rendering after redirect (intentional)
        return # rubocop:disable Style/RedundantReturn
      end
    end

    # Only allow a list of trusted parameters through.
    # https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-expect
    # https://www.youtube.com/watch?v=9esE-s_BiAw
    def chat_params
      params.expect(chat: [ :name ])
    end
end
