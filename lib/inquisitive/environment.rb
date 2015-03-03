module Inquisitive
  module Environment
    include Inquisitive::Utils

    def truthy
      /true|yes|1/i
    end

    def inquires_about(env_var, opts={})

      env_accessor = opts.fetch(:with, env_var.downcase[/(.*?)(?=(?:_$|$))/])
      @__env_accessors__ ||= HashWithIndifferentAccess.new
      @__env_accessors__[env_accessor] = env_var

      mode = Inquisitive[ opts.fetch(:mode, :static).to_s ]

      if mode.dynamic?

        define_singleton_method :"#{env_accessor}" do
          Inquisitive[Parser[@__env_accessors__[__method__]]]
        end

      else

        @__cached_env__ ||= HashWithIndifferentAccess.new
        @__cached_env__[env_accessor] = Inquisitive[Parser[env_var]] if mode.static?

        define_singleton_method :"#{env_accessor}" do
          if @__cached_env__.has_key? __method__
            @__cached_env__[__method__]
          else
            @__cached_env__[__method__] = Inquisitive[Parser[@__env_accessors__[__method__]]]
          end
        end

      end

      present_if = opts.fetch(:present_if, nil)

      @__env_presence__ ||= HashWithIndifferentAccess.new
      @__env_presence__["#{env_accessor}?"] = present_if if present_if

      define_singleton_method :"#{env_accessor}?" do
        if @__env_presence__.has_key? __method__
          @__env_presence__[__method__] === send(predication(__method__))
        else
          Inquisitive.present? send(predication(__method__))
        end
      end

    end

  private

    module Parser
      class << self

        def [](var_name)
          result = if ENV.has_key? var_name

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
