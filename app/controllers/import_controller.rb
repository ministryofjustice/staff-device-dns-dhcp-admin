class ImportController < ApplicationController
  def index
    authorize! :manage, :import
  end
  
  def create
    authorize! :manage, :import
    
    config_parser = DhcpConfigParser.new(
      kea_config_filepath: "kea-config.json",
      legacy_config_filepath: import_params[:file]
    )

    if config_parser.run
      redirect_to import_path, notice: "Successfully ran the import."
    else
      render :index, error: "Failed to run the import." 
    end
  end

  private

  def import_params
    params.require(:import).permit(:file)
  end
   
end

### Find a way to pass kea-config.json to DhcpConfigParser
# Also want to be able to pull from S3
# Should end up with a file object, this may cause us to require DhcpConfigParser to be able to take data as an input, instead of having to look to the filesystem. 
