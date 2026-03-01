class PagesController < ApplicationController
  def home
  end

  def about
  end

  def simulation
  end

  def renovate
  end

  # Pages de simulation par région
  def simulation_region
    @region = params[:region]

    # Vérifier que la région est valide
    unless ['wallonie', 'flandre', 'bruxelles'].include?(@region)
      redirect_to simulation_path, alert: "Région non valide"
      return
    end
  end

  def simulation_primes
    @region = params[:region]

    unless ['wallonie', 'flandre', 'bruxelles'].include?(@region)
      redirect_to simulation_path, alert: "Région non valide"
      return
    end
  end

  def simulation_prets
    @region = params[:region]

    unless ['wallonie', 'flandre', 'bruxelles'].include?(@region)
      redirect_to simulation_path, alert: "Région non valide"
      return
    end
  end
end
