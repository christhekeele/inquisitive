module Inquisitive
  module Environment
    include Inquisitive

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
          if ENV.has_key? var_name
            
            env_var = ENV[var_name]
            if env_var.include? ','
              env_var.split(',').map(&:strip)
            else
              env_var
            end

          elsif env_vars = can_find_env_keys_from(var_name)

            env_vars.reduce({}) do |hash, key|
              hash[key_for(key, var_name)] = Inquisitive[Parser[key]]
              hash
            end

          else
            ""
          end
        end
        
        def can_find_env_keys_from(var_name)
          found = env_keys_from(var_name)
          found.empty? ? nil : found
        end

        def env_keys_from(var_name)
          ENV.keys.select do |key|
            key =~ /^#{var_name}__/
          end
        end

        def key_for(env_key, var_name)
          env_key.gsub("#{var_name}__", '').downcase
        end

      end
    end

  end
end
