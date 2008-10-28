class Admin::PhotoParticipantsController < ApplicationController

  before_filter(:get_photo)

  # GET /photo_participants
  # GET /photo_participants.xml
  def index
    @photo_participants = @photo.photo_participants.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photo_participants }
    end
  end

  # GET /photo_participants/1
  # GET /photo_participants/1.xml
  def show
    @photo_participant = @photo.photo_participants.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photo_participant }
    end
  end

  # GET /photo_participants/new
  # GET /photo_participants/new.xml
  def new
    @photo_participant = @photo.photo_participants.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo_participant }
    end
  end

  # GET /photo_participants/1/edit
  def edit
    @photo_participant = @photo.photo_participants.find(params[:id])
  end

  # POST /photo_participants
  # POST /photo_participants.xml
  def create
    @photo_participant = @photo.photo_participants.build(params[:photo_participant])

    respond_to do |format|
      if @photo_participant.save
        flash[:notice] = 'PhotoParticipant was successfully created.'
        format.html { redirect_to admin_site_photo_participants_path(@photo) }
        format.xml  { render :xml => @photo_participant, :status => :created, :location => admin_site_photo_participant(@site, @photo, @photo_participant) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo_participant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photo_participants/1
  # PUT /photo_participants/1.xml
  def update
    @photo_participant = @photo.photo_participants.find(params[:id])

    respond_to do |format|
      if @photo_participant.update_attributes(params[:photo_participant])
        flash[:notice] = 'PhotoParticipant was successfully updated.'
        format.html { redirect_to admin_site_photo_participants_path(@photo) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photo_participant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photo_participants/1
  # DELETE /photo_participants/1.xml
  def destroy
    @photo_participant = PhotoParticipant.find(params[:id])
    @photo_participant.destroy

    respond_to do |format|
      format.html { redirect_to(admin_site_photo_participants_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def get_photo
    @site = Site.find(params[:site_id])
    @photo = @site.photos.find(params[:photo_id])
  end
end
