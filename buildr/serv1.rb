require 'sinatra'
require 'yaml'

# Define the path to your YAML file
YAML_FILE_PATH = 'data.yml'

# Load YAML data from file
def load_data
  YAML.load_file(YAML_FILE_PATH) || []
end

# Save YAML data to file
def save_data(data)
  File.open(YAML_FILE_PATH, 'w') { |file| file.write(data.to_yaml) }
end

# Route to display the form and existing data
get '/' do
  @data = load_data
  erb :form
end

# Route to receive form submission and update the file
post '/add_element' do
  new_element = {
    'nom' => params['nom'],
    'coût' => params['coût'],
    'symboles' => params['symboles'].split(',').map(&:strip),
    'note' => params['note']
  }
  
  data = load_data
  data << new_element
  save_data(data)
  
  redirect '/'
end


# Route to handle editing an element
post '/edit_element' do
  index = params['edit_index'].to_i
  @data = load_data
  @edit_mode = true
  @edit_index = index
  erb :form
end

# Route to update an element
post '/update_element' do
  index = params['edit_index'].to_i
  data = load_data
  data[index] = {
    'nom' => params['nom'],
    'coût' => params['coût'],
    'symboles' => params['symboles'].split(',').map(&:strip),
    'note' => params['note']
  }
  save_data(data)
  redirect '/'
end