require 'sinatra'
require 'slim'
require 'json'
require 'br/cpf'


get(%r{^(?!/api)}) { slim :index }

get '/api' do
  content_type :json
  Response.data(params).to_json
end






class Response
  def self.data(parameters)
    response = []
    parameters.each do |k,v|
      case k.to_sym
        when :email
          response << Validator::Email.new(v).instance_eval { as_json }
        when :cep
          response << Validator::Cpf.new(v).instance_eval { as_json }
        when :cpf
          response << Validator::Cpf.new(v).instance_eval { as_json }
      end
    end
    return response
  end
end




module Validator

  class Email
    attr_accessor :email

    def initialize(email)
      @email = email
    end

    def as_json
      { email: { valid: valid?, email: @email }.merge(metadata) }
    end

    # TODO
    # Metadata for emails, like provider, country and these stuffs.
    def metadata
      {}
    end

    def valid?
      regex = %r{^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))}.match(@email)

      !regex.nil?
    end

  end 


  class Cep
    def self.valid?(cep)

    end
  end



  class Cpf
    attr_accessor :cpf

    def initialize(cpf)
      @cpf = Parser::Numeric.delete_non_numeric(cpf)
    end


    def as_json
      { cpf: { valid: valid?, cpf: @cpf } }
    end


    def valid?
      BR::CPF.valid? @cpf
    end
  end
end



module Parser
  class Numeric
    def self.delete_non_numeric(non_numeric)
      return non_numeric.to_s.gsub(/[^0-9]/s, '')
    end
  end
end

