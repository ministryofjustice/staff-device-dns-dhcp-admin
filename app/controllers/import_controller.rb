class ImportController < ApplicationController
  def index
    authorize! :manage, :import
  end

  def create
    authorize! :manage, :import
    @result = update_dhcp_config.call(nil, -> { run_import })
    if @result.success?
      redirect_to import_path, notice: "Successfully ran the import."
    else
      render :index
    end
  end

  private

  def import_params
    params.require(:import).permit(:file, :kea_config_file, :fits_id, :subnet_list)
  end

  def config_parser
    DhcpConfigParser.new(
      kea_config_filepath: import_params[:kea_config_file],
      legacy_config_filepath: import_params[:file]
    )
  end

  def run_import
    config_parser.run(
      fits_id: import_params[:fits_id],
      subnet_list: import_params[:subnet_list].split(",").map(&:squish)
    )
  end
end

### Find a way to pass kea-config.json to DhcpConfigParser
# Should end up with a file object, this may cause us to require DhcpConfigParser to be able to take data as an input, instead of having to look to the filesystem.
# refactor - scrap the idea of pulling the keaconfig from the config file
