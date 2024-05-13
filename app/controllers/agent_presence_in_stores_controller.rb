class AgentPresenceInStoresController < ApplicationController
  before_action :set_agent_presence_in_store, only: %i[ show edit update destroy ]

  # GET /agent_presence_in_stores or /agent_presence_in_stores.json
  def index
    @q = AgentPresenceInStore.ransack(params[:q])
    @agent_presence_in_stores =
      @q.result
        .includes(:user, :buyer)
        .order(created_at: :desc)
        .page(params[:page])
        .per(40)
  end

  # GET /agent_presence_in_stores/1 or /agent_presence_in_stores/1.json
  def show
  end

  # GET /agent_presence_in_stores/new
  def new
    @agent_presence_in_store = AgentPresenceInStore.new(
      buyer_id: params[:buyer_id], user_id: current_user.id
    )
  end

  # GET /agent_presence_in_stores/1/edit
  def edit
  end

  # POST /agent_presence_in_stores or /agent_presence_in_stores.json
  def create
    @agent_presence_in_store = AgentPresenceInStore.new(agent_presence_in_store_params)

    respond_to do |format|
      if @agent_presence_in_store.save
        format.html { redirect_to root_url, notice: "Agent presence in store was successfully created." }
        format.json { render :show, status: :created, location: @agent_presence_in_store }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @agent_presence_in_store.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agent_presence_in_stores/1 or /agent_presence_in_stores/1.json
  def update
    respond_to do |format|
      if @agent_presence_in_store.update(agent_presence_in_store_params)
        format.html { redirect_to agent_presence_in_store_url(@agent_presence_in_store), notice: "Agent presence in store was successfully updated." }
        format.json { render :show, status: :ok, location: @agent_presence_in_store }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @agent_presence_in_store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agent_presence_in_stores/1 or /agent_presence_in_stores/1.json
  def destroy
    @agent_presence_in_store.destroy

    respond_to do |format|
      format.html { redirect_to agent_presence_in_stores_url, notice: "Agent presence in store was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agent_presence_in_store
      @agent_presence_in_store = AgentPresenceInStore.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def agent_presence_in_store_params
      params.require(:agent_presence_in_store).permit(:user_id, :buyer_id, :latitude, :longitude, :status, :distance_in_meters)
    end
end
