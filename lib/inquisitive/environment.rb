require 'inquisitive/utils'

module Inquisitive
  module Environment
    include Inquisitive::Utils

    def truthy
      /true|yes|1/i
    end

    def inquires_about(env_var, opts={})

      env_accessor = opts.fetch(:with, env_var.downcase[/(.*?)(?=(?:_$|$))/]).to_sym
      env_presence = :"#{env_accessor}?"
      env_default  = opts[:default]
      present_if = opts[:present_if]

      define_singleton_method env_presence do |with_default: true|
        !!(with_default and env_default) || if present_if
          present_if === Inquisitive[Parser[env_var]]
        else
          Inquisitive.present? Inquisitive[Parser[env_var]]
        end
      end

      define_singleton_method env_accessor do
        Inquisitive[
          if send env_presence, with_default: false
            Parser[env_var]
          else
            env_default
          end
        ]
      end

    end

  private

    module Parser
      class << self

        def [](var_name)
          result = if ENV.has_key? var_name.to_s

            env_var = ENV[var_name]
            if env_var.include? ','
              env_var.split(',').map(&:strip)
            else
              env_var
            end

          elsif env_vars = can_find_env_keys_from(var_name)

            Hash[].tap do |hash|
              env_vars.each do |key|
                set_hash_value_of hash, key
              end
            end

          end

          replace_empty result
        end

        def can_find_env_keys_from(var_name)
          found = env_keys_from(var_name)
          Inquisitive.present?(found) ? found : nil
        end

        def env_keys_from(var_name)
          ENV.keys.select do |key|
            key =~ /^#{var_name}__/
          end
        end

        def set_hash_value_of(hash, var)
          keypath = var.split('__').map(&:downcase)
          keypath.shift # discard variable namespace
          hash.tap do |hash|
            keypath.reduce(hash) do |namespace, key|

              namespace[key] = if key == keypath.last
                replace_empty Inquisitive[Parser[var]]
              else
                if namespace[key].kind_of? ::Hash
                  namespace[key]
                else
                  Hash.new
                end
              end

            end
          end
        end

        def replace_empty(value)
          Inquisitive.present?(value) ? value : NilClass.new(nil)
        end

      end
    end

  end
end
