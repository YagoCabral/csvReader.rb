require_relative 'project'
require 'rspec/mocks'
require 'webmock/rspec'

RSpec.describe LeadIntegration do
  describe '.read_leads_from_csv' do
		# Simulando a leitura dos leads do CSV
		leads = LeadIntegration.read_leads_from_csv

    it 'should return an array of leads' do
			expect(leads).to be_an(Array)
			expect(leads).not_to be_empty
			expect(leads.first).to be_a(Hash)
    end

		it 'should return leads with all fields filled' do
			# Verifica se todos os campos dos leads estão preenchidos
			leads.each do |lead|
				expect(lead.keys).to contain_exactly('id', 'created_time', 'ad_id', 'ad_name', 
				'adset_id', 'adset_name', 'campaign_id', 'campaign_name', 'form_id', 'form_name', 
				'is_organic', 'platform', 'nome_completo', 'email', 'telefone')
			end
		end

		it 'should check if all lead IDs are unique' do
			# Verifica se todos os IDs dos leads são únicos
			ids = leads.map { |lead| lead['id'] }
  		expect(ids).to eq(ids.uniq)
		end
  end

  describe '.post_leads' do
		# Simulando um conjunto de leads para envio
		leads = [{ 'id' => '1', 'name' => 'Lead 1' }]

		it 'should make a POST request' do
			# Simula uma solicitação POST bem-sucedida e verifica se é feita corretamente
			stub_request(:post, "https://httpbin.org/post")
				.with(body: { leads: leads }.to_json)
				.to_return(status: 200)
	
			response = LeadIntegration.post_leads(leads)
		end

		it 'should correctly send lead data in the POST request body' do
			# Verifica se os dados dos leads são enviados corretamente no corpo da solicitação POST
			stub_request(:post, "https://httpbin.org/post")
				.with { |request| JSON.parse(request.body) == { 'leads' => leads } }
				.to_return(status: 200)
		
			LeadIntegration.post_leads(leads)
		end
	end

  describe '.save_http_status_code' do
		# Definindo o caminho do arquivo CSV
		HTTP_STATUS_CSV_FILE_PATH = 'http_status_codes.csv'
	
		before(:each) do
			File.delete(HTTP_STATUS_CSV_FILE_PATH) if File.exist?(HTTP_STATUS_CSV_FILE_PATH)
		end
	
		it 'should correctly create the CSV file' do
			# Simula uma resposta HTTP e verifica se o arquivo CSV é criado corretamente
			response = double('response', code: '200')
	
			expect(File).not_to exist(HTTP_STATUS_CSV_FILE_PATH)
	
			LeadIntegration.save_http_status_code(response)
	
			expect(File).to exist(HTTP_STATUS_CSV_FILE_PATH)
		end
	
		it 'should correctly save the HTTP status code in the CSV file' do
			# Simula uma resposta HTTP e verifica se o código de status é salvo corretamente no arquivo CSV
			response = double('response', code: '200')
	
			LeadIntegration.save_http_status_code(response)
	
			csv_content = CSV.read(HTTP_STATUS_CSV_FILE_PATH)
			expect(csv_content.last).to eq(['200'])
		end
	end
end