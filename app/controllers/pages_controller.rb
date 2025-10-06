class PagesController < ApplicationController
  def home
  end

  def about
  end

  def faq
  end

  def data
  end

  # Pages régionales pour le SEO géographique
  def wallonie
    @region = 'wallonie'
    @region_data = GeoSeoHelper::REGIONS_CONFIG[:wallonie]
    render 'region'
  end

  def flandre
    @region = 'flandre'
    @region_data = GeoSeoHelper::REGIONS_CONFIG[:flandre]
    render 'region'
  end

  def bruxelles
    @region = 'bruxelles'
    @region_data = GeoSeoHelper::REGIONS_CONFIG[:bruxelles]
    render 'region'
  end

  # Pages par ville pour le SEO longue traîne
  def city
    @region = params[:region]
    @city = params[:city]
    @region_data = GeoSeoHelper::REGIONS_CONFIG[@region.to_sym]

    # Rediriger si ville non valide
    unless @region_data && @region_data[:major_cities].map(&:parameterize).include?(@city)
      redirect_to send("region_#{@region}_path"), status: :moved_permanently
      return
    end

    @city_name = @region_data[:major_cities].find { |c| c.parameterize == @city }
  end
end
