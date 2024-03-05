require 'csv'
require 'uri'
require 'net/http'
require 'json'

class LeadIntegration
  CSV_FILE_PATH = 'lost-leads (1).csv'
  HTTP_STATUS_CSV_FILE_PATH = 'http_status_codes.csv'
  
  class << self
    def run
      # Executa a integração de leads
      leads = read_leads_from_csv
      response = post_leads(leads)
      save_http_status_code(response)
    end

    def read_leads_from_csv
      # Lê os leads do arquivo CSV e os armazena em uma lista
      leads = []
      File.open(CSV_FILE_PATH, 'r') do |file|
        file.each_line do |line|
          lead_data = line.chomp.split(',')
          lead = {}
          lead['id'] = lead_data[0]
          lead['created_time'] = lead_data[1]
          lead['ad_id'] = lead_data[2]
          lead['ad_name'] = lead_data[3]
          lead['adset_id'] = lead_data[4]
          lead['adset_name'] = lead_data[5]
          lead['campaign_id'] = lead_data[6]
          lead['campaign_name'] = lead_data[7]
          lead['form_id'] = lead_data[8]
          lead['form_name'] = lead_data[9]
          lead['is_organic'] = lead_data[10]
          lead['platform'] = lead_data[11]
          lead['nome_completo'] = lead_data[12]
          lead['email'] = lead_data[13]
          lead['telefone'] = lead_data[14]
          leads << lead
        end
      end
      leads
    end

    def post_leads(leads)
      # Envia os leads para um servidor usando uma solicitação POST
      uri = URI('https://httpbin.org/post')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request.body = { leads: leads }.to_json

      response = http.request(request)

      # Verifica se a solicitação foi bem-sucedida e exibe o resultado
      if response.code == '200'
        puts 'POST request successful'
        puts "Response body: #{response.body}"
      else
        puts 'POST request failed'
        puts "Response code: #{response.code}"
      end

      response
    end

    def save_http_status_code(response)
      # Salva o código de status HTTP em um arquivo CSV
      status_code = response.code
    
      CSV.open(HTTP_STATUS_CSV_FILE_PATH, 'a+') do |csv|
        csv << [status_code]
      end
    end
  end
end

# Executa a integração de leads quando o script é executado
LeadIntegration.run